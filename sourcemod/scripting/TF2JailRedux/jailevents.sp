public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	int client = GetClientOfUserId( event.GetInt("userid") );

	if (!IsClientValid(client))
		return Plugin_Continue;

	// BUG; players can spawn as spectators in midround... something to do with ForceTeamChange maybe?
	if (!GetEntProp(client, Prop_Send, "m_iTeamNum"))
	{
		ForcePlayerSuicide(client);
		return Plugin_Continue;
	}

	JailFighter player = JailFighter(client);
	int team = GetClientTeam(client);
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");

//	if (player.bIsFreeday)	// They changed teams, sucks for them
//		player.RemoveFreeday();
	if (player.bIsQueuedFreeday)
	{
		player.GiveFreeday();
		player.TeleportToPosition(FREEDAY);
	}

	if (team == BLU)
	{
		if (AlreadyMuted(client) && cvarTF2Jail[DisableBlueMute].BoolValue && gamemode.iRoundState != StateRunning)
		{
			player.ForceTeamChange(RED);
			EmitSoundToClient(client, "vo/heavy_no03.mp3");
			CPrintToChat(client, "%t %t", "Plugin Tag", "Muted Can't Join");
		}
	}

	if (g_bTF2Attribs)
	{
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:if (cvarTF2Jail[NoDoubleJump].BoolValue) TF2Attrib_SetByDefIndex(client, 49, 1.0);
			case TFClass_Pyro:if (cvarTF2Jail[NoAirblast].BoolValue) TF2Attrib_SetByDefIndex(client, 823, 1.0);
		}
	}

	if (gamemode.bIsWarday)
		player.TeleportToPosition(team);	// Enum value is the same as team value, so we can cheat it

	gamemode.ToggleMuting(player);
	ManageSpawn(player, event);
	SetPawnTimer(PrepPlayer, 0.1, player.userid);

	player.flHealTime = 0.0;
	player.nWardenStabbed = 0;

	return Plugin_Continue;
}

public Action OnPlayerDamaged(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter victim = JailFighter.OfUserId( event.GetInt("userid") );
	JailFighter attacker = JailFighter.OfUserId( event.GetInt("attacker") );

	if (victim.index == attacker.index || attacker.index <= 0)
		return Plugin_Continue;

	ManageHurtPlayer(attacker, victim, event);

	return Plugin_Continue;
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateDisabled)
		return Plugin_Continue;

	JailFighter victim = JailFighter.OfUserId( event.GetInt("userid") );	
	JailFighter attacker = JailFighter.OfUserId( event.GetInt("attacker") );

	if (g_bTF2Attribs)
		TF2Attrib_RemoveAll(victim.index);

	if (IsClientValid(attacker.index))
		if (!gamemode.bDisableKillSpree)
			FreeKillSystem(attacker);

	SetPawnTimer(CheckLivingPlayers, 0.1);

	if (victim.bIsFreeday)
		victim.RemoveFreeday();
	else if (victim.bIsRebel)
		victim.ClearRebel();

	else if (victim.bIsWarden)
	{
		victim.WardenUnset();

		if (gamemode.iRoundState == StateRunning)
		{
			if (Call_OnWardenKilled(victim, attacker, event) == Plugin_Continue || !gamemode.bSilentWardenKills)
				PrintCenterTextAll("%t", "Warden Killed");
		}
	}

	victim.iCustom = 0;
	victim.bSelectingLR = false;
	victim.nWardenStabbed = 0;

	ManagePlayerDeath(attacker, victim, event);
	gamemode.ToggleMuting(victim, true);	// IsPlayerAlive more like returns true on player_death >:c

	return Plugin_Continue;
}

public Action OnPreRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
	{
#if defined _SteamWorks_Included
		if (g_bSteam)
			SteamWorks_SetGameDescription("Team Fortress");
#endif
		return Plugin_Continue;
	}

	JailFighter player;
	int i;
	if (gamemode.bIsMapCompatible)
	{
		if (strCellOpener[0] != '\0')
		{
			i = FindEntity(strCellOpener, "func_button");
			if (i != -1)
				SetEntProp(i, Prop_Data, "m_bLocked", 1, 1);
			else LogError("***TF2JB ERROR*** Entity name not found for Cell Door Opener! Please verify integrity of the config and the map.");
		}

		if (strFFButton[0] != '\0')
		{
			i = FindEntity(strFFButton, "func_button");
			if (i != -1)
				SetEntProp(i, Prop_Data, "m_bLocked", 1, 1);
		}

		if (strCellNames[0] != '\0')
		{
			int ent;
			char entname[32];
			bool hooked;
			for (i = 0; i < sizeof(strDoorsList); i++)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, strDoorsList[i])) != -1)
				{
					GetEntPropString(ent, Prop_Data, "m_iName", entname, sizeof(entname));
					if (StrEqual(entname, strCellNames, false))
					{
						if (!hooked)
						{
							// This is the keystone door. What happens to it (should) happen to the rest of the doors
							// Hook it's outputs so forwards only fire once per output
							if (strcmp(strDoorsList[i], "func_movelinear", false))	// func_movelinears don't have an OnOpen output, but have the input, weird
								HookSingleEntityOutput(ent, "OnOpen", OnCellsOpened);

							// Hooks for full actions, only when the cell(s) finish their open/close action
							HookSingleEntityOutput(ent, "OnFullyOpen", OnCellsFullyOpen);
							HookSingleEntityOutput(ent, "OnFullyClosed", OnCellsFullyClose);

							hooked = true;
						}
					}
				}
			}
		}
	}

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		player = JailFighter(i);
//		if (player.bIsQueuedFreeday && IsPlayerAlive(i))
//		{
//			player.GiveFreeday();
//			player.TeleportToPosition(FREEDAY);
//		}

		ResetVariables(player, false);

		if (strBackgroundSong[0] != '\0')
			StopSound(i, SNDCHAN_AUTO, strBackgroundSong);
	}
	Call_OnRoundReset();

	// gamemode.iLRType = -1;
	gamemode.DoorHandler(CLOSE);
	gamemode.bDisableCriticals = false;
	gamemode.bMedicDisabled = false;
	gamemode.iRoundState = StateStarting;

	return Plugin_Continue;
}

// TODO; optimize me! We're taking on average 20~25ms to get through here! Too slow!!!
public Action OnArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	gamemode.bCellsOpened = false;
	gamemode.bWardenExists = false;
	gamemode.bIsWardenLocked = false;
	gamemode.bWardenStartLocked = false;
	gamemode.bFirstDoorOpening = false;
	gamemode.iLivingMuteType = cvarTF2Jail[LivingMuteType].IntValue;
	gamemode.iMuteType = cvarTF2Jail[MuteType].IntValue;
	gamemode.iWarden = view_as< JailFighter >(0);

	int i;
	JailFighter player;

	CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	SetPawnTimer(CheckLivingPlayers, 0.1);

	if (cvarTF2Jail[Balance].BoolValue)
		gamemode.AutobalanceTeams();

	if (gamemode.b1stRoundFreeday)
	{
		gamemode.DoorHandler(OPEN);

		char firstday[32];
		FormatEx(firstday, sizeof(firstday), "%t", "First Day Freeday");
		SetTextNode(hTextNodes[0], firstday, EnumTNPS[0].fCoord_X, EnumTNPS[0].fCoord_Y, EnumTNPS[0].fHoldTime, EnumTNPS[0].iRed, EnumTNPS[0].iGreen, EnumTNPS[0].iBlue, EnumTNPS[0].iAlpha, EnumTNPS[0].iEffect, EnumTNPS[0].fFXTime, EnumTNPS[0].fFadeIn, EnumTNPS[0].fFadeOut);
		PrintCenterTextAll(firstday);
		
		gamemode.iTimeLeft = cvarTF2Jail[RoundTime_Freeday].IntValue;
		gamemode.iLRType = -1;
		return Plugin_Continue;
	}

	bool warday;
	float time;
	int wep;

	gamemode.iTimeLeft = cvarTF2Jail[RoundTime].IntValue;
	gamemode.iLRType = gamemode.iLRPresetType;
	gamemode.iRoundState = StateRunning;
	gamemode.bIsLRRound = gamemode.iLRType > -1;

	ManageRoundStart();	// NOTE THE ORDER OF EXECUTION; *RoundStart BEFORE *RoundStartPlayer
	ManageHUDText();

	warday = gamemode.bIsWarday;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;

		player = JailFighter(i);
		ManageRoundStartPlayer(player);

		if (warday)
		{
			player.TeleportToPosition(GetClientTeam(i));

			wep = GetPlayerWeaponSlot(i, 2);
			if (wep > MaxClients && IsValidEntity(wep) && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 589 && GetClientTeam(i) == BLU)	// Eureka Effect
			{
				TF2_RemoveWeaponSlot(i, 2);
				player.SpawnWeapon("tf_weapon_wrench", 7, 1, 0, "");
			}

			wep = GetPlayerWeaponSlot(i, 4);
			if (wep > MaxClients && IsValidEntity(wep) && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 60)	// Cloak and Dagger
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
		time = cvarTF2Jail[DoorOpenTimer].FloatValue;
		if (time != 0.0)
			SetPawnTimer(Open_Doors, time, gamemode.iRoundCount);
	}

	time = cvarTF2Jail[WardenDelay].FloatValue;
	if (time != 0.0)
	{
		gamemode.bIsWardenLocked = true;
		// If an LR disables warden, don't use the delayed enablers
		if (!gamemode.bWardenStartLocked)
		{
			if (time == -1.0)
			{
				SetPawnTimer(EnableWarden2, cvarTF2Jail[WardenDelay2].FloatValue, gamemode.iRoundCount);
//				gamemode.FindRandomWarden();
			}
			else SetPawnTimer(EnableWarden, time, gamemode.iRoundCount);
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
	bool attrib = g_bTF2Attribs;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (attrib)
			TF2Attrib_RemoveAll(i);

		player = JailFighter(i);

		if (player.bIsFreeday)
			player.RemoveFreeday();
		else if (player.bIsRebel)
			player.ClearRebel();

		for (x = 0; x < sizeof(hTextNodes); x++)
			if (hTextNodes[x] != null)
				ClearSyncHud(i, hTextNodes[x]);

		if (GetClientMenu(i) != MenuSource_None)
			CancelClientMenu(i, true);

		if (strBackgroundSong[0] != '\0')
			StopSound(i, SNDCHAN_AUTO, strBackgroundSong);

		ManageRoundEnd(player, event);
		player.UnmutePlayer();
		player.bSelectingLR = false;
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
	gamemode.bAllowWeapons = false;
	gamemode.bSilentWardenKills = false;
	gamemode.bDisableMuting = false;
	gamemode.bDisableKillSpree = false;
	gamemode.bIgnoreRebels = false;
	gamemode.bIsLRRound = false;
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

	if (IsClientValid(player.index) 
	&& gamemode.iRoundState != StateEnding 
	&& !player.bSkipPrep
	&& !gamemode.bAllowWeapons)
		SetPawnTimer(PrepPlayer, 0.2, player.userid);

	player.bSkipPrep = false;

	return Plugin_Continue;
}

public Action OnChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailFighter player = JailFighter.OfUserId( event.GetInt("userid") );

	if (IsClientValid(player.index))
		SetPawnTimer(PrepPlayer, 0.1, player.userid);

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
	if (!medic || !patient)
		return Plugin_Continue;

	ManageUberDeployed(patient, medic, event);
	return Plugin_Continue;
}