class X2Item_Shield extends X2Item config(Shields);

var config WeaponDamageValue SHIELD_CV_BASEDAMAGE;
var config WeaponDamageValue SHIELD_MG_BASEDAMAGE;
var config WeaponDamageValue SHIELD_BM_BASEDAMAGE;

var config array<name> SHIELD_CV_ABILITIES;
var config array<name> SHIELD_MG_ABILITIES;
var config array<name> SHIELD_BM_ABILITIES;

var config int SHIELD_CV_AIM;
var config int SHIELD_CV_CRITCHANCE;
var config int SHIELD_CV_ISOUNDRANGE;
var config int SHIELD_CV_IENVIRONMENTDAMAGE;
var config int SHIELD_CV_NUM_UPGRADE_SLOTS;

var config int SHIELD_MG_AIM;
var config int SHIELD_MG_CRITCHANCE;
var config int SHIELD_MG_ISOUNDRANGE;
var config int SHIELD_MG_IENVIRONMENTDAMAGE;
var config int SHIELD_MG_NUM_UPGRADE_SLOTS;

var config int SHIELD_BM_AIM;
var config int SHIELD_BM_CRITCHANCE;
var config int SHIELD_BM_ISOUNDRANGE;
var config int SHIELD_BM_IENVIRONMENTDAMAGE;
var config int SHIELD_BM_NUM_UPGRADE_SLOTS;

var config WeaponDamageValue SPARK_SHIELD_CV_BASEDAMAGE;
var config WeaponDamageValue SPARK_SHIELD_MG_BASEDAMAGE;
var config WeaponDamageValue SPARK_SHIELD_BM_BASEDAMAGE;

var config array<name> SPARK_SHIELD_CV_ABILITIES;
var config array<name> SPARK_SHIELD_MG_ABILITIES;
var config array<name> SPARK_SHIELD_BM_ABILITIES;

var config int SPARK_SHIELD_CV_AIM;
var config int SPARK_SHIELD_CV_CRITCHANCE;
var config int SPARK_SHIELD_CV_ISOUNDRANGE;
var config int SPARK_SHIELD_CV_IENVIRONMENTDAMAGE;
var config int SPARK_SHIELD_CV_NUM_UPGRADE_SLOTS;

var config int SPARK_SHIELD_MG_AIM;
var config int SPARK_SHIELD_MG_CRITCHANCE;
var config int SPARK_SHIELD_MG_ISOUNDRANGE;
var config int SPARK_SHIELD_MG_IENVIRONMENTDAMAGE;
var config int SPARK_SHIELD_MG_NUM_UPGRADE_SLOTS;

var config int SPARK_SHIELD_BM_AIM;
var config int SPARK_SHIELD_BM_CRITCHANCE;
var config int SPARK_SHIELD_BM_ISOUNDRANGE;
var config int SPARK_SHIELD_BM_IENVIRONMENTDAMAGE;
var config int SPARK_SHIELD_BM_NUM_UPGRADE_SLOTS;

var config bool SHIELD_MELEE_DISORIENTS;
var config bool SPARK_SHIELD_MELEE_DISORIENTS;

var config bool SHIELD_MELEE_STUNS;
var config bool SPARK_SHIELD_MELEE_STUNS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(BallisticShield_CV());
	Weapons.AddItem(BallisticShield_MG());
	Weapons.AddItem(BallisticShield_BM());

	Weapons.AddItem(SparkBallisticShield_CV());
	Weapons.AddItem(SparkBallisticShield_MG());
	Weapons.AddItem(SparkBallisticShield_BM());

	return Weapons;
}

static function X2WeaponTemplate BallisticShield_CV()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'BallisticShield_CV');
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shield';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///WoTC_Shield_UI.Inv_Ballistic_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	
	Template.BaseDamage = default.SHIELD_CV_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SHIELD_CV_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SHIELD_CV_CRITCHANCE;
	Template.iSoundRange = default.SHIELD_CV_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SHIELD_CV_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = default.SHIELD_CV_NUM_UPGRADE_SLOTS;
	Template.iClipSize = 0;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iRange = 0;
	Template.iRadius = 1;
	Template.GameArchetype = "WoTC_Ballistic_Shield.Archetype.WP_Ballistic_Shield";
	Template.Tier = 0;
	
	Template.PointsToComplete = 0;
	Template.TradingPostValue = 0;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	
	Template.Abilities = default.SHIELD_CV_ABILITIES;

	if (default.SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	
	
	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SHIELD_CV_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.StartingItem = true;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate BallisticShield_MG()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'BallisticShield_MG');
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shield';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///WoTC_Shield_UI.Inv_Plated_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WoTC_Plated_Shield.Archetype.WP_Plated_Shield";
	Template.Tier = 1;

	Template.iRadius = 1;
	Template.NumUpgradeSlots = default.SHIELD_MG_NUM_UPGRADE_SLOTS;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage = default.SHIELD_MG_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SHIELD_MG_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SHIELD_MG_CRITCHANCE;
	Template.iSoundRange = default.SHIELD_MG_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SHIELD_MG_IENVIRONMENTDAMAGE;	

	Template.Abilities = default.SHIELD_MG_ABILITIES;

	if (default.SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	

	Template.CreatorTemplateName = 'MediumPlatedArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'BallisticShield_CV'; // Which item this will be upgraded from
	
	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SHIELD_MG_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	
	return Template;
}

static function X2DataTemplate BallisticShield_BM()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'BallisticShield_BM');
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shield';
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///WoTC_Shield_UI.Inv_Powered_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WoTC_Powered_Shield.Archetype.WP_Powered_Shield";
	Template.Tier = 2;

	Template.iRadius = 1;
	Template.NumUpgradeSlots = default.SHIELD_BM_NUM_UPGRADE_SLOTS;;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage = default.SHIELD_BM_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SHIELD_BM_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SHIELD_BM_CRITCHANCE;
	Template.iSoundRange = default.SHIELD_BM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SHIELD_BM_IENVIRONMENTDAMAGE;

	Template.Abilities = default.SHIELD_BM_ABILITIES;

	if (default.SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	
	
	Template.CreatorTemplateName = 'MediumPoweredArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'BallisticShield_MG'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SHIELD_BM_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	
	return Template;
}


static function X2WeaponTemplate SparkBallisticShield_CV()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'SparkBallisticShield_CV');
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'spark_shield';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///WoTC_Spark_Shields.UI.Inv_Conventional_Spark_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	
	Template.BaseDamage = default.SPARK_SHIELD_CV_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SPARK_SHIELD_CV_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SPARK_SHIELD_CV_CRITCHANCE;
	Template.iSoundRange = default.SPARK_SHIELD_CV_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPARK_SHIELD_CV_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = default.SPARK_SHIELD_CV_NUM_UPGRADE_SLOTS;
	Template.iClipSize = 0;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iRange = 0;
	Template.iRadius = 1;
	Template.GameArchetype = "WoTC_Spark_Shields.Archetype.WP_Spark_Ballistic_Shield";
	Template.Tier = 0;
	
	Template.PointsToComplete = 0;
	Template.TradingPostValue = 0;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	
	Template.Abilities = default.SPARK_SHIELD_CV_ABILITIES;

	if (default.SPARK_SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SPARK_SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	
	
	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SPARK_SHIELD_CV_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.StartingItem = true;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate SparkBallisticShield_MG()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'SparkBallisticShield_MG');
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'spark_shield';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///WoTC_Spark_Shields.UI.Inv_Plated_Spark_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WoTC_Spark_Shields.Archetype.WP_Spark_Plated_Shield";
	Template.Tier = 1;

	Template.iRadius = 1;
	Template.NumUpgradeSlots = default.SPARK_SHIELD_MG_NUM_UPGRADE_SLOTS;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage = default.SPARK_SHIELD_MG_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SPARK_SHIELD_MG_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SPARK_SHIELD_MG_CRITCHANCE;
	Template.iSoundRange = default.SPARK_SHIELD_MG_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPARK_SHIELD_MG_IENVIRONMENTDAMAGE;	

	Template.Abilities = default.SPARK_SHIELD_MG_ABILITIES;

	if (default.SPARK_SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SPARK_SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	

	Template.CreatorTemplateName = 'PlatedSparkArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'SparkBallisticShield_CV'; // Which item this will be upgraded from
	
	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SPARK_SHIELD_MG_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	
	return Template;
}

static function X2DataTemplate SparkBallisticShield_BM()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'SparkBallisticShield_BM');
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'spark_shield';
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///WoTC_Spark_Shields.UI.Inv_Powered_Spark_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftHand;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WoTC_Spark_Shields.Archetype.WP_Spark_Powered_Shield";
	Template.Tier = 2;

	Template.iRadius = 1;
	Template.NumUpgradeSlots = default.SPARK_SHIELD_BM_NUM_UPGRADE_SLOTS;;
	Template.InfiniteAmmo = true;
	Template.bHideClipSizeStat = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage = default.SPARK_SHIELD_BM_BASEDAMAGE;
	Template.DamageTypeTemplateName = default.SPARK_SHIELD_BM_BASEDAMAGE.DamageType;
	Template.Aim = 0;
	Template.CritChance = default.SPARK_SHIELD_BM_CRITCHANCE;
	Template.iSoundRange = default.SPARK_SHIELD_BM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPARK_SHIELD_BM_IENVIRONMENTDAMAGE;

	Template.Abilities = default.SPARK_SHIELD_BM_ABILITIES;

	if (default.SPARK_SHIELD_MELEE_DISORIENTS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	}
	if (default.SPARK_SHIELD_MELEE_STUNS)
	{
		Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false));
	}	
	
	Template.CreatorTemplateName = 'PoweredSparkArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'SparkBallisticShield_MG'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(Caps(class'XLocalizedData'.default.MeleeTutorialTitle) @ class'XLocalizedData'.default.AimLabel,, default.SPARK_SHIELD_BM_AIM,,, "%");
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY);
	Template.SetUIStatMarkup(class'XGLocalizedData_BallisticShields'.default.m_strAimPenalty, eStat_Offense, class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY,,, "%");

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	
	return Template;
}
