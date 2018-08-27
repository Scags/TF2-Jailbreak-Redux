public Action Command_Help(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;
	
	Panel panel = new Panel();
	char buffer[32];
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Welcome");
	panel.SetTitle(buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Who's Warden");
	panel.DrawItem(buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel What are LR's");
	panel.DrawItem(buffer);
#if defined _clientprefs_included
	FormatEx(buffer, sizeof(buffer), "%t", "Help Panel Turn Off Music");
	panel.DrawItem(buffer);
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
						CPrintToChat(client, "{crimson}[TF2Jail]{default} %t", "Current Warden", gamemode.iWarden.index);
					else CPrintToChat(client, TAG ... "%t", "No Current Warden");
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

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (player.bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Already Warden");
		return Plugin_Handled;
	}

	if (gamemode.bWardenExists)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{default} %t", "CurrentWarden", gamemode.iWarden.index);
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, TAG ... "%t", "Need Alive");
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != BLU)
	{
		CPrintToChat(client, TAG ... "%t", "Need Blue Team");
		return Plugin_Handled;
	}

	if (gamemode.bAdminLockWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Admin Lock Warden");
		return Plugin_Handled;
	}

	if (gamemode.b1stRoundFreeday || gamemode.bIsWardenLocked)
	{
		CPrintToChat(client, TAG ... "%t", "Warden Locked");
		return Plugin_Handled;
	}
	
	if (player.bLockedFromWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Locked From Warden");
		return Plugin_Handled;
	}
	
	player.WardenSet();
	player.WardenMenu();
	return Plugin_Handled;
}

public Action Command_ExitWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	CPrintToChatAll(TAG ... "%t", "Warden Retired Chat", client);
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN, true);

	return Plugin_Handled;
}

public Action Command_CloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!gamemode.bIsMapCompatible)
	{
		CPrintToChat(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}
	
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE, true);

	return Plugin_Handled;
}

public Action Command_EnableFriendlyFire(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	switch (hEngineConVars[0].BoolValue)
	{
		case true:
		{
			hEngineConVars[0].SetBool(false);
			CPrintToChatAll(TAG ... "%t", "FF Off Warden", client);
		}
		case false:
		{
			hEngineConVars[0].SetBool(true);
			CPrintToChatAll(TAG ... "%t", "FF On Warden", client);
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	switch (hEngineConVars[1].BoolValue)
	{
		case true:
		{
			hEngineConVars[1].SetBool(false);
			CPrintToChatAll(TAG ... "%t", "Collisions Off Warden", client);
		}
		case false:
		{
			hEngineConVars[1].SetBool(true);
			CPrintToChatAll(TAG ... "%t", "Collisions On Warden", client);
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bAdminLockedLR)
	{
		CPrintToChat(client, TAG ... "%t", "Admin Locked LR");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}
	if (gamemode.bIsLRInUse)
	{
		CPrintToChat(client, TAG ... "%t", "LR Given");
		return Plugin_Handled;
	}

	if (!args)
	{
		if (IsVoteInProgress())
			return Plugin_Handled;

		Menu menu = new Menu(MenuHandle_ForceLR);
		char buffer[16]; FormatEx(buffer, sizeof(buffer), "%t", "Choose Player");
		menu.SetTitle(buffer);
		AddClientsToMenu(menu, true);
		menu.ExitButton = true;
		menu.Display(client, -1);

		return Plugin_Handled;
	}

	char targetname[32]; GetCmdArgString(targetname, sizeof(targetname));
	int target = FindTarget(client, targetname);
	if (!IsClientValid(target))
	{
		CPrintToChat(client, TAG ... "%t", "Player no longer available");
		return Plugin_Handled;
	}
	if (!IsPlayerAlive(target))
	{
		CPrintToChat(client, TAG ... "%", "Target must be alive");
		return Plugin_Handled;
	}
	if (GetClientTeam(target) != RED)
	{
		CPrintToChat(client, TAG ... "%t", "Target Not On Red");
		return Plugin_Handled;
	}
	JailFighter(target).ListLRS();

	return Plugin_Handled;
}

public Action Command_RemoveLastRequest(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[DenyLR].BoolValue)
	{
		CPrintToChat(client, TAG ... "%t", "Denying LR Disabled");
		return Plugin_Handled;
	}

	if (gamemode.iLRPresetType < 0)
	{
		CPrintToChat(client, TAG ... "%t", "No LR Next Round");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			JailFighter(i).bIsQueuedFreeday = false;

	arrLRS.Set( gamemode.iLRPresetType, arrLRS.Get(gamemode.iLRPresetType)-1 );
	gamemode.bIsLRInUse = false;
	gamemode.iLRPresetType = -1;
	CPrintToChatAll(TAG ... "%t", "Warden Deny LR", client);

	return Plugin_Handled;
}

public Action Command_ListLastRequests(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
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
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
		CReplyToCommand(client, "{crimson}[TF2Jail]{default} %t", "CurrentWarden", gamemode.iWarden.index);
	else CReplyToCommand(client, TAG ... "%t", "No Current Warden");

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
			CPrintToChat(client, TAG ... "%t", "Music On");
		}
		else
		{
			player.bNoMusic = true;
			CPrintToChat(client, TAG ... "%t", "Music Off");
		}
	}
}
#endif

public Action AdminRemoveWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!gamemode.bWardenExists)
	{
		CReplyToCommand(client, TAG ... "%t", "No Current Warden");
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
		CReplyToCommand(client, TAG ... "%t", "No LR Next Round");
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
			CPrintToChat(i, ADMTAG ... "%t", "Admin Remove Queued Freeday");
			player.bIsQueuedFreeday = false;
		}

		if (player.bIsFreeday)
		{
			CPrintToChat(i, ADMTAG ... "%t", "Admin Remove Freeday");
			player.RemoveFreeday();
		}
	}

	int type = gamemode.iLRPresetType;
	arrLRS.Set( type, arrLRS.Get(type)-1 );
	gamemode.iLRPresetType = -1;
	gamemode.bIsLRInUse = false;

	CPrintToChatAll(ADMTAG ... "%t", "Admin Denied LR");

	return Plugin_Handled;
}

public Action AdminOpenCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(OPEN, true, false);

	return Plugin_Handled;
}

public Action AdminCloseCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(CLOSE, true, false);

	return Plugin_Handled;
}

public Action AdminLockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(LOCK, true, false);

	return Plugin_Handled;
}

public Action AdminUnlockCells(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bIsMapCompatible)
	{
		CReplyToCommand(client, TAG ... "%t", "Map Incompatible");
		return Plugin_Handled;
	}

	gamemode.DoorHandler(UNLOCK, true, false);

	return Plugin_Handled;
}

public Action AdminForceWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);
		if (!IsClientValid(target))
		{
			CReplyToCommand(client, TAG ... "%t", "Player no longer available");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(target))
		{
			CReplyToCommand(client, TAG ... "%", "Target must be alive");
			return Plugin_Handled;
		}

		if (GetClientTeam(target) != BLU)
		{
			CReplyToCommand(client, TAG ... "%t", "Target Need Blue Team");
			return Plugin_Handled;
		}

		if (gamemode.bWardenExists)
			gamemode.iWarden.WardenUnset();

		JailFighter targ = JailFighter(target);
		targ.WardenSet();
		targ.WardenMenu();
		CPrintToChatAll(ADMTAG ... "%t", "Admin Force Warden", target);
		
		return Plugin_Handled;
	}

	if (gamemode.bWardenExists)
		gamemode.iWarden.WardenUnset();

	gamemode.FindRandomWarden();
	CPrintToChatAll(ADMTAG ... "%t", "Admin Force Random Warden");
	return Plugin_Handled;
}

public Action AdminForceLR(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	
	if (args)
	{
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));

		int target = FindTarget(client, arg, true);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, TAG ... "%t", "Player no longer available");
			return Plugin_Handled;
		}
		if (!IsPlayerAlive(client))
		{
			CReplyToCommand(client, TAG ... "%t", "Target must be alive");
			return Plugin_Handled;
		}
		CPrintToChatAll(ADMTAG ... "%t", "Admin Force LR", target);
		JailFighter(target).ListLRS();

		return Plugin_Handled;
	}

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!IsPlayerAlive(client))
	{
		CReplyToCommand(client, TAG ... "%t", "Need Alive");
		return Plugin_Handled;
	}

	CPrintToChatAll(ADMTAG ... "%t", "Admin Force LR Self");
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
	CPrintToChatAll("{orange}[TF2Jail]{fullred} %t", "Admin Reset Plugin");

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
			CReplyToCommand(client, ADMTAG ... "%t", "Doors Work");
		else CReplyToCommand(client, "{orange}[TF2Jail]{fullred} %t", "Doors Don't Work");
	}

	if (sCellOpener[0] != '\0')
	{
		int open_cells = FindEntity(sCellOpener, "func_button");
		if (IsValidEntity(open_cells))
			CReplyToCommand(client, ADMTAG ... "%t", "Buttons Work");
		else CReplyToCommand(client, "{orange}[TF2Jail]{fullred} %t", "Buttons Don't Work");
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
			CReplyToCommand(client, TAG ... "%t", "Player no longer available");
			return Plugin_Handled;
		}
		JailFighter targ = JailFighter(target);

		if (targ.bIsFreeday)
		{
			CReplyToCommand(client, TAG ... "%t", "Target Is Freeday");
			return Plugin_Handled;
		}
		
		CPrintToChatAll(ADMTAG ... "%t", "Admin Give Freeday", target);
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
				CPrintToChat(client, TAG ... "%t", "Player no longer available");
				Admin_GiveFreedaysMenu(client);
				return;
			}

			JailFighter(target).GiveFreeday();
			CPrintToChatAll(ADMTAG ... "%t", "Admin Give Freeday", target);
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
			CReplyToCommand(client, TAG ... "%t", "Player no longer available");
			return Plugin_Handled;
		}

		JailFighter targ = JailFighter(target);
		if (!targ.bIsFreeday)
		{
			CReplyToCommand(client, TAG ... "Target is not a freeday.");
			return Plugin_Handled;
		}

		CPrintToChatAll(ADMTAG ... "%t", "Admin Remove Freeday", target);
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
			JailFighter targ = JailFighter.OfUserId(StringToInt(player));
			
			if (!IsClientInGame(targ.index))
			{
				CReplyToCommand(client, TAG ... "%t", "Player no longer available");
				return;
			}

			if (!targ.bIsFreeday)
			{
				CReplyToCommand(client, TAG ... "%t", "Player Not Freeday");
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
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, TAG ... "%t", "Warden Already Locked");
		return Plugin_Handled;
	}
	if (gamemode.bWardenExists)
		gamemode.iWarden.WardenUnset();

	gamemode.bAdminLockWarden = true;
	CPrintToChatAll(ADMTAG ... "%t", "Admin Lock Warden");

	return Plugin_Handled;
}

public Action AdminUnlockWarden(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!gamemode.bAdminLockWarden)
	{
		CReplyToCommand(client, TAG ... "%t", "Warden Not Locked");
		return Plugin_Handled;
	}

	gamemode.bAdminLockWarden = false;
	CPrintToChatAll(ADMTAG ... "%t", "Admin Unlock Warden");

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
				CPrintToChat(client, TAG ... "%t", "Not Warden");
				return;
			}

			char player[32];
			menu.GetItem(select, player, sizeof(player));
			int target = GetClientOfUserId(StringToInt(player));

			if (!IsClientInGame(target))
			{
				CPrintToChat(client, TAG ... "%t", "Player no longer available");
				return;
			}
			if (GetClientTeam(target) != RED)
			{
				CPrintToChat(client, TAG ... "%t,", "Target Not On Red");
				return;
			}
			if (gamemode.bIsLRInUse)
			{
				CPrintToChat(client, TAG ... "%t", "LR Given");
				return;
			}

			JailFighter(target).ListLRS();
			CPrintToChatAll(TAG ... "%t", "Warden Give LR", client, target);
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
	
	AddClientsToMenu(menu, false, 0);
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
				CPrintToChat(client, TAG ... "%t", "Player no longer available");
				FreedayforClientsMenu(client);
				return;
			}
			JailFighter targ = JailFighter(target);
			if (targ.bIsQueuedFreeday)
			{
				CPrintToChat(client, TAG ... "%t", "Freeday Already Queued", target);
				FreedayforClientsMenu(client);
				return;
			}
			if (limit < cvarTF2Jail[FreedayLimit].IntValue)
			{
				targ.bIsQueuedFreeday = true;
				limit++;
				CPrintToChatAll(TAG ... "%t", "Chosen For Freeday", client, target);
				if (limit < cvarTF2Jail[FreedayLimit].IntValue)
					FreedayforClientsMenu(client);
				else limit = 0;
			}
			else 
			{	
				CPrintToChat(client, TAG ... "%t", "Freeday Max", client);
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[0].BoolValue)
	{
		hEngineConVars[0].SetBool(true);
		CPrintToChatAll(TAG ... "%t", "FF On Warden", client);
	}
	else
	{
		hEngineConVars[0].SetBool(false);
		CPrintToChatAll(TAG ... "%t", "FF Off Warden", client);
	}
	return Plugin_Handled;
}

public Action Command_WardenCC(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}

	if (!hEngineConVars[1].BoolValue)
	{
		hEngineConVars[1].SetBool(true);
		CPrintToChatAll(TAG ... "%t", "Collisions On Warden", client);
	}
	else
	{
		hEngineConVars[1].SetBool(false);
		CPrintToChatAll(TAG ... "%t", "Collisions Off Warden");
	}
	return Plugin_Handled;
}

public Action Command_WardenMarker(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[Markers].BoolValue)
	{
		CPrintToChat(client, TAG ... "%t", "Not Enabled");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}

	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}
	if (gamemode.bMarkerExists)
	{
		CPrintToChat(client, TAG ... "%t", "Slow Down");
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
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	if (!cvarTF2Jail[WardenLaser].BoolValue)
	{
		CPrintToChat(client, TAG ... "%t", "Not Enabled");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	JailFighter player = JailFighter(client);
	if (!player.bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}
	if (player.bLasering)
	{
		player.bLasering = false;
		CPrintToChat(client, TAG ... "%t", "Laser Off");
	}
	else
	{
		player.bLasering = true;
		CPrintToChat(client, TAG ... "%t", "Laser On");
	}

	return Plugin_Handled;
}

public Action Command_WardenToggleMedic(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (!client)
	{
		CReplyToCommand(client, TAG ... "%t", "Command is in-game only");
		return Plugin_Handled;
	}

	if (!cvarTF2Jail[WardenToggleMedic].BoolValue)
	{
		CPrintToChat(client, TAG ... "%t", "Not Enabled");
		return Plugin_Handled;
	}

	if (gamemode.iRoundState != StateRunning)
	{
		CPrintToChat(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (!JailFighter(client).bIsWarden)
	{
		CPrintToChat(client, TAG ... "%t", "Not Warden");
		return Plugin_Handled;
	}
	if (gamemode.bMedicDisabled)
		CPrintToChatAll(TAG ... "%t", "Medic Room Enabled", client);
	else CPrintToChatAll(TAG ... "%t", "Medic Room Disabled", client);
	
	gamemode.ToggleMedic(gamemode.bMedicDisabled);
	return Plugin_Handled;
}

public Action AdminWardayRed(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Before Or During Round");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetRed)
	{
		CReplyToCommand(client, TAG ... "%t", "No Warday Config At Location");
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

	CPrintToChatAll(ADMTAG ... "%t", "Warday Red Active");
	return Plugin_Handled;
}

public Action AdminWardayBlue(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Before Or During Round");
		return Plugin_Handled;
	}

	if (!gamemode.bWardayTeleportSetBlue)
	{
		CReplyToCommand(client, TAG ... "%t", "No Warday Config At Location");
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

	CPrintToChatAll(ADMTAG ... "%t", "Warday Blue Active");
	return Plugin_Handled;
}

public Action AdminFullWarday(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState > StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Before Or During Round");
		return Plugin_Handled;
	}

	bool allowred = gamemode.bWardayTeleportSetRed,
		 allowblu = gamemode.bWardayTeleportSetBlue;

	if (!allowred)
		CReplyToCommand(client, TAG ... "%t", "Ignore Red Team Warday");
	else if (!allowblu)
		CReplyToCommand(client, TAG ... "%t", "Ignore Blue Team Warday");
	else if (!allowblu && !allowred)
	{
		CReplyToCommand(client, TAG ... "%t", "No Warday Config");
		return Plugin_Handled;
	}

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			JailFighter(i).TeleportToPosition(GetClientTeam(i));

	CPrintToChatAll(ADMTAG ... "%t", "Warday Activate");
	return Plugin_Handled;
}

public Action AdminReloadCFG(int client, int args)
{
	ServerCommand("exec sourcemod/TF2JailRedux.cfg");
	CReplyToCommand(client, "{orange}[TF2Jail]{fullred} %t", "Reload CFG");
	return Plugin_Handled;
}

public Action AdminToggleMedic(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;

	if (gamemode.iRoundState != StateRunning)
	{
		CReplyToCommand(client, TAG ... "%t", "Needs Active Round");
		return Plugin_Handled;
	}
	if (gamemode.bMedicDisabled)
		CPrintToChatAll(ADMTAG ... "%t", "Medic Room Enabled Admin");
	else CPrintToChatAll(ADMTAG ... "%t", "Medic Room Disabled Admin");

	gamemode.ToggleMedic(gamemode.bMedicDisabled);
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
	CReplyToCommand(client, "%d", gamemode.hPlugins.Size);
}
public Action arrLRSLength(int client, int args)
{
	CReplyToCommand(client, "%d", arrLRS.Length);
}