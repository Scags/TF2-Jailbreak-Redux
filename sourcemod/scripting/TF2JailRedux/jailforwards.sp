methodmap PrivateForward < Handle
{	// Nergal saves the day!
	public PrivateForward( const Handle forw )
	{
		if (forw != null)
			return view_as<PrivateForward>( forw );
		return null;
	}
	property int FuncCount 
	{
		public get()	{ return GetForwardFunctionCount(this); }
	}
	public bool Add(Handle plugin, Function func)
	{
		return AddToForward(this, plugin, func);
	}
	public bool Remove(Handle plugin, Function func)
	{
		return RemoveFromForward(this, plugin, func);
	}
	public int RemoveAll(Handle plugin)
	{
		return RemoveAllFromForward(this, plugin);
	}
	public void Start()
	{
		Call_StartForward(this);
	}
};

PrivateForward
	g_hForwards[OnMusicPlay+1]
;

void InitializeForwards()
{
	g_hForwards[OnDownloads] 			= new PrivateForward( CreateForward(ET_Ignore) );
	g_hForwards[OnLRRoundActivate] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnManageRoundStart] 	= new PrivateForward( CreateForward(ET_Ignore) );
	g_hForwards[OnManageRoundEnd] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnLRRoundEnd] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnWardenGet] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnClientTouch]			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnRedThink] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnAllBlueThink] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBlueNotWardenThink] 	= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnWardenThink] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnLRTextHud] 			= new PrivateForward( CreateForward(ET_Ignore, Param_String) );
	g_hForwards[OnLRPicked] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef) );
	g_hForwards[OnPlayerDied] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnBuildingDestroyed]	= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnObjectDeflected] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnPlayerJarated] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnUberDeployed] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnPlayerSpawned]		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnMenuAdd] 				= new PrivateForward( CreateForward(ET_Ignore, Param_CellByRef, Param_Cell) );
	g_hForwards[OnPanelAdd] 			= new PrivateForward( CreateForward(ET_Ignore, Param_CellByRef) );
	g_hForwards[OnManageTimeLeft] 		= new PrivateForward( CreateForward(ET_Ignore) );
	g_hForwards[OnPlayerPrepped] 		= new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnHurtPlayer] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnHookDamage] 			= new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell) );
	g_hForwards[OnWMenuAdd] 			= new PrivateForward( CreateForward(ET_Ignore, Param_CellByRef) );
	g_hForwards[OnWMenuSelect] 			= new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_String) );
	g_hForwards[OnMusicPlay]			= new PrivateForward( CreateForward(ET_Ignore, Param_String, Param_FloatByRef) );
}
void Call_OnDownloads()
{
	g_hForwards[OnDownloads].Start();
	Call_Finish();
}
void Call_OnLRRoundActivate(const JailFighter player)
{
	g_hForwards[OnLRRoundActivate].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnManageRoundStart()
{
	g_hForwards[OnManageRoundStart].Start();
	Call_Finish();
}
void Call_OnManageRoundEnd(Event event)
{
	g_hForwards[OnManageRoundEnd].Start();
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnLRRoundEnd(const JailFighter player)
{
	g_hForwards[OnLRRoundEnd].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnWardenGet(const JailFighter player)
{
	g_hForwards[OnWardenGet].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnClientTouch(const JailFighter toucher, const JailFighter touchee)
{
	g_hForwards[OnClientTouch].Start();
	Call_PushCell(toucher);
	Call_PushCell(touchee);
	Call_Finish();
}
void Call_OnRedThink(const JailFighter player)
{
	g_hForwards[OnRedThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnAllBlueThink(const JailFighter player)
{
	g_hForwards[OnAllBlueThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBlueNotWardenThink(const JailFighter player)
{
	g_hForwards[OnBlueNotWardenThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnWardenThink(const JailFighter player)
{
	g_hForwards[OnWardenThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnLRTextHud(char strHud[128])
{
	g_hForwards[OnLRTextHud].Start();
	Call_PushString(strHud);
	Call_Finish();
}
void Call_OnLRPicked(const JailFighter player, const int request, const int value, ArrayList & array)
{
	g_hForwards[OnLRPicked].Start();
	Call_PushCell(player);
	Call_PushCell(request);
	Call_PushCell(value);
	Call_PushCellRef(array);
	Call_Finish();
}
void Call_OnPlayerDied(const JailFighter player, const JailFighter victim, Event event)
{
	g_hForwards[OnPlayerDied].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnObjectDeflected(const JailFighter airblaster, const JailFighter airblasted, Event event)
{
	g_hForwards[OnObjectDeflected].Start();
	Call_PushCell(airblaster);
	Call_PushCell(airblasted);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnBuildingDestroyed(const JailFighter destroyer, const int building, Event event)
{
	g_hForwards[OnBuildingDestroyed].Start();
	Call_PushCell(destroyer);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnPlayerJarated(const JailFighter jarateer, const JailFighter jarateed, Event event)
{
	g_hForwards[OnPlayerJarated].Start();
	Call_PushCell(jarateer);
	Call_PushCell(jarateed);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnUberDeployed(const JailFighter patient, const JailFighter medic, Event event)
{
	g_hForwards[OnUberDeployed].Start();
	Call_PushCell(patient);
	Call_PushCell(medic);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerSpawned(const JailFighter player, Event event)
{
	g_hForwards[OnPlayerSpawned].Start();
	Call_PushCell(player);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnMenuAdd(Menu & menu, ArrayList array)
{
	g_hForwards[OnMenuAdd].Start();
	Call_PushCellRef(menu);
	Call_PushCell(array);
	Call_Finish();
}
void Call_OnPanelAdd(Menu & panel)
{
	g_hForwards[OnPanelAdd].Start();
	Call_PushCellRef(panel);
	Call_Finish();
}
void Call_OnManageTimeLeft()
{
	g_hForwards[OnManageTimeLeft].Start();
	Call_Finish();
}
void Call_OnPlayerPrepped(const JailFighter player)
{
	g_hForwards[OnPlayerPrepped].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnHurtPlayer(const JailFighter victim, const JailFighter attacker, int damage, int custom, int weapon, Event event)
{
	g_hForwards[OnHurtPlayer].Start();
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_PushCell(custom);
	Call_PushCell(weapon);
	Call_PushCell(event);
	Call_Finish();
}
Action Call_OnHookDamage(const JailFighter victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	g_hForwards[OnHookDamage].Start();
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
	g_hForwards[OnWMenuAdd].Start();
	Call_PushCellRef(menu);
	Call_Finish();
}
void Call_OnWMenuSelect(const JailFighter player, const char[] index)
{
	g_hForwards[OnWMenuSelect].Start();
	Call_PushCell(player);
	Call_PushString(index);
	Call_Finish();
}
void Call_OnMusicPlay(char song[PLATFORM_MAX_PATH], float & time)
{
	g_hForwards[OnMusicPlay].Start();
	Call_PushStringEx(song, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish();
}