#include "PFUAIController.h"

#include "PFUFighterCharacter.h"
#include "PFUCombatComponent.h"

APFUAIController::APFUAIController()
{
    PrimaryActorTick.bCanEverTick = true;
}

void APFUAIController::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    APFUFighterCharacter* Fighter = Cast<APFUFighterCharacter>(GetPawn());
    if (!Fighter || !Target || !Fighter->IsCombatEnabled() || Target->GetCombatComponent()->IsDefeated()) return;
    const float Distance = FMath::Abs(Target->GetActorLocation().X - Fighter->GetActorLocation().X);
    const float DesiredRange = Fighter->GetCombatComponent()->GetProfile().StandardAttack.Range * 0.82f;
    if (Distance > DesiredRange)
        Fighter->MoveHorizontal(FMath::Sign(Target->GetActorLocation().X - Fighter->GetActorLocation().X));
    else if (Distance < DesiredRange * 0.52f)
        Fighter->MoveHorizontal(-FMath::Sign(Target->GetActorLocation().X - Fighter->GetActorLocation().X));

    DecisionCooldown -= DeltaSeconds;
    if (DecisionCooldown <= 0.0f && Distance <= Fighter->GetCombatComponent()->GetProfile().SpecialAttack.Range)
    {
        FRandomStream Random(static_cast<int32>(GetWorld()->GetTimeSeconds() * 1000.0) ^ Fighter->GetCombatComponent()->GetProfile().Seed);
        if (Random.FRand() < 0.3f) Fighter->SpecialAttack();
        else Fighter->StandardAttack();
        DecisionCooldown = Random.FRandRange(0.16f, 0.48f);
    }
}

