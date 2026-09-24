#include "PFUFighterCharacter.h"

#include "PFUCharacterAssembler.h"
#include "PFUCombatComponent.h"
#include "PFUMatchGameMode.h"
#include "GameFramework/CharacterMovementComponent.h"

APFUFighterCharacter::APFUFighterCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
    CombatComponent = CreateDefaultSubobject<UPFUCombatComponent>(TEXT("CombatComponent"));
    CharacterAssembler = CreateDefaultSubobject<UPFUCharacterAssembler>(TEXT("CharacterAssembler"));
    GetMesh()->SetVisibility(false);
    GetCharacterMovement()->bConstrainToPlane = true;
    GetCharacterMovement()->SetPlaneConstraintNormal(FVector(0, 1, 0));
    GetCharacterMovement()->bSnapToPlaneAtStart = true;
    GetCharacterMovement()->bRunPhysicsWithNoController = true;
    GetCharacterMovement()->MaxWalkSpeed = 420.0f;
    GetCharacterMovement()->BrakingDecelerationWalking = 1800.0f;
}

void APFUFighterCharacter::BeginPlay()
{
    Super::BeginPlay();
    SetActorLocation(FVector(GetActorLocation().X, 0.0f, GetActorLocation().Z));
}

void APFUFighterCharacter::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if (Opponent && !Opponent->GetCombatComponent()->IsDefeated())
    {
        FacingSign = FMath::Sign(Opponent->GetActorLocation().X - GetActorLocation().X);
        if (FMath::IsNearlyZero(FacingSign)) FacingSign = PlayerIndex == 0 ? 1.0f : -1.0f;
        SetActorRotation(FRotator(0, FacingSign > 0.0f ? 0.0f : 180.0f, 0));
    }
    HitFlashRemaining = FMath::Max(0.0f, HitFlashRemaining - DeltaSeconds);
}

void APFUFighterCharacter::InitializeFighter(const FPFUFighterProfile& InProfile, int32 InPlayerIndex)
{
    Profile = InProfile;
    PlayerIndex = InPlayerIndex;
    CombatComponent->InitializeFromProfile(Profile);
    CharacterAssembler->AssembleFallback(Profile);
    GetCharacterMovement()->MaxWalkSpeed = FMath::Clamp(230.0f + Profile.Stats.Speed * 8.0f, 280.0f, 520.0f);
}

void APFUFighterCharacter::MoveHorizontal(float AxisValue)
{
    if (!bCombatEnabled || CombatComponent->IsDefeated()) return;
    AddMovementInput(FVector::ForwardVector, FMath::Clamp(AxisValue, -1.0f, 1.0f));
}

void APFUFighterCharacter::StandardAttack()
{
    if (bCombatEnabled) CombatComponent->TryStandardAttack(FacingSign);
}

void APFUFighterCharacter::SpecialAttack()
{
    if (bCombatEnabled) CombatComponent->TrySpecialAttack(FacingSign);
}

void APFUFighterCharacter::PlayHitReaction()
{
    HitFlashRemaining = 0.16f;
}

void APFUFighterCharacter::HandleDefeated()
{
    bCombatEnabled = false;
    if (APFUMatchGameMode* Match = GetWorld()->GetAuthGameMode<APFUMatchGameMode>())
        Match->NotifyFighterDefeated(this);
}

