enum	// Legacy forwards
{
//	Old_OnLastRequestExecute,
	Old_OnWardenGiven,
	Old_OnWardenRemoved,
	Old_OnFreedayGiven,
	Old_OnFreedayRemoved,
//	Old_OnFreekillerGiven,
//	Old_OnFreekillerRemoved,
	Old_OnRebelGiven,
	Old_OnRebelRemoved
};

Handle
	hPrivFwds[OnPlayMusic+1],
	hLegacyFwds[Old_OnRebelRemoved+1]
;

void InitializeForwards()
{
	hPrivFwds[OnDownloads] 				= CreateForward(ET_Ignore);
	hPrivFwds[OnRoundStart] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnRoundStartPlayer]		= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnRoundEnd] 				= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnRoundEndPlayer] 		= CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	hPrivFwds[OnWardenGet] 				= CreateForward(ET_Hook,   Param_Cell);
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
	hPrivFwds[OnPlayerPrepped] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnHurtPlayer] 			= CreateForward(ET_Ignore, Param_Cell, Param_Cell, /*Param_Cell, Param_Cell, Param_Cell, */Param_Cell);
	hPrivFwds[OnTakeDamage] 			= CreateForward(ET_Hook,   Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell);
	hPrivFwds[OnWMenuAdd] 				= CreateForward(ET_Ignore, Param_CellByRef);
	hPrivFwds[OnWMenuSelect] 			= CreateForward(ET_Hook,   Param_Cell, Param_String);
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
	hPrivFwds[OnPlayerPreppedPre] 		= CreateForward(ET_Hook,   Param_Cell);
	hPrivFwds[OnLRGiven] 				= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnSoundHook] 				= CreateForward(ET_Hook,   Param_Array, Param_CellByRef, Param_String, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_String, Param_CellByRef);
	hPrivFwds[OnEntCreated]				= CreateForward(ET_Hook,   Param_Cell, Param_String);
	hPrivFwds[OnCalcAttack] 			= CreateForward(ET_Hook,   Param_Cell, Param_Cell, Param_String, Param_CellByRef);
	hPrivFwds[OnRebelGiven] 			= CreateForward(ET_Hook,   Param_Cell);
	hPrivFwds[OnRebelRemoved] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnWardenRemoved] 			= CreateForward(ET_Ignore, Param_Cell);
	hPrivFwds[OnShouldAutobalance] 		= CreateForward(ET_Hook);
	hPrivFwds[OnShouldAutobalancePlayer]= CreateForward(ET_Hook,   Param_Cell);
	hPrivFwds[OnSetWardenLock] 			= CreateForward(ET_Hook,   Param_Cell);
	hPrivFwds[OnPlayMusic]				= CreateForward(ET_Hook,   Param_String, Param_FloatByRef);

	hLegacyFwds[Old_OnWardenGiven] 			= CreateGlobalForward("TF2Jail_OnWardenGiven", ET_Ignore, Param_Cell);
	hLegacyFwds[Old_OnWardenRemoved] 		= CreateGlobalForward("TF2Jail_OnWardenRemoved", ET_Ignore, Param_Cell);
//	hLegacyFwds[Old_OnLastRequestExecute] 	= CreateGlobalForward("TF2Jail_OnLastRequestExecute", ET_Ignore, Param_String);
	hLegacyFwds[Old_OnFreedayGiven] 		= CreateGlobalForward("TF2Jail_OnFreedayGiven", ET_Ignore, Param_Cell);
	hLegacyFwds[Old_OnFreedayRemoved] 		= CreateGlobalForward("TF2Jail_OnFreedayRemoved", ET_Ignore, Param_Cell);
//	hLegacyFwds[Old_OnFreekillerGiven] 		= CreateGlobalForward("TF2Jail_OnFreekillerGiven", ET_Ignore, Param_Cell);
//	hLegacyFwds[Old_OnFreekillerRemoved] 	= CreateGlobalForward("TF2Jail_OnFreekillerRemoved", ET_Ignore, Param_Cell);
	hLegacyFwds[Old_OnRebelGiven] 			= CreateGlobalForward("TF2Jail_OnRebelGiven", ET_Ignore, Param_Cell);
	hLegacyFwds[Old_OnRebelRemoved] 		= CreateGlobalForward("TF2Jail_OnRebelRemoved", ET_Ignore, Param_Cell);
}
void Call_OnDownloads()
{
	Call_StartForward(hPrivFwds[OnDownloads]);
	Call_Finish();
}
void Call_OnRoundStart(Event event)
{
	Call_StartForward(hPrivFwds[OnRoundStart]);
	Call_PushCell(event);
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

	Call_StartForward(hLegacyFwds[Old_OnWardenGiven]);
	Call_PushCell(player);
	Call_Finish();
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
void Call_OnHudShow(char hud[128])
{
	Call_StartForward(hPrivFwds[OnHudShow]);
	Call_PushStringEx(hud, 128, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
Action Call_OnLRPicked(const JailFighter player, const int index, ArrayList array)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnLRPicked]);
	Call_PushCell(player);
	Call_PushCell(index);
	Call_PushCell(array);
	Call_Finish(action);
	return action;
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
void Call_OnMenuAdd(const int index, int &max, char name[64])
{
	Call_StartForward(hPrivFwds[OnMenuAdd]);
	Call_PushCell(index);
	Call_PushCellRef(max);
	Call_PushStringEx(name, 64, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
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
void Call_OnPlayerPrepped(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnPlayerPrepped]);
	Call_PushCell(player);
	Call_Finish();
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
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnTakeDamage]);
	Call_PushCell(victim);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
	Call_PushCell(damagecustom);
	Call_Finish(action);
	return action;
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
	Action action = Plugin_Handled;	// Start as handled because most LRs won't have a background song... probably
	Call_StartForward(hPrivFwds[OnPlayMusic]);
	Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(action);
	return action;
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
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnTimeEnd]);
	Call_Finish(action);
	return action;
}
Action Call_OnLastGuard()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnLastGuard]);
	Call_Finish(action);
	return action;
}
Action Call_OnLastPrisoner()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnLastPrisoner]);
	Call_Finish(action);
	return action;
}
void Call_OnCheckLivingPlayers()
{
	Call_StartForward(hPrivFwds[OnCheckLivingPlayers]);
	Call_Finish();
}
Action Call_OnWardenKilled(const JailFighter victim, const JailFighter attacker, Event event)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnWardenKilled]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish(action);
	return action;
}
void Call_OnFreedayGiven(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnFreedayGiven]);
	Call_PushCell(player);
	Call_Finish();

	Call_StartForward(hLegacyFwds[Old_OnFreedayGiven]);
	Call_PushCell(player);		// Core casts it correctly anyway
	Call_Finish();
}
void Call_OnFreedayRemoved(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnFreedayRemoved]);
	Call_PushCell(player);
	Call_Finish();

	Call_StartForward(hLegacyFwds[Old_OnFreedayRemoved]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnPreThink(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnPreThink]);
	Call_PushCell(player);
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
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsOpen]);
	Call_Finish(action);
	return action;
}
Action Call_OnDoorsClose()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsClose]);
	Call_Finish(action);
	return action;
}
Action Call_OnDoorsLock()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsLock]);
	Call_Finish(action);
	return action;
}
Action Call_OnDoorsUnlock()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnDoorsUnlock]);
	Call_Finish(action);
	return action;
}
Action Call_OnPlayerPreppedPre(const JailFighter player)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnPlayerPreppedPre]);
	Call_PushCell(player);
	Call_Finish(action);
	return action;
}
void Call_OnLRGiven(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnLRGiven]);
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnSoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JailFighter player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnSoundHook]);
	Call_PushArrayEx(clients, 64, SM_PARAM_COPYBACK);
	Call_PushCellRef(numClients);
	Call_PushStringEx(sample, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(player);
	Call_PushCellRef(channel);
	Call_PushFloatRef(volume);
	Call_PushCellRef(level);
	Call_PushCellRef(pitch);
	Call_PushCellRef(flags);
	Call_PushStringEx(soundEntry, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCellRef(seed);
	Call_Finish(action);
	return action;
}
Action Call_OnEntCreated(int entity, const char[] name)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnEntCreated]);
	Call_PushCell(entity);
	Call_PushString(name);
	Call_Finish(action);
	return action;
}
Action Call_OnCalcAttack(JailFighter player, int weapon, char[] weaponname, bool &result)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnCalcAttack]);
	Call_PushCell(player);
	Call_PushCell(weapon);
	Call_PushString(weaponname);
	Call_PushCellRef(result);
	Call_Finish(action);
	return action;
}
Action Call_OnRebelGiven(const JailFighter player)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnRebelGiven]);
	Call_PushCell(player);
	Call_Finish(action);

	Call_StartForward(hLegacyFwds[Old_OnRebelGiven]);
	Call_PushCell(player);
	Call_Finish();
	return action;
}
void Call_OnRebelRemoved(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnRebelRemoved]);
	Call_PushCell(player);
	Call_Finish();

	Call_StartForward(hLegacyFwds[Old_OnRebelRemoved]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnWardenRemoved(const JailFighter player)
{
	Call_StartForward(hPrivFwds[OnWardenRemoved]);
	Call_PushCell(player);
	Call_Finish();

	Call_StartForward(hLegacyFwds[Old_OnWardenRemoved]);
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnShouldAutobalance()
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnShouldAutobalance]);
	Call_Finish(action);
	return action;
}
Action Call_OnShouldAutobalancePlayer(const JailFighter player)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnShouldAutobalancePlayer]);
	Call_PushCell(player);
	Call_Finish(action);
	return action;
}
Action Call_OnSetWardenLock(const bool statusto)
{
	Action action = Plugin_Continue;
	Call_StartForward(hPrivFwds[OnSetWardenLock]);
	Call_PushCell(statusto);
	Call_Finish(action);
	return action;
}