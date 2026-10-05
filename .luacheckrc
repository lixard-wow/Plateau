std = "lua51"
max_line_length = false
self = false

globals = {
    "SlashCmdList",
    "PlateauDB",
    "Plateau",
    "PlateauOptions",
    "SLASH_PLATEAU1",
    "SLASH_PLATEAU2",
}

ignore = {
    "212/self",
    "211/ADDON",
    "11./^SLASH_",
    "11./^BINDING_",
}

read_globals = {
    "ADDONS", "AbbreviateNumbers", "AnchorUtil", "AuraContainerSortDirection", "AuraContainerSortMethod",
    "AuraUtil", "CR_CRIT_MELEE", "CR_HASTE_MELEE", "CR_MASTERY", "CR_VERSATILITY_DAMAGE_DONE",
    "C_AddOnProfiler", "C_AddOns", "C_CVar", "C_ChallengeMode", "C_ChatInfo", "C_ClassColor", "C_Container",
    "C_CurrencyInfo", "C_CurveUtil", "C_DurationUtil", "C_EventUtils", "C_Item", "C_Map", "C_MythicPlus",
    "C_NamePlate", "C_PartyInfo", "C_PvP", "C_QuestLog", "C_RestrictedActions", "C_Scenario",
    "C_ScenarioInfo", "C_Secrets", "C_SpecializationInfo", "C_Spell", "C_SpellBook", "C_StringUtil",
    "C_Texture", "C_Timer", "C_TooltipInfo", "C_UnitAuras", "ChatFrame1", "ColorPickerFrame",
    "CombatLogGetCurrentEventInfo", "Constants", "CopyTable", "CreateAbbreviateConfig", "CreateColor",
    "CreateFrame", "CreateFromMixins", "CreateUnitHealPredictionCalculator", "CreateVector2D",
    "CurveConstants", "DAMAGE_TEXT_FONT", "DEFAULT_CHAT_FRAME", "ElvUI", "Enum", "EventUtil",
    "FOREIGN_SERVER_LABEL", "GAMEMENU_OPTIONS", "GameMenuFrame", "GameTooltip",
    "GameTooltip_SetDefaultAnchor", "GetAddOnMemoryUsage", "GetBuildInfo", "GetCoinTextureString",
    "GetCombatRating", "GetCombatRatingBonus", "GetCreatureDifficultyColor", "GetCritChance",
    "GetCursorPosition", "GetDifficultyInfo", "GetHaste", "GetInstanceInfo", "GetInventoryItemID",
    "GetInventoryItemLink", "GetItemInfo", "GetLocale", "GetMastery", "GetMasteryEffect",
    "GetNumGroupMembers", "GetNumSpecializations", "GetRaidRosterInfo", "GetRaidTargetIndex", "GetRealmName",
    "GetRuneCooldown", "GetSpecialization", "GetSpecializationInfo", "GetSpecializationRole",
    "GetSpellCooldown", "GetSpellInfo", "GetTime", "GetVersatilityBonus", "HideUIPanel", "INTERRUPTED",
    "InCombatLockdown", "InterfaceOptionsFrame_OpenToCategory", "InterfaceOptions_AddCategory", "IsInGroup",
    "IsInInstance", "IsInRaid", "IsMouseButtonDown", "IsShiftKeyDown", "LibDeflate", "LibStub",
    "MenuResponse", "MenuUtil", "Mixin", "NPC_NAMES_DROPDOWN_ALL", "NPC_NAMES_DROPDOWN_HOSTILE",
    "NPC_NAMES_DROPDOWN_INTERACTIVE", "NPC_NAMES_DROPDOWN_NONE", "NPC_NAMES_DROPDOWN_TRACKED",
    "NUM_BAG_SLOTS", "NamePlateConstants", "NamePlateFriendlyFrameOptions", "PixelUtil", "PlateauConflicts",
    "PlateauOptions", "PlateauSetup", "PlaySound", "PlaySoundFile", "RAID_CLASS_COLORS",
    "RAID_TARGET_TEXTURE_COLUMNS", "RAID_TARGET_TEXTURE_ROWS", "RegisterAttributeDriver",
    "RegisterStateDriver", "ReloadUI", "SOUNDKIT", "SPELL_INTERRUPTED_BY", "STANDARD_TEXT_FONT", "Settings",
    "TooltipUtil", "UIParent", "UISpecialFrames", "UNIT_NAME_FONT", "UnitAffectingCombat", "UnitAura",
    "UnitBuff", "UnitCanAttack", "UnitCastingDuration", "UnitCastingInfo", "UnitChannelDuration",
    "UnitChannelInfo", "UnitClass", "UnitClassBase", "UnitClassFromGUID", "UnitClassification",
    "UnitCreatureFamily", "UnitCreatureType", "UnitDebuff", "UnitEffectiveLevel",
    "UnitEmpoweredChannelDuration", "UnitExists", "UnitFrameUtil", "UnitGUID",
    "UnitGetDetailedHealPrediction", "UnitGetTotalAbsorbs", "UnitGroupRolesAssigned", "UnitHasPowerType",
    "UnitHealth", "UnitHealthMax", "UnitHealthPercent", "UnitInParty", "UnitIsBossMob", "UnitIsLieutenant",
    "UnitIsPlayer", "UnitIsTapDenied", "UnitIsUnit", "UnitLevel", "UnitName", "UnitNameFromGUID",
    "UnitPlayerControlled", "UnitPower", "UnitPowerDisplayMod", "UnitPowerMax", "UnitPowerMissing",
    "UnitPowerPercent", "UnitPowerType", "UnitRace", "UnitReaction", "UnitSelectionColor", "UnitSex",
    "UnitShouldDisplaySpellTargetName", "UnitSpellTargetName", "UnitStat", "UnitThreatSituation",
    "UpdateAddOnMemoryUsage", "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WorldFrame", "bit", "date",
    "debugprofilestop", "debugstack", "difftime", "geterrorhandler", "hooksecurefunc", "issecretvalue",
    "issecure", "issecurevariable", "securecall", "seterrorhandler", "strfind", "strjoin", "strlower",
    "strmatch", "strrep", "strsplit", "strtrim", "strupper", "tContains", "time", "tinsert", "tostringall",
    "tremove", "wipe",
}
