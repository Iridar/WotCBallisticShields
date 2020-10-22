class X2DownloadableContentInfo_WotCBallisticShields extends X2DownloadableContentInfo;

var config(Content) array<AnimationPoses> m_arrAnimationPoses;
var config(Shields) array<name> IgnoreCharacterTemplates;

static event OnLoadedSavedGame()
{
	`Log("Starting OnLoadedSavedGame", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
	UpdateStorage();
}

static event OnPostTemplatesCreated()
{
	local X2Photobooth Photobooth;
	local int i;

	Photobooth = X2Photobooth(class'Engine'.static.FindClassDefaultObject("XComGame.X2Photobooth"));
	for (i = 0; i < default.m_arrAnimationPoses.Length; i++)
	{
		Photobooth.m_arrAnimationPoses.AddItem(default.m_arrAnimationPoses[i]);
	}
}

// ******** HANDLE UPDATING STORAGE ************* //
static function UpdateStorage()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local array<X2ItemTemplate> ItemTemplates;
	local XComGameState_Item NewItemState;
	local int i;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Musashi: Updating HQ Storage to add CombatKnife");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('BallisticShield_CV'));

	for (i = 0; i < ItemTemplates.Length; ++i)
	{
		if(ItemTemplates[i] != none)
		{
			if (!XComHQ.HasItem(ItemTemplates[i]))
			{
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " not found, adding to inventory", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
				NewItemState = ItemTemplates[i].CreateInstanceFromTemplate(NewGameState);
				NewGameState.AddStateObject(NewItemState);
				XComHQ.AddItemToHQInventory(NewItemState);
			} else {
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " found, skipping inventory add", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
			}
		}
	}

	// Check Tier 2 & 3 for running campaigns that already bought the shields
	AddHigherTiers('BallisticShield_MG', 'MediumPlatedArmor', XComHQ, NewGameState);
	AddHigherTiers('BallisticShield_BM', 'MediumPoweredArmor', XComHQ, NewGameState);
	
	History.AddGameStateToHistory(NewGameState);
}

static function AddHigherTiers(
	name Template,
	name CheckTemplate,
	XComGameState_HeadquartersXCom XComHQ,
	XComGameState NewGameState
	)
{
	local XComGameState_Item NewItemState;
	local X2ItemTemplate ItemTemplate, CheckItemTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateMgr.FindItemTemplate(Template);
	CheckItemTemplate = ItemTemplateMgr.FindItemTemplate(CheckTemplate);
	if(ItemTemplate != none)
	{
		if (!XComHQ.HasItem(ItemTemplate) && 
			XComHQ.HasItem(CheckItemTemplate))
		{
			`Log(ItemTemplate.GetItemFriendlyName() @ " not found, adding to inventory", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(NewItemState);
			XComHQ.AddItemToHQInventory(NewItemState);
		} else if(XComHQ.HasItem(ItemTemplate) && !XComHQ.HasItem(CheckItemTemplate)) {
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			XComHQ.RemoveItemFromInventory(NewGameState, NewItemState.GetReference(), 1);
			`Log(ItemTemplate.GetItemFriendlyName() @ " removed because coressponding tier not unlocked", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
		} else {
			`Log(ItemTemplate.GetItemFriendlyName() @ " found or not unlocked yet, skipping inventory add", class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
		}
	}
}

static function WeaponInitialized(XGWeapon WeaponArchetype, XComWeapon Weapon, optional XComGameState_Item ItemState=none)
{
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_Unit UnitState;

	if (ItemState == none)
	{
		return;
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ItemState.OwnerStateObject.ObjectID));
	if (UnitState != none && default.IgnoreCharacterTemplates.Find(UnitState.GetMyTemplateName()) == INDEX_NONE)
	{
		WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
	
		if (WeaponTemplate != none && HasShieldEquipped(UnitState) && ItemState.InventorySlot == eInvSlot_PrimaryWeapon)
		{
			`LOG(default.Class.Name @ GetFuncName() @ "Spawn" @ WeaponArchetype @ ItemState.GetMyTemplateName() @ Weapon.CustomUnitPawnAnimsets.Length, class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');
			Weapon.DefaultSocket = 'R_Hand';
		}
	}
}

static function bool HasShieldEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item	ItemState;

	ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (ItemState != none)
	{
		return ItemState.GetWeaponCategory() == 'shield';
	}
	return false;
}

static function bool CanAddItemToInventory_CH_Improved(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason, optional XComGameState_Item ItemState)
{
	local X2WeaponTemplate			WeaponTemplate;
	local bool						bEvaluate;
	local XComGameState_Item		PrimaryWeapon, SecondaryWeapon;
	//local XGParamTag				LocTag;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	PrimaryWeapon = UnitState.GetPrimaryWeapon();
	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	//LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	if (!UnitState.bIgnoreItemEquipRestrictions &&
		WeaponTemplate != none &&
		PrimaryWeapon != none &&
		SecondaryWeapon != none &&
		default.IgnoreCharacterTemplates.Find(UnitState.GetMyTemplateName()) == INDEX_NONE
	)
	{
		if (X2WeaponTemplate(SecondaryWeapon.GetMyTemplate()).WeaponCat == 'Shield' &&
		    (WeaponTemplate.InventorySlot == eInvSlot_PrimaryWeapon || ItemState.InventorySlot== eInvSlot_PrimaryWeapon)
		)
		{
			if (class'X2DataStructure_BallisticShields'.default.AllowedPrimaryWeaponCategoriesWithShield.Find(WeaponTemplate.WeaponCat) == INDEX_NONE)
			{
				bCanAddItem = 0;
				//LocTag.StrValue0 = WeaponTemplate.GetLocalizedCategory();
				DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
					`XEXPAND.ExpandString(
						class'XGLocalizedData_BallisticShields'.default.m_strCategoryRestricted
					)
				);
				bEvaluate = true;
			}
		}

		if (WeaponTemplate.InventorySlot == eInvSlot_SecondaryWeapon &&
			WeaponTemplate.WeaponCat == 'Shield')
		{
			if (class'X2DataStructure_BallisticShields'.default.AllowedPrimaryWeaponCategoriesWithShield.Find(X2WeaponTemplate(PrimaryWeapon.GetMyTemplate()).WeaponCat) == INDEX_NONE)
			{
				bCanAddItem = 0;
				//LocTag.StrValue0 = X2WeaponTemplate(PrimaryWeapon.GetMyTemplate()).GetLocalizedCategory();
				DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
					`XEXPAND.ExpandString(
						class'XGLocalizedData_BallisticShields'.default.m_strCategoryRestricted
					)
				);
				bEvaluate = true;
			}
		}
	}

	if ((bEvaluate && CheckGameState != none) || (!bEvaluate && CheckGameState == none))
		`LOG(GetFuncName() @ WeaponTemplate.DataName @ DisabledReason @ bEvaluate, class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');

	if(CheckGameState == none)
		return !bEvaluate;

	return bEvaluate;
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	local XComGameState_Item	PrimaryWeapon;
	local XComGameState_Item	SecondaryWeapon;
	local X2WeaponTemplate		PrimaryWeaponTemplate;
	local X2WeaponTemplate		SecondaryWeaponTemplate;
	local XComContentManager	Content;


	if (UnitState == none || !UnitState.IsSoldier() || default.IgnoreCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
	{
		return;
	}

	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	if (SecondaryWeapon != none)
	{
		SecondaryWeaponTemplate = X2WeaponTemplate(SecondaryWeapon.GetMyTemplate());
	}
	else
	{
		return;
	}

	PrimaryWeapon = UnitState.GetPrimaryWeapon();
	if (PrimaryWeapon != none)
	{
		PrimaryWeaponTemplate = X2WeaponTemplate(PrimaryWeapon.GetMyTemplate());
	}
	
	if (SecondaryWeaponTemplate.WeaponCat == 'shield')
	{
		`LOG(GetFuncName() @ UnitState.GetFullName() @ PrimaryWeaponTemplate.DataName @ SecondaryWeaponTemplate.DataName, class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');

		Content = `CONTENT;
		if (PrimaryWeaponTemplate != none)
		{
			switch (PrimaryWeaponTemplate.WeaponCat)
			{
				case 'rifle':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_AssaultRifle")));
					break;
				case 'sidearm':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_AutoPistol")));
					break;
				case 'pistol': 
				case 'sawedoff':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Pistol")));
					break;
				case 'shotgun':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Shotgun")));
					break;
				case 'bullpup':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_SMG")));
					break;
				case 'sword':
				case 'combatknife':
					CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Sword")));
					break;
				default:
					break;
			}
		}

		CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Armory")));

		if (PrimaryWeaponTemplate != none && PrimaryWeaponTemplate.WeaponCat == 'sword')
		{
			CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Melee")));
		}
		else
		{
			CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield")));
		}
	}
	//	Assume that if the unit has a SPARK Ballistic Shield equipped, then they're a SPARK or a MEC Trooper.
	if (SecondaryWeaponTemplate.WeaponCat == 'spark_shield')
	{
		Content = `CONTENT;

		//	Shield animations need to be added here to replace the Walk Back animation on the Avenger. They also contain a Deflect animation.
		CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Spark_Shields.Anims.AS_Spark_BallisticShield_Pawn")));

		//	Hunker Down animations. Used by Shield Wall. 
		CustomAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("WoTC_Spark_Shields.Anims.AS_Spark_HunkerDown_Pawn")));
	}
}

static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit	UnitState;
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));
	if (UnitState == none)
		return "";

	if (UnitCanEquipSparkShield(UnitState) || UnitHasSparkShieldEquipped(UnitState))
	{
		return "WoTC_Spark_Shields.Meshes.Spark_Shield_Sockets";
	}

	return "";
}
// Need to check it this way, because *after* the shield is equipped is too late to append the sockets.
static final function bool UnitCanEquipSparkShield(const out XComGameState_Unit UnitState)
{
	local X2SoldierClassTemplate Template;

	Template = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().FindSoldierClassTemplate(UnitState.GetSoldierClassTemplateName());

	return Template != none && Template.AllowedWeapons.Find('WeaponType', 'spark_shield') != INDEX_NONE;
}

static final function bool UnitHasSparkShieldEquipped(const out XComGameState_Unit UnitState)
{
	local XComGameState_Item	SecondaryWeapon;
	local X2WeaponTemplate		SecondaryWeaponTemplate;

	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	if (SecondaryWeapon != none)
	{
		SecondaryWeaponTemplate = X2WeaponTemplate(SecondaryWeapon.GetMyTemplate());

		return SecondaryWeaponTemplate != none && SecondaryWeaponTemplate.WeaponCat == 'spark_shield';
	}
	return false;
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name TagText;
	
	TagText = name(InString);
	switch (TagText)
	{
	case 'BS_TAG_SHIELD_WALL_DEFENSE':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_WALL_DEFENSE));
		return true;
	case 'BS_TAG_SHIELD_POINTS_CV':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_POINTS_CV));
		return true;
	case 'BS_TAG_SHIELD_POINTS_MG':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_POINTS_MG));
		return true;
	case 'BS_TAG_SHIELD_POINTS_BM':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_POINTS_BM));
		return true;
	case 'BS_TAG_SPARK_SHIELD_POINTS_CV':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SPARK_SHIELD_POINTS_CV));
		return true;
	case 'BS_TAG_SPARK_SHIELD_POINTS_MG':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SPARK_SHIELD_POINTS_MG));
		return true;
	case 'BS_TAG_SPARK_SHIELD_POINTS_BM':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SPARK_SHIELD_POINTS_BM));
		return true;
	case 'BS_TAG_SHIELD_MOBILITY_PENALTY':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_MOBILITY_PENALTY));
		return true;
	case 'BS_TAG_SHIELD_AIM_PENALTY':
		OutString = SetColor(String(class'X2Ability_ShieldAbilitySet'.default.SHIELD_AIM_PENALTY));
		return true;
	
	//	===================================================
	default:
            return false;
    }  
}

static function string SetColor(string Value)
{	
	return "<font color='#64c4ce'>" $ Value $ "</font>";
}