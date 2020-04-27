#pragma semicolon 1

#include <morecolors>
#include <tf2jailredux_teambans>
#include <tf2jailredux>
#include <clientprefs>

#undef TAG
#define TAG "{crimson}[TF2Jail] Teambans{burlywood} "

#define PLUGIN_VERSION 		"1.0.4"
#define RED 				2
#define BLU 				3
#define IsClientValid(%1) 	((0 < %1 <= MaxClients) && IsClientInGame(%1))

#pragma newdecls required

public Plugin myinfo =
{
	name = "TF2Jail Redux TeamBans",
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
	bDisabled = true	// Grrrr
;

ConVar
	bEnabled,
	cvarJBANS[Version + 1]
;

char
	strCoreTable[32],
	strLogTable[64],
	strWardenTable[32]
;

Database
	hTheDB
;

GlobalForward
	hOnBan,
	hOnUnBan,
	hOnOfflineBan,
	hOnOfflineUnBan,
	hOnWardenBan,
	hOnWardenUnBan,
	hOnOfflineWardenBan,
	hOnOfflineWardenUnBan
;

methodmap JailPlayer < JBPlayer
{
	public JailPlayer( const int r )
	{
		return view_as< JailPlayer >(r);
	}

	public static JailPlayer OfUserId( const int id )
	{
		return view_as< JailPlayer >(GetClientOfUserId(id));
	}

	public static JailPlayer Of( const JBPlayer player )
	{
		return view_as< JailPlayer >(player);
	}

	property int iTimeLeft 
	{
		public get() 				{ return this.GetProp("iTimeLeft"); }
		public set( const int i ) 	{ this.SetProp("iTimeLeft", i); }
	}
	property int iWardenTimeLeft
	{
		public get() 				{ return this.GetProp("iWardenTimeLeft"); }
		public set( const int i ) 	{ this.SetProp("iWardenTimeLeft", i); }
	}

	property bool bIsGuardbanned
	{
		public get() 				{ return this.GetProp("bIsGuardbanned"); }
		public set( const bool i ) 	{ this.SetProp("bIsGuardbanned", i); }
	}
	property bool bIsWardenBanned
	{
		public get() 				{ return this.GetProp("bIsWardenBanned"); }
		public set( const bool i ) 	{ this.SetProp("bIsWardenBanned", i); }
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("tf2jail_redux.phrases");
	LoadTranslations("tf2jailredux_teambans.phrases");

	bEnabled 						= CreateConVar("sm_jbans_enable", "1", "Status of the plugin: (1 = on, 0 = off)", FCVAR_NOTIFY);
	cvarJBANS[Version] 				= CreateConVar("tf2jbans_version", PLUGIN_VERSION, "TF2Jail Redux GuardBans version. (DO NOT TOUCH)", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarJBANS[JoinMessage] 			= CreateConVar("sm_jbans_banmessage", "Please visit our website to appeal.", "Message to the client on join if banned.", FCVAR_NOTIFY);
	cvarJBANS[Prefix] 				= CreateConVar("sm_jbans_tableprefix", "", "Prefix for database tables. (Can be blank)", FCVAR_NOTIFY);
	cvarJBANS[SQLDriver] 			= CreateConVar("sm_jbans_sqldriver", "default", "Config entry to use for database.", FCVAR_NOTIFY);
	cvarJBANS[Debug] 				= CreateConVar("sm_jbans_debug", "0", "Enable console debugging for TF2Jail Redux GuardBans?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarJBANS[RageTableRefresh]		= CreateConVar("sm_jbans_ragetable_refresh", "2", "Refresh the Rage Ban menu every 'x' mapchanges.", FCVAR_NOTIFY, true, 1.0, true, 10.0);
	cvarJBANS[IgnoreMidRound]		= CreateConVar("sm_jbans_ignore_midround", "1", "If a guardbanned player spawns on Blue team in the middle of the round, ignore forcing them to Red team?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

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
	RegAdminCmd("sm_wb", Cmd_WardenBan, ADMFLAG_GENERIC, "Ban players from Warden.");
	RegAdminCmd("sm_wardenban", Cmd_WardenBan, ADMFLAG_GENERIC, "Ban players from Warden.");
	RegAdminCmd("sm_wub", Cmd_WardenUnBan, ADMFLAG_GENERIC, "Unban players from Warden.");
	RegAdminCmd("sm_wardenunban", Cmd_WardenUnBan, ADMFLAG_GENERIC, "Unban players from Warden.");
	RegAdminCmd("sm_wboff", Cmd_OfflineWardenBan, ADMFLAG_GENERIC, "Ban disconnected players from Warden via Steam ID.");
	RegAdminCmd("sm_wardenban_offline", Cmd_OfflineWardenBan, ADMFLAG_GENERIC, "Ban disconnected players from Warden via Steam ID.");
	RegAdminCmd("sm_wuboff", Cmd_OfflineWardenUnBan, ADMFLAG_GENERIC, "Unban disconnected players from Warden via Steam ID.");
	RegAdminCmd("sm_wardenunban_offline", Cmd_OfflineWardenUnBan, ADMFLAG_GENERIC, "Unban disconnected players from Warden via Steam ID.");

	AutoExecConfig(true, "TF2JailRedux_TeamBans");

	hRageTable  	= new ArrayList(ByteCountToCells(22));
	hRageTableNames = new ArrayList(ByteCountToCells(22));

	iTableDelete = 0;
}

public void InitSubPlugin()
{
	JB_Hook(OnPlayerSpawned, fwdOnPlayerSpawn);
	JB_Hook(OnWardenGet, fwdOnWardenGet);
}

/**
 *	Purpose: Disable the plugin if TF2Jail Redux is unloaded.
 *	This is simpler than unloading the plugin during this time.
*/
public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true))
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
	if (!strcmp(name, "TF2Jail_Redux", true))
	{
		if (bDisabled)
		{
			bEnabled.SetBool(true);
			InitSubPlugin();
		}
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
	FormatEx(query, sizeof(query), 
			"SELECT ban_time "
		...	"FROM %s "
		...	"WHERE steamid = '%s';",
			strCoreTable, ID);

	hTheDB.Query(CCB_Induction, query, GetClientUserId(client));

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("Querying client %N connection with query %s", client, query);

	ReplaceStringEx(query, sizeof(query), strCoreTable, strWardenTable);
	hTheDB.Query(CCB_Induction_Warden, query, GetClientUserId(client));
}

public void fwdOnPlayerSpawn(const JBPlayer Player, Event event)
{
	if (!bEnabled.BoolValue)
		return;
	if (IsFakeClient(Player.index))
		return;
	if (GetClientTeam(Player.index) != BLU)
		return;

	bool running = JBGameMode_GetProp("iRoundState") == StateRunning;
	if (cvarJBANS[IgnoreMidRound].BoolValue && running)
		return;

	JailPlayer base = JailPlayer.Of(Player);

	if (!base.bIsGuardbanned)
		return;

	char BanMsg[128]; cvarJBANS[JoinMessage].GetString(BanMsg, sizeof(BanMsg));	
	PrintCenterText(base.index, "%t", "Guardbanned Center");
	CPrintToChat(base.index, "%t %s", "Plugin Tag Teambans", BanMsg);
	base.ForceTeamChange(RED, !running);
}

public Action fwdOnWardenGet(const JBPlayer Player)
{
	JailPlayer player = JailPlayer.Of(Player);
	if (!player.bIsWardenBanned)
		return Plugin_Continue;

	char BanMsg[128]; cvarJBANS[JoinMessage].GetString(BanMsg, sizeof(BanMsg));	
	PrintCenterText(player.index, "%t", "Wardenbanned Center");
	CPrintToChat(player.index, "%t %s", "Plugin Tag Teambans", BanMsg);
	return Plugin_Handled;
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

	if (!player.bIsGuardbanned)
	{
		char name[32];
		GetClientName(client, name, sizeof(name));

		hRageTable.PushString(ID);
		hRageTableNames.PushString(name);
	}
	else
	{
		char query[256];
		FormatEx(query, sizeof(query), 
			"SELECT ban_time"
		...	" FROM %s"
		...	" WHERE steamid = '%s';",
			strCoreTable, ID);

		DataPack pack = new DataPack();
		pack.WriteString(ID);
		pack.WriteCell(player.iTimeLeft);

		if (cvarJBANS[Debug].BoolValue)
			LogMessage("Checking out client %N with query %s", client, query);

		hTheDB.Query(CCB_Disconnect, query, pack);
	}

	if (player.bIsWardenBanned)
	{
		char query[256];
		FormatEx(query, sizeof(query), 
			"SELECT ban_time"
		...	" FROM %s"
		...	" WHERE steamid = '%s';",
			strWardenTable, ID);

		DataPack pack = new DataPack();
		pack.WriteString(ID);
		pack.WriteCell(player.iWardenTimeLeft);

		if (cvarJBANS[Debug].BoolValue)
			LogMessage("Checking out client %N with query %s", client, query);

		hTheDB.Query(CCB_Disconnect_Warden, query, pack);
	}

	player.iTimeLeft = 0;
	player.iWardenTimeLeft = 0;
	player.bIsGuardbanned = false;
	player.bIsWardenBanned = false;
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
		if (player.iTimeLeft && player.bIsGuardbanned)
			if (--player.iTimeLeft <= 0)
				UnGuardBan(i, 0);

		if (player.iWardenTimeLeft && player.bIsWardenBanned)
			if (--player.iWardenTimeLeft <= 0)
				UnWardenBan(i, 0);
	}
	return Plugin_Continue;
}

public Action Cmd_UnGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
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
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
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
			CReplyToCommand(client, "%t %t ", "Plugin Tag Teambans", "Already Guardbanned", target_list[0]);
		else
		{
			char reason[256];
			for (int i = 3; i <= args; i++)
			{
				GetCmdArg(i, s, sizeof(s));
				Format(reason, sizeof(reason), "%s %s", reason, s);
			}
			GuardBan(target_list[0], client, time, reason);
		}
	}
	else CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Unable to target");
	return Plugin_Handled;
}

public Action Cmd_IsBanned(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (args != 1)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cmd Usage IsBanned");
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
			if (player.iTimeLeft <= 0)
				CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Is Guardbanned permanently", target_list[0]);
			else CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Is Guardbanned Time Left", target_list[0], player.iTimeLeft);
		else CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Is Not Guardbanned", target_list[0]);
	}
	else CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Unable to Target");
	return Plugin_Handled;
}

public Action Cmd_OfflineUnGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cmd Usage OfflineUnguardban");
		return Plugin_Handled;
	}

	char ID[32]; GetCmdArgString(ID, sizeof(ID));
	OfflineUnBan(ID, client);
	CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Offline Unguardban", ID);

	return Plugin_Handled;
}

public Action Cmd_OfflineGuardBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cmd Usage OfflineGuardban");
		return Plugin_Handled;
	}

	char ID[32]; GetCmdArgString( ID, sizeof(ID));

	OfflineBan(ID, client);
	CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Offline Guardban", ID);

	return Plugin_Handled;
}

public Action Cmd_RageBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (!client)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Command is in-game only");
		return Plugin_Handled;
	}

	RageBanMenu(client);
	return Plugin_Handled;
}

public Action Cmd_WardenUnBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
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
	else UnWardenBan(target_list[0], client);

	return Plugin_Handled;
}

public Action Cmd_WardenBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Not Enabled");
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
		if (JailPlayer(target_list[0]).bIsWardenBanned)
			CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Already Wardenbanned", target_list[0]);
		else WardenBan(target_list[0], client, time);
	else CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cannot target bot");
	return Plugin_Handled;
}

public Action Cmd_OfflineWardenUnBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cmd Usage OfflineUnwardenban");
		return Plugin_Handled;
	}

	char ID[32]; GetCmdArgString(ID, sizeof(ID));
	OfflineUnWardenBan(ID, client);
	CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Offline Unwardenban", ID);

	return Plugin_Handled;
}

public Action Cmd_OfflineWardenBan(int client, int args)
{
	if (!bEnabled.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Not Enabled");
		return Plugin_Handled;
	}

	if (!args)
	{
		CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Cmd Usage OfflineWardenban");
		return Plugin_Handled;
	}

	char ID[32]; GetCmdArgString( ID, sizeof(ID));

	OfflineWardenBan(ID, client);
	CReplyToCommand(client, "%t %t", "Plugin Tag Teambans", "Offline Wardenban", ID);

	return Plugin_Handled;
}

public void OfflineBan(const char[] ID, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnOfflineBan);
	Call_PushString(ID);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action == Plugin_Handled || action == Plugin_Stop)	// Allow returning Plugin_Changed
		return;

	char query[512];

	// KILL ME
	Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		... "VALUES ('%s', 0) "
		... "ON DUPLICATE KEY "
		... "UPDATE ban_time = 0;",
			strCoreTable, ID);

	hTheDB.Query(CCB_OfflineGuardBan, query);

	int timestamp = GetTime();
	char ID2[32]; 
	if (admin) GetClientAuthId(admin, AuthId_Steam2, ID2, sizeof(ID2)); else ID2 = "Console";

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

	player.bIsGuardbanned = false;
	player.iTimeLeft = 0;

	char idk[64]; FormatEx(idk, sizeof(idk), "%t", "Plugin Tag Teambans");
	if (!admin)
		CPrintToChatAll("%t Console: %t", "Plugin Tag Teambans", "Unguardban", target);
	else CShowActivity2(admin, idk, " %t", "Unguardban", target);

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

	char ID[32], idk[64];
	GetClientAuthId(victim, AuthId_Steam2, ID, sizeof(ID));
	FormatEx(idk, sizeof(idk), "%t", "Plugin Tag Teambans");

	if (!time)
		CShowActivity2(admin, idk, " %t", "Guardban Permanent", victim);
	else CShowActivity2(admin, idk, " %t", "Guardban Timed", victim, time);

	player.bIsGuardbanned = true;
	player.iTimeLeft = time;

	char query[512];
	hTheDB.Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		...	"VALUES ('%s', %d) "
		... "ON DUPLICATE KEY "
		... "UPDATE ban_time = %d", 
			strCoreTable, ID, time, time);

	hTheDB.Query(CCB_GuardBan, query);

	if (GetClientTeam(victim) == BLU)
	{
		if (JBGameMode_GetProp("iRoundState") >= StateRunning)
		{
			ForcePlayerSuicide(victim);
			ChangeClientTeam(victim, RED);
		}
		else player.ForceTeamChange(RED);
	}

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("[JBANS] Querying client %N's ban with query: %s", victim, query);

	int timestamp = GetTime();
	char ID2[32]; if (admin) GetClientAuthId(admin, AuthId_Steam2, ID2, sizeof(ID2)); else ID2 = "Console";

	hTheDB.Format(query, sizeof(query),
			"INSERT INTO %s "
		... "(timestamp, offender_steamid, offender_name, admin_steamid, admin_name, bantime, timeleft, reason) "
		... "VALUES (%d, '%s', '%N', '%s', '%N', %d, %d, '%s')",
			strLogTable, timestamp, ID2, victim, ID2, admin, time, time, reason);

	hTheDB.Query(CCB_GuardBan, query);
}

public void UnWardenBan(int target, int admin)
{
	if (!target || !IsClientInGame(target))
		return;

	JailPlayer player = JailPlayer(target);
	if (!player.bIsWardenBanned)
	{
		CReplyToCommand(admin, "%t %t", "Plugin Tag Teambans", "Not Wardenbanned");
		return;
	}

	Action action = Plugin_Continue;
	Call_StartForward(hOnWardenUnBan);
	Call_PushCell(target);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action == Plugin_Handled || action == Plugin_Stop)
		return;

	player.bIsWardenBanned = false;
	player.iWardenTimeLeft = 0;

	char ID[32], idk[64], query[256];
	GetClientAuthId(target, AuthId_Steam2, ID, sizeof(ID));
	FormatEx(idk, sizeof(idk), "%t", "Plugin Tag Teambans");

	CShowActivity2(admin, idk, " %t", "Unwardenban", target);

	Format(query, sizeof(query), 
			"DELETE FROM %s "
		...	"WHERE steamid = '%s';",
			strWardenTable, ID);

	if (cvarJBANS[Debug].BoolValue)
		LogMessage("Unwardenbanning client %N. Query: %s", target, query);
	hTheDB.Query(CCB_UnWardenBan, query);
}

public void WardenBan(int victim, int admin, int time)
{
	if (!bEnabled.BoolValue)
		return;

	if (!victim || !IsClientInGame(victim))
		return;

	JailPlayer player = JailPlayer(victim);
	if (player.bIsWardenBanned)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnWardenBan);
	Call_PushCell(victim);
	Call_PushCell(admin);
	Call_PushCellRef(time);
	Call_Finish(action);
	if (action == Plugin_Handled || action == Plugin_Stop)
		return;

	char ID[32], idk[64];
	GetClientAuthId(victim, AuthId_Steam2, ID, sizeof(ID));
	FormatEx(idk, sizeof(idk), "%t", "Plugin Tag Teambans");

	if (!time)
		CShowActivity2(admin, idk, " %t", "Wardenban Permanent", victim);
	else CShowActivity2(admin, idk, " %t", "Wardenban Timed", victim, time);

	if (player.bIsWarden)
		JBGameMode_FireWarden(false);	// Curse you gamemode properties!

	player.bIsWardenBanned = true;
	player.iWardenTimeLeft = time;

	char query[512];
	hTheDB.Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		...	"VALUES ('%s', %d) "
		... "ON DUPLICATE KEY "
		... "UPDATE ban_time = %d", 
			strWardenTable, ID, time, time);

	hTheDB.Query(CCB_WardenBan, query);
}

public void OfflineUnWardenBan(const char[] ID, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnOfflineWardenUnBan);
	Call_PushString(ID);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action != Plugin_Continue)
		return;

	char query[256];
	Format(query, sizeof(query), 
			"DELETE FROM %s "
		...	"WHERE steamid = '%s';",
			strWardenTable, ID);

	hTheDB.Query(CCB_OfflineUnWardenBan, query);
}

public void OfflineWardenBan(const char[] ID, int admin)
{
	if (!bEnabled.BoolValue)
		return;

	Action action = Plugin_Continue;
	Call_StartForward(hOnOfflineWardenBan);
	Call_PushString(ID);
	Call_PushCell(admin);
	Call_Finish(action);
	if (action >= Plugin_Handled)	// Allow returning Plugin_Changed
		return;

	char query[512];

	// KILL ME
	Format(query, sizeof(query), 
			"INSERT INTO %s "
		...	"(steamid, ban_time) "
		... "VALUES ('%s', 0) "
		... "ON DUPLICATE KEY "
		... "UPDATE ban_time = 0;",
			strWardenTable, ID);

	hTheDB.Query(CCB_OfflineWardenBan, query);
}

public void RageBanMenu(int client)
{
	if (!bEnabled.BoolValue)
		return;

	Menu rage = new Menu(RageMenu);
	char s[16];

	FormatEx(s, sizeof(s), "%t", "Rage Ban Menu");
	rage.SetTitle(s);
	int len = hRageTableNames.Length;

	if (!len)
	{
		delete rage;
		CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "No matching clients");
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
			CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Rageban", ID);
		}
		case MenuAction_End:delete menu;
	}
}

public void DisplayBannableMenu(const int client)
{
	Menu menu = new Menu(BanMenu);

	char name[32], ID[8];
	JailPlayer player;
	int i, count;

	FormatEx(name, sizeof(name), "%t", "Ban Menu");

	menu.SetTitle(name);
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
		CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "No matching clients");
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
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Player no longer available");
				return;
			}

			if (JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Already Guardbanned");
				return;
			}

			Menu time = new Menu(BanTimeMenu);
			char s[32]; FormatEx(s, sizeof(s), "%t", "Select Time");
			time.SetTitle(s);
			time.AddItem(ID, "10");
			time.AddItem(ID, "30");
			time.AddItem(ID, "60");
			time.AddItem(ID, "120");
			time.AddItem(ID, "720");
			time.AddItem(ID, "1440");
			time.AddItem(ID, "0");
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
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Player no longer available");
				return;
			}

			if (JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Already Guardbanned");
				return;
			}

			// TODO: Make this translation-determinant
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

			GuardBan(banned, client, time);
		}
	}
}

public void DisplayUnbannableMenu(const int client)
{
	Menu menu = new Menu(UnbanMenu);

	char name[32], ID[8];
	JailPlayer player;
	int i, count;

	FormatEx(name, sizeof(name), "%t", "Unban Menu");
	menu.SetTitle(name);
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
		CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "No matching clients");
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
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Player no longer available");
				return;
			}

			if (!JailPlayer(banned).bIsGuardbanned)
			{
				CPrintToChat(client, "%t %t", "Plugin Tag Teambans", "Not Guardbanned");
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

	Transaction txn = new Transaction();

	FormatEx(strCoreTable, sizeof(strCoreTable), "%stf2jr_guardbans", prefix);

	char query[512];
	Format(query, sizeof(query), 
			"CREATE TABLE IF NOT EXISTS %s "
		...	"(steamid VARCHAR(22), "
		...	"ban_time INT(16), "
		...	"PRIMARY KEY (steamid));", 
			strCoreTable);

	txn.AddQuery(query);

	FormatEx(strWardenTable, sizeof(strWardenTable), "%stf2jr_wardenbans", prefix);
	ReplaceStringEx(query, sizeof(query), strCoreTable, strWardenTable);

	txn.AddQuery(query);

	// Let's keep webpanel compatibility shall we?
	// Because I know one exists... somewhere...
	FormatEx(strLogTable, sizeof(strLogTable), "%stf2jr_guardbans_logs", prefix);

	FormatEx(query, sizeof(query), 
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

	txn.AddQuery(query);

	hTheDB.Execute(txn, TXN_OnSuccess, TXN_OnFailure);
}

public void TXN_OnSuccess(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	if (cvarJBANS[Debug].BoolValue)
		LogMessage("[JBANS] Successfully created and executed transaction with %d queries.", numQueries);

	/**
	 *	Purpose: If the plugin is late loaded, database is nulled.
	 *	There needs to be an induction on each client, however.
	 *	This is the only reasonable place to put it I guess.
	*/
	if (bLate)
	{
		for (int i = MaxClients; i; --i)
			if (IsClientInGame(i) && IsClientAuthorized(i))
				OnClientPostAdminCheck(i);
		bLate = false;
	}
}

public void TXN_OnFailure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[JBANS] Could not initialize core tables. Index %d: %s", failIndex, error);
	SetFailState("[JBANS] Failed Database induction. Exiting...");
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

			FormatEx(query, sizeof(query), 
					"UPDATE %s "
				...	"SET ban_time = %d "
				... "WHERE steamid = '%s';",
					strCoreTable, timeleft, ID);

			hTheDB.Query(DBCB_Disconnect, query);

			FormatEx(query, sizeof(query), 
				"UPDATE %s "
			... "SET timeleft = %d "
			... "WHERE offender_steamid = '%s' "
			... "AND timeleft >= 0;",
				strLogTable, timeleft, ID);

			hTheDB.Query(DBCB_Disconnect, query);
		}
	}
	else LogError("[JBANS] Error on client disconnect: %s", error);
	delete pack;
}

public int CCB_Disconnect_Warden(Database db, DBResultSet results, const char[] error, DataPack pack)
{
	if (results)
	{
		pack.Reset();
		char ID[32]; pack.ReadString(ID, sizeof(ID));
		int timeleft = pack.ReadCell();

		if (results.RowCount)
		{
			char query[256];

			FormatEx(query, sizeof(query), 
					"UPDATE %s "
				...	"SET ban_time = %d "
				... "WHERE steamid = '%s';",
					strWardenTable, timeleft, ID);

			hTheDB.Query(DBCB_Disconnect, query);
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

public int CCB_Induction_Warden(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if (!client || !IsClientInGame(client))
		return;

	if (results)
	{
		int rows = results.RowCount;
		if (cvarJBANS[Debug].BoolValue)
			LogMessage("[JBANS] Found client (%N) warden induction rowcount %d.", client, rows);

		JailPlayer player = JailPlayer(client);
		if (rows)
		{
			results.FetchRow();

			int time = results.FetchInt(0);
			if (cvarJBANS[Debug].BoolValue)
				LogMessage("[JBANS]: %N joined with %i time remaining on wardenban.", client, time);

			player.iWardenTimeLeft = time;
			player.bIsWardenBanned = true;
		}
		else player.bIsWardenBanned = false;
	}
	else LogError("[JBANS] Database error on client (%N) warden induction: %s", client, error);
}

public int DBCB_Disconnect(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client disconnect: %s", error);
}

public int CCB_GuardBan(Database db, DBResultSet results, const char[] error, any data)
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

public int CCB_UnWardenBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client UnWardenBan: %s", error);
}

public int CCB_WardenBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on client WardenBan: %s", error);
}

public int CCB_OfflineUnWardenBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on Offline UnWardenBan: %s", error);
}

public int CCB_OfflineWardenBan(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[JBANS] Database error on Offline WardenBan: %s", error);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	hOnBan					= CreateGlobalForward("JB_OnBan", 					ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_String);
	hOnUnBan				= CreateGlobalForward("JB_OnUnBan", 				ET_Hook, Param_Cell, Param_Cell);
	hOnOfflineBan			= CreateGlobalForward("JB_OnOfflineBan", 			ET_Hook, Param_String, Param_Cell);
	hOnOfflineUnBan			= CreateGlobalForward("JB_OnOfflineUnBan", 			ET_Hook, Param_String, Param_Cell);

	hOnWardenBan			= CreateGlobalForward("JB_OnWardenBan", 			ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
	hOnWardenUnBan			= CreateGlobalForward("JB_OnWardenUnBan", 			ET_Hook, Param_Cell, Param_Cell);
	hOnOfflineWardenBan		= CreateGlobalForward("JB_OnOfflineWardenBan", 		ET_Hook, Param_String, Param_Cell);
	hOnOfflineWardenUnBan	= CreateGlobalForward("JB_OnOfflineWardenUnBan", 	ET_Hook, Param_String, Param_Cell);

	CreateNative("JB_GuardBan", Native_GuardBan);
	CreateNative("JB_UnGuardBan", Native_UnGuardBan);
	CreateNative("JB_OfflineGuardBan", Native_OfflineGuardBan);
	CreateNative("JB_OfflineUnGuardBan", Native_OfflineUnGuardBan);

	CreateNative("JB_RageBanMenu", Native_RageBanMenu);
	CreateNative("JB_DisplayBanMenu", Native_DisplayBanMenu);
	CreateNative("JB_DisplayUnbanMenu", Native_DisplayUnbanMenu);

	CreateNative("JB_WardenBan", Native_WardenBan);
	CreateNative("JB_UnWardenBan", Native_UnWardenBan);
	CreateNative("JB_OfflineWardenBan", Native_OfflineWardenBan);
	CreateNative("JB_OfflineUnWardenBan", Native_OfflineUnWardenBan);

	RegPluginLibrary("TF2JailRedux_TeamBans");

	bLate = late;

	return APLRes_Success;
}

public any Native_GuardBan(Handle plugin, int numParams)
{
	char reason[256]; GetNativeString(4, reason, 256);
	GuardBan(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), reason);
}
public any Native_UnGuardBan(Handle plugin, int numParams)
{
	UnGuardBan(GetNativeCell(1), GetNativeCell(2));
}
public any Native_OfflineGuardBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineBan(ID, GetNativeCell(2));
}
public any Native_OfflineUnGuardBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineUnBan(ID, GetNativeCell(2));
}
public any Native_RageBanMenu(Handle plugin, int numParams)
{
	RageBanMenu(GetNativeCell(1));
}
public any Native_DisplayBanMenu(Handle plugin, int numParams)
{
	DisplayBannableMenu(GetNativeCell(1));
}
public any Native_DisplayUnbanMenu(Handle plugin, int numParams)
{
	DisplayUnbannableMenu(GetNativeCell(1));
}

public any Native_WardenBan(Handle plugin, int numParams)
{
	WardenBan(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}
public any Native_UnWardenBan(Handle plugin, int numParams)
{
	UnWardenBan(GetNativeCell(1), GetNativeCell(2));
}
public any Native_OfflineWardenBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineWardenBan(ID, GetNativeCell(2));
}
public any Native_OfflineUnWardenBan(Handle plugin, int numParams)
{
	char ID[32]; GetNativeString(1, ID, sizeof(ID));
	OfflineUnWardenBan(ID, GetNativeCell(2));
}