/*	  _____   _____   ____        _           _   _     ____               _                
	 |_   _| |  ___| |___ \      | |   __ _  (_) | |   |  _ \    ___    __| |  _   _  __  __
	   | |   | |_      __) |  _  | |  / _` | | | | |   | |_) |  / _ \  / _` | | | | | \ \/ /
	   | |   |  _|    / __/  | |_| | | (_| | | | | |   |  _ <  |  __/ | (_| | | |_| |  >  < 
	   |_|   |_|     |_____|  \___/   \__,_| |_| |_|   |_| \_\  \___|  \__,_|  \__,_| /_/\_\ */

#if SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR <= 9
  #error This plugin requires SourceMod 1.10 and above
#endif

#define PLUGIN_NAME 		"[TF2] Jailbreak Redux"
#define PLUGIN_VERSION 		"2.0.1Beta"
#define PLUGIN_AUTHOR 		"Scag/Ragenewb, props to Drixevel and Nergal/Assyrian"
#define PLUGIN_DESCRIPTION 	"Deluxe version of TF2Jail"

#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <tf2jailredux>
#include <clientprefs>
#include <tf2items>
#include <tf2_stocks>
#include <sdktools>

#undef REQUIRE_EXTENSIONS
#tryinclude <SteamWorks>
#define REQUIRE_EXTENSIONS

#undef REQUIRE_PLUGIN
#include <tf2attributes>
#include <basecomm>
#tryinclude <sourcebanspp>
#if !defined _sourcebanspp_included
#tryinclude <sourcebans>
#endif
#tryinclude <sourcecomms>
#tryinclude <voiceannounce_ex>
#tryinclude <tf_ontakedamage>
#define REQUIRE_PLUGIN

#pragma semicolon 			1
#pragma newdecls 			required

#define RED 				2
#define BLU 				3
#define MAX_TF_PLAYERS 		34	// 32 + replay + console

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
	BlueCritType,
	MuteType,
	LivingMuteType,
	Disguising,
	WardenDelay,
	LRDefault,
	FreeKill,
	FreeKillTime,
	FreeKillMessage,
	AutobalanceImmunity,
	NoCharge,
	NoAirblast,
	NoDoubleJump,
	DenyLR,
	WardenLaser,
	WardenToggleMedic,
	Advert,
	WardenAnnotation,
	MarkerType,
	EngieBuildings,
	LRTimer,
	WardenFiring,
	WardenFiringRatio,
	NoCritOnLock,
	Rebellers,
	RebelTime,
	RendererColor,
	RendererParticles,
	LocDistance,
	HideParticles,
	WardenInvite,
	WardenToggleMuting,
	MedicLoseFreeday,
	FreedayBeamLifetime,
	WardenDelay2,
	WardenStabProtect,
	WardenStabCount,
	ImmunityDuringLRSelect,
	FFType,
	WardenSetHP,
	Version
};

enum struct TextNodeParam
{	// Hud Text Parameters
	float fCoord_X;
	float fCoord_Y;
	float fHoldTime;
	int iRed;
	int iBlue;
	int iGreen;
	int iAlpha;
	int iEffect;
	float fFXTime;
	float fFadeIn;
	float fFadeOut;
}

TextNodeParam EnumTNPS[4];

enum struct TargetFilter
{	// Custom target filters allocated by config
	float vecLoc[3];
	float flDist;
	bool bML;
	char strDescriptN[64];
	char strDescriptA[64];
	char strName[32];	// If you have a filter > 32 chars then you got some serious problems
}

// If adding new cvars put them above Version in the enum
ConVar
	cvarTF2Jail[Version + 1],
	bEnabled,
	hEngineConVars[2]
;

Handle
	hTextNodes[4],
	AimHud
;

Cookie
	MusicCookie
;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

#include "TF2JailRedux/stocks.inc"
#include "TF2JailRedux/jailbase.sp"
#include "TF2JailRedux/jailgamemode.sp"

JailGameMode gamemode;

#include "TF2JailRedux/jailhandler.sp"
#include "TF2JailRedux/jailforwards.sp"
#include "TF2JailRedux/jailevents.sp"
#include "TF2JailRedux/jailcommands.sp"
#include "TF2JailRedux/targetfilters.sp"
#include "TF2JailRedux/functable.sp"
#include "TF2JailRedux/natives.sp"

public void OnPluginStart()
{
	gamemode = new JailGameMode();

	LoadTranslations("common.phrases");
	LoadTranslations("tf2jail_redux.phrases");

	bEnabled 								= CreateConVar("sm_tf2jr_enable", "1", "Status of the plugin: (1 = on, 0 = off)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Version] 					= CreateConVar("tf2jr_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
	cvarTF2Jail[Balance] 					= CreateConVar("sm_tf2jr_auto_balance", "1", "Should the plugin autobalance teams?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[BalanceRatio] 				= CreateConVar("sm_tf2jr_balance_ratio", "0.5", "Ratio for autobalance: (Example: 0.5 = 2:4)", FCVAR_NOTIFY, true, 0.1, true, 1.0);
	cvarTF2Jail[DoorOpenTimer] 				= CreateConVar("sm_tf2jr_cell_timer", "60", "Time after Arena round start to open doors.", FCVAR_NOTIFY, true, 0.0, true, 120.0);
	cvarTF2Jail[FreedayLimit] 				= CreateConVar("sm_tf2jr_freeday_limit", "3", "Max number of freedays for the Freeday For Others lr.", FCVAR_NOTIFY, true, 1.0, true, 16.0);
	cvarTF2Jail[KillPointServerCommand] 	= CreateConVar("sm_tf2jr_point_servercommand", "1", "Kill 'point_servercommand' entities.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLR] 			= CreateConVar("sm_tf2jr_freeday_removeonlr", "1", "Remove Freedays on Last Request.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RemoveFreedayOnLastGuard] 	= CreateConVar("sm_tf2jr_freeday_removeonlastguard", "1", "Remove Freedays on Last Guard.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenTimer] 				= CreateConVar("sm_tf2jr_warden_timer", "20", "Time in seconds after Warden is unset or lost to lock Warden.", FCVAR_NOTIFY, true, 1.0);
	cvarTF2Jail[RoundTimerStatus]			= CreateConVar("sm_tf2jr_roundtimer_status", "1", "Status of the round timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RoundTime] 					= CreateConVar("sm_tf2jr_roundtimer_time", "600", "Amount of time normally on the timer (if enabled).", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RoundTime_Freeday] 			= CreateConVar("sm_tf2jr_roundtimer_time_freeday", "300", "Amount of time on 1st day freeday.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RebelAmmo] 					= CreateConVar("sm_tf2jr_red_ammo", "1", "What should happen when Prisoners get ammo? 0 = nothing; 1 = remove Freedays of said prisoner; 2 = mark player as rebel", FCVAR_NOTIFY, true, 0.0, true, 2.00);
	cvarTF2Jail[DroppedWeapons] 			= CreateConVar("sm_tf2jr_dropped_weapons", "1", "Should dropped weapons be killed on spawn?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[VentHit] 					= CreateConVar("sm_tf2jr_vent_freeday", "1", "Should freeday players lose their freeday if they hit/break a vent?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[SeeNames] 					= CreateConVar("sm_tf2jr_wardensee", "1", "Allow the Warden to see prisoner names?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NameDistance] 				= CreateConVar("sm_tf2jr_wardensee_distance", "800", "From how far can the Warden see prisoner names? (Hammer Units)", FCVAR_NOTIFY, true, 0.0, true, 1000.0);
	cvarTF2Jail[SeeHealth] 					= CreateConVar("sm_tf2jr_wardensee_health", "1", "Can the Warden see prisoner health?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EnableMusic] 				= CreateConVar("sm_tf2jr_music_on", "1", "Enable background music that could possibly play with last requests?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[MusicVolume] 				= CreateConVar("sm_tf2jr_music_volume", ".5", "Volume in which background music plays. (If enabled)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EurekaTimer] 				= CreateConVar("sm_tf2jr_eureka_teleport", "20", "How long must players wait until they are able to Eureka Effect Teleport again? (0 to disable cooldown)", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[VIPFlag] 					= CreateConVar("sm_tf2jr_vip_flag", "a", "What admin flags do VIP players fall under? Leave blank to disable VIP perks.", FCVAR_NOTIFY);
	cvarTF2Jail[AdmFlag] 					= CreateConVar("sm_tf2jr_admin_flag", "b", "What admin flags do admins fall under? Leave blank to disable Admin perks.", FCVAR_NOTIFY);
	cvarTF2Jail[DisableBlueMute] 			= CreateConVar("sm_tf2jr_blue_mute", "1", "Disable joining blue team for muted players?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Markers] 					= CreateConVar("sm_tf2jr_warden_markers", "3", "Warden markers lifetime in seconds? (0 to disable them entirely)", FCVAR_NOTIFY, true, 0.0, true, 30.0);
	cvarTF2Jail[BlueCritType] 				= CreateConVar("sm_tf2jr_criticals", "2", "What type of criticals should guards get? 0 = none; 1 = mini-crits; 2 = full crits", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvarTF2Jail[MuteType] 					= CreateConVar("sm_tf2jr_muting", "6", "What type of dead player muting should occur? 0 = none; 1 = red players(except VIPs); 2 = blue players(except VIPs); 3 = all players(except VIPs); 4 = all red players; 5 = all blue players; 6 = everybody. ADMINS ARE EXEMPT FROM ALL OF THESE!", FCVAR_NOTIFY, true, 0.0, true, 6.0);
	cvarTF2Jail[LivingMuteType] 			= CreateConVar("sm_tf2jr_live_muting", "1", "What type of living player muting should occur? 0 = none; 1 = red players(except VIPs); 2 = blue players(except VIPs and warden); 3 = all players(except VIPs and warden); 4 = all red players; 5 = all blue players(except warden); 6 = everybody(except warden). ADMINS ARE EXEMPT FROM ALL OF THESE!", FCVAR_NOTIFY, true, 0.0, true, 6.0);
	cvarTF2Jail[Disguising] 				= CreateConVar("sm_tf2jr_disguising", "0", "What teams can disguise, if any? (Your Eternal Reward only) 0 = no disguising; 1 = only Red can disguise; 2 = Only blue can disguise; 3 = all players can disguise", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarTF2Jail[WardenDelay] 				= CreateConVar("sm_tf2jr_warden_delay", "0", "Delay in seconds after round start until players can toggle becoming the warden. 0 to disable delay. -1 to automatically pick a warden on round start.", FCVAR_NOTIFY, true, -1.0);
	cvarTF2Jail[LRDefault] 					= CreateConVar("sm_tf2jr_lr_default", "5", "Default number of times the basic last requests can be picked in a single map. 0 for no limit.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[FreeKill] 					= CreateConVar("sm_tf2jr_freekill", "3", "How many kills in a row must a player get before the freekiller system activates? 0 to disable. (This does not affect gameplay, prints SourceBans information to admin consoles determined by \"sm_tf2jr_admin_flag\").", FCVAR_NOTIFY, true, 0.0, true, 33.0);
	cvarTF2Jail[FreeKillTime] 				= CreateConVar("sm_tf2jr_freekill_time", "15", "Maximum time between kills in order to increment a would-be freekiller's kill count.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[FreeKillMessage] 			= CreateConVar("sm_tf2jr_freekill_message", "0", "If \"sm_tf2jr_freekill\" is enabled, how are admins to be notified of a freekiller? 0 = Console message; 1 = Chat message.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[AutobalanceImmunity] 		= CreateConVar("sm_tf2jr_auto_balance_immunity", "1", "Allow VIP's/admins to have autobalance immunity? (If autobalancing is enabled). 0 = disabled; 1 = VIPs only; 2 = Admins only", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvarTF2Jail[NoCharge] 					= CreateConVar("sm_tf2jr_demo_charge", "3", "Disable DemoMan's charge ability? 0 = Allow; 1 = Disable for Blue team; 2 = Disable for Red team; 3 = Disable for all", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarTF2Jail[NoAirblast] 				= CreateConVar("sm_tf2jr_airblast", "1", "Disable Pyro airblast? (Requires TF2Attributes)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[NoDoubleJump] 				= CreateConVar("sm_tf2jr_double_jump", "1", "Disable Scout double jump? (Requires TF2Attributes)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[DenyLR] 					= CreateConVar("sm_tf2jr_warden_deny_lr", "1", "Allow Wardens to deny the queued last request?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenLaser] 				= CreateConVar("sm_tf2jr_warden_laser", "1", "Allow Wardens to use laser pointers?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenToggleMedic] 			= CreateConVar("sm_tf2jr_warden_toggle_medic", "0", "Allow Wardens to toggle the medic room?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Advert] 					= CreateConVar("sm_tf2jr_advertisement", "540", "Time in seconds to display the chat advertisement. 0 to disable.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[WardenAnnotation] 			= CreateConVar("sm_tf2jr_warden_annotation", "5", "Display an annotation over the Warden's head on get? If so, how long in seconds?", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[MarkerType] 				= CreateConVar("sm_tf2jr_warden_marker_type", "0", "If \"sm_tf2jr_warden_markers\" is enabled, what type of markers should there be? 0 = Circles; 1 = Annotations.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[EngieBuildings] 			= CreateConVar("sm_tf2jr_engi_pda", "0", "Allow Engineers to keep their PDA's? 0 = None; 1 = Red team PDA's only; 2 = Blue team PDA's only; 3 = Everyone keeps their PDA", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarTF2Jail[LRTimer] 					= CreateConVar("sm_tf2jr_lr_timer", "0", "When an LR is given, should the round timer be set to a certain time? 0 to disable.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[WardenFiring] 				= CreateConVar("sm_tf2jr_warden_fire", "0", "Allow players vote to fire the current Warden?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenFiringRatio] 			= CreateConVar("sm_tf2jr_warden_fire_ratio", "0.6", "Percentage of players required for fire Wardens.", FCVAR_NOTIFY, true, 0.05, true, 1.0);
	cvarTF2Jail[NoCritOnLock] 				= CreateConVar("sm_tf2jr_crit_on_lock", "0", "When Warden locks, should guards lose their crits?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[Rebellers] 					= CreateConVar("sm_tf2jr_rebellers", "0", "Enable the Rebel system.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RebelTime] 					= CreateConVar("sm_tf2jr_rebel_timer", "30", "Timer for the Rebel system, if it's enabled.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[RendererColor] 				= CreateConVar("sm_tf2jr_renderer_color", "1" ,"Parse renderer colors from the \"TF2Jail_RoleRenders\" config?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[RendererParticles] 			= CreateConVar("sm_tf2jr_renderer_particles", "1", "Parse renderer particles from the \"TF2Jail_RoleRenders\" config?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[LocDistance]				= CreateConVar("sm_tf2jr_filter_distance", "300", "Distance (hu) to register players as in the area of the location target filters. (@freedayloc, @wardayloc, etc)", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[HideParticles] 				= CreateConVar("sm_tf2jr_hide_particles", "1", "Hide renderer particles from players when they are cloaked?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenInvite] 				= CreateConVar("sm_tf2jr_warden_invite", "0", "Allow the Warden to invite players to the Guards' team?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenToggleMuting] 		= CreateConVar("sm_tf2jr_warden_mute", "0", "Allow the Warden to toggle plugin muting?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[MedicLoseFreeday] 			= CreateConVar("sm_tf2jr_medic_freeday", "2", "If a Medic with a freeday is healing rebels, should that medic lose freeday? If so, how long must they heal said rebels?", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[FreedayBeamLifetime] 		= CreateConVar("sm_tf2jr_freeday_beamtime", "10", "Time in seconds for the Freeday beam's lifetime.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[WardenDelay2] 				= CreateConVar("sm_tf2jr_warden_delay2", "0", "If \"sm_tf2jr_warden_delay\" is -1, Time in seconds after the round starts to randomly select a warden.", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[WardenStabProtect] 			= CreateConVar("sm_tf2jr_warden_stab", "0.0", "The amount of damage reduction for wardens against backstabs. Ex: 0 -> no change; 0.6 -> 60%; 1.0 -> 100% damage resistance.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenStabCount] 			= CreateConVar("sm_tf2jr_warden_stabcount", "0", "If \"sm_tf2jr_warden_stab\" is not 0.0, how many backstabs will the damage effect protect? 0 -> infinite", FCVAR_NOTIFY, true, 0.0);
	cvarTF2Jail[ImmunityDuringLRSelect] 	= CreateConVar("sm_tf2jr_lr_select_godmode", "0", "When a player is selecting their last request, should they receive damage immunity? This will not apply to environmental damage", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[FFType] 					= CreateConVar("sm_tf2jr_warden_friendlyfire_type", "0", "When a warden toggles friendly-fire, should only prisoners be able to damage each other? Guards will not deal damage to each other.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTF2Jail[WardenSetHP] 				= CreateConVar("sm_tf2jr_warden_set_hp", "0", "Should the warden be able to restore health for prisoners?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig(true, "TF2JailRedux");

		/* Used in core*/
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", OnPlayerDamaged, EventHookMode_Pre);
	HookEvent("teamplay_round_start", OnPreRoundStart);
	HookEvent("arena_round_start", OnArenaRoundStart);
	HookEvent("teamplay_round_win", OnRoundEnded);
	HookEvent("post_inventory_application", OnRegeneration);
	HookEvent("player_changeclass", OnChangeClass, EventHookMode_Pre);
	HookEvent("player_team", OnChangeTeam);
	// HookEvent("player_disconnect", OnDisconnect, EventHookMode_Pre);
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
	RegConsoleCmd("sm_jbmusic", Command_MusicOff, "Client cookie that disables LR background music (if it exists).");
	RegConsoleCmd("sm_jailmusic", Command_MusicOff, "Client cookie that disables LR background music (if it exists).");
	RegConsoleCmd("sm_wmarker", Command_WardenMarker, "Allows the Warden to create a marker that players can see/hear.");
	RegConsoleCmd("sm_wmk", Command_WardenMarker, "Allows the Warden to create a marker that players can see/hear.");
	RegConsoleCmd("sm_wlaser", Command_WardenLaser, "Allows the Warden to use a laser pointer by holding Reload.");
	RegConsoleCmd("sm_wl", Command_WardenLaser, "Allows the Warden to use a laser pointer by holding Reload.");
	RegConsoleCmd("sm_wtm", Command_WardenToggleMedic, "Allows the Warden to toggle the medic room.");
	RegConsoleCmd("sm_wtmedic", Command_WardenToggleMedic, "Allows the Warden to toggle the medic room.");
	RegConsoleCmd("sm_wtogglemedic", Command_WardenToggleMedic, "Allows the Warden to toggle the medic room.");
	RegConsoleCmd("sm_fire", Command_FireWarden, "Vote for Warden to be fired.");
	RegConsoleCmd("sm_firewarden", Command_FireWarden, "Vote for Warden to be fired.");
	RegConsoleCmd("sm_winv", Command_WardenInvite, "Allows the Warden to invite players to the Guards team.");
	RegConsoleCmd("sm_wardeninv", Command_WardenInvite, "Allows the Warden to invite players to the Guards team.");
	RegConsoleCmd("sm_wmute", Command_WardenToggleMuting, "Allows the Warden to toggle plugin muting.");
	RegConsoleCmd("sm_wardenmute", Command_WardenToggleMuting, "Allows the Warden to toggle plugin muting.");
	RegConsoleCmd("sm_wardenhp", Command_WardenHP, "Allows the Warden to reset the health of prisoners.");
	RegConsoleCmd("sm_whp", Command_WardenHP, "Allows the Warden to reset the health of prisoners.");
	RegConsoleCmd("sm_whealth", Command_WardenHP, "Allows the Warden to reset the health of prisoners.");

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
	RegAdminCmd("sm_gf", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Freeday.");
	RegAdminCmd("sm_givefreeday", AdminGiveFreeday, ADMFLAG_GENERIC, "Give a client on the server a Freeday.");
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
	RegAdminCmd("sm_startwarday", AdminFullWarday, ADMFLAG_GENERIC, "Teleport all players to their warday teleport location.");
	RegAdminCmd("sm_sw", AdminFullWarday, ADMFLAG_GENERIC, "Teleport all players to their warday teleport location.");
	RegAdminCmd("sm_tm", AdminToggleMedic, ADMFLAG_GENERIC, "Toggle the medic room.");
	RegAdminCmd("sm_tmedic", AdminToggleMedic, ADMFLAG_GENERIC, "Toggle the medic room.");
	RegAdminCmd("sm_togglemedic", AdminToggleMedic, ADMFLAG_GENERIC, "Toggle the medic room.");
	RegAdminCmd("sm_reloadjailcfg", AdminReloadCFG, ADMFLAG_GENERIC, "Reload TF2Jail Redux's config file.");
	RegAdminCmd("sm_jtime", AdminJailTime, ADMFLAG_GENERIC, "Set the jail round time.");
	RegAdminCmd("sm_jt", AdminJailTime, ADMFLAG_GENERIC, "Set the jail round time.");

	RegAdminCmd("sm_setpreset", SetPreset, ADMFLAG_GENERIC, "Set gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_itype", Type, ADMFLAG_GENERIC, "gamemode.iLRType. (DEBUGGING)");
	RegAdminCmd("sm_ipreset", Preset, ADMFLAG_GENERIC, "gamemode.iLRPresetType. (DEBUGGING)");
	RegAdminCmd("sm_getprop", GameModeProp, ADMFLAG_GENERIC, "Retrieve a gamemode property value. (DEBUGGING)");
	RegAdminCmd("sm_getpprop", BaseProp, ADMFLAG_GENERIC, "Retrieve a base player property value. (DEBUGGING)");
	RegAdminCmd("sm_lrlen", hLRSLength, ADMFLAG_GENERIC, "gamemode.hLRS.Size. (DEBUGGING)");
	RegAdminCmd("sm_jailreset", AdminResetPlugin, ADMFLAG_ROOT, "Reset all plug-in global variables. (DEBUGGING)");

	hEngineConVars[0] = FindConVar("mp_friendlyfire");
	hEngineConVars[1] = FindConVar("tf_avoidteammates_pushaway");

	AimHud = CreateHudSynchronizer();

	AddMultiTargetFilter("@warden", WardenGroup, "The Warden.", false);
	AddMultiTargetFilter("@!warden", WardenGroup, "All but the Warden.", false);
	AddMultiTargetFilter("@freedays", FreedaysGroup, "All Freedays.", false);
	AddMultiTargetFilter("@!freedays", FreedaysGroup, "All but the Freedays", false);
	AddMultiTargetFilter("@rebels", RebelsGroup, "All Rebels", false);
	AddMultiTargetFilter("@!rebels", RebelsGroup, "All but the Rebels", false);
	// Target filters are cool! Who can disagree?
	AddMultiTargetFilter("@freedayloc", FreedayLocGroup, "The Freeday location", false);
	AddMultiTargetFilter("@!freedayloc", FreedayLocGroup, "All but the Freeday location", false);
	AddMultiTargetFilter("@wardayred", WardayRedLocGroup, "The Red Warday location", false);
	AddMultiTargetFilter("@!wardayred", WardayRedLocGroup, "All but the Red Warday location", false);
	AddMultiTargetFilter("@wardayblue", WardayBluLocGroup, "The Blue Warday location", false);
	AddMultiTargetFilter("@!wardayblue", WardayBluLocGroup, "All but the Blue Warday location", false);
	AddMultiTargetFilter("@wardayloc", WardayAnyLocGroup, "The Warday locations", false);
	AddMultiTargetFilter("@!wardayloc", WardayAnyLocGroup, "All but the Warday locations", false);
	AddMultiTargetFilter("@medic", MedicLocGroup, "The Medic Room", false);
	AddMultiTargetFilter("@!medic", MedicLocGroup, "All but the Medic Room", false);

	AddNormalSoundHook(SoundHook);

	MusicCookie = new Cookie("sm_tf2jr_music", "Determines if client wishes to listen to background music played by the plugin/LRs", CookieAccess_Protected);

	int i;

	for (i = MaxClients; i; --i) 
	{
		if (IsClientConnected(i))
			OnClientConnected(i);

		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
			OnClientPostAdminCheck(i);
		}
	}

	for (i = 0; i < sizeof(hTextNodes); i++)
		hTextNodes[i] = CreateHudSynchronizer();

	hJailFields[0] = new StringMap();

	HookEntityOutput("item_ammopack_full", "OnCacheInteraction", OnTakeAmmo);
	HookEntityOutput("item_ammopack_medium", "OnCacheInteraction", OnTakeAmmo);
	HookEntityOutput("item_ammopack_small", "OnCacheInteraction", OnTakeAmmo);
	HookEntityOutput("tf_ammo_pack", "OnCacheInteraction", OnTakeAmmo);

	ParseLRConfig();	// Only happens once
}

public void OnLibraryAdded(const char[] name)
{
#if defined _SteamWorks_Included
	if (!strcmp(name, "SteamWorks", false))
		g_bSteam = true;
#endif
#if defined _sourcebans_included || defined _sourcebanspp_included
//	if (!StrContains(name, "sourcebans", false))
//		g_bSB = true;
#endif
#if defined _voiceannounce_ex_included
//	if (!strcmp(name, "voiceannounce_ex", false))
//		g_bVA = true;
#endif
#if defined __tf_ontakedamage_included
	if (!strcmp(name, "tf_ontakedamage", false))
		g_bTFOTD = true;
#endif
	if (!StrContains(name, "sourcecomms", false))
		g_bSC = true;
	if (!strcmp(name, "tf2attributes", false))
		g_bTF2Attribs = true;
}

public void OnLibraryRemoved(const char[] name)
{
#if defined _SteamWorks_Included
	if (!strcmp(name, "SteamWorks", false))
		g_bSteam = false;
#endif
#if defined _sourcebans_included || defined _sourcebanspp_included
//	if (!StrContains(name, "sourcebans"))
//		g_bSB = false;
#endif
#if defined _voiceannounce_ex_included
//	if (!strcmp(name, "voiceannounce_ex", false))
//		g_bVA = false;
#endif
#if defined __tf_ontakedamage_included
	if (!strcmp(name, "tf_ontakedamage", false))
		g_bTFOTD = false;
#endif
	if (!StrContains(name, "sourcecomms", false))
		g_bSC = false;
	if (!strcmp(name, "tf2attributes", false))
		g_bTF2Attribs = false;
}

public void OnPluginEnd()
{
	StopBackGroundMusic();

	if (gamemode.iRoundState == StateRunning)
	{
//		OnRoundEnded(null, "", false);	// Ok sourcemod, you win
		// OnLibraryRemoved for myself fires before OnPluginEnd,
		// so that means that the current lr (if there was one)
		// would/could have its handle freed, and then we can't fire 
		// functions for it because it's null!

		// SOOOO. DONT RELOAD THE PLUGIN DURING AN LR THAT SETS
		// CONVARS AND SHIT YOU FUCKIGAHDFBSUHNJSF
	}

	ConvarsSet(false);

	int i, u;
	for (i = MaxClients; i; --i)
		if (IsClientInGame(i))
			for (u = 0; u < sizeof(hTextNodes); ++u)
				if (hTextNodes[u] != null)
					ClearSyncHud(i, hTextNodes[u]);
}

public void OnMapStart()
{
	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	float time = cvarTF2Jail[Advert].FloatValue;
	if (time != 0.0)
		CreateTimer(time, Timer_Announce, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	gamemode.b1stRoundFreeday = true;
	gamemode.iRoundCount = 0;

	ManageDownloads();	// Handler

	// This code isn't mine, but idk who did this before
//	HookEntityOutput("item_ammopack_full", "OnCacheInteraction", OnTakeAmmo);
//	HookEntityOutput("item_ammopack_medium", "OnCacheInteraction", OnTakeAmmo);
//	HookEntityOutput("item_ammopack_small", "OnCacheInteraction", OnTakeAmmo);
//	HookEntityOutput("tf_ammo_pack", "OnCacheInteraction", OnTakeAmmo);
//	https://github.com/alliedmodders/sourcemod/blob/master/extensions/sdktools/outputnatives.cpp#L141-L144 ;-;

	int len = gamemode.hLRCount.Length;
	int i;
	for (i = 0; i < len; ++i)
		gamemode.hLRCount.Set(i, 0);

	if (!bLate)
	{
		gamemode.iVotesNeeded = 0;
		gamemode.ResetVotes();
	}
	else bLate = false;
}

public void OnConfigsExecuted()
{
	if (!bEnabled.BoolValue)
		return;

	ConvarsSet(true);
	ParseConfigs(); // Parse all configuration files under 'addons/sourcemod/configs/tf2jail/...'.
	BuildMenu();

#if defined _SteamWorks_Included
	if (g_bSteam)
	{
		char sDescription[32];
		FormatEx(sDescription, sizeof(sDescription), "TF2Jail Redux v%s", PLUGIN_VERSION);
		SteamWorks_SetGameDescription(sDescription);
	}
#endif
}

public void OnMapEnd()
{
	// gamemode.Init();		// Clears plugin/extension dependencies
	StopBackGroundMusic();

	if (gamemode.iRoundState == StateRunning)
		OnRoundEnded(null, "", false);

	gamemode.iLRPresetType = -1;

	ConvarsSet(false);

	int i, u;
	for (i = MaxClients; i; --i)
		if (IsClientInGame(i))
			for (u = 0; u < sizeof(hTextNodes); ++u)
				if (hTextNodes[u] != null)
					ClearSyncHud(i, hTextNodes[u]);
}

public void OnClientConnected(int client)
{
	if (hJailFields[client])
		delete hJailFields[client];

	hJailFields[client] = new StringMap();

	JailFighter player = JailFighter(client);
	player.bVoted = false;
	player.bIsVIP = false;
	player.bIsAdmin = false;
	player.bIsMuted = false;

	gamemode.iVoters++;
	gamemode.iVotesNeeded = RoundToFloor(float(gamemode.iVoters) * cvarTF2Jail[WardenFiringRatio].FloatValue);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnPlayerTakeDamageAlive);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_PreThink, PreThink);

	JailFighter player = JailFighter(client);
	player.iCustom = 0;
	player.iKillCount = 0;
	player.iRebelParticle = -1;
	player.iWardenParticle = -1;
	player.iFreedayParticle = -1;
	player.iHealth = 0;
	player.nWardenStabbed = 0;
	player.bIsWarden = false;
	player.bIsQueuedFreeday = false;
	player.bIsFreeday = false;
	player.bLockedFromWarden = false;
	//player.bIsVIP = false;
	//player.bIsAdmin = false;
	player.bInJump = false;
	player.bUnableToTeleport = false;
	player.bLasering = false;
	player.bIsRebel = false;
	player.bSkipPrep = false;
	player.bSelectingLR = false;
	player.flSpeed = 0.0;
	player.flKillingSpree = 0.0;
	player.flHealTime = 0.0;
	player.hRebelTimer = null;

	SetPawnTimer(WelcomeMessage, 5.0, player.userid);
	ManageClientStartVariables(player);
}

public void OnClientPostAdminCheck(int client)
{
	char strVIP[16]; cvarTF2Jail[VIPFlag].GetString(strVIP, sizeof(strVIP));
	char strAdmin[16]; cvarTF2Jail[AdmFlag].GetString(strAdmin, sizeof(strAdmin));

	JailFighter player = JailFighter(client);

	player.bIsVIP = (strVIP[0] != '\0' && IsValidAdmin(client, strVIP)); // Very useful stock ^^
	player.bIsAdmin = (strAdmin[0] != '\0' && IsValidAdmin(client, strAdmin));

	if (!AlreadyMuted(client))
		SetClientListeningFlags(client, VOICE_NORMAL);
	// Brute force them to be unmuted, then let properties take over
	gamemode.ToggleMuting(player);
}

public void OnClientDisconnect(int client)
{
	JailFighter player = JailFighter(client);

	if (player.bVoted)
		gamemode.iVotes--;

	gamemode.iVoters--;
	gamemode.iVotesNeeded = RoundToFloor(float(gamemode.iVoters) * cvarTF2Jail[WardenFiringRatio].FloatValue);

	if (player.bIsWarden)
	{
		player.WardenUnset();
		PrintCenterTextAll("%t", "Warden Disconnected");
	}
	// If they're warden, they wouldn't vote... right?
	else if (gamemode.iVotes >= gamemode.iVotesNeeded)
		gamemode.FireWarden();
}

public Action OnTouch(int toucher, int touchee)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (!IsClientValid(toucher) || !IsClientValid(touchee))
		return Plugin_Continue;

	if (GetClientTeam(toucher) != GetClientTeam(touchee))
		ManageTouch(JailFighter(toucher), JailFighter(touchee));	// Handler

	return Plugin_Continue;
}

public Action Timer_PlayerThink(Handle timer)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (gamemode.flMusicTime <= GetGameTime() && cvarTF2Jail[EnableMusic].BoolValue)
		MusicPlay();

	JailFighter player;
	int state = gamemode.iRoundState;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (state != StateRunning)
			continue;

		player = JailFighter(i);

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

				if (!IsInRange(i, target, cvarTF2Jail[NameDistance].FloatValue))
					continue;

				SetHudTextParams(-1.0, 0.59, 0.4, 255, 100, 255, 255, 1);
				if (cvarTF2Jail[SeeHealth].BoolValue)
					ShowSyncHudText(i, AimHud, "%N [%d]", target, GetClientHealth(target));
				else ShowSyncHudText(i, AimHud, "%N", target);
			}
		}
		else if (GetClientTeam(i) == RED)
		{
			ManageRedThink(player);

			if (!player.bIsFreeday)
				continue;

			/* Props to <eVa>Dog */
			float vecOrigin[3]; GetClientAbsOrigin(i, vecOrigin);
			TE_SetupBeamPoints(vecOld[i], vecOrigin, iLaserBeam, iHalo2, 0, 0, cvarTF2Jail[FreedayBeamLifetime].FloatValue, 20.0, 10.0, 5, 0.0, {255, 25, 25, 255}, 30);
			TE_SendToAll();

			vecOld[i] = vecOrigin;

			if (TF2_GetPlayerClass(i) == TFClass_Medic)
			{
				float healtime = cvarTF2Jail[MedicLoseFreeday].FloatValue;
				if (healtime != 0.0)
				{
					JailFighter rebel = JailFighter(GetHealingTarget(i));
					if (0 < rebel.index <= MaxClients && rebel.bIsRebel)
					{
						player.flHealTime += IsMedicUbering(i) ? 0.2 : 0.1;
						if (player.flHealTime >= healtime)
						{
							player.RemoveFreeday();
							PrintCenterTextAll("%t", "Medic Heal Rebel", i);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_Announce(Handle timer)
{
	if (bEnabled.BoolValue)
		CPrintToChatAll("%t %t", "Plugin Tag", "Announce Timer", PLUGIN_VERSION);
}

public Action Timer_Round(Handle timer)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateEnding || gamemode.iTimeLeft < 0)
		return Plugin_Stop;

	int time = gamemode.iTimeLeft;
	gamemode.iTimeLeft--;
	char time2[6];

	if (time / 60 > 9)
		IntToString(time / 60, time2, 6);
	else FormatEx(time2, 6, "0%i", time / 60);

	if (time % 60 > 9)
		Format(time2, 6, "%s:%i", time2, time % 60);
	else Format(time2, 6, "%s:0%i", time2, time % 60);

	SetTextNode(hTextNodes[3], time2, EnumTNPS[3].fCoord_X, EnumTNPS[3].fCoord_Y, EnumTNPS[3].fHoldTime, EnumTNPS[3].iRed, EnumTNPS[3].iGreen, EnumTNPS[3].iBlue, EnumTNPS[3].iAlpha, EnumTNPS[3].iEffect, EnumTNPS[3].fFXTime, EnumTNPS[3].fFadeIn, EnumTNPS[3].fFadeOut);

	switch (time) 
	{
		case 60:EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30:EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10:EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5: 
		{
			char sound[PLATFORM_MAX_PATH];
			FormatEx(sound, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		case 0:
		{
			if (ManageTimeEnd() == Plugin_Continue)	// Handler
				ForceTeamWin(BLU);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void ConvarsSet(const bool status)
{
	if (status)
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

public void HookVent(int entity)
{
	if (IsValidEntity(entity))
		SDKHook(entity, SDKHook_OnTakeDamage, OnVentTakeDamage);
}

public Action OnPlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	return ManageOnTakeDamage(JailFighter(victim), attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

public Action OnPlayerTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;	

	Action action;
	JailFighter player = JailFighter(victim);
	if (player.bIsWarden && damagecustom == TF_CUSTOM_BACKSTAB)
	{
		// Use OTD alive to avoid all that extra damage crap tf2 does
		float reduction = cvarTF2Jail[WardenStabProtect].FloatValue;
		if (reduction != 0.0)
		{
			int max = cvarTF2Jail[WardenStabCount].IntValue;
			if (!max || player.nWardenStabbed < max)
			{
				damage = float(GetEntProp(victim, Prop_Data, "m_iMaxHealth"));
				damage *= FloatAbs(1.0 - reduction);
				action = Plugin_Changed;
			}
		}
		++player.nWardenStabbed;
	}

	return action;
}

#if defined __tf_ontakedamage_included
public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (IsClientValid(attacker) && attacker != victim
		&& weapon != -1 && critType < CritType_MiniCrit && GetClientTeam(attacker) == BLU
		&& !gamemode.bDisableCriticals && cvarTF2Jail[BlueCritType].IntValue == 1)
	{
		critType = CritType_MiniCrit;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
#endif

public void OnTakeAmmo(const char[] output, int touchee, int toucher, float delay)
{
	if (!bEnabled.BoolValue)
		return;

	if (!IsClientValid(toucher))
		return;

	int action = cvarTF2Jail[RebelAmmo].IntValue;
	if (!action)
		return;

	JailFighter player = JailFighter(toucher);
	if (player.bIsFreeday && action >= 1)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%t", "Taken Ammo", toucher);
	}
	if (action == 2)
		player.MarkRebel();
}

public void OnFirstCellOpening(const char[] output, int touchee, int toucher, float delay)
{
	gamemode.bFirstDoorOpening = true;
	gamemode.bCellsOpened = true;	// Some maps have a cell timer, so this lets the warden reclose the cells with 1 tap
}

public Action OnVentTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsClientValid(attacker) || !IsValidEntity(victim))
		return Plugin_Continue;

	JailFighter player = JailFighter(attacker);
	if (player.bIsFreeday)
	{
		player.RemoveFreeday();
		PrintCenterTextAll("%t", "Hit Vent", attacker);
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

	if (player.bIsWarden && (GetClientButtons(client) & IN_RELOAD) && player.bLasering && cvarTF2Jail[WardenLaser].BoolValue)
	{
		float vecPos[3];
		float vecEyes[3]; GetClientEyePosition(client, vecEyes);
		if (GetClientAimPos(client, vecPos, vecEyes, TraceRayFilterPlayers))
		{
			TE_SetupBeamPoints(vecEyes, vecPos, iLaserBeam, 0, 0, 0, 0.1, 0.25, 0.0, 1, 0.0, {0, 100, 255, 255}, 0);
			TE_SendToAll();

			TE_SetupGlowSprite(vecEyes, iHalo, 0.1, 0.25, 30);
			TE_SendToAll();
		}
	}
	ManageOnPreThink(player);
}

public bool TraceRayFilterPlayers(int entity, int mask, any data)
{
	return !(0 < entity <= MaxClients);
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
		CPrintToChat(client, "%t %t", "Plugin Tag", "Can't Teleport");
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
	ParseRoleRenderersConfig();
}

public void ParseMapConfig()
{
	if (strConfig[CFG_MAP][0] == '\0')
		BuildPath(Path_SM, strConfig[CFG_MAP], sizeof(strConfig[]), "configs/tf2jail/mapconfig.cfg");

	gamemode.bIsMapCompatible = false;
	gamemode.bFreedayTeleportSet = false;
	gamemode.bWardayTeleportSetBlue = false;
	gamemode.bWardayTeleportSetRed = false;

	KeyValues kv = new KeyValues(strKVConfig[CFG_MAP]);
	char map[128];
	GetCurrentMap(map, sizeof(map));

	if (!kv.ImportFromFile(strConfig[CFG_MAP]) || !kv.JumpToKey(map))
	{
		LogError("~~~~~No TF2Jail Map Config set for map '%s', dismantling teleportation~~~~~", map);
		delete kv;
		return;
	}

	char cellnames[32], cellsbutton[32], ffbutton[32];

	kv.GetString("CellNames", cellnames, sizeof(cellnames));
	if (cellnames[0] != '\0')
	{
		if (FindEntity(cellnames, "func_door") != -1)
		{
			strCellNames = cellnames;
			gamemode.bIsMapCompatible = true;
		}
	}

	kv.GetString("CellsButton", cellsbutton, sizeof(cellsbutton));
	if (cellsbutton[0] != '\0' && FindEntity(cellsbutton, "func_button") != -1)
		strCellOpener = cellsbutton;

	kv.GetString("FFButton", ffbutton, sizeof(ffbutton));
	if (ffbutton[0] != '\0' && FindEntity(ffbutton, "func_button") != -1)
		strCellOpener = ffbutton;

	if (kv.JumpToKey("Freeday"))
	{
		if (kv.JumpToKey("Teleport"))
		{
			if (kv.GetNum("Status", 1))
			{
				gamemode.bFreedayTeleportSet = true;
				vecFreedayPosition[0] = kv.GetFloat("Coordinate_X");
				vecFreedayPosition[1] = kv.GetFloat("Coordinate_Y");
				vecFreedayPosition[2] = kv.GetFloat("Coordinate_Z");
			}
			kv.GoBack();
		}
		kv.GoBack();
	}

	if (kv.JumpToKey("Warday - Guards"))
	{
		if (kv.JumpToKey("Teleport"))
		{
			if (kv.GetNum("Status", 1))
			{
				gamemode.bWardayTeleportSetBlue = true;
				vecWardayBlu[0] = kv.GetFloat("Coordinate_X");
				vecWardayBlu[1] = kv.GetFloat("Coordinate_Y");
				vecWardayBlu[2] = kv.GetFloat("Coordinate_Z");
			}
			kv.GoBack();
		}
		kv.GoBack();
	}

	if (kv.JumpToKey("Warday - Reds"))
	{
		if (kv.JumpToKey("Teleport"))
		{
			if (kv.GetNum("Status", 1))
			{
				gamemode.bWardayTeleportSetRed = true;
				vecWardayRed[0] = kv.GetFloat("Coordinate_X");
				vecWardayRed[1] = kv.GetFloat("Coordinate_Y");
				vecWardayRed[2] = kv.GetFloat("Coordinate_Z");
			}
			kv.GoBack();
		}
		kv.GoBack();
	}

	ManageTargetFilters(kv);	// targetfilters.sp
	delete kv;
}

public void ParseNodeConfig()
{
	if (strConfig[CFG_TEXT][0] == '\0')
		BuildPath(Path_SM, strConfig[CFG_TEXT], sizeof(strConfig[]), "configs/tf2jail/textnodes.cfg");

	KeyValues kv = new KeyValues(strKVConfig[CFG_TEXT]);
	if (!kv.ImportFromFile(strConfig[CFG_TEXT]) || !kv.GotoFirstSubKey(false))
	{
		LogError("~~~~~No TF2Jail Node Config found in path '%s'. Ignoring all text factors.~~~~~", strConfig[CFG_TEXT]);
		delete kv;
		return;
	}

	int count;
	do
	{
		EnumTNPS[count].fCoord_X = kv.GetFloat("Coord_X", -1.0);
		EnumTNPS[count].fCoord_Y = kv.GetFloat("Coord_Y", -1.0);
		EnumTNPS[count].fHoldTime = kv.GetFloat("HoldTime", 5.0);
		kv.GetColor("Color", EnumTNPS[count].iRed, EnumTNPS[count].iGreen, EnumTNPS[count].iBlue, EnumTNPS[count].iAlpha);
		EnumTNPS[count].iEffect = kv.GetNum("Effect", 0);
		EnumTNPS[count].fFXTime = kv.GetFloat("fxTime", 6.0);
		EnumTNPS[count].fFadeIn = kv.GetFloat("FadeIn", 0.1);
		EnumTNPS[count].fFadeOut = kv.GetFloat("FadeOut", 0.2);

		++count;
	}	while kv.GotoNextKey(false);

	delete kv;
}

public void ParseRoleRenderersConfig()
{
	if (strConfig[CFG_ROLES][0] == '\0')
		BuildPath(Path_SM, strConfig[CFG_ROLES], sizeof(strConfig[]), "configs/tf2jail/rolerenderers.cfg");

	KeyValues kv = new KeyValues(strKVConfig[CFG_ROLES]);

	if (!kv.ImportFromFile(strConfig[CFG_ROLES]))
	{
		LogError("~~~~~No TF2Jail Role Config found in path '%s'. Ignoring all particle effects.~~~~~", strConfig[CFG_ROLES]);
		delete kv;
		return;
	}

	SetRoleRender(kv, "Warden", iWardenColors, strWardenParticles, sizeof(strWardenParticles), flWardenOffset);
	SetRoleRender(kv, "Freedays", iFreedayColors, strFreedayParticles, sizeof(strFreedayParticles), flFreedayOffset);
	SetRoleRender(kv, "Rebellers", iRebelColors, strRebelParticles, sizeof(strRebelParticles), flRebelOffset);

	delete kv;
}

public void ParseLRConfig()
{
	if (strConfig[CFG_LR][0] == '\0')
		BuildPath(Path_SM, strConfig[CFG_LR], sizeof(strConfig[]), "configs/tf2jail/lastrequests.cfg");

	KeyValues kv = new KeyValues(strKVConfig[CFG_LR]);
	if (!FileExists(strConfig[CFG_LR]) || !kv.ImportFromFile(strConfig[CFG_LR]))
	{
		LogError("Last Request config not found in '%s', are you sure you don't need it?", strConfig[CFG_LR]);
		delete kv;
		return;
	}

	if (kv.GotoFirstSubKey())
	{
		LastRequest lr;
		KeyValues imprt;
		char name[MAX_LRNAME_LENGTH];
		char id[4];		// HOW COULD YOU HAVE MORE THAN 1000 LAST REQUESTS?!

		do
		{
			kv.GetSectionName(name, sizeof(name));
			if (kv.JumpToKey("Parameters", false))
			{
				bool dis = !!kv.GetNum("Disabled", 0);	// Skip disabled
				kv.GoBack();
				if (dis)
					continue;
			}

			lr = view_as< LastRequest >(new StringMap());

//			kv.GetString("Name", name, sizeof(name));
			gamemode.hLRS.SetValue(name, lr);

			lr.SetValue("__LRID", gamemode.iLRs);
			IntToString(gamemode.iLRs, id, sizeof(id));
			gamemode.hLRS.SetValue(id, lr);		// Int-Map it so it can be grabbed both by name and index

			imprt = new KeyValues(name);
			imprt.Import(kv);		// Grab the subkeys
			lr.SetValue("__KV", imprt);
			lr.SetValue("__FUNCS", new FuncTable(JBFWD_LENGTH));

			++gamemode.iLRs;
			gamemode.hLRCount.Push(0);

		}	while kv.GotoNextKey();
	}

	delete kv;
}

public void SetRoleRender(KeyValues kv, const char[] role, int color[4], char[] particle, int size, float &offset)
{
	if (!kv.JumpToKey(role))
		return;

	color[0] = color[1] = color[2] = color[3] = 255;
	kv.GetColor("Color", color[0], color[1], color[2], color[3]);
	kv.GetString("Particle", particle, size);
	offset = kv.GetFloat("Offset", 0.0);
	kv.GoBack();
}

public void BuildMenu()
{
	if (strConfig[CFG_WMENU][0] == '\0')
		BuildPath(Path_SM, strConfig[CFG_WMENU], sizeof(strConfig[]), "configs/tf2jail/wardenmenu.cfg");

	delete gamemode.hWardenMenu;

	Menu menu = new Menu(WardenMenuHandler);
	menu.SetTitle("%t", "Warden Commands");

	KeyValues kv = new KeyValues(strKVConfig[CFG_WMENU]);

	if (!kv.ImportFromFile(strConfig[CFG_WMENU]) || !kv.GotoFirstSubKey(false))
	{
		LogError("No warden menu config found in path '%s'. Warden menu has been disabled.", strConfig[CFG_WMENU]);
		delete kv;
		delete menu;
		return;
	}

	char id[64], name[256];
	do
	{
		kv.GetSectionName(id, sizeof(id));
		kv.GetString(NULL_STRING, name, sizeof(name));
		menu.AddItem(id, name);
	} 	while kv.GotoNextKey(false);

	delete kv;
	ManageWardenMenu(menu);		// Handler
	gamemode.hWardenMenu = menu;
}

public bool AlreadyMuted(const int client)
{
	switch (g_bSC)
	{
#if defined _sourcecomms_included
		case true:return SourceComms_GetClientMuteType(client) != bNot;
#endif
#if defined _basecomm_included
		case false:return BaseComm_IsClientMuted(client);
#endif
	}
	return false;
}

public void EnableEureka(const int userid)
{
	JailFighter player = JailFighter.OfUserId(userid);
	if (IsClientValid(player.index))
		player.bUnableToTeleport = false;
}

public void WelcomeMessage(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsClientValid(client))
		CPrintToChat(client, "%t %t", "Plugin Tag", "Welcome Message");
}

public void DisableWarden(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount 
	 || gamemode.iRoundState != StateRunning 
	 || gamemode.bWardenExists 
	 || gamemode.bIsWardenLocked)
		return;

	gamemode.DoorHandler(OPEN);
	if (gamemode.SetWardenLock(true))
		CPrintToChatAll("%t %t", "Plugin Tag", "Warden Locked Lack");

	// TODO; move this to SetWardenLock, but have it toggle properly!
	// Admin could lock warden manually -> no crits for rest of round
	if (cvarTF2Jail[NoCritOnLock].BoolValue)
		gamemode.bDisableCriticals = true;
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
		RemoveEntity(ent);
}

public void MusicPlay()
{
	if (gamemode.iRoundState != StateRunning)
		return;

	char sound[PLATFORM_MAX_PATH];
	float time = -1.0;

	LastRequest lr = gamemode.GetCurrentLR();
	if (lr != null)
	{
		if (lr.GetMusicStatus())
		{
			lr.GetMusicFileName(sound, sizeof(sound));
			time = lr.GetMusicTime();
		}
	}

	if (ManageMusic(sound, time) > Plugin_Changed)
		return;

	if (sound[0] != EOS && time != -1.0)
	{
		float vol = cvarTF2Jail[MusicVolume].FloatValue;
		strcopy(strBackgroundSong, PLATFORM_MAX_PATH, sound);
		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientInGame(i))
				continue;
			if (JailFighter(i).bNoMusic)
				continue;
			EmitSoundToClient(i, sound, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
		gamemode.flMusicTime = GetGameTime() + time;
	}
}

public void StopBackGroundMusic()
{
	if (strBackgroundSong[0] != '\0')
		for (int i = MaxClients; i; --i) 
			if (IsClientInGame(i))
				StopSound(i, SNDCHAN_AUTO, strBackgroundSong);
}

// Props to Dr.Doctor
public void CreateMarker(const int client)
{
	float time = cvarTF2Jail[Markers].FloatValue;
	if (time == 0.0)
		return;

	float vecAngles[3], vecOrigin[3], vecPos[3];

	GetClientEyePosition(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);

	Handle trace = TR_TraceRayFilterEx(vecOrigin, vecAngles, MASK_SHOT, RayType_Infinite, TraceRayFilterPlayers);

	if (!TR_DidHit(trace))
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "No Marker");
		delete trace;
		return;
	}

	TR_GetEndPosition(vecPos, trace);
	vecPos[2] += 5.0;
	delete trace;

	if (cvarTF2Jail[MarkerType].BoolValue)
	{
		int annot = CreateEntityByName("training_annotation");
		DispatchKeyValueFloat(annot, "lifetime", time);
		DispatchKeyValueVector(annot, "origin", vecPos);
		DispatchKeyValueFloat(annot, "offset", 20.0);

		char buffer[32]; FormatEx(buffer, sizeof(buffer), "%t", "Warden Marker Annotation");
		DispatchKeyValue(annot, "display_text", buffer);

		DispatchSpawn(annot);
		AcceptEntityInput(annot, "Show");
		SetPawnTimer(RemoveEnt, time, EntIndexToEntRef(annot));
	}
	else
	{
		TE_SetupBeamRingPoint(vecPos, 300.0, 300.1, iLaserBeam, iHalo, 0, 10, time, 2.0, 0.0, {255, 255, 255, 255}, 10, 0);
		TE_SendToAll();
	}

	gamemode.bMarkerExists = true;
	// TODO; delta-time this!!!
	SetPawnTimer(ResetMarker, 1.0);

	EmitAmbientSound("misc/rd_finale_beep01.wav", vecPos);
	EmitAmbientSound("misc/rd_finale_beep01.wav", vecPos);
}

public void ResetMarker()
{
	gamemode.bMarkerExists = false;
}

public void Open_Doors(const int roundcount)
{
	if (gamemode.bCellsOpened || roundcount != gamemode.iRoundCount || gamemode.iRoundState != StateRunning || gamemode.bFirstDoorOpening)
		return;

	if (gamemode.DoorHandler(OPEN))
		CPrintToChatAll("%t %t", "Plugin Tag", "Door Open Timer", cvarTF2Jail[DoorOpenTimer].IntValue);
}

public void EnableFFTimer(const int roundcount)
{
	if (hEngineConVars[0].BoolValue || roundcount != gamemode.iRoundCount || gamemode.iRoundState != StateRunning)
		return;

	hEngineConVars[0].SetBool(true);
	CPrintToChatAll("%t %t", "Plugin Tag", "FF On");
}

public void FreeKillSystem(const JailFighter attacker)
{
	if (GetClientTeam(attacker.index) != BLU)
		return;

//	if (attacker.bIsAdmin) 	// Admin abuse :o
//		return;

	if (gamemode.iRoundState != StateRunning)
		return;

	float currtime = GetGameTime();
	if (currtime <= attacker.flKillingSpree)
		attacker.iKillCount++;
	else attacker.iKillCount = 0;

	if (attacker.iKillCount == cvarTF2Jail[FreeKill].IntValue)
	{
		char ip[32];
		bool messagetype = cvarTF2Jail[FreeKillMessage].BoolValue;
		GetClientIP(attacker.index, ip, sizeof(ip));

		for (int i = MaxClients; i; --i)
			if (IsClientInGame(i))
				if (JailFighter(i).bIsAdmin)
					if (messagetype)
						CPrintToChat(i, "%t **********\n%L\nIP:%s\n**********", "Plugin Tag", attacker.index, ip);
					else PrintToConsole(i, "**********\n%L\nIP:%s\n**********", attacker.index, ip);
		attacker.iKillCount = 0;
	}
	else attacker.flKillingSpree = currtime + cvarTF2Jail[FreeKillTime].FloatValue;
}

public void EnableWarden(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount 
	 || gamemode.iRoundState != StateRunning 
	 || !gamemode.bIsWardenLocked 
	 || gamemode.bWardenExists)
		return;

	if (gamemode.SetWardenLock(false))
		CPrintToChatAll("%t %t", "Plugin Tag", "Warden Enabled");
}

public void EnableWarden2(const int roundcount)
{
	if (roundcount != gamemode.iRoundCount
	 || gamemode.iRoundState != StateRunning
	 || gamemode.bWardenExists)
		return;

	gamemode.FindRandomWarden();
}

public void RemoveRebel(const int userid, const int roundcount)
{
	if (roundcount != gamemode.iRoundCount || gamemode.iRoundState != StateRunning)
		return;

	JailFighter player = JailFighter.OfUserId(userid);
	if (!player || !IsPlayerAlive(player.index))
		return;

	player.ClearRebel();
}

public Action KillOnSpawn(int ent)
{
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	return Plugin_Handled;
}

public Action OnBuildingSpawn(int ent)
{
	if (gamemode.bAllowBuilding)
		return Plugin_Continue;

	if (GetEntPropEnt(ent, Prop_Send, "m_hBuilder") != -1)
	{
		RemoveEntity(ent);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public int InviteReceiveMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsPlayerAlive(client))
				return;

			char s[4]; menu.GetItem(select, s, sizeof(s));
			switch (StringToInt(s))
			{
				case 0:
				{
					CPrintToChatAll("%t %t", "Plugin Tag", "Player Invite Accepted", client);
					JailFighter(client).ForceTeamChange(BLU);
				}
				case 1:CPrintToChatAll("%t %t", "Plugin Tag", "Player Invite Denied", client);
			}
		}
		case MenuAction_Cancel:if (IsPlayerAlive(client) && select == MenuCancel_Exit)
									CPrintToChatAll("%t %t", "Plugin Tag", "Player Invite Denied", client);
		case MenuAction_End:delete menu;
	}
}

public void ExecuteLR(LastRequest lr)
{
	KeyValues kv = lr.GetKv();

	if (kv == null)
		return;

//	PrintToChatAll("Executing");
	char command[256];
	kv.GetString("Execute_Cmd", command, sizeof(command));
	if (command[0] != '\0')
	{
		DataPack pack;
		CreateDataTimer(0.5, ExecServerCmd, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(command);
	}

	bool freeday;
	if (kv.JumpToKey("Parameters"))
	{
//		PrintToChatAll("params");
		freeday = !!kv.GetNum("IsFreedayType", 0);

		if (kv.GetNum("OpenCells", 0))
			gamemode.DoorHandler(OPEN);

		gamemode.bDisableKillSpree = !!kv.GetNum("VoidFreekills", 0);

		int time = cvarTF2Jail[RoundTime].IntValue;
		if (!kv.GetNum("TimerStatus", 1))
			time = -1;	// TODO; make this better
		else time = kv.GetNum("TimerTime", 0);

		Call_OnTimeLeft(lr, time);

		if (time)
			gamemode.iTimeLeft = time;

		gamemode.bIsWardenLocked = !!kv.GetNum("AdminLockWarden", 0) || !!kv.GetNum("LockWarden", 0);
		gamemode.bDisableCriticals = !kv.GetNum("EnableCriticals", 1);

		if (kv.GetNum("BalanceTeams", 0))
			gamemode.EvenTeams();

		gamemode.bIsWarday = !!kv.GetNum("IsWarday", 0);
		gamemode.bDisableMuting = !!kv.GetNum("NoMuting", 0);
		gamemode.bAllowBuilding = !!kv.GetNum("AllowBuilding", 0);
		gamemode.ToggleMedic(!kv.GetNum("DisableMedic", 0));
		gamemode.bAllowWeapons = !!kv.GetNum("AllowWeapons", 0);
		gamemode.bIgnoreRebels = !!kv.GetNum("IgnoreRebels", 0);

		if (kv.GetNum("RegenerateReds", 0))
		{
			for (int i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (GetClientTeam(i) == RED)
				{
					JailFighter(i).bSkipPrep = true;
					TF2_RegeneratePlayer(i);
				}
			}
		}

		if (kv.JumpToKey("KillWeapons"))
		{
			bool kill[4];
			kill[0] = !!kv.GetNum("Red", 0);
			kill[1] = !!kv.GetNum("Blue", 0);
			kill[2] = !!kv.GetNum("Warden", 0);
			kill[3] = !!kv.GetNum("Melee", 0);

			JailFighter player;
			for (int i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				player = JailFighter(i);
				switch (GetClientTeam(i))
				{
					case RED:
						if (kill[0])
							player.StripToMelee();
					case BLU:
						if (kill[1] || (kill[2] && player.bIsWarden))
							player.StripToMelee();
				}
				if (kill[3])
					TF2_RemoveAllWeapons(i);
			}

			kv.GoBack();
		}

		if (kv.JumpToKey("FriendlyFire"))
		{
			if (kv.GetNum("Status", 0))
			{
				float fftime = kv.GetFloat("Timer", 1.0);
				if (fftime < 0.0)
					fftime = 0.0;

				Call_OnFFTimer(lr, fftime);
				SetPawnTimer(EnableFFTimer, fftime, gamemode.iRoundCount);
			}

			kv.GoBack();
		}

		kv.GoBack();
	}

	char buffer[256];
	kv.GetString("Activated", buffer, sizeof(buffer));
	if (buffer[0] != '\0')
	{
		if (freeday)
		{
			JailFighter player;

			for (int i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i))
					continue;

				player = JailFighter(i);
				if (player.bIsFreeday)
				{
					kv.GetString("Activated", buffer, sizeof(buffer));	// Just do it again I guess
					char name[32];
					GetClientName(i, name, sizeof(name));

					ReplaceString(buffer, sizeof(buffer), "{NAME}", name);
					CPrintToChatAll("%t %s", "Plugin Tag", buffer);
				}
			}
		}
		else CPrintToChatAll("%t %s", "Plugin Tag", buffer);
	}

//	if (kv.JumpToKey("Music"))
//	{
//		if (kv.GetNum("Status", 0))
//		{
//			kv.GetString("File", strBackgroundSong, sizeof(strBackgroundSong));
//			if (strBackgroundSong[0] != '\0')
//				gamemode.flMusicDuration = kv.GetFloat("Time", 0.0);
//		}
//		kv.GoBack();
//	}

	if (kv.JumpToKey("Properties"))
	{
		if (kv.GotoFirstSubKey(false))
		{
			do
			{
				kv.GetSectionName(buffer, 64);
				if (buffer[0] != '\0')
				{
					switch (kv.GetDataType(NULL_STRING))
					{
						case KvData_Int:gamemode.SetValue(buffer, kv.GetNum(NULL_STRING));
						case KvData_Float:gamemode.SetValue(buffer, kv.GetFloat(NULL_STRING));
						case KvData_String:
						{
							char buffer2[128]; kv.GetString(NULL_STRING, buffer2, sizeof(buffer2));
							gamemode.SetString(buffer, buffer2);
						}
						case KvData_Color:
						{
							int color[4]; kv.GetColor4(NULL_STRING, color);
							gamemode.SetArray(buffer, color, 4);
						}
					}
				}
			}	while kv.GotoNextKey(false);
			kv.GoBack();
		}
		kv.GoBack();
	}
	Call_OnLRActivate(lr);

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		Call_OnLRActivatePlayer(lr, JailFighter(i));
	}
}

public Action ExecServerCmd(Handle timer, DataPack pack)
{
//	if (gamemode.iRoundState != StateRunning)
//		return Plugin_Continue;

	pack.Reset();
	char buffer[256]; pack.ReadString(buffer, sizeof(buffer));
	ServerCommand("%s", buffer);
	return Plugin_Continue;
}

public bool TraceRayDontHitSelf(int ent, int mask, any data)
{
	return ent != data;
}

public Action Timer_ClearRebel(Handle timer, any userid)
{
	JailFighter player = JailFighter.OfUserId(userid);
	if (IsClientValid(player.index) && gamemode.iRoundState == StateRunning)
	{
		// Null it first since ClearRebel() kills the timer and that's a bad thing to do in it's own callback
		player.hRebelTimer = null;
		player.ClearRebel();
	}
}

public Function GetLRFunction(LastRequest lr, int index)
{
	DataPack pack; lr.GetValue("__FUNCS", pack);
	pack.Position = view_as< DataPackPos >(index + 1);
	return pack.ReadFunction();
}

#file "TF2Jail_Redux"