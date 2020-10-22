class X2Condition_ExcludeCharacterTemplates extends X2Condition;

//	This condition succeeds if the owner unit's character template name is NOT listed in the exclusion list.

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		if (class'X2DownloadableContentInfo_WotCBallisticShields'.default.IgnoreCharacterTemplates.Find(UnitState.GetMyTemplateName()) == INDEX_NONE)
		{
			return 'AA_Success'; 
		}
	}

	return 'AA_UnitIsWrongType';
}

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	return class'X2DownloadableContentInfo_WotCBallisticShields'.default.IgnoreCharacterTemplates.Find(SourceUnit.GetMyTemplateName()) == INDEX_NONE;
}