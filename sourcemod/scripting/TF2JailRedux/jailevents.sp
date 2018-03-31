public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	int client = GetClientOfUserId( event.GetInt("userid") );
	
	if (!IsClientValid(client))
		return Plugin_Continue;

	JailFighter player = JailFighter(client);

	switch (GetClientTeam(client))
	{
		case RED:
		{
			if (player.bIsQueuedFreeday && gamemode.iRoundState == StateStarting)	// Only teleport at round start
			{
				player.GiveFreeday();
				player.TeleportToPosition(FREEDAY);
			}
		}
		case BLU:
		{
			if (AlreadyMuted(client) && cvarTF2Jail[DisableBlueMute].BoolValue)
			{
				player.ForceTeamChange(RED);
				EmitSoundToClient(client, NO);
				CPrintToChat(client, "{red}[TF2Jail]{tan} You are muted, therefore you cannot join Blue Team.");
			}
		}
	}
	if (gamemode.bTF2Attribs)
	{
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:if (cvarTF2Jail[NoDoubleJump].BoolValue) TF2Attrib_SetByDefIndex(client, 49, 1.0);
			case TFClass_Pyro:if (cvarTF2Jail[NoAirblast].BoolValue) TF2Attrib_SetByDefIndex(client, 823, 1.0);
		}
	}

	if (gamemode.bIsWarday)
		player.TeleportToPosition(GetClientTeam(client));	// Enum value is the same as team value, so we can cheat it

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

	if (victim.index == attacker || attacker <= 0)
		return Plugin_Continue;

	JailFighter atkr = JailFighter(attacker);
	ManageHurtPlayer(atkr, victim, event);

	return Plugin_Continue;
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateDisabled)
		return Plugin_Continue;

	JailFighter victim = JailFighter( event.GetInt("userid"), true );	
	JailFighter attacker = JailFighter( event.GetInt("attacker"), true );

	if (gamemode.bTF2Attribs)
		TF2Attrib_RemoveAll(victim.index);

	if (IsClientValid(attacker.index))
	{
		int killcount = cvarTF2Jail[FreeKill].IntValue;
		if (killcount)
			FreeKillSystem(attacker, killcount);
	}

	SetPawnTimer(CheckLivingPlayers, 0.2);

	if (victim.bIsFreeday)
		victim.RemoveFreeday();

	if (victim.bIsWarden)
	{
		victim.WardenUnset();
		gamemode.bWardenExists = false;

		if (gamemode.iRoundState == StateRunning)
		{
			if (Call_OnWardenKilled(victim, attacker, event) == Plugin_Continue)
				PrintCenterTextAll("Warden has been killed!");

			float time = cvarTF2Jail[WardenTimer].FloatValue;
			if (time != 0.0)
				SetPawnTimer(DisableWarden, time, gamemode.iRoundCount);
		}
	}

	if (victim.iCustom)
	{
		if (gamemode.iLRPresetType == Custom)
			gamemode.iLRPresetType = -1;
		victim.iCustom = 0;
	}

	ManagePlayerDeath(attacker, victim, event);

	return Plugin_Continue;
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (gamemode.bIsMapCompatible)
	{
		if (sCellOpener[0] != '\0')
		{
			int CellHandler = FindEntity(sCellOpener, "func_button");
			if (IsValidEntity(CellHandler))
				SetEntProp(CellHandler, Prop_Data, "m_bLocked", 1, 1);
			else LogError("***TF2JB ERROR*** Entity name not found for Cell Door Opener! Please verify integrity of the config and the map.");
		}

		if (sFFButton[0] != '\0')
		{
			int iFFButton = FindEntity(sFFButton, "func_button");
			if (IsValidEntity(iFFButton))
				SetEntProp(iFFButton, Prop_Data, "m_bLocked", 1, 1);
		}
	}
	
	JailFighter player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		player = JailFighter(i);
		ResetVariables(player, false);
	}

	gamemode.iLRType = -1;
	gamemode.DoorHandler(CLOSE);
	gamemode.bDisableCriticals = false;
	gamemode.bOneGuardLeft = false;
	gamemode.bOnePrisonerLeft = false;
	gamemode.iRoundState = StateStarting;

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
	JailFighter player;

	CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	SetPawnTimer(CheckLivingPlayers, 0.2);

	if (cvarTF2Jail[Balance].BoolValue && gamemode.iPlaying > 2)
	{
		int flamemanager;
		bool immunity = cvarTF2Jail[AutobalanceImmunity].BoolValue;
		float ratio;
		float balance = cvarTF2Jail[BalanceRatio].FloatValue;
		float lBlue = float(GetLivingPlayers(BLU));
		float lRed = float(GetLivingPlayers(RED));

		for (i = MaxClients; i; --i)	// 2 player loops so that autobalance doesn't fuck over ManageRoundStart()
		{
			if (!IsClientInGame(i))
				continue;
			if (!IsPlayerAlive(i))
				continue;

			ratio = lBlue / lRed;

			if (ratio > balance)
			{
				player = JailFighter(GetRandomPlayer(BLU, true));
				if ((immunity && !player.bIsVIP) || !immunity)
				{
					if (HasEntProp(i, Prop_Send, "m_hFlameManager"))
					{
						flamemanager = GetEntPropEnt(i, Prop_Send, "m_hFlameManager");	// Avoid teamkilling
						if (flamemanager != -1)
							AcceptEntityInput(flamemanager, "Kill");
					}
					player.ForceTeamChange(RED);
					CPrintToChat(player.index, "{red}[TF2Jail]{tan} You have been autobalanced.");

					lBlue--;	// Avoid loopception
					lRed++;
				}
			}
		}
	}
	
	if (gamemode.b1stRoundFreeday)
	{
		gamemode.DoorHandler(OPEN);
		PrintCenterTextAll("1st round freeday");

		char s1stDay[256];
		strcopy(s1stDay, sizeof(s1stDay), "First Day Freeday");
		SetTextNode(hTextNodes[0], s1stDay, EnumTNPS[0][fCoord_X], EnumTNPS[0][fCoord_Y], EnumTNPS[0][fHoldTime], EnumTNPS[0][iRed], EnumTNPS[0][iGreen], EnumTNPS[0][iBlue], EnumTNPS[0][iAlpha], EnumTNPS[0][iEffect], EnumTNPS[0][fFXTime], EnumTNPS[0][fFadeIn], EnumTNPS[0][fFadeOut]);
		
		gamemode.iTimeLeft = cvarTF2Jail[RoundTime_Freeday].IntValue;
		gamemode.iLRType = -1;
		return Plugin_Continue;
	}

	bool warday;
	float delay;

	gamemode.iLRType = gamemode.iLRPresetType;
	gamemode.iRoundState = StateRunning;


	ManageRoundStart();		// THESE FIRE BEFORE INITIALIZATION FUNCTIONS IN THE PLAYER LOOP
	ManageCells();			// This is the only (easy) way for the VSH sub-plugin to grab a random player
	ManageFFTimer();		// And force them to be a boss, then OnLRActivate() we force non-bosses to red team
	ManageHUDText();		// If you need to do something that goes against this functionality, you'll have to
	ManageTimeLeft();		// Loop clients on ManageRoundStart() to set what you want, then ignore OnLRActivate()
	// Or if you aren't using the VSH subplugin, ignore this

	SetPawnTimer(_MusicPlay, 1.4);

	warday = gamemode.bIsWarday;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;

		player = JailFighter(i);
		player.bIsQueuedFreeday = false;

		OnLRActivate(player);

		if (warday)
			player.TeleportToPosition(GetClientTeam(i));
	}

	gamemode.iLRPresetType = -1;
	
	if (gamemode.bIsMapCompatible && cvarTF2Jail[DoorOpenTimer].FloatValue != 0.0)
		SetPawnTimer(Open_Doors, cvarTF2Jail[DoorOpenTimer].FloatValue, gamemode.iRoundCount);

	delay = cvarTF2Jail[WardenDelay].FloatValue;
	if (delay != 0.0)
	{
		gamemode.bIsWardenLocked = true;
		SetPawnTimer(EnableWarden, delay, gamemode.iRoundCount);
	}
	return Plugin_Continue;
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	StopBackGroundMusic();
	JailFighter player;
	int i, x;
	bool attrib = gamemode.bTF2Attribs;
	gamemode.iRoundCount++;

	for (i = MaxClients; i; --i)
	{
		if (!IsValidClient(i))
			continue;
		
		if (attrib)
			TF2Attrib_RemoveAll(i);

		player = JailFighter(i);
		player.bLockedFromWarden = false;

		if (player.bIsFreeday)
			player.RemoveFreeday();

		for (x = 0; x < sizeof(hTextNodes); x++)
		{
			if (hTextNodes[x] != null)
				ClearSyncHud(i, hTextNodes[x]);
		}

		if (GetClientMenu(i) != MenuSource_None && !IsVoteInProgress())
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
	// gamemode.iLRType = -1;
	gamemode.iTimeLeft = 0; // Had to set it to 0 here because it kept glitching out... odd
	gamemode.iRoundState = StateEnding;

	return Plugin_Continue;
}

/*public Action OnRegeneration(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter( event.GetInt("userid"), true );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}*/

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

	JailFighter( event.GetInt("userid"), true ).bInJump = StrEqual(name, "rocket_jump", false) || StrEqual(name, "sticky_jump", false);
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