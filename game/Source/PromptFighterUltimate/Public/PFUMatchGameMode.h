#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "PFUTypes.h"
#include "PFUMatchGameMode.generated.h"

class APFUFighterCharacter;
class APFUAIController;
class APFUCombatCamera;
class UPFUMatchWidget;

UCLASS()
class PROMPTFIGHTERULTIMATE_API APFUMatchGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    APFUMatchGameMode();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    void StartMatchFromPrompts(const FString& PlayerOnePrompt, const FString& PlayerTwoPrompt, bool bAutonomous);
    void RestartCurrentMatch();
    void NotifyFighterDefeated(APFUFighterCharacter* Defeated);

private:
    void CreateFallbackArena();
    void DestroyCurrentActors();
    void FinishByTime();
    void FinishMatch(const FString& Result);

    UPROPERTY() TObjectPtr<APFUFighterCharacter> FighterOne;
    UPROPERTY() TObjectPtr<APFUFighterCharacter> FighterTwo;
    UPROPERTY() TObjectPtr<APFUAIController> AIControllerOne;
    UPROPERTY() TObjectPtr<APFUAIController> AIControllerTwo;
    UPROPERTY() TObjectPtr<APFUCombatCamera> CombatCamera;
    UPROPERTY() TObjectPtr<UPFUMatchWidget> MatchWidget;
    UPROPERTY() TArray<TObjectPtr<AActor>> ArenaActors;
    FString LastPromptOne;
    FString LastPromptTwo;
    FString ResultText;
    EPFUControlMode ControlMode = EPFUControlMode::Manual;
    EPFUMatchState MatchState = EPFUMatchState::CharacterSelect;
    float RemainingTime = 90.0f;
};
