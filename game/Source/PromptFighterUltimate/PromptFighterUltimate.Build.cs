using UnrealBuildTool;

public class PromptFighterUltimate : ModuleRules
{
    public PromptFighterUltimate(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new[]
        {
            "Core", "CoreUObject", "Engine", "InputCore", "UMG", "AIModule"
        });
        PrivateDependencyModuleNames.AddRange(new[]
        {
            "Slate", "SlateCore"
        });
    }
}
