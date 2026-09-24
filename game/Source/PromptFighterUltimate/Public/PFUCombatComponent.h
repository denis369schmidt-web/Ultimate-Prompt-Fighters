#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "PFUTypes.h"
#include "PFUCombatComponent.generated.h"

UCLASS(ClassGroup=(PFU), meta=(BlueprintSpawnableComponent))
class PROMPTFIGHTERULTIMATE_API UPFUCombatComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UPFUCombatComponent();

    void InitializeFromProfile(const FPFUFighterProfile& InProfile);
    bool TryStandardAttack(float FacingSign);
    bool TrySpecialAttack(float FacingSign);
    float ReceiveCombatDamage(float RawDamage, float Knockback, float SourceX);
    void ResetCombat();

    UFUNCTION(BlueprintPure) float GetHealth() const { return Health; }
    UFUNCTION(BlueprintPure) float GetMaxHealth() const { return MaxHealth; }
    UFUNCTION(BlueprintPure) float GetHealthPercent() const { return MaxHealth > 0.0f ? Health / MaxHealth : 0.0f; }
    UFUNCTION(BlueprintPure) const FPFUFighterProfile& GetProfile() const { return Profile; }
    UFUNCTION(BlueprintPure) bool IsDefeated() const { return Health <= 0.0f; }

private:
    bool PerformAttack(const FPFUAbilitySpec& Ability, float FacingSign, double& CooldownEnd);

    UPROPERTY() FPFUFighterProfile Profile;
    UPROPERTY() float Health = 100.0f;
    UPROPERTY() float MaxHealth = 100.0f;
    double StandardCooldownEnd = 0.0;
    double SpecialCooldownEnd = 0.0;
};

