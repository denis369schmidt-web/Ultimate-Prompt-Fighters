#include "PFUCombatComponent.h"

#include "PFUFighterCharacter.h"
#include "Engine/World.h"
#include "GameFramework/CharacterMovementComponent.h"

UPFUCombatComponent::UPFUCombatComponent()
{
    PrimaryComponentTick.bCanEverTick = false;
}

void UPFUCombatComponent::InitializeFromProfile(const FPFUFighterProfile& InProfile)
{
    Profile = InProfile;
    MaxHealth = 85.0f + static_cast<float>(Profile.Stats.Vitality) * 2.0f;
    ResetCombat();
}

void UPFUCombatComponent::ResetCombat()
{
    Health = MaxHealth;
    StandardCooldownEnd = 0.0;
    SpecialCooldownEnd = 0.0;
}

bool UPFUCombatComponent::TryStandardAttack(float FacingSign)
{
    return PerformAttack(Profile.StandardAttack, FacingSign, StandardCooldownEnd);
}

bool UPFUCombatComponent::TrySpecialAttack(float FacingSign)
{
    return PerformAttack(Profile.SpecialAttack, FacingSign, SpecialCooldownEnd);
}

bool UPFUCombatComponent::PerformAttack(const FPFUAbilitySpec& Ability, float FacingSign, double& CooldownEnd)
{
    if (!GetWorld() || IsDefeated()) return false;
    const double Now = GetWorld()->GetTimeSeconds();
    if (Now < CooldownEnd) return false;
    CooldownEnd = Now + FMath::Clamp(Ability.Cooldown, PFULimits::MinCooldown, PFULimits::MaxCooldown);

    APFUFighterCharacter* OwnerFighter = Cast<APFUFighterCharacter>(GetOwner());
    if (!OwnerFighter || !OwnerFighter->IsCombatEnabled()) return false;
    const float Range = FMath::Clamp(Ability.Range, PFULimits::MinRange, PFULimits::MaxRange);
    const FVector Center = OwnerFighter->GetActorLocation() + FVector(FMath::Sign(FacingSign) * Range * 0.55f, 0.0f, 55.0f);
    TArray<FOverlapResult> Hits;
    FCollisionObjectQueryParams Objects;
    Objects.AddObjectTypesToQuery(ECC_Pawn);
    FCollisionQueryParams Params(SCENE_QUERY_STAT(PFUAttack), false, OwnerFighter);
    GetWorld()->OverlapMultiByObjectType(Hits, Center, FQuat::Identity, Objects, FCollisionShape::MakeSphere(Range * 0.52f), Params);

    TSet<TWeakObjectPtr<AActor>> DamagedThisAttack;
    for (const FOverlapResult& Hit : Hits)
    {
        APFUFighterCharacter* Target = Cast<APFUFighterCharacter>(Hit.GetActor());
        if (!Target || Target == OwnerFighter || DamagedThisAttack.Contains(Target)) continue;
        DamagedThisAttack.Add(Target);
        Target->GetCombatComponent()->ReceiveCombatDamage(
            FMath::Clamp(Ability.Damage, PFULimits::MinDamage, PFULimits::MaxDamage),
            Ability.Knockback,
            OwnerFighter->GetActorLocation().X);
    }
    return true;
}

float UPFUCombatComponent::ReceiveCombatDamage(float RawDamage, float Knockback, float SourceX)
{
    if (IsDefeated()) return 0.0f;
    const float DefenseMultiplier = FMath::Clamp(1.0f - Profile.Stats.Defense * 0.012f, 0.55f, 0.9f);
    const float AppliedDamage = FMath::Clamp(RawDamage, PFULimits::MinDamage, PFULimits::MaxDamage) * DefenseMultiplier;
    Health = FMath::Max(0.0f, Health - AppliedDamage);

    if (APFUFighterCharacter* Fighter = Cast<APFUFighterCharacter>(GetOwner()))
    {
        const float Direction = FMath::Sign(Fighter->GetActorLocation().X - SourceX);
        Fighter->LaunchCharacter(FVector(Direction * FMath::Clamp(Knockback, 50.0f, 350.0f), 0.0f, 55.0f), true, false);
        Fighter->PlayHitReaction();
        if (Health <= 0.0f) Fighter->HandleDefeated();
    }
    return AppliedDamage;
}

