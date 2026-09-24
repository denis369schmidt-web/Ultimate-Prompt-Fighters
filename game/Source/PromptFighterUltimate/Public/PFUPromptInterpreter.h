#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "PFUTypes.h"
#include "PFUPromptInterpreter.generated.h"

UCLASS(BlueprintType)
class PROMPTFIGHTERULTIMATE_API UPFUPromptInterpreter : public UObject
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintPure, Category="PFU|Prompt")
    static FPFUFighterProfile Interpret(const FString& Prompt, int32 PlayerIndex);

    static uint32 StableSeed(const FString& Prompt, int32 PlayerIndex);
    static bool ValidateProfile(const FPFUFighterProfile& Profile, FString& OutError);

private:
    static FString SanitizePrompt(const FString& Prompt);
    static void AllocateStats(FRandomStream& Random, EPFUArchetype Archetype, FPFUFighterStats& OutStats);
    static FPFUAbilitySpec MakeStandard(const FPFUFighterStats& Stats, EPFUArchetype Archetype);
    static FPFUAbilitySpec MakeSpecial(const FPFUFighterStats& Stats, EPFUElement Element, EPFUArchetype Archetype);
};

