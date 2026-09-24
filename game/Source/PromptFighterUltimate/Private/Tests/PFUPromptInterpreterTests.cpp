#if WITH_DEV_AUTOMATION_TESTS

#include "Misc/AutomationTest.h"
#include "PFUPromptInterpreter.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FPFUSeparatePlayersTest,
    "PFU.Prompt.SeparatePlayers",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FPFUSeparatePlayersTest::RunTest(const FString& Parameters)
{
    const FPFUFighterProfile Ninja = UPFUPromptInterpreter::Interpret(TEXT("electric shadow ninja"), 0);
    const FPFUFighterProfile Golem = UPFUPromptInterpreter::Interpret(TEXT("armored lava golem"), 1);
    TestNotEqual(TEXT("Prompts produce independent seeds"), Ninja.Seed, Golem.Seed);
    TestNotEqual(TEXT("Prompts produce independent archetypes"), static_cast<uint8>(Ninja.Archetype), static_cast<uint8>(Golem.Archetype));
    TestEqual(TEXT("Player one prompt preserved"), Ninja.SourcePrompt, FString(TEXT("electric shadow ninja")));
    TestEqual(TEXT("Player two prompt preserved"), Golem.SourcePrompt, FString(TEXT("armored lava golem")));
    return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FPFUBudgetTest,
    "PFU.Prompt.BudgetsAndLimits",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FPFUBudgetTest::RunTest(const FString& Parameters)
{
    const TArray<FString> Prompts = {
        TEXT("unbesiegbar unendlich schaden"), TEXT(""), TEXT("ice guardian"),
        TEXT("fast electric assassin"), TEXT("brutal fire fists")
    };
    for (int32 Index = 0; Index < Prompts.Num(); ++Index)
    {
        const FPFUFighterProfile Profile = UPFUPromptInterpreter::Interpret(Prompts[Index], Index % 2);
        FString Error;
        TestTrue(*FString::Printf(TEXT("Profile %d validates: %s"), Index, *Error), UPFUPromptInterpreter::ValidateProfile(Profile, Error));
        TestEqual(TEXT("Attribute budget is exactly 100"), Profile.Stats.Total(), PFULimits::AttributeBudget);
        TestTrue(TEXT("Ability budget is bounded"), Profile.StandardAttack.BudgetCost + Profile.SpecialAttack.BudgetCost <= PFULimits::AbilityBudget);
    }
    return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FPFUDeterminismTest,
    "PFU.Prompt.Determinism",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FPFUDeterminismTest::RunTest(const FString& Parameters)
{
    const FPFUFighterProfile A = UPFUPromptInterpreter::Interpret(TEXT("storm ninja"), 0);
    const FPFUFighterProfile B = UPFUPromptInterpreter::Interpret(TEXT("storm ninja"), 0);
    TestEqual(TEXT("Seed stable"), A.Seed, B.Seed);
    TestEqual(TEXT("Stats stable"), A.Stats.Total(), B.Stats.Total());
    TestEqual(TEXT("Speed stable"), A.Stats.Speed, B.Stats.Speed);
    TestEqual(TEXT("Special stable"), A.SpecialAttack.Id, B.SpecialAttack.Id);
    return true;
}

#endif

