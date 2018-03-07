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
stock char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" }

/** Methodmaps ftw **/
methodmap JBPlayer
{
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the JailFighter internal methodmap.
	 *	 
	 * @param index			Index (or the userid) of a player.
	 * @param userid		If using userid instead of player index, set this param to true.
	 *
	 * @return				A player instance of the JBPlayer methodmap.
	*/
	public native JBPlayer(const int index, bool userid = false);

	/* **** **** [ P R O P E R T I E S ] **** **** */
	
	/**
	 * Gets the userid of the JB player instance.
	 *
	 * @return				The bare player userid integer.
	*/
	property int userid 
	{
		public native get();
	}
	
	/**
	 * Gets the index of the JB player instance.
	 *
	 * @return				The bare player index integer.
	*/
	property int index 
	{
		public native get();
	}
	
	/**
     * Gets the property of the internal JailFighter methodmap.
     *
	 * @param prop_name		Name of property you want to access data from.
	 * @param item			Reference to use of the variable to overwrite with data from the property.
	 *
     * @return				Property value called if it was valid
    */
	public native any GetProperty(const char prop_name[64]);
	
	/**
     * Sets the property of the internal JB methodmap.
     * NOTE: You can use this to create new properties which GetProperty can access!
     *
	 * @param prop_name		Name of the property you want to override data from (works like StringMap).
	 * @param value			Data you want the property to hold.
	 *
     * @noreturn
    */
	public native void SetProperty(const char prop_name[64], any value);

	/**		AVAILABLE PROPERTIES
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
		
	/**
	 *	Creates and spawns a weapon to a player.
	 *
	 *	@param name 		Entity name of the weapon being spawned (Cannot be a wearable).
	 *	@param index 		Item index of the weapon.
	 *	@param level		Item level of the weapon.
	 *	@param qual			Item quality of the weapon.
	 *	@param att 			Item attributes separated by " ; ".
	 *
	 *	@return				The weapon spawned to the client.
	*/
	public native int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att);

	/**
	 *	Retrieve an item definition index of a player's weaponslot.
	 *
	 *	@param slot 		Slot to grab the item index from.
	 *
	 *	@return 			Index of the valid, equipped weapon.
	*/
	public native int GetWeaponSlotIndex(const int slot);

	/**
	 *	Set the alpha magnitude a player's weapons.
	 *
	 *	@param alpha 		Number from 0 to 255 to set on the weapon.
	 *
	 *	@noreturn
	*/
	public native void SetWepInvis(const int alpha);

	/**
	 *	Silently switch a player's team.
	 *
	 *	@param team 		Team to switch to.
	 *	@param spawn 		Determine whether or not to respawn the client.
	 *
	 *	@noreturn
	*/
	public native void ForceTeamChange(const int team, bool spawn = true);

	/**
	 *	Teleport a player either to a freeday or warday location.
	 *	@NOTE 				IF GAMEMODE TELEPORT PROPERTIES ARE NOT TRUE, PLAYER WILL BE TELEPORTED TO MAP'S ORIGIN.
	 *
	 *	@param iLocation 	Location to teleport the client.
	 *
	 *	@noreturn
	*/
	public native void TeleportToPosition(const int iLocation);

	/**
	 *	List the last request menu to the player.
	 *
	 *	@noreturn
	*/
	public native void ListLRS();

	/**
	 *	Remove all weapons, disguises, and wearables from a client.
	 *
	 *	@noreturn
	*/
	public native void PreEquip();

	/**
	 *	Teleport a player to the appropriate spawn location.
	 *
	 *	@param team 		Team spawn to teleport the client to.
	 *
	 *	@noreturn
	*/
	public native void TeleToSpawn(int team = 0);

	/**
	 *	Spawn a small healthpack at the client's origin.
	 *
	 *	@param ownerteam 	Team to give the healthpack.
	 *
	 *	@noreturn
	*/
	public native void SpawnSmallHealthPack(int ownerteam = 0);

	/**
	 *	Mute a client through the plugin.
	 *	@NOTE 				PLAYERS THAT ARE DEEMED AS ADMINS WILL NEVER BE MUTED.
	 *
	 *	@noreturn
	*/
	public native void MutePlayer();

	/**
	 *	Initialize a player as a freeday
	 *	@NOTE 				DOES NOT TELEPORT THEM TO THE FREEDAY LOCATION.
	 *
	 *	@noreturn
	*/
	public native void GiveFreeday();

	/**
	 *	Terminate a player as a freeday.
	 *
	 *	@noreturn
	*/
	public native void RemoveFreeday();

	/**
	 *	Remove all player weapons that are not their melee.
	 *
	 *	@noreturn
	*/
	public native void StripToMelee();

	/**
	 *	Strip a player of all of their ammo.
	 *
	 *	@noreturn
	*/
	public native void EmptyWeaponSlots();

	/**
	 *	Unmute a player through the plugin.
	 *
	 *	@noreturn
	*/
	public native void UnmutePlayer();

	/**
	 *	Initialize a player as the warden.
	 *	@NOTE 				THIS AUTOMATICALLY GIVES THE PLAYER THE WARDEN MENU.
	 *
	 *	@noreturn
	*/
	public native void WardenSet();

	/**
	 *	Terminate a player as the warden.
	 *
	 *	@noreturn
	*/
	public native void WardenUnset();

	/**
	 *	Convert a player into the Horseless Headless Horsemann.
	 *
	 *	@noreturn
	*/
	public native void MakeHorsemann();

	/**
	 *	Give a player the warden menu.
	 *
	 *	@noreturn
	*/
	public native void WardenMenu();

	/**
	 *	Allow a player to climb walls upon hitting them.
	 *
	 *	@param weapon 		Weapon the client is using to attack.
	 *	@param upwardvel	Velocity to send the client (in hammer units).
	 *	@param health 		Health to take from the client.
	 *	@param attackdelay 	Length in seconds to delay the player in attacking again.
	 *
	 *	@noreturn
	*/
	public native void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay);
};


/**
 *	Registers a plugin to be able to use TF2Jail's forwards
 *	NOTE: The purpose of this native is to register last-request subplugins, you don't need to register plugins to use forwards, simply hook what forward you need.
 *	If you add a last request and want to test it before you allow all players to use it, do NOT register the sub-plugin, and use sm_setpreset to activate the lr type for next round.
 *	
 *	@param plugin_name		Module name you want your calling plugin to be identified under.
 *
 *	@return					Integer of the plugin array index
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
	OnClientInduction,
	OnVariableReset,
	OnTimeEnd,
	OnPlayMusic
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
		OnClientInduction
		OnVariableReset
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
	function void (const JBPlayer Victim, const JBPlayer Attacker, Event event);

	//	OnManageRoundStart
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

	// OnPlayMusic
	function Action (char song[PLATFORM_MAX_PATH], float & time);

	// OnTimeEnd
	function Action ();
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
 *	property int iTimeLeft
 *	property int iLRPresetType
 *	property int iLRType
 *	property int iFreedayLimit		
 *	property bool bSteam			// If has SteamTools
 *	property bool bSB 				// If has Sourcebans (Optional, not used in core)
 *	property bool bSC				// If has SourceComms
 *	property bool bVA 				// If has VoiceAnnounce_Ex (Optional, not used in core)
 *	property bool bTF2Attribs
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
 *	property bool bFirstDoorOpening
 *	property float flMusicTime		// Optional, not used in core
*/

/**
 *	Retrieve the amount of living/playing players in the server.
 *
 *	@return 			The number of players currently alive.
*/
native int JBGameMode_Playing();

/**
 *	Find and Initialize a random player as the warden.
 *
 *	@noreturn
*/
native void JBGameMode_FindRandomWarden();

/**
 *	Handle the cell doors.
 *
 *	@param status 			Type of cell door usage found in the eDoorsMode enum.
 *
 *	@noreturn
*/
native void JBGameMode_ManageCells(const eDoorsMode status);

/**
 *	Find the current warden if one exists.
 *
 *	@return 				The current warden.
 *
*/
native int JBGameMode_FindWarden();

/** 
 *	Find and terminate the current warden.
 *
 *	@param prevent 			Prevent the player from becoming warden again.
 * 	@param announce 		Display to all players that the warden was fired.
 *
 *	@noreturn
*/
native void JBGameMode_FireWarden(bool prevent = true, bool announce = true);


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
	MarkNativeAsOptional("JBPlayer.GetWeaponSlotIndex");
	MarkNativeAsOptional("JBPlayer.SetWepInvis");
	MarkNativeAsOptional("JBPlayer.ForceTeamChange");
	MarkNativeAsOptional("JBPlayer.TeleportToPosition");
	MarkNativeAsOptional("JBPlayer.ListLRS");
	MarkNativeAsOptional("JBPlayer.PreEquip");
	// MarkNativeAsOptional("JBPlayer.SetAmmotable");
	// MarkNativeAsOptional("JBPlayer.SetCliptable");
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
	MarkNativeAsOptional("JBPlayer.WardenMenu");
	MarkNativeAsOptional("JBPlayer.ClimbWall");

	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");
	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_FindWarden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
}
#endif