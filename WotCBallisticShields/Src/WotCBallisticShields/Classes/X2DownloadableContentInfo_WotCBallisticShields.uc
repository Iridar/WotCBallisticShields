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
	local X2WeaponTemplate PrimaryWeaponTemplate, SecondaryWeaponTemplate;
	local string AnimSetToLoad;

	if (UnitState == none || !UnitState.IsSoldier() || default.IgnoreCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
	{
		return;
	}

	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());
	SecondaryWeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	
	if (SecondaryWeaponTemplate.WeaponCat == 'shield')
	{
		`LOG(GetFuncName() @ UnitState.GetFullName() @ PrimaryWeaponTemplate.DataName @ SecondaryWeaponTemplate.DataName, class'X2Ability_ShieldAbilitySet'.default.bLog, 'WotCBallisticShields');

		switch (PrimaryWeaponTemplate.WeaponCat)
		{
			case 'rifle':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AssaultRifle'";
				break;
			case 'sidearm':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AutoPistol'";
				break;
			case 'pistol': case 'sawedoff':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Pistol'";
				break;
			case 'shotgun':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Shotgun'";
				break;
			case 'bullpup':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_SMG'";
				break;
			case 'sword':
			case 'combatknife':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Sword'";
				break;
		}

		if (AnimSetToLoad != "")
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype(AnimSetToLoad)));
		}

		CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Armory")));

		if (PrimaryWeaponTemplate.WeaponCat == 'sword')
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield_Melee")));
		}
		else
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("WoTC_Shield_Animations.Anims.AS_Shield")));
		}
	}
}