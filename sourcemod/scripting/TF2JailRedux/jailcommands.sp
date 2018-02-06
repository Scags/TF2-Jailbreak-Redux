public Action Command_Help(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;
	
	Panel panel = new Panel();
	panel.SetTitle("Welcome to TF2Jail Redux!");
	panel.DrawItem("Who's the current warden?");
	panel.DrawItem("What are the last requests?");
	panel.DrawItem("Turn off the background music? (Doesn't exist yet so lol)");
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
					{
						int iWarden = FindWarden();
						CPrintToChat(client, "{red}[JailRedux]{red} %N{tan} is the current warden.", iWarden);
					}
					else CPrintToChat(client, "{red}[JailRedux]{tan} There is no current warden.");
				}
				case 1:ListLastRequestPanel(client);
				case 2:MusicPanel(client);
			}
		}
	}
}

public Action Command_BecomeWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	JailFighter cli = JailFighter(client);
	if (cli.bLockedFromWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You may not become warden until next round.");
		return Plugin_Handled;
	}
	if (!client)
	{
		CReplyToCommand(client, "[JailRedux] Command is in-game only");
		return Plugin_Handled;
	}

	if (gamemode.bAdminLockWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Admin has locked warden.");
		return Plugin_Handled;
	}

	if (gamemode.b1stRoundFreeday || gamemode.bIsWardenLocked)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Warden is locked.");
		return Plugin_Handled;
	}
	
	int iWarden = FindWarden();

	if (gamemode.bWardenExists)
	{
		CPrintToChat(client, "{red}[JailRedux]{red} %N{tan} is the current warden.", iWarden);
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You must be alive");
		return Plugin_Handled;
	}

	if (TF2_GetClientTeam(client) != TFTeam_Blue)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not on Blue Team.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	player.WardenSet();
	WardenMenu(player.index);
	ManageWarden(player);
	gamemode.bWardenExists = true;
	return Plugin_Handled;
}

public Action Command_ExitWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(player.index, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	CPrintToChatAll("{red}[JailRedux] {tan}Warden %N has retired!", player.index);
	PrintCenterTextAll("Warden has retired");
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
		CReplyToCommand(client, "[JailRedux] Command is in-game only.");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(player.index, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	WardenMenu(player.index);

	return Plugin_Handled;
}

public Action Command_OpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Map is incompatible.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN);

	return Plugin_Handled;
}

public Action Command_CloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "[JailRedux] Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Map is incompatible.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE);

	return Plugin_Handled;
}

public Action Command_EnableFriendlyFire(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	switch (GetConVarBool(hEngineConVars[0]))
	{
		case true:
		{
			SetConVarBool(hEngineConVars[0], false);
			CPrintToChatAll("{red}[JailRedux]{tan} Warden {default}%N{tan} has disabled Friendly-Fire.", client);
		}
		case false:
		{
			SetConVarBool(hEngineConVars[0], true);
			CPrintToChatAll("{red}[JailRedux]{tan} Warden {default}%N{tan} has enabled Friendly-Fire.", client);
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
		CReplyToCommand(client, "[JailRedux] Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	switch (GetConVarBool(hEngineConVars[1]))
	{
		case true:
		{
			SetConVarBool(hEngineConVars[1], false);
			CPrintToChatAll("{red}[JailRedux]{tan} Warden {default}%N{tan} has disabled collisions.", client);
		}
		case false:
		{
			SetConVarBool(hEngineConVars[1], true);
			CPrintToChatAll("{red}[JailRedux]{tan} Warden {default} %N{tan} has enabled collisions.", client);
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
		CReplyToCommand(client, "{red}[JailRedux]{tan} Command is in-game only.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	if (gamemode.bAdminLockedLR)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Admin has locked LR.");
		return Plugin_Handled;
	}

	if (args >= 2)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Usage: sm_givelr or sm_givelr <playername>");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	if (gamemode.bIsLRInUse)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Last Request has already been given.");
		return Plugin_Handled;
	}

	if (!args)
	{
		if (IsVoteInProgress())
			return Plugin_Handled;

		Menu menu = new Menu(MenuHandle_ForceLR);
		menu.SetTitle("Choose a Player");
		AddClientsToMenu(menu);
		menu.ExitButton = true;
		menu.Display(client, 30);
	}

	if (args == 1)
	{
		char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
		int iTarg = FindTarget(client, targetname);
		if (!IsClientValid(iTarg))
			return Plugin_Handled;
		if (!IsPlayerAlive(iTarg))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target is not alive!");
			return Plugin_Handled;
		}
		if (GetClientTeam(iTarg) != RED)
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target is not on Red Team!");
			return Plugin_Handled;
		}
		JailFighter(iTarg).ListLRS();
	}

	return Plugin_Handled;
}

void AddClientsToMenu(Menu & menu, bool alive = false, int team = RED)
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
		Format(strName, sizeof(strName), "%N", i);
		menu.AddItem(strID, strName);
	}
}

public Action Command_RemoveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	if (gamemode.iLRPresetType < 0)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} There is no last request set for next round.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i))
			JailFighter(i).bIsQueuedFreeday = false;
	}

	arrLRS[gamemode.iLRPresetType]--;
	gamemode.bIsLRInUse = false;
	gamemode.iLRPresetType = -1;
	CPrintToChatAll("{red}[JailRedux]{tan}Warden {default}%N{tan} has denied the Last Request!", client);

	return Plugin_Handled;
}

public Action Command_ListLastRequests(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Command is in-game only");
		return Plugin_Handled;
	}

	ListLastRequestPanel(client);
	return Plugin_Handled;
}

public void ListLastRequestPanel(const int client)
{
	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Last Request List");
	AddLRToPanel(panel);
	panel.Send(client, ListLRsPanel, 9001);
	delete panel;
	/*Menu menu = new Menu(ListLRsPanel);
	menu.SetTitle("Last Request List");
	//menu.AddItem("0", "Random LR");
	AddLRToMenu(menu);
	menu.ExitButton = true;
	menu.Display(client, 30);*/
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
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	int iWarden = FindWarden();
	if (gamemode.bWardenExists)
		CReplyToCommand(client, "{red}[JailRedux]{red} %N {tan}is the current warden.", iWarden);
	else CReplyToCommand(client, "{red}[JailRedux]{tan} There is no current warden.");

	return Plugin_Handled;
}

public Action AdminRemoveWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bWardenExists)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} No warden currently.");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	PrintCenterTextAll("Warden has been fired!");
	
	FireWarden(false);
	
	return Plugin_Handled;
}

void FireWarden(bool prevent = true)
{
	JailFighter player = JailFighter(FindWarden());
	player.WardenUnset();
	gamemode.bWardenExists = false;
	if (gamemode.iRoundState == StateRunning)
	{
		if (cvarTF2Jail[WardenTimer].IntValue != 0)
			SetPawnTimer(DisableWarden, cvarTF2Jail[WardenTimer].FloatValue, gamemode.iRoundCount);
	}
	if (prevent)
		player.bLockedFromWarden = true;
	CPrintToChatAll("{orange}[JailRedux]{tan} Warden has been fired!");
}

public Action AdminDenyLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iLRPresetType < 0)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} There is no last request set for next round.");
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
			CPrintToChat(player.index, "{orange}[JailRedux]{tan} An Admin has removed your queued freeday!");
			player.bIsQueuedFreeday = false;
		}

		if (player.bIsFreeday)
		{
			CPrintToChat(player.index, "{orange}[JailRedux]{tan} An Admin has removed your freeday!");
			player.bIsFreeday = false;
		}

		if (hTextNodes[1] != null)
			ClearSyncHud(i, hTextNodes[1]);
	}

	arrLRS[gamemode.iLRPresetType]--;
	gamemode.bIsLRInUse = false;
	gamemode.iLRPresetType = -1;

	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has denied the current last request!");

	return Plugin_Handled;
}

public Action AdminOpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Map is not compatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN);
	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has opened cells.");

	return Plugin_Handled;
}

public Action AdminCloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE);
	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has closed cells.");

	return Plugin_Handled;
}

public Action AdminLockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(LOCK);
	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has locked cells.");

	return Plugin_Handled;
}

public Action AdminUnlockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Map is incompatible.");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(UNLOCK);
	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has unlocked cells.");

	return Plugin_Handled;
}

public Action AdminForceWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.bWardenExists)
	{
		int iWarden = FindWarden();
		CReplyToCommand(client, "{red}[JailRedux] {fullred}%N {tan} is the current warden.", iWarden);
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}

	if (args > 0)
	{
		char sArg[64];
		GetCmdArgString(sArg, sizeof(sArg));

		int target = FindTarget(client, sArg, true);
		JailFighter targ = JailFighter(target);
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Player is no longer available.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(target))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target must be alive.");
			return Plugin_Handled;
		}

		targ.WardenSet();
		ManageWarden(targ);
		CPrintToChatAll("{orange}[JailRedux]{tan} Admin has forced %N as warden.", targ.index);
		gamemode.bWardenExists = true;
		
		return Plugin_Handled;
	}

	gamemode.FindRandomWarden();
	return Plugin_Handled;
}

public Action AdminForceLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);

	if (args > 0)
	{
		char sArg[64];
		GetCmdArgString(sArg, sizeof(sArg));

		int target = FindTarget(client, sArg, true);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Player is no longer available.");
			return Plugin_Handled;
		}
		if (GetClientMenu(target) != MenuSource_None)
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target already has a menu open.");
			return Plugin_Handled;
		}
		CPrintToChatAll("{orange}[JailRedux]{tan} Admin has forced %N to receive a Last Request.", target);
		JailFighter(target).ListLRS();

		return Plugin_Handled;
	}

	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has forced a Last Request for themselves.");
	player.ListLRS();

	return Plugin_Handled;
}

public Action AdminResetPlugin(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	JailFighter player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		
		player = JailFighter(i);
		player.iCustom = 0;
		player.iKillCount = 0;
		player.bIsWarden = false;
		player.bIsMuted = false;
		player.bIsQueuedFreeday = false;
		player.bIsFreeday = false;
		player.bLockedFromWarden = false;
		player.bIsVIP = false;
		player.bIsAdmin = false;
		player.bIsHHH = false;
		player.bInJump = false;
		player.bUnableToTeleport = false;
		player.flSpeed = 0.0;
		player.flKillSpree = 0.0;
	}

	gamemode.iRoundState = 0;
	gamemode.iTimeLeft = 0;
	gamemode.iRoundCount = 0;
	gamemode.iLRPresetType = -1;
	gamemode.iLRType = -1;
	gamemode.iFreedayLimit = 0;
	gamemode.bFreedayTeleportSet = false;
	gamemode.bIsFreedayRound = false;
	gamemode.bDisableCriticals = false;
	gamemode.bWardenExists = false;
	gamemode.bFirstDoorOpening = false;
	gamemode.bAdminLockedLR = false;
	gamemode.bAdminLockWarden = false;
	gamemode.bIsWarday = false;
	gamemode.bOneGuardLeft = false;
	gamemode.bIsLRInUse = false;
	gamemode.b1stRoundFreeday = false;
	gamemode.bCellsOpened = false;
	gamemode.bIsMapCompatible = false;

	ParseConfigs();
	//BuildMenus();
	CPrintToChatAll("{orange}[JailRedux]{fullred} Admin has reset plugin!");

	return Plugin_Handled;
}

public Action AdminMapCompatibilityCheck(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (strlen(sCellNames) != 0)
	{
		int cell_door = FindEntity(sCellNames, "func_door");
		if (IsValidEntity(cell_door))
			CReplyToCommand(client, "{orange}[JailRedux]{tan} Doors are functional.");
		else CReplyToCommand(client, "{orange}[JailRedux]{fullred} Doors are not functional.");
	}

	if (strlen(sCellOpener) != 0)
	{
		int open_cells = FindEntity(sCellOpener, "func_button");
		if (IsValidEntity(open_cells))
			CReplyToCommand(client, "{orange}[JailRedux]{tan} Cell door functionality is active.");
		else CReplyToCommand(client, "{orange}[JailRedux]{fullred} Cell door functionality is inactive.");
	}
	return Plugin_Handled;
}

public Action AdminGiveFreeday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (args > 0)
	{
		char sArg[64];
		GetCmdArgString(sArg, sizeof(sArg));

		int target = FindTarget(client, sArg, true);
		JailFighter targ = JailFighter(target);
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Player is no longer available.");
			return Plugin_Handled;
		}

		if (targ.bIsFreeday)
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target is currently a freeday.");
			return Plugin_Handled;
		}
		
		CPrintToChatAll("{orange}[JailRedux]{tan} Admin has given %N a freeday.", targ.index);

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

	AddClientsToMenu(menu, false);
	menu.ExitButton = true;
	menu.Display(client, 30);
}

public int ForceFreedayMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char strCli[32];
			menu.GetItem(select, strCli, sizeof(strCli));
			JailFighter targ = JailFighter( StringToInt(strCli), true );

			if (!IsClientValid(targ.index))
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is no longer available.");
				GiveFreedaysMenu(client);
				return;
			}
			targ.GiveFreeday();
			CPrintToChatAll("{orange}[JailRedux] Admin has forced %N to receive a Freeday!", targ.index);
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
		char sArg[64];
		GetCmdArgString(sArg, sizeof(sArg));

		int target = FindTarget(client, sArg, true);
		JailFighter targ = JailFighter(target);
		
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Player is no longer available.");
			return Plugin_Handled;
		}

		if (!targ.bIsFreeday)
		{
			CReplyToCommand(client, "{red}[JailRedux]{tan} Target is not a freeday.");
			return Plugin_Handled;
		}

		CPrintToChatAll("{orange}[JailRedux]{tan} Admin has removed freeday from %N", target);
		targ.RemoveFreeday();

		return Plugin_Handled;
	}
	RemoveFreedaysMenu(client);

	return Plugin_Handled;
}

public Action AdminLockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Warden is already locked");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
	{
		JailFighter( FindWarden() ).WardenUnset();
		gamemode.bWardenExists = false;
	}

	gamemode.bAdminLockWarden = true;

	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has locked warden!");

	return Plugin_Handled;
}

public Action AdminUnlockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, "{red}[JailRedux]{tan} Warden is not locked");
		return Plugin_Handled;
	}

	gamemode.bAdminLockWarden = false;
	CPrintToChatAll("{orange}[JailRedux]{tan} Admin has unlocked warden.");

	return Plugin_Handled;
}

public void GiveFreedaysMenu(const int client)
{
	if (!IsPlayerAlive(client))
		return;

	if (IsVoteInProgress())
		return;

	Menu menu = new Menu(FreedayMenu);
	menu.SetTitle("Select Player(s) for Freeday");

	AddClientsToMenu(menu, false);
	menu.ExitButton = true;
	menu.Display(client, 30);
}

public int FreedayMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsPlayerAlive(client))
				return;

			char strCli[32];
			menu.GetItem(select, strCli, sizeof(strCli));
			JailFighter targ = JailFighter( StringToInt(strCli), true );

			if (!IsClientInGame(targ.index))
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is no longer available.");
				GiveFreedaysMenu(client);
				return;
			}
			if (targ.bIsQueuedFreeday)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is already queued for Freeday.");
				GiveFreedaysMenu(client);
				return;
			}
			int limit = cvarTF2Jail[FreedayLimit].IntValue;
			if (gamemode.iFreedayLimit < limit)
			{
				targ.bIsQueuedFreeday = true;
				CPrintToChat(client, "{red}[JailRedux]{tan} Selected {red}%N{tan}.", targ.index);
				gamemode.iFreedayLimit++;
				if (gamemode.iFreedayLimit < limit)
					GiveFreedaysMenu(client);
				return;
			}
			else
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Maximum amount of freedays have been picked.");
				return;
			}
		}
		case MenuAction_End:delete menu;
	}
}

public void RemoveFreedaysMenu(int client)
{
	if (!client)
		return;

	if (IsVoteInProgress())return;

	Menu menu = new Menu(MenuHandle_RemoveFreedays);
	menu.SetTitle("Choose a Player");

	char strName[32], strID[8];
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && TF2_GetClientTeam(i) == TFTeam_Red && JailFighter(i).bIsFreeday)
		{
			IntToString(GetClientUserId(i), strID, sizeof(strID));
			Format(strName, sizeof(strName), "%N", i);
			menu.AddItem(strID, strName);
		}
	}
	menu.ExitButton = true;
	menu.Display(client, 30);
}

public int MenuHandle_RemoveFreedays(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char strCli[32];
			menu.GetItem(select, strCli, sizeof(strCli));
			JailFighter targ = JailFighter( StringToInt(strCli), true );
			
			if (!IsClientInGame(targ.index))
			{
				CReplyToCommand(client, "{red}[JailRedux]{tan} Client is no longer available.");
				return;
			}

			if (!targ.bIsFreeday)
			{
				CReplyToCommand(client, "{red}[JailRedux]{tan} Client is not a freeday");
				RemoveFreedaysMenu(client);
				return;
			}

			targ.RemoveFreeday();

			RemoveFreedaysMenu(client);
		}
		case MenuAction_End:delete menu;
	}
}

public void WardenMenu(const int client)
{
	if (IsVoteInProgress())
		return;

	Menu menu = new Menu(MenuHandle_WardenMenu);
	menu.SetTitle("Warden Commands");
	menu.AddItem("0", "Open Cells");
	menu.AddItem("1", "Close Cells");
	menu.AddItem("2", "Enable/Disable FF");
	menu.AddItem("3", "Enable/Disable Collisions");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandle_WardenMenu(Menu menu, MenuAction action, int client, int select)
{
	JailFighter param = JailFighter(client);
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!param.bIsWarden)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
				return;
			}
			switch (select)
			{
				case 0:
				{
					if (!gamemode.bCellsOpened)
					{
						gamemode.DoorHandler(OPEN);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has opened cells.");
						gamemode.bCellsOpened = true;
					}
					else CPrintToChat(client, "{red}[JailRedux]{tan} Cells are already open.");
					WardenMenu(client);
				}
				case 1:
				{
					if (gamemode.bCellsOpened)
					{
						gamemode.DoorHandler(CLOSE);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has closed cells.");
						gamemode.bCellsOpened = false;
					}
					else CPrintToChat(client, "{red}[JailRedux]{tan} Cells are not open.");
					WardenMenu(client);
				}
				case 2:
				{
					if (GetConVarBool(hEngineConVars[0]) == false)
					{
						SetConVarBool(hEngineConVars[0], true);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has enabled Friendly-Fire!");
					}
					else 
					{
						SetConVarBool(hEngineConVars[0], false);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has disabled Friendly-Fire.");
					}
					WardenMenu(client);
				}
				case 3:
				{
					if (GetConVarBool(hEngineConVars[1]) == false)
					{
						SetConVarBool(hEngineConVars[1], true);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has enabled collisions!");
					}
					else
					{
						SetConVarBool(hEngineConVars[1], false);
						CPrintToChatAll("{red}[JailRedux]{tan} Warden has disabled collisions.");
					}
					WardenMenu(client);
				}
			}
		}
		case MenuAction_End:delete menu;
	}
}

public int MenuHandle_ForceLR(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			JailFighter param = JailFighter(client);

			char strCli[32];
			menu.GetItem(select, strCli, sizeof(strCli));
			JailFighter targ = JailFighter( StringToInt(strCli), true );

			if (!param.bIsWarden)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
				return;
			}
			if (!IsClientInGame(targ.index))
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is no longer available.");
				return;
			}

			if (gamemode.bIsLRInUse)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Last Request has already been given.");
				return;
			}

			if (TF2_GetClientTeam(targ.index) != TFTeam_Red)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is not on Red Team.");
				return;
			}
			targ.ListLRS();

			CPrintToChatAll("{red}[JailRedux]{tan} Warden {red}%N{tan} has given %N a last request.", param.index, targ.index);
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
	menu.Display(client, 30);
}

public int MenuHandle_FreedayForClients(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char strCli[32];
			menu.GetItem(select, strCli, sizeof(strCli));
			JailFighter targ = JailFighter( StringToInt(strCli), true );

			if (!IsClientInGame(targ.index))
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Player is no longer available");
				FreedayforClientsMenu(client);
				return;
			}
			if (targ.bIsQueuedFreeday)
			{
				CPrintToChat(client, "{red}[JailRedux]{tan} Freeday for %N is currently queued", targ.index);
				FreedayforClientsMenu(client);
				return;
			}
			if (gamemode.iFreedayLimit < cvarTF2Jail[FreedayLimit].IntValue)
			{
				targ.bIsQueuedFreeday = true;
				gamemode.iFreedayLimit++;
				CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen %N for freeday", client, targ.index);
				FreedayforClientsMenu(client);
				return;
			}
			else 
			{	
				CPrintToChat(client, "{red}[JailRedux]{tan} %N has picked the maximum amount of freedays", client);
				return;
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
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	if (GetConVarBool(hEngineConVars[0]) == false)
	{
		SetConVarBool(hEngineConVars[0], true);
		CPrintToChatAll("{red}[JailRedux]{tan} Warden has enabled Friendly-Fire!");
	}
	else
	{
		SetConVarBool(hEngineConVars[0], false);
		CPrintToChatAll("{red}[JailRedux]{tan} Warden has disabled Friendly-Fire!");
	}
	return Plugin_Handled;
}

public Action Command_WardenCC(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Round must be active.");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You are not warden.");
		return Plugin_Handled;
	}

	if (GetConVarBool(hEngineConVars[1]) == false)
	{
		SetConVarBool(hEngineConVars[1], true);
		CPrintToChatAll("{red}[JailRedux]{tan} Warden has enabled Collisions!");
	}
	else
	{
		SetConVarBool(hEngineConVars[1], false);
		CPrintToChatAll("{red}[JailRedux]{tan} Warden has disabled Collisions!");
	}
	return Plugin_Handled;
}

public Action AdminWardayRed(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Must be done before or during active round.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || TF2_GetClientTeam(i) != TFTeam_Red)
			continue;

		TeleportEntity(i, flWardayRed, nullvec, nullvec);
		CPrintToChat(i, "{orange}[JailRedux]{tan} Warday has been activated!");
	}
	return Plugin_Handled;
}

public Action AdminWardayBlue(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Must be done before or during active round.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || TF2_GetClientTeam(i) != TFTeam_Blue)
			continue;

		TeleportEntity(i, flWardayBlu, nullvec, nullvec);
		CPrintToChat(i, "{orange}[JailRedux]{tan} Warday has been activated!");
	}
	return Plugin_Handled;
}

public Action FullWarday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} Must be done before or during active round.");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		JailFighter(i).TeleportToPosition(GetClientTeam(i));
	}

	CPrintToChatAll("{orange}[JailRedux]{tan} Warday has been activated!");

	return Plugin_Handled;
}

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
			CPrintToChat(client, "{red}[JailRedux]{tan} You've turned {lightgreen}On{default} the TF2Jail Background Music.");
		}
		else
		{
			player.bNoMusic = true;
			CPrintToChat(client, "{red}[JailRedux]{tan} You've turned {lightgreen}Off{default} the TF2Jail Background Music.\nWhen the music stops, it won't play again.");
		}
	}
}

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