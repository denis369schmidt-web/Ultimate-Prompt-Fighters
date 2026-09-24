#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "PFUTypes.h"
#include "PFUFighterCharacter.generated.h"

class UPFUCombatComponent;
class UPFUCharacterAssembler;

UCLASS()
class PROMPTFIGHTERULTIMATE_API APFUFighterCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    APFUFighterCharacter();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;

    void InitializeFighter(const FPFUFighterProfile& InProfile, int32 InPlayerIndex);
    void MoveHorizontal(float AxisValue);
    void StandardAttack();
    void SpecialAttack();
    void SetOpponent(APFUFighterCharacter* InOpponent) { Opponent = InOpponent; }
    void SetCombatEnabled(bool bEnabled) { bCombatEnabled = bEnabled; }
    bool IsCombatEnabled() const { return bCombatEnabled; }
    float GetFacingSign() const { return FacingSign; }
    int32 GetPlayerIndex() const { return PlayerIndex; }
    UPFUCombatComponent* GetCombatComponent() const { return CombatComponent; }
    void PlayHitReaction();
    void HandleDefeated();

private:
    UPROPERTY(VisibleAnywhere) TObjectPtr<UPFUCombatComponent> CombatComponent;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UPFUCharacterAssembler> CharacterAssembler;
    UPROPERTY() TObjectPtr<APFUFighterCharacter> Opponent;
    FPFUFighterProfile Profile;
    int32 PlayerIndex = 0;
    float FacingSign = 1.0f;
    bool bCombatEnabled = false;
    float HitFlashRemaining = 0.0f;
};

