#pragma once

#include "CoreMinimal.h"
#include "PFUTypes.generated.h"

UENUM(BlueprintType)
enum class EPFUArchetype : uint8
{
    Agile,
    Guardian,
    Bruiser,
    Mystic
};

UENUM(BlueprintType)
enum class EPFUElement : uint8
{
    Electric,
    Fire,
    Ice,
    Shadow,
    Stone,
    Wind
};

UENUM(BlueprintType)
enum class EPFUControlMode : uint8
{
    Manual,
    Autonomous
};

UENUM(BlueprintType)
enum class EPFUMatchState : uint8
{
    CharacterSelect,
    Countdown,
    Fighting,
    RoundOver
};

USTRUCT(BlueprintType)
struct FPFUFighterStats
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Vitality = 20;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Power = 20;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Defense = 20;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Speed = 20;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Technique = 20;

    int32 Total() const { return Vitality + Power + Defense + Speed + Technique; }
};

USTRUCT(BlueprintType)
struct FPFUAbilitySpec
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName Id = NAME_None;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Damage = 8.0f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Range = 145.0f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Cooldown = 0.7f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Knockback = 120.0f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 BudgetCost = 20;
};

USTRUCT(BlueprintType)
struct FPFUFighterProfile
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadOnly) FString DisplayName;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FString SourcePrompt;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 Seed = 0;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) EPFUArchetype Archetype = EPFUArchetype::Agile;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) EPFUElement Element = EPFUElement::Shadow;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName BodyModule = TEXT("Body_Agile");
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName ArmorModule = TEXT("Armor_Light");
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName WeaponModule = TEXT("Weapon_Blades");
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FLinearColor PrimaryColor = FLinearColor(0.03f, 0.05f, 0.1f);
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FLinearColor AccentColor = FLinearColor::Cyan;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FPFUFighterStats Stats;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FPFUAbilitySpec StandardAttack;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FPFUAbilitySpec SpecialAttack;
};

namespace PFULimits
{
    constexpr int32 AttributeBudget = 100;
    constexpr int32 MinAttribute = 8;
    constexpr int32 MaxAttribute = 36;
    constexpr int32 AbilityBudget = 60;
    constexpr float MinDamage = 3.0f;
    constexpr float MaxDamage = 30.0f;
    constexpr float MinCooldown = 0.30f;
    constexpr float MaxCooldown = 6.0f;
    constexpr float MinRange = 90.0f;
    constexpr float MaxRange = 300.0f;
}

