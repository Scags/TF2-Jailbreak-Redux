public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	int client = GetClientOfUserId( event.GetInt("userid") );
	
	if (!IsClientValid(client))
		return Plugin_Continue;

	JailFighter player = JailFighter(client);
	SetEntityModel(client, "");

	switch (GetClientTeam(client))
	{
		case RED:
		{
			if (player.bIsQueuedFreeday)
			{
				player.GiveFreeday();
				player.TeleportToPosition(FREEDAY);
			}
		}
		case BLU:
		{
			if (AlreadyMuted(client) && cvarTF2Jail[DisableBlueMute].BoolValue && gamemode.iRoundState != StateRunning)
			{
				player.ForceTeamChange(RED);
				EmitSoundToClient(client, NO);
				CPrintToChat(client, TAG ... "%t", "Muted Can't Join");
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

	gamemode.ToggleMuting(player);
	ManageSpawn(player, event);
	SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter victim = JailFighter.OfUserId( event.GetInt("userid") );
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

	JailFighter victim = JailFighter.OfUserId( event.GetInt("userid") );	
	JailFighter attacker = JailFighter.OfUserId( event.GetInt("attacker") );

	if (gamemode.bTF2Attribs)
		TF2Attrib_RemoveAll(victim.index);

	if (IsClientValid(attacker.index))
	{
		if (!gamemode.bDisableKillSpree)
		{
			int killcount = cvarTF2Jail[FreeKill].IntValue;
			if (killcount)
				FreeKillSystem(attacker, killcount);
		}
	}

	SetPawnTimer(CheckLivingPlayers, 0.2);

	if (victim.bIsFreeday)
		victim.RemoveFreeday();

	if (victim.bIsWarden)
	{
		victim.WardenUnset();
		gamemode.bWardenExists = false;

		if (gamemode.iRoundState == StateRunning)
			if (Call_OnWardenKilled(victim, attacker, event) == Plugin_Continue || !gamemode.bSilentWardenKills)
				PrintCenterTextAll("%t", "Warden Killed");
	}

	if (victim.iCustom)
	{
		if (gamemode.iLRPresetType == Custom)
			gamemode.iLRPresetType = -1;
		victim.iCustom = 0;
	}

	ManagePlayerDeath(attacker, victim, event);
	gamemode.ToggleMuting(victim, true);	// IsPlayerAlive more like returns true on player_death >:c

	return Plugin_Continue;
}

public Action OnPreRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
	{
		Steam_SetGameDescription("Team Fortress");
		return Plugin_Continue;
	}

	JailFighter player;
	int i;
	if (gamemode.bIsMapCompatible)
	{
		int ent;
		if (sCellOpener[0] != '\0')
		{
			ent = FindEntity(sCellOpener, "func_button");
			if (IsValidEntity(ent))
				SetEntProp(ent, Prop_Data, "m_bLocked", 1, 1);
			else LogError("***TF2JB ERROR*** Entity name not found for Cell Door Opener! Please verify integrity of the config and the map.");
		}

		if (sFFButton[0] != '\0')
		{
			ent = FindEntity(sFFButton, "func_button");
			if (IsValidEntity(ent))
				SetEntProp(ent, Prop_Data, "m_bLocked", 1, 1);
		}

		if (sCellNames[0] != '\0')
		{
			char sEntityName[32];
			for (i = 0; i < sizeof(sDoorsList); i++)
			{
				ent = -1;
				while ((ent = FindEntityByClassnameSafe(ent, sDoorsList[i])) != -1)
				{
					GetEntPropString(ent, Prop_Data, "m_iName", sEntityName, sizeof(sEntityName));
					if (StrEqual(sEntityName, sCellNames, false))	// Laziness, hook first cell door opening so open door timer catches and doesn't open on its own
						HookSingleEntityOutput(ent, "OnOpen", OnFirstCellOpening, true);
				}
			}
		}
	}

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		player = JailFighter(i);
		if (player.bIsQueuedFreeday && IsPlayerAlive(i))
		{
			player.GiveFreeday();
			player.TeleportToPosition(FREEDAY);
		}

		ResetVariables(player, false);
	}

	// gamemode.iLRType = -1;
	gamemode.DoorHandler(CLOSE);
	gamemode.bDisableCriticals = false;
	gamemode.bMedicDisabled = false;
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
	gamemode.iLivingMuteType = cvarTF2Jail[LivingMuteType].IntValue;
	gamemode.iMuteType = cvarTF2Jail[MuteType].IntValue;

	int i;
	JailFighter player;

	CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	SetPawnTimer(CheckLivingPlayers, 0.2);

	if (cvarTF2Jail[Balance].BoolValue && gamemode.iPlaying > 2)
	{
		int flamemanager;
		int immunity = cvarTF2Jail[AutobalanceImmunity].IntValue;
		float ratio;
		float balance = cvarTF2Jail[BalanceRatio].FloatValue;
		float lBlue = float( GetLivingPlayers(BLU) );
		float lRed = float( GetLivingPlayers(RED) );

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
				if ((immunity == 2 && !player.bIsAdmin) || (immunity == 1 && !player.bIsVIP) || !immunity)
				{
					if (HasEntProp(i, Prop_Send, "m_hFlameManager"))
					{
						flamemanager = GetEntPropEnt(i, Prop_Send, "m_hFlameManager");	// Avoid teamkilling
						if (flamemanager != -1)
							AcceptEntityInput(flamemanager, "Kill");
					}
					player.ForceTeamChange(RED);
					CPrintToChat(player.index, TAG ... "%t", "Autobalanced");

					lBlue--;	// Avoid loopception
					lRed++;
				}
			}
		}
	}

	if (gamemode.b1stRoundFreeday)
	{
		gamemode.DoorHandler(OPEN);

		char s1stDay[32];
		FormatEx(s1stDay, sizeof(s1stDay), "%t", "First Day Freeday");
		SetTextNode(hTextNodes[0], s1stDay, EnumTNPS[0][fCoord_X], EnumTNPS[0][fCoord_Y], EnumTNPS[0][fHoldTime], EnumTNPS[0][iRed], EnumTNPS[0][iGreen], EnumTNPS[0][iBlue], EnumTNPS[0][iAlpha], EnumTNPS[0][iEffect], EnumTNPS[0][fFXTime], EnumTNPS[0][fFadeIn], EnumTNPS[0][fFadeOut]);
		PrintCenterTextAll(s1stDay);
		
		gamemode.iTimeLeft = cvarTF2Jail[RoundTime_Freeday].IntValue;
		gamemode.iLRType = -1;
		return Plugin_Continue;
	}

	bool warday;
	float delay;
	int wep;

	gamemode.iLRType = gamemode.iLRPresetType;
	gamemode.iRoundState = StateRunning;

	ManageOnRoundStart(event);	// THESE FIRE BEFORE INITIALIZATION FUNCTIONS IN THE PLAYER LOOP
	ManageCells();				// This is the only (easy) way for the VSH sub-plugin to grab a random player
	ManageFFTimer();			// And force them to be a boss, then ManageRoundStart() we force non-bosses to red team
	ManageHUDText();			// If you need to do something that goes against this functionality, you'll have to
	ManageTimeLeft();			// Loop clients on ManageRoundStart() to set what you want, then ignore OnLRActivate()
	// Or if you aren't using the VSH subplugin, ignore this

	warday = gamemode.bIsWarday;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;

		player = JailFighter(i);
		ManageRoundStart(player, event);

		if (warday)
		{
			player.TeleportToPosition(GetClientTeam(i));

			wep = GetPlayerWeaponSlot(i, 2);
			if (wep > MaxClients && IsValidEdict(wep) && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 589 && GetClientTeam(i) == BLU)	// Eureka Effect
			{
				TF2_RemoveWeaponSlot(i, 2);
				player.SpawnWeapon("tf_weapon_wrench", 7, 1, 0, "");
			}

			wep = GetPlayerWeaponSlot(i, 4);
			if (wep > MaxClients && IsValidEdict(wep) && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 60)	// Cloak and Dagger
			{
				TF2_RemoveWeaponSlot(i, 4);
				player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "");
			}
		}
		gamemode.ToggleMuting(player);
	}

	gamemode.iLRPresetType = -1;

	if (gamemode.bIsMapCompatible)
	{
		float dooropen = cvarTF2Jail[DoorOpenTimer].FloatValue;
		if (dooropen != 0.0)
			SetPawnTimer(Open_Doors, dooropen, gamemode.iRoundCount);
	}

	delay = cvarTF2Jail[WardenDelay].FloatValue;
	if (delay != 0.0)
	{
		if (delay == -1.0)
			gamemode.FindRandomWarden();
		else
		{
			gamemode.bIsWardenLocked = true;
			SetPawnTimer(EnableWarden, delay, gamemode.iRoundCount);
		}
	}

	gamemode.flMusicTime = GetGameTime() + 1.4;
	return Plugin_Continue;
}

public Action OnRoundEnded(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player;
	int i, x;
	bool attrib = gamemode.bTF2Attribs;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (attrib)
			TF2Attrib_RemoveAll(i);

		player = JailFighter(i);

		if (player.bIsFreeday)
			player.RemoveFreeday();

		for (x = 0; x < sizeof(hTextNodes); x++)
			if (hTextNodes[x] != null)
				ClearSyncHud(i, hTextNodes[x]);

		if (GetClientMenu(i) != MenuSource_None)
			CancelClientMenu(i, true);

		StopSound(i, SNDCHAN_AUTO, BackgroundSong);

		ManageRoundEnd(player, event);
		player.UnmutePlayer();
	}
	ManageOnRoundEnd(event); // Making 1 with and without clients so things dont fire once for every client in the loop
	
	hEngineConVars[0].SetBool(false);
	hEngineConVars[1].SetBool(false);

	gamemode.b1stRoundFreeday = false;
	gamemode.bIsLRInUse = false;
	gamemode.bDisableCriticals = false;
	gamemode.bIsWarday = false;
	gamemode.bOneGuardLeft = false;
	gamemode.bOnePrisonerLeft = false;
	gamemode.bAllowBuilding = false;
	gamemode.bSilentWardenKills = false;
	gamemode.bDisableMuting = false;
	gamemode.bDisableKillSpree = false;
	gamemode.iLRType = -1;
	gamemode.iTimeLeft = 0; // Had to set it to 0 here because it kept glitching out... odd
	gamemode.iRoundState = StateEnding;
	gamemode.iRoundCount++;

	return Plugin_Continue;
}

public Action OnRegeneration(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter.OfUserId( event.GetInt("userid") );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public Action OnChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter.OfUserId( event.GetInt("userid") );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	return Plugin_Continue;
}

public void OnChangeTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return;

	if (event.GetBool("disconnect"))
		return;

	gamemode.ToggleMuting(JailFighter.OfUserId( event.GetInt("userid") ), _, event.GetInt("team"));
}

public void OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return;

	JailFighter.OfUserId( event.GetInt("userid") ).bInJump = StrEqual(name, "rocket_jump", false) || StrEqual(name, "sticky_jump", false);
}

/** Events that aren't used in core (but are used in VSH plugin module) :^) **/
public Action ObjectDeflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter airblaster = JailFighter.OfUserId( event.GetInt("userid") );
	JailFighter airblasted = JailFighter.OfUserId( event.GetInt("ownerid") );
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

	JailFighter destroyer = JailFighter.OfUserId( event.GetInt("attacker") );
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");
	ManageBuildingDestroyed(destroyer, building, objecttype, event);
	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter jarateer = JailFighter.OfUserId( event.GetInt("thrower_entindex") );
	JailFighter jarateed = JailFighter.OfUserId( event.GetInt("victim_entindex") );
	ManageOnPlayerJarated(jarateer, jarateed, event);
	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	JailFighter medic = JailFighter.OfUserId( event.GetInt("userid") );
	JailFighter patient = JailFighter.OfUserId( event.GetInt("targetid") );
	ManageUberDeployed(patient, medic, event);
	return Plugin_Continue;
}