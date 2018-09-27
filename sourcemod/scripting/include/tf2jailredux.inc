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

stock const char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };


/**	JailFighter.GetValue
 *	Gets the property of the internal JailFighter methodmap.
 *
 *	@param client 		Player index.
 *	@param key			Name of property you want to access data from.
 *	@param item			Reference to use of the variable to overwrite with data from the property.
 *
 *	@return				Property value called if it was valid
*/
native any JB_GetValue(const int client, const char key[64]);

/**	JailFighter.SetValue
 *	Sets the property of the internal JB methodmap.
 *	@note 				You can use this to create new properties which GetValue can access!
 *
 *	@param client 		Player index.
 *	@param key			Name of the property you want to override data from (works like StringMap).
 *	@param value		Data you want the property to hold.
 *
 *	@noreturn
*/
native void JB_SetValue(const int client, const char key[64], any value);

/**		AVAILABLE PROPERTIES
 *	int iLRCustom							// For the Custom LR
 *	int iKillCount							// For the ghetto rigged freekill system
 *	bool bIsWarden 							// Client is/isn't Warden
 *	bool bIsMuted							// Varies with CVars
 *	bool bIsQueuedFreeday					// Freeday for Self or Freeday for Others
 *	bool bIsFreeday 						// Client is/isn't a freeday
 *	bool bLockedFromWarden					// Upon being fired or retiring
 *	bool bIsVIP								// Default Reserve flag
 *	bool bIsAdmin							// Default Generic flag
 *	bool bIsHHH								// For the HHHDay LR
 *	bool bInJump							// Client is rocket/sticky jumping
 *	bool bUnableToTeleport 					// Client can/can't teleport with Eureka Effect
 *	float flSpeed 							// Client speed, isn't used
 *	float flKillSpree 						// Also for the ghetto rigged freekill system
*/

/**	JailFighter.SpawnWeapon
 *	Creates and spawns a weapon to a player.
 *
 *	@param client 		Player index.
 *	@param name 		Entity name of the weapon being spawned (Cannot be a wearable).
 *	@param index 		Item index of the weapon.
 *	@param level		Item level of the weapon.
 *	@param qual			Item quality of the weapon.
 *	@param att 			Item attributes separated by " ; ".
 *
 *	@return				The weapon spawned to the client.
*/
stock int TF2_SpawnWeapon(const int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == null)
		return -1;
	
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	count &= ~1;
	if (count > 0) 
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2 = 0;
		for (int i = 0 ; i < count ; i += 2) 
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete hWeapon;
	EquipPlayerWeapon(client, entity);
	return entity;
}
/**	JailFighter.GetWeaponSlotIndex
 *	Retrieve an item definition index of a player's weaponslot.
 *
 *	@param client 		Player index.
 *	@param slot 		Slot to grab the item index from.
 *
 *	@return 			Index of the valid, equipped weapon.
*/
stock int GetIndexOfWeaponSlot(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
}

/**	JailFighter.SetWepInvis
 *	Set the alpha magnitude a player's weapons.
 *
 *	@param client 		Player index.
 *	@param alpha 		Number from 0 to 255 to set on the weapon.
 *
 *	@noreturn
*/
stock void SetWeaponInvis(const int client, const int alpha)
{
	int transparent = alpha;
	for (int i = 0; i < 5; i++) 
	{
		int entity = GetPlayerWeaponSlot(client, i); 
		if (IsValidEdict(entity) && IsValidEntity(entity))
		{
			if (transparent > 255)
				transparent = 255;
			if (transparent < 0)
				transparent = 0;
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 150, 150, 150, transparent); 
		}
	}
}

/**	JailFighter.ForceTeamChange
 *	Silently switch a player's team.
 *
 *	@param client 		Player index.
 *	@param team 		Team to switch to.
 *	@param spawn 		Determine whether or not to respawn the client.
 *
 *	@noreturn
*/
stock void ForceClientTeamChange(const int client, const int iTeam, bool spawn = true)
{
	if (TF2_GetPlayerClass(client) > TFClass_Unknown)
	{
		SetEntProp(client, Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(client, iTeam);
		SetEntProp(client, Prop_Send, "m_lifeState", 0);
		if (spawn)
			TF2_RespawnPlayer(client);
	}
}

/**	JailFighter.TeleportToPosition
 *	Teleport a player either to a freeday or warday location.
 *	@note 				If gamemode teleport properties are not true, teleportation will fail
 *
 *	@param client 		Player index.
 *	@param location 	Location to teleport the client.
 *
 *	@noreturn
*/
native void JB_TeleportToPosition(const int client, const int location);

/**	JailFighter.ListLRS
 *	List the last request menu to the player.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_ListLRS(const int client);

/**	JailFighter.PreEquip
 *	Remove all weapons, disguises, and wearables from a client.
 *
 *	@param client 		Player index.
 *	@param weps 		True to remove all weapons, false otherwise.
 *
 *	@noreturn
*/
stock void RemoveAll(const int client, bool weps = true)
{
	TF2_RemovePlayerDisguise(client);
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearabl*")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
	if (weps)
		TF2_RemoveAllWeapons(client);
}

/**	JailFighter.TeleToSpawn
 *	Teleport a player to the appropriate spawn location.
 *
 *	@param client 		Player index.
 *	@param team 		Team spawn to teleport the client to.
 *
 *	@noreturn
*/
stock void TeleportToSpawn(const int client, int team = 0)	// Props to Chdata!
{
	int iEnt = -1;
	float vPos[3], vAng[3];
	ArrayList hArray = new ArrayList();
	while ((iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1)
	{
		if (team <= 1)
			hArray.Push(iEnt);
		else if (GetEntProp(iEnt, Prop_Send, "m_iTeamNum") == team)
			hArray.Push(iEnt);
	}
	iEnt = hArray.Get(GetRandomInt(0, hArray.Length - 1));
	delete hArray;
	
	// Technically you'll never find a map without a spawn point. not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(client, vPos, vAng, NULL_VECTOR);
}

/**	JailFighter.SpawnSmallHealthPack
 *	Spawn a small healthpack at the client's origin.
 *
 *	@param client 		Player index.
 *	@param ownerteam 	Team to give the healthpack.
 *
 *	@noreturn
*/
stock void SpawnSmallHealthPackAt(const int client, int ownerteam = 0)
{
	if (!IsPlayerAlive(client))
		return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	if (IsValidEntity(healthpack)) 
	{
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  // For safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
	}
}

/**	JailFighter.MutePlayer
 *	Mute a client through the plugin.
 *	@note 				Players that are deemed as admins will never be muted.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_MutePlayer(const int client);

/**	JailFighter.GiveFreeday
 *	Initialize a player as a freeday.
 *	@note 				Does not teleport them to the freeday location.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_GiveFreeday(const int client);

/**	JailFighter.RemoveFreeday
 *	Terminate a player as a freeday.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_RemoveFreeday(const int client);

/**	JailFighter.StripToMelee
 *	Remove all player weapons that are not their melee.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
stock void StripPlayerToMelee(const int client)
{
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	TF2_RemoveWeaponSlot(client, 5);

	char sClassName[64];
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
}
/**	JailFighter.EmptyWeaponSlots
 *	Strip a player of all of their ammo.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
stock void EmptyPlayerWeaponSlots(const int client)
{
	if (!IsPlayerAlive(client))
		return;

	int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
	int weapon;

	for (int i = 0; i < 2; i++)
	{
		offset += 4;

		weapon = GetEntDataEnt2(client, offset);

		if (!IsValidEntity(weapon))
			continue;

		int clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
		if (clip != -1)
			SetEntProp(weapon, Prop_Send, "m_iClip1", 0);

		clip = GetEntProp(weapon, Prop_Send, "m_iClip2");
		if (clip != -1)
			SetEntProp(weapon, Prop_Send, "m_iClip2", 0);
			
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, 0, 4, true);
	}

	char sClassName[64];
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
}

/**	JailFighter.UnmutePlayer
 *	Unmute a player through the plugin.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_UnmutePlayer(const int client);

/**	JailFighter.WardenSet
 *	Initialize a player as the warden.
 *	@note 				This automatically gives the player the warden menu
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenSet(const int client);

/**	JailFighter.WardenUnset
 *	Terminate a player as the warden.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenUnset(const int client);

/**	JailFighter.MakeHorsemann
 *	Convert a player into the Horseless Headless Horsemann.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_MakeHorsemann(const int client);

/**	JailFighter.UnHorsemann
 *	Terminate a player as the Horseless Headless Horsemann.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_UnHorsemann(const int client);

/**	JailFighter.WardenMenu
 *	Give a player the warden menu.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenMenu(const int client);

/**	JailFighter.ClimbWall
 *	Allow a player to climb walls upon hitting them.
 *
 *	@param client 		Player index.
 *	@param weapon 		Weapon the client is using to attack.
 *	@param upwardvel	Velocity to send the client (in hammer units).
 *	@param health 		Health to take from the client.
 *	@param attackdelay 	Length in seconds to delay the player in attacking again.
 *
 *	@noreturn
*/
native void JB_ClimbWall(const int client, const int weapon, const float upwardvel, const float health, const bool attackdelay);

/**	JailFighter.bNoMusic
 *	Get's player's Music Cookie.
 *
 *	@param client 		Player index.
 *
 *	@return 			True if music is toggled off. False otherwise.
*/
native bool JB_NoMusic(const int client);

/**	JailFighter.hMap
 *	Retrieve this player's StringMap address.
 *	@note 				This can be used alongside StringMap methods to get/set to and create keys in the core StringMap!
 *
 *	@param client 		Player index.
 *
 *	@return 			Pointer to this players StringMap.
*/
native StringMap JB_Map(const int client);


methodmap JBPlayer
{
	/** [ C O N S T R U C T O R S ] **/

	public JBPlayer( const int index )
	{
		return view_as< JBPlayer >(index);
	}

	public static JBPlayer OfUserId( const int userid )
	{
		return view_as< JBPlayer >(GetClientOfUserId(userid));
	}

	public static JBPlayer Of( const any thing )
	{
		return view_as< JBPlayer >(thing);
	}

	/* **** **** [ P R O P E R T I E S ] **** **** */

	property int userid 
	{
		public get() 				{ return GetClientUserId(view_as< int >(this)); }
	}

	property int index 
	{
		public get() 				{ return view_as< int >(this); }
	}

	property StringMap hMap
	{
		public get()				{ return JB_Map(this.index); }
	}

	/**
	 *	Get's player's Music Cookie.
	 *
	 *	@return 			True if music is toggled off. False otherwise.
	*/
	property bool bNoMusic
	{
		public get()
		{
			return JB_NoMusic(this.index);
		}
	}

	/**
	 *	Gets the property of the internal JailFighter methodmap.
	 *	@note 				If you are getting a float value, you MUST view_as<float>
	 *
	 *	@param key			Name of property you want to access data from.
	 *	@param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 *	@return				Property value called if it was valid
	*/
	public any GetValue( const char key[64] )
	{
		return JB_GetValue(this.index, key);
	}

	/**
	 *	Sets the property of the internal JB methodmap.
	 *	@note 				You can use this to create new properties which GetValue can access!
	 *
	 *	@param key			Name of the property you want to override data from (works like StringMap).
	 *	@param value		Data you want the property to hold.
	 *
	 *	@noreturn
	*/
	public void SetValue( const char key[64], any value )
	{
		JB_SetValue(this.index, key, value);
	}

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

	property float flSpeed
	{
		public get() 				{ return this.GetValue("flSpeed"); }
		public set( const float i )	{ this.SetValue("flSpeed", i); }
	}
	property float flKillSpree
	{
		public get() 				{ return this.GetValue("flKillSpree"); }
		public set( const float i )	{ this.SetValue("flKillSpree", i); }
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
	public int SpawnWeapon( char[] name, const int index, const int level, const int qual, char[] att )
	{
		return TF2_SpawnWeapon(this.index, name, index, level, qual, att);
	}

	/**
	 *	Retrieve an item definition index of a player's weaponslot.
	 *
	 *	@param slot 		Slot to grab the item index from.
	 *
	 *	@return 			Index of the valid, equipped weapon.
	*/
	public int GetWeaponSlotIndex( const int slot )
	{
		return GetIndexOfWeaponSlot(this.index, slot);
	}

	/**
	 *	Set the alpha magnitude a player's weapons.
	 *
	 *	@param alpha 		Number from 0 to 255 to set on the weapon.
	 *
	 *	@noreturn
	*/
	public void SetWepInvis( const int alpha )
	{
		SetWeaponInvis(this.index, alpha);
	}

	/**
	 *	Silently switch a player's team.
	 *
	 *	@param team 		Team to switch to.
	 *	@param spawn 		Determine whether or not to respawn the client.
	 *
	 *	@noreturn
	*/
	public void ForceTeamChange( const int team, bool spawn = true )
	{
		ForceClientTeamChange(this.index, team, spawn);
	}

	/**
	 *	Teleport a player either to a freeday or warday location.
	 *	@note 				If gamemode teleport properties are not true, teleportation will fail
	 *
	 *	@param location 	Location to teleport the client.
	 *
	 *	@noreturn
	*/
	public void TeleportToPosition( const int location )
	{
		JB_TeleportToPosition(this.index, location);
	}

	/**
	 *	List the last request menu to the player.
	 *
	 *	@noreturn
	*/
	public void ListLRS()
	{
		JB_ListLRS(this.index);
	}

	/**
	 *	Remove all weapons, disguises, and wearables from a client.
	 *
	 *	@noreturn
	*/
	public void PreEquip( bool weps = true )
	{
		RemoveAll(this.index, weps);
	}

	/**
	 *	Teleport a player to the appropriate spawn location.
	 *
	 *	@param team 		Team spawn to teleport the client to.
	 *
	 *	@noreturn
	*/
	public void TeleToSpawn( int team = 0 )
	{
		TeleportToSpawn(this.index, team);
	}

	/**
	 *	Spawn a small healthpack at the client's origin.
	 *
	 *	@param ownerteam 	Team to give the healthpack.
	 *
	 *	@noreturn
	*/
	public void SpawnSmallHealthPack( int ownerteam = 0 )
	{
		SpawnSmallHealthPackAt(this.index, ownerteam);
	}

	/**
	 *	Mute a client through the plugin.
	 *	@note 				Players that are deemed as admins will never be muted.
	 *
	 *	@noreturn
	*/
	public void MutePlayer()
	{
		JB_MutePlayer(this.index);
	}

	/**
	 *	Initialize a player as a freeday.
	 *	@note 				Does not teleport them to the freeday location.
	 *
	 *	@noreturn
	*/
	public void GiveFreeday()
	{
		JB_GiveFreeday(this.index);
	}

	/**
	 *	Terminate a player as a freeday.
	 *
	 *	@noreturn
	*/
	public void RemoveFreeday()
	{
		JB_RemoveFreeday(this.index);
	}

	/**
	 *	Remove all player weapons that are not their melee.
	 *
	 *	@noreturn
	*/
	public void StripToMelee()
	{
		StripPlayerToMelee(this.index);
	}

	/**
	 *	Strip a player of all of their ammo.
	 *
	 *	@noreturn
	*/
	public void EmptyWeaponSlots()
	{
		EmptyPlayerWeaponSlots(this.index);
	}

	/**
	 *	Unmute a player through the plugin.
	 *
	 *	@noreturn
	*/
	public void UnmutePlayer()
	{
		JB_UnmutePlayer(this.index);
	}

	/**
	 *	Initialize a player as the warden.
	 *	@note 				This automatically gives the player the warden menu
	 *
	 *	@noreturn
	*/
	public void WardenSet()
	{
		JB_WardenSet(this.index);
	}

	/**
	 *	Terminate a player as the warden.
	 *
	 *	@noreturn
	*/
	public void WardenUnset()
	{
		JB_WardenUnset(this.index);
	}

	/**
	 *	Convert a player into the Horseless Headless Horsemann.
	 *
	 *	@noreturn
	*/
	public void MakeHorsemann()
	{
		JB_MakeHorsemann(this.index);
	}

	/**
	 *	Terminate a player as the Horseless Headless Horsemann.
	 *
	 *	@noreturn
	*/
	public void UnHorsemann()
	{
		JB_UnHorsemann(this.index);
	}

	/**
	 *	Give a player the warden menu.
	 *
	 *	@noreturn
	*/
	public void WardenMenu()
	{
		JB_WardenMenu(this.index);
	}

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
	public void ClimbWall( const int weapon, const float upwardvel, const float health, const bool attackdelay )
	{
		JB_ClimbWall(this.index, weapon, upwardvel, health, attackdelay);
	}
};


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
 * 	int iMuteType
 *	int iLivingMuteType
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


/**
 *	Set an array into this the GameMode StringMap
 *
 *	@param key			Key string.
 *	@param array		Array to store.
 *	@param num_items	Number of items in the array.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool JBGameMode_SetArray(const char[] key, const any[] array, int num_items, bool replace = true);

/**
 *	Sets a string value in the GameMode StringMap, either inserting a new entry or replacing an old one.
 *
 *	@param key			Key string.
 *	@param string		String to store.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool JBGameMode_SetString(const char[] key, const char[] string, bool replace = true);

/**
 *	Retrieves an array in the GameMode StringMap.
 *
 *	@param key			Key string.
 *	@param array		Buffer to store array.
 *	@param max_size		Maximum size of array buffer.
 *	@param size			Optional parameter to store the number of elements written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or string (not an array).
*/
native bool JBGameMode_GetArray(const char[] key, any[] array, int max_size, int &size = 0);

/**
 *	Retrieves a string in the GameMode StringMap.
 *
 *	@param key			Key string.
 *	@param string		Buffer to store value.
 *	@param max_size		Maximum size of string buffer.
 *	@param size			Optional parameter to store the number of bytes written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or array (not a string).
*/
native bool JBGameMode_GetString(const char[] key, char[] string, int max_size, int &size = 0);

/**
 *	Removes a key entry from the GameMode StringMap.
 *
 *	@param key			Key string.
 *
 *	@return				True on success, false if the value was never set.
*/
native bool JBGameMode_Remove(const char[] key);

/**
 *	Clears all entries from the GameMode StringMap.
 *
 *	@noreturn
*/
native void JBGameMode_Clear();

/**
 *	Create a snapshot of the GameMode StringMap's keys. See StringMapSnapshot.
 *
 *	@return 			Handle to key Snapshot.
*/
native StringMapSnapshot JBGameMode_Snapshot();

/**
 *	Retrieves the number of elements in the GameMode StringMap.
 *
 *	@return 			Element count.
*/
native int JBGameMode_Size();

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
};


/**
 *	Registers a sub-plugin to be added to the last request handle.
 *	@note 					The purpose of this native is to register last-request subplugins, 
 * 							you don't need to register plugins to use forwards, 
 *							simply hook what forward you need.
 *							You MUST register a Last Request sub-plugin in order for it to work.
 *
 *	@return					True on success, false if plugin was already registered.
 */
native bool TF2JailRedux_RegisterPlugin();

/**
 *	Un-registers a plugin from the last request handle.
 *	@note 					This is optional, however doing this will prevent breakage when unloading
 *							or reloading sub-plugins mid-game.
 *							Obviously, you must use the name plugin_name as you did when you registered
 *							the plugin originally.
 *							This is best suited to be used OnPluginEnd() but it's return can be used to
 *							your advantage (see @return).
 *
 *	@return 				Returns true if the plugin is unregistered. Just because a plugin is unregistered
 *							does not mean that it is unloaded. Therefore you can use a global bool to 
 * 							determine if you should continue with your forward-hooked code. See the VSH 
 * 							or PH sub-plugin for usage.
*/
native bool TF2JailRedux_UnRegisterPlugin();

/**
 *	Retrieve the calling plugin's LR index
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
	OnPlayerPreppedPost,
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
		OnPlayerPreppedPost
		OnClientInduction
		OnVariableReset
		OnFreedayGiven
		OnFreedayRemoved
	*/
	function void (const JBPlayer Player);
	
	/*
		OnPlayerSpawned
		OnRoundEndPlayer
	*/
	function void (const JBPlayer Player, Event event);

	/*
		OnClientTouch
		OnPlayerJarated
		OnUberDeployed		Medic is Player, Patient is Victim
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
		OnRoundStart
		OnCheckLivingPlayers
	*/
	function void ();

	//	OnMenuAdd
	function void (const int index, int &max, char strName[32]);

	//	OnPanelAdd
	function void (const int index, char name[64]);

	//	OnRoundEnd
	function void (Event event);

	//	OnWMenuAdd
	function void (Menu &menu);	

	// 	OnHudShow
	function void (char strHud[128]);

	// 	OnLRPicked			Return anything but Continue to prevent setting the next iLRPresetType to index
	function Action (const JBPlayer Player, const int index, ArrayList array);

	// 	OnHurtPlayer
	function void (const JBPlayer Victim, const JBPlayer Attacker, Event event);

	// 	OnTakeDamage
	function Action (const JBPlayer Victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnWMenuSelect
	function Action (const JBPlayer Player, const char[] index);

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
	function Action (const JBPlayer Victim, const JBPlayer Attacker, Event event);

	//	OnPreThink
	function void (const JBPlayer Player, int buttons);

	//	OnFFTimer
	function void (float &time);

	//	OnTimeLeft
	function void (int &time);

	/*
		OnWardenGet			Return anything but Continue to prevent player from becoming warden
		OnPlayerPrepped		Return anything but Continue to not fire
	*/
	function Action (const JBPlayer Player);
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
	MarkNativeAsOptional("TF2JailRedux_UnRegisterPlugin");
	MarkNativeAsOptional("TF2JailRedux_LRIndex");

	MarkNativeAsOptional("JB_Hook");
	MarkNativeAsOptional("JB_HookEx");
	MarkNativeAsOptional("JB_Unhook");
	MarkNativeAsOptional("JB_UnhookEx");

	MarkNativeAsOptional("JB_GetValue");
	MarkNativeAsOptional("JB_SetValue");
	MarkNativeAsOptional("JB_Map");

	MarkNativeAsOptional("JB_TeleportToPosition");
	MarkNativeAsOptional("JB_ListLRS");
	MarkNativeAsOptional("JB_MutePlayer");
	MarkNativeAsOptional("JB_GiveFreeday");
	MarkNativeAsOptional("JB_RemoveFreeday");
	MarkNativeAsOptional("JB_UnmutePlayer");
	MarkNativeAsOptional("JB_WardenSet");
	MarkNativeAsOptional("JB_WardenUnset");
	MarkNativeAsOptional("JB_MakeHorsemann");
	MarkNativeAsOptional("JB_UnHorsemann");
	MarkNativeAsOptional("JB_WardenMenu");
	MarkNativeAsOptional("JB_ClimbWall");
	MarkNativeAsOptional("JB_NoMusic");

	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_Warden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
	MarkNativeAsOptional("JBGameMode_OpenAllDoors");
	MarkNativeAsOptional("JBGameMode_ToggleMedic");
	// MarkNativeAsOptional("JBGameMode_ToggleMedicTeam");

	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");
	MarkNativeAsOptional("JBGameMode_SetArray");
	MarkNativeAsOptional("JBGameMode_SetString");
	MarkNativeAsOptional("JBGameMode_GetArray");
	MarkNativeAsOptional("JBGameMode_GetString");
	MarkNativeAsOptional("JBGameMode_Remove");
	MarkNativeAsOptional("JBGameMode_Clear");
	MarkNativeAsOptional("JBGameMode_Snapshot");
	MarkNativeAsOptional("JBGameMode_Size");

	MarkNativeAsOptional("JBGameMode.JBGameMode");
}
#endif