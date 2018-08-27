#pragma semicolon 1

#include <morecolors>
#include <tf2jailredux_teambans>
#include <tf2jailredux>
#include <clientprefs>

#undef TAG
#define TAG "{crimson}[TF2Jail] Teambans{burlywood} "

#define PLUGIN_VERSION "1.0.0"
#define RED 				2
#define BLU 				3
#define IsClientValid(%1) 	((0 < %1 <= MaxClients) && IsClientInGame(%1))

#pragma newdecls required

public Plugin myinfo =
{
	name = "TF2Jail Redux Team Bans",
	author = "Scag/Ragenewb",
	description = "Guardbanning functionality for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = ""
};

enum
{
	JoinMessage = 0,
	Prefix,
	SQLDriver,
	Debug,
	RageTableRefresh,
	IgnoreMidRound,
	Version
}

ArrayList	// ArrayList of menu-useable data
	hRageTable,
	hRageTableNames
;

int			// Refresh RageTable every x mapchanges
	iTableDelete
;

bool
	bLate,
	bDisabled	// Grrrr
;

ConVar
	bEnabled,
	cvarJBANS[Version + 1]
;

char
	strCoreTable[32],
	strLogTable[64]
;

Database
	hTheDB
;

Handle
	hOnBan,
	hOnUnBan,
	hOnOfflineBan,
	hOnOfflineUnBan
;

methodmap JailPlayer < JBPlayer
{
	public JailPlayer( const int r )
	{
		return view_as< JailPlayer >(JBPlayer(r));
	}

	public static JailPlayer OfUserId( const int id )
	{
		return view_as< JailPlayer >(JBPlayer.OfUserId(id));
	}

	public static JailPlayer Of( const JBPlayer player )
	{
		return view_as< JailPlayer >(player);
	}

	property int iTimeLeft 
	{
		public get() 				{ return this.GetValue("iTimeLeft"); }
		public set( const int i ) 	{ this.SetValue("iTimeLeft", i); }
	}

	property bool bIsGuardbanned
	{
		public get() 				{ return this.GetValue("bIsGuardbanned"); }
		public set( const bool i ) 	{ this.SetValue("bIsGuardbanned", i); }
	}

	// Soon(tm)
	/*property bool bWardenBanned
	{
		public get() 				{ return this.GetValue("bWardenBanned"); }
		public set( const bool i ) 	{ this.SetValue("bWardenBanned", i); }
	}*/	
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	bEnabled 						= CreateConVar("sm_jbans_enable", "1", "Status of the plugin: (1 = on, 0 = off)", FCVAR_NOTIFY);
	cvarJBANS[Version] 				= CreateConVar("tf2jbans_version", PLUGIN_VERSION, "TF2Jail Redux GuardBans version. (DO NOT TOUCH)", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarJBANS[JoinMessage] 			= CreateConVar("sm_jbans_banmessage", "Please visit our website to appeal.", "Message to the client on join if banned.", FCVAR_NOTIFY);
	cvarJBANS[Prefix] 				= CreateConVar("sm_jbans_tableprefix", "", "Prefix for database tables. (Can be blank)", FCVAR_NOTIFY);
	cvarJBANS[SQLDriver] 			= CreateConVar("sm_jbans_sqldriver", "default", "Config entry to use for database.", FCVAR_NOTIFY);
	cvarJBANS[Debug] 				= CreateConVar("sm_jbans_debug", "1", "Enable console debugging for TF2Jail Redux GuardBans?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarJBANS[RageTableRefresh]		= CreateConVar("sm_jbans_ragetable_refresh", "2", "Refresh the Rage Ban menu every 'x' mapchanges.", FCVAR_NOTIFY, true, 1.0, true, 10.0);
	cvarJBANS[IgnoreMidRound]		= CreateConVar("sm_jbans_ignore_midround", "1", "If a guardbanned player spawns on blue in the middle of the round, ignore forcing them to Red team?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	RegAdminCmd("sm_gb", Cmd_GuardBan, ADMFLAG_GENERIC, "Ban a player from blue team.");
	RegAdminCmd("sm_guardban", Cmd_GuardBan, ADMFLAG_GENERIC, "Ban a player from blue team.");
	RegAdminCmd("sm_teamban", Cmd_GuardBan, ADMFLAG_GENERIC, "Ban a player from blue team.");
	RegAdminCmd("sm_teamban_status", Cmd_IsBanned, ADMFLAG_GENERIC, "Determine if a player is GuardBanned.");
	RegAdminCmd("sm_gbstatus", Cmd_IsBanned, ADMFLAG_GENERIC, "Determine if a player is GuardBanned.");
	RegAdminCmd("sm_gbs", Cmd_IsBanned, ADMFLAG_GENERIC, "Determine if a player is GuardBanned.");
	RegAdminCmd("sm_tub", Cmd_UnGuardBan, ADMFLAG_GENERIC, "Unban a player from blue team.");
	RegAdminCmd("sm_gub", Cmd_UnGuardBan, ADMFLAG_GENERIC, "Unban a player from blue team.");
	RegAdminCmd("sm_teamunban", Cmd_UnGuardBan, ADMFLAG_GENERIC, "Unban a player from blue team.");
	RegAdminCmd("sm_teamban_offline", Cmd_OfflineGuardBan, ADMFLAG_GENERIC, "Ban disconnected players from blue team via Steam ID.");
	RegAdminCmd("sm_gboff", Cmd_OfflineGuardBan, ADMFLAG_GENERIC, "Ban disconnected players from blue team via Steam ID.");
	RegAdminCmd("sm_teamunban_offline", Cmd_OfflineUnGuardBan, ADMFLAG_GENERIC, "Unban disconnected players from blue team via Steam ID.");
	RegAdminCmd("sm_tuboff", Cmd_OfflineUnGuardBan, ADMFLAG_GENERIC, "Unban disconnected players from blue team via Steam ID.");
	RegAdminCmd("sm_rb", Cmd_RageBan, ADMFLAG_GENERIC, "Ban disconnected players through a menu.");
	RegAdminCmd("sm_rageban", Cmd_RageBan, ADMFLAG_GENERIC, "Ban disconnected players through a menu.");

	AutoExecConfig(true, "TF2JailRedux_TeamBans");

	hRageTable  	= new ArrayList(ByteCountToCells(22));
	hRageTableNames = new ArrayList(ByteCountToCells(22));

	iTableDelete = 0;
}

public void OnAllPluginsLoaded()
{
	JB_Hook(OnPlayerSpawned, fwdOnPlayerSpawn);
}

/**
 *	Purpose: Disable the plugin if TF2Jail Redux is unloaded.
 *	This is simpler than unloading the plugin during this time.
*/
public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{
		bDisabled = bEnabled.BoolValue;
		if (bDisabled)
			bEnabled.SetBool(false);
	}
}

/**
 *	Purpose: re-enable the plugin when TF2Jail Redux is loaded.
 *	This will not fire if the plugin is disabled via CVar.
 *	This is why 'bDisabled' is used.
*/
public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{
		if (bDisabled)
			bEnabled.SetBool(true);

		OnAllPluginsLoaded();
	}
}

public void OnMapStart()
{
	CreateTimer(60.0, CheckTimedGuardBans, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	if (!(++iTableDelete % cvarJBANS[RageTableRefresh].IntValue))
	{
		hRageTable.Clear();
		hRageTableNames.Clear();
	}
}

public void OnConfigsExecuted()
{
	char database[32]; cvarJBANS[SQLDriver].GetString(database, sizeof(database));

	if (!hTheDB && database[0] != '\0')
	{
		Database.Connect(DBCB_Connect, database);
		if (cvarJBANS[Debug].BoolValue)
			LogMessage("[JBANS] Connected to database %s.", database);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!bEnabled.BoolValue)
		return;

	if (IsFakeClient(client))
		return;

	char ID[32]; GetClientAuthId(client, AuthId_Steam2, ID, sizeof(ID));

	int pos = hRageTable.FindString(ID);
	if (pos > -1)
	{
		hRageTable.Erase(pos);
		hRageTableNames.Erase(pos);
		if (cvarJBANS[Debug].BoolValue)
			LogMessage("Client %N has been removed from Rage Tables for reconnecting.", client);
	}

	char query[256];
	Format(query, sizeof(query), 
			"SELECT ban_time "
		...	"FROM %s "
		...	"WHERE steamid = '%s';",
			strCoreTable, ID);

	// Has to happen after OnClientPutInServer .-.
	hTheDB.Query(CCB_Induction, query, GetClientUserId(client));

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("Querying client %N connection with query %s", client, query);
}

public void fwdOnPlayerSpawn(const JBPlayer Player)
{
	if (!bEnabled.BoolValue)
		return;
	if (IsFakeClient(Player.index))
		return;
	if (GetClientTeam(Player.index) != BLU)
		return;

	bool running = JBGameMode_GetProperty("iRoundState") == StateRunning;
	if (cvarJBANS[IgnoreMidRound].BoolValue && running)
		return;

	JailPlayer base = JailPlayer.Of(Player);

	if (!base.bIsGuardbanned)
		return;

	char BanMsg[64]; cvarJBANS[JoinMessage].GetString(BanMsg, sizeof(BanMsg));	
	PrintCenterText(base.index, "You are guardbanned");
	CPrintToChat(base.index, TAG ... "%s", BanMsg);
	base.ForceTeamChange(RED, running ? false : true);
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client))
		return;

	if (!bEnabled.BoolValue)
		return;

	char ID[32];
	GetClientAuthId(client, AuthId_Steam2, ID, sizeof(ID));

	JailPlayer player = JailPlayer(client);

	if (!player.bIsGuardbanned)	// If they're not guardbanned then there's no point in querying
	{
		char name[32];
		GetClientName(client, name, sizeof(name));

		hRageTable.PushString(ID);
		hRageTableNames.PushString(name);
		return;
	}

	char query[256];
	Format(query, sizeof(query), 
			"SELECT ban_time"
		...	" FROM %s"
		...	" WHERE steamid = '%s';",
			strCoreTable, ID);

	DataPack pack = new DataPack();
	pack.WriteString(ID);
	pack.WriteCell(player.iTimeLeft);
	hTheDB.Query(CCB_Disconnect, query, pack);
	if (cvarJBANS[Debug].BoolValue)
		LogMessage("Checking out client %N with query %s", client, query);
}

public Action CheckTimedGuardBans(Handle timer)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	JailPlayer player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		
		player = JailPlayer(i);
		if (!player.iTimeLeft || !player.bIsGuardbanned)
			continue;

		player.iTimeLeft--;
		if (player.iTimeLeft <= 0)
		{
			UnGuardBan(i, 0);
			player.bIsGuardbanned = false;
		}
	}
	return Plugin_Continue;
}

public Action Cmd_UnGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (!args)
	{
		DisplayUnbannableMenu(client);
		return Plugin_Handled;
	}
		
	char target[64];
	GetCmdArg(1, target, sizeof(target));
	
	char clientName[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;
	
	int target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS, 0, clientName, sizeof(clientName), tn_is_ml);
	
	if (target_count != 1)
		ReplyToTargetError(client, target_count);
	else UnGuardBan(target_list[0], client);
	
	return Plugin_Handled;
}

public Action Cmd_GuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (!args && client)
	{
		DisplayBannableMenu(client);
		return Plugin_Handled;
	}

	char target[32], s[32], name[32];
	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, s, sizeof(s));
	int time = StringToInt(s);
	
	int target_list[MAXPLAYERS];
	bool tn_is_ml;
	int target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS, 0, name, sizeof(name), tn_is_ml);
	
	if (target_count != 1)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	if (!IsFakeClient(target_list[0]))
	{
		if (JailPlayer(target_list[0]).bIsGuardbanned)
			CReplyToCommand(client, TAG ... "%s %N is already guardbanned.", target_list[0]);
		else
		{
			char reason[256];
			for (int i = 3; i <= args; i++)
			{
				GetCmdArg(i, s, sizeof(s));
				StrCat(reason, sizeof(reason), s);
			}
			GuardBan(target_list[0], client, time, reason);
		}
	}
	else CReplyToCommand(client, TAG ... "Cannot target player.");
	return Plugin_Handled;
}

public Action Cmd_IsBanned(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (args != 1)
	{
		CReplyToCommand(client, TAG ... "Usage: sm_gbs <player>");
		return Plugin_Handled;
	}

	char target[32];
	GetCmdArg(1, target, sizeof(target));

	char name[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;

	int target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS, 0, name, sizeof(name), tn_is_ml);

	if (target_count != 1)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	if (!IsFakeClient(target_list[0]))
	{
		JailPlayer player = JailPlayer(target_list[0]);
		if (player.bIsGuardbanned)
		{
			if (player.iTimeLeft <= 0)
				CReplyToCommand(client, TAG ... "%N is guardbanned permanently.", target_list[0]);
			else CReplyToCommand(client, TAG ... "%N is guardbanned for %i more minutes.", target_list[0], player.iTimeLeft);
		}
		else CReplyToCommand(client, TAG ... "%N is not guardbanned.", target_list[0]);
	}
	else CReplyToCommand(client, TAG ... "Cannot target player.");
	return Plugin_Handled;
}

public Action Cmd_OfflineUnGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, TAG ... "Usage: sm_tuboff <steamid>.");
		return Plugin_Handled;
	}
	
	char ID[32]; GetCmdArgString(ID, sizeof(ID));
	OfflineUnBan(ID, client);
	CReplyToCommand(client, TAG ... "Successfully Unguardbanned Steam ID %s.", ID);
	
	return Plugin_Handled;
}

public Action Cmd_OfflineGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, TAG ... "Usage: sm_gboff <steamid>.");
		return Plugin_Handled;
	}

	char ID[32]; GetCmdArgString( ID, sizeof(ID));

	OfflineBan(ID, client);
	CReplyToCommand(client, TAG ... "Successfully Guardbanned Steam ID %s.", ID);

	return Plugin_Handled;
}

public Action Cmd_RageBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, TAG ... "This plugin is not enabled.");
		return Plugin_Handled;
	}

	if (!client)
	{
		CReplyToCommand(client, TAG ... "Command must be done in-game.");
		return Plugin_Handled;
	}

	RageBanMenu(client);
	return Plugin_Handled;
}

void OfflineBan(const char[] ID, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnOfflineBan);
	Call_PushString(ID);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action == Plugin_Handled || action == Plugin_Stop)	// allow returning Plugin_Changed
		return;

	char query[512];

	// KILL ME
	Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		... "VALUES ('%s', 0) "
		... "ON DUPLICATE KEY "
		... "UPDATE steamid = '%s';",
			strCoreTable, ID, ID);

	hTheDB.Query(CCB_OfflineGuardBan, query);

	int timestamp = GetTime();
	char ID2[32];	if (admin) GetClientAuthId(admin, AuthId_Steam2, ID2, sizeof(ID2)); else ID2 = "Console";

	hTheDB.Format(query, sizeof(query), 
			"INSERT INTO %s "
		... "(timestamp, offender_steamid, offender_name, admin_steamid, "
		... "admin_name, bantime, timeleft, reason) "
		... "VALUES (%d, '%s', NULL, '%s', '%N', 0, 0, '');",
			strLogTable, timestamp, ID, ID2, admin);

	hTheDB.Query(CCB_OfflineGuardBan, query);
}

public void OfflineUnBan(const char[] ID, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnOfflineUnBan);
	Call_PushString(ID);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action != Plugin_Continue)
		return;

	char query[256];
	Format(query, sizeof(query), 
			"DELETE FROM %s "
		...	"WHERE steamid = '%s';",
			strCoreTable, ID);

	hTheDB.Query(CCB_OfflineUnGuardBan, query);

	Format(query, sizeof(query), 
			"UPDATE %s "
		... "SET timeleft = -1 "
		... "WHERE offender_steamid = '%s' "
		... "AND timeleft >= 0;",
			strLogTable, ID);

	hTheDB.Query(CCB_OfflineUnGuardBan, query);
}

public void UnGuardBan(int target, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	if (!target || !IsClientInGame(target))
		return;

	JailPlayer player = JailPlayer(target);

	if (!player.bIsGuardbanned)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnUnBan);
	Call_PushCell(target);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action != Plugin_Continue)
		return;

	char ID[32], query[256];
	GetClientAuthId(target, AuthId_Steam2, ID, sizeof(ID));

	CShowActivityEx(admin, TAG, "Unguardbanned %N", target);

	Format(query, sizeof(query), 
			"DELETE FROM %s "
		...	"WHERE steamid = '%s';",
			strCoreTable, ID);

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("UnGuardBanning client %N. Query: %s", target, query);
	hTheDB.Query(CCB_UnGuardBan, query);

	Format(query, sizeof(query), 
			"UPDATE %s "
		... "SET timeleft = -1 "
		... "WHERE offender_steamid = '%s' "
		... "AND timeleft >= 0;",
			strLogTable, ID);

	player.bIsGuardbanned = false;
}

void GuardBan(int victim, int admin, int time, char reason[256] = "")
{
	if (!bEnabled.BoolValue)
		return;

	if (!victim || !IsClientInGame(victim))
		return;

	JailPlayer player = JailPlayer(victim);
	if (player.bIsGuardbanned)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnBan);
	Call_PushCell(victim);
	Call_PushCell(admin);
	Call_PushCellRef(time);
	Call_PushStringEx(reason, sizeof(reason), 0, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if (action == Plugin_Handled || action == Plugin_Stop)
		return;

	char ID[32], BanMsg[32];
	GetClientAuthId(victim, AuthId_Steam2, ID, sizeof(ID));

	if (!time)
		Format(BanMsg, sizeof(BanMsg), "permanently.");
	else Format(BanMsg, sizeof(BanMsg), "for %d minutes.", time);

	CShowActivityEx(admin, TAG, "Guardbanned %N", victim);

	char query[512];
	hTheDB.Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		...	"VALUES ('%s', %d) "
		... "ON DUPLICATE KEY "
		... "UPDATE ban_time = %d", 
			strCoreTable, ID, time, time);

	hTheDB.Query(CCB_Guardban, query);

	player.bIsGuardbanned = true;
	player.iTimeLeft = time;
	if (GetClientTeam(victim) == BLU)
	{
		if (JBGameMode_GetProperty("iRoundState") >= StateRunning)
		{
			ForcePlayerSuicide(victim);
			ChangeClientTeam(victim, RED);
		}
		else player.ForceTeamChange(RED);
	}

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("[JBANS] Querying client %N's ban with query: %s", victim, query);

	int timestamp = GetTime();
	char ID2[32];	if (admin) GetClientAuthId(admin, AuthId_Steam2, ID2, sizeof(ID2)); else ID2 = "Console";

	hTheDB.Format(query, sizeof(query),
			"INSERT INTO %s "
		... "(timestamp, offender_steamid, offender_name, admin_steamid, admin_name, bantime, timeleft, reason) "
		... "VALUES (%d, '%s', '%N', '%s', '%N', %d, %d, '%s')",
			strLogTable, timestamp, ID2, victim, ID2, admin, time, time, reason);

	hTheDB.Query(CCB_Guardban, query);
}

public void RageBanMenu(int client)
{
	if (!bEnabled.BoolValue)
		return;

	Menu rage = new Menu(RageMenu);
	rage.SetTitle("Rage Ban Menu");
	int len = hRageTableNames.Length;
	if (!len)
	{
		delete rage;
		CPrintToChat(client, TAG ... "No players found.");
		return;
	}
	else
	{
		char ID[32], name[32];
		for (int i = 0; i < len; i++)
		{
			hRageTable.GetString(i, ID, sizeof(ID));
			hRageTableNames.GetString(i, name, sizeof(name));
			rage.AddItem(ID, name);
		}
	}
	rage.ExitButton = true;
	rage.Display(client, -1);
}

public int RageMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char ID[32]; menu.GetItem(select, ID, sizeof(ID));
			OfflineBan(ID, client);
			CPrintToChat(client, TAG ... "Successfully Rage Banned player with Steam ID %s.", ID);
		}
		case MenuAction_End:delete menu;
	}
}

public void DisplayBannableMenu(const int client)
{
	Menu menu = new Menu(BanMenu);
	menu.SetTitle("Select a player to guardban");
	char name[32], ID[8];
	JailPlayer player;
	int i, count;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;

		if (i == client)
			continue;

		player = JailPlayer(i);
		if (player.bIsGuardbanned)
			continue;

		GetClientName(i, name, sizeof(name));
		IntToString(GetClientUserId(i), ID, sizeof(ID));
		menu.AddItem(ID, name);
		count++;
	}

	if (!count)
	{
		delete menu;
		CPrintToChat(client, TAG ... "No players found.");
		return;
	}
	menu.ExitButton = true;
	menu.Display(client, -1);
}

public int BanMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char ID[8]; menu.GetItem(select, ID, sizeof(ID));
			int banned = GetClientOfUserId(StringToInt(ID));
			if (!banned)
			{
				CPrintToChat(client, TAG ... "Client is no longer in-game.");
				return;
			}

			if (JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, TAG ... "Client is already guardbanned.");
				return;
			}

			Menu time = new Menu(BanTimeMenu);
			time.SetTitle("Select a time in minutes");
			time.AddItem(ID, "10");
			time.AddItem(ID, "30");
			time.AddItem(ID, "60");
			time.AddItem(ID, "120");
			time.AddItem(ID, "720");
			time.AddItem(ID, "1440");
			time.AddItem(ID, "0 - Permanent");
			time.Display(client, -1);
		}
		case MenuAction_End:delete menu;
	}
}

public int BanTimeMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char ID[8]; menu.GetItem(select, ID, sizeof(ID));
			int banned = GetClientOfUserId(StringToInt(ID));
			if (!banned)
			{
				CPrintToChat(client, TAG ... "Client is no longer in-game.");
				return;
			}

			if (JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, TAG ... "Client is already guardbanned.");
				return;
			}

			int time;
			switch (select)
			{
				case 0:time = 10;
				case 1:time = 30;
				case 2:time = 60;
				case 3:time = 120;
				case 4:time = 720;
				case 5:time = 1440;
				case 6:time = 0;
			}

			CPrintToChat(client, TAG ... "Successfully guardbanned client for %d minutes.", time);
			GuardBan(banned, client, time);
		}
	}
}

public void DisplayUnbannableMenu(const int client)
{
	Menu menu = new Menu(UnbanMenu);
	menu.SetTitle("Select a player to unguardban");

	char name[32], ID[8];
	JailPlayer player;
	int i, count;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;

		if (i == client)
			continue;

		player = JailPlayer(i);
		if (!player.bIsGuardbanned)
			continue;

		GetClientName(i, name, sizeof(name));
		IntToString(GetClientUserId(i), ID, sizeof(ID));
		menu.AddItem(ID, name);
		count++;
	}

	if (!count)
	{
		delete menu;
		CPrintToChat(client, TAG ... "No players found.");
		return;
	}

	menu.Display(client, -1);
}

public int UnbanMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char ID[32]; menu.GetItem(select, ID, sizeof(ID));
			int banned = GetClientOfUserId(StringToInt(ID));
			if (!banned)
			{
				CPrintToChat(client, TAG ... "Client is no longer in-game.");
				return;
			}

			if (!JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, TAG ... "Client is not guardbanned.");
				return;
			}

			UnGuardBan(banned, client);
		}
		case MenuAction_End:delete menu;
	}
}

public int DBCB_Connect(Database db, const char[] error, any data)
{
	if (!db)
	{
		LogError("[JBANS] Induction error: %s", error);
		return;
	}

	if (hTheDB)
	{
		delete db;
		return;
	}

	hTheDB = db;

	char prefix[16];
	cvarJBANS[Prefix].GetString(prefix, sizeof(prefix));
	if (prefix[0] != '\0')
		StrCat(prefix, 16, "_");

	Format(strCoreTable, sizeof(strCoreTable), "%stf2jr_guardbans", prefix);

	char query[512];
	Format(query, sizeof(query), 
			"CREATE TABLE IF NOT EXISTS %s "
		...	"(steamid VARCHAR(22), "
		...	"ban_time INT(16), "
		...	"PRIMARY KEY (steamid));", 
			strCoreTable);

	db.Query(DBCB_Initialization, query);	// I use 'initialize' too much

	// Let's keep webpanel compatibility shall we?
	Format(strLogTable, sizeof(strLogTable), "%stf2jr_guardbans_logs", prefix);

	Format(query, sizeof(query), 
			"CREATE TABLE IF NOT EXISTS %s "
		...	"(timestamp INT, "
		...	"offender_steamid VARCHAR(22), "
		... "offender_name VARCHAR(32), "
		... "admin_steamid VARCHAR(22), "
		... "admin_name VARCHAR(32), "
		... "bantime INT(16), "
		... "timeleft INT(16), "
		... "reason VARCHAR(200), "
		... "PRIMARY KEY (timestamp));", 
			strLogTable);

	db.Query(DBCB_Initialization, query);
}

public int DBCB_Initialization(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
	{
		LogError("[JBANS] Could not initialize core table: %s", error);
		SetFailState("[JBANS] Failed Database induction. Exiting...");
	}

	/**
	 *	Purpose: If the plugin is late loaded, database is nulled.
	 *	There needs to be an induction on each client, however.
	 *	This is the only reasonable place to put it I guess.
	*/
	if (bLate)
	{
		for (int i = MaxClients; i; --i)
			if (IsClientInGame(i))
				OnClientPostAdminCheck(i);
		bLate = false;
	}
}

public int CCB_Disconnect(Database db, DBResultSet results, const char[] error, DataPack pack)
{
	if (results)
	{
		pack.Reset();
		char ID[32]; pack.ReadString(ID, sizeof(ID));
		int timeleft = pack.ReadCell();

		if (results.RowCount)
		{
			char query[256];
			if (timeleft <= 0)
			{
				Format(query, sizeof(query), 
						"DELETE FROM %s "
					...	"WHERE steamid = '%s';",
						strCoreTable, ID);

				hTheDB.Query(DBCB_Disconnect, query);
			}
			else
			{
				Format(query, sizeof(query), 
						"UPDATE %s "
					...	"SET ban_time = %d "
					... "WHERE steamid = '%s';",
						strCoreTable, timeleft, ID);

				hTheDB.Query(DBCB_Disconnect, query);
			}
		}
	}
	else LogError("[JBANS] Error on client disconnect: %s", error);
	delete pack;
}

public int CCB_Induction(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if (!client || !IsClientInGame(client))
		return;

	if (results)
	{
		int rows = results.RowCount;
		if (cvarJBANS[Debug].BoolValue)
			LogMessage("[JBANS] Found client (%N) induction rowcount %d.", client, rows);
		
		JailPlayer player = JailPlayer(client);
		if (rows)
		{
			results.FetchRow();
			
			int time = results.FetchInt(0);
			if (cvarJBANS[Debug].BoolValue)
				LogMessage("[JBANS]: %N joined with %i time remaining on ban.", client, time);

			player.iTimeLeft = time;
			player.bIsGuardbanned = true;
		}
		else player.bIsGuardbanned = false;
	}
	else LogError("[JBANS] Database error on client (%N) induction: %s", client, error);
}

public int DBCB_Disconnect(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client disconnect: %s", error);
}

public int CCB_Guardban(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client Guardban: %s", error);
}

public int CCB_UnGuardBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client UnGuardBan: %s", error);
}

public int CCB_OfflineGuardBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on Offline GuardBan: %s", error);
}

public int CCB_OfflineUnGuardBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on Offline UnGuardBan: %s", error);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	hOnBan				= CreateGlobalForward("JB_OnBan", 			ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_String);
	hOnUnBan			= CreateGlobalForward("JB_OnUnBan", 		ET_Hook, Param_Cell, Param_Cell);
	hOnOfflineBan		= CreateGlobalForward("JB_OnOfflineBan", 	ET_Hook, Param_String, Param_Cell);
	hOnOfflineUnBan		= CreateGlobalForward("JB_OnOfflineUnBan", 	ET_Hook, Param_String, Param_Cell);

	CreateNative("JB_GuardBan", Native_GuardBan);
	CreateNative("JB_UnGuardBan", Native_UnGuardBan);
	CreateNative("JB_OfflineGuardBan", Native_OfflineGuardBan);
	CreateNative("JB_OfflineUnGuardBan", Native_OfflineUnGuardBan);

	CreateNative("JB_RageBanMenu", Native_RageBanMenu);
	CreateNative("JB_DisplayBanMenu", Native_DisplayBanMenu);
	CreateNative("JB_DisplayUnbanMenu", Native_DisplayUnbanMenu);

	CreateNative("JB_IsClientGuardbanned", Native_IsClientGuardbanned);

	RegPluginLibrary("TF2JailRedux_TeamBans");

	bLate = late;

	return APLRes_Success;
}

public int Native_GuardBan(Handle plugin, int numParams)
{
	char reason[256]; GetNativeString(4, reason, 256);
	GuardBan(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), reason);
}
public int Native_UnGuardBan(Handle plugin, int numParams)
{
	UnGuardBan(GetNativeCell(1), GetNativeCell(2));
}
public int Native_OfflineGuardBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineBan(ID, GetNativeCell(2));
}
public int Native_OfflineUnGuardBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineUnBan(ID, GetNativeCell(2));
}
public int Native_RageBanMenu(Handle plugin, int numParams)
{
	RageBanMenu(GetNativeCell(1));
}
public int Native_DisplayBanMenu(Handle plugin, int numParams)
{
	DisplayBannableMenu(GetNativeCell(1));
}
public int Native_DisplayUnbanMenu(Handle plugin, int numParams)
{
	DisplayUnbannableMenu(GetNativeCell(1));
}
public int Native_IsClientGuardbanned(Handle plugin, int numParams)
{
	return JailPlayer(GetNativeCell(1)).bIsGuardbanned;
}