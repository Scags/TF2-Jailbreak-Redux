#if defined _tf2jailredux_included
  #endinput
#endif
#define _tf2jailredux_included

enum eDoorsMode
{	// Doors obviously
	OPEN = 0,
	CLOSE,
	LOCK,
	UNLOCK
};

enum
{	// gamemode.iRoundStates
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};

enum eTextNodeParams
{	// Hud Text Paramaters
	Float:fCoord_X,
	Float:fCoord_Y,
	Float:fHoldTime,
	iRed,
	iBlue,
	iGreen,
	iAlpha,
	iEffect,
	Float:fFXTime,
	Float:fFadeIn,
	Float:fFadeOut,
};

enum
{	// Freeday/warday position integers
	FREEDAY = 1,
	WRED = 2,
	WBLU = 3
};

stock char snd[PLATFORM_MAX_PATH];
#define MAXMESSAGE	4096
stock char gameMessage[MAXMESSAGE];	// For formatting chat/hint/center/etc messages
stock char BackgroundSong[PLATFORM_MAX_PATH];	// If you want a sweet song with your lr, try this out

/** Methodmaps ftw **/
methodmap JBPlayer
{
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the JailFighter internal methodmap
	 * @param index			index (or the userid) of a player
	 * @param userid		if using userid instead of player index, set this param to true
	 * @return				a player instance of the JBPlayer methodmap
	*/
	public native JBPlayer(const int index, bool userid=false);

	/* **** **** [ P R O P E R T I E S ] **** **** */
	
	/**
	 * gets the userid of the JB player instance
	 * @return			the bare player userid integer
	*/
	property int userid 
	{
		public native get();
	}
	
	/**
	 * gets the index of the JB player instance
	 * @return			the bare player index integer
	*/
	property int index 
	{
		public native get();
	}
	
	/**
     * sets the property of the internal JailFighter methodmap
     * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of property you want to access data from.
	 * @param item			reference to use of the variable to overwrite with data from the property.
     * @return		
    */
	public native any GetProperty(const char prop_name[64]);
	
	/**
     * sets the property of the internal JB methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of the property you want to override data from (works like StringMap).
	 * @param value			data you want the property to hold.
     * @noreturn
    */	
	public native void SetProperty(const char prop_name[64], any value);

	/*		AVAILABLE PROPERTIES
		property int iLRCustom							// For the Custom LR
		property int iKillCount							// For the ghetto rigged freekill system
		property bool bIsMuted							// If not bIsAdmin and dead; or not bIsVIP and alive
		property bool bIsQueuedFreeday					// Freeday for Self or Freeday for Others
		property bool bIsFreeday 						// Client is/isn't a freeday
		property bool bLockedFromWarden					// Upon being fired or retiring
		property bool bIsVIP							// Default Reserve flag
		property bool bIsAdmin							// Default Generic flag
		property bool bIsHHH							// For the HHHDay LR
		property bool bInJump							// Client is rocket/sticky jumping
		property bool bNoMusic							// LR music option (cookie)
		property bool bUnableToTeleport 				// Client can/can't teleport with Eureka Effect
		property float flSpeed 							// Client speed, isn't used
		property float flKillSpree 						// Also for the ghetto rigged freekill system
	*/
		
	public native int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att);
	public native void ForceTeamChange(const int team, bool spawn = true);
	public native void TeleportToPosition(const int iLocation);
	public native void ListLRS();
	public native void PreEquip();
	public native void SetAmmotable(const int wepslot, const int val);
	public native void SetCliptable(const int wepslot, const int val);
	public native void TeleToSpawn(int team = 0);
	public native void SpawnSmallHealthPack(int ownerteam = 0);
	public native void MutePlayer();
	public native void GiveFreeday();
	public native void RemoveFreeday();
	public native void StripToMelee();
	public native void EmptyWeaponSlots();
	public native void UnmutePlayer();
	public native void WardenSet();
	public native void WardenUnset();
	public native void MakeHorsemann();
};


/**
 * Registers a plugin to be able to use TF2Jail's forwards
 * NOTE: The purpose of this native is to register last-request subplugins, you don't need to register plugins to use forwards, simply hook what forward you need.
 * @param plugin_name		module name you want your calling plugin to be identified under
 * @return					integer of the plugin array index
 */
native int TF2JailRedux_RegisterPlugin(const char plugin_name[64]);


enum	// JB Hook Types
{
	OnDownloads = 0,
	OnLRRoundActivate,
	OnManageRoundStart,
	OnManageRoundEnd,
	OnLRRoundEnd,
	OnWardenGet,
	OnClientTouch,
	OnRedThink,
	OnAllBlueThink,
	OnBlueNotWardenThink,
	OnWardenThink,
	OnLRTextHud,
	OnLRPicked,
	OnPlayerDied,
	OnBuildingDestroyed,
	OnObjectDeflected,
	OnPlayerJarated,
	OnUberDeployed,
	OnPlayerSpawned,
	OnMenuAdd,
	OnPanelAdd,
	OnManageTimeLeft,
	OnPlayerPrepped,
	OnHurtPlayer,
	OnHookDamage,
	OnWMenuAdd,
	OnWMenuSelect,
	OnMusicPlay
};

/* SDKHook-Style Forwards */
typeset JBHookCB 
{
	/*
		OnLRRoundActivate
		OnLRRoundEnd
		OnWardenGet
		OnRedThink
		OnBlueNotWardenThink
		OnAllBlueThink
		OnWardenThink
		OnPlayerPrepped
	*/
	function void (const JBPlayer Player);
	
	//	OnPlayerSpawned
	function void (const JBPlayer Player, Event event);

	/*
		OnClientTouch
		OnPlayerJarated
		OnUberDeployed	// Medic is Player, Patient is Victim
	*/
	function void (const JBPlayer Player, const JBPlayer Victim);

	//	OnBuildingDestroyed
	function void (const JBPlayer Attacker, const int building, Event event);

	/*
		OnPlayerDied
		OnPlayerAirblasted
	*/
	function void (const JBPlayer Attacker, const JBPlayer Victim, Event event);

	// 	OnManageRoundStart
	function void ();

	//	OnMenuAdd
	function void (Menu & menu, ArrayList array);

	// 	OnManageRoundEnd
	function void (Event event);

	/* 
		OnPanelAdd
		OnWMenuAdd
	*/
	function void (Menu & menu);	

	// 	OnLRTextHud
	function void (char strHud[128]);

	// 	OnLRPicked
	function void (const JBPlayer Player, const int request, const int value, ArrayList & array);

	// 	OnHurtPlayer
	function void (const JBPlayer Victim, const JBPlayer Attacker, int damage, int custom, int weapon, Event event);

	// 	OnHookDamage
	function Action (const JBPlayer Victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnWMenuSelect
	function void (const JBPlayer Player, const char[] index);
};

// Use hooktype enum on these.
native void JB_Hook(const int callbacktype, JBHookCB callback);
native bool JB_HookEx(const int callbacktype, JBHookCB callback);

native void JB_Unhook(const int callbacktype, JBHookCB callback);
native bool JB_UnhookEx(const int callbacktype, JBHookCB callback);


native any JBGameMode_GetProperty(const char prop_name[64]);
native void JBGameMode_SetProperty(const char prop_name[64], any value);

/** Properties
 *	property int iRoundState
 *	property int iPlaying
 *	property int iTimeLeft
 *	property int iLRPresetType
 *	property int iLRType
 *	property int iFreedayLimit		
 *	property bool bSteam			// If has SteamTools
 *	property bool bSB 				// If has Sourcebans (Optional, not used in core)
 *	property bool bSC				// If has SourceComms
 *	property bool bVA 				// If has VoiceAnnounce_Ex (Optional, not used in core)
 *	property bool bTF2Attribs		// Not really needed but lol ok
 *	property bool bIsMapCompatible
 *	property bool bFreedayTeleportSet
 *	property bool bWardayTeleportSetBlue
 *	property bool bWardayTeleportSetRed
 *	property bool bCellsOpened
 *	property bool b1stRoundFreeday
 *	property bool bIsLRInUse
 *	property bool bIsWardenLocked
 *	property bool bOneGuardLeft
 *	property bool bAdminLockWarden
 *	property bool bAdminLockedLR
 *	property bool bDisableCriticals
 *	property bool bIsFreedayRound
 *	property bool bWardenExists
 *	property bool bAvoidTeamKills
 *	property bool bIsWarday
 *	property bool bIsVIPLR			// Optional, not used in core
 *	property bool bFirstDoorOpening
 *	property float flMusicTime		// Optional, not used in core
*/

native void JBGameMode_FindRandomWarden();						// gamemode.FindRandomWarden()
native void JBGameMode_ManageCells(const eDoorsMode status);	// gamemode.DoorHandler(status)
native int JBGameMode_FindWarden(); 							// gamemode.FindWarden()
native void JBGamMode_FireWarden(bool prevent = true, bool announce = true); // gamemode.FireWarden(prevent, announce)

public SharedPlugin __pl_tf2jailredux = {
	name = "TF2Jail_Redux",
	file = "TF2Jail_Redux.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_tf2jailredux_SetNTVOptional()
{
	MarkNativeAsOptional("TF2JailRedux_RegisterPlugin");

	MarkNativeAsOptional("JB_Hook");
	MarkNativeAsOptional("JB_HookEx");
	MarkNativeAsOptional("JB_Unhook");
	MarkNativeAsOptional("JB_UnhookEx");

	MarkNativeAsOptional("JBPlayer.JBPlayer");
	MarkNativeAsOptional("JBPlayer.userid.get");
	MarkNativeAsOptional("JBPlayer.index.get");
	MarkNativeAsOptional("JBPlayer.GetProperty");
	MarkNativeAsOptional("JBPlayer.SetProperty");
	MarkNativeAsOptional("JBPlayer.SpawnWeapon");
	MarkNativeAsOptional("JBPlayer.ForceTeamChange");
	MarkNativeAsOptional("JBPlayer.TeleportToPosition");
	MarkNativeAsOptional("JBPlayer.ListLRS");
	MarkNativeAsOptional("JBPlayer.PreEquip");
	MarkNativeAsOptional("JBPlayer.SetAmmotable");
	MarkNativeAsOptional("JBPlayer.SetCliptable");
	MarkNativeAsOptional("JBPlayer.TeleToSpawn");
	MarkNativeAsOptional("JBPlayer.SpawnSmallHealthPack");
	MarkNativeAsOptional("JBPlayer.MutePlayer");
	MarkNativeAsOptional("JBPlayer.GiveFreeday");
	MarkNativeAsOptional("JBPlayer.RemoveFreeday");
	MarkNativeAsOptional("JBPlayer.StripToMelee");
	MarkNativeAsOptional("JBPlayer.EmptyWeaponSlots");
	MarkNativeAsOptional("JBPlayer.UnmutePlayer");
	MarkNativeAsOptional("JBPlayer.WardenSet");
	MarkNativeAsOptional("JBPlayer.WardenUnset");
	MarkNativeAsOptional("JBPlayer.MakeHorsemann");

	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_FindWarden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
}
#endif