#if defined _tf2jr_player_included
	#endinput
#endif
#define _tf2jr_player_included

/**
 *	@section Player methodmap
*/
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
	 *	Constructs an instance of the JBPLayer methodmap directly from a client's serial.
	 *
	 *	@param serial 		Serial of the client.
	 *
	 *	@return 			A player instance of the JBPlayer methodmap.
	*/
	public static JBPlayer OfSerial( const int serial )
	{
		return view_as< JBPlayer >(GetClientFromSerial(serial));
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
	 *	@deprecated 		Use JBPlayer.GetProp or JBPlayer.GetPropFloat
	 *	Gets the property of the internal JailFighter methodmap.
	 *	@note 				If you are getting a float value, you MUST view_as< float >.
	 *
	 *	@param key			Name of property you want to access data from.
	 *	@param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 *	@return				Property value called if it was valid.
	*/
	#pragma deprecated Use type-safe JBPlayer.GetProp or JBPlayer.GetPropFloat
	public native any GetValue( const char key[64] );

	/**
	 *	@deprecated 		Use JBPlayer.SetProp or JBPlayer.SetPropFloat
	 *	Sets the property of the internal JB methodmap.
	 *	NOTE: You can use this to create new properties which GetValue can access!
	 *
	 *	@param key			Name of the property you want to override data from (works like StringMap).
	 *	@param value		Data you want the property to hold.
	 *
	 *	@noreturn
	*/
	#pragma deprecated Use type-safe JBPlayer.SetProp or JBPlayer.SetPropFloat
	public native void SetValue( const char key[64], any value );

	/** PROPS
	 *	Basic get/set to JailFighter properties.
	 *	Properties are handled in the internal StringMap and can be accessed
	 *	by any plugin that uses the proper function.
	 *	You can also create new keys that GetProp* can access!
	**/

	public any GetProp(const char[] key)
	{
		any val; this.hMap.GetValue(key, val);
		return val;
	}
	public void SetProp(const char[] key, any val)
	{
		this.hMap.SetValue(key, val);
	}
	public float GetPropFloat(const char[] key)
	{
		float val; this.hMap.GetValue(key, val);
		return val;
	}
	public void SetPropFloat(const char[] key, float val)
	{
		this.hMap.SetValue(key, val);
	}
	public int GetPropString(const char[] key, char[] buffer, int maxlen)
	{
		return this.hMap.GetString(key, buffer, maxlen);
	}
	public void SetPropString(const char[] key, const char[] val)
	{
		this.hMap.SetString(key, val);
	}

	public void GetPropArray(const char[] key, any[] buffer, int maxlen)
	{
		this.hMap.GetArray(key, buffer, maxlen);
	}
	public void SetPropArray(const char[] key, any[] val, int maxlen)
	{
		this.hMap.SetArray(key, val, maxlen);
	}

	property int iCustom
	{
		public get() 				{ return this.GetProp("iCustom"); }
		public set( const int i )	{ this.SetProp("iCustom", i); }
	}
	property int iKillCount
	{
		public get() 				{ return this.GetProp("iKillCount"); }
		public set( const int i )	{ this.SetProp("iKillCount", i); }
	}
	property int iRebelParticle
	{
		public get() 				{ return this.GetProp("iRebelParticle"); }
		public set( const int i )	{ this.SetProp("iRebelParticle", i); }
	}
	property int iWardenParticle
	{
		public get() 				{ return this.GetProp("iWardenParticle"); }
		public set( const int i )	{ this.SetProp("iWardenParticle", i); }
	}
	property int iFreedayParticle
	{
		public get() 				{ return this.GetProp("iFreedayParticle"); }
		public set( const int i )	{ this.SetProp("iFreedayParticle", i); }
	}
	property int iFreekillerParticle
	{
		public get() 				{ return this.GetProp("iFreekillerParticle"); }
		public set( const int i )	{ this.SetProp("iFreekillerParticle", i); }
	}
	property int iHealth
	{
		public get() 				{ return this.GetProp("iHealth"); }
		public set( const int i )	{ this.SetProp("iHealth", i); }
	}
	property int nWardenStabbed
	{
		public get() 				{ return this.GetProp("nWardenStabbed"); }
		public set( const int i )	{ this.SetProp("nWardenStabbed", i); }
	}

	property bool bIsWarden
	{
		public get() 				{ return this.GetProp("bIsWarden"); }
		public set( const bool i )	{ this.SetProp("bIsWarden", i); }
	}
	property bool bIsQueuedFreeday
	{
		public get() 				{ return this.GetProp("bIsQueuedFreeday"); }
		public set( const bool i )	{ this.SetProp("bIsQueuedFreeday", i); }
	}
	property bool bIsFreeday
	{
		public get() 				{ return this.GetProp("bIsFreeday"); }
		public set( const bool i )	{ this.SetProp("bIsFreeday", i); }
	}
	property bool bLockedFromWarden
	{
		public get() 				{ return this.GetProp("bLockedFromWarden"); }
		public set( const bool i )	{ this.SetProp("bLockedFromWarden", i); }
	}
	property bool bInJump
	{
		public get() 				{ return this.GetProp("bInJump"); }
		public set( const bool i )	{ this.SetProp("bInJump", i); }
	}
	property bool bUnableToTeleport
	{
		public get() 				{ return this.GetProp("bUnableToTeleport"); }
		public set( const bool i )	{ this.SetProp("bUnableToTeleport", i); }
	}
	property bool bLasering
	{
		public get() 				{ return this.GetProp("bLasering"); }
		public set( const bool i )	{ this.SetProp("bLasering", i); }
	}
	property bool bIsMuted
	{
		public get() 				{ return this.GetProp("bIsMuted"); }
		public set( const bool i )	{ this.SetProp("bIsMuted", i); }
	}
	property bool bVoted
	{
		public get() 				{ return this.GetProp("bVoted"); }
		public set( const bool i )	{ this.SetProp("bVoted", i); }
	}
	property bool bIsRebel
	{
		public get() 				{ return this.GetProp("bIsRebel"); }
		public set( const bool i )	{ this.SetProp("bIsRebel", i); }
	}
	property bool bIsFreekiller
	{
		public get() 				{ return this.GetProp("bIsFreekiller"); }
		public set( const bool i )	{ this.SetProp("bIsFreekiller", i); }
	}
	property bool bIsVIP
	{
		public get() 				{ return this.GetProp("bIsVIP"); }
		public set( const bool i )	{ this.SetProp("bIsVIP", i); }
	}
	property bool bIsAdmin
	{
		public get() 				{ return this.GetProp("bIsAdmin"); }
		public set( const bool i )	{ this.SetProp("bIsAdmin", i); }
	}
	property bool bSkipPrep
	{
		public get() 				{ return this.GetProp("bSkipPrep"); }
		public set( const bool i )	{ this.SetProp("bSkipPrep", i); }
	}
	property bool bSelectingLR
	{
		public get() 				{ return this.GetProp("bSelectingLR"); }
		public set( const bool i )	{ this.SetProp("bSelectingLR", i); }
	}

	property float flSpeed
	{
		public get() 				{ return this.GetPropFloat("flSpeed"); }
		public set( const float i )	{ this.SetPropFloat("flSpeed", i); }
	}
	property float flKillingSpree
	{
		public get() 				{ return this.GetPropFloat("flKillingSpree"); }
		public set( const float i )	{ this.SetPropFloat("flKillingSpree", i); }
	}
	property float flHealTime
	{
		public get() 				{ return this.GetPropFloat("flHealTime"); }
		public set( const float i )	{ this.SetPropFloat("flHealTime", i); }
	}

	property Handle hRebelTimer
	{
		public get() 				{ return this.GetProp("hRebelTimer"); }
		public set( const Handle i ){ this.SetProp("hRebelTimer", i); }		
	}
	property Handle hFreekillTimer
	{
		public get() 				{ return this.GetProp("hFreekillTimer"); }
		public set( const Handle i ){ this.SetProp("hFreekillTimer", i); }		
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
	 *	@return 			True on success, false otherwise.
	*/
	public native bool TeleportToPosition( const int location );

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
	 *	@param attackdelay 	Delay the player's next attack.
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

	/**
	 *	Mark a player as a rebel.
	 *
	 *	@noreturn
	*/
	public native void MarkRebel();

	/**
	 *	Clear a player's rebel status.
	 *
	 *	@noreturn
	*/
	public native void ClearRebel();
};

/**
 *	@endsection
*/
