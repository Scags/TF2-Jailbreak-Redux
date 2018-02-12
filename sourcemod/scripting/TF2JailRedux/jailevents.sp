public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter( event.GetInt("userid"), true );
	
	if (!IsClientValid(player.index))
		return Plugin_Continue;

	ManageSpawn(player, event);
	SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter victim = JailFighter( event.GetInt("userid"), true );
	int attacker = GetClientOfUserId( event.GetInt("attacker") );

	if ( victim.index == attacker || attacker <= 0 )
		return Plugin_Continue;

	JailFighter atkr = JailFighter(attacker);
	ManageHurtPlayer(atkr, victim, event);

	return Plugin_Continue;
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return Plugin_Continue;

	JailFighter victim = JailFighter( event.GetInt("userid"), true );	
	JailFighter attacker = JailFighter( event.GetInt("attacker"), true );
	
	ManagePlayerDeath(attacker, victim, event);
	
	return Plugin_Continue;
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (gamemode.bIsMapCompatible)
	{
		if (strlen(sCellOpener) != 0)
		{
			int CellHandler = FindEntity(sCellOpener, "func_button");
			if (IsValidEntity(CellHandler))
				SetEntProp(CellHandler, Prop_Data, "m_bLocked", 1, 1);
			else LogError("***TF2JB ERROR*** Entity name not found for Cell Door Opener! Please verify integrity of the config and the map.");
		}

		if (strlen(sFFButton) != 0)
		{
			int iFFButton = FindEntity(sFFButton, "func_button");
			if (IsValidEntity(iFFButton))
				SetEntProp(iFFButton, Prop_Data, "m_bLocked", 1, 1);
		}
	}
	
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i))
			JailFighter(i).UnmutePlayer();
	}

	gamemode.DoorHandler(CLOSE);
	gamemode.bDisableCriticals = false;
	gamemode.iFreedayLimit = 0;
	gamemode.iRoundState = StateStarting;
	gamemode.iRoundCount++;
	gamemode.bOneGuardLeft = false;
	
	return Plugin_Continue;
}

public Action OnArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	gamemode.bCellsOpened = false;
	gamemode.bWardenExists = false;
	gamemode.bIsWardenLocked = false;
	gamemode.bFirstDoorOpening = false;
	int i;
	bool warday;
	JailFighter player;
	
	if (gamemode.b1stRoundFreeday)
	{
		gamemode.DoorHandler(OPEN);
		PrintCenterTextAll("1st round freeday");

		char s1stDay[256];
		Format(s1stDay, sizeof(s1stDay), "First Day Freeday");
		SetTextNode(hTextNodes[0], s1stDay, EnumTNPS[0][fCoord_X], EnumTNPS[0][fCoord_Y], EnumTNPS[0][fHoldTime], EnumTNPS[0][iRed], EnumTNPS[0][iGreen], EnumTNPS[0][iBlue], EnumTNPS[0][iAlpha], EnumTNPS[0][iEffect], EnumTNPS[0][fFXTime], EnumTNPS[0][fFadeIn], EnumTNPS[0][fFadeOut]);
		
		gamemode.iTimeLeft = cvarTF2Jail[RoundTime_Freeday].IntValue;
		gamemode.iLRType = -1;
	}
	if (cvarTF2Jail[Balance].BoolValue && gamemode.iPlaying > 2)
	{
		float flRatio, flBalance = cvarTF2Jail[BalanceRatio].FloatValue;
		int rand;
		for (i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i))
				continue;

			flRatio = float(GetLivingPlayers(3)) / float(GetLivingPlayers(2));

			if (flRatio <= flBalance)
				break;

			rand = GetRandomPlayer(BLU, true);
			JailFighter(rand).ForceTeamChange(RED);
			CPrintToChat(rand, "{red}[JailRedux]{tan} You have been autobalanced.");
		}
	}

	gamemode.iLRType = gamemode.iLRPresetType;
	//gamemode.bIsLRInUse = true;

	ManageRoundStart();		// THESE FIRE BEFORE INITIALIZATION FUNCTIONS IN THE PLAYER LOOP
	IsFreedayLR();			// This is the only (easy) way for the VSH sub-plugin to grab a random player
	CriticalEnable();		// And force them to be a boss, then OnLRActivate() we force non-bosses to red team
	ManageCells();			// If you need to do something that goes against this functionality, you'll have to
	ManageFFTimer();		// Loop clients on ManageRoundStart() to set what you want, then ignore OnLRActivate()
	ManageHUDText();		// Or if you aren't using the VSH subplugin, ignore this
	ManageFFTimer();
	ManageTimeLeft();

	SetPawnTimer(_MusicPlay, 1.4);
	warday = gamemode.bIsWarday;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (!IsPlayerAlive(i))
			continue;
		
		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);	// For shitheads like Dimmy who ruin fun
		OnLRActivate(player);

		if (warday)
			player.TeleportToPosition(GetClientTeam(i));
	}
	SetPawnTimer(ResetDamage, 1.0);	// Players could teamkill with the flames upon autobalance

	PrintToConsoleAll("[JailRedux] Red Team has been muted.");
	
	gamemode.iLRPresetType = -1;
	gamemode.iRoundState = StateRunning;

	CreateTimer(1.0, Timer_Round, _, FULLTIMER);
	
	if (gamemode.bIsMapCompatible && cvarTF2Jail[DoorOpenTimer].FloatValue != 0.0)
	{
		SetPawnTimer(Open_Doors, cvarTF2Jail[DoorOpenTimer].FloatValue, gamemode.iRoundCount);
		//CreateTimer(cvarTF2Jail[DoorOpenTimer].FloatValue, Open_Doors, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	StopBackGroundMusic();
	JailFighter player;

	for (int i = MaxClients; i; --i)
	{
		if (!IsValidClient(i))
			continue;
		
		TF2Attrib_RemoveAll(i);

		player = JailFighter(i);
		player.UnmutePlayer();
		player.bLockedFromWarden = false;
		player.bIsZombie = false;

		if (player.bIsFreeday)
			player.RemoveFreeday();

		for (int x = 0; x < sizeof(hTextNodes); x++)
		{
			if (hTextNodes[x] != null)
				ClearSyncHud(i, hTextNodes[x]);
		}

		if (GetClientMenu(i) != MenuSource_None)
			CancelClientMenu(i, true);
				
		ManageRoundEnd(player);
	}
	ManageOnRoundEnd(event); // Making 1 with and without clients so things dont fire once for every client in the loop
	
	hEngineConVars[0].SetBool(false);
	hEngineConVars[1].SetBool(false);

	gamemode.bAdminLockWarden = false;
	gamemode.b1stRoundFreeday = false;
	gamemode.bIsLRInUse = false;
	gamemode.bDisableCriticals = false;
	gamemode.bIsWarday = false;
	gamemode.iLRType = -1;
	gamemode.iTimeLeft = 0; // Had to set it to 0 here because it kept glitching out... odd
	gamemode.iRoundState = StateEnding;

	return Plugin_Continue;
}

public Action OnRegeneration(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter( event.GetInt("userid"), true );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public Action OnChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter( (event.GetInt("userid")), true );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public void OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return;

	JailFighter(event.GetInt("userid"), true).bInJump = StrEqual(name, "rocket_jump", false) || StrEqual(name, "sticky_jump", false);
}

/** Events that aren't used in core (but are used in VSH plugin module) :^) **/
public Action ObjectDeflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter airblaster = JailFighter( event.GetInt("userid"), true );
	JailFighter airblasted = JailFighter( event.GetInt("ownerid"), true );
	int weaponid = GetEventInt(event, "weaponid");
	if (weaponid)
		return Plugin_Continue;
	ManageOnAirblast(airblaster, airblasted, event);
	return Plugin_Continue;
}

public Action ObjectDestroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter destroyer = JailFighter( event.GetInt("attacker"), true );
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");
	ManageBuildingDestroyed(destroyer, building, objecttype, event);
	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter jarateer = JailFighter( event.GetInt("thrower_entindex"), true );
	JailFighter jarateed = JailFighter( event.GetInt("victim_entindex"), true );
	ManageOnPlayerJarated(jarateer, jarateed, event);
	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	JailFighter medic = JailFighter( event.GetInt("userid"), true );
	JailFighter patient = JailFighter( event.GetInt("targetid"), true );
	ManageUberDeployed(patient, medic, event);
	return Plugin_Continue;
}