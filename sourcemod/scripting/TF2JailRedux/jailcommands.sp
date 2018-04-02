public Action Command_Help(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;
	
	Panel panel = new Panel();
	panel.SetTitle("Welcome to TF2Jail Redux!");
	panel.DrawItem("Who's the current warden?");
	panel.DrawItem("What are the last requests?");
#if defined _clientprefs_included
	panel.DrawItem("Turn off the background music?");
#endif
	panel.Send(client, Panel_Help, 9001);
	delete panel;
	
	return Plugin_Handled;
}

public int Panel_Help(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (select)
			{
				case 0:
				{
					if (gamemode.bWardenExists)
						CPrintToChat(client, "{crimson}[TF2Jail]{default} %N{burlywood} is the current warden.", gamemode.FindWarden().index);
					else CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} There is no current warden.");
				}
				case 1:ListLastRequestPanel(client);
#if defined _clientprefs_included
				case 2:MusicPanel(client);
#endif
			}
		}
	}
}

public Action Command_BecomeWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.bWardenExists)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{default} %N{burlywood} is the current warden.", gamemode.FindWarden().index);
		return Plugin_Handled;
	}
	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You must be alive.");
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != BLU)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not on Blue Team.");
		return Plugin_Handled;
	}

	if (gamemode.bAdminLockWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Admin has locked warden.");
		return Plugin_Handled;
	}

	if (gamemode.b1stRoundFreeday || gamemode.bIsWardenLocked)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Warden is locked.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (player.bLockedFromWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You may not become warden until next round.");
		return Plugin_Handled;
	}
	if (player.bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are already warden.");
		return Plugin_Handled;
	}
	
	player.WardenSet();
	player.WardenMenu();
	gamemode.bWardenExists = true;
	return Plugin_Handled;
}

public Action Command_ExitWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(player.index, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has retired!", client);
	PrintCenterTextAll("Warden has retired!");

	player.bLockedFromWarden = true;
	player.WardenUnset();
	gamemode.bWardenExists = false;
	
	return Plugin_Handled;
}

public Action Command_WardenMenu(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	player.WardenMenu();
	return Plugin_Handled;
}

public Action Command_OpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Map is incompatible.");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN);
	CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has closed cells.", client);

	return Plugin_Handled;
}

public Action Command_CloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Map is incompatible.");
		return Plugin_Handled;
	}
	
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE);
	CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has closed cells.", client);

	return Plugin_Handled;
}

public Action Command_EnableFriendlyFire(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	switch (hEngineConVars[0].BoolValue)
	{
		case true:
		{
			hEngineConVars[0].SetBool(false);
			CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has disabled Friendly-Fire.", client);
		}
		case false:
		{
			hEngineConVars[0].SetBool(true);
			CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has enabled Friendly-Fire.", client);
		}
	}
	return Plugin_Handled;
}

public Action Command_EnableCollisions(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	switch (hEngineConVars[1].BoolValue)
	{
		case true:
		{
			hEngineConVars[1].SetBool(false);
			CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has disabled collisions.", client);
		}
		case false:
		{
			hEngineConVars[1].SetBool(true);
			CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has enabled collisions.", client);
		}
	}
	return Plugin_Handled;
}

public Action Command_GiveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (args >= 2)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Usage: sm_givelr or sm_givelr <playername>");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (gamemode.bAdminLockedLR)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Admin has locked LR.");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}
	if (gamemode.bIsLRInUse)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Last Request has already been given.");
		return Plugin_Handled;
	}

	if (!args)
	{
		if (IsVoteInProgress())
			return Plugin_Handled;

		Menu menu = new Menu(MenuHandle_ForceLR);
		menu.SetTitle("Choose a Player");
		AddClientsToMenu(menu, true);
		menu.ExitButton = true;
		menu.Display(client, -1);

		return Plugin_Handled;
	}

	if (args == 1)
	{
		char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
		int target = FindTarget(client, targetname);
		if (!IsClientValid(target))
			return Plugin_Handled;

		if (!IsPlayerAlive(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target is not alive.");
			return Plugin_Handled;
		}
		if (GetClientTeam(target) != RED)
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target is not on Red Team.");
			return Plugin_Handled;
		}
		JailFighter(target).ListLRS();
	}

	return Plugin_Handled;
}

void AddClientsToMenu(Menu &menu, bool alive = false, int team = RED)
{
	char strName[32], strID[8];
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		if (GetClientTeam(i) != team)
			continue;

		IntToString(GetClientUserId(i), strID, sizeof(strID));
		GetClientName(i, strName, sizeof(strName));
		menu.AddItem(strID, strName);
	}
}

public Action Command_RemoveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[DenyLR].BoolValue)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Denying last requests has been disabled.");
		return Plugin_Handled;
	}

	if (gamemode.iLRPresetType < 0)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} There is no last request set for next round.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			JailFighter(i).bIsQueuedFreeday = false;

	arrLRS.Set( gamemode.iLRPresetType, arrLRS.Get(gamemode.iLRPresetType)-1 );
	gamemode.bIsLRInUse = false;
	gamemode.iLRPresetType = -1;
	CPrintToChatAll("{crimson}[TF2Jail]{burlywood}Warden {default}%N{burlywood} has denied the Last Request!", client);

	return Plugin_Handled;
}

public Action Command_ListLastRequests(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}

	ListLastRequestPanel(client);
	return Plugin_Handled;
}

public void ListLastRequestPanel(const int client)
{
	if (IsVoteInProgress())
		return;

	Menu panel = new Menu(ListLRsPanel);
	panel.SetTitle("Last Request List");
	AddLRToPanel(panel);
	panel.ExitButton = true;
	panel.Display(client, -1);
}

public int ListLRsPanel(Menu menu, MenuAction action, int client, int select)
{
	return;
}

public Action Command_CurrentWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
		CReplyToCommand(client, "{crimson}[TF2Jail]{default} %N{burlywood} is the current warden.", gamemode.FindWarden().index);
	else CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} There is no current warden.");

	return Plugin_Handled;
}

public Action AdminRemoveWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (!gamemode.bWardenExists)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} There is no current warden.");
		return Plugin_Handled;
	}
	gamemode.FireWarden(false);
	
	return Plugin_Handled;
}

public Action AdminDenyLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iLRPresetType == -1)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} There is no last request set for next round.");
		return Plugin_Handled;
	}

	JailFighter player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		
		player = JailFighter(i);
		if (player.bIsQueuedFreeday)
		{
			CPrintToChat(i, "{orange}[TF2Jail]{burlywood} An Admin has removed your queued freeday!");
			player.bIsQueuedFreeday = false;
		}

		if (player.bIsFreeday)
		{
			CPrintToChat(i, "{orange}[TF2Jail]{burlywood} An Admin has removed your freeday!");
			player.RemoveFreeday();
		}
	}

	int type = gamemode.iLRPresetType;
	arrLRS.Set( type, arrLRS.Get(type)-1 );
	gamemode.iLRPresetType = -1;
	gamemode.bIsLRInUse = false;

	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has denied the current last request!");

	return Plugin_Handled;
}

public Action AdminOpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Map is not compatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN);
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has opened cells.");

	return Plugin_Handled;
}

public Action AdminCloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE);
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has closed cells.");

	return Plugin_Handled;
}

public Action AdminLockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(LOCK);
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has locked cells.");

	return Plugin_Handled;
}

public Action AdminUnlockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(UNLOCK);
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has unlocked cells.");

	return Plugin_Handled;
}

public Action AdminForceWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{fullred} %N{burlywood} is the current warden.", gamemode.FindWarden().index);
		return Plugin_Handled;
	}

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target must be alive.");
			return Plugin_Handled;
		}

		if (GetClientTeam(target) != BLU)
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target is not on Blue Team.");
			return Plugin_Handled;
		}

		JailFighter targ = JailFighter(target);
		targ.WardenSet();
		targ.WardenMenu();
		CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has forced {default}%N{burlywood} as warden.", target);
		gamemode.bWardenExists = true;
		
		return Plugin_Handled;
	}

	gamemode.FindRandomWarden();
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has forced a random player as warden.");
	return Plugin_Handled;
}

public Action AdminForceLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	
	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
			return Plugin_Handled;
		}
		CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has forced {fullred}%N{burlywood} to receive a Last Request.", target);
		JailFighter(target).ListLRS();

		return Plugin_Handled;
	}

	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has forced a Last Request for themselves.");
	JailFighter(client).ListLRS();

	return Plugin_Handled;
}

public Action AdminResetPlugin(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		ResetVariables(JailFighter(i), false);
	}

	gamemode.iRoundState = 0;
	gamemode.iTimeLeft = 0;
	gamemode.iRoundCount = 0;
	gamemode.iLRPresetType = -1;
	gamemode.iLRType = -1;
	gamemode.bFreedayTeleportSet = false;
	gamemode.bIsFreedayRound = false;
	gamemode.bDisableCriticals = false;
	gamemode.bWardenExists = false;
	gamemode.bFirstDoorOpening = false;
	gamemode.bAdminLockedLR = false;
	gamemode.bAdminLockWarden = false;
	gamemode.bIsWarday = false;
	gamemode.bOneGuardLeft = false;
	gamemode.bOnePrisonerLeft = false;
	gamemode.bIsLRInUse = false;
	gamemode.b1stRoundFreeday = false;
	gamemode.bCellsOpened = false;
	gamemode.bIsMapCompatible = false;

	ParseConfigs();
	CPrintToChatAll("{orange}[TF2Jail]{fullred} Admin has reset plugin!");

	return Plugin_Handled;
}

public Action AdminMapCompatibilityCheck(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (sCellNames[0] != '\0')
	{
		int cell_door = FindEntity(sCellNames, "func_door");
		if (IsValidEntity(cell_door))
			CReplyToCommand(client, "{orange}[TF2Jail]{burlywood} Doors are functional.");
		else CReplyToCommand(client, "{orange}[TF2Jail]{fullred} Doors are not functional.");
	}

	if (sCellOpener[0] != '\0')
	{
		int open_cells = FindEntity(sCellOpener, "func_button");
		if (IsValidEntity(open_cells))
			CReplyToCommand(client, "{orange}[TF2Jail]{burlywood} Cell door functionality is active.");
		else CReplyToCommand(client, "{orange}[TF2Jail]{fullred} Cell door functionality is inactive.");
	}
	return Plugin_Handled;
}

public Action AdminGiveFreeday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
			return Plugin_Handled;
		}
		JailFighter targ = JailFighter(target);

		if (targ.bIsFreeday)
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target is currently a freeday.");
			return Plugin_Handled;
		}
		
		CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has given {default}%N{burlywood} a freeday.", target);
		targ.GiveFreeday();

		return Plugin_Handled;
	}

	Admin_GiveFreedaysMenu(client);
	return Plugin_Handled;
}

public void Admin_GiveFreedaysMenu(const int client)
{
	if (!client)
		return;

	if (IsVoteInProgress())
		return;

	Menu menu = new Menu(ForceFreedayMenu);
	menu.SetTitle("Select Player(s) for Freeday");

	AddClientsToMenu(menu);
	menu.ExitButton = true;
	menu.Display(client, -1);
}

public int ForceFreedayMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char player[32];
			menu.GetItem(select, player, sizeof(player));
			int target = GetClientOfUserId(StringToInt(player));

			if (!IsClientValid(target))
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
				Admin_GiveFreedaysMenu(client);
				return;
			}

			JailFighter(target).GiveFreeday();
			CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has forced {default}%N{burlywood} to receive a Freeday!", target);
		}
		case MenuAction_End:delete menu;
	}
}

public Action AdminRemoveFreeday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);
		
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
			return Plugin_Handled;
		}

		JailFighter targ = JailFighter(target);
		if (!targ.bIsFreeday)
		{
			CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Target is not a freeday.");
			return Plugin_Handled;
		}

		CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has removed freeday from {default}%N", target);
		targ.RemoveFreeday();

		return Plugin_Handled;
	}
	RemoveFreedaysMenu(client);

	return Plugin_Handled;
}

public void RemoveFreedaysMenu(int client)
{
	if (!client)
		return;

	if (IsVoteInProgress())
		return;

	Menu menu = new Menu(MenuHandle_RemoveFreedays);
	menu.SetTitle("Choose a Player");

	char strName[32], strID[8];
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
			
		if (JailFighter(i).bIsFreeday)
		{
			IntToString(GetClientUserId(i), strID, sizeof(strID));
			GetClientName(i, strName, sizeof(strName));
			menu.AddItem(strID, strName);
		}
	}
	menu.ExitButton = true;
	menu.Display(client, -1);
}

public int MenuHandle_RemoveFreedays(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char player[32];
			menu.GetItem(select, player, sizeof(player));
			JailFighter targ = JailFighter(StringToInt(player), true);
			
			if (!IsClientInGame(targ.index))
			{
				CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Client is no longer available.");
				return;
			}

			if (!targ.bIsFreeday)
			{
				CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Client is not a freeday");
				RemoveFreedaysMenu(client);
				return;
			}

			targ.RemoveFreeday();
			RemoveFreedaysMenu(client);
		}
		case MenuAction_End:delete menu;
	}
}

public Action AdminLockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warden is already locked.");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
	{
		gamemode.FindWarden().WardenUnset();
		gamemode.bWardenExists = false;
	}

	gamemode.bAdminLockWarden = true;
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has locked warden!");

	return Plugin_Handled;
}

public Action AdminUnlockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warden is not locked.");
		return Plugin_Handled;
	}

	gamemode.bAdminLockWarden = false;
	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Admin has unlocked warden.");

	return Plugin_Handled;
}

public int MenuHandle_ForceLR(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!JailFighter(client).bIsWarden)
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
				return;
			}

			char player[32];
			menu.GetItem(select, player, sizeof(player));
			int target = GetClientOfUserId(StringToInt(player));

			if (!IsClientInGame(target))
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
				return;
			}
			if (GetClientTeam(target) != RED)
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Player is not on Red Team.");
				return;
			}
			if (gamemode.bIsLRInUse)
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Last Request has already been given.");
				return;
			}

			JailFighter(target).ListLRS();
			CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden {default}%N{burlywood} has given {default}%N{burlywood} a last request.", client, target);
		}
		case MenuAction_End:delete menu;
	}
}

public void FreedayforClientsMenu(const int client)
{
	if (IsVoteInProgress() || !IsPlayerAlive(client))
		return;

	Menu menu = new Menu(MenuHandle_FreedayForClients);
	menu.SetTitle("Choose a Player for Freeday");
	
	AddClientsToMenu(menu, false);
	menu.ExitButton = true;
	menu.Display(client, -1);
}

public int MenuHandle_FreedayForClients(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char player[32];
			menu.GetItem(select, player, sizeof(player));
			static int limit;
			int target = GetClientOfUserId(StringToInt(player));

			if (!IsClientInGame(target))
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Player is no longer available.");
				FreedayforClientsMenu(client);
				return;
			}
			JailFighter targ = JailFighter(target);
			if (targ.bIsQueuedFreeday)
			{
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Freeday for {default}%N{burlywood} is currently queued.", target);
				FreedayforClientsMenu(client);
				return;
			}
			if (limit < cvarTF2Jail[FreedayLimit].IntValue)
			{
				targ.bIsQueuedFreeday = true;
				limit++;
				CPrintToChatAll("{crimson}[TF2Jail]{burlywood} {default}%N{burlywood} has chosen {default}%N{burlywood} for freeday.", client, target);
				if (limit < cvarTF2Jail[FreedayLimit].IntValue)
					FreedayforClientsMenu(client);
				else limit = 0;
			}
			else 
			{	
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You have picked the maximum amount of freedays.", client);
				limit = 0;
			}
		}
		case MenuAction_End:delete menu;
	}
}

public Action Command_WardenFF(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	if (hEngineConVars[0].BoolValue == false)
	{
		hEngineConVars[0].SetBool(true);
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden has enabled Friendly-Fire!");
	}
	else
	{
		hEngineConVars[0].SetBool(false);
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden has disabled Friendly-Fire!");
	}
	return Plugin_Handled;
}

public Action Command_WardenCC(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}

	if (hEngineConVars[1].BoolValue == false)
	{
		hEngineConVars[1].SetBool(true);
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden has enabled Collisions!");
	}
	else
	{
		hEngineConVars[1].SetBool(false);
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} Warden has disabled Collisions!");
	}
	return Plugin_Handled;
}

public Action Command_WardenMarker(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[Markers].BoolValue)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} This is not enabled.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}
	if (gamemode.bMarkerExists)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Slow down there cowboy.");
		return Plugin_Handled;
	}

	CreateMarker(client);
	return Plugin_Handled;
}

public Action Command_WardenLaser(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Command is in-game only.");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[WardenLaser].BoolValue)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} This is not enabled.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Round must be active.");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not warden.");
		return Plugin_Handled;
	}
	if (player.bLasering)
	{
		player.bLasering = false;
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You have turned Warden Lasers {default}off{burlywood}.");
	}
	else
	{
		player.bLasering = true;
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You have turned Warden Lasers {default}on{burlywood}. Hold reload to activate.");
	}

	return Plugin_Handled;
}

public Action AdminWardayRed(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Must be done before or during active round.");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetRed)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warday configuration is not set for this location!");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i) || GetClientTeam(i) != RED)
			continue;

		TeleportEntity(i, flWardayRed, NULL_VECTOR, NULL_VECTOR);
	}

	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Warday for Red team has been activated!");
	return Plugin_Handled;
}

public Action AdminWardayBlue(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Must be done before or during active round.");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetBlue)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warday configuration is not set for this location!");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i) || GetClientTeam(i) != BLU)
			continue;

		TeleportEntity(i, flWardayBlu, NULL_VECTOR, NULL_VECTOR);
	}

	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Warday for Blue team has been activated!");
	return Plugin_Handled;
}

public Action AdminFullWarday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Must be done before or during active round.");
		return Plugin_Handled;
	}

	bool allowred = gamemode.bWardayTeleportSetRed,
		 allowblu = gamemode.bWardayTeleportSetBlue;

	if (!allowred)
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warday for Red Team is not configured, ignoring...");
	else if (!allowblu)
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warday for Blue Team is not configured, ignoring...");
	else if (!allowblu && !allowred)
	{
		CReplyToCommand(client, "{crimson}[TF2Jail]{burlywood} Warday configuration is not set.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == RED && !allowred)
			continue;

		if (GetClientTeam(i) == BLU && !allowblu)
			continue;

		JailFighter(i).TeleportToPosition(GetClientTeam(i));
	}

	CPrintToChatAll("{orange}[TF2Jail]{burlywood} Warday has been activated!");

	return Plugin_Handled;
}

public Action AdminReloadCFG(int client, int args)
{
	ServerCommand("exec sourcemod/TF2JailRedux.cfg");
	CReplyToCommand(client, "{orange}[TF2Jail]{fullred} Reloading plugin CFG.");
	return Plugin_Handled;
}
#if defined _clientprefs_included
public Action Command_MusicOff(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;

	MusicPanel(client);
	return Plugin_Handled;
}

public void MusicPanel(const int client)
{
	Panel panel = new Panel();
	panel.SetTitle("Turn the TF2Jail Music...");
	panel.DrawItem("On?");
	panel.DrawItem("Off?");
	panel.Send(client, MusicTogglePanel, 9001);
	delete (panel);
}

public int MusicTogglePanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select) 
	{
		JailFighter player = JailFighter(client);
		if (select == 1) 
		{
			player.bNoMusic = false;
			CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You've turned {lightgreen}On{default} the TF2Jail Background Music.");
		}
		else
		{
			player.bNoMusic = true;
			CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You've turned {lightgreen}Off{default} the TF2Jail Background Music.\nWhen the music stops, it won't play again.");
		}
	}
}
#endif

public Action Preset(int client, int args)
{
	CReplyToCommand(client, "%i", gamemode.iLRPresetType);
}
public Action Type(int client, int args)
{
	CReplyToCommand(client, "%i", gamemode.iLRType);
}
public Action SetPreset(int client, int args)
{
	char strCmd[4]; GetCmdArg(1, strCmd, sizeof(strCmd));
	gamemode.iLRPresetType = StringToInt(strCmd);
}
public Action GameModeProp(int client, int args)
{
	char arg[64]; GetCmdArg(1, arg, 64);
	any val = JBGameMode_GetProperty(arg);
	CReplyToCommand(client, "%s value: %i", arg, val);
}
public Action BaseProp(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	JBPlayer player;
	char arg1[64]; GetCmdArg(1, arg1, 64);
	any val;
	if (args == 1)
	{
		player = JBPlayer(client);
		val = player.GetValue(arg1);
		CReplyToCommand(client, "%s value: %i", arg1, val);
		return Plugin_Handled;
	}
	char arg2[64]; GetCmdArg(2, arg2, 64);
	player = JBPlayer(FindTarget(client, arg1));
	val = player.GetValue(arg2);
	CReplyToCommand(client, "%N's %s value: %i", player.index, arg2, val);
	return Plugin_Handled;
}
public Action PluginLength(int client, int args)
{
	CReplyToCommand(client, "%d", hPlugins.Length);
}
public Action arrLRSLength(int client, int args)
{
	CReplyToCommand(client, "%d", arrLRS.Length);
}