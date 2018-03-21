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
stock char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };

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
	 * @param key		Name of property you want to access data from.
	 * @param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 * @return				Property value called if it was valid
    */
	public native any GetValue(const char key[64]);
	
	/**
	 * Sets the property of the internal JB methodmap.
	 * NOTE: You can use this to create new properties which GetValue can access!
	 *
	 * @param key		Name of the property you want to override data from (works like StringMap).
	 * @param value			Data you want the property to hold.
	 *
	 * @noreturn
	*/
	public native void SetValue(const char key[64], any value);

	/**		AVAILABLE PROPERTIES
		property int iLRCustom							// For the Custom LR
		property int iKillCount							// For the ghetto rigged freekill system
		property bool bIsMuted							// Varies with CVars
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
	 *	Set an array into this player's StringMap
	 *
	 *	@param key			Key string.
	 *	@param array		Array to store.
	 *	@param num_items	Number of items in the array.
	 *	@param replace		If false, operation will fail if the key is already set.
	 *
	 *	@return				True on success, false on failure.
	*/
 	public native bool SetArray(const char[] key, const any[] array, int num_items, bool replace = true);

	/**
	 *	Sets a string value in this player's StringMap, either inserting a new entry or replacing an old one.
	 *
	 *	@param key			Key string.
	 *	@param string		String to store.
	 *	@param replace		If false, operation will fail if the key is already set.
	 *
	 *	@return				True on success, false on failure.
	*/
 	public native bool SetString(const char[] key, const char[] string, bool replace = true);

	/**
	 *	Retrieves an array in this player's StringMap.
	 *
	 *	@param key			Key string.
	 *	@param array		Buffer to store array.
	 *	@param max_size		Maximum size of array buffer.
	 *	@param size			Optional parameter to store the number of elements written to the buffer.
	 *
	 *	@return				True on success.  False if the key is not set, or the key is set 
	 *						as a value or string (not an array).
	*/
 	public native bool GetArray(const char[] key, any[] array, int max_size, int &size = 0);

	/**
	 *	Retrieves a string in this player's StringMap.
	 *
	 *	@param key			Key string.
	 *	@param string		Buffer to store value.
	 *	@param max_size		Maximum size of string buffer.
	 *	@param size			Optional parameter to store the number of bytes written to the buffer.
	 *
	 *	@return				True on success.  False if the key is not set, or the key is set 
	 *						as a value or array (not a string).
	*/
 	public native bool GetString(const char[] key, char[] string, int max_size, int &size = 0);

	/**
	 *	Removes a key entry from this player's StringMap.
	 *
	 *	@param key			Key string.
	 *
	 *	@return				True on success, false if the value was never set.
	*/
 	public native bool Remove(const char[] key);

	/**
	 *	Clears all entries from this player's StringMap.
	 *
	 *	@noreturn
	*/
	public native void Clear();

	/**
	 *	Create a snapshot of this player's StringMap's keys. See StringMapSnapshot.
	 *
	 *	@return 			Handle to key SnapShot.
	*/
	public native StringMapSnapshot Snapshot();

	/**
	 *	Retrieves the number of elements in this player's StringMap.
	*/
	property int Size
	{
		public native get();
	}
		
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
	 *	@NOTE 				If gamemode teleport properties are not true, player will be teleported to map's origin
	 *
	 *	@param location 	Location to teleport the client.
	 *
	 *	@noreturn
	*/
	public native void TeleportToPosition(const int location);

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
	 *	@NOTE 				Players that are deemed as admins will never be muted
	 *
	 *	@noreturn
	*/
	public native void MutePlayer();

	/**
	 *	Initialize a player as a freeday
	 *	@NOTE 				Does not teleport them to the freeday location
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
	 *	@NOTE 				This automatically gives the player the warden menu
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
	OnLastGuard,
	OnLastPrisoner,
	OnCheckLivingPlayers,
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

	/*
		OnDownloads
		OnManageRoundStart
		OnCheckLivingPlayers
	*/
	function void ();

	//	OnMenuAdd
	function void (Menu &menu, ArrayList array);

	// 	OnManageRoundEnd
	function void (Event event);

	/* 
		OnPanelAdd
		OnWMenuAdd
	*/
	function void (Menu &menu);	

	// 	OnLRTextHud
	function void (char strHud[128]);

	// 	OnLRPicked
	function void (const JBPlayer Player, const int request, const int value, ArrayList &array);

	// 	OnHurtPlayer
	function void (const JBPlayer Victim, const JBPlayer Attacker, int damage, int custom, int weapon, Event event);

	// 	OnHookDamage
	function Action (const JBPlayer Victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnWMenuSelect
	function void (const JBPlayer Player, const char[] index);

	// OnPlayMusic
	function Action (char song[PLATFORM_MAX_PATH], float &time);

	/*
		OnTimeEnd
		OnLastGuard		Return Handled to stop "One Guard Left" message. Return Stop to not fire OnCheckLivingPlayers
		OnLastPrisoner	Return Stop to not fire OnCheckLivingPlayers
	*/
	function Action ();
};

/**
 *	Hook function from the core plugin and use them within another plugin.
 *
 *	@param callbacktype 	Enum type to hook into.
 *	@param callback 		Function to call when the forward is called.
 *	
 *	@noreturn
*/
native void JB_Hook(const int callbacktype, JBHookCB callback);

/**
 *	Determine if this function is hooked into forward calls.
 *	@NOTE 					This automatically hooks functions into forwards if it wasn't already (if possible).
 *
 *	@param callbacktype 	Enum type to hook into.
 *	@param callback 		Function to call when the forward is called.
 *
 *	@return 				True on success or if the function was already hooked.
*/	
native bool JB_HookEx(const int callbacktype, JBHookCB callback);

/**
 *	Unhook a function from forward calls.
 *
 *	@param callbacktype 	Enum type to unhook from.
 *	@param callback 		Function to unhook calls from.
 *
 *	@noreturn
*/
native void JB_Unhook(const int callbacktype, JBHookCB callback);

/**
 *	Determine if a function is unhooked from forward calls.
 *	@NOTE 					This automatically unhooks functions from forwards if they weren't already (if possible).
 *	
 *	@param callbacktype 	Enum type to unhook from.
 *	@param callback 		Function to hunhook calls from.
 *
 *	@return 				True on successful unhook, false otherwise or if function wasn't hooked.
*/
native bool JB_UnhookEx(const int callbacktype, JBHookCB callback);



/**
 *	Get a property value from the JailGameMode internal methodmap (works like StringMap).
 *
 *	@param prop_name 		Property key to call from.
 *
 *	@return 				Value received from called key.
*/
native any JBGameMode_GetProperty(const char prop_name[64]);

/**
 *	Set a property to the JailGameMode internal methodmap.
 *	@NOTE 					This can set properties that GetProperty can access!
 *
 *	@param prop_name 		Property key to set into the StringMap.
 *	@param value 			Value to set to it.
 *
 *	@noreturn
*/
native void JBGameMode_SetProperty(const char prop_name[64], any value);

/** Properties
 *	int iRoundState
 *	int iTimeLeft
 *	int iLRPresetType
 *	int iLRType
 *	bool bSteam				// If has SteamTools
 *	bool bSB 				// If has Sourcebans (Optional, not used in core)
 *	bool bSC				// If has SourceComms
 *	bool bVA 				// If has VoiceAnnounce_Ex (Optional, not used in core)
 *	bool bTF2Attribs
 *	bool bIsMapCompatible
 *	bool bFreedayTeleportSet
 *	bool bWardayTeleportSetBlue
 *	bool bWardayTeleportSetRed
 *	bool bCellsOpened
 *	bool b1stRoundFreeday
 *	bool bIsLRInUse
 *	bool bIsWardenLocked
 *	bool bOneGuardLeft
 *	bool bOnePrisonerLeft
 *	bool bAdminLockWarden
 *	bool bAdminLockedLR
 *	bool bDisableCriticals
 *	bool bIsFreedayRound
 *	bool bWardenExists
 *	bool bAvoidTeamKills
 *	bool bIsWarday
 *	bool bFirstDoorOpening
 *	float flMusicTime		// Optional, not used in core
*/

/**
 *	Retrieve the amount of living/playing players in the server.
 *
 *	@return 				The number of players currently alive.
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

	MarkNativeAsOptional("JBPlayer.SetValue");
	MarkNativeAsOptional("JBPlayer.SetArray");
	MarkNativeAsOptional("JBPlayer.SetString");
	MarkNativeAsOptional("JBPlayer.GetValue");
	MarkNativeAsOptional("JBPlayer.GetArray");
	MarkNativeAsOptional("JBPlayer.GetString");
	MarkNativeAsOptional("JBPlayer.Remove");
	MarkNativeAsOptional("JBPlayer.Clear");
	MarkNativeAsOptional("JBPlayer.Snapshot");
	MarkNativeAsOptional("JBPlayer.Size.get");

	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");
	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_FindWarden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
}
#endif