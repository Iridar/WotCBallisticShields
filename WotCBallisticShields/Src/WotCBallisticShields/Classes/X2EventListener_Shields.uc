class X2EventListener_Shields extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(GetLocalizedCategory_Template());
	Templates.AddItem(OverrideHitEffects_Template());

	return Templates;
}

static function CHEventListenerTemplate GetLocalizedCategory_Template()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_Shields_GetLocalizedCategory');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('GetLocalizedCategory', ListenerEventFunction, ELD_Immediate, 50);

	return Template;
}

static function EventListenerReturn ListenerEventFunction(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local X2WeaponTemplate Template;

	Tuple = XComLWTuple(EventData);
	Template = X2WeaponTemplate(EventSource);

	if (Tuple == none || Template == none)
		return ELR_NoInterrupt;

	switch (Template.WeaponCat)
	{
	case 'shield':
		Tuple.Data[0].s = class'XGLocalizedData_BallisticShields'.default.m_strShieldCategory;
	case 'spark_shield':
		Tuple.Data[0].s = class'XGLocalizedData_BallisticShields'.default.m_strSparkShieldCategory;
	default:
		return ELR_NoInterrupt;
	}

	return ELR_NoInterrupt;
}

static function CHEventListenerTemplate OverrideHitEffects_Template()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_Shields_OverrideHitEffects');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('OverrideHitEffects', OnOverrideHitEffects, ELD_Immediate);

	return Template;
}

static function EventListenerReturn OnOverrideHitEffects(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComUnitPawn Pawn;
	local XComGameState_Unit UnitState;
	local EAbilityHitResult HitResult;

	Tuple = XComLWTuple(EventData);
	Pawn = XComUnitPawn(EventSource);
	if (Pawn == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.m_kGameUnit.ObjectID));

	if (UnitState != none && class'X2DownloadableContentInfo_WotCBallisticShields'.static.UnitHasSparkShieldEquipped(UnitState))
	{
		HitResult = EAbilityHitResult(Tuple.Data[7].i);

		// Override the templar fx
		if (HitResult == eHit_Deflect || HitResult == eHit_Reflect)
		{
			Tuple.Data[0].b = true;
		}
	}
	return ELR_NoInterrupt;
}