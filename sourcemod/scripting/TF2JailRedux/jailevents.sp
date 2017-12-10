public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter( event.GetInt("userid"), true );
	if ( player && IsClientInGame(player.index) ) 
	{
		KillWeapons(player);
		ManageWeaponStatus(player);
		ManageSpawn(player, event);

		switch (TF2_GetClientTeam(player.index))
		{
			case TFTeam_Blue:
			{
				player.BlueEquip();
				if (AlreadyMuted(player.index) && gamemode.iLRType != VSH)
				{
					player.ForceTeamChange(RED);
					EmitSoundToClient(player.index, NO);
					CPrintToChat(player.index, "{red}[JailRedux]{tan} You are muted, therefore you cannot join Blue team.");
				}
			}
			case TFTeam_Red:
			{
				player.RedEquip();
				//if (gamemode.iRoundState != StateRunning)
					//CPrintToChat(player.index, "{red}[JailRedux]{tan} Your weapons and ammo have been stripped.");
			}
		}
	}
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

	JailFighter atkr = JailFighter( event.GetInt("attacker"), true );
	ManageHurtPlayer(atkr, victim, event);

	return Plugin_Continue;
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return Plugin_Continue;

	JailFighter victim = JailFighter( event.GetInt("userid"), true );	
	JailFighter attacker = JailFighter( event.GetInt("attacker"), true );

	if (victim.bIsFreeday)
		victim.RemoveFreeday();

	victim.MutePlayer();

	if (victim.iCustom > 0)
		victim.iCustom = 0;
		
	if (victim.bIsWarden)
	{
		victim.WardenUnset();
		gamemode.bWardenExists = false;
		if (gamemode.iRoundState == StateRunning)
		{
			if (cvarTF2Jail[WardenTimer].IntValue != 0)
			{
				int iTimer = gamemode.iRoundCount;
				SetPawnTimer(DisableWarden, cvarTF2Jail[WardenTimer].FloatValue, iTimer);
			}
		}
	}
	if (GetLivingPlayers(3) == 2)
	{
		if (cvarTF2Jail[RemoveFreedayOnLastGuard].BoolValue)
		{
			for (int i = MaxClients; i; --i)
			{
				JailFighter player = JailFighter(i);
				if (IsClientValid(player.index) && player.bIsFreeday)
					player.RemoveFreeday();
			}
		}
		
		/*if (!gamemode.bOneGuardLeft)
		{
			gamemode.bOneGuardLeft = true;
			PrintCenterTextAll("One guard left...");
		}*/
	}

	//SetPawnTimer(CheckAlivePlayers, 0.2);
	
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
			int CellHandler = Entity_FindByName(sCellOpener, "func_button");
			if (IsValidEntity(CellHandler))
				SetEntProp(CellHandler, Prop_Data, "m_bLocked", 1, 1);
			else LogError("***TF2JB ERROR*** Entity name not found for Cell Door Opener! Please verify integrity of the config and the map.");
		}

		if (strlen(sFFButton) != 0)
		{
			int iFFButton = Entity_FindByName(sFFButton, "func_button");
			if (IsValidEntity(iFFButton))
				SetEntProp(iFFButton, Prop_Data, "m_bLocked", 1, 1);
		}
	}
	
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientValid(i))
			continue;
		JailFighter player = JailFighter(i);
		player.UnmutePlayer();
	}

	gamemode.DoorHandler(CLOSE);
	
	//if (gamemode.b1stRoundFreeday)
	//	gamemode.iTimeLeft = cvarTF2Jail[RoundTime_Freeday].IntValue;
	//else gamemode.iTimeLeft = cvarTF2Jail[RoundTime].IntValue;
	
	gamemode.bDisableCriticals = false;
	gamemode.iFreedayLimit = 0;
	gamemode.iRoundState = StateStarting;
	gamemode.iRoundCount++;
	
	return Plugin_Continue;
}

public Action OnArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	gamemode.DoorHandler(CLOSE);
	int i;
	gamemode.bCellsOpened = false;
	gamemode.bWardenExists = false;
	gamemode.bIsWardenLocked = false;
	gamemode.bFirstDoorOpening = false;
	
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
		float flRatio;
		for (i = MaxClients; i; --i)
		{
			if (!IsClientValid(i))
				continue;
			
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);	// For shitheads like Dimmy who ruin fun
			JailFighter player = JailFighter(i);
			flRatio = float(GetLivingPlayers(3)) / float(GetLivingPlayers(2));

			if (flRatio <= 0.5)
				break;

			if (IsClientValid(i) && TF2_GetClientTeam(i) == TFTeam_Blue)
			{
				player.ForceTeamChange(2);
				//TF2_ChangeClientTeam(i, TFTeam_Red);
				//TF2_RespawnPlayer(i);	// ForceTeamChange does this automatically

				CPrintToChat(i, "{red}TF2Jail{tan} You have been autobalanced.");
			}
		}
		SetPawnTimer(ResetDamage, 1.0);	// Players could teamkill with the flames upon autobalance
	}
		
	if (gamemode.iLRPresetType >= 0 || gamemode.iLRPresetType == -2)	// There's bound to be an easier way to do this
	{
		gamemode.iLRType = gamemode.iLRPresetType;
		//gamemode.bIsLRInUse = true;

		ManageRoundStart();		// THESE FIRE BEFORE LOADING FUNCTIONS FOR THE PLAYER LOOP
		IsFreedayLR();			// This is only (easy) way for the VSH sub-plugin to grab a random player
		CriticalEnable();		// And force them to be a boss, then OnLRActivate() we force non-bosses to red team
		ManageCells();			// If you need to do something that goes against this functionality, you'll have to
		ManageFFTimer();		// Loop clients on ManageRoundStart() to set what you want, then ignore OnLRActivate()
		ManageHUDText();
		ManageFFTimer();
		ManageTimeLeft();
		SetPawnTimer(_MusicPlay, 1.4);

		for (i = MaxClients; i; --i)
		{
			if (!IsClientValid(i) || !IsPlayerAlive(i))
				continue;

			JailFighter player = JailFighter(i);
			OnLRActivate(player);	// Handler
			
			/*if (player.bIsFreeday)
				TeleportEntity(player.index, flFreedayPosition, NULL_VECTOR, NULL_VECTOR);*/
		}		
		gamemode.iLRPresetType = -1;
	}
	else 
	{
		gamemode.iLRType = -1;
		gamemode.iTimeLeft = cvarTF2Jail[RoundTime].IntValue;
	}

	gamemode.iRoundState = StateRunning;

	CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	if (gamemode.bIsMapCompatible && cvarTF2Jail[DoorOpenTimer].FloatValue != 0.0)
	{
		int iTimer = gamemode.iRoundCount;
		SetPawnTimer(Open_Doors, cvarTF2Jail[DoorOpenTimer].FloatValue, iTimer);
		//CreateTimer(cvarTF2Jail[DoorOpenTimer].FloatValue, Open_Doors, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	for (i = MaxClients; i; --i)
	{
		if (!IsValidClient(i))
			continue;

		JailFighter player = JailFighter(i);
		if (!player.bIsVIP || !IsPlayerAlive(i))
			player.MutePlayer();
		if (player.bIsVIP || TF2_GetClientTeam(i) == TFTeam_Blue)
			player.UnmutePlayer();

		PrintToConsole(i, "[JailRedux] Red Team has been muted.");
	}

	if (gamemode.bIsWarday)
	{
		for (i = MaxClients; i; --i)
		{
			if (!IsClientValid(i) || !IsPlayerAlive(i))
				continue;
			if (TF2_GetClientTeam(i) == TFTeam_Blue)
				TeleportEntity(i, flWardayBlu, nullvec, nullvec);
			else TeleportEntity(i, flWardayRed, nullvec, nullvec);
		}
	}	
	return Plugin_Continue;
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	StopBackGroundMusic();

	for (int i = MaxClients; i; --i)
	{
		if (!IsValidClient(i))
			continue;
		
		TF2Attrib_RemoveAll(i);
		JailFighter player = JailFighter(i);
		player.UnmutePlayer();

		if (player.bIsFreeday)
			player.RemoveFreeday();

		for (int x = 0; x < sizeof(hTextNodes); x++)
		{
			if (hTextNodes[x] != null)
				ClearSyncHud(i, hTextNodes[x]);
		}
			
		player.bLockedFromWarden = false;

		if (GetClientMenu(i) != MenuSource_None)
			CancelClientMenu(i, true);
				
		ManageRoundEnd(player);
	}
	ManageOnRoundEnd(event); // Making 1 with and without clients so things dont fire once for every client in the loop
	
	SetConVarBool(hEngineConVars[0], false);
	SetConVarBool(hEngineConVars[1], false);

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

	JailFighter player = JailFighter(event.GetInt("userid"), true);

	if (!IsValidClient(player.index))
		return Plugin_Continue;
		
	RequestFrame(KillWeapons, player);
	RequestFrame(ManageWeaponStatus, player);
	
	switch (TF2_GetClientTeam(player.index))
	{
		case TFTeam_Blue:player.BlueEquip();
		case TFTeam_Red:player.RedEquip();
	}

	return Plugin_Continue;
}

public Action OnChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter(GetClientOfUserId(event.GetInt("userid")), true);
	if (IsClientValid(player.index))
	{
		RequestFrame(KillWeapons, player);
		RequestFrame(ManageWeaponStatus, player);
	}

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

	JailFighter destroyer = JailFighter(event.GetInt("attacker"), true);
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");
	ManageBuildingDestroyed(destroyer, building, objecttype, event);
	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter jarateer = JailFighter(event.GetInt("thrower_entindex"), true);
	JailFighter jarateed = JailFighter(event.GetInt("victim_entindex"), true);
	ManageOnPlayerJarated(jarateer, jarateed, event);
	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	JailFighter medic = JailFighter(event.GetInt("userid"), true);
	JailFighter patient = JailFighter(event.GetInt("targetid"), true);
	ManageUberDeployed(patient, medic, event);
	return Plugin_Continue;
}