#if defined _tf2jr_gamemode_included
	#endinput
#endif
#define _tf2jr_gamemode_included

#include <tf2jailredux/player>
#include <tf2jailredux/lastrequest>

enum eDoorsMode
{	// Doors obviously
	OPEN = 0,
	CLOSE,
	LOCK,
	UNLOCK
};


/**
 *	@section non-methodmap Gamemode natives
*/

/**
 *	Retrieve an instance of the JailGameMode StringMap.
 *	@note 					This inherits from StringMap, so you can perform
 * 							StringMap methods on it!
 *							DO NOT DELETE THIS UNDER ANY CIRCUMSTANCES
 *
 *	@return 				Handle to the JailGameMode internal StringMap.
*/
native JBGameMode JBGameMode_Instance();

/**
 *	Retrieve the amount of living/playing players in the server.
 *
 *	@return 				The number of players currently alive.
*/
stock int JBGameMode_Playing()
{
	int playing;
	for (int i = MaxClients; i; --i) 
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;
		++playing;
	}
	return playing;
}

/**
 *	Find and Initialize a random player as the warden.
 *
 *	@return 				JBPlayer instance of the new Warden if they were valid.
*/
native JBPlayer JBGameMode_FindRandomWarden();

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
 *	Get the position of a certain teleportation location.
 *
 *	@param location  		Location index to get.
 *	@param array 			Vector to copy to.
 *
 *	@return 				True if the location property is valid.
*/
native bool JBGameMode_GetTelePosition(const int location, float[] array);

/**
 *	Toggle the Warden's lock status.
 *	@note 					This is recommended rather than setting the raw property due
 *							to a forward plugins can operate on.
 *
 *	@param status  			Location index to get.
 *	@param unsetwarden 		If true, unset the current warden.
 *
 *	@return 				True on success, false otherwise.
*/
native bool JBGameMode_SetWardenLock(const bool status, bool unsetwarden = false);

/**
 *	Get a property value from the JailGameMode internal methodmap (works like StringMap).
 *	@deprecated 			Use type-safe GetProp* functions instead
 *
 *	@param name 			Property key to call from.
 *
 *	@return 				Value received from called key.
*/
#pragma deprecated Use type-safe GetProp* functions instead
native any JBGameMode_GetProperty(const char[] key);

/**
 *	Set a property to the JailGameMode internal methodmap.
 *	@deprecated 			Use type-safe SetProp* functions instead
 *	@note 					This can set properties that GetProperty can access!
 *
 *	@param name 			Property key to set into the StringMap.
 *	@param value 			Value to set to it.
 *
 *	@noreturn
*/
#pragma deprecated Use type-safe SetProp* functions instead
native void JBGameMode_SetProperty(const char[] key, any value);

native any JBGameMode_GetProp(const char[] key);
native void JBGameMode_SetProp(const char[] key, any val);

native float JBGameMode_GetPropFloat(const char[] key);
native void JBGameMode_SetPropFloat(const char[] key, float val);

native int JBGameMode_GetPropString(const char[] key, char[] buffer, int maxlen);
native void JBGameMode_SetPropString(const char[] key, const char[] val);

native void JBGameMode_GetPropArray(const char[] key, any[] val, int maxlen);
native void JBGameMode_SetPropArray(const char[] key, any[] val, int maxlen);

/**
 *	Autobalance the teams in accordance with the cvars.
 *
 *	@param announce 		Tell the player that they've been autobalanced.
 *
 *	@noreturn
*/
native void JBGameMode_AutobalanceTeams(bool announce = true);

/**
 *	Autobalance the teams as evenly as possible.
 *	@note 					Guardbanned players are handled automatically.
 *
 *	@param announce			Tell the player that they've been autobalanced.
 *	@param followimmun 		If true, follow autobalance immunity rules.
 *
 *	@noreturn
*/
native void JBGameMode_EvenTeams(bool announce = true, bool followimmun = true);

/**
 *	Retrieve a Handle to the gamemode's current last request.
 *	@note 					Last requests are only active when iRoundState is StateRunning.
 *
 *	@return 				LastRequest Handle to current LR, or null if iLRType is -1.
*/
stock LastRequest JBGameMode_GetCurrentLR()
{
	return LastRequest.At(JBGameMode_GetProp("iLRType"));
}

/**
 *	Retrieve a last request by it's name.
 *	@note 					This is also its 'Name' entry in the config if it exists
 *
 *	@return 				LastRequest Handle to LR if found, null otherwise.
*/
stock LastRequest JBGameMode_GetLRByName(const char[] name)
{
	return LastRequest.ByName(name);
}

/** Properties
 *	int iRoundState
 *	int iTimeLeft
 *	int iLRPresetType
 *	int iLRType
 *	bool bSteam				// If has SteamTools
 *	bool bSB 				// If has SourceBans (Optional, not used in core)
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
 *	bool bIsLRRound
 *	bool bWardenExists
 *	bool bAvoidTeamKills
 *	bool bIsWarday
 *	bool bFirstDoorOpening
 *	bool bSilentWardenKills
 *	bool bMedicDisabled
 *	bool bDisableMuting
 *	bool bDisableKillSpree
 *	bool bIsLRRound
 *	float flMusicTime
*/

/**
 *	@endsection
*/


/**
 *	@section Gamemode methodmap
*/

methodmap JBGameMode < StringMap
{
	/**
	 *	Initialize global methodmap with a shared handle to the core JailGameMode methodmap.
	 *	@note				DO NOT DELETE THIS UNDER ANY CIRCUMSTANCES
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
	 *	@deprecated 		Use type-safe SetProp* functions instead
	 *
	 *	@param key 			Property key to call from.
	 *
	 *	@return 			Value received from called key.
	*/
#pragma deprecated Use type-safe SetProp* functions instead
	public bool SetProperty( const char[] key, any i )
	{
		return this.SetValue(key, i);
	}

	/**
	 *	Get a property value from the JailGameMode StringMap.
	 *	@deprecated 		Use type-safe GetProp* functions instead
	 *
	 *	@param key 			Property key to call from.
	 *
	 *	@return 			Value received from called key.
	*/
#pragma deprecated Use type-safe SetProp* functions instead
	public any GetProperty( const char[] key )
	{
		any i; this.GetValue(key, i);
		return i;
	}

	public any GetProp(const char[] key)
	{
		any i; this.GetValue(key, i);
		return i;
	}

	public void SetProp(const char[] key, any val)
	{
		this.SetValue(key, val);
	}

	public float GetPropFloat(const char[] key)
	{
		float val; this.GetValue(key, val);
		return val;
	}

	public void SetPropFloat(const char[] key, float val)
	{
		this.SetValue(key, val);
	}

	public int GetPropString(const char[] key, char[] buffer, int maxlen)
	{
		return this.GetString(key, buffer, maxlen);
	}

	public void SetPropString(const char[] key, const char[] val)
	{
		this.SetString(key, val);
	}

	public void GetPropArray(const char[] key, any[] buffer, int maxlen)
	{
		this.GetArray(key, buffer, maxlen);
	}

	public void SetPropArray(const char[] key, any[] val, int maxlen)
	{
		this.SetArray(key, val, maxlen);
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
	property int iMuteType
	{
		public get()
		{
			int i; this.GetValue("iMuteType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iMuteType", i);
		}
	}
	property int iLivingMuteType
	{
		public get()
		{
			int i; this.GetValue("iLivingMuteType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLivingMuteType", i);
		}
	}
	property int iVoters
	{
		public get()
		{
			int i; this.GetValue("iVoters", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iVoters", i);
		}
	}
	property int iVotes
	{
		public get()
		{
			int i; this.GetValue("iVotes", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iVotes", i);
		}
	}
	property int iVotesNeeded
	{
		public get()
		{
			int i; this.GetValue("iVotesNeeded", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iVotesNeeded", i);
		}
	}
	property int iLRs
	{
		public get()
		{
			int i; this.GetValue("iLRs", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLRs", i);
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
	property bool bAllowWeapons
	{
		public get()
		{
			bool i; this.GetValue("bAllowWeapons", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAllowWeapons", i);
		}
	}
	property bool bIgnoreRebels
	{
		public get()
		{
			bool i; this.GetValue("bIgnoreRebels", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIgnoreRebels", i);
		}
	}
	property bool bIsLRRound
	{
		public get()
		{
			bool i; this.GetValue("bIsLRRound", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsLRRound", i);
		}
	}
	property bool bMarkerExists
	{
		public get()
		{
			bool i; this.GetValue("bMarkerExists", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bMarkerExists", i);
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

	property JBPlayer iWarden
	{
		public get()
		{
			int i; this.GetValue("iWarden", i);
			JBPlayer player = JBPlayer.OfUserId(i);
			if (!player || !player.bIsWarden)
				return view_as< JBPlayer >(0);
			return player;
		}
		public set( const JBPlayer i )
		{
			this.SetValue("iWarden", i ? i.userid : 0);
		}
	}

	property Menu hWardenMenu
	{
		public get()
		{
			Menu i; this.GetValue("hWardenMenu", i);
			return i;
		}
		public set( const Menu i )
		{
			this.SetValue("hWardenMenu", i);
		}
	}

	property StringMap hLRS
	{
		public get()
		{
			StringMap i; this.GetValue("hLRS", i);
			return i;
		}
		public set ( const StringMap i )
		{
			this.SetValue("hLRS", i);
		}
	}
	property StringMap hTargetFilters
	{
		public get()
		{
			StringMap i; this.GetValue("hTargetFilters", i);
			return i;
		}
		public set ( const StringMap i )
		{
			this.SetValue("hTargetFilters", i);
		}
	}

	property ArrayList hLRCount
	{
		public get()
		{
			ArrayList i; this.GetValue("hLRCount", i);
			return i;
		}
		public set ( const ArrayList i )
		{
			this.SetValue("hLRCount", i);
		}
	}


	/**
	 *	Find and Initialize a random player as the warden.
	 *
	 *	@return 				JBPlayer instance of the new Warden if they were valid.
	*/
	public JBPlayer FindRandomWarden()
	{
		return JBGameMode_FindRandomWarden();
	}

	/**
	 *	Handle the cell doors.
	 *
	 *	@param status 		Type of cell door usage found in the eDoorsMode enum.
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
	 *	@return 			JBPlayer instance of the current warden.
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
	 *	@param prevent 		Prevent the player from becoming warden again.
	 * 	@param announce 	Display to all players that the warden was fired.
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
	 *	@param status 		True to enable it, False otherwise
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
	 *	@param team 		Team to toggle
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
	 *	@param player 		JBPlayer instance of player to toggle muting for.
	 *	@param forcedead 	Force the client to be treated as dead, even if they aren't.
	 *	@param teamchange 	Force team-based muting onto the client, even if they aren't
	 *						on that team.
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

	/**
	 *	Get the position of a certain teleportation location.
	 *
	 *	@param location  	Location index to get.
	 *	@param array 		Vector to copy to.
	 *
	 *	@return 			True if the location property is valid.
	*/
	public bool GetTelePosition( const int location, float[] array )
	{
		return JBGameMode_GetTelePosition(location, array);
	}

	/**
	 *	Autobalance the teams in accordance with the cvars.
	 *
	 *	@param announce 		Tell the player that they've been autobalanced.
	 *
	 *	@noreturn
	*/
	public void AutobalanceTeams(bool announce = true)
	{
		JBGameMode_AutobalanceTeams(announce);
	}

	/**
	 *	Autobalance the teams as evenly as possible.
	 *	@note 					Guardbanned players are handled automatically.
	 *
	 *	@param announce			Tell the player that they've been autobalanced.
	 *	@param followimmun 		If true, follow autobalance immunity rules.
	 *
	 *	@noreturn
	*/
	public void EvenTeams(bool announce = true, bool followimmun = true)
	{
		JBGameMode_EvenTeams(announce, followimmun);
	}

	/**
	 *	Retrieve a Handle to the gamemode's current last request
	 *	@note 					Last requests are only active when iRoundState is StateRunning
	 *
	 *	@return 				LastRequest Handle to current LR, or null if iLRType is -1
	*/
	public LastRequest GetCurrentLR()
	{
		return JBGameMode_GetCurrentLR();
	}
};

/**
 *	@endsection
*/