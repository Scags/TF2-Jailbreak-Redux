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

stock char snd[PLATFORM_MAX_PATH];
#define MAXMESSAGE	4096
stock char gameMessage[MAXMESSAGE];	// For formatting chat/hint/center/etc messages
stock char BackgroundSong[PLATFORM_MAX_PATH];	// If you want a sweet song with your lr, try this out
stock char sDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };

methodmap JBPlayer
{
	/** [ C O N S T R U C T O R ]
	 *	Constructs an instance of the JailFighter internal methodmap.
	 *	 
	 *	@param index			Index (or the userid) of a player.
	 *	@param userid		If using userid instead of player index, set this param to true.
	 *
	 *	@return				A player instance of the JBPlayer methodmap.
	*/
	public native JBPlayer(const int index, bool userid = false);

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
	
	/**
	 *	Gets the property of the internal JailFighter methodmap.
	 *
	 *	@param key		Name of property you want to access data from.
	 *	@param item			Reference to use of the variable to overwrite with data from the property.
	 *
	 *	@return				Property value called if it was valid
	*/
	public native any GetValue(const char key[64]);
	
	/**
	 *	Sets the property of the internal JB methodmap.
	 *	NOTE: You can use this to create new properties which GetValue can access!
	 *
	 *	@param key		Name of the property you want to override data from (works like StringMap).
	 *	@param value			Data you want the property to hold.
	 *
	 *	@noreturn
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
	 *	@NOTE 				Players that are deemed as admins will never be muted.
	 *
	 *	@noreturn
	*/
	public native void MutePlayer();

	/**
	 *	Initialize a player as a freeday.
	 *	@NOTE 				Does not teleport them to the freeday location.
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
	public native void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay);
};

/**	base.GetValue
 *	Gets the property of the internal JailFighter methodmap.
 *
 *	@param client 		Player.
 *	@param key			Name of property you want to access data from.
 *	@param item			Reference to use of the variable to overwrite with data from the property.
 *
 *	@return				Property value called if it was valid
*/
native any GetPlayerMapValue(const int client, const char key[64]);

/**	base.GetValue
 *	Sets the property of the internal JB methodmap.
 *	@NOTE 				You can use this to create new properties which GetValue can access!
 *
 *	@param client 		Player.
 *	@param key			Name of the property you want to override data from (works like StringMap).
 *	@param value		Data you want the property to hold.
 *
 *	@noreturn
*/
native void SetPlayerMapValue(const int client, const char key[64], any value);

/**		AVAILABLE PROPERTIES
 *	property int iLRCustom							// For the Custom LR
 *	property int iKillCount							// For the ghetto rigged freekill system
 *	property bool bIsMuted							// Varies with CVars
 *	property bool bIsQueuedFreeday					// Freeday for Self or Freeday for Others
 *	property bool bIsFreeday 						// Client is/isn't a freeday
 *	property bool bLockedFromWarden					// Upon being fired or retiring
 *	property bool bIsVIP							// Default Reserve flag
 *	property bool bIsAdmin							// Default Generic flag
 *	property bool bIsHHH							// For the HHHDay LR
 *	property bool bInJump							// Client is rocket/sticky jumping
 *	property bool bNoMusic							// LR music option (cookie)
 *	property bool bUnableToTeleport 				// Client can/can't teleport with Eureka Effect
 *	property float flSpeed 							// Client speed, isn't used
 *	property float flKillSpree 						// Also for the ghetto rigged freekill system
*/

/**	base.SetArray
 *	Set an array into this player's StringMap
 *
 *	@param client 		Player.
 *	@param key			Key string.
 *	@param array		Array to store.
 *	@param num_items	Number of items in the array.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool SetPlayerMapArray(const int client, const char[] key, const any[] array, int num_items, bool replace = true);

/**	base.SetString
 *	Sets a string value in this player's StringMap, either inserting a new entry or replacing an old one.
 *
 *	@param client 		Player.
 *	@param key			Key string.
 *	@param string		String to store.
 *	@param replace		If false, operation will fail if the key is already set.
 *
 *	@return				True on success, false on failure.
*/
native bool SetPlayerMapString(const int client, const char[] key, const char[] string, bool replace = true);

/**	base.GetArray
 *	Retrieves an array in this player's StringMap.
 *
 *	@param client 		Player.
 *	@param key			Key string.
 *	@param array		Buffer to store array.
 *	@param max_size		Maximum size of array buffer.
 *	@param size			Optional parameter to store the number of elements written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or string (not an array).
*/
native bool GetPlayerMapArray(const int client, const char[] key, any[] array, int max_size, int &size = 0);

/**	base.GetString
 *	Retrieves a string in this player's StringMap.
 *
 *	@param client 		Player.
 *	@param key			Key string.
 *	@param string		Buffer to store value.
 *	@param max_size		Maximum size of string buffer.
 *	@param size			Optional parameter to store the number of bytes written to the buffer.
 *
 *	@return				True on success.  False if the key is not set, or the key is set 
 *						as a value or array (not a string).
*/
native bool GetPlayerMapString(const int client, const char[] key, char[] string, int max_size, int &size = 0);

/**	base.Remove
 *	Removes a key entry from this player's StringMap.
 *
 *	@param client 		Player.
 *	@param key			Key string.
 *
 *	@return				True on success, false if the value was never set.
*/
native bool RemovePlayerKey(const int client, const char[] key);

/**	base.Clear
 *	Clears all entries from this player's StringMap.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void ClearPlayerMap(const int client);

/**	base.Snapshot
 *	Create a snapshot of this player's StringMap's keys. See StringMapSnapshot.
 *
 *	@param client 		Player.
 *
 *	@return 			Handle to key SnapShot.
*/
native StringMapSnapshot SnapshotPlayerMapKeys(const int client);

/**	base.Size
 *	Retrieves the number of elements in this player's StringMap.
 *
 *	@param client 		Player.
 *
 *	@return 			Player's StringMap size.
*/
native int GetPlayerMapSize(const int client)

/**	base.SpawnWeapon
 *	Creates and spawns a weapon to a player.
 *
 *	@param client 		Player.
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
 *	@param client 		Player.
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
 *	@param client 		Player.
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
 *	@param client 		Player.
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
 *	@NOTE 				If gamemode teleport properties are not true, player will be teleported to map's origin
 *
 *	@param client 		Player.
 *	@param location 	Location to teleport the client.
 *
 *	@noreturn
*/
native void TeleportPlayerToPosition(const int client, const int location);

/**	base.ListLRS
 *	List the last request menu to the player.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void ListPlayerLRS(const int client);

/**	base.PreEquip
 *	Remove all weapons, disguises, and wearables from a client.
 *
 *	@param client 		Player.
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
 *	@param client 		Player.
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
 *	@param client 		Player.
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
 *	@NOTE 				Players that are deemed as admins will never be muted.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void JailMutePlayer(const int client);

/**	base.GiveFreeday
 *	Initialize a player as a freeday.
 *	@NOTE 				Does not teleport them to the freeday location.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void GivePlayerFreeday(const int client);

/**	base.RemoveFreeday
 *	Terminate a player as a freeday.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void RemovePlayerFreeday(const int client);

/**	base.StripToMelee
 *	Remove all player weapons that are not their melee.
 *
 *	@param client 		Player.
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
 *	@param client 		Player.
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
	
	//CPrintToChat(client, "{red}[TF2Jail]{tan} Your weapons and ammo have been stripped.");
}

/**	base.UnmutePlayer
 *	Unmute a player through the plugin.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void JailUnmutePlayer(const int client);

/**	base.WardenSet
 *	Initialize a player as the warden.
 *	@NOTE 				This automatically gives the player the warden menu
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void JailWardenSet(const int client);

/**	base.WardenUnset
 *	Terminate a player as the warden.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void JailWardenUnset(const int client);

/**	base.MakeHorsemann
 *	Convert a player into the Horseless Headless Horsemann.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void MakePlayerHorsemann(const int client);

/**	base.UnHorsemann
 *	Terminate a player as the Horseless Headless Horsemann.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void UnHorsemannPlayer(const int client);

/**	base.WardenMenu
 *	Give a player the warden menu.
 *
 *	@param client 		Player.
 *
 *	@noreturn
*/
native void WardenMenuPlayer(const int client);

/**	base.ClimbWall
 *	Allow a player to climb walls upon hitting them.
 *
 *	@param client 		Player.
 *	@param weapon 		Weapon the client is using to attack.
 *	@param upwardvel	Velocity to send the client (in hammer units).
 *	@param health 		Health to take from the client.
 *	@param attackdelay 	Length in seconds to delay the player in attacking again.
 *
 *	@noreturn
*/
native void PlayerClimbWall(const int client, const int weapon, const float upwardvel, const float health, const bool attackdelay);



methodmap JBGameMode //< StringMap
{
	/**
	 *	Initialize global methodmap with a handle to the core JailGameMode methodmap.
	 *	@NOTE 				This must be done OnAllPluginsLoaded() to assure that TF2Jail Redux loads first.
	 *
	 *	@return 			Instance of the JailGameMode methodmap.
	*/
	public native JBGameMode();

	/**
	 *	Retrieve the amount of living/playing players in the server.
	*/
	property int iPlaying
	{
		public native get();
	}

	/**
	 *	Find and Initialize a random player as the warden.
	 *
	 *	@noreturn
	*/
	public native void FindRandomWarden();

	/**
	 *	Handle the cell doors.
	 *
	 *	@param status 			Type of cell door usage found in the eDoorsMode enum.
	 *
	 *	@noreturn
	*/
	public native void DoorHandler(const eDoorsMode status);

	 /**
	 *	Find the current warden if one exists.
	 *
	 *	@return 				The current warden.
	 *
	*/
	public native JBPlayer FindWarden();

	/** 
	 *	Find and terminate the current warden.
	 *
	 *	@param prevent 			Prevent the player from becoming warden again.
	 * 	@param announce 		Display to all players that the warden was fired.
	 *
	 *	@noreturn
	*/
	public native void FireWarden(bool prevent = true, bool announce = true);

	/**
	 *	Open all doors in a map.
	 *
	 *	@noreturn
	*/
	public native void OpenAllDoors();

	/**
	 *	Get a property value from the JailGameMode internal methodmap (works like StringMap).
	 *
	 *	@param prop_name 		Property key to call from.
	 *
	 *	@return 				Value received from called key.
	*/
	public native any GetProperty(const char prop_name[64]);

	/**
	 *	Set a property to the JailGameMode internal methodmap.
	 *	@NOTE 					This can set properties that GetProperty can access!
	 *
	 *	@param prop_name 		Property key to set into the StringMap.
	 *	@param value 			Value to set to it.
	 *
	 *	@noreturn
	*/
	public native void SetProperty(const char prop_name[64], any value);

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
	 *	Set an array into this the GameMode StringMap
	 *
	 *	@param key			Key string.
	 *	@param array		Array to store.
	 *	@param num_items	Number of items in the array.
	 *	@param replace		If false, operation will fail if the key is already set.
	 *
	 *	@return				True on success, false on failure.
	*/
	public native bool JBGameMode_SetArray(const char[] key, const any[] array, int num_items, bool replace = true);

	/**
	 *	Sets a string value in the GameMode StringMap, either inserting a new entry or replacing an old one.
	 *
	 *	@param key			Key string.
	 *	@param string		String to store.
	 *	@param replace		If false, operation will fail if the key is already set.
	 *
	 *	@return				True on success, false on failure.
	*/
	public native bool JBGameMode_SetString(const char[] key, const char[] string, bool replace = true);

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
	public native bool JBGameMode_GetArray(const char[] key, any[] array, int max_size, int &size = 0);

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
	public native bool JBGameMode_GetString(const char[] key, char[] string, int max_size, int &size = 0);

	/**
	 *	Removes a key entry from the GameMode StringMap.
	 *
	 *	@param key			Key string.
	 *
	 *	@return				True on success, false if the value was never set.
	*/
	public native bool JBGameMode_Remove(const char[] key);

	/**
	 *	Clears all entries from the GameMode StringMap.
	 *
	 *	@noreturn
	*/
	public native void JBGameMode_Clear();

	/**
	 *	Create a snapshot of the GameMode StringMap's keys. See StringMapSnapshot.
	 *
	 *	@return 			Handle to key SnapShot.
	*/
	public native StringMapSnapshot JBGameMode_Snapshot();

	/**
	 *	Retrieves the number of elements in the GameMode StringMap.
	*/
	property int Size
	{
		public native get();
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

/**
 *	Open all doors in a map.
 *
 *	@noreturn
*/
native void JBGameMode_OpenAllDoors();

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
		OnBlueThink
		OnWardenThink
		OnPlayerPrepped
		OnClientInduction
		OnVariableReset
		OnFreedayGiven
		OnFreedayRemoved
	*/
	function void (const JBPlayer Player);
	
	//	OnPlayerSpawned
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
		OnTimeEnd			Return anything but Continue to override forcing Blue team to win
		OnLastGuard			Return Handled to stop "One Guard Left" message. Return Stop to not fire OnCheckLivingPlayers
		OnLastPrisoner		Return Stop to not fire OnCheckLivingPlayers
	*/
	function Action ();

	//	OnWardenKilled		Return anything but Continue to stop "Warden has been killed" message
	function Action (const JBPlayer Victim, const JBPlayer Attacker, Event event);
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
	MarkNativeAsOptional("JBPlayer.UnHorsemann");
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

	MarkNativeAsOptional("GetPlayerMapValue");
	MarkNativeAsOptional("SetPlayerMapValue");
	MarkNativeAsOptional("SetPlayerMapArray");
	MarkNativeAsOptional("SetPlayerMapString");
	MarkNativeAsOptional("GetPlayerMapArray");
	MarkNativeAsOptional("GetPlayerMapString");
	MarkNativeAsOptional("RemovePlayerKey");
	MarkNativeAsOptional("ClearPlayerMap");
	MarkNativeAsOptional("SnapshotPlayerMapKeys");
	MarkNativeAsOptional("GetPlayerMapSize");
	MarkNativeAsOptional("TeleportPlayerToPosition");
	MarkNativeAsOptional("ListPlayerLRS");
	MarkNativeAsOptional("JailMutePlayer");
	MarkNativeAsOptional("GivePlayerFreeday");
	MarkNativeAsOptional("RemovePlayerFreeday");
	MarkNativeAsOptional("JailUnmutePlayer");
	MarkNativeAsOptional("JailWardenSet");
	MarkNativeAsOptional("JailWardenUnset");
	MarkNativeAsOptional("MakePlayerHorsemann");
	MarkNativeAsOptional("UnHorsemannPlayer");
	MarkNativeAsOptional("WardenMenuPlayer");
	MarkNativeAsOptional("PlayerClimbWall");

	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_FindWarden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
	MarkNativeAsOptional("JBGameMode_OpenAllDoors");

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
	MarkNativeAsOptional("JBGameMode.iPlaying.get");
	MarkNativeAsOptional("JBGameMode.FindRandomWarden");
	MarkNativeAsOptional("JBGameMode.DoorHandler");
	MarkNativeAsOptional("JBGameMode.FindWarden");
	MarkNativeAsOptional("JBGameMode.FireWarden");
	MarkNativeAsOptional("JBGameMode.OpenAllDoors");
	MarkNativeAsOptional("JBGameMode.GetProperty");
	MarkNativeAsOptional("JBGameMode.SetProperty");
	MarkNativeAsOptional("JBGameMode.SetArray");
	MarkNativeAsOptional("JBGameMode.SetString");
	MarkNativeAsOptional("JBGameMode.GetArray");
	MarkNativeAsOptional("JBGameMode.GetString");
	MarkNativeAsOptional("JBGameMode.Remove");
	MarkNativeAsOptional("JBGameMode.Clear");
	MarkNativeAsOptional("JBGameMode.Snapshot");
	MarkNativeAsOptional("JBGameMode.Size.get");
}
#endif