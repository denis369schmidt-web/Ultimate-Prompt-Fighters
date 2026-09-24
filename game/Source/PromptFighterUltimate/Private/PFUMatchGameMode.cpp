#include "PFUMatchGameMode.h"

#include "PFUAIController.h"
#include "PFUCombatCamera.h"
#include "PFUCombatComponent.h"
#include "PFUFighterCharacter.h"
#include "PFUMatchWidget.h"
#include "PFUPlayerController.h"
#include "PFUPromptInterpreter.h"
#include "Blueprint/UserWidget.h"
#include "Components/DirectionalLightComponent.h"
#include "Components/SkyLightComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/World.h"
#include "Engine/DirectionalLight.h"
#include "Engine/SkyLight.h"
#include "Engine/StaticMeshActor.h"

APFUMatchGameMode::APFUMatchGameMode()
{
    PrimaryActorTick.bCanEverTick = true;
    DefaultPawnClass = nullptr;
    PlayerControllerClass = APFUPlayerController::StaticClass();
}

void APFUMatchGameMode::BeginPlay()
{
    Super::BeginPlay();
    CreateFallbackArena();
    if (APlayerController* Controller = GetWorld()->GetFirstPlayerController())
    {
        MatchWidget = CreateWidget<UPFUMatchWidget>(Controller, UPFUMatchWidget::StaticClass());
        if (MatchWidget) MatchWidget->AddToViewport();
    }
}

void APFUMatchGameMode::CreateFallbackArena()
{
    UStaticMesh* Cube = LoadObject<UStaticMesh>(nullptr, TEXT("/Engine/BasicShapes/Cube.Cube"));
    if (!Cube) return;
    auto SpawnBlock = [this, Cube](const FVector& Location, const FVector& Scale)
    {
        AStaticMeshActor* Block = GetWorld()->SpawnActor<AStaticMeshActor>(Location, FRotator::ZeroRotator);
        if (Block)
        {
            Block->GetStaticMeshComponent()->SetStaticMesh(Cube);
            Block->SetActorScale3D(Scale);
            Block->GetStaticMeshComponent()->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
            ArenaActors.Add(Block);
        }
    };
    SpawnBlock(FVector(0, 0, -35), FVector(13.0f, 2.0f, 0.35f));
    SpawnBlock(FVector(-700, 0, 150), FVector(0.3f, 2.0f, 3.0f));
    SpawnBlock(FVector(700, 0, 150), FVector(0.3f, 2.0f, 3.0f));
    ADirectionalLight* Moon = GetWorld()->SpawnActor<ADirectionalLight>(FVector(0, -200, 500), FRotator(-38, -28, 0));
    if (Moon)
    {
        Moon->GetLightComponent()->SetIntensity(4.0f);
        Moon->GetLightComponent()->SetLightColor(FLinearColor(0.22f, 0.42f, 1.0f));
        ArenaActors.Add(Moon);
    }
    ASkyLight* Sky = GetWorld()->SpawnActor<ASkyLight>();
    if (Sky)
    {
        Sky->GetLightComponent()->SetIntensity(0.45f);
        ArenaActors.Add(Sky);
    }
}

void APFUMatchGameMode::DestroyCurrentActors()
{
    for (AActor* Actor : { Cast<AActor>(AIControllerOne), Cast<AActor>(AIControllerTwo), Cast<AActor>(FighterOne), Cast<AActor>(FighterTwo), Cast<AActor>(CombatCamera) })
        if (IsValid(Actor)) Actor->Destroy();
    AIControllerOne = nullptr; AIControllerTwo = nullptr; FighterOne = nullptr; FighterTwo = nullptr; CombatCamera = nullptr;
}

void APFUMatchGameMode::StartMatchFromPrompts(const FString& PlayerOnePrompt, const FString& PlayerTwoPrompt, bool bAutonomous)
{
    DestroyCurrentActors();
    LastPromptOne = PlayerOnePrompt;
    LastPromptTwo = PlayerTwoPrompt;
    ResultText.Reset();
    RemainingTime = 90.0f;
    ControlMode = bAutonomous ? EPFUControlMode::Autonomous : EPFUControlMode::Manual;

    const FPFUFighterProfile ProfileOne = UPFUPromptInterpreter::Interpret(PlayerOnePrompt, 0);
    const FPFUFighterProfile ProfileTwo = UPFUPromptInterpreter::Interpret(PlayerTwoPrompt, 1);
    FActorSpawnParameters Params;
    FighterOne = GetWorld()->SpawnActor<APFUFighterCharacter>(APFUFighterCharacter::StaticClass(), FVector(-260, 0, 110), FRotator::ZeroRotator, Params);
    FighterTwo = GetWorld()->SpawnActor<APFUFighterCharacter>(APFUFighterCharacter::StaticClass(), FVector(260, 0, 110), FRotator(0, 180, 0), Params);
    if (!FighterOne || !FighterTwo) { FinishMatch(TEXT("Fehler: Kaempfer konnten nicht erzeugt werden.")); return; }
    FighterOne->InitializeFighter(ProfileOne, 0);
    FighterTwo->InitializeFighter(ProfileTwo, 1);
    FighterOne->SetOpponent(FighterTwo);
    FighterTwo->SetOpponent(FighterOne);
    FighterOne->SetCombatEnabled(true);
    FighterTwo->SetCombatEnabled(true);

    if (APFUPlayerController* Controller = Cast<APFUPlayerController>(GetWorld()->GetFirstPlayerController()))
        Controller->SetFighters(bAutonomous ? nullptr : FighterOne, bAutonomous ? nullptr : FighterTwo);

    if (bAutonomous)
    {
        AIControllerOne = GetWorld()->SpawnActor<APFUAIController>();
        AIControllerTwo = GetWorld()->SpawnActor<APFUAIController>();
        AIControllerOne->Possess(FighterOne); AIControllerOne->SetTarget(FighterTwo);
        AIControllerTwo->Possess(FighterTwo); AIControllerTwo->SetTarget(FighterOne);
    }

    CombatCamera = GetWorld()->SpawnActor<APFUCombatCamera>(APFUCombatCamera::StaticClass(), FVector(0, -900, 270), FRotator::ZeroRotator, Params);
    if (CombatCamera)
    {
        CombatCamera->SetFighters(FighterOne, FighterTwo);
        if (APlayerController* Controller = GetWorld()->GetFirstPlayerController()) Controller->SetViewTarget(CombatCamera);
    }
    MatchState = EPFUMatchState::Fighting;
}

void APFUMatchGameMode::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if (MatchState == EPFUMatchState::Fighting)
    {
        RemainingTime = FMath::Max(0.0f, RemainingTime - DeltaSeconds);
        if (RemainingTime <= 0.0f) FinishByTime();
    }
    const float HealthOne = FighterOne ? FighterOne->GetCombatComponent()->GetHealthPercent() : 1.0f;
    const float HealthTwo = FighterTwo ? FighterTwo->GetCombatComponent()->GetHealthPercent() : 1.0f;
    if (MatchWidget) MatchWidget->UpdateMatch(HealthOne, HealthTwo, RemainingTime, ResultText);
}

void APFUMatchGameMode::NotifyFighterDefeated(APFUFighterCharacter* Defeated)
{
    if (MatchState != EPFUMatchState::Fighting) return;
    if (FighterOne && FighterTwo && FighterOne->GetCombatComponent()->IsDefeated() && FighterTwo->GetCombatComponent()->IsDefeated())
        FinishMatch(TEXT("Unentschieden"));
    else FinishMatch(Defeated == FighterOne ? TEXT("Spieler 2 gewinnt") : TEXT("Spieler 1 gewinnt"));
}

void APFUMatchGameMode::FinishByTime()
{
    if (!FighterOne || !FighterTwo) { FinishMatch(TEXT("Unentschieden")); return; }
    const float A = FighterOne->GetCombatComponent()->GetHealthPercent();
    const float B = FighterTwo->GetCombatComponent()->GetHealthPercent();
    if (FMath::IsNearlyEqual(A, B, 0.01f)) FinishMatch(TEXT("Unentschieden nach Zeit"));
    else FinishMatch(A > B ? TEXT("Spieler 1 gewinnt nach Zeit") : TEXT("Spieler 2 gewinnt nach Zeit"));
}

void APFUMatchGameMode::FinishMatch(const FString& Result)
{
    MatchState = EPFUMatchState::RoundOver;
    ResultText = Result;
    if (FighterOne) FighterOne->SetCombatEnabled(false);
    if (FighterTwo) FighterTwo->SetCombatEnabled(false);
}

void APFUMatchGameMode::RestartCurrentMatch()
{
    if (!LastPromptOne.IsEmpty() || !LastPromptTwo.IsEmpty())
        StartMatchFromPrompts(LastPromptOne, LastPromptTwo, ControlMode == EPFUControlMode::Autonomous);
}
