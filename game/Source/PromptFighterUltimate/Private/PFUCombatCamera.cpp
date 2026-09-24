#include "PFUCombatCamera.h"

#include "Camera/CameraComponent.h"
#include "PFUFighterCharacter.h"

APFUCombatCamera::APFUCombatCamera()
{
    PrimaryActorTick.bCanEverTick = true;
    GetCameraComponent()->SetFieldOfView(47.0f);
}

void APFUCombatCamera::SetFighters(APFUFighterCharacter* InA, APFUFighterCharacter* InB)
{
    FighterA = InA;
    FighterB = InB;
}

void APFUCombatCamera::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if (!FighterA || !FighterB) return;
    const FVector Midpoint = (FighterA->GetActorLocation() + FighterB->GetActorLocation()) * 0.5f;
    const float Separation = FMath::Abs(FighterA->GetActorLocation().X - FighterB->GetActorLocation().X);
    const float Distance = FMath::Clamp(760.0f + Separation * 0.34f, 820.0f, 1150.0f);
    const FVector Desired(Midpoint.X, -Distance, 270.0f);
    SetActorLocation(FMath::VInterpTo(GetActorLocation(), Desired, DeltaSeconds, 4.0f));
    const FRotator Look = (FVector(Midpoint.X, 0, 100) - GetActorLocation()).Rotation();
    SetActorRotation(FMath::RInterpTo(GetActorRotation(), Look, DeltaSeconds, 5.0f));
}

