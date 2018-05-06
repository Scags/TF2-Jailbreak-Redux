#if defined _tf2jailredux_included
  #endinput
#endif
#define _tf2jailredux_included

#include <tf2_stocks>
#include <tf2items>

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

stock char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };


/**	base.GetValue
 *	Gets the property of the internal JailFighter methodmap.
 *
 *	@param client 		Player index.
 *	@param key			Name of property you want to access data from.
 *	@param item			Reference to use of the variable to overwrite with data from the property.
 *
 *	@return				Property value called if it was valid
*/
native any JB_GetValue(const int client, const char key[64]);

/**	base.GetValue
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
 *	bool bNoMusic							// LR music option (cookie)
 *	bool bUnableToTeleport 					// Client can/can't teleport with Eureka Effect
 *	float flSpeed 							// Client speed, isn't used
 *	float flKillSpree 						// Also for the ghetto rigged freekill system
*/

/**	base.SetArray
 *	Set an array into this player's StringMap
 *
 *	@param client 		Player index.
 *	@param key			Key string.
 *	@param array		Array to store.
 *	@param num_items	Number of items in the array.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool JB_SetArray(const int client, const char[] key, const any[] array, int num_items, bool replace = true);

/**	base.SetString
 *	Sets a string value in this player's StringMap, either inserting a new entry or replacing an old one.
 *
 *	@param client 		Player index.
 *	@param key			Key string.
 *	@param string		String to store.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool JB_SetString(const int client, const char[] key, const char[] string, bool replace = true);

/**	base.GetArray
 *	Retrieves an array in this player's StringMap.
 *
 *	@param client 		Player index.
 *	@param key			Key string.
 *	@param array		Buffer to store array.
 *	@param max_size		Maximum size of array buffer.
 *	@param size			Optional parameter to store the number of elements written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or string (not an array).
*/
native bool JB_GetArray(const int client, const char[] key, any[] array, int max_size, int &size = 0);

/**	base.GetString
 *	Retrieves a string in this player's StringMap.
 *
 *	@param client 		Player index.
 *	@param key			Key string.
 *	@param string		Buffer to store value.
 *	@param max_size		Maximum size of string buffer.
 *	@param size			Optional parameter to store the number of bytes written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or array (not a string).
*/
native bool JB_GetString(const int client, const char[] key, char[] string, int max_size, int &size = 0);

/**	base.Remove
 *	Removes a key entry from this player's StringMap.
 *
 *	@param client 		Player index.
 *	@param key			Key string.
 *
 *	@return				True on success, false if the value was never set.
*/
native bool JB_Remove(const int client, const char[] key);

/**	base.Clear
 *	Clears all entries from this player's StringMap.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_Clear(const int client);

/**	base.Snapshot
 *	Create a snapshot of this player's StringMap's keys. See StringMapSnapshot.
 *
 *	@param client 		Player index.
 *
 *	@return 			Handle to key SnapShot.
*/
native StringMapSnapshot JB_Snapshot(const int client);

/**	base.Size
 *	Retrieves the number of elements in this player's StringMap.
 *
 *	@param client 		Player index.
 *
 *	@return 			Player's StringMap size.
*/
native int JB_Size(const int client);

/**	base.SpawnWeapon
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
/**	base.GetWeaponSlotIndex
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

/**	base.SetWepInvis
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
	return;
}

/**	base.ForceTeamChange
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

/**	base.TeleportToPosition
 *	Teleport a player either to a freeday or warday location.
 *	@note 				If gamemode teleport properties are not true, teleportation will fail
 *
 *	@param client 		Player index.
 *	@param location 	Location to teleport the client.
 *
 *	@noreturn
*/
native void JB_TeleportToPosition(const int client, const int location);

/**	base.ListLRS
 *	List the last request menu to the player.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_ListLRS(const int client);

/**	base.PreEquip
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
	while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
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
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable_razorback")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable_campaign_item")) != -1)
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


/**	base.TeleToSpawn
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
		else
		{
			int iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == team)
				hArray.Push(iEnt);
		}
	}
	iEnt = hArray.Get(GetRandomInt(0, hArray.Length - 1));
	hArray.Close();

	// Technically you'll never find a map without a spawn point. not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(client, vPos, vAng, NULL_VECTOR);
}
/**	base.SpawnSmallHealthPack
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
	return;
}
/**	base.MutePlayer
 *	Mute a client through the plugin.
 *	@note 				Players that are deemed as admins will never be muted.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_MutePlayer(const int client);

/**	base.GiveFreeday
 *	Initialize a player as a freeday.
 *	@note 				Does not teleport them to the freeday location.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_GiveFreeday(const int client);

/**	base.RemoveFreeday
 *	Terminate a player as a freeday.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_RemoveFreeday(const int client);

/**	base.StripToMelee
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
/**	base.EmptyWeaponSlots
 *	Strip a player of all of their ammo.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
stock void EmptyPlayerWeaponSlots(const int client)
{
	if (!IsPlayerAlive(client) || TF2_GetClientTeam(client) != TFTeam_Red)
		return;

	int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
	int weapon;

	for (int i = 0; i < 2; i++)
	{
		offset += 4;

		weapon = GetEntDataEnt2(client, offset);

		if (!IsValidEntity(weapon) || i == TFWeaponSlot_Melee)
			continue;

		int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
		if (clip != -1)
			SetEntProp(weapon, Prop_Data, "m_iClip1", 0);

		clip = GetEntProp(weapon, Prop_Data, "m_iClip2");
		if (clip != -1)
			SetEntProp(weapon, Prop_Data, "m_iClip2", 0);
			
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, 0, 4, true);
	}

	char sClassName[64];
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
	
	//CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Your weapons and ammo have been stripped.");
}

/**	base.UnmutePlayer
 *	Unmute a player through the plugin.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_UnmutePlayer(const int client);

/**	base.WardenSet
 *	Initialize a player as the warden.
 *	@note 				This automatically gives the player the warden menu
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenSet(const int client);

/**	base.WardenUnset
 *	Terminate a player as the warden.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenUnset(const int client);

/**	base.MakeHorsemann
 *	Convert a player into the Horseless Headless Horsemann.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_MakeHorsemann(const int client);

/**	base.UnHorsemann
 *	Terminate a player as the Horseless Headless Horsemann.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_UnHorsemann(const int client);

/**	base.WardenMenu
 *	Give a player the warden menu.
 *
 *	@param client 		Player index.
 *
 *	@noreturn
*/
native void JB_WardenMenu(const int client);

/**	base.ClimbWall
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

/**	base.bNoMusic
 *	Get's player's Music Cookie.
 *
 *	@param client 		Player index.
 *
 *	@return 			True if music is toggled off. False otherwise.
*/
native bool JB_NoMusic(const int client);

/**	base.hMap
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
	/** [ C O N S T R U C T O R S ]
	 *	Constructs an instance of the JailFighter internal methodmap.
	 *
	 *	@param index		Index of a player.
	 *
	 *	@return				A player instance of the JBPlayer methodmap.
	*/
	public native JBPlayer( const int index );

	/**
	 *	Constructs an instance of the JailFighter internal methodmap directly from a client's userid.
	 *	@note 				Syntax is like so: JBPlayer.OfUserid(userid)
	 *
	 *	@param userid 		UserId of the client.
	 *
	 *	@return 			A player instance of the JBPlayer methodmap.
	*/
	public static native JBPlayer OfUserId( const int userid );

	/* **** **** [ P R O P E R T I E S ] **** **** */

	/**
	 *	Gets the userid of the JB player instance.
	 *
	 *	@return				The bare player userid integer.
	*/
	property int userid 
	{
		public native get();
	}

	/**
	 *	Gets the index of the JB player instance.
	 *
	 *	@return				The bare player index integer.
	*/
	property int index 
	{
		public native get();
	}

	property StringMap hMap
	{
		public get()
		{
			return JB_Map(this.index);
		}
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
	 *
	 *	@param key		Name of property you want to access data from.
	 *	@param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 *	@return				Property value called if it was valid
	*/
	public any GetValue(const char key[64])
	{
		return JB_GetValue(this.index, key);
	}

	/**
	 *	Sets the property of the internal JB methodmap.
	 *	NOTE: You can use this to create new properties which GetValue can access!
	 *
	 *	@param key		Name of the property you want to override data from (works like StringMap).
	 *	@param value			Data you want the property to hold.
	 *
	 *	@noreturn
	*/
	public void SetValue(const char key[64], any value)
	{
		JB_SetValue(this.index, key, value);
	}

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
	 *	bool bNoMusic							// LR music option (cookie)
	 *	bool bUnableToTeleport 					// Client can/can't teleport with Eureka Effect
	 *	float flSpeed 							// Client speed, isn't used
	 *	float flKillSpree 						// Also for the ghetto rigged freekill system
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
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att)
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
	public int GetWeaponSlotIndex(const int slot)
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
	public void SetWepInvis(const int alpha)
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
	public void ForceTeamChange(const int team, bool spawn = true)
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
	public void TeleportToPosition(const int location)
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
	public void PreEquip(bool weps = true)
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
	public void TeleToSpawn(int team = 0)
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
	public void SpawnSmallHealthPack(int ownerteam = 0)
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
	public void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay)
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
native int JBGameMode_Warden();

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
 *	@return 			Handle to key SnapShot.
*/
native StringMapSnapshot JBGameMode_Snapshot();

/**
 *	Retrieves the number of elements in the GameMode StringMap.
*/
native int JBGameMode_Size();


methodmap JBGameMode
{
	/**
	 *	Initialize global methodmap with a handle to the core JailGameMode methodmap.
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
	public void DoorHandler(const eDoorsMode status)
	{
		JBGameMode_ManageCells(status);
	}

	 /**
	 *	Find the current warden if one exists.
	 *
	 *	@return 				The current warden.
	*/
	property int Warden
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
	public void FireWarden(bool prevent = true, bool announce = true)
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
	public void ToggleMedic(const bool status)
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
	 *	Get a property value from the JailGameMode internal methodmap (works like StringMap).
	 *
	 *	@param prop_name 		Property key to call from.
	 *
	 *	@return 				Value received from called key.
	*/
	public any GetProperty(const char prop_name[64])
	{
		return JBGameMode_GetProperty(prop_name);
	}

	/**
	 *	Set a property to the JailGameMode internal methodmap.
	 *	@note 					This can set properties that GetProperty can access!
	 *
	 *	@param prop_name 		Property key to set into the StringMap.
	 *	@param value 			Value to set to it.
	 *
	 *	@noreturn
	*/
	public void SetProperty(const char prop_name[64], any value)
	{
		JBGameMode_SetProperty(prop_name, value);
	}

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
	public bool SetArray(const char[] key, const any[] array, int num_items, bool replace = true)
	{
		return JBGameMode_SetArray(key, array, num_items, replace);
	}

	/**
	 *	Sets a string value in the GameMode StringMap, either inserting a new entry or replacing an old one.
	 *
	 *	@param key			Key string.
	 *	@param string		String to store.
	 *	@param replace		If false, operation will fail if the key is already set.
	 *
	 *	@return				True on success, false on failure.
	*/
	public bool SetString(const char[] key, const char[] string, bool replace = true)
	{
		return JBGameMode_SetString(key, string, replace);
	}

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
	public bool GetArray(const char[] key, any[] array, int max_size, int &size = 0)
	{
		return JBGameMode_GetArray(key, array, max_size, size);
	}

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
	public bool GetString(const char[] key, char[] string, int max_size, int &size = 0)
	{
		return JBGameMode_GetString(key, string, max_size, size);
	}

	/**
	 *	Removes a key entry from the GameMode StringMap.
	 *
	 *	@param key			Key string.
	 *
	 *	@return				True on success, false if the value was never set.
	*/
	public bool Remove(const char[] key)
	{
		return JBGameMode_Remove(key);
	}

	/**
	 *	Clears all entries from the GameMode StringMap.
	 *
	 *	@noreturn
	*/
	public void Clear()
	{
		JBGameMode_Clear();
	}

	/**
	 *	Create a snapshot of the GameMode StringMap's keys. See StringMapSnapshot.
	 *
	 *	@return 			Handle to key SnapShot.
	*/
	public StringMapSnapshot Snapshot()
	{
		return JBGameMode_Snapshot();
	}

	/**
	 *	Retrieves the number of elements in the GameMode StringMap.
	*/
	property int Size
	{
		public get()
		{
			return JBGameMode_Size();
		}
	}
};


/**
 *	Registers a plugin to be able to use TF2Jail's forwards
 *	@note 					The purpose of this native is to register last-request subplugins, you don't need to register plugins to use forwards, 
 *							simply hook what forward you need.
 *							If you add a last request and want to test it before you allow all players to use it, do NOT register the sub-plugin, 
 *							and use sm_setpreset to activate the lr type for next round.
 *	
 *	@param plugin_name		Module name you want your calling plugin to be identified under.
 *
 *	@return					Integer of the plugin array index.
 */
native int TF2JailRedux_RegisterPlugin(const char plugin_name[64]);


enum	// JB Hook Types
{
	OnDownloads = 0,
	OnManageRoundStart,
	OnManageRoundStartPlayer,
	OnManageRoundEnd,
	OnManageRoundEndPlayer,
	OnWardenGet,
	OnClientTouch,
	OnRedThink,
	OnBlueThink,
	// OnBlueNotWardenThink,
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
	OnWardenKilled,
	OnFreedayGiven,
	OnFreedayRemoved,
	OnPreThink,
	OnManageFFTimer,
	OnLRInitialized,
	OnDoorsOpen,
	OnDoorsClose,
	OnDoorsLock,
	OnDoorsUnlock,
	OnPlayMusic
};

/* SDKHook-Style Forwards */
typeset JBHookCB
{
	/*
		OnManageRoundStartPlayer
		OnWardenGet
		OnRedThink
		OnBlueThink
		OnWardenThink
		OnPlayerPrepped
		OnClientInduction
		OnVariableReset
		OnFreedayGiven
		OnFreedayRemoved
	*/
	function void (const JBPlayer Player);
	
	/*
		OnPlayerSpawned
		OnManageRoundEndPlayer
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
		OnManageRoundStart
		OnCheckLivingPlayers
	*/
	function void ();

	//	OnMenuAdd
	function void (const int index, int &max, char strName[32]);

	//	OnPanelAdd
	function void (const int index, char name[64]);

	//	OnManageRoundEnd
	function void (Event event);

	//	OnWMenuAdd
	function void (Menu &menu);	

	// 	OnLRTextHud
	function void (char strHud[128]);

	// 	OnLRPicked			Return anything but Continue to prevent setting the next iLRPresetType to index
	function Action (const JBPlayer Player, const int index, ArrayList array);

	// 	OnHurtPlayer
	function void (const JBPlayer Victim, const JBPlayer Attacker, Event event);

	// 	OnHookDamage
	function Action (const JBPlayer Victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnWMenuSelect
	function void (const JBPlayer Player, const char[] index);

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

	//	OnManageFFTimer
	function void (float &time);

	//	OnManageTimeLeft
	function void (int &time);
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

	MarkNativeAsOptional("JB_Hook");
	MarkNativeAsOptional("JB_HookEx");
	MarkNativeAsOptional("JB_Unhook");
	MarkNativeAsOptional("JB_UnhookEx");

	MarkNativeAsOptional("JBPlayer.JBPlayer");
	MarkNativeAsOptional("JBPlayer.OfUserId");
	MarkNativeAsOptional("JBPlayer.userid.get");
	MarkNativeAsOptional("JBPlayer.index.get");

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