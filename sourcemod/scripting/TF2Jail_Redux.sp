/*	  _____   _____   ____        _           _   _     ____               _                
	 |_   _| |  ___| |___ \      | |   __ _  (_) | |   |  _ \    ___    __| |  _   _  __  __
	   | |   | |_      __) |  _  | |  / _` | | | | |   | |_) |  / _ \  / _` | | | | | \ \/ /
	   | |   |  _|    / __/  | |_| | | (_| | | | | |   |  _ <  |  __/ | (_| | | |_| |  >  < 
	   |_|   |_|     |_____|  \___/   \__,_| |_| |_|   |_| \_\  \___|  \__,_|  \__,_| /_/\_\ */

/**
 **	TF2Jail_Redux.sp: Contains the core functions of the plugin, along with natives 			   **
 **	jailbase.sp: Player methodmap properties plus a few handy variables 						   **
 **	jailgamemode.sp: Gamemode methodmap properties that control gameplay functionality			   **
 **	jailevents.sp: Events of the plugin that are organized and managed by...					   **
 **	jailhandler.sp: Logic of gamemode behavior under any circumstance, functions called from core  **
 **	jailcommands.sp: Commands and some of the menus corresponding to commands 					   **
 **	stocks.inc: Stock functions used or could possibly be used within plugin 					   **
 **	jailforwards.sp: Contains external gamemode third-party functionality, leave it alone 		   **
 **	tf2jailredux.inc: External gamemode third-party functionality, leave it alone 				   **
 **	If you're here to give some more uniqueness to the plugin, check jailhandler 	 			   **
 **	It's fixed with a variety of not only last request examples, but gameplay event management.	   **
 **	VSH and PH are standalone subplugins, if there is an issue with them, simply delete them	   **
 **/

#define PLUGIN_NAME			"[TF2] Jailbreak Redux"
#define PLUGIN_VERSION		"0.13.3"
#define PLUGIN_AUTHOR		"Scag/Ragenewb, props to Keith (Aerial Vanguard) and Nergal/Assyrian"
#define PLUGIN_DESCRIPTION	"Deluxe version of TF2Jail"

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <morecolors>
#include <tf2jailredux>

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#undef REQUIRE_PLUGIN
#include <tf2attributes>
#tryinclude <sourcebans>
#tryinclude <sourcebanspp>
#tryinclude <sourcecomms>
#tryinclude <basecomm>
#tryinclude <clientprefs>
#tryinclude <voiceannounce_ex>
#define REQUIRE_PLUGIN

#pragma semicolon 			1
#pragma newdecls 			required

#define RED 				2
#define BLU 				3

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
	VIPFlag,
	AdmFlag,
	DisableBlueMute,
	Markers,
	CritType,
	MuteType,
	LivingMuteType,
	Disguising,
	WardenDelay,
	LRDefault,
	FreeKill,
	FreeKillMessage,
	AutobalanceImmunity,
	NoCharge,
	NoAirblast,
	NoDoubleJump,
	DenyLR,
	WardenLaser,
	Version
};

// If adding new cvars put them above Version in the enum
ConVar 
	cvarTF2Jail[Version + 1],
	bEnabled,
	hEngineConVars[3]
;

Handle 
	hTextNodes[4],
#if defined _clientprefs_included
	MusicCookie,
#endif
	AimHud
;

char
	sCellNames[32],
	sCellOpener[32],
	sFFButton[32]
;

float
	flFreedayPosition[3], 
	flWardayBlu[3], 
	flWardayRed[3]
;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

ArrayList 
	hPlugins
;

#include "TF2JailRedux/stocks.inc"
#include "TF2JailRedux/jailhandler.sp"
#include "TF2JailRedux/jailforwards.sp"
#include "TF2JailRedux/jailevents.sp"
#include "TF2JailRedux/jailcommands.sp"

public void OnPluginStart()
{
	gamemode = new JailGameMode();
	gamemode.Init();
	
	InitializeForwards();	// Forwards

	LoadTranslations("common.phrases");

	bEnabled 								= CreateConVar("sm_tf2jr_enable", "1", "Status of the plugin: (1 = on, 0 = off)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Version] 					= CreateConVar("tf2jr_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
	cvarTF2Jail[Balance] 					= CreateConVar("sm_tf2jr_auto_balance", "1", "Should the plugin autobalance teams?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[BalanceRatio] 				= CreateConVar("sm_tf2jr_balance_ratio", "0.5", "Ratio for autobalance: (Example: 0.5 = 2:4)", FCVAR_NOTIFY, true, 0.1, true, 1.0);
	cvarTF2Jail[DoorOpenTimer] 				= CreateConVar("sm_tf2jr_cell_timer", "60", "Time after Arena round start to open doors.", FCVAR_NOTIFY, true, 0.0, true, 120.0);
	cvarTF2Jail[FreedayLimit] 				= CreateConVar("sm_tf2jr_freeday_limit", "3", "Max number of freedays for the Freeday For Others lr.", FCVAR_NOTIFY, true, 1.0, true, 16.0);
	cvarTF2Jail[KillPointServerCommand] 	= CreateConVar("sm_tf2jr_point_servercommand", "1", "Kill 'point_servercommand' entities.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLR] 			= CreateConVar("sm_tf2jr_freeday_removeonlr", "1", "Remove Freedays on Last Request.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLastGuard] 	= CreateConVar("sm_tf2jr_freeday_removeonlastguard", "1", "Remove Freedays on Last Guard.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenTimer] 				= CreateConVar("sm_tf2jr_warden_timer", "20", "Time in seconds after Warden is unset or lost to lock Warden.", FCVAR_NOTIFY);
	cvarTF2Jail[RoundTimerStatus]			= CreateConVar("sm_tf2jr_roundtimer_status", "1", "Status of the round timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RoundTime] 					= CreateConVar("sm_tf2jr_roundtimer_time", "600", "Amount of time normally on the timer (if enabled).", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RoundTime_Freeday] 			= CreateConVar("sm_tf2jr_roundtimer_time_freeday", "300", "Amount of time on 1st day freeday.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RebelAmmo] 					= CreateConVar("sm_tf2jr_red_ammo", "1", "Should freedays be removed upon a freeday player's collection of ammo?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[DroppedWeapons] 			= CreateConVar("sm_tf2jr_dropped_weapons", "1", "Should players be allowed to pick up dropped weapons?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[VentHit] 					= CreateConVar("sm_tf2jr_vent_freeday", "1", "Should freeday players lose their freeday if they hit/break a vent?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[SeeNames] 					= CreateConVar("sm_tf2jr_wardensee", "1", "Allow the Warden to see prisoner names?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NameDistance] 				= CreateConVar("sm_tf2jr_wardensee_distance", "200", "From how far can the Warden see prisoner names? (Hammer Units)", FCVAR_NOTIFY, true, 0.0, true, 1000.0);
	cvarTF2Jail[SeeHealth] 					= CreateConVar("sm_tf2jr_wardensee_health", "1", "Can the Warden see prisoner health?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EnableMusic] 				= CreateConVar("sm_tf2jr_music_on", "1", "Enable background music that could possibly play with last requests?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[MusicVolume] 				= CreateConVar("sm_tf2jr_music_volume", ".5", "Volume in which background music plays. (If enabled)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EurekaTimer] 				= CreateConVar("sm_tf2jr_eureka_teleport", "20", "How long must players wait until they are able to Eureka Effect Teleport again? (0 to disable cooldown)", FCVAR_NOTIFY, true, 0.0, true, 60.0);
	cvarTF2Jail[VIPFlag] 					= CreateConVar("sm_tf2jr_vip_flag", "r", "What admin flag do VIP players fall under? Leave blank to disable Admin perks.", FCVAR_NOTIFY);
	cvarTF2Jail[AdmFlag] 					= CreateConVar("sm_tf2jr_admin_flag", "b", "What admin flag do admins fall under? Leave blank to disable Admin perks.", FCVAR_NOTIFY);
	cvarTF2Jail[DisableBlueMute] 			= CreateConVar("sm_tf2jr_blue_mute", "1", "Disable joining blue team for muted players?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Markers] 					= CreateConVar("sm_tf2jr_warden_markers", "3", "Warden markers lifetime in seconds? (0 to disable them entirely)", FCVAR_NOTIFY, true, 0.0, true, 30.0);
	cvarTF2Jail[CritType] 					= CreateConVar("sm_tf2jr_criticals", "2", "What type of criticals should guards get? 0 = none; 1 = mini-crits; 2 = full crits", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvarTF2Jail[MuteType] 					= CreateConVar("sm_tf2jr_muting", "6", "What type of dead player muting should occur? 0 = no muting; 1 = red players only are muted(except VIPs); 2 = blue players only are muted(except VIPs); 3 = all players are muted(except VIPs); 4 = all red players are muted; 5 = all blue players are muted; 6 = everybody is muted. ADMINS ARE EXEMPT FROM ALL OF THESE!", FCVAR_NOTIFY, true, 0.0, true, 6.0);
	cvarTF2Jail[LivingMuteType] 			= CreateConVar("sm_tf2jr_live_muting", "1", "What type of living player muting should occur? 0 = no muting; 1 = red players only are muted(except VIPs); 2 = blue players only are muted(except VIPs and warden); 3 = all players are muted(except VIPs and warden); 4 = all red players are muted; 5 = all blue players are muted(except warden); 6 = everybody is muted(except warden). ADMINS ARE EXEMPT FROM ALL OF THESE!", FCVAR_NOTIFY, true, 0.0, true, 6.0);
	cvarTF2Jail[Disguising] 				= CreateConVar("sm_tf2jr_disguising", "0", "What teams can disguise, if any? (Your Eternal Reward only) 0 = no disguising; 1 = only Red can disguise; 2 = Only blue can disguise; 3 = all players can disguise", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarTF2Jail[WardenDelay] 				= CreateConVar("sm_tf2jr_warden_delay", "0", "Delay in seconds after round start until players can toggle becoming the warden. 0 to disable delay.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[LRDefault] 					= CreateConVar("sm_tf2jr_lr_default", "5", "Default number of times the basic last requests can be picked in a single map. 0 for no limit.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[FreeKill] 					= CreateConVar("sm_tf2jr_freekill", "3", "How many kills in a row must a player get before the freekiller system activates? 0 to disable. (This does not affect gameplay, prints SourceBans information to admin consoles determined by \"sm_tf2jr_admin_flag\").", FCVAR_NOTIFY, true, 0.0, true, 33.0);
	cvarTF2Jail[FreeKillMessage] 			= CreateConVar("sm_tf2jr_freekill_message", "0", "if \"sm_tf2jr_freekill\" is enabled, how are admins to be notified of a freekiller? 0 = Console message; 1 = Chat message.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[AutobalanceImmunity] 		= CreateConVar("sm_tf2jr_auto_balance_immunity", "1", "Allow VIP's/admins to have autobalance immunity? (If autobalancing is enabled).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NoCharge] 					= CreateConVar("sm_tf2jr_demo_charge", "3", "Disable DemoMan's charge ability? 0 = Allow; 1 = Disable for Blue team; 2 = Disable for Red team; 3 = Disable for all", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarTF2Jail[NoAirblast] 				= CreateConVar("sm_tf2jr_airblast", "1", "Disable Pyro airblast? (Requires TF2Attributes)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NoDoubleJump] 				= CreateConVar("sm_tf2jr_double_jump", "1", "Disable Scout doublejump? (Requires TF2Attributes)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[DenyLR] 					= CreateConVar("sm_tf2jr_warden_deny_lr", "1", "Allow Wardens to deny the queued last request?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenLaser] 				= CreateConVar("sm_tf2jr_warden_laser", "1", "Allow Wardens to use laser pointers?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig(true, "TF2JailRedux");

		/* Used in core*/
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("arena_round_start", OnArenaRoundStart);
	HookEvent("teamplay_round_win", OnRoundEnd);
	// HookEvent("post_inventory_application", OnRegeneration);
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

	RegConsoleCmd("sm_jhelp", Command_Help, "Display a menu containing the major commands.");
	RegConsoleCmd("sm_jailhelp", Command_Help, "Display a menu containing the major commands.");
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
#if defined _clientprefs_included
	RegConsoleCmd("sm_jbmusic", Command_MusicOff, "Client cookie that disables LR background music (if it exists).");
	RegConsoleCmd("sm_jailmusic", Command_MusicOff, "Client cookie that disables LR background music (if it exists).");
#endif
	RegConsoleCmd("sm_wmarker", Command_WardenMarker, "Allows the Warden to create a marker that players can see/hear.");
	RegConsoleCmd("sm_wmk", Command_WardenMarker, "Allows the Warden to create a marker that players can see/hear.");
	RegConsoleCmd("sm_wlaser", Command_WardenLaser, "Allows the Warden to use a laser pointer by holding Reload.");
	RegConsoleCmd("sm_wl", Command_WardenLaser, "Allows the Warden to use a laser pointer by holding Reload.");

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
	RegAdminCmd("sm_flr", AdminForceLR, ADMFLAG_GENERIC, "Force a last request to either administrator or another, living client.");
	RegAdminCmd("sm_forcelr", AdminForceLR, ADMFLAG_GENERIC, "Force a last request to either administrator or another, living client.");
	RegAdminCmd("sm_compatible", AdminMapCompatibilityCheck, ADMFLAG_GENERIC, "Check if the current map is compatible with the plug-in.");
	RegAdminCmd("sm_compat", AdminMapCompatibilityCheck, ADMFLAG_GENERIC, "Check if the current map is compatible with the plug-in.");
	RegAdminCmd("sm_gf", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Free day.");
	RegAdminCmd("sm_givefreeday", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Free day.");
	RegAdminCmd("sm_rf", AdminRemoveFreeday, ADMFLAG_GENERIC, "Remove a client's Free day status if they have one.");
	RegAdminCmd("sm_removefreeday", AdminRemoveFreeday, ADMFLAG_GENERIC, "Remove a client's Free day status if they have one.");
	RegAdminCmd("sm_lw", AdminLockWarden, ADMFLAG_GENERIC, "Lock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_lockwarden", AdminLockWarden, ADMFLAG_GENERIC, "Lock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_ulw", AdminUnlockWarden, ADMFLAG_GENERIC, "Unlock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_unlockwarden", AdminUnlockWarden, ADMFLAG_GENERIC, "Unlock Warden from being taken by clients publicly.");
	RegAdminCmd("sm_wardayred", AdminWardayRed, ADMFLAG_GENERIC, "Teleport all prisoners to their warday teleport location.");
	RegAdminCmd("sm_wred", AdminWardayRed, ADMFLAG_GENERIC, "Teleport all prisoners to their warday teleport location.");
	RegAdminCmd("sm_wardayblue", AdminWardayBlue, ADMFLAG_GENERIC, "Teleport all guards to their warday teleport location.");
	RegAdminCmd("sm_wblue", AdminWardayBlue, ADMFLAG_GENERIC, "Teleport all guards to their warday teleport location.");
	RegAdminCmd("sm_startwarday", FullWarday, ADMFLAG_GENERIC, "Teleport all players to their warday teleport location.");
	RegAdminCmd("sm_sw", FullWarday, ADMFLAG_GENERIC, "Teleport all players to their warday teleport location.");

	RegAdminCmd("sm_setpreset", SetPreset, ADMFLAG_ROOT, "Set gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_itype", Type, ADMFLAG_ROOT, "gamemode.iLRType. (DEBUGGING)");
	RegAdminCmd("sm_ipreset", Preset, ADMFLAG_ROOT, "gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_getprop", GameModeProp, ADMFLAG_ROOT, "Retrieve a gamemode property value. (DEBUGGING)");
	RegAdminCmd("sm_getpprop", BaseProp, ADMFLAG_ROOT, "Retrieve a base player property value. (DEBUGGING)");
	RegAdminCmd("sm_len", PluginLength, ADMFLAG_ROOT, "hPlugins.Length. (DEBUGGING)");
	RegAdminCmd("sm_lrlen", arrLRSLength, ADMFLAG_ROOT, "arrLRS.Length. (DEBUGGING)");
	RegAdminCmd("sm_jailreset", AdminResetPlugin, ADMFLAG_ROOT, "Reset all plug-in global variables. (DEBUGGING)");

	hEngineConVars[0] = FindConVar("mp_friendlyfire");
	hEngineConVars[1] = FindConVar("tf_avoidteammates_pushaway");
	hEngineConVars[2] = FindConVar("sv_gravity");
		
	AimHud = CreateHudSynchronizer();

	AddMultiTargetFilter("@warden", WardenGroup, "The Warden.", false);
	AddMultiTargetFilter("@!warden", WardenGroup, "All but the Warden.", false);
	AddMultiTargetFilter("@freedays", FreedaysGroup, "All Freedays.", false);

	AddNormalSoundHook(SoundHook);

#if defined _clientprefs_included
	MusicCookie = RegClientCookie("sm_tf2jr_music", "Determines if client wishes to listen to background music played by the plugin/LRs", CookieAccess_Protected);
#endif

	int i;

	for (i = MaxClients; i; --i) 
	{
		if (IsValidClient(i))
		{
			OnClientPutInServer(i);
			OnClientPostAdminCheck(i);
		}
	}

	for (i = 0; i < sizeof(hTextNodes); i++)
		hTextNodes[i] = CreateHudSynchronizer();

	hJailFields[0] = new StringMap();
	hPlugins = new ArrayList();
	arrLRS = new ArrayList(1, LRMAX+1);	// Registering plugins pushes indexes to arrLRS, we also start at 0 so +1
}

public bool WardenGroup(const char[] pattern, Handle clients)
{
	if (bEnabled.BoolValue)
	{
		bool non = StrContains(pattern, "!", false) != - 1;
		for (int i = MaxClients; i; --i) 
		{
			if (IsClientInGame(i) && FindValueInArray(clients, i) == - 1)
			{
				if (JailFighter(i).bIsWarden) 
				{
					if (!non)
						PushArrayCell(clients, i);
				}
				else if (non)
					PushArrayCell(clients, i);
			}
		}
	}
	return true;
}

public bool FreedaysGroup(const char[] pattern, Handle clients)
{
	if (bEnabled.BoolValue)
		for (int i = MaxClients; i; --i)
			if (IsClientInGame(i) && FindValueInArray(clients, i) == -1)
				if (JailFighter(i).bIsFreeday)
					PushArrayCell(clients, i);
	return true;
}

public void OnAllPluginsLoaded()
{
#if defined _steamtools_included
	gamemode.bSteam = LibraryExists("SteamTools");
#endif
#if defined _sourcebans_included || defined _sourcebanspp_included
	gamemode.bSB = (LibraryExists("sourcebans") || LibraryExists("sourcebans++"));
#endif
	gamemode.bSC = LibraryExists("sourcecomms");
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
#if defined _sourcebans_included || defined _sourcebanspp_included
	if (!strcmp(name, "sourcebans", false) || !strcmp(name, "sourcebans++", false))
		gamemode.bSB = true;
#endif
	if (!strcmp(name, "sourcecomms", false))
		gamemode.bSC = true;
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
#if defined _sourcebans_included || defined _sourcebanspp_included
	if ((!strcmp(name, "sourcebans", false) && !LibraryExists("sourcebans++")) || (!strcmp(name, "sourcebans++", false) && !LibraryExists("sourcebans")))
		gamemode.bSB = false;
#endif
	if (!strcmp(name, "sourcecomms", false))
		gamemode.bSC = false;
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

	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(465.0, Timer_Announce, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	gamemode.b1stRoundFreeday = true;

	ManageDownloads();	// Handler

	HookEntityOutput("item_ammopack_full", "OnPlayerTouch", OnEntTouch);
	HookEntityOutput("item_ammopack_medium", "OnPlayerTouch", OnEntTouch);
	HookEntityOutput("item_ammopack_small", "OnPlayerTouch", OnEntTouch);
	HookEntityOutput("tf_ammo_pack", "OnPlayerTouch", OnEntTouch);

	int len = arrLRS.Length;
	for (int i = 0; i < len; i++)
		arrLRS.Set( i, 0 );
}

public void OnMapEnd()
{
	gamemode.Init();
	StopBackGroundMusic();

	hEngineConVars[2].SetInt(800);	// For admins like sans who force change the map during the low gravity LR
	ConvarsSet(false);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_PreThink, PreThink);

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
	player.bLasering = false;
	player.bEvilBeamed = false;
	player.flSpeed = 0.0;
	player.flKillSpree = 0.0;

	ManageClientStartVariables(player);
}

public void OnClientPostAdminCheck(int client)
{	// Gotta make sure
	char strVIP[4]; cvarTF2Jail[VIPFlag].GetString(strVIP, sizeof(strVIP));
	char strAdmin[4]; cvarTF2Jail[AdmFlag].GetString(strAdmin, sizeof(strAdmin));
	JailFighter player = JailFighter(client);

	SetPawnTimer(WelcomeMessage, 5.0, player.userid);

	if (strVIP[0] != '\0')
	{
		if (IsValidAdmin(client, strVIP)) // Very useful stock ^^
			player.bIsVIP = true;
	}
	else player.bIsVIP = false;

	if (strAdmin[0] != '\0')
	{
		if (IsValidAdmin(client, strAdmin))
			player.bIsAdmin = true;
	}
	else player.bIsVIP = false;

	// if (cvarTF2Jail[MuteType].IntValue >= 4)
		// player.MutePlayer();
}

public Action OnTouch(int toucher, int touchee)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (!IsClientValid(toucher) || !IsClientValid(touchee))
		return Plugin_Continue;

	if (TF2_GetClientTeam(toucher) == TFTeam_Red)
		ManageRedTouchBlue(JailFighter(toucher), JailFighter(touchee));	// Handler

	return Plugin_Continue;
}

public Action Timer_PlayerThink(Handle timer)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (gamemode.flMusicTime <= GetGameTime() && cvarTF2Jail[EnableMusic].BoolValue)
		_MusicPlay();

	JailFighter player;
	int type = cvarTF2Jail[MuteType].IntValue;
	int livingtype = cvarTF2Jail[LivingMuteType].IntValue;
	int state = gamemode.iRoundState;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		player = JailFighter(i);
		if (!IsPlayerAlive(i) && state == StateRunning)
		{
			switch (type)
			{
				case 0:player.UnmutePlayer();
				case 1:
				{
					if (GetClientTeam(i) == RED && !player.bIsVIP)
						player.MutePlayer();
					else player.UnmutePlayer();
				}
				case 2:
				{
					if (GetClientTeam(i) == BLU && !player.bIsVIP)
						player.MutePlayer();
					else player.UnmutePlayer();
				}
				case 3:if (!player.bIsVIP) player.MutePlayer();
				case 4:if (GetClientTeam(i) == RED) player.MutePlayer();
				case 5:if (GetClientTeam(i) == BLU) player.MutePlayer();
				default:player.MutePlayer();
			}
			continue;
		}
		else if (state != StateRunning)
			player.UnmutePlayer();

		if (state == StateRunning)
		{
			switch (livingtype)
			{
				case 0:player.UnmutePlayer();
				case 1:
				{
					if (GetClientTeam(i) == RED && !player.bIsVIP)
						player.MutePlayer();
					else player.UnmutePlayer();
				}
				case 2:
				{
					if (GetClientTeam(i) == BLU && !player.bIsVIP)
						player.MutePlayer();
					else player.UnmutePlayer();
				}
				case 3:if (!player.bIsVIP) player.MutePlayer();
				case 4:if (GetClientTeam(i) == RED) player.MutePlayer();
				case 5:if (GetClientTeam(i) == BLU) player.MutePlayer();
				default:player.MutePlayer();
			}
		}
		else player.UnmutePlayer();

		if (state != StateRunning)
			continue;

		if (GetClientTeam(i) == BLU)
		{
			ManageBlueThink(player);
			if (player.bIsWarden)
			{
				ManageWardenThink(player);

				int target = GetClientAimTarget(i, true);
				if (!IsClientValid(target))
					continue;
				if (GetClientTeam(i) == GetClientTeam(target))
					continue;

				float flCpos[3], flTpos[3];
				GetClientEyePosition(i, flCpos);
				GetClientEyePosition(target, flTpos);

				if (!CanSeeTarget(i, flCpos, target, flTpos, cvarTF2Jail[NameDistance].FloatValue))
					continue;

				if (TF2_IsPlayerInCondition(target, TFCond_Cloaked) // Cloak watches are removed but meh
				 || TF2_IsPlayerInCondition(target, TFCond_DeadRingered)
				 || TF2_IsPlayerInCondition(target, TFCond_Disguised))
					continue;

				SetHudTextParams(-1.0, 0.59, 0.4, 255, 100, 255, 255, 1);
				if (cvarTF2Jail[SeeHealth].BoolValue)
					ShowSyncHudText(i, AimHud, "%N [%d]", target, GetClientHealth(target));
				else ShowSyncHudText(i, AimHud, "%N", target);
			}
		}
		// else if (GetClientTeam(i) == BLU && !player.bIsWarden)
			// ManageBlueNotWardenThink(player);
		else if (GetClientTeam(i) == RED)
			ManageRedThink(player);
	}
	return Plugin_Continue;
}

public Action Timer_Announce(Handle timer)
{
	if (bEnabled.BoolValue)
		CPrintToChatAll("{red}[TF2Jail] Redux{tan} V%s by {default}Scag/Ragenewb{tan}.", PLUGIN_VERSION);
}

public void OnClientDisconnect(int client)
{
	ManageClientDisconnect(JailFighter(client));	// Handler
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

public void HookVent(const int ref)
{
	int vent = EntRefToEntIndex(ref);
	if (IsValidEntity(vent))
		SDKHook(vent, SDKHook_OnTakeDamage, OnEntTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!bEnabled.BoolValue || !IsClientValid(victim))
		return Plugin_Continue;

	return ManageOnTakeDamage(JailFighter(victim), attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

public void OnEntTouch(const char[] output, int touchee, int toucher, float delay)
{
	if (!bEnabled.BoolValue || !cvarTF2Jail[RebelAmmo].BoolValue)
		return;

	if (!IsClientValid(toucher))
		return;

	JailFighter player = JailFighter(toucher);
	if (player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%N has taken ammo and lost their freeday!", toucher);
	}
}

public Action OnEntTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsClientValid(attacker) || !IsValidEntity(victim))
		return Plugin_Continue;

	JailFighter player = JailFighter(attacker);
	if (player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%N has hit a vent and lost their freeday!", attacker);
	}
	return Plugin_Continue;
}

public void PreThink(int client)
{
	if (!bEnabled.BoolValue)
		return;

	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	JailFighter player = JailFighter(client);
	int buttons = GetClientButtons(client);

	if (player.bIsWarden && (buttons & IN_RELOAD) && player.bLasering && cvarTF2Jail[WardenLaser].BoolValue)
	{
		float vecPos[3];
		float vecEyes[3]; GetClientEyePosition(client, vecEyes);
		if (GetClientAimPos(client, vecPos, vecEyes, TraceRayFilterPlayersAndSelf))
		{
			TE_SetupBeamPoints(vecEyes, vecPos, iLaserBeam, 0, 0, 0, 0.1, 0.25, 0.0, 1, 0.0, {0, 100, 255, 255}, 0);
			TE_SendToAll();

			TE_SetupGlowSprite(vecEyes, iHalo, 0.1, 0.25, 30);
			TE_SendToAll();
		}
	}
	ManageOnPreThink(player, buttons);
}

public bool TraceRayFilterPlayersAndSelf(int entity, int mask, any data)
{
	if (entity > 0 && entity <= MaxClients)
		return false;

	if (entity == data)
		return false;

	return true;
}

public Action EurekaTele(int client, const char[] command, int args)
{
	if (!bEnabled.BoolValue || !IsPlayerAlive(client))
		return Plugin_Continue;

	float time = cvarTF2Jail[EurekaTimer].FloatValue;

	if (time <= 0.0)
		return Plugin_Continue;

	JailFighter player = JailFighter(client);

	if (player.bUnableToTeleport)
	{
		CPrintToChat(client, "{red}[TF2Jail]{tan} You can't teleport yet!");
		return Plugin_Handled;
	}

	player.bUnableToTeleport = true;
	SetPawnTimer(EnableEureka, time, player.userid);

	return Plugin_Continue;
}

public void ParseConfigs()
{
	ParseMapConfig();
	ParseNodeConfig();
}

public void ParseMapConfig()
{
	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, sizeof(sConfig), "configs/tf2jail/mapconfig.cfg");

	KeyValues key = new KeyValues("TF2Jail_MapConfig");
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (!key.ImportFromFile(sConfig))
	{
		gamemode.bIsMapCompatible = false;
		gamemode.bFreedayTeleportSet = false;
		gamemode.bWardayTeleportSetBlue = false;
		gamemode.bWardayTeleportSetRed = false;
		LogError("~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");

		delete key;
		return;
	}
	if (!key.JumpToKey(sMapName))
	{
		gamemode.bIsMapCompatible = false;
		gamemode.bFreedayTeleportSet = false;
		gamemode.bWardayTeleportSetBlue = false;
		gamemode.bWardayTeleportSetRed = false;
		LogError("~~~~~No TF2Jail Map Config set, dismantling teleportation~~~~~");

		delete key;
		return;
	}
	char CellNames[32], CellsButton[32], ffButton[32];

	key.GetString("CellNames", CellNames, sizeof(CellNames));
	if (CellNames[0] != '\0')
	{
		int iCelldoors = FindEntity(CellNames, "func_door");
		if (IsValidEntity(iCelldoors))
		{
			sCellNames = CellNames;
			gamemode.bIsMapCompatible = true;
		}
		else gamemode.bIsMapCompatible = false;
	}
	else gamemode.bIsMapCompatible = false;

	key.GetString("CellsButton", CellsButton, sizeof(CellsButton));
	if (CellsButton[0] != '\0')
	{
		int iCellOpener = FindEntity(CellsButton, "func_button");
		if (IsValidEntity(iCellOpener))
			sCellOpener = CellsButton;
	}
	key.GetString("FFButton", ffButton, sizeof(ffButton));
	if (ffButton[0] != '\0')
	{
		int iFFButton = FindEntity(ffButton, "func_button");
		if (IsValidEntity(iFFButton))
			sCellOpener = ffButton;
	}

	if (key.JumpToKey("Freeday"))
	{
		if (key.JumpToKey("Teleport"))
		{
			gamemode.bFreedayTeleportSet = view_as< bool >(key.GetNum("Status", 1));

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
			gamemode.bWardayTeleportSetBlue = view_as< bool >(key.GetNum("Status", 1));

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
			gamemode.bWardayTeleportSetRed = view_as< bool >(key.GetNum("Status", 1));

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

	delete key;
}

public void ParseNodeConfig()
{
	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, sizeof(sConfig), "configs/tf2jail/textnodes.cfg");

	KeyValues key = new KeyValues("TF2Jail_Nodes");
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
			} while key.GotoNextKey(false);
		}
	}
	else LogError("~~~~~No TF2Jail Node Config found in path %s. Ignoring all text factors.~~~~~", sConfig);
	delete key;
}

public bool AlreadyMuted(const int client)
{
	switch (gamemode.bSC)
	{
#if defined _sourcecomms_included
		case true:return view_as< bool >(SourceComms_GetClientMuteType(client) != bNot);
#endif
#if defined _basecomm_included
		case false:return BaseComm_IsClientMuted(client);
#endif
	}
	return false;
}

public void EnableEureka(const int userid)
{
	JailFighter player = JailFighter(userid, true);
	if (IsClientInGame(player.index))
		player.bUnableToTeleport = false;
}

public void WelcomeMessage(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsClientInGame(client))
		CPrintToChat(client, "{red}[TF2Jail]{tan} Welcome to TF2 Jailbreak Redux. Type \"!jhelp\" for help.");
}

public void ResetDamage()
{
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
	}
}

public void KillThatBitch(const int client)
{
	EmitSoundToAll(SuicideSound);
	ForcePlayerSuicide(client);
	if (IsPlayerAlive(client))	// In case their kartified or something idk
		SDKHooks_TakeDamage(client, 0, 0, 9001.0, DMG_DIRECT, _, _, _);
}

public void UnHorsemannify(const JailFighter player)
{
	if (IsClientInGame(player.index))
		player.UnHorsemann();
}

public void RandSniper(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount)
		return;

	int rand = GetRandomClient();

	if (!IsClientValid(rand))
		return;

	EmitSoundToAll(SuicideSound);
	SDKHooks_TakeDamage(rand, 0, 0, 9001.0, DMG_DIRECT|DMG_BULLET, _, _, _);

	SetPawnTimer(RandSniper, GetRandomFloat(30.0, 60.0), roundcount);
}

public void EndRandSniper(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount)
		return;

	int rand = GetRandomClient();

	if (!IsClientValid(rand))
		return;

	EmitSoundToAll(SuicideSound);
	SDKHooks_TakeDamage(rand, 0, 0, 9001.0, DMG_DIRECT|DMG_BULLET, _, _, _);

	SetPawnTimer(EndRandSniper, GetRandomFloat(0.1, 0.3), roundcount);
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

public void DisableWarden(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount 
	 || gamemode.iRoundState != StateRunning 
	 || gamemode.bWardenExists 
	 || gamemode.bIsWardenLocked)
		return;

	CPrintToChatAll("{red}[TF2Jail]{tan} Warden has been locked due to lack of warden.");
	gamemode.DoorHandler(OPEN);
	gamemode.bIsWardenLocked = true;
}

public void NoAttacking(const int wepref)
{
	int weapon = EntRefToEntIndex(wepref);
	SetNextAttack(weapon, 1.56);
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
	if (gamemode.iRoundState != StateRunning)
		return;

	float currtime = GetGameTime();
	if (gamemode.flMusicTime > currtime)
		return;

	char sound[PLATFORM_MAX_PATH] = "";
	float time = -1.0;

	if (ManageMusic(sound, time) != Plugin_Continue)
		return;

	if (sound[0] != '\0')
	{
		float vol = cvarTF2Jail[MusicVolume].FloatValue;
		strcopy(BackgroundSong, PLATFORM_MAX_PATH, sound);
		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientInGame(i))
				continue;
#if defined _clientprefs_included
			if (JailFighter(i).bNoMusic)
				continue;
#endif
			EmitSoundToClient(i, sound, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
	if (time != -1.0)
		gamemode.flMusicTime = currtime + time;
}

public void StopBackGroundMusic()
{
	for (int i = MaxClients; i; --i) 
		if (IsClientInGame(i))
			StopSound(i, SNDCHAN_AUTO, BackgroundSong);
}

public bool CheckSet(const int client, const int count, const int max)
{
	if (!max)
		return true;

	if (count >= max)
	{
		CPrintToChat(client, "{red}[TF2Jail]{tan} This LR has been picked the maximum amount of times for this map.");
		JailFighter(client).ListLRS();
		//ListLastRequests(client);
		return false;
	}
	return true;
}
// Props to Dr.Doctor
public void CreateMarker(const int client)
{
	if (!cvarTF2Jail[Markers].BoolValue)
		return;

	float vecAngles[3], vecOrigin[3], flPos[3];

	GetClientEyePosition(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);

	Handle trace = TR_TraceRayFilterEx(vecOrigin, vecAngles, MASK_SHOT, RayType_Infinite, TraceRayFilterPlayers);

	if (!TR_DidHit(trace))
	{
		CPrintToChat(client, "{red}[TF2Jail]{tan} Unable to create a marker.");
		delete trace;
		return;
	}

	TR_GetEndPosition(flPos, trace);
	flPos[2] += 5.0;
	delete trace;

	TE_SetupBeamRingPoint(flPos, 300.0, 300.1, iLaserBeam, iHalo, 0, 10, cvarTF2Jail[Markers].FloatValue, 2.0, 0.0, {255, 255, 255, 255}, 10, 0);
	TE_SendToAll();
	gamemode.bMarkerExists = true;
	SetPawnTimer(ResetMarker, 1.0);
	EmitAmbientSound("misc/rd_finale_beep01.wav", flPos); EmitAmbientSound("misc/rd_finale_beep01.wav", flPos);
}

public void ResetMarker()
{
	gamemode.bMarkerExists = false;
}

public bool TraceRayFilterPlayers(int ent, int mask)
{
	return (ent > MaxClients || !ent);
}

int iHHHParticle[MAXPLAYERS + 1][3];
/** ctrl+c
	ctrl+v **/
public void DoHorsemannParticles(const int client)
{
	int lefteye = MakeParticle(client, "halloween_boss_eye_glow", "lefteye");
	if (IsValidEntity(lefteye))
		iHHHParticle[client][0] = EntIndexToEntRef(lefteye);

	int righteye = MakeParticle(client, "halloween_boss_eye_glow", "righteye");
	if (IsValidEntity(righteye))
		iHHHParticle[client][1] = EntIndexToEntRef(righteye);
/*	int bodyglow = MakeParticle(client, "halloween_boss_shape_glow", "");
	if (IsValidEntity(bodyglow))
	{
		iHHHParticle[client][2] = EntIndexToEntRef(bodyglow);
	}*/
}
public void ClearHorsemannParticles(const int client)
{
	int ent;
	for (int i = 0; i < 3; i++)
	{
		ent = EntRefToEntIndex(iHHHParticle[client][i]);
		if (ent > MaxClients && IsValidEntity(ent))
			AcceptEntityInput(ent, "Kill");
		iHHHParticle[client][i] = -1;
	}
}
// From AimNames by -MCG-retsam & Antithasys
int g_iFilteredEntity = -1;
public bool CanSeeTarget(any origin, float pos[3], any target, float targetPos[3], float range)
{
	float dist;
	dist = GetVectorDistanceMeter(pos, targetPos);
	if (dist >= range)
		return false;

	Handle hTraceEx;
	float hitPos[3];
	g_iFilteredEntity = origin;
	hTraceEx = TR_TraceRayFilterEx(pos, targetPos, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilter);

	if (!TR_DidHit(hTraceEx))
	{
		delete hTraceEx;
		return false;
	}
	
	TR_GetEndPosition(hitPos, hTraceEx);
	delete hTraceEx;

	if (GetVectorDistanceMeter(hitPos, targetPos) <= 1.0)
		return true;

	return false;
}

public float UnitToMeter(float distance)
{
	return distance / 50.00;
}

float GetVectorDistanceMeter(const float vec1[3], const float vec2[3], bool squared = false) 
{
	return UnitToMeter(GetVectorDistance(vec1, vec2, squared));
}

public bool TraceFilter(int ent, int contentMask)
{
	return (ent != g_iFilteredEntity);
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
			if (ManageTimeEnd() == Plugin_Continue)
				ForceTeamWin(BLU);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void Open_Doors(const int roundcount)
{
	if (gamemode.bCellsOpened || roundcount != gamemode.iRoundCount || gamemode.iRoundState != StateRunning || gamemode.bFirstDoorOpening)
		return;

	gamemode.DoorHandler(OPEN);
	CPrintToChatAll("{red}[TF2Jail]{tan} The cell doors have opened after %i seconds of remaining closed.", cvarTF2Jail[DoorOpenTimer].IntValue);
	gamemode.bCellsOpened = true;
}

public void EnableFFTimer(const int roundcount)
{
	if (hEngineConVars[0].BoolValue == true || roundcount != gamemode.iRoundCount || gamemode.iRoundState != StateRunning)
		return;

	hEngineConVars[0].SetBool(true);
	CPrintToChatAll("{red}[TF2Jail]{tan} Friendly-Fire has been enabled!");
}

public void FreeKillSystem(const JailFighter attacker, const int killcount)
{	// Ghetto rigged freekill system, gives the info needed for sourcebans
	if (GetClientTeam(attacker.index) != BLU)
		return;

	if (attacker.bIsAdmin) 	// Admin abuse :o
		return;

	if (gamemode.iRoundState != StateRunning)
		return;

	float curtime = GetGameTime();
	if (curtime <= attacker.flKillSpree)
		attacker.iKillCount++;
	else attacker.iKillCount = 0;

	if (attacker.iKillCount == killcount)
	{
		char strIP[32];
		bool messagetype = cvarTF2Jail[FreeKillMessage].BoolValue;
		GetClientIP(attacker.index, strIP, sizeof(strIP));

		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i))
				continue;

			if (JailFighter(i).bIsAdmin)
			{
				if (messagetype)
					CPrintToChat(i, "{red}**********\n%L\nIP:%s\n**********");
				else PrintToConsole(i, "**********\n%L\nIP:%s\n**********", attacker.index, strIP);
			}
		}
		attacker.iKillCount = 0;
	}
	else attacker.flKillSpree = curtime + 15;
}

public void EnableWarden(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount 
	 || gamemode.iRoundState != StateRunning 
	 || !gamemode.bIsWardenLocked 
	 || gamemode.bWardenExists)
		return;

	gamemode.bIsWardenLocked = false;
	CPrintToChatAll("{red}[TF2Jail]{tan} Warden has been enabled.");
}

public Action OnEntSpawn(int ent)
{
	if (IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Handled;
}

// Props to Nergal!!!
stock Handle FindPluginByName(const char name[64]) // Searches in linear time or O(n) but it only searches when TF2Jail's plugin's loaded
{
	char dictVal[64];
	Handle thisPlugin;
	StringMap pluginMap;
	int arraylen = hPlugins.Length;
	for (int i = 0; i < arraylen; ++i) 
	{
		pluginMap = hPlugins.Get(i);
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
	StringMap pluginMap = hPlugins.Get(index);
	if (pluginMap.GetValue("PluginHandle", thisPlugin))
		return thisPlugin;
	return null;
}

public int RegisterPlugin(const Handle pluginhndl, const char modulename[64])
{
	if (!ValidateName(modulename)) 
	{
		LogError("TF2Jail :: Register Plugin  **** Invalid Name For Plugin Registration ****");
		return -1;
	}
	else if (FindPluginByName(modulename) != null) 
	{
		LogError("TF2Jail :: Register Plugin  **** Plugin Already Registered ****");
		return -1;
	}

	// Create dictionary to hold necessary data about plugin
	StringMap PluginMap = new StringMap();
	PluginMap.SetValue("PluginHandle", pluginhndl);
	PluginMap.SetString("PluginName", modulename);

	// Push to global vector
	hPlugins.Push(PluginMap);
	// Push to core last request handle
	arrLRS.Push(0);

	return hPlugins.Length - 1; // Return the index of registered plugin!
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
		/* Functional */
	CreateNative("TF2JailRedux_RegisterPlugin", Native_RegisterPlugin);
	CreateNative("JB_Hook", Native_Hook);
	CreateNative("JB_HookEx", Native_HookEx);
	CreateNative("JB_Unhook", Native_Unhook);
	CreateNative("JB_UnhookEx", Native_UnhookEx);
		/* Player Methodmap*/
	CreateNative("JBPlayer.JBPlayer", Native_JBInstance);
	CreateNative("JBPlayer.userid.get", Native_JBPlayer_Userid);
	CreateNative("JBPlayer.index.get", Native_JBPlayer_Index);
		/* Player */
	CreateNative("JB_GetValue", Native_JB_GetValue);
	CreateNative("JB_SetValue", Native_JB_SetValue);
	CreateNative("JB_SetArray", Native_JB_SetArray);
	CreateNative("JB_SetString", Native_JB_SetString);
	CreateNative("JB_GetArray", Native_JB_GetArray);
	CreateNative("JB_GetString", Native_JB_GetString);
	CreateNative("JB_Remove", Native_JB_Remove);
	CreateNative("JB_Clear", Native_JB_Clear);
	CreateNative("JB_Snapshot", Native_JB_Snapshot);
	CreateNative("JB_Size", Native_JB_Size);
	CreateNative("JB_TeleportToPosition", Native_JB_TeleportToPosition);
	CreateNative("JB_ListLRS", Native_JB_ListLRS);
	CreateNative("JB_MutePlayer", Native_JB_MutePlayer);
	CreateNative("JB_GiveFreeday", Native_JB_GiveFreeday);
	CreateNative("JB_RemoveFreeday", Native_JB_RemoveFreeday);
	CreateNative("JB_UnmutePlayer", Native_JB_UnmutePlayer);
	CreateNative("JB_WardenSet", Native_JB_WardenSet);
	CreateNative("JB_WardenUnset", Native_JB_WardenUnset);
	CreateNative("JB_MakeHorsemann", Native_JB_MakeHorsemann);
	CreateNative("JB_UnHorsemann", Native_JB_UnHorsemann);
	CreateNative("JB_WardenMenu", Native_JB_WardenMenu);
	CreateNative("JB_ClimbWall", Native_JB_ClimbWall);
	CreateNative("JB_NoMusic", Native_JB_NoMusic);
		/* Gamemode */
	CreateNative("JBGameMode_Playing", Native_JBGameMode_Playing);
	CreateNative("JBGameMode_ManageCells", Native_JBGameMode_ManageCells);
	CreateNative("JBGameMode_FindRandomWarden", Native_JBGameMode_FindRandomWarden);
	CreateNative("JBGameMode_FindWarden", Native_JBGameMode_FindWarden);
	CreateNative("JBGameMode_FireWarden", Native_JBGameMode_FireWarden);
	CreateNative("JBGameMode_OpenAllDoors", Native_JBGameMode_OpenAllDoors);
		/* Gamemode StringMap */
	CreateNative("JBGameMode_GetProperty", Native_JBGameMode_GetProperty);
	CreateNative("JBGameMode_SetProperty", Native_JBGameMode_SetProperty);
	CreateNative("JBGameMode_SetArray", Native_JBGameMode_SetArray);
	CreateNative("JBGameMode_SetString", Native_JBGameMode_SetString);
	CreateNative("JBGameMode_GetArray", Native_JBGameMode_GetArray);
	CreateNative("JBGameMode_GetString", Native_JBGameMode_GetString);
	CreateNative("JBGameMode_Remove", Native_JBGameMode_Remove);
	CreateNative("JBGameMode_Clear", Native_JBGameMode_Clear);
	CreateNative("JBGameMode_Snapshot", Native_JBGameMode_Snapshot);
	CreateNative("JBGameMode_Size", Native_JBGameMode_Size);
		/* Gamemode Methodmap */
	CreateNative("JBGameMode.JBGameMode", Native_JBGameMode_Instance);

	RegPluginLibrary("TF2Jail_Redux");
}

public int Native_RegisterPlugin(Handle plugin, int numParams)
{
	char ModuleName[64]; GetNativeString(1, ModuleName, sizeof(ModuleName));
	int plugin_index = RegisterPlugin(plugin, ModuleName); // ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return plugin_index;
}
public int Native_Hook(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	Function Func = GetNativeFunction(2);
	if (hPrivFwds[JBHook] != null)
		AddToForward(hPrivFwds[JBHook], plugin, Func);
}
public int Native_HookEx(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	Function Func = GetNativeFunction(2);
	if (hPrivFwds[JBHook] != null)
		return AddToForward(hPrivFwds[JBHook], plugin, Func);
	return 0;
}
public int Native_Unhook(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	if (hPrivFwds[JBHook] != null)
		RemoveFromForward(hPrivFwds[JBHook], plugin, GetNativeFunction(2));
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	int JBHook = GetNativeCell(1);
	if (hPrivFwds[JBHook] != null)
		return RemoveFromForward(hPrivFwds[JBHook], plugin, GetNativeFunction(2));
	return 0;
}

public int Native_JBInstance(Handle plugin, int numParams)
{
	JailFighter player = JailFighter(GetNativeCell(1), GetNativeCell(2));
	return view_as< int >(player);
}
public int Native_JBPlayer_Userid(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	return player.userid;
}
public int Native_JBPlayer_Index(Handle plugin, int numParams)
{
	JailFighter player = GetNativeCell(1);
	return player.index;
}

public int Native_JB_GetValue(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	any item;
	if (hJailFields[client].GetValue(key, item))
		return item;
	return 0;
}
public int Native_JB_SetValue(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	any item = GetNativeCell(3);
	return hJailFields[client].SetValue(key, item);
}
public int Native_JB_SetArray(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	int length = GetNativeCell(4);
	any[] array = new any[length];
	GetNativeArray(3, array, length);
	bool replace = GetNativeCell(5);
	return hJailFields[client].SetArray(key, array, length, replace);
}
public int Native_JB_SetString(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	int len; GetNativeStringLength(3, len);
	++len;
	char[] val = new char[len];
	GetNativeString(3, val, len);
	bool replace = GetNativeCell(4);
	return hJailFields[client].SetString(key, val, replace);
}
public int Native_JB_GetArray(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	int length = GetNativeCell(4);
	any[] array = new any[length];
	GetNativeArray(3, array, length);
	int size = GetNativeCellRef(5);
	return hJailFields[client].GetArray(key, array, length, size);
}
public int Native_JB_GetString(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	int len; GetNativeStringLength(3, len);
	++len;
	char[] val = new char[len];
	GetNativeString(3, val, len);
	int size = GetNativeCellRef(4);
	return hJailFields[client].GetString(key, val, len, size);
}
public int Native_JB_Remove(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char key[64]; GetNativeString(2, key, 64);
	return hJailFields[client].Remove(key);
}
public int Native_JB_Clear(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	hJailFields[client].Clear();
}
public int Native_JB_Snapshot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return view_as< int >(hJailFields[client].Snapshot());
}
public int Native_JB_Size(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return hJailFields[client].Size;
}
public int Native_JB_TeleportToPosition(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int location = GetNativeCell(2);
	JailFighter(client).TeleportToPosition(location);
}
public int Native_JB_ListLRS(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).ListLRS();
}
public int Native_JB_MutePlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).MutePlayer();
}
public int Native_JB_GiveFreeday(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).GiveFreeday();
}
public int Native_JB_RemoveFreeday(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).RemoveFreeday();
}
public int Native_JB_UnmutePlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).UnmutePlayer();
}
public int Native_JB_WardenSet(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).WardenSet();
}
public int Native_JB_WardenUnset(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).WardenUnset();
}
public int Native_JB_MakeHorsemann(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).MakeHorsemann();
}
public int Native_JB_UnHorsemann(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).UnHorsemann();
}
public int Native_JB_WardenMenu(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	JailFighter(client).WardenMenu();
}
public int Native_JB_ClimbWall(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int wep = GetNativeCell(2);
	float spawntime = view_as< float >(GetNativeCell(3));
	float healthdmg = view_as< float >(GetNativeCell(4));
	bool attackdelay = GetNativeCell(5);
	JailFighter(client).ClimbWall(wep, spawntime, healthdmg, attackdelay);
}
public int Native_JB_NoMusic(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return JailFighter(client).bNoMusic;
}

public int Native_JBGameMode_Playing(Handle plugin, int numParams)
{
	return gamemode.iPlaying;
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
public int Native_JBGameMode_FindWarden(Handle plugin, int numParams)
{
	return view_as< int >(gamemode.FindWarden());
}
public int Native_JBGameMode_FireWarden(Handle plugin, int numParams)
{
	bool prevent = GetNativeCell(1);
	bool announce = GetNativeCell(2);
	gamemode.FireWarden(prevent, announce);
}
public int Native_JBGameMode_OpenAllDoors(Handle plugin, int numParams)
{
	gamemode.OpenAllDoors();
}

public int Native_JBGameMode_GetProperty(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	any item;
	if (gamemode.GetValue(key, item))
		return item;
	return 0;
}
public int Native_JBGameMode_SetProperty(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	any item = GetNativeCell(2);
	gamemode.SetValue(key, item);
}
public int Native_JBGameMode_SetArray(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int length = GetNativeCell(3);
	any[] array = new any[length];
	GetNativeArray(2, array, length);
	bool replace = GetNativeCell(4);
	return gamemode.SetArray(key, array, length, replace);
}
public int Native_JBGameMode_SetString(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len; GetNativeStringLength(2, len);
	++len;
	char[] val = new char[len];
	GetNativeString(2, val, len);
	bool replace = GetNativeCell(3);
	return gamemode.SetString(key, val, replace);
}
public int Native_JBGameMode_GetArray(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int length = GetNativeCell(3);
	any[] array = new any[length];
	GetNativeArray(2, array, length);
	int size = GetNativeCellRef(4);
	return gamemode.GetArray(key, array, length, size);
}
public int Native_JBGameMode_GetString(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len; GetNativeStringLength(2, len);
	++len;
	char[] val = new char[len];
	GetNativeString(2, val, len);
	int size = GetNativeCellRef(3);
	return gamemode.GetString(key, val, len, size);
}
public int Native_JBGameMode_Remove(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	return gamemode.Remove(key);
}
public int Native_JBGameMode_Clear(Handle plugin, int numParams)
{
	gamemode.Clear();
}
public int Native_JBGameMode_Snapshot(Handle plugin, int numParams)
{
	return view_as< int >(gamemode.Snapshot());
}
public int Native_JBGameMode_Size(Handle plugin, int numParams)
{
	return gamemode.Size;
}

public int Native_JBGameMode_Instance(Handle plugin, int numParams)
{
	return view_as< int >(gamemode);
}
