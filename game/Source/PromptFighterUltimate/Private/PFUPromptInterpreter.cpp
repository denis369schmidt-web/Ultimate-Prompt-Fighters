#include "PFUPromptInterpreter.h"

namespace
{
    bool ContainsAny(const FString& Text, std::initializer_list<const TCHAR*> Terms)
    {
        for (const TCHAR* Term : Terms)
        {
            if (Text.Contains(Term, ESearchCase::IgnoreCase)) return true;
        }
        return false;
    }

    void SetStats(FPFUFighterStats& Stats, int32 V, int32 P, int32 D, int32 S, int32 T)
    {
        Stats.Vitality = V; Stats.Power = P; Stats.Defense = D; Stats.Speed = S; Stats.Technique = T;
    }
}

FString UPFUPromptInterpreter::SanitizePrompt(const FString& Prompt)
{
    FString Result;
    Result.Reserve(FMath::Min(Prompt.Len(), 512));
    for (int32 Index = 0; Index < Prompt.Len() && Result.Len() < 512; ++Index)
    {
        const TCHAR Character = Prompt[Index];
        if (!FChar::IsControl(Character)) Result.AppendChar(Character);
    }
    Result.TrimStartAndEndInline();
    return Result.IsEmpty() ? TEXT("balanced unknown fighter") : Result;
}

uint32 UPFUPromptInterpreter::StableSeed(const FString& Prompt, int32 PlayerIndex)
{
    const FString Normalized = SanitizePrompt(Prompt).ToLower();
    uint32 Hash = 2166136261u;
    for (const TCHAR Character : Normalized)
    {
        Hash ^= static_cast<uint32>(Character);
        Hash *= 16777619u;
    }
    Hash ^= static_cast<uint32>(PlayerIndex + 1) * 0x9e3779b9u;
    return Hash;
}

void UPFUPromptInterpreter::AllocateStats(FRandomStream& Random, EPFUArchetype Archetype, FPFUFighterStats& OutStats)
{
    switch (Archetype)
    {
        case EPFUArchetype::Agile:    SetStats(OutStats, 17, 19, 13, 31, 20); break;
        case EPFUArchetype::Guardian: SetStats(OutStats, 28, 18, 30, 10, 14); break;
        case EPFUArchetype::Bruiser:  SetStats(OutStats, 24, 30, 22, 11, 13); break;
        default:                      SetStats(OutStats, 18, 18, 14, 18, 32); break;
    }

    int32* Values[] = { &OutStats.Vitality, &OutStats.Power, &OutStats.Defense, &OutStats.Speed, &OutStats.Technique };
    for (int32 Step = 0; Step < 8; ++Step)
    {
        int32 From = Random.RandRange(0, 4);
        int32 To = Random.RandRange(0, 4);
        if (From != To && *Values[From] > PFULimits::MinAttribute && *Values[To] < PFULimits::MaxAttribute)
        {
            --*Values[From];
            ++*Values[To];
        }
    }
}

FPFUAbilitySpec UPFUPromptInterpreter::MakeStandard(const FPFUFighterStats& Stats, EPFUArchetype Archetype)
{
    FPFUAbilitySpec Ability;
    Ability.Id = Archetype == EPFUArchetype::Guardian ? TEXT("HeavyJab") : TEXT("QuickStrike");
    Ability.Damage = FMath::Clamp(5.0f + Stats.Power * 0.24f, 5.0f, 15.0f);
    Ability.Range = FMath::Clamp(105.0f + Stats.Technique * 1.8f, PFULimits::MinRange, 180.0f);
    Ability.Cooldown = FMath::Clamp(0.95f - Stats.Speed * 0.014f, 0.38f, 0.9f);
    Ability.Knockback = FMath::Clamp(80.0f + Stats.Power * 3.0f, 90.0f, 190.0f);
    Ability.BudgetCost = 20;
    return Ability;
}

FPFUAbilitySpec UPFUPromptInterpreter::MakeSpecial(const FPFUFighterStats& Stats, EPFUElement Element, EPFUArchetype Archetype)
{
    FPFUAbilitySpec Ability;
    Ability.Id = FName(*FString::Printf(TEXT("Special_%d_%d"), static_cast<int32>(Element), static_cast<int32>(Archetype)));
    Ability.Damage = FMath::Clamp(12.0f + Stats.Power * 0.36f + Stats.Technique * 0.1f, 14.0f, PFULimits::MaxDamage);
    Ability.Range = FMath::Clamp(135.0f + Stats.Technique * 3.1f, 140.0f, PFULimits::MaxRange);
    Ability.Cooldown = FMath::Clamp(4.8f - Stats.Speed * 0.045f, 2.3f, PFULimits::MaxCooldown);
    Ability.Knockback = FMath::Clamp(150.0f + Stats.Power * 5.0f, 180.0f, 330.0f);
    Ability.BudgetCost = 40;
    return Ability;
}

FPFUFighterProfile UPFUPromptInterpreter::Interpret(const FString& Prompt, int32 PlayerIndex)
{
    FPFUFighterProfile Profile;
    Profile.SourcePrompt = SanitizePrompt(Prompt);
    Profile.Seed = static_cast<int32>(StableSeed(Profile.SourcePrompt, PlayerIndex) & 0x7fffffff);
    FRandomStream Random(Profile.Seed);
    const FString Lower = Profile.SourcePrompt.ToLower();

    if (ContainsAny(Lower, {TEXT("ninja"), TEXT("schnell"), TEXT("fast"), TEXT("assassin"), TEXT("shadow")}))
        Profile.Archetype = EPFUArchetype::Agile;
    else if (ContainsAny(Lower, {TEXT("golem"), TEXT("panzer"), TEXT("armor"), TEXT("guardian"), TEXT("tank")}))
        Profile.Archetype = EPFUArchetype::Guardian;
    else if (ContainsAny(Lower, {TEXT("brutal"), TEXT("faust"), TEXT("fist"), TEXT("berserk")}))
        Profile.Archetype = EPFUArchetype::Bruiser;
    else
        Profile.Archetype = static_cast<EPFUArchetype>(Random.RandRange(0, 3));

    if (ContainsAny(Lower, {TEXT("blitz"), TEXT("electric"), TEXT("storm")})) Profile.Element = EPFUElement::Electric;
    else if (ContainsAny(Lower, {TEXT("lava"), TEXT("feuer"), TEXT("fire"), TEXT("burn")})) Profile.Element = EPFUElement::Fire;
    else if (ContainsAny(Lower, {TEXT("eis"), TEXT("ice"), TEXT("frost")})) Profile.Element = EPFUElement::Ice;
    else if (ContainsAny(Lower, {TEXT("stein"), TEXT("stone"), TEXT("earth")})) Profile.Element = EPFUElement::Stone;
    else if (ContainsAny(Lower, {TEXT("wind"), TEXT("air")})) Profile.Element = EPFUElement::Wind;
    else Profile.Element = EPFUElement::Shadow;

    switch (Profile.Archetype)
    {
        case EPFUArchetype::Agile:
            Profile.DisplayName = TEXT("Volt Shadow"); Profile.BodyModule = TEXT("Body_Agile");
            Profile.ArmorModule = TEXT("Armor_ShadowLight"); Profile.WeaponModule = TEXT("Weapon_TwinBlades");
            break;
        case EPFUArchetype::Guardian:
            Profile.DisplayName = TEXT("Cinder Bastion"); Profile.BodyModule = TEXT("Body_Heavy");
            Profile.ArmorModule = TEXT("Armor_Volcanic"); Profile.WeaponModule = TEXT("Weapon_Gauntlets");
            break;
        case EPFUArchetype::Bruiser:
            Profile.DisplayName = TEXT("Iron Breaker"); Profile.BodyModule = TEXT("Body_Bruiser");
            Profile.ArmorModule = TEXT("Armor_Medium"); Profile.WeaponModule = TEXT("Weapon_Fists");
            break;
        default:
            Profile.DisplayName = TEXT("Arc Weaver"); Profile.BodyModule = TEXT("Body_Mystic");
            Profile.ArmorModule = TEXT("Armor_Runes"); Profile.WeaponModule = TEXT("Weapon_Focus");
            break;
    }

    Profile.PrimaryColor = Profile.Archetype == EPFUArchetype::Guardian
        ? FLinearColor(0.035f, 0.018f, 0.012f) : FLinearColor(0.018f, 0.028f, 0.075f);
    Profile.AccentColor = Profile.Element == EPFUElement::Fire
        ? FLinearColor(1.0f, 0.06f, 0.005f) : FLinearColor(0.0f, 0.75f, 1.0f);
    AllocateStats(Random, Profile.Archetype, Profile.Stats);
    Profile.StandardAttack = MakeStandard(Profile.Stats, Profile.Archetype);
    Profile.SpecialAttack = MakeSpecial(Profile.Stats, Profile.Element, Profile.Archetype);
    return Profile;
}

bool UPFUPromptInterpreter::ValidateProfile(const FPFUFighterProfile& Profile, FString& OutError)
{
    if (Profile.Stats.Total() != PFULimits::AttributeBudget)
    {
        OutError = TEXT("Attribute total is not 100."); return false;
    }
    const int32 Values[] = { Profile.Stats.Vitality, Profile.Stats.Power, Profile.Stats.Defense, Profile.Stats.Speed, Profile.Stats.Technique };
    for (int32 Value : Values)
    {
        if (Value < PFULimits::MinAttribute || Value > PFULimits::MaxAttribute)
        {
            OutError = TEXT("Attribute outside allowed range."); return false;
        }
    }
    if (Profile.StandardAttack.BudgetCost + Profile.SpecialAttack.BudgetCost > PFULimits::AbilityBudget)
    {
        OutError = TEXT("Ability budget exceeded."); return false;
    }
    for (const FPFUAbilitySpec* Ability : { &Profile.StandardAttack, &Profile.SpecialAttack })
    {
        if (Ability->Damage < PFULimits::MinDamage || Ability->Damage > PFULimits::MaxDamage ||
            Ability->Cooldown < PFULimits::MinCooldown || Ability->Cooldown > PFULimits::MaxCooldown ||
            Ability->Range < PFULimits::MinRange || Ability->Range > PFULimits::MaxRange)
        {
            OutError = TEXT("Ability value outside allowed range."); return false;
        }
    }
    OutError.Reset();
    return true;
}

