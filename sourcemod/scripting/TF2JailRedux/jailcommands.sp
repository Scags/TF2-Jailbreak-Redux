public Action Command_Help(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;
	
	Panel panel = new Panel();
	// TODO; make this better... don't know how just do it
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Welcome");
	panel.SetTitle(buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Who's Warden");
	panel.DrawItem(buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel What are LR's");
	panel.DrawItem(buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Turn Off Music");
	panel.DrawItem(buffer);

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
				case 1:
					if (gamemode.bWardenExists)
						CPrintToChat(client, "%t %t", "Plugin Tag", "Current Warden", gamemode.iWarden.index);
					else CPrintToChat(client, "%t %t", "Plugin Tag", "No Current Warden");
				case 2:ListLastRequestPanel(client);
				case 3:MusicPanel(client);
			}
		}
	}
}

public Action Command_BecomeWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (player.bIsWarden)
	{
		player.WardenMenu();
		return Plugin_Handled;
	}

	if (gamemode.bWardenExists)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Current Warden", gamemode.iWarden.index);
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Need Alive");
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != BLU)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Need Blue Team");
		return Plugin_Handled;
	}

	if (gamemode.b1stRoundFreeday || gamemode.bIsWardenLocked)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Warden Locked");
		return Plugin_Handled;
	}
	
	if (player.bLockedFromWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Locked From Warden");
		return Plugin_Handled;
	}

	player.WardenSet();
	return Plugin_Handled;
}

public Action Command_ExitWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	CPrintToChatAll("%t %t", "Plugin Tag", "Warden Retired Chat", client);
	PrintCenterTextAll("%t", "Warden Retired Center");

	player.bLockedFromWarden = true;
	player.WardenUnset();
	
	return Plugin_Handled;
}

public Action Command_WardenMenu(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
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
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (gamemode.bCellsOpened)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Cells Already Open");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(OPEN, true))
	{
		char method[32];
		FormatEx(method, sizeof(method), "%t", "Opened");
		CPrintToChatAll("%t %t", "Plugin Tag", "Warden Work Cells", client, method);
	}
	// Only happens if cells are in limbo aka partially opened/closed
//	else CReplyToCommand(client, "%t %t", "Plugin Tag", "Cells Already Open");

	return Plugin_Handled;
}

public Action Command_CloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (!gamemode.bCellsOpened)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Cells Not Open");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(CLOSE, true))
	{
		char method[32];
		FormatEx(method, sizeof(method), "%t", "Closed");
		CPrintToChatAll("%t %t", "Plugin Tag", "Warden Work Cells", client, method);
	}

	return Plugin_Handled;
}

public Action Command_EnableFriendlyFire(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[0].BoolValue)
	{
		hEngineConVars[0].SetBool(true);
		CPrintToChatAll("%t %t", "Plugin Tag", "FF On Warden", client);
	}
	else 
	{
		hEngineConVars[0].SetBool(false);
		CPrintToChatAll("%t %t", "Plugin Tag", "FF Off Warden", client);
	}

	return Plugin_Handled;
}

public Action Command_EnableCollisions(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[1].BoolValue)
	{
		hEngineConVars[1].SetBool(true);
		CPrintToChatAll("%t %t", "Plugin Tag", "Collisions On Warden");
	}
	else
	{
		hEngineConVars[1].SetBool(false);
		CPrintToChatAll("%t %t", "Plugin Tag", "Collisions Off Warden");
	}

	return Plugin_Handled;
}

public Action Command_GiveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bAdminLockedLR)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Admin Locked LR");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	if (gamemode.bIsLRInUse)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "LR Given");
		return Plugin_Handled;
	}

	if (!args && client)
	{
		if (IsVoteInProgress())
			return Plugin_Handled;

		Menu menu = new Menu(MenuHandle_GiveLR);
		char buffer[16]; FormatEx(buffer, sizeof(buffer), "%t", "Choose Player");
		menu.SetTitle(buffer);
		AddClientsToMenu(menu, true);
		menu.ExitButton = true;
		menu.Display(client, 0);

		return Plugin_Handled;
	}

	char targetname[32]; GetCmdArgString(targetname, sizeof(targetname));
	char clientName[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;

	int target_count = ProcessTargetString(targetname, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

	if (target_count != 1)
		ReplyToTargetError(client, target_count);

	if (GetClientTeam(target_list[0]) != RED)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Target Not On Red");
		return Plugin_Handled;
	}
	JailFighter(target_list[0]).ListLRS();

	return Plugin_Handled;
}

public Action Command_RemoveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[DenyLR].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Denying LR Disabled");
		return Plugin_Handled;
	}

	if (gamemode.iLRPresetType == -1)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "No LR Next Round");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			JailFighter(i).bIsQueuedFreeday = false;

	gamemode.hLRCount.Set(gamemode.iLRPresetType, gamemode.hLRCount.Get(gamemode.iLRPresetType)-1);
	gamemode.bIsLRInUse = false;
	CPrintToChatAll("%t %t", "Plugin Tag", "Warden Deny LR", client);

	Call_OnLRDenied(LastRequest.At(gamemode.iLRPresetType));
	gamemode.iLRPresetType = -1;

	return Plugin_Handled;
}

public Action Command_ListLastRequests(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
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
	panel.SetTitle("%t", "Last Request List");
	AddLRToPanel(panel);
	panel.ExitButton = true;
	panel.Display(client, 0);
}

public int ListLRsPanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_End)
		delete menu;
}

public Action Command_CurrentWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Current Warden", gamemode.iWarden.index);
	else CReplyToCommand(client, "%t %t", "Plugin Tag", "No Current Warden");

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
	char s[32];

	FormatEx(s, sizeof(s), "%t", "Music Panel");
	panel.SetTitle(s);
	FormatEx(s, sizeof(s), "%t", "On");
	panel.DrawItem(s);
	FormatEx(s, sizeof(s), "%t", "Off");
	panel.DrawItem(s);
	FormatEx(s, sizeof(s), "%t", "Exit");
	panel.DrawItem(s);
	panel.Send(client, MusicTogglePanel, 9001);
	delete panel;
}

public int MusicTogglePanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select) 
	{
		JailFighter player = JailFighter(client);
		if (select == 1) 
		{
			player.bNoMusic = false;
			CPrintToChat(client, "%t %t", "Plugin Tag", "Music On");
		}
		else if (select == 2)
		{
			player.bNoMusic = true;
			CPrintToChat(client, "%t %t", "Plugin Tag", "Music Off");
		}
	}
}

public Action AdminRemoveWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!gamemode.bWardenExists)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "No Current Warden");
		return Plugin_Handled;
	}

	char tag[64];
	FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Remove Warden", gamemode.iWarden.index);
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Remove Warden", gamemode.iWarden.index);
	gamemode.FireWarden(false);
	
	return Plugin_Handled;
}

public Action AdminDenyLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iLRPresetType == -1)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "No LR Next Round");
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
			CPrintToChat(i, "%t %t", "Admin Tag", "Admin Remove Queued Freeday");
			player.bIsQueuedFreeday = false;
		}

		if (player.bIsFreeday)
		{
			CPrintToChat(i, "%t %t", "Admin Tag", "Admin Remove Freeday");
			player.RemoveFreeday();
		}
	}

	Call_OnLRDenied(LastRequest.At(gamemode.iLRPresetType));

	int type = gamemode.iLRPresetType;
	gamemode.hLRCount.Set(type, gamemode.hLRCount.Get(type)-1);
	gamemode.iLRPresetType = -1;
	gamemode.bIsLRInUse = false;

	char tag[64];
	FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Denied LR");
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Denied LR");
//	CPrintToChatAll("%t %t", "Admin Tag", "Admin Denied LR");

	return Plugin_Handled;
}

public Action AdminOpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(OPEN, true, false))
	{
		char tag[64];
		char method[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		FormatEx(method, sizeof(method), "%t", "Opened");
		CShowActivityEx(client, tag, "%t", "Admin Work Cells", method);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Work Cells", method);
	}

	return Plugin_Handled;
}

public Action AdminCloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(CLOSE, true, false))
	{
		char tag[64];
		char method[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		FormatEx(method, sizeof(method), "%t", "Closed");
		CShowActivityEx(client, tag, "%t", "Admin Work Cells", method);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Work Cells", method);
	}

	return Plugin_Handled;
}

public Action AdminLockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(LOCK, true, false))
	{
		char tag[64];
		char method[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		FormatEx(method, sizeof(method), "%t", "Locked");
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Work Cells", method);
	}

	return Plugin_Handled;
}

public Action AdminUnlockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Map Incompatible");
		return Plugin_Handled;
	}

	if (gamemode.DoorHandler(UNLOCK, true, false))
	{
		char tag[64];
		char method[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		FormatEx(method, sizeof(method), "%t", "Unlocked");
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Work Cells", method);
	}

	return Plugin_Handled;
}

public Action AdminForceWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));
		char clientName[32];
		int target_list[MAXPLAYERS];
		bool tn_is_ml;

		int target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

		if (target_count != 1)
			ReplyToTargetError(client, target_count);

		if (GetClientTeam(target_list[0]) != BLU)
		{
			CReplyToCommand(client, "%t %t", "Plugin Tag", "Target Need Blue Team");
			return Plugin_Handled;
		}

		gamemode.iWarden.WardenUnset();

		JailFighter(target_list[0]).WardenSet();
		char tag[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		CShowActivityEx(client, tag, "%t", "Admin Force Warden", target_list[0]);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Force Warden", target_list[0]);
//		CPrintToChatAll("%t %t", "Admin Tag", "Admin Force Warden", target_list[0]);

		return Plugin_Handled;
	}

	gamemode.iWarden.WardenUnset();
	gamemode.FindRandomWarden();

	char tag[32];
	FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Force Random Warden");
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Force Random Warden");

	return Plugin_Handled;
}

public Action AdminForceLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

//	if (gamemode.iRoundState != StateRunning)
//	{
//		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
//		return Plugin_Handled;
//	}

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));
		char clientName[32];
		int target_list[MAXPLAYERS];
		bool tn_is_ml;

		int target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

		if (target_count != 1)
			ReplyToTargetError(client, target_count);

		char tag[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		CShowActivityEx(client, tag, "%t", "Admin Force LR", target_list[0]);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Force LR", target_list[0]);
//		CPrintToChatAll("%t %t", "Admin Tag", "Admin Force LR", target_list[0]);
		JailFighter(target_list[0]).ListLRS();

		return Plugin_Handled;
	}

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!IsPlayerAlive(client))
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Need Alive");
		return Plugin_Handled;
	}

	char tag[32];
	FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Force LR Self");
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Force LR Self");
//	CPrintToChatAll("%t %t", "Admin Tag", "Admin Force LR Self");
	JailFighter(client).ListLRS();

	return Plugin_Handled;
}

public Action AdminResetPlugin(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			ResetVariables(JailFighter(i), false);

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
	gamemode.bIsWardenLocked = false;
	gamemode.bIsWarday = false;
	gamemode.bOneGuardLeft = false;
	gamemode.bOnePrisonerLeft = false;
	gamemode.bIsLRInUse = false;
	gamemode.b1stRoundFreeday = false;
	gamemode.bCellsOpened = false;
	gamemode.bIsMapCompatible = false;

	ParseConfigs();
	BuildMenu();
	CPrintToChatAll("%t %t", "Admin Tag", "Admin Reset Plugin");

	return Plugin_Handled;
}

public Action AdminMapCompatibilityCheck(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (strCellNames[0] != '\0')
		CReplyToCommand(client, "%t %t", "Admin Tag", IsValidEntity(FindEntity(strCellNames, "func_door")) ? "Doors Work" : "Doors Don't Work");

	if (strCellOpener[0] != '\0')
		CReplyToCommand(client, "%t %t", "Admin Tag", IsValidEntity(FindEntity(strCellNames, "func_button")) ? "Buttons Work" : "Buttons Don't Work");

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
		char clientName[32];
		int target_list[MAXPLAYERS];
		bool tn_is_ml;

		int target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

		if (target_count != 1)
			ReplyToTargetError(client, target_count);

		JailFighter targ = JailFighter(target_list[0]);

		if (targ.bIsFreeday)
		{
			CReplyToCommand(client, "%t %t", "Plugin Tag", "Target Is Freeday");
			return Plugin_Handled;
		}

		char tag[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		CShowActivityEx(client, tag, "%t", "Admin Give Freeday", target_list[0]);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Give Freeday", target_list[0]);
//		CPrintToChatAll("%t %t", "Admin Tag", "Admin Give Freeday", target_list[0]);
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
	menu.SetTitle("%t", "Select For Freeday");

	AddClientsToMenu(menu);
	menu.ExitButton = true;
	menu.Display(client, 0);
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
				CPrintToChat(client, "%t %t", "Plugin Tag", "Player no longer available");
				Admin_GiveFreedaysMenu(client);
				return;
			}

			JailFighter(target).GiveFreeday();
			char tag[32];
			FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
			CShowActivityEx(client, tag, "%t", "Admin Give Freeday", target);
			LogMessage("\"%L\" triggered \"%t\"", client, "Admin Give Freeday", target);
//			CPrintToChatAll("%t %t", "Admin Tag", "Admin Give Freeday", target);
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

		char clientName[32];
		int target_list[MAXPLAYERS];
		bool tn_is_ml;

		int target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

		if (target_count != 1)
			ReplyToTargetError(client, target_count);

		JailFighter targ = JailFighter(target_list[0]);
		if (!targ.bIsFreeday)
		{
			CReplyToCommand(client, "%t %t", "Plugin Tag", "Player Not Freeday");
			return Plugin_Handled;
		}

		char tag[32];
		FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
		CShowActivityEx(client, tag, "%t", "Admin Remove Freeday", target_list[0]);
		LogMessage("\"%L\" triggered \"%t\"", client, "Admin Remove Freeday", target_list[0]);
//		CPrintToChatAll("%t %t", "Admin Tag", "Admin Remove Freeday", target_list[0]);
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
	menu.SetTitle("%t", "Choose Player");

	char name[32], strID[8];
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (JailFighter(i).bIsFreeday)
		{
			IntToString(GetClientUserId(i), strID, sizeof(strID));
			GetClientName(i, name, sizeof(name));
			menu.AddItem(strID, name);
		}
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public int MenuHandle_RemoveFreedays(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char player[32];
			menu.GetItem(select, player, sizeof(player));
			JailFighter targ = JailFighter.OfUserId(StringToInt(player));

			if (!IsClientInGame(targ.index))
			{
				CReplyToCommand(client, "%t %t", "Plugin Tag", "Player no longer available");
				return;
			}

			if (!targ.bIsFreeday)
			{
				CReplyToCommand(client, "%t %t", "Plugin Tag", "Player Not Freeday");
				RemoveFreedaysMenu(client);
				return;
			}

			targ.RemoveFreeday();
			char tag[32];
			FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
			CShowActivityEx(client, tag, "%t", "Admin Remove Freeday", targ.index);
			LogMessage("\"%L\" triggered \"%t\"", client, "Admin Remove Freeday", targ.index);
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
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bIsWardenLocked)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Warden Already Locked");
		return Plugin_Handled;
	}

	gamemode.iWarden.WardenUnset();
	gamemode.bIsWardenLocked = true;
	char tag[32];
	FormatEx(tag, sizeof(tag), "%t",  "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Lock Warden");
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Lock Warden");
//	CPrintToChatAll("%t %t", "Admin Tag", "Admin Lock Warden");

	return Plugin_Handled;
}

public Action AdminUnlockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!gamemode.bIsWardenLocked)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Warden Not Locked");
		return Plugin_Handled;
	}

	gamemode.bIsWardenLocked = false;
	char tag[32];
	FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Admin Unlock Warden");
	LogMessage("\"%L\" triggered \"%t\"", client, "Admin Unlock Warden");
//	CPrintToChatAll("%t %t", "Admin Tag", "Admin Unlock Warden");

	return Plugin_Handled;
}

public int MenuHandle_GiveLR(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!JailFighter(client).bIsWarden)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
				return;
			}

			char player[32];
			menu.GetItem(select, player, sizeof(player));
			int target = GetClientOfUserId(StringToInt(player));

			if (!IsClientInGame(target))
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Player no longer available");
				return;
			}
			if (GetClientTeam(target) != RED)
			{
				CPrintToChat(client, "%t %t,", "Plugin Tag", "Target Not On Red");
				return;
			}
			if (gamemode.bIsLRInUse)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "LR Given");
				return;
			}

			JailFighter(target).ListLRS();
			CPrintToChatAll("%t %t", "Plugin Tag", "Warden Give LR", client, target);
		}
		case MenuAction_End:delete menu;
	}
}

public void FreedayforClientsMenu(const int client)
{
	if (IsVoteInProgress() || !IsPlayerAlive(client))
		return;

	Menu menu = new Menu(MenuHandle_FreedayForClients);
	menu.SetTitle("%t", "Select For Freeday");

	char name[32], strID[8];
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (!JailFighter(i).bIsQueuedFreeday)
		{
			IntToString(GetClientUserId(i), strID, sizeof(strID));
			GetClientName(i, name, sizeof(name));
			menu.AddItem(strID, name);
		}
	}
//	AddClientsToMenu(menu, false, 0);
	menu.ExitButton = true;
	menu.Display(client, 0);
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
				CPrintToChat(client, "%t %t", "Plugin Tag", "Player no longer available");
				FreedayforClientsMenu(client);
				return;
			}
			JailFighter targ = JailFighter(target);
			if (targ.bIsQueuedFreeday)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Freeday Already Queued", target);
				FreedayforClientsMenu(client);
				return;
			}
			if (limit < cvarTF2Jail[FreedayLimit].IntValue)
			{
				targ.bIsQueuedFreeday = true;
				limit++;
				CPrintToChatAll("%t %t", "Plugin Tag", "Chosen For Freeday", client, target);
				if (limit < cvarTF2Jail[FreedayLimit].IntValue)
					FreedayforClientsMenu(client);
				else limit = 0;
			}
			else 
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Freeday Max", client);
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

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[0].BoolValue)
	{
		hEngineConVars[0].SetBool(true);
		CPrintToChatAll("%t %t", "Plugin Tag", "FF On Warden", client);
		gamemode.bWardenToggledFF = true;
	}
	else
	{
		hEngineConVars[0].SetBool(false);
		CPrintToChatAll("%t %t", "Plugin Tag", "FF Off Warden", client);
	}
	return Plugin_Handled;
}

public Action Command_WardenCC(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[1].BoolValue)
	{
		hEngineConVars[1].SetBool(true);
		CPrintToChatAll("%t %t", "Plugin Tag", "Collisions On Warden", client);
	}
	else
	{
		hEngineConVars[1].SetBool(false);
		CPrintToChatAll("%t %t", "Plugin Tag", "Collisions Off Warden", client);
	}
	return Plugin_Handled;
}

public Action Command_WardenMarker(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[Markers].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	if (gamemode.bMarkerExists)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Slow Down");
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
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[WardenLaser].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	if (player.bLasering)
	{
		player.bLasering = false;
		CPrintToChat(client, "%t %t", "Plugin Tag", "Laser Off");
	}
	else
	{
		player.bLasering = true;
		CPrintToChat(client, "%t %t", "Plugin Tag", "Laser On");
	}

	return Plugin_Handled;
}

public Action Command_WardenToggleMedic(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	if (!cvarTF2Jail[WardenToggleMedic].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}

	if (gamemode.bMedicDisabled)
		CPrintToChatAll("%t %t", "Plugin Tag", "Medic Room Enabled", client);
	else CPrintToChatAll("%t %t", "Plugin Tag", "Medic Room Disabled", client);
	
	gamemode.ToggleMedic(gamemode.bMedicDisabled);
	return Plugin_Handled;
}

public Action Command_FireWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	if (!cvarTF2Jail[WardenFiring].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}

	if (!gamemode.bWardenExists)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "No Current Warden");
		return Plugin_Handled;
	}

	JailFighter(client).AttemptFireWarden();
	return Plugin_Handled;
}

public Action Command_WardenInvite(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;
	
	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	
	if (!cvarTF2Jail[WardenInvite].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}

	if (!args)
	{
		MakeInviteMenu(client);
		return Plugin_Handled;
	}

	char targetname[32]; GetCmdArgString(targetname, sizeof(targetname));
	char clientName[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;

	int target_count = ProcessTargetString(targetname, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

	if (target_count != 1)
		ReplyToTargetError(client, target_count);
	
	if (GetClientTeam(target_list[0]) != RED)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Target Not On Red");
		return Plugin_Handled;
	}

	player.InviteToGuards(JailFighter(target_list[0]));
	return Plugin_Handled;
}

public void MakeInviteMenu(const int client)
{
	Menu menu = new Menu(InviteMenu);
	menu.SetTitle("%t", "Choose Player");
	AddClientsToMenu(menu, true, RED);
	menu.Display(client, 0);
}

public int InviteMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsClientValid(client) || !IsPlayerAlive(client))
				return;

			JailFighter player = JailFighter(client);
			if (!player.bIsWarden)
				return;

			char s[8]; menu.GetItem(select, s, sizeof(s));
			JailFighter target = JailFighter.OfUserId(StringToInt(s));

			if (!IsClientValid(target.index))
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Player no longer available");
				MakeInviteMenu(client);
				return;
			}

			if (!IsPlayerAlive(target.index))
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Need Alive");
				MakeInviteMenu(client);
				return;
			}

			if (GetClientTeam(target.index) != RED)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag", "Target Not On Red");
				MakeInviteMenu(client);
				return;
			}

			player.InviteToGuards(target);
		}
		case MenuAction_End:delete menu;
	}
}

public Action Command_WardenToggleMuting(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;
	
	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	
	if (!cvarTF2Jail[WardenToggleMuting].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}

	DetermineMuteStyleMenu(player.index);
	return Plugin_Handled;
}

public void DetermineMuteStyleMenu(const int client)
{
	Menu menu = new Menu(MuteStyleMenu);
	menu.SetTitle("%t", "Mute Style Select");

	char s[16];
	FormatEx(s, sizeof(s), "%t", "Living");
	menu.AddItem("0", s);
	FormatEx(s, sizeof(s), "%t", "Dead");
	menu.AddItem("1", s);
	menu.Display(client, 0);
}

public int MuteStyleMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsClientValid(client) || !IsPlayerAlive(client))
				return;

			char s[4]; menu.GetItem(select, s, sizeof(s));
			MakeMuteToggleMenu(client, StringToInt(s));
		}
		case MenuAction_End:delete menu;
	}
}

public void MakeMuteToggleMenu(const int client, const int type)
{
	Menu menu = new Menu(MuteToggleMenu);
	menu.SetTitle("%t", "Mute Style Select");

	char s[64], id[4];
	int draw, currtype = (type ? gamemode.iMuteType : gamemode.iLivingMuteType);

	for (int i = 0; i < 7; ++i)
	{
		draw = (i == currtype ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		switch (i)
		{
			case 0:FormatEx(s, sizeof(s), "%t", "Mute No One");
			case 1:FormatEx(s, sizeof(s), "%t", "Mute Red Ex VIP");
			case 2:FormatEx(s, sizeof(s), "%t", "Mute Blue Ex VIP");
			case 3:FormatEx(s, sizeof(s), "%t", "Mute All Ex VIP");
			case 4:FormatEx(s, sizeof(s), "%t", "Mute All Red");
			case 5:FormatEx(s, sizeof(s), "%t", "Mute All Blue");
			case 6:FormatEx(s, sizeof(s), "%t", "Mute All");
		}
		IntToString(i, id, sizeof(id));
		menu.AddItem(id, s, draw);
	}

	IntToString(type, id, sizeof(id));
	menu.AddItem("7", id, ITEMDRAW_IGNORE);
	menu.Display(client, 0);
}

public int MuteToggleMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsClientValid(client) || !IsPlayerAlive(client))
				return;

			char s[2]; menu.GetItem(select, s, sizeof(s));
			char s2[2]; menu.GetItem(8, s2, sizeof(s2));

			if (StringToInt(s2))
				gamemode.iMuteType = StringToInt(s);
			else gamemode.iLivingMuteType = StringToInt(s);

			gamemode.RecalcMuting();
			CPrintToChatAll("%t %t", "Plugin Tag", "Warden Toggle Mute", client);
		}
		case MenuAction_End:delete menu;
	}
}

public Action Command_WardenHP(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;
	
	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Command is in-game only");
		return Plugin_Handled;
	}

	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Warden");
		return Plugin_Handled;
	}
	
	if (!cvarTF2Jail[WardenSetHP].BoolValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Not Enabled");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) != RED)
			continue;

		SetEntityHealth(i, GetEntProp(i, Prop_Data, "m_iMaxHealth"));
	}
	CPrintToChatAll("%t %t", "Plugin Tag", "Warden Health Restore", client);
	return Plugin_Handled;
}

public Action AdminWardayRed(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Before Or During Round");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetRed)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "No Warday Config At Location");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i) || GetClientTeam(i) != RED)
			continue;

		TeleportEntity(i, vecWardayRed, NULL_VECTOR, NULL_VECTOR);
	}

	char tag[64]; FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Warday Red Active");
	LogMessage("\"%L\" triggered \"%t\"", client, "Warday Red Active");
	return Plugin_Handled;
}

public Action AdminWardayBlue(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!(StateStarting <= gamemode.iRoundState <= StateRunning))
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Before Or During Round");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetBlue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "No Warday Config At Location");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i) || GetClientTeam(i) != BLU)
			continue;

		TeleportEntity(i, vecWardayBlu, NULL_VECTOR, NULL_VECTOR);
	}

	char tag[64]; FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Warday Blue Active");
	LogMessage("\"%L\" triggered \"%t\"", client, "Warday Blue Active");
	return Plugin_Handled;
}

public Action AdminFullWarday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!(StateRunning <= gamemode.iRoundState <= StateRunning))
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Before Or During Round");
		return Plugin_Handled;
	}

	bool allowred = gamemode.bWardayTeleportSetRed,
		 allowblu = gamemode.bWardayTeleportSetBlue;

	if (!allowblu && !allowred)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "No Warday Config");
		return Plugin_Handled;
	}
	else if (!allowred)
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Ignore Red Team Warday");
	else if (!allowblu)
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Ignore Blue Team Warday");

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			JailFighter(i).TeleportToPosition(GetClientTeam(i));

	char tag[64]; FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	CShowActivityEx(client, tag, "%t", "Warday Activate");
	LogMessage("\"%L\" triggered \"%t\"", client, "Warday Activate");
	return Plugin_Handled;
}

public Action AdminReloadCFG(int client, int args)
{
	ServerCommand("exec sourcemod/TF2JailRedux.cfg");
	CReplyToCommand(client, "%t %t", "Admin Tag", "Reload CFG");
	return Plugin_Handled;
}

public Action AdminToggleMedic(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	char tag[64]; FormatEx(tag, sizeof(tag), "%t ", "Admin Tag");
	char method[256];
	if (gamemode.bMedicDisabled)
		FormatEx(method, sizeof(method), "%t", "Medic Room Enabled Admin");
	else FormatEx(method, sizeof(method), "%t", "Medic Room Disabled Admin");

	CShowActivityEx(client, tag, "%t", method);
	LogMessage("\"%L\" triggered \"%t\"", client, method);

	gamemode.ToggleMedic(gamemode.bMedicDisabled);
	return Plugin_Handled;
}

// Thx Mr. Panica
public Action AdminJailTime(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!args)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Jail Time Usage");
		return Plugin_Handled;
	}

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Needs Active Round");
		return Plugin_Handled;
	}

	char arg[32]; GetCmdArg(1, arg, sizeof(arg));
	if (!IsStringNumeric(arg))
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag", "Requires Number");
		return Plugin_Handled;
	}

	int time = StringToInt(arg);
	if (time < 0)
		time = 0;

	gamemode.iTimeLeft = time;
	CReplyToCommand(client, "%t %t", "Plugin Tag", "Time Set", time);
	return Plugin_Handled;
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
public Action GameModeProp(int client, int args)
{
	char arg[64]; GetCmdArg(1, arg, 64);
	any val = JBGameMode_GetProp(arg);
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
		val = player.GetProp(arg1);
		CReplyToCommand(client, "%s value: %i", arg1, val);
		return Plugin_Handled;
	}

	char arg2[64]; GetCmdArg(2, arg2, 64);
	char clientName[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;

	int target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);

	if (target_count != 1)
		ReplyToTargetError(client, target_count);

	player = JBPlayer(target_list[0]);

	val = player.GetProp(arg2);
	CReplyToCommand(client, "%N's %s value: %i", player.index, arg2, val);
	return Plugin_Handled;
}
public Action hLRSLength(int client, int args)
{
	CReplyToCommand(client, "%d", gamemode.hLRS.Size);
}