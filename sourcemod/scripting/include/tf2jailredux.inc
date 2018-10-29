#if defined _tf2jailredux_included
  #endinput
#endif
#define _tf2jailredux_included

#include <tf2_stocks>
#include <tf2items>

#define TAG 				"{crimson}[TF2Jail]{burlywood} "
#define ADMTAG 				"{orange}[TF2Jail]{burlywood} "

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

enum
{	// Freeday/warday position integers
	FREEDAY = 1,
	WRED = 2,
	WBLU = 3
};

stock char strDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };


methodmap JBPlayer
{
	/** [ C O N S T R U C T O R S ]
	 *	Constructs an instance of the JBPLayer methodmap.
	 *
	 *	@param index		Index of a player.
	 *
	 *	@return				A player instance of the JBPlayer methodmap.
	*/
	public JBPlayer( const int index )
	{
		return view_as< JBPlayer >(index);
	}

	/**
	 *	Constructs an instance of the JBPLayer methodmap directly from a client's userid.
	 *
	 *	@param userid 		UserId of the client.
	 *
	 *	@return 			A player instance of the JBPlayer methodmap.
	*/
	public static JBPlayer OfUserId( const int userid )
	{
		return view_as< JBPlayer >(GetClientOfUserId(userid));
	}

	/**
	 *	Constructs an instance of the JBPLayer methodmap from the 'any' tag.
	 *
	 *	@param thing 		Object to initialize.
	 *
	 *	@return 			A player instance of the JBPlayer methodmap.
	*/
	public static JBPlayer Of( const any thing )
	{
		return view_as< JBPlayer >(thing));
	}

	/* **** **** [ P R O P E R T I E S ] **** **** */

	/**
	 *	Gets the userid of the JB player instance.
	 *
	 *	@return				The bare player userid integer.
	*/
	property int userid 
	{
		public get()			{ return GetClientUserId(view_as< int >(this)); }
	}

	/**
	 *	Gets the index of the JB player instance.
	 *
	 *	@return				The bare player index integer.
	*/
	property int index 
	{
		public get()			{ return view_as< int >(this); }
	}

	property StringMap hMap
	{
		public native get();

	}

	/**
	 *	Get's player's Music Cookie.
	 *
	 *	@return 			True if music is toggled off. False otherwise.
	*/
	property bool bNoMusic
	{
		public native get();
	}

	/**
	 *	Gets the property of the internal JailFighter methodmap.
	 *	@note 				If you are getting a float value, you MUST view_as< float >.
	 *
	 *	@param key			Name of property you want to access data from.
	 *	@param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 *	@return				Property value called if it was valid.
	*/
	public native any GetValue( const char key[64] );

	/**
	 *	Sets the property of the internal JB methodmap.
	 *	NOTE: You can use this to create new properties which GetValue can access!
	 *
	 *	@param key		Name of the property you want to override data from (works like StringMap).
	 *	@param value			Data you want the property to hold.
	 *
	 *	@noreturn
	*/
	public native void SetValue( const char key[64], any value );

	property int iCustom
	{
		public get() 				{ return this.GetValue("iCustom"); }
		public set( const int i )	{ this.SetValue("iCustom", i); }
	}
	property int iKillCount
	{
		public get() 				{ return this.GetValue("iKillCount"); }
		public set( const int i )	{ this.SetValue("iKillCount", i); }
	}

	property bool bIsWarden
	{
		public get() 				{ return this.GetValue("bIsWarden"); }
		public set( const bool i )	{ this.SetValue("bIsWarden", i); }
	}
	property bool bIsQueuedFreeday
	{
		public get() 				{ return this.GetValue("bIsQueuedFreeday"); }
		public set( const bool i )	{ this.SetValue("bIsQueuedFreeday", i); }
	}
	property bool bIsFreeday
	{
		public get() 				{ return this.GetValue("bIsFreeday"); }
		public set( const bool i )	{ this.SetValue("bIsFreeday", i); }
	}
	property bool bLockedFromWarden
	{
		public get() 				{ return this.GetValue("bLockedFromWarden"); }
		public set( const bool i )	{ this.SetValue("bLockedFromWarden", i); }
	}
	property bool bIsHHH
	{
		public get() 				{ return this.GetValue("bIsHHH"); }
		public set( const bool i )	{ this.SetValue("bIsHHH", i); }
	}
	property bool bInJump
	{
		public get() 				{ return this.GetValue("bInJump"); }
		public set( const bool i )	{ this.SetValue("bInJump", i); }
	}
	property bool bUnableToTeleport
	{
		public get() 				{ return this.GetValue("bUnableToTeleport"); }
		public set( const bool i )	{ this.SetValue("bUnableToTeleport", i); }
	}
	property bool bLasering
	{
		public get() 				{ return this.GetValue("bLasering"); }
		public set( const bool i )	{ this.SetValue("bLasering", i); }
	}
	property bool bIsMuted
	{
		public get() 				{ return this.GetValue("bIsMuted"); }
		public set( const bool i )	{ this.SetValue("bIsMuted", i); }
	}
	property bool bVoted
	{
		public get() 				{ return this.GetValue("bVoted"); }
		public set( const bool i )	{ this.SetValue("bVoted", i); }
	}

	property float flSpeed
	{
		public get() 				{ return this.GetValue("flSpeed"); }
		public set( const float i )	{ this.SetValue("flSpeed", i); }
	}
	property float flKillingSpree
	{
		public get() 				{ return this.GetValue("flKillingSpree"); }
		public set( const float i )	{ this.SetValue("flKillingSpree", i); }
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
	public native int SpawnWeapon( char[] name, const int index, const int level, const int qual, char[] att );

	/**
	 *	Retrieve an item definition index of a player's weaponslot.
	 *
	 *	@param slot 		Slot to grab the item index from.
	 *
	 *	@return 			Index of the valid, equipped weapon.
	*/
	public native int GetWeaponSlotIndex( const int slot );

	/**
	 *	Set the alpha magnitude a player's weapons.
	 *
	 *	@param alpha 		Number from 0 to 255 to set on the weapon.
	 *
	 *	@noreturn
	*/
	public native void SetWepInvis( const int alpha );

	/**
	 *	Silently switch a player's team.
	 *
	 *	@param team 		Team to switch to.
	 *	@param spawn 		Determine whether or not to respawn the client.
	 *
	 *	@noreturn
	*/
	public native void ForceTeamChange( const int team, bool spawn = true );

	/**
	 *	Teleport a player either to a freeday or warday location.
	 *	@note 				If gamemode teleport properties for the location are not true, 
	 * 						teleportation will fail.
	 *
	 *	@param location 	Location to teleport the client.
	 *
	 *	@noreturn
	*/
	public native void TeleportToPosition( const int location );

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
	public native void PreEquip( bool weps = true );

	/**
	 *	Teleport a player to the appropriate spawn location.
	 *
	 *	@param team 		Team spawn to teleport the client to.
	 *
	 *	@noreturn
	*/
	public native void TeleToSpawn( int team = 0 );

	/**
	 *	Spawn a small healthpack at the client's origin.
	 *
	 *	@param ownerteam 	Team to give the healthpack.
	 *
	 *	@noreturn
	*/
	public native void SpawnSmallHealthPack( int ownerteam = 0 );

	/**
	 *	Mute a client through the plugin.
	 *	@note 				Players that are deemed as admins will never be muted.
	 *
	 *	@noreturn
	*/
	public native void MutePlayer();

	/**
	 *	Initialize a player as a freeday.
	 *	@note 				Does not teleport them to the freeday location.
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
	 *	@note 				This automatically gives the player the warden menu
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
	 *	Terminate a player as the Horseless Headless Horsemann.
	 *
	 *	@noreturn
	*/
	public native void UnHorsemann();

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
	public native void ClimbWall( const int weapon, const float upwardvel, const float health, const bool attackdelay );

	/**
	 *	Have the player vote to fire the Current Warden.
	 *
	 *	@noreturn
	*/
	public native void AttemptFireWarden();
};

enum JBGameMode{}

/**
 *	Retrieve an instance of the JailGameMode StringMap.
 *	@note 					This inherits from StringMap, so you can perform
 * 							StringMap methods on it!
 *
 *	@return 				Handle to the JailGameMode internal StringMap.
*/
native JBGameMode JBGameMode_Instance();

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
*/
native JBPlayer JBGameMode_Warden();

/** 
 *	Find and terminate the current warden.
 *
 *	@param prevent 			Prevent the player from becoming warden again.
 * 	@param announce 		Display to all players that the warden was fired.
 *
 *	@noreturn
*/
native void JBGameMode_FireWarden(bool prevent = true, bool announce = true);

/**
 *	Open all of the doors on a map
 *	@note 					This ignores all name checks and opens every door possible.
 *
 *	@noreturn
*/
native void JBGameMode_OpenAllDoors();

/**
 *	Enable/Disable the medic room in a map
 *
 *	@param status 			True to enable it, False otherwise
 *
 *	@noreturn
*/
native void JBGameMode_ToggleMedic(const bool status);

/**
 *	Toggle team filtering on the medic room
 *
 *	@param team 			Team to toggle
 *
 *	@noreturn
*/
// native void JBGameMode_ToggleMedicTeam(int team = 0);

/**
 *	Trigger muting on clients.
 *
 *	@param player 			JBPlayer instance of player to toggle muting for.
 *	@param forcedead 		Force the client to be treated as dead, even if they aren't.
 *	@param teamchange 		Force team-based muting onto the client, even if they aren't
 *							on that team.
 *
 *	@noreturn
*/
native void JBGameMode_ToggleMuting(const JBPlayer player, bool forcedead = false, int teamchange = 0);

/**
 *	Reset the Warden-firing votes.
 *
 *	@noreturn
*/
native void JBGameMode_ResetVotes();

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
 *	@note 					This can set properties that GetProperty can access!
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
 *	bool bSilentWardenKills
 *	bool bMedicDisabled
 *	bool bDisableMuting
 *	bool bDisableKillSpree
 *	float flMusicTime
*/

methodmap JBGameMode < StringMap
{
	/**
	 *	Initialize global methodmap with a shared handle to the core JailGameMode methodmap.
	 *
	 *	@return 			Instance of the JailGameMode methodmap.
	*/
	public native JBGameMode();

	/**
	 *	Retrieve the amount of living/playing players in the server.
	*/
	property int iPlaying
	{
		public get()
		{
			return JBGameMode_Playing();
		}
	}
	/**
	 *	Get a property value from the JailGameMode internal methodmap (works like StringMap).
	 *	@deprecated 			Use JBGameMode.SetValue instead, or use the preset properties below.
	 *							You can also make a methodmap that inherites from JBGameMode, then
	 *							create the properties that you need.
	 *
	 *	@param prop_name 		Property key to call from.
	 *
	 *	@return 				Value received from called key.
	*/
#pragma deprecated Use 'JBGameMode.SetValue' instead, or use the preset properties.
	public bool SetProperty( const char prop_name[64], any i )
	{
		return this.SetValue(prop_name, i);
	}

	/**
	 *	Get a property value from the JailGameMode StringMap.
	 *	@deprecated 			UseJBGameMode.GetValue instead, or use the preset properties below.
	 *							You can also make a methodmap that inherites from JBGameMode, then
	 *							get the properties that you need.
	 *
	 *	@param prop_name 		Property key to call from.
	 *
	 *	@return 				Value received from called key.
	*/
#pragma deprecated Use 'JBGameMode.GetValue' instead, or use the preset properties.
	public any GetProperty( const char prop_name[64] )
	{
		any i; this.GetValue(prop_name, i);
		return i;
	}

	property int iRoundState
	{
		public get()
		{
			int i; this.GetValue("iRoundState", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iRoundState", i);
		}
	}
	property int iTimeLeft
	{
		public get()
		{
			int i; this.GetValue("iTimeLeft", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iTimeLeft", i);
		}
	}
	property int iLRPresetType
	{
		public get()
		{
			int i; this.GetValue("iLRPresetType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLRPresetType", i);
		}
	}
	property int iLRType
	{
		public get()
		{
			int i; this.GetValue("iLRType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLRType", i);
		}
	}
	property int iRoundCount
	{
		public get()
		{
			int i; this.GetValue("iRoundCount", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iRoundCount", i);
		}
	}

	property bool bSteam
	{
		public get()
		{
			bool i; this.GetValue("bSteam", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSteam", i);
		}
	}
	property bool bSB
	{
		public get()
		{
			bool i; this.GetValue("bSB", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSB", i);
		}
	}
	property bool bSC
	{
		public get()
		{
			bool i; this.GetValue("bSC", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSC", i);
		}
	}
	property bool bVA
	{
		public get()
		{
			bool i; this.GetValue("bVA", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bVA", i);
		}
	}
	property bool bTF2Attribs
	{
		public get()
		{
			bool i; this.GetValue("bTF2Attribs", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bTF2Attribs", i);
		}
	}
	property bool bIsMapCompatible
	{
		public get()
		{
			bool i; this.GetValue("bIsMapCompatible", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsMapCompatible", i);
		}
	}
	property bool bFreedayTeleportSet
	{
		public get()
		{
			bool i; this.GetValue("bFreedayTeleportSet", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bFreedayTeleportSet", i);
		}
	}
	property bool bWardayTeleportSetBlue
	{
		public get()
		{
			bool i; this.GetValue("bWardayTeleportSetBlue", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardayTeleportSetBlue", i);
		}
	}
	property bool bWardayTeleportSetRed
	{
		public get()
		{
			bool i; this.GetValue("bWardayTeleportSetRed", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardayTeleportSetRed", i);
		}
	}
	property bool bCellsOpened
	{
		public get()
		{
			bool i; this.GetValue("bCellsOpened", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bCellsOpened", i);
		}
	}
	property bool b1stRoundFreeday
	{
		public get()
		{
			bool i; this.GetValue("b1stRoundFreeday", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("b1stRoundFreeday", i);
		}
	}
	property bool bIsLRInUse
	{
		public get()
		{
			bool i; this.GetValue("bIsLRInUse", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsLRInUse", i);
		}
	}
	property bool bIsWardenLocked
	{
		public get()
		{
			bool i; this.GetValue("bIsWardenLocked", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsWardenLocked", i);
		}
	}
	property bool bOneGuardLeft
	{
		public get()
		{
			bool i; this.GetValue("bOneGuardLeft", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bOneGuardLeft", i);
		}
	}
	property bool bOnePrisonerLeft
	{
		public get()
		{
			bool i; this.GetValue("bOnePrisonerLeft", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bOnePrisonerLeft", i);
		}
	}
	property bool bAdminLockWarden
	{
		public get()
		{
			bool i; this.GetValue("bAdminLockWarden", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAdminLockWarden", i);
		}
	}
	property bool bAdminLockedLR
	{
		public get()
		{
			bool i; this.GetValue("bAdminLockedLR", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAdminLockedLR", i);
		}
	}
	property bool bDisableCriticals
	{
		public get()
		{
			bool i; this.GetValue("bDisableCriticals", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bDisableCriticals", i);
		}
	}
	property bool bIsFreedayRound
	{
		public get()
		{
			bool i; this.GetValue("bIsFreedayRound", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsFreedayRound", i);
		}
	}
	property bool bWardenExists
	{
		public get()
		{
			bool i; this.GetValue("bWardenExists", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardenExists", i);
		}
	}
	property bool bAvoidTeamKills
	{
		public get()
		{
			bool i; this.GetValue("bAvoidTeamKills", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAvoidTeamKills", i);
		}
	}
	property bool bIsWarday
	{
		public get()
		{
			bool i; this.GetValue("bIsWarday", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsWarday", i);
		}
	}
	property bool bFirstDoorOpening
	{
		public get()
		{
			bool i; this.GetValue("bFirstDoorOpening", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bFirstDoorOpening", i);
		}
	}
	property bool bSilentWardenKills
	{
		public get()
		{
			bool i; this.GetValue("bSilentWardenKills", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSilentWardenKills", i);
		}
	}
	property bool bMedicDisabled
	{
		public get()
		{
			bool i; this.GetValue("bMedicDisabled", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bMedicDisabled", i);
		}
	}
	property bool bDisableMuting
	{
		public get()
		{
			bool i; this.GetValue("bDisableMuting", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bDisableMuting", i);
		}
	}
	property bool bDisableKillSpree
	{
		public get()
		{
			bool i; this.GetValue("bDisableKillSpree", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bDisableKillSpree", i);
		}
	}

	property bool bAllowBuilding
	{
		public get()
		{
			bool i; this.GetValue("bAllowBuilding", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAllowBuilding", i);
		}
	}

	property float flMusicTime
	{
		public get()
		{
			float i; this.GetValue("flMusicTime", i);
			return i;
		}
		public set( const float i )
		{
			this.SetValue("flMusicTime", i); 
		}
	}

	/**
	 *	Find and Initialize a random player as the warden.
	 *
	 *	@noreturn
	*/
	public void FindRandomWarden()
	{
		JBGameMode_FindRandomWarden();
	}

	/**
	 *	Handle the cell doors.
	 *
	 *	@param status 			Type of cell door usage found in the eDoorsMode enum.
	 *
	 *	@noreturn
	*/
	public void DoorHandler( const eDoorsMode status )
	{
		JBGameMode_ManageCells(status);
	}

	 /**
	 *	Find the current warden if one exists.
	 *
	 *	@return 				The current warden.
	*/
	property JBPlayer Warden
	{
		public get()
		{
			return JBGameMode_Warden();
		}
	}

	/** 
	 *	Find and terminate the current warden.
	 *
	 *	@param prevent 			Prevent the player from becoming warden again.
	 * 	@param announce 		Display to all players that the warden was fired.
	 *
	 *	@noreturn
	*/
	public void FireWarden( bool prevent = true, bool announce = true )
	{
		JBGameMode_FireWarden(prevent, announce);
	}

	/**
	 *	Open all doors in a map.
	 *
	 *	@noreturn
	*/
	public void OpenAllDoors()
	{
		JBGameMode_OpenAllDoors();
	}

	/**
	 *	Enable/Disable the medic room in a map
	 *
	 *	@param status 			True to enable it, False otherwise
	 *
	 *	@noreturn
	*/
	public void ToggleMedic( const bool status )
	{
		JBGameMode_ToggleMedic(status);
	}

	/**
	 *	Toggle team filtering on the medic room
	 *
	 *	@param team 			Team to toggle
	 *
	 *	@noreturn
	*/
	/*public void ToggleMedicTeam(int team = 0)
	{
		JBGameMode_ToggleMedicTeam(team);
	}*/

	/**
	 *	Trigger muting on clients.
	 *
	 *	@param player 			JBPlayer instance of player to toggle muting for.
	 *	@param forcedead 		Force the client to be treated as dead, even if they aren't.
	 *	@param teamchange 		Force team-based muting onto the client, even if they aren't
	 *							on that team.
	 *
	 *	@noreturn
	*/
	public void ToggleMuting(const JBPlayer player, bool forcedead = false, int teamchange = 0)
	{
		JBGameMode_ToggleMuting(player, forcedead, teamchange);
	}

	/**
	 *	Reset the Warden-firing votes.
	 *
	 *	@noreturn
	*/
	public void ResetVotes()
	{
		JBGameMode_ResetVotes();
	}
};


/**
 *	Registers a sub-plugin to be added to the last request handle.
 *	@note 					The purpose of this native is to register last-request subplugins, 
 * 							you don't need to register plugins to use forwards, 
 *							simply hook what forward you need.
 *							You MUST register a Last Request sub-plugin in order for it to work.
 *
 *	@return					True on success.
*/
native bool TF2JailRedux_RegisterPlugin();

/**
 *	Registers a sub-plugin to be added to the last request handle.
 *	@note 					This native is explicitly made for using multiple last requests
 *							with a single plugin. Indices collect upon registration are 
 * 							incremented above the plugin index; TF2JailRedux_LRIndex()+1, +2, etc.
 *
 *	@return					True on success.
*/
native bool TF2JailRedux_RegisterLR();

/**
 *	Un-registers a sub-plugin from the last request handle.
 *	@note 					This is optional, however doing this will prevent breakage when unloading
 *							or reloading sub-plugins mid-game.
 *							This is best suited to be used OnPluginEnd().
 *
 *	@return 				True on success. False if the plugin is not registered.
*/
native bool TF2JailRedux_UnRegisterPlugin();

/**
 *	Un-registers a last request from a sub-plugin.
 *	@note 					This is optional, however doing this will prevent breakage when unloading
 * 							or reloading sub-plugins mid-game. This MUST be done before unregistering
 * 							the plugin in its entirety.
 * 							This is best suited to be used OnPLuginEnd().
 *
 *	@param idx 				Index of the last request to remove. This must be greater than
 * 							TF2JailRedux_LRIndex(). See TF2JailRedux_RegisterLR().
 *
 *	@return 				True on success. False if the plugin is not registered.
*/
native bool TF2JailRedux_UnRegisterLR(int idx);

/**
 *	Retrieve the calling plugin's LR index.
 *	@note 					This does not work on LR pack sub-plugins.
 *
 *	@return 				LR index of this plugin if it is registered. 0 otherwise.
*/
native int TF2JailRedux_LRIndex();


enum	// JB Hook Types
{
	OnDownloads = 0,
	OnRoundStart,
	OnRoundStartPlayer,
	OnRoundEnd,
	OnRoundEndPlayer,
	OnPreThink,
	OnRedThink,
	OnBlueThink,
	OnWardenGet,
	OnClientTouch,
	OnWardenThink,
	OnPlayerSpawned,
	OnPlayerDied,
	OnWardenKilled,
	OnTimeLeft,
	OnPlayerPrepped,
	OnHurtPlayer,
	OnTakeDamage,
	OnLastGuard,
	OnLastPrisoner,
	OnCheckLivingPlayers,
	OnBuildingDestroyed,
	OnObjectDeflected,
	OnPlayerJarated,
	OnUberDeployed,
	OnMenuAdd,
	OnPanelAdd,
	OnHudShow,
	OnLRPicked,
	OnWMenuAdd,
	OnWMenuSelect,
	OnClientInduction,
	OnVariableReset,
	OnTimeEnd,
	OnFreedayGiven,
	OnFreedayRemoved,
	OnFFTimer,
	OnDoorsOpen,
	OnDoorsClose,
	OnDoorsLock,
	OnDoorsUnlock,
	OnPlayerPreppedPre,
	OnLRGiven,
	OnSoundHook,
	OnEntCreated,
	OnCalcAttack,
	OnRebelGiven,
	OnRebelRemoved,
	OnPlayMusic
};

/* SDKHook-Style Forwards */
typeset JBHookCB
{
	/*
		OnRoundStartPlayer
		OnRedThink
		OnBlueThink
		OnWardenThink
		OnPlayerPrepped
		OnClientInduction
		OnVariableReset
		OnFreedayGiven
		OnFreedayRemoved
		OnLRGiven
		OnPreThink
		OnRebelGiven
		OnRebelRemoved
	*/
	function void (const JBPlayer player);
	
	/*
		OnPlayerSpawned
		OnRoundEndPlayer
	*/
	function void (const JBPlayer player, Event event);

	/*
		OnClientTouch
		OnPlayerJarated
		OnUberDeployed		Medic is player, Patient is victim
	*/
	function void (const JBPlayer player, const JBPlayer victim);

	//	OnBuildingDestroyed
	function void (const JBPlayer attacker, const int building, Event event);

	/*
		OnPlayerDied
		OnPlayerAirblasted
	*/
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);

	/*
		OnDownloads
		OnCheckLivingPlayers
	*/
	function void ();

	//	OnMenuAdd
	function void (const int index, int &max, char name[32]);

	//	OnPanelAdd
	function void (const int index, char name[64]);

	/*	
		OnRoundEnd
		OnRoundStart
	*/
	function void (Event event);

	//	OnWMenuAdd
	function void (Menu &menu);	

	// 	OnHudShow
	function void (char hud[128]);

	// 	OnLRPicked			Return anything but Continue to prevent setting the next iLRPresetType to index
	function Action (const JBPlayer player, const int index, ArrayList array);

	// 	OnHurtPlayer
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);

	// 	OnTakeDamage
	function Action (const JBPlayer victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnWMenuSelect
	function Action (const JBPlayer player, const char[] index);

	//	OnPlayMusic
	function Action (char song[PLATFORM_MAX_PATH], float &time);

	/*
		OnTimeEnd			Return anything but Continue to override forcing Blue team to win
		OnLastGuard			Return Handled to stop "One Guard Left" message. Return Stop to not fire OnCheckLivingPlayers
		OnLastPrisoner		Return Stop to not fire OnCheckLivingPlayers
		OnDoorsOpen 		Return anything but Continue to not fire
		OnDoorsClose 		Return anything but Continue to not fire
		OnDoorsLock 		Return anything but Continue to not fire
		OnDoorsUnlock 		Return anything but Continue to not fire
	*/
	function Action ();

	//	OnWardenKilled		Return anything but Continue to stop "Warden has been killed" message
	function Action (const JBPlayer victim, const JBPlayer attacker, Event event);

	//	OnFFTimer
	function void (float &time);

	//	OnTimeLeft
	function void (int &time);

	/*
		OnWardenGet
		OnPlayerPreppedPre
	*/
	function Action (const JBPlayer player);

	//	OnSoundHook
	function Action (int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed);

	//	OnEntCreated
	function Action (int ent, const char[] classname);

	//	OnCalcAttack
	function Action (JBPlayer player, int weapon, char[] weaponname, bool &result);
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
 *	@note 					This automatically hooks functions into forwards if it wasn't already (if possible).
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
 *	@note 					This automatically unhooks functions from forwards if they weren't already (if possible).
 *	
 *	@param callbacktype 	Enum type to unhook from.
 *	@param callback 		Function to hunhook calls from.
 *
 *	@return 				True on successful unhook, false otherwise or if function wasn't hooked.
*/
native bool JB_UnhookEx(const int callbacktype, JBHookCB callback);



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
public void __pl_tf2jailredux_SetNTVOptional()
{
	MarkNativeAsOptional("TF2JailRedux_RegisterPlugin");
	MarkNativeAsOptional("TF2JailRedux_RegisterLR");
	MarkNativeAsOptional("TF2JailRedux_UnRegisterPlugin");
	MarkNativeAsOptional("TF2JailRedux_UnRegisterLR");
	MarkNativeAsOptional("TF2JailRedux_LRIndex");

	MarkNativeAsOptional("JB_Hook");
	MarkNativeAsOptional("JB_HookEx");
	MarkNativeAsOptional("JB_Unhook");
	MarkNativeAsOptional("JB_UnhookEx");

	MarkNativeAsOptional("JBPlayer.GetValue");
	MarkNativeAsOptional("JBPlayer.SetValue");

	MarkNativeAsOptional("JBPlayer.bNoMusic.get");
	MarkNativeAsOptional("JBPlayer.hMap.get");

	MarkNativeAsOptional("JBPlayer.SpawnWeapon");
	MarkNativeAsOptional("JBPlayer.GetWeaponSlotIndex");
	MarkNativeAsOptional("JBPlayer.SetWepInvis");
	MarkNativeAsOptional("JBPlayer.ForceTeamChange");
	MarkNativeAsOptional("JBPlayer.TeleportToPosition");
	MarkNativeAsOptional("JBPlayer.ListLRS");
	MarkNativeAsOptional("JBPlayer.PreEquip");
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
	MarkNativeAsOptional("JBPlayer.UnHorsemann");
	MarkNativeAsOptional("JBPlayer.WardenMenu");
	MarkNativeAsOptional("JBPlayer.ClimbWall");
	MarkNativeAsOptional("JBPlayer.AttemptFireWarden");

	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_Warden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
	MarkNativeAsOptional("JBGameMode_OpenAllDoors");
	MarkNativeAsOptional("JBGameMode_ToggleMedic");
	// MarkNativeAsOptional("JBGameMode_ToggleMedicTeam");
	MarkNativeAsOptional("JBGameMode_ResetVotes");

	MarkNativeAsOptional("JBGameMode_Instance");
	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");

	MarkNativeAsOptional("JBGameMode.JBGameMode");
}
#endif