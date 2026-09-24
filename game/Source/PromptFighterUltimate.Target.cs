using UnrealBuildTool;
using System.Collections.Generic;

public class PromptFighterUltimateTarget : TargetRules
{
    public PromptFighterUltimateTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("PromptFighterUltimate");
    }
}

