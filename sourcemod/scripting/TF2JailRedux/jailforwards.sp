Handle
	hPrivFwds[OnPlayMusic+1]
;

void InitializeForwards()
{
	hPrivFwds[OnDownloads] 				= CreateForward(ET_Ignore);
	hPrivFwds[OnRoundStart] 			= CreateForward(ET_Ignore);
	hPrivFwds[OnRoundStartPlayer]		= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnRoundEnd] 				= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnRoundEndPlayer] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnWardenGet] 				= CreateForward(ET_Hook, Param_Cell);
	hPrivFwds[OnClientTouch]			= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnRedThink] 				= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnBlueThink] 				= CreateForward(ET_Ignore, Param_Cell);
	// hPrivFwds[OnBlueNotWardenThink] 	= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnWardenThink] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnHudShow] 				= CreateForward(ET_Ignore, Param_String);
	hPrivFwds[OnLRPicked] 				= CreateForward(ET_Hook,   Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnPlayerDied] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnBuildingDestroyed]		= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnObjectDeflected] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnPlayerJarated] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnUberDeployed] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnPlayerSpawned]			= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnMenuAdd] 				= CreateForward(ET_Ignore, Param_Cell, Param_CellByRef, Param_String);
	hPrivFwds[OnPanelAdd] 				= CreateForward(ET_Ignore, Param_Cell, Param_String);
	hPrivFwds[OnTimeLeft] 				= CreateForward(ET_Ignore, Param_CellByRef);
	hPrivFwds[OnPlayerPrepped] 			= CreateForward(ET_Hook, Param_Cell);
	hPrivFwds[OnHurtPlayer] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, /*Param_Cell, Param_Cell, Param_Cell, */Param_Cell);
	hPrivFwds[OnTakeDamage] 			= CreateForward(ET_Hook,   Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell);
	hPrivFwds[OnWMenuAdd] 				= CreateForward(ET_Ignore, Param_CellByRef);
	hPrivFwds[OnWMenuSelect] 			= CreateForward(ET_Hook, Param_Cell, Param_String);
	hPrivFwds[OnClientInduction] 		= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnVariableReset] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnTimeEnd] 				= CreateForward(ET_Hook);
	hPrivFwds[OnLastGuard] 				= CreateForward(ET_Hook);
	hPrivFwds[OnLastPrisoner] 			= CreateForward(ET_Hook);
	hPrivFwds[OnCheckLivingPlayers] 	= CreateForward(ET_Ignore);
	hPrivFwds[OnWardenKilled] 			= CreateForward(ET_Hook,   Param_Cell, Param_Cell, Param_Cell);
	hPrivFwds[OnFreedayGiven] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnFreedayRemoved] 		= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnPreThink] 				= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnFFTimer] 				= CreateForward(ET_Ignore, Param_FloatByRef);
	hPrivFwds[OnDoorsOpen] 				= CreateForward(ET_Hook);
	hPrivFwds[OnDoorsClose] 			= CreateForward(ET_Hook);
	hPrivFwds[OnDoorsLock] 				= CreateForward(ET_Hook);
	hPrivFwds[OnDoorsUnlock] 			= CreateForward(ET_Hook);
	hPrivFwds[OnPlayerPreppedPost] 		= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnPlayMusic]				= CreateForward(ET_Hook,   Param_String, Param_FloatByRef);
}
void Call_OnDownloads()
{
	Call_StartForward(hPrivFwds[OnDownloads]);
	Call_Finish();
}
void Call_OnRoundStart()
{
	Call_StartForward(hPrivFwds[OnRoundStart]);
	Call_Finish();
}
void Call_OnRoundStartPlayer(const JailFighter player, Event event)
{
	Call_StartForward(hPrivFwds[OnRoundStartPlayer]);
	Call_PushCell(player);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnRoundEnd(Event event)
{
	Call_StartForward(hPrivFwds[OnRoundEnd]);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnRoundEndPlayer(const JailFighter player, Event event)
{
	Call_StartForward(hPrivFwds[OnRoundEndPlayer]);
	Call_PushCell(player);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnWardenGet(const JailFighter player)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnWardenGet]);
	Call_PushCell(player);
	Call_Finish(action);
	return action;
}
void Call_OnClientTouch(const JailFighter toucher, const JailFighter touchee)
{
	Call_StartForward(hPrivFwds[OnClientTouch]);
	Call_PushCell(toucher);
	Call_PushCell(touchee);
	Call_Finish();
}
void Call_OnRedThink(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnRedThink]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBlueThink(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnBlueThink]);
	Call_PushCell(player);
	Call_Finish();
}
/*void Call_OnBlueNotWardenThink(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnBlueNotWardenThink]);
	Call_PushCell(player);
	Call_Finish();
}*/
void Call_OnWardenThink(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnWardenThink]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnHudShow(char strHud[128])
{
	Call_StartForward(hPrivFwds[OnHudShow]);
	Call_PushStringEx(strHud, 128, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
Action Call_OnLRPicked(const JailFighter player, const int index, ArrayList array)
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnLRPicked]);
	Call_PushCell(player);
	Call_PushCell(index);
	Call_PushCell(array);
	Call_Finish(result);
	return result;
}
void Call_OnPlayerDied(const JailFighter player, const JailFighter attacker, Event event)
{
	Call_StartForward(hPrivFwds[OnPlayerDied]);
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnObjectDeflected(const JailFighter airblasted, const JailFighter airblaster, Event event)
{
	Call_StartForward(hPrivFwds[OnObjectDeflected]);
	Call_PushCell(airblasted);
	Call_PushCell(airblaster);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnBuildingDestroyed(const JailFighter destroyer, const int building, Event event)
{
	Call_StartForward(hPrivFwds[OnBuildingDestroyed]);
	Call_PushCell(destroyer);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerJarated(const JailFighter jarateer, const JailFighter jarateed, Event event)
{
	Call_StartForward(hPrivFwds[OnPlayerJarated]);
	Call_PushCell(jarateer);
	Call_PushCell(jarateed);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnUberDeployed(const JailFighter patient, const JailFighter medic, Event event)
{
	Call_StartForward(hPrivFwds[OnUberDeployed]);
	Call_PushCell(patient);
	Call_PushCell(medic);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerSpawned(const JailFighter player, Event event)
{
	Call_StartForward(hPrivFwds[OnPlayerSpawned]);
	Call_PushCell(player);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnMenuAdd(const int index, int &max, char name[32])
{
	Call_StartForward(hPrivFwds[OnMenuAdd]);
	Call_PushCell(index);
	Call_PushCellRef(max);
	Call_PushStringEx(name, 32, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnPanelAdd(const int index, char name[64])
{
	Call_StartForward(hPrivFwds[OnPanelAdd]);
	Call_PushCell(index);
	Call_PushStringEx(name, 64, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnTimeLeft(int &time)
{
	Call_StartForward(hPrivFwds[OnTimeLeft]);
	Call_PushCellRef(time);
	Call_Finish();
}
Action Call_OnPlayerPrepped(const JailFighter player)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnPlayerPrepped]);
	Call_PushCell(player);
	Call_Finish(action);
	return action;
}
void Call_OnHurtPlayer(const JailFighter victim, const JailFighter attacker, /*int damage, int custom, int weapon, */Event event)
{
	Call_StartForward(hPrivFwds[OnHurtPlayer]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	// Call_PushCell(damage);
	// Call_PushCell(custom);
	// Call_PushCell(weapon);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnTakeDamage(const JailFighter victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnTakeDamage]);
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
	Call_StartForward(hPrivFwds[OnWMenuAdd]);
	Call_PushCellRef(menu);
	Call_Finish();
}
Action Call_OnWMenuSelect(const JailFighter player, const char[] index)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnWMenuSelect]);
	Call_PushCell(player);
	Call_PushString(index);
	Call_Finish(action);
	return action;
}
Action Call_OnPlayMusic(char song[PLATFORM_MAX_PATH], float &time)
{
	Action result = Plugin_Handled;	// Start as handled because most LRs won't have a background song... probably
	Call_StartForward(hPrivFwds[OnPlayMusic]);
	Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_BINARY|SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(result);
	return result;
}
void Call_OnClientInduction(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnClientInduction]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnVariableReset(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnVariableReset]);
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnTimeEnd()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnTimeEnd]);
	Call_Finish(result);
	return result;
}
void Call_OnLastGuard(Action &result)
{
	Call_StartForward(hPrivFwds[OnLastGuard]);
	Call_Finish(result);
}
Action Call_OnLastPrisoner()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnLastPrisoner]);
	Call_Finish(result);
	return result;
}
void Call_OnCheckLivingPlayers()
{
	Call_StartForward(hPrivFwds[OnCheckLivingPlayers]);
	Call_Finish();
}
Action Call_OnWardenKilled(const JailFighter victim, const JailFighter attacker, Event event)
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnWardenKilled]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish(result);
	return result;
}
void Call_OnFreedayGiven(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnFreedayGiven]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnFreedayRemoved(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnFreedayRemoved]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnPreThink(const JailFighter player, int buttons)
{
	Call_StartForward(hPrivFwds[OnPreThink]);
	Call_PushCell(player);
	Call_PushCell(buttons);
	Call_Finish();
}
void Call_OnFFTimer(float &time)
{
	Call_StartForward(hPrivFwds[OnFFTimer]);
	Call_PushFloatRef(time);
	Call_Finish();
}
Action Call_OnDoorsOpen()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsOpen]);
	Call_Finish(result);
	return result;
}
Action Call_OnDoorsClose()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsClose]);
	Call_Finish(result);
	return result;
}
Action Call_OnDoorsLock()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsLock]);
	Call_Finish(result);
	return result;
}
Action Call_OnDoorsUnlock()
{
	Action result = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsUnlock]);
	Call_Finish(result);
	return result;
}
void Call_OnPlayerPreppedPost(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnPlayerPreppedPost]);
	Call_PushCell(player);
	Call_Finish();
}