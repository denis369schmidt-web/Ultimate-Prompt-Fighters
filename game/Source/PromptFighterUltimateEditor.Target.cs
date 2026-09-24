using UnrealBuildTool;
using System.Collections.Generic;

public class PromptFighterUltimateEditorTarget : TargetRules
{
    public PromptFighterUltimateEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("PromptFighterUltimate");
    }
}

