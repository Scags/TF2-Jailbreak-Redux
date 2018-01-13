/**
 *	Hello person who will be reading this some time in the future, and welcome to TF2Jail Redux!	*
 *	Here is the summary and organization of the associated files within it 							*
 **	TF2Jail_Redux.sp: Contains the core functions of the plugin, along with forwards 			   **
 **	jailbase.sp: Player methodmap properties plus a few handy variables 						   **
 **	jailgamemode.sp: Gamemode methodmap properties that control gameplay functionality			   **
 **	jailevents.sp: Events of the plugin that are organized and managed by...					   **
 **	jailhandler.sp: Logic of gamemode behavior under any circumstances, functions called from core **
 **	jailcommands.sp: Commands and some of the menus corresponding to commands 					   **
 **	stocks.inc: Stock functions used or could possibly be used within plugin 					   **
 **	jailforwards.sp: Contains external gamemode third-party functionality, leave it alone 		   **
 ** tf2jailredux.inc: External gamemode third-party functionality, leave it alone 				   **
 *	If you're here to give some more uniqueness to the plugin, check jailhandler 	 				*
 *	It's fixed with a variety of not only last request examples, but gameplay event management.		*
 *	VSH is a subplugin, if there is an issues with it, simply delete it and edit jailhandler		*
 **/

#define PLUGIN_NAME			"[TF2] Jailbreak Redux"
#define PLUGIN_VERSION		"0.10.8"
#define PLUGIN_AUTHOR		"Ragenewb/Scag, props to Keith (Drixevel) and Nergal/Assyrian"
#define PLUGIN_DESCRIPTION	"Deluxe version of TF2Jail"

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2items_giveweapon>
#include <morecolors>
#include <smlib/clients>	// I have a phobia of unnecessarily large plugins
#include <tf2attributes>
#include <tf2jailredux>

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#undef REQUIRE_PLUGIN
#tryinclude <sourcebans>
#tryinclude <sourcecomms>
#tryinclude <basecomm>
#tryinclude <clientprefs>
#define REQUIRE_PLUGIN

#pragma semicolon 			1
#pragma newdecls 			required

#define PLYR				MAXPLAYERS+1 
#define toggle(%1)			(%1) = !(%1)
#define UNASSIGNED 			0
#define NEUTRAL 			0
#define SPEC 				1
#define RED 				2
#define BLU 				3
#define nullvec				NULL_VECTOR
#define FULLTIMER			TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE
#define LR_DEFAULT 			5

enum	// Cvar name
{
	Balance = 0,
	BalanceRatio,
	DoorOpenTimer,
	FreedayLimit,
	KillPointServerCommand,
	RemoveFreedayOnLR,
	RemoveFreedayOnLastGuard,
	WardenTimer,
	RoundTimerStatus,
	RoundTime,
	RoundTime_Freeday,
	RebelAmmo,
	DroppedWeapons,
	VentHit,
	SeeNames,
	NameDistance,
	SeeHealth,
	EnableMusic,
	MusicVolume,
	EurekaTimer,
	CritFallOff,
	VIPFlag,
	AdmFlag,
	Version
};

ConVar
bEnabled = null
;

// If adding new cvars put them above Version in the enum
ConVar cvarTF2Jail[Version + 1];

Handle hEngineConVars[2],
	   hTextNodes[4],
	   AimHud,
	   MusicCookie
	   ;

char sCellNames[32],
	 sCellOpener[32],
	 sFFButton[32]
	 ;

char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear" };

float flFreedayPosition[3], 
	  flWardayBlu[3], 
	  flWardayRed[3]
	  ;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = ""
};

ArrayList g_hPluginsRegistered;

#include "TF2JailRedux/stocks.inc"
#include "TF2JailRedux/jailhandler.sp"
#include "TF2JailRedux/jailforwards.sp"
#include "TF2JailRedux/jailevents.sp"
#include "TF2JailRedux/jailcommands.sp"

public void OnPluginStart()
{
	gamemode = JailGameMode();
	gamemode.Init();
	
	InitializeForwards();	// Forwards

	bEnabled = CreateConVar("sm_tf2jr_enable", "1", "Status of the plugin: (1 = on, 0 = off)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Version] = CreateConVar("tf2jr_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
	cvarTF2Jail[Balance] = CreateConVar("sm_tf2jr_auto_balance", "1", "Should the plugin autobalance teams?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[BalanceRatio] = CreateConVar("sm_tf2jr_balance_ratio", "0.5", "Ratio for autobalance: (Example: 0.5 = 2:4)", FCVAR_NOTIFY, true, 0.1, true, 1.0);
	cvarTF2Jail[DoorOpenTimer] = CreateConVar("sm_tf2jr_cell_timer", "60", "Time after Arena round start to open doors.", FCVAR_NOTIFY, true, 0.0, true, 120.0);
	cvarTF2Jail[FreedayLimit] = CreateConVar("sm_tf2jr_freeday_limit", "3", "Max number of freedays for the lr.", FCVAR_NOTIFY, true, 1.0, true, 16.0);
	cvarTF2Jail[KillPointServerCommand] = CreateConVar("sm_tf2jr_point_servercommand", "1", "Kill 'point_servercommand' entities.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLR] = CreateConVar("sm_tf2jr_freeday_removeonlr", "1", "Remove Freedays on Last Request.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLastGuard] = CreateConVar("sm_tf2jr_freeday_removeonlastguard", "1", "Remove Freedays on Last Guard.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenTimer] = CreateConVar("sm_tf2jr_warden_timer", "20", "Time in seconds after Warden is unset or lost to lock Warden.", FCVAR_NOTIFY);
	cvarTF2Jail[RoundTimerStatus] = CreateConVar("sm_tf2jr_roundtimer_status", "1", "Status of the round timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RoundTime] = CreateConVar("sm_tf2jr_roundtimer_time", "600", "Amount of time normally on the timer (if enabled).", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RoundTime_Freeday] = CreateConVar("sm_tf2jr_roundtimer_time_freeday", "300", "Amount of time on 1st day freeday.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RebelAmmo] = CreateConVar("sm_tf2jr_red_ammo", "1", "Should freedays be removed upon a freeday player's collection of ammo?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[DroppedWeapons] = CreateConVar("sm_tf2jr_dropped_weapons", "1", "Should players be allowed to pick up dropped weapons?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[VentHit] = CreateConVar("sm_tf2jr_vent_freeday", "1", "Should freeday players lose their freeday if they hit/break a vent?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[SeeNames] = CreateConVar("sm_tf2jr_wardensee", "1", "Allow the Warden to see prisoner names?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NameDistance] = CreateConVar("sm_tf2jr_wardensee_distance", "200", "From how far can the Warden see prisoner names? (Hammer Units)", FCVAR_NOTIFY, true, 0.0, true, 500.0);
	cvarTF2Jail[SeeHealth] = CreateConVar("sm_tf2jr_wardensee_health", "1", "Can the Warden see prisoner health?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EnableMusic] = CreateConVar("sm_tf2jr_music_on", "1", "Enable background music that could possibly play with last requests?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[MusicVolume] = CreateConVar("sm_tf2jr_music_volume", ".5", "Volume in which background music plays. (If enabled)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EurekaTimer] = CreateConVar("sm_tf2jr_eureka_teleport", "20", "How long must players wait until they are able to Eureka Effect Teleport again?", FCVAR_NOTIFY, true, 0.0, true, 60.0);
	cvarTF2Jail[CritFallOff] = CreateConVar("sm_tf2jr_crit_falloff", "1", "Should guard criticals receive damage falloff? (Similar to Ambassador's weapon stat)", FCVAR_NOTIFY, true, 1.0, true, 0.0);
	cvarTF2Jail[VIPFlag] = CreateConVar("sm_tf2jr_vip_flag", "r", "What admin flag do VIP players fall under?", FCVAR_NOTIFY);
	cvarTF2Jail[AdmFlag] = CreateConVar("sm_tf2jr_admin_flag", "b", "What admin flag do admins fall under?", FCVAR_NOTIFY);

	AutoExecConfig(true, "TF2JailRedux");

		/* Used in core*/
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("arena_round_start", OnArenaRoundStart);
	HookEvent("teamplay_round_win", OnRoundEnd);
	//HookEvent("player_shield_blocked", RazorBackStab);	// SDKHooks grabs this anyways
	HookEvent("post_inventory_application", OnRegeneration);
	HookEvent("player_changeclass", OnChangeClass, EventHookMode_Pre);
	//HookEvent("player_team", OnChangeTeam, EventHookMode_Post);
		/* Kinda used in core but not really */
	HookEvent("rocket_jump", OnHookedEvent);
	HookEvent("rocket_jump_landed", OnHookedEvent);
	HookEvent("sticky_jump", OnHookedEvent);
	HookEvent("sticky_jump_landed", OnHookedEvent);
		/* Not used in core */
	HookEvent("object_deflected", ObjectDeflected);	// Literally only using these for the VSH subplugin
	HookEvent("object_destroyed", ObjectDestroyed, EventHookMode_Pre);
	HookEvent("player_jarated", PlayerJarated);
	HookEvent("player_chargedeployed", UberDeployed);

	AddCommandListener(EurekaTele, "eureka_teleport");

	RegConsoleCmd("sm_jhelp", Command_Help, "Display a menu containing the major commands");
	RegConsoleCmd("sm_jailhelp", Command_Help, "Display a menu containing the major commands");
	RegConsoleCmd("sm_w", Command_BecomeWarden, "Become the Warden.");
	RegConsoleCmd("sm_warden", Command_BecomeWarden, "Become the Warden.");
	RegConsoleCmd("sm_uw", Command_ExitWarden, "Remove yourself from Warden.");
	RegConsoleCmd("sm_unwarden", Command_ExitWarden, "Remove yourself from Warden.");
	RegConsoleCmd("sm_wm", Command_WardenMenu, "Call the Warden Menu if you're Warden.");
	RegConsoleCmd("sm_wmenu", Command_WardenMenu, "Call the Warden Menu if you're Warden.");
	RegConsoleCmd("sm_wardenmenu", Command_WardenMenu, "Call the Warden Menu if you're Warden.");
	RegConsoleCmd("sm_open", Command_OpenCells, "Open the cell doors.");
	RegConsoleCmd("sm_close", Command_CloseCells, "Close the cell doors.");
	RegConsoleCmd("sm_wcc", Command_WardenCC, "Warden toggling of collisions.");
	RegConsoleCmd("sm_wff", Command_WardenFF, "Warden toggling of Friendly-Fire.");
	RegConsoleCmd("sm_glr", Command_GiveLastRequest, "Give a last request to a Prisoner as Warden.");
	RegConsoleCmd("sm_givelr", Command_GiveLastRequest, "Give a last request to a Prisoner as Warden.");
	RegConsoleCmd("sm_givelastrequest", Command_GiveLastRequest, "Give a last request to a Prisoner as Warden.");
	RegConsoleCmd("sm_rlr", Command_RemoveLastRequest, "Remove a last request from a Prisoner as Warden.");
	RegConsoleCmd("sm_removelr", Command_RemoveLastRequest, "Remove a last request from a Prisoner as Warden.");
	RegConsoleCmd("sm_removelastrequest", Command_RemoveLastRequest, "Remove a last request from a Prisoner as Warden.");
	RegConsoleCmd("sm_listlr", Command_ListLastRequests, "Display a list of last requests available.");
	RegConsoleCmd("sm_lrlist", Command_ListLastRequests, "Display a list of last requests available.");
	RegConsoleCmd("sm_lrslist", Command_ListLastRequests, "Display a list of last requests available.");
	RegConsoleCmd("sm_lrs", Command_ListLastRequests, "Display a list of last requests available.");
	RegConsoleCmd("sm_lastrequestlist", Command_ListLastRequests, "Display a list of last requests available.");
	RegConsoleCmd("sm_cw", Command_CurrentWarden, "Display the name of the current Warden.");
	RegConsoleCmd("sm_currentwarden", Command_CurrentWarden, "Display the name of the current Warden.");
	RegConsoleCmd("sm_jbmusic", Command_MusicOff, "Client cookie that disables LR background music (if it exists)");

	RegAdminCmd("sm_rw", AdminRemoveWarden, ADMFLAG_GENERIC, "Remove the currently active Warden.");
	RegAdminCmd("sm_removewarden", AdminRemoveWarden, ADMFLAG_GENERIC, "Remove the currently active Warden.");
	RegAdminCmd("sm_dlr", AdminDenyLR, ADMFLAG_GENERIC, "Deny any currently queued last requests.");
	RegAdminCmd("sm_denylr", AdminDenyLR, ADMFLAG_GENERIC, "Deny any currently queued last requests.");
	RegAdminCmd("sm_denylastrequest", AdminDenyLR, ADMFLAG_GENERIC, "Deny any currently queued last requests.");
	RegAdminCmd("sm_oc", AdminOpenCells, ADMFLAG_GENERIC, "Open the cell doors if closed.");
	RegAdminCmd("sm_opencells", AdminOpenCells, ADMFLAG_GENERIC, "Open the cell doors if closed.");
	RegAdminCmd("sm_cc", AdminCloseCells, ADMFLAG_GENERIC, "Close the cell doors if open.");
	RegAdminCmd("sm_closecells", AdminCloseCells, ADMFLAG_GENERIC, "Close the cell doors if open.");
	RegAdminCmd("sm_lc", AdminLockCells, ADMFLAG_GENERIC, "Lock the cell doors if unlocked.");
	RegAdminCmd("sm_lockcells", AdminLockCells, ADMFLAG_GENERIC, "Lock the cell doors if unlocked.");
	RegAdminCmd("sm_ulc", AdminUnlockCells, ADMFLAG_GENERIC, "Unlock the cell doors if locked.");
	RegAdminCmd("sm_unlockcells", AdminUnlockCells, ADMFLAG_GENERIC, "Unlock the cell doors if locked.");
	RegAdminCmd("sm_fw", AdminForceWarden, ADMFLAG_GENERIC, "Force a client to become Warden.");
	RegAdminCmd("sm_forcewarden", AdminForceWarden, ADMFLAG_GENERIC, "Force a client to become Warden.");
	RegAdminCmd("sm_flr", AdminForceLR, ADMFLAG_GENERIC, "Force a last request to become queued for the administrator.");
	RegAdminCmd("sm_forcelr", AdminForceLR, ADMFLAG_GENERIC, "Force a last request to become queued for the administrator.");
	RegAdminCmd("sm_compatible", AdminMapCompatibilityCheck, ADMFLAG_GENERIC, "Check if the current map is compatible with the plug-in.");
	RegAdminCmd("sm_gf", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Free day.");
	RegAdminCmd("sm_givefreeday", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Free day.");
	RegAdminCmd("sm_rf", AdminRemoveFreeday, ADMFLAG_GENERIC, "Remove a client's Free day status if they have one.");
	RegAdminCmd("sm_removefreeday", AdminRemoveFreeday, ADMFLAG_GENERIC, "Remove a client's Free day status if they have one.");
	RegAdminCmd("sm_lw", AdminLockWarden, ADMFLAG_GENERIC, "Lock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_lockwarden", AdminLockWarden, ADMFLAG_GENERIC, "Lock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_ulw", AdminUnlockWarden, ADMFLAG_GENERIC, "Unlock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_unlockwarden", AdminUnlockWarden, ADMFLAG_GENERIC, "Unlock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_wardayred", AdminWardayRed, ADMFLAG_GENERIC, "Teleport all prisoners to their warday teleport location.");
	RegAdminCmd("sm_wardayblue", AdminWardayBlue, ADMFLAG_GENERIC, "Teleport all guards to their warday teleport location.");
	RegAdminCmd("sm_startwarday", FullWarday, ADMFLAG_GENERIC, "Teleport all players to their warday teleport location.");

	RegAdminCmd("sm_setpreset", SetPreset, ADMFLAG_ROOT, "Set gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_itype", Type, ADMFLAG_ROOT, "gamemode.iLRType. (DEBUGGING)");
	RegAdminCmd("sm_ipreset", Preset, ADMFLAG_ROOT, "gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_jailreset", AdminResetPlugin, ADMFLAG_ROOT, "Reset all plug-in global variables. (DEBUGGING)");

	hEngineConVars[0] = FindConVar("mp_friendlyfire");
	hEngineConVars[1] = FindConVar("tf_avoidteammates_pushaway");

	for (int i = 0; i < sizeof(hTextNodes); i++)
		hTextNodes[i] = CreateHudSynchronizer();
		
	AimHud = CreateHudSynchronizer();

	AddMultiTargetFilter("@warden", WardenGroup, "The Warden.", false);
	AddMultiTargetFilter("@freedays", FreedaysGroup, "All Freedays.", false);
	AddMultiTargetFilter("@!warden", WardenGroup, "All but the Warden.", false);

	/*int ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_ammopack_full")) != -1)
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerTouch, true);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_ammopack_medium")) != -1)
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerTouch, true);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_ammopack_small")) != -1)
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerTouch, true);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_ammo_pack")) != -1)
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerTouch, true);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_breakable")) != -1)
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnBreak", VentTouch, true);
	}*/
	
	AddNormalSoundHook(SoundHook);

	MusicCookie = RegClientCookie("sm_tf2jr_music", "Determines if client wishes to listen to background music played by the plugin/LRs", CookieAccess_Protected);

	for (int i = MaxClients; i; --i) 
	{
		if (!IsValidClient(i))
			continue;
		OnClientPutInServer(i);
	}

	hJailFields[0] = new StringMap();
	g_hPluginsRegistered = new ArrayList();
}

public bool WardenGroup(const char[] pattern, Handle clients)
{
	bool non = StrContains(pattern, "!", false) != - 1;
	for (int i = MaxClients; i; i--) 
	{
		if (IsClientValid(i) && FindValueInArray(clients, i) == - 1)
		{
			if (bEnabled.BoolValue && JailFighter(i).bIsWarden) {
				if (!non)
					PushArrayCell(clients, i);
			}
			else if (non)
				PushArrayCell(clients, i);
		}
	}
	return true;
}

public bool FreedaysGroup(const char[] pattern, Handle clients)
{
	for (int i = MaxClients; i; --i)
	{
		if (IsClientValid(i) && FindValueInArray(clients, i) == -1)
		{
			if (bEnabled.BoolValue && JailFighter(i).bIsFreeday)
				PushArrayCell(clients, i);
		}
	}
	return true;
}

public void OnAllPluginsLoaded()
{
	#if defined _steamtools_included
	gamemode.bSteam = LibraryExists("SteamTools");
	#endif
	#if defined _sourcebans_included
	gamemode.bSB = LibraryExists("sourcebans");
	#endif
	#if defined _sourcecomms_included
	gamemode.bSC = LibraryExists("sourcecomms");
	#endif
	#if defined _voiceannounce_ex_included
	gamemode.bVA = LibraryExists("voiceannounce_ex");
	#endif
	gamemode.bTF2Attribs = LibraryExists("tf2attributes");
}

public void OnLibraryAdded(const char[] name)
{
	#if defined _steamtools_included
	if (!strcmp(name, "SteamTools", false))
		gamemode.bSteam = true;
	#endif
	#if defined _sourcebans_included
	if (!strcmp(name, "sourcebans", false))
		gamemode.bSB = true;
	#endif
	#if defined _sourcecomms_included
	if (!strcmp(name, "sourcecomms", false))
		gamemode.bSC = true;
	#endif
	#if defined _voiceannounce_ex_included
	if (!strcmp(name, "voiceannounce_ex", false))
		gamemode.bVA = true;
	#endif
	if (!strcmp(name, "tf2attributes", false))
		gamemode.bTF2Attribs = true;
}

public void OnLibraryRemoved(const char[] name)
{
	#if defined _steamtools_included
	if (!strcmp(name, "SteamTools", false))
		gamemode.bSteam = false;
	#endif
	#if defined _sourcebans_included
	if (!strcmp(name, "sourcebans", false))
		gamemode.bSB = false;
	#endif
	#if defined _sourcecomms_included
	if (!strcmp(name, "sourcecomms", false))
		gamemode.bSC = false;
	#endif
	#if defined _voiceannounce_ex_included
	if (!strcmp(name, "voiceannounce_ex", false))
		gamemode.bVA = false;
	#endif
	if (!strcmp(name, "tf2attributes", false))
		gamemode.bTF2Attribs = false;
}

public void OnPluginEnd()
{
	// Execute all OnMapEnd functionality whenever the plugin ends.
	OnMapEnd();
}

public void OnConfigsExecuted()
{
	if (!bEnabled.BoolValue)
		return;

	ConvarsSet(true);

	ParseConfigs(); // Parse all configuration files under 'addons/sourcemod/configs/tf2jail/...'.

	#if defined _steamtools_included
	if (gamemode.bSteam) 
	{
		char sDescription[64];
		Format(sDescription, sizeof(sDescription), "%s v%s", PLUGIN_NAME, PLUGIN_VERSION);
		Steam_SetGameDescription(sDescription);
	}
	#endif
}

public void OnMapStart()
{
	if (!bEnabled.BoolValue)
		return;
		
	CreateTimer(0.3, Timer_AimName, _, FULLTIMER);
	CreateTimer(0.1, Timer_PlayerThink, _, FULLTIMER);
		
	gamemode.b1stRoundFreeday = true;
		
	LRMapStartVariables(); // Handler
	ManageDownloads();	// Handler
}

public void OnMapEnd()
{
	if (!bEnabled.BoolValue)
		return;

	gamemode.Init();

	FindConVar("sv_gravity").SetInt(800);	// For admins like sans who force change the map during the low gravity LR
	ConvarsSet(false);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	//SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
	SDKHook(client, SDKHook_Touch, OnTouch);
	//SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	//SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
		
	if (hJailFields[client] != null)
		delete hJailFields[client];
	
	hJailFields[client] = new StringMap();
	JailFighter player = JailFighter(client);
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

public void OnClientPostAdminCheck(int client)
{	// Gotta make sure
	if (!bEnabled.BoolValue)
		return;

	char strVIP[4]; cvarTF2Jail[VIPFlag].GetString(strVIP, sizeof(strVIP));
	char strAdmin[4]; cvarTF2Jail[AdmFlag].GetString(strAdmin, sizeof(strAdmin));
	JailFighter player = JailFighter(client);

	SetPawnTimer(WelcomeMessage, 5.0, player.userid);

	if (IsValidAdmin(player.index, strVIP)) // Very useful stock ^^
		player.bIsVIP = true;
	else player.bIsVIP = false;

	if (IsValidAdmin(player.index, strAdmin))
		player.bIsAdmin = true;
	else { player.bIsAdmin = false; player.MutePlayer(); }
}

public Action OnTouch(int toucher, int touchee)
{
	if (IsClientValid(touchee) && IsClientValid(toucher)) 
	{
		JailFighter player = JailFighter(toucher);
		JailFighter victim = JailFighter(touchee);
		
		if (TF2_GetClientTeam(player.index) == TFTeam_Red)
			ManageRedTouchBlue(player, victim);	// Handler
	}
	return Plugin_Continue;
}

public Action Timer_PlayerThink(Handle hTimer)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return Plugin_Continue;
		
	for (int i = MaxClients; i; --i) {
		if (!IsValidClient(i, false) || !IsPlayerAlive(i))
			continue;
		JailFighter player = JailFighter(i);
		if (TF2_GetClientTeam(player.index) == TFTeam_Blue)
			ManageAllBlueThink(player);
		else if (TF2_GetClientTeam(player.index) == TFTeam_Blue && !player.bIsWarden)
			ManageBlueNotWardenThink(player);
		else if (TF2_GetClientTeam(player.index) == TFTeam_Red)
			ManageRedThink(player);
		else if (TF2_GetClientTeam(player.index) == TFTeam_Blue && player.bIsWarden)
			ManageWardenThink(player);
		/* Overcomplicated I know, but gives lrs every possible think aspect */
	}
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (!bEnabled.BoolValue || !IsClientValid(client))
		return;

	JailFighter player = JailFighter(client);
	
	player.Init_JB();
	ManageClientDisconnect(player);	// Handler
}

public void ConvarsSet(bool Status)
{
	if (Status)
	{
		FindConVar("mp_stalemate_enable").SetInt(0);
		FindConVar("tf_arena_use_queue").SetInt(0);
		FindConVar("mp_teams_unbalance_limit").SetInt(0);
		FindConVar("mp_autoteambalance").SetInt(0);
		FindConVar("tf_arena_first_blood").SetInt(0);
		FindConVar("mp_scrambleteams_auto").SetInt(0);
		FindConVar("phys_pushscale").SetInt(1000);
	}
	else
	{
		FindConVar("mp_stalemate_enable").SetInt(1);
		FindConVar("tf_arena_use_queue").SetInt(1);
		FindConVar("mp_teams_unbalance_limit").SetInt(1);
		FindConVar("mp_autoteambalance").SetInt(1);
		FindConVar("tf_arena_first_blood").SetInt(1);
		FindConVar("mp_scrambleteams_auto").SetInt(1);
	}
}

/*public Action OnPlayerTouch(const char[] name, int touchee, int toucher, float delay)
{	// Works 9/10 times, better than nothing
	if (!bEnabled.BoolValue || !cvarTF2Jail[RebelAmmo].BoolValue)
		return Plugin_Continue;
		
	JailFighter player = JailFighter(toucher);
	if (IsClientValid(player.index) && IsPlayerAlive(player.index) && player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%N has taken ammo and lost their freeday!", player.index);
	}
	return Plugin_Continue;
}

public Action VentTouch(const char[] name, int toucher, int func, float delay)
{	// Does this even work?
	if (!bEnabled.BoolValue || !cvarTF2Jail[VentHit].BoolValue)
		return Plugin_Continue;
		
	JailFighter touch = JailFighter(toucher);
	if (IsClientValid(touch.index) && IsPlayerAlive(touch.index) && touch.bIsFreeday && IsValidEntity(func))
	{
		touch.RemoveFreeday();
		PrintCenterTextAll("%N has broken a vent and lost their freeday!", touch.index);
	}
	return Plugin_Continue;
}*/

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!bEnabled.BoolValue || !IsClientValid(victim) || !IsClientValid(attacker))
		return Plugin_Continue;

	JailFighter vict = JailFighter(victim);
	return ManageOnTakeDamage(vict, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	//return Plugin_Continue;
}

public Action OnEntTouch(int toucher, int touchee)
{
	if (!cvarTF2Jail[RebelAmmo].BoolValue || !IsClientValid(toucher))
		return Plugin_Continue;

	JailFighter player = JailFighter(toucher);
	if (player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%N has taken ammo and lost their freeday!", toucher);
	}
	return Plugin_Continue;
}

public Action OnEntTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!cvarTF2Jail[VentHit].BoolValue || !IsClientValid(attacker))
		return Plugin_Continue;

	JailFighter player = JailFighter(attacker);
	if (player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%N has broken a vent and lost their freeday!", attacker);
	}
	return Plugin_Continue;
}

public Action EurekaTele(int client, const char[] strCommand, int args)
{
	if (!bEnabled.BoolValue || !IsClientValid(client))
		return Plugin_Continue;

	JailFighter player = JailFighter(client);
	
	if (player.bUnableToTeleport)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} You can't teleport yet!");
		return Plugin_Handled;
	}

	player.bUnableToTeleport = true;
	SetPawnTimer(EnableEureka, cvarTF2Jail[EurekaTimer].FloatValue, player.userid);
	return Plugin_Continue;
}

public void ParseConfigs()
{
	ParseMapConfig();
	ParseNodeConfig();
}

public void ParseMapConfig()
{
	KeyValues key = new KeyValues("TF2Jail_MapConfig");

	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, sizeof(sConfig), "configs/tf2jail/mapconfig.cfg");

	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (key.ImportFromFile(sConfig))
	{
		if (key.JumpToKey(sMapName))
		{
			char CellNames[32], CellsButton[32], ffButton[32];

			key.GetString("CellNames", CellNames, sizeof(CellNames));
			if (strlen(CellNames) != 0)
			{
				int iCelldoors = Entity_FindByName(CellNames, "func_door");
				if (IsValidEntity(iCelldoors))
				{
					sCellNames = CellNames;
					gamemode.bIsMapCompatible = true;
				}
				else gamemode.bIsMapCompatible = false;
			}
			else gamemode.bIsMapCompatible = false;

			key.GetString("CellsButton", CellsButton, sizeof(CellsButton));
			if (strlen(CellsButton) != 0)
			{
				int iCellOpener = Entity_FindByName(CellsButton, "func_button");
				if (IsValidEntity(iCellOpener))
					sCellOpener = CellsButton;
			}
			key.GetString("FFButton", ffButton, sizeof(ffButton));
			if (strlen(ffButton) != 0)
			{
				int iFFButton = Entity_FindByName(ffButton, "func_button");
				if (IsValidEntity(iFFButton))
					sCellOpener = ffButton;
			}

			if (key.JumpToKey("Freeday"))
			{
				if (key.JumpToKey("Teleport"))
				{
					gamemode.bFreedayTeleportSet = view_as<bool>(key.GetNum("Status", 1));

					if (gamemode.bFreedayTeleportSet)
					{
						flFreedayPosition[0] = key.GetFloat("Coordinate_X");
						flFreedayPosition[1] = key.GetFloat("Coordinate_Y");
						flFreedayPosition[2] = key.GetFloat("Coordinate_Z");
					}

					key.GoBack();
				}
				else gamemode.bFreedayTeleportSet = false;
				key.GoBack();
			}
			else gamemode.bFreedayTeleportSet = false;
			
			if (key.JumpToKey("Warday - Guards"))
			{
				if (key.JumpToKey("Teleport"))
				{
					gamemode.bWardayTeleportSetBlue = view_as<bool>(key.GetNum("Status", 1));

					if (gamemode.bWardayTeleportSetBlue)
					{
						flWardayBlu[0] = key.GetFloat("Coordinate_X");
						flWardayBlu[1] = key.GetFloat("Coordinate_Y");
						flWardayBlu[2] = key.GetFloat("Coordinate_Z");
					}
					key.GoBack();
				}
				else gamemode.bWardayTeleportSetBlue = false;
				key.GoBack();
			}
			else gamemode.bWardayTeleportSetBlue = false;
			
			if (key.JumpToKey("Warday - Reds"))
			{
				if (key.JumpToKey("Teleport"))
				{
					gamemode.bWardayTeleportSetRed = view_as<bool>(key.GetNum("Status", 1));

					if (gamemode.bWardayTeleportSetRed)
					{
						flWardayRed[0] = key.GetFloat("Coordinate_X");
						flWardayRed[1] = key.GetFloat("Coordinate_Y");
						flWardayRed[2] = key.GetFloat("Coordinate_Z");
					}
					key.GoBack();
				}
				else gamemode.bWardayTeleportSetRed = false;
				key.GoBack();
			}
			else gamemode.bWardayTeleportSetRed = false;
		}
		else
		{
			gamemode.bIsMapCompatible = false;
			gamemode.bFreedayTeleportSet = false;
			gamemode.bWardayTeleportSetBlue = false;
			gamemode.bWardayTeleportSetRed = false;
			LogError("~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");
			LogAction(0, -1, "~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");
		}
	}
	else
	{
		gamemode.bIsMapCompatible = false;
		gamemode.bFreedayTeleportSet = false;
		gamemode.bWardayTeleportSetBlue = false;
		gamemode.bWardayTeleportSetRed = false;
		LogError("~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");
		LogAction(0, -1, "~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");
	}
	delete key;
}

public void ParseNodeConfig()
{
	KeyValues key = new KeyValues("TF2Jail_Nodes");

	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, sizeof(sConfig), "configs/tf2jail/textnodes.cfg");

	if (key.ImportFromFile(sConfig))
	{
		if (key.GotoFirstSubKey(false))
		{
			int count = 0;
			do
			{
				EnumTNPS[count][fCoord_X] = key.GetFloat("Coord_X", -1.0);
				EnumTNPS[count][fCoord_Y] = key.GetFloat("Coord_Y", -1.0);
				EnumTNPS[count][fHoldTime] = key.GetFloat("HoldTime", 5.0);
				key.GetColor("Color", EnumTNPS[count][iRed], EnumTNPS[count][iGreen], EnumTNPS[count][iBlue], EnumTNPS[count][iAlpha]);
				EnumTNPS[count][iEffect] = key.GetNum("Effect", 0);
				EnumTNPS[count][fFXTime] = key.GetFloat("fxTime", 6.0);
				EnumTNPS[count][fFadeIn] = key.GetFloat("FadeIn", 0.1);
				EnumTNPS[count][fFadeOut] = key.GetFloat("FadeOut", 0.2);

				count++;
			} while (key.GotoNextKey(false));
		}
	}
	delete key;
}

public bool AlreadyMuted(const int client)
{
	switch (gamemode.bSC)
	{
		case true:return view_as<bool>(SourceComms_GetClientMuteType(client) != bNot);
		case false:return view_as<bool>(BaseComm_IsClientMuted(client));
	}
	return false;
}

public void EnableEureka(const int userid)
{
	JailFighter player = JailFighter(GetClientOfUserId(userid));
	player.bUnableToTeleport = false;
}

public void WelcomeMessage(const int userid)
{
	int client = GetClientOfUserId(userid);
	CPrintToChat(client, "{red}[JailRedux]{tan} Welcome to TF2 Jailbreak Redux. Type \"!jhelp\" for help.");
}

public void ResetDamage()
{
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientValid(i))
			continue;
		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
	}
}

public Action Timer_AimName(Handle hTimer)
{
	if (!bEnabled.BoolValue || !cvarTF2Jail[SeeNames].BoolValue)
		return Plugin_Stop;
	
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientValid(i) || !IsPlayerAlive(i))
			continue;
		JailFighter player = JailFighter(i);
		int target = GetClientAimTarget(player.index, true);
		
		if (!IsClientValid(target))
			return Plugin_Continue;
			
		if (GetClientTeam(player.index) == GetClientTeam(target))
			return Plugin_Continue;
		
		float flCpos[3], flTpos[3];
		GetClientEyePosition(player.index, flCpos);
		GetClientEyePosition(target, flTpos);
		
		if (CanSeeTarget(player.index, flCpos, target, flTpos, cvarTF2Jail[NameDistance].FloatValue) && player.bIsWarden)
		{
			if (TF2_IsPlayerInCondition(target, TFCond_Cloaked) // Cloak watches are removed but meh
				|| TF2_IsPlayerInCondition(target, TFCond_DeadRingered)
				|| TF2_IsPlayerInCondition(target, TFCond_Disguised))
				return Plugin_Continue;

			SetHudTextParams(-1.0, 0.59, 0.4, 255, 100, 255, 255, 1);
			if (cvarTF2Jail[SeeHealth].BoolValue)
				ShowSyncHudText(player.index, AimHud, "%N [%d]", target, GetClientHealth(target));
			else ShowSyncHudText(player.index, AimHud, "%N", target);
		}
	}
	return Plugin_Continue;
}

public int FindWarden()
{
	if (gamemode.bWardenExists)
	{
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientValid(i))
				continue;
			if (!JailFighter(i).bIsWarden)
				continue;
			return i;
		}
	}
	return 0;
}

public void KillThatBitch(const int client)
{
	EmitSoundToAll(SuicideSound);
	ForcePlayerSuicide(client);
	if (IsPlayerAlive(client))	// In case their kartified or something idk
		SDKHooks_TakeDamage(client, 0, 0, 9001.0, DMG_DIRECT, _, _, _);
}

public void ManageHealth(const int client)
{	// Idk why but health refused to set straight from start
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	SetEntProp(client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth"));
}

public void UnHorsemannify(const JailFighter player)
{
	if (IsClientValid(player.index))
		player.UnHorsemann();
}

public void RandSniper(const int iTimer)
{
	if (iTimer != gamemode.iRoundCount)
		return;
		
	int rand = Client_GetRandom(CLIENTFILTER_ALIVE | CLIENTFILTER_NOBOTS);

	ForcePlayerSuicide(rand);
	EmitSoundToAll(SuicideSound);
	if (IsPlayerAlive(rand))
		SDKHooks_TakeDamage(rand, 0, 0, 9001.0, DMG_DIRECT, _, _, _);
	
	SetPawnTimer(RandSniper, GetRandomFloat(30.0, 60.0), gamemode.iRoundCount);
}

public void EndRandSniper(const int iTimer)
{
	if (iTimer != gamemode.iRoundCount)
		return;

	int rand = Client_GetRandom(CLIENTFILTER_ALIVE | CLIENTFILTER_NOBOTS);

	ForcePlayerSuicide(rand);
	EmitSoundToAll(SuicideSound);
	if (IsPlayerAlive(rand))
		SDKHooks_TakeDamage(rand, 0, 0, 9001.0, DMG_DIRECT, _, _, _);
	
	SetPawnTimer(EndRandSniper, GetRandomFloat(0.1, 0.3), gamemode.iRoundCount);
}

public void ResetModelProps(const int client)
{
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
	SetEntPropFloat(client, Prop_Send, "m_flHeadScale", 1.0);
	SetEntPropFloat(client, Prop_Send, "m_flTorsoScale", 1.0);
	SetEntPropFloat(client, Prop_Send, "m_flHandScale", 1.0);
}

public void Regen(const int client)
{
	TF2_RegeneratePlayer(client);
}

public void DisableWarden(const int iTimer)
{
	if (iTimer != gamemode.iRoundCount 
		|| gamemode.iRoundState != StateRunning 
		|| gamemode.bWardenExists 
		|| gamemode.bIsWardenLocked)
		return;

	CPrintToChatAll("{red}[JailRedux]{tan} Warden has been locked due to lack of warden.");
	gamemode.DoorHandler(OPEN);
	gamemode.bIsWardenLocked = true;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!bEnabled.BoolValue)
		return;
	
	ManageEntityCreated(entity, classname);
}

public void RemoveEnt(any data)
{
	int ent = EntRefToEntIndex(data);
	if (IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
}

public void _MusicPlay()
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return;
	
	float currtime = GetGameTime();
	if (!cvarTF2Jail[EnableMusic].BoolValue || gamemode.flMusicTime > currtime)
		return;
	
	char sound[PLATFORM_MAX_PATH] = "";
	float time = -1.0;
	
	ManageMusic(sound, time);
	
	float vol = cvarTF2Jail[MusicVolume].FloatValue;
	if (sound[0] != '\0') 
	{
		strcopy(BackgroundSong, PLATFORM_MAX_PATH, sound);
		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientValid(i))
				continue;
			JailFighter player = JailFighter(i);
			if (player.bNoMusic)
				continue;

			EmitSoundToClient(i, sound, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, nullvec, nullvec, false, 0.0);
		}
	}
	if (time != - 1.0)
		gamemode.flMusicTime = currtime + time;
}

public void StopBackGroundMusic()
{
	for (int i = MaxClients; i; --i) 
	{
		if (!IsClientValid(i))
			continue;

		StopSound(i, SNDCHAN_AUTO, BackgroundSong);
	}
}

public bool CheckSet(const int client, const int iLRCount, const int iMax)
{
	JailFighter player = JailFighter(client);
	if (iLRCount >= iMax)
	{
		CPrintToChat(client, "{red}[JailRedux]{tan} This LR has been picked the maximum amount of times for this map.");
		player.ListLRS();
		//ListLastRequests(client);
		return false;
	}
	return true;
}


public Action Timer_Round(Handle timer)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateEnding)
		return Plugin_Stop;

	int time = gamemode.iTimeLeft;
	gamemode.iTimeLeft--;
	char strTime[6];
	
	if (time / 60 > 9)
		IntToString(time / 60, strTime, 6);
	else Format(strTime, 6, "0%i", time / 60);
	
	if (time % 60 > 9)
		Format(strTime, 6, "%s:%i", strTime, time % 60);
	else Format(strTime, 6, "%s:0%i", strTime, time % 60);

	SetTextNode(hTextNodes[3], strTime, EnumTNPS[3][fCoord_X], EnumTNPS[3][fCoord_Y], EnumTNPS[3][fHoldTime], EnumTNPS[3][iRed], EnumTNPS[3][iGreen], EnumTNPS[3][iBlue], EnumTNPS[3][iAlpha], EnumTNPS[3][iEffect], EnumTNPS[3][fFXTime], EnumTNPS[3][fFadeIn], EnumTNPS[3][fFadeOut]);

	switch (time) 
	{
		case 60:EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30:EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10:EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5: 
		{
			char sound[PLATFORM_MAX_PATH];
			Format(sound, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		case 0:
		{
			ForceTeamWin(BLU);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action UnmuteReds(Handle hTimer)
{
	for (int i = MaxClients; i; --i)
	{
		if (IsClientValid(i) && TF2_GetClientTeam(i) == TFTeam_Red)
			JailFighter(i).UnmutePlayer();
		PrintToConsole(i, "[JailRedux] Red team has been unmuted.");
	}
}

public void Open_Doors(const int iTimer)
{
	if (gamemode.bCellsOpened || iTimer != gamemode.iRoundCount || gamemode.iRoundState != StateRunning || gamemode.bFirstDoorOpening)
		return;

	gamemode.DoorHandler(OPEN);
	int time = cvarTF2Jail[DoorOpenTimer].IntValue;
	CPrintToChatAll("{red}[JailRedux]{tan} The cell doors have opened after %i seconds of remaining closed.", time);
	gamemode.bCellsOpened = true;
}

public void EnableFFTimer(const int iTimer)
{
	if (GetConVarBool(hEngineConVars[0]) == true || iTimer != gamemode.iRoundCount || gamemode.iRoundState != StateRunning)
		return;
		
	SetConVarBool(hEngineConVars[0], true);
	CPrintToChatAll("{red}[JailRedux]{tan} Friendly-Fire has been enabled!");
}

public void FreeKillSystem(const JailFighter attacker)
{	// Ghetto rigged freekill system, gives the info needed for sourcebans
	if (gamemode.iRoundState != StateRunning || gamemode.iLRType == 19)
		return;
	float curtime = GetGameTime();
	if ( curtime <= attacker.flKillSpree && TF2_GetClientTeam(attacker.index) == TFTeam_Blue )
		attacker.iKillCount++;
	else attacker.iKillCount = 0;
	
	char strIP[32], strID[32];
	
	if (attacker.iKillCount == 3)
	{
		GetClientIP(attacker.index, strIP, sizeof(strIP));
		//GetClientAuthId(attacker.index, AuthId_Steam2, strID, sizeof(strID));
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientValid(i))
				continue;
				
			JailFighter player = JailFighter(i);
			if (player.bIsAdmin)
				PrintToConsole(i, "**********\n%L\nIP:%s\n**********", attacker.index, strID, strIP);
		}
		attacker.iKillCount = 0;
	}
	else attacker.flKillSpree = curtime + 10;
}

// Props to Nergal!!!
stock Handle FindPluginByName(const char name[64]) // Searches in linear time or O(n) but it only searches when TF2Jail's plugin's loaded
{
	char dictVal[64];
	Handle thisPlugin;
	StringMap pluginMap;
	int arraylen = g_hPluginsRegistered.Length;
	for (int i = 0; i < arraylen; ++i) 
	{
		pluginMap = g_hPluginsRegistered.Get(i);
		if (pluginMap.GetString("PluginName", dictVal, 64))
		{
			if (!strcmp(name, dictVal, false)) 
			{
				pluginMap.GetValue("PluginHandle", thisPlugin);
				return thisPlugin;
			}
		}
	}
	return null;
}

stock Handle GetPluginByIndex(const int index)
{
	Handle thisPlugin;
	StringMap pluginMap = g_hPluginsRegistered.Get(index);
	if (pluginMap.GetValue("PluginHandle", thisPlugin))
		return thisPlugin;
	return null;
}

public int RegisterPlugin(const Handle pluginhndl, const char modulename[64])
{
	if (!ValidateName(modulename)) {
		LogError("TF2Jail :: Register Plugin  **** Invalid Name For Plugin Registration ****");
		return -1;
	}
	else if (FindPluginByName(modulename) != null) {
		LogError("TF2Jail :: Register Plugin  **** Plugin Already Registered ****");
		return -1;
	}
	
	// Create dictionary to hold necessary data about plugin
	StringMap PluginMap = new StringMap();
	PluginMap.SetValue("PluginHandle", pluginhndl);
	PluginMap.SetString("PluginName", modulename);
	
	// Push to global vector
	g_hPluginsRegistered.Push(PluginMap);
	
	return g_hPluginsRegistered.Length - 1; // Return the index of registered plugin!
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
		/* Functional */
	CreateNative("TF2JailRedux_RegisterPlugin", Native_RegisterPlugin);
	CreateNative("JB_Hook", Native_Hook);
	CreateNative("JB_HookEx", Native_HookEx);
	CreateNative("JB_Unhook", Native_Unhook);
	CreateNative("JB_UnhookEx", Native_UnhookEx);
		/* Player */
	CreateNative("JBPlayer.JBPlayer", Native_JBInstance);
	CreateNative("JBPlayer.userid.get", Native_JBGetUserid);
	CreateNative("JBPlayer.index.get", Native_JBGetIndex);
	CreateNative("JBPlayer.GetProperty", Native_JB_getProperty);
	CreateNative("JBPlayer.SetProperty", Native_JB_setProperty);
	CreateNative("JBPlayer.SpawnWeapon", Native_JB_SpawnWep);
	CreateNative("JBPlayer.ForceTeamChange", Native_JB_ForceTeamChange);
	CreateNative("JBPlayer.TeleportToPosition", Native_JB_TeleportToPosition);
	CreateNative("JBPlayer.ListLRS", Native_JB_ListLRS);
	CreateNative("JBPlayer.PreEquip", Native_JB_PreEquip);
	CreateNative("JBPlayer.WardenSet", Native_JB_WardenSet);
	CreateNative("JBPlayer.WardenUnset", Native_JB_WardenUnset);
	CreateNative("JBPlayer.MakeHorsemann", Native_JB_MakeHorsemann);
	CreateNative("JBPlayer.MutePlayer", Native_JB_MutePlayer);
	CreateNative("JBPlayer.UnmutePlayer", Native_JB_UnmutePlayer);
	CreateNative("JBPlayer.EmptyWeaponSlots", Native_JB_EmptyWeaponSlots);
	CreateNative("JBPlayer.StripToMelee", Native_JB_StripToMelee);
	CreateNative("JBPlayer.GiveFreeday", Native_JB_GiveFreeday);
	CreateNative("JBPlayer.RemoveFreeday", Native_JB_RemoveFreeday);
	CreateNative("JBPlayer.SpawnSmallHealthPack", Native_JB_SpawnSmallHealthPack);
	CreateNative("JBPlayer.TeleToSpawn", Native_JB_TeleToSpawn);
	CreateNative("JBPlayer.SetCliptable", Native_JB_SetCliptable);
	CreateNative("JBPlayer.SetAmmotable", Native_JB_SetAmmotable);

		/* Gamemode */
	CreateNative("JBGameMode_GetProperty", Native_JBGameMode_GetProperty);
	CreateNative("JBGameMode_SetProperty", Native_JBGameMode_SetProperty);
	CreateNative("JBGameMode_ManageCells", Native_JBGameMode_ManageCells);
	CreateNative("JBGameMode_FindRandomWarden", Native_JBGameMode_FindRandomWarden);

	RegPluginLibrary("TF2Jail_Redux");
}

public int Native_RegisterPlugin(Handle plugin, int numParams)
{
	char ModuleName[64]; GetNativeString(1, ModuleName, sizeof(ModuleName));
	int plugin_index = RegisterPlugin(plugin, ModuleName); // ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return plugin_index;
}
public int Native_JBInstance(Handle plugin, int numParams)
{
	JailFighter player = JailFighter(GetNativeCell(1), GetNativeCell(2));
	return view_as<int>(player);
}
public int Native_JBGetUserid(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	return player.userid;
}
public int Native_JBGetIndex(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	return player.index;
}
public int Native_JB_getProperty(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item;
	if (hJailFields[player.index].GetValue(prop_name, item))
		return item;
	return 0;
}
public int Native_JB_setProperty(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	hJailFields[player.index].SetValue(prop_name, item);
}
public int Native_Hook(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	
	Function Func = GetNativeFunction(2);
	if (g_hForwards[JBHook] != null)
		g_hForwards[JBHook].Add(plugin, Func);
}
public int Native_HookEx(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	
	Function Func = GetNativeFunction(2);
	if (g_hForwards[JBHook] != null)
		return g_hForwards[JBHook].Add(plugin, Func);
	return 0;
}
public int Native_Unhook(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	
	if (g_hForwards[JBHook] != null)
		g_hForwards[JBHook].Remove(plugin, GetNativeFunction(2));
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	
	if (g_hForwards[JBHook] != null)
		return g_hForwards[JBHook].Remove(plugin, GetNativeFunction(2));
	return 0;
}
public int Native_JB_SpawnWep(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	char classname[64]; GetNativeString(2, classname, 64);
	int itemindex = GetNativeCell(3);
	int level = GetNativeCell(4);
	int quality = GetNativeCell(5);
	char attributes[128]; GetNativeString(6, attributes, 128);
	return player.SpawnWeapon(classname, itemindex, level, quality, attributes);
}
public int Native_JB_ForceTeamChange(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.ForceTeamChange(team);
}
public int Native_JB_GetWeaponSlotIndex(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	player.GetWeaponSlotIndex(slot);
}
public int Native_JB_SetWepInvis(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int alpha = GetNativeCell(2);
	player.SetWepInvis(alpha);
}
public int Native_JB_TeleToSpawn(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.TeleToSpawn(team);
}
public int Native_JB_TeleportToPosition(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int loc = GetNativeCell(2);
	player.TeleportToPosition(loc);
}
public int Native_JB_ListLRS(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.ListLRS();
}
public int Native_JB_PreEquip(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.PreEquip();
}
public int Native_JB_WardenSet(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.WardenSet();
}
public int Native_JB_WardenUnset(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.WardenUnset();
}
public int Native_JB_MakeHorsemann(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.MakeHorsemann();
}
public int Native_JB_MutePlayer(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.MutePlayer();
}
public int Native_JB_UnmutePlayer(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.UnmutePlayer();
}
public int Native_JB_EmptyWeaponSlots(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.EmptyWeaponSlots();
}
public int Native_JB_StripToMelee(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.StripToMelee();
}
public int Native_JB_GiveFreeday(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.GiveFreeday();
}
public int Native_JB_RemoveFreeday(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	player.RemoveFreeday();
}
public int Native_JB_SpawnSmallHealthPack(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int ownerteam = GetNativeCell(2);
	player.SpawnSmallHealthPack(ownerteam);
}
public int Native_JB_SetCliptable(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	int count = GetNativeCell(3);
	player.SetCliptable(slot, count);
}
public int Native_JB_SetAmmotable(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	int count = GetNativeCell(3);
	player.SetAmmotable(slot, count);
}

public int Native_JBGameMode_GetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, 64);
	any item;
	if (hGameModeFields.GetValue(prop_name, item)) {
		return item;
	}
	return 0;
}
public int Native_JBGameMode_SetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, 64);
	any item = GetNativeCell(2);
	hGameModeFields.SetValue(prop_name, item);
}
public int Native_JBGameMode_FindRandomWarden(Handle plugin, int numParams)
{
	gamemode.FindRandomWarden();
}
public int Native_JBGameMode_ManageCells(Handle plugin, int numParams)
{
	eDoorsMode status = GetNativeCell(1);
	gamemode.DoorHandler(status);
}
