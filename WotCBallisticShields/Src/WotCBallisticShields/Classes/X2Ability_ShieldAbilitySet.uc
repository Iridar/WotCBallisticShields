class X2Ability_ShieldAbilitySet extends X2Ability config(Shields);

var config int SHIELD_WALL_DODGE;
var config int SHIELD_WALL_DEFENSE;
var config bool SHIELD_WALL_FREE_ACTION;

var config int SHIELD_POINTS_CV;
var config int SHIELD_POINTS_MG;
var config int SHIELD_POINTS_BM;

var config int SPARK_SHIELD_POINTS_CV;
var config int SPARK_SHIELD_POINTS_MG;
var config int SPARK_SHIELD_POINTS_BM;

var config int SHIELD_MOBILITY_PENALTY;
var config int SHIELD_AIM_PENALTY;

var config bool bLog;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(ShieldWall());
	Templates.AddItem(BallisticShield('BallisticShield_CV', default.SHIELD_POINTS_CV));
	Templates.AddItem(BallisticShield('BallisticShield_MG', default.SHIELD_POINTS_MG));
	Templates.AddItem(BallisticShield('BallisticShield_BM', default.SHIELD_POINTS_BM));

	Templates.AddItem(BallisticShield('SparkBallisticShield_CV', default.SPARK_SHIELD_POINTS_CV));
	Templates.AddItem(BallisticShield('SparkBallisticShield_MG', default.SPARK_SHIELD_POINTS_MG));
	Templates.AddItem(BallisticShield('SparkBallisticShield_BM', default.SPARK_SHIELD_POINTS_BM));
	Templates.AddItem(ShieldBash());
	Templates.AddItem(ShieldAnimSet());
	Templates.AddItem(BallisticShield_GenerateCover());	
	
	return Templates;
}

static function X2AbilityTemplate ShieldWall()
{
	local X2AbilityTemplate Template;
	local X2Effect_ShieldWall CoverEffect;

	Template = class'X2Ability_DefaultAbilitySet'.static.AddHunkerDownAbility('ShieldWall');

	Template.IconImage = "img:///WoTC_Shield_UI.ShieldWall_Icon";

	if (default.SHIELD_WALL_FREE_ACTION)
	{
		Template.AbilityCosts.Length = 0;
		Template.AbilityCosts.AddItem(default.FreeActionCost);
	}

	X2Condition_UnitProperty(Template.AbilityShooterConditions[0]).ExcludeNoCover = false;

	X2Effect_PersistentStatChange(Template.AbilityTargetEffects[0]).m_aStatChanges[0].StatAmount = default.SHIELD_WALL_DODGE;
	X2Effect_PersistentStatChange(Template.AbilityTargetEffects[0]).m_aStatChanges[1].StatAmount = default.SHIELD_WALL_DEFENSE;

	CoverEffect = new class'X2Effect_ShieldWall';
	CoverEffect.EffectName = 'ShieldWall';
	CoverEffect.bRemoveWhenMoved = false;
	CoverEffect.bRemoveOnOtherActivation = false;
	CoverEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	CoverEffect.CoverType = CoverForce_High;
	CoverEffect.DuplicateResponse = eDupe_Allow;
	Template.AddTargetEffect(CoverEffect);

	Template.OverrideAbilities.AddItem('HunkerDown');

	//	WAR Suit's "Shieldwall" ability. Redundant with *this* Shield Wall.
	//	Also its OnEffectRemoved it does UnitState.bGeneratesCover = false, effectivelly turning off the X2Effect_GenerateCover in the BallisticShield passive.
	//	Kinda big deal.
	Template.OverrideAbilities.AddItem('HighCoverGenerator');	

	return Template;
}

static function X2AbilityTemplate BallisticShield(name TemplateName, int ShieldHPAmount)
{
	local X2AbilityTemplate Template;
	local X2Effect_EnergyShield ShieldedEffect;
	local X2Effect_PersistentStatChange PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	//Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.IconImage = "img:///WoTC_Shield_UI.BallisticShield_Icon";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(1, true, false, true, eGameRule_TacticalGameStart);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldHPAmount);
	ShieldedEffect.EffectName = 'Ballistic_Shield_Effect';	//	Stormrider Class depends on this Effect Name, don't change pl0x
	ShieldedEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(ShieldedEffect);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.SHIELD_MOBILITY_PENALTY);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Offense, default.SHIELD_AIM_PENALTY);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	//	UI Stat Markup has no effect on abilities that are not a part of the soldier's skill tree.
	//Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.SHIELD_MOBILITY_PENALTY);
	//Template.SetUIStatMarkup(class'XLocalizedData'.default.AimLabel, eStat_Offense, default.SHIELD_AIM_PENALTY);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate BallisticShield_GenerateCover()
{
	local X2AbilityTemplate Template;
	local X2Effect_GenerateCover CoverEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BallisticShield_GenerateCover');

	Template.IconImage = "img:///WoTC_Shield_UI.BallisticShield_Icon";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.Hostility = eHostility_Neutral;
	SetHidden(Template);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	CoverEffect = new class'X2Effect_GenerateCover';
	CoverEffect.EffectName = 'BallisticShield';
	CoverEffect.bRemoveWhenMoved = false;
	CoverEffect.bRemoveOnOtherActivation = false;
	CoverEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	CoverEffect.CoverType = CoverForce_Low;
	CoverEffect.DuplicateResponse = eDupe_Allow;
	Template.AddTargetEffect(CoverEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ShieldBash()
{
	local X2AbilityTemplate                 Template;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('ShieldBash');
	Template.IconImage = "img:///WoTC_Shield_UI.ShieldBash_Icon";

	//Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// These don't appear to be in use anymore.
	//Template.CustomFireAnim = 'FF_MeleeShieldBash';
	//Template.CustomFireKillAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingFireAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingFireKillAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingTurnLeftFireAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingTurnLeftFireKillAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingTurnRightFireAnim = 'FF_MeleeShieldBash';
	//Template.CustomMovingTurnRightFireKillAnim = 'FF_MeleeShieldBash';

	// Allow enemies to get knocked back on death. They're being bashed, not sliced through.
	Template.bOverrideMeleeDeath = true;

	return Template;
}

static function X2AbilityTemplate ShieldAnimSet()
{
    local X2AbilityTemplate						Template;
    local X2Effect_AdditionalAnimSets			AnimSets;
	local X2Effect_ShieldAim					ShieldAim;
	local X2Condition_ExcludeCharacterTemplates	Condition;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'ShieldAnimSet');

    Template.AbilitySourceName = 'eAbilitySource_Item';
    SetHidden(Template);
    Template.Hostility = eHostility_Neutral;
    
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
    AnimSets = new class'X2Effect_AdditionalAnimSets';
    AnimSets.EffectName = 'ShieldAnimSet';
    //AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield'");
	AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Grenade'");
	AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Medkit'");
    AnimSets.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
    AnimSets.DuplicateResponse = eDupe_Ignore;

	//	This effect will apply only to units whose character template name is not in the exclusion list.
	Condition = new class'X2Condition_ExcludeCharacterTemplates';
	AnimSets.TargetConditions.AddItem(Condition);

    Template.AddTargetEffect(AnimSets);

	//	Gives the token +20 Aim to abilities attached to the shield (the Shield Bash).
	//	Doing it this way instead of giving Aim directly to the weapon template out of concern for the UI Sat Markup.
	//	The markup must be applied by this secondary weapon so the player can clearly see carrying a shield 
	//	will apply the aim penalty to the soldier.
	ShieldAim = new class'X2Effect_ShieldAim';
	ShieldAim.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(ShieldAim);
    
    Template.bSkipFireAction = true;
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function SetHidden(out X2AbilityTemplate Template)
{
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.bHideOnClassUnlock = true;
}