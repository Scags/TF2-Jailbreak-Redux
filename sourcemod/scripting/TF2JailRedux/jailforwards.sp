Handle
	g_hForwards[OnPlayMusic+1]
;

void InitializeForwards()
{
	g_hForwards[OnDownloads] 			= CreateForward(ET_Ignore);
	g_hForwards[OnLRRoundActivate] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnManageRoundStart] 	= CreateForward(ET_Ignore);
	g_hForwards[OnManageRoundEnd] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnLRRoundEnd] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnWardenGet] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnClientTouch]			= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	g_hForwards[OnRedThink] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnBlueThink] 			= CreateForward(ET_Ignore, Param_Cell);
	// g_hForwards[OnBlueNotWardenThink] 	= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnWardenThink] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnLRTextHud] 			= CreateForward(ET_Ignore, Param_String);
	g_hForwards[OnLRPicked] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
	g_hForwards[OnPlayerDied] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnBuildingDestroyed]	= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnObjectDeflected] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnPlayerJarated] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnUberDeployed] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnPlayerSpawned]		= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	g_hForwards[OnMenuAdd] 				= CreateForward(ET_Ignore, Param_CellByRef, Param_Cell);
	g_hForwards[OnPanelAdd] 			= CreateForward(ET_Ignore, Param_CellByRef);
	g_hForwards[OnManageTimeLeft] 		= CreateForward(ET_Ignore);
	g_hForwards[OnPlayerPrepped] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnHurtPlayer] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnHookDamage] 			= CreateForward(ET_Hook,   Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell);
	g_hForwards[OnWMenuAdd] 			= CreateForward(ET_Ignore, Param_CellByRef);
	g_hForwards[OnWMenuSelect] 			= CreateForward(ET_Ignore, Param_Cell, Param_String);
	g_hForwards[OnClientInduction] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnVariableReset] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnTimeEnd] 				= CreateForward(ET_Hook);
	g_hForwards[OnLastGuard] 			= CreateForward(ET_Hook);
	g_hForwards[OnLastPrisoner] 		= CreateForward(ET_Hook);
	g_hForwards[OnCheckLivingPlayers] 	= CreateForward(ET_Ignore);
	g_hForwards[OnWardenKilled] 		= CreateForward(ET_Hook,   Param_Cell, Param_Cell, Param_Cell);
	g_hForwards[OnFreedayGiven] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnFreedayRemoved] 		= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[OnPlayMusic]			= CreateForward(ET_Hook,   Param_String, Param_FloatByRef);
}
void Call_OnDownloads()
{
	Call_StartForward(g_hForwards[OnDownloads]);
	Call_Finish();
}
void Call_OnLRRoundActivate(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnLRRoundActivate]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnManageRoundStart()
{
	Call_StartForward(g_hForwards[OnManageRoundStart]);
	Call_Finish();
}
void Call_OnManageRoundEnd(Event event)
{
	Call_StartForward(g_hForwards[OnManageRoundEnd]);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnLRRoundEnd(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnLRRoundEnd]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnWardenGet(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnWardenGet]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnClientTouch(const JailFighter toucher, const JailFighter touchee)
{
	Call_StartForward(g_hForwards[OnClientTouch]);
	Call_PushCell(toucher);
	Call_PushCell(touchee);
	Call_Finish();
}
void Call_OnRedThink(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnRedThink]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBlueThink(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnBlueThink]);
	Call_PushCell(player);
	Call_Finish();
}
/*void Call_OnBlueNotWardenThink(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnBlueNotWardenThink]);
	Call_PushCell(player);
	Call_Finish();
}*/
void Call_OnWardenThink(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnWardenThink]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnLRTextHud(char strHud[128])
{
	Call_StartForward(g_hForwards[OnLRTextHud]);
	Call_PushStringEx(strHud, 128, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnLRPicked(const JailFighter player, const int request, const int value, ArrayList &array)
{
	Call_StartForward(g_hForwards[OnLRPicked]);
	Call_PushCell(player);
	Call_PushCell(request);
	Call_PushCell(value);
	Call_PushCellRef(array);
	Call_Finish();
}
void Call_OnPlayerDied(const JailFighter player, const JailFighter attacker, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerDied]);
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnObjectDeflected(const JailFighter airblasted, const JailFighter airblaster, Event event)
{
	Call_StartForward(g_hForwards[OnObjectDeflected]);
	Call_PushCell(airblasted);
	Call_PushCell(airblaster);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnBuildingDestroyed(const JailFighter destroyer, const int building, Event event)
{
	Call_StartForward(g_hForwards[OnBuildingDestroyed]);
	Call_PushCell(destroyer);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnPlayerJarated(const JailFighter jarateer, const JailFighter jarateed, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerJarated]);
	Call_PushCell(jarateer);
	Call_PushCell(jarateed);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnUberDeployed(const JailFighter patient, const JailFighter medic, Event event)
{
	Call_StartForward(g_hForwards[OnUberDeployed]);
	Call_PushCell(patient);
	Call_PushCell(medic);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerSpawned(const JailFighter player, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerSpawned]);
	Call_PushCell(player);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnMenuAdd(Menu & menu, ArrayList array)
{
	Call_StartForward(g_hForwards[OnMenuAdd]);
	Call_PushCellRef(menu);
	Call_PushCell(array);
	Call_Finish();
}
void Call_OnPanelAdd(Menu & panel)
{
	Call_StartForward(g_hForwards[OnPanelAdd]);
	Call_PushCellRef(panel);
	Call_Finish();
}
void Call_OnManageTimeLeft()
{
	Call_StartForward(g_hForwards[OnManageTimeLeft]);
	Call_Finish();
}
void Call_OnPlayerPrepped(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnPlayerPrepped]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnHurtPlayer(const JailFighter victim, const JailFighter attacker, int damage, int custom, int weapon, Event event)
{
	Call_StartForward(g_hForwards[OnHurtPlayer]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_PushCell(custom);
	Call_PushCell(weapon);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnHookDamage(const JailFighter victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	Call_StartForward(g_hForwards[OnHookDamage]);
	Call_PushCell(victim);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce, 3);
	Call_PushArray(damagePosition, 3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}
void Call_OnWMenuAdd(Menu & menu)
{
	Call_StartForward(g_hForwards[OnWMenuAdd]);
	Call_PushCellRef(menu);
	Call_Finish();
}
void Call_OnWMenuSelect(const JailFighter player, const char[] index)
{
	Call_StartForward(g_hForwards[OnWMenuSelect]);
	Call_PushCell(player);
	Call_PushString(index);
	Call_Finish();
}
Action Call_OnPlayMusic(char song[PLATFORM_MAX_PATH], float &time)
{
	Action result = Plugin_Handled;	// Start as handled because most LRs won't have a background song... probably
	Call_StartForward(g_hForwards[OnPlayMusic]);
	Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_BINARY|SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(result);
	return result;
}
void Call_OnClientInduction(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnClientInduction]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnVariableReset(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnVariableReset]);
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnTimeEnd()
{
	Action result = Plugin_Continue;
	Call_StartForward(g_hForwards[OnTimeEnd]);
	Call_Finish(result);
	return result;
}
void Call_OnLastGuard(Action &result)
{
	Call_StartForward(g_hForwards[OnLastGuard]);
	Call_Finish(result);
}
void Call_OnLastPrisoner(Action &result)
{
	Call_StartForward(g_hForwards[OnLastPrisoner]);
	Call_Finish(result);
}
void Call_OnCheckLivingPlayers()
{
	Call_StartForward(g_hForwards[OnCheckLivingPlayers]);
	Call_Finish();
}
Action Call_OnWardenKilled(const JailFighter victim, const JailFighter attacker, Event event)
{
	Action result = Plugin_Continue;
	Call_StartForward(g_hForwards[OnWardenKilled]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish(result);
	return result;
}
void Call_OnFreedayGiven(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnFreedayGiven]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnFreedayRemoved(const JailFighter player)
{
	Call_StartForward(g_hForwards[OnFreedayRemoved]);
	Call_PushCell(player);
	Call_Finish();
}