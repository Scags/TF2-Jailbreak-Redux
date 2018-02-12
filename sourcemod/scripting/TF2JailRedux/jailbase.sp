// Having this here for reasons
methodmap TF2Item < Handle
{
	public TF2Item(int iFlags) {
		return view_as<TF2Item>(TF2Items_CreateItem(iFlags));
	}
	property int iFlags {
		public get() 			{ return TF2Items_GetFlags(this); }
		public set(int iVal) 	{ TF2Items_SetFlags(this, iVal); }
	}
	property int iItemIndex {
		public get() 			{ return TF2Items_GetItemIndex(this); }
		public set(int iVal) 	{ TF2Items_SetItemIndex(this, iVal); }
	}
	property int iQuality {
		public get() 			{ return TF2Items_GetQuality(this); }
		public set(int iVal) 	{ TF2Items_SetQuality(this, iVal); }
	}
	property int iLevel {
		public get() 			{ return TF2Items_GetLevel(this); }
		public set(int iVal)	{ TF2Items_SetLevel(this, iVal); }
	}
	property int iNumAttribs {
		public get() 			{ return TF2Items_GetNumAttributes(this); }
		public set(int iVal) 	{ TF2Items_SetNumAttributes(this, iVal); }
	}
	public int GiveNamedItem(int iClient)
	{
		return TF2Items_GiveNamedItem(iClient, this);
	}
	public void SetClassname(char[] strClassName)
	{
		TF2Items_SetClassname(this, strClassName);
	}
	public void GetClassname(char[] strDest, int iDestSize)
	{
		TF2Items_GetClassname(this, strDest, iDestSize);
	}
	public void SetAttribute(int iSlotIndex, int iAttribDefIndex, float flValue)
	{
		TF2Items_SetAttribute(this, iSlotIndex, iAttribDefIndex, flValue);
	}
	public int GetAttribID(int iSlotIndex)
	{
		return TF2Items_GetAttributeId(this, iSlotIndex);
	}
	public float GetAttribValue(int iSlotIndex)
	{
		return TF2Items_GetAttributeValue(this, iSlotIndex);
	}
};

stock TF2Item PrepareItemHandle(TF2Item hItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
	static TF2Item hWeapon = null;
	int addattribs = 0;

	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	int flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve)
		flags |= PRESERVE_ATTRIBUTES;

	if ( !hWeapon )
		hWeapon = new TF2Item(flags);
	else hWeapon.iFlags = flags;
//	Handle hWeapon = TF2Items_CreateItem(flags);	//null;

	if (hItem != null) {
		addattribs = hItem.iNumAttribs;
		if (addattribs) {
			for (int i=0; i < 2*addattribs; i+=2) {
				bool dontAdd = false;
				int attribIndex = hItem.GetAttribID(i);
				for (int z=0; z < attribCount+i; z += 2) {
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd) {
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(hItem.GetAttribValue(i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2*addattribs;
		}
		delete hItem;
	}

	if (name[0] != '\0') {
		flags |= OVERRIDE_CLASSNAME;
		hWeapon.SetClassname(name);
	}
	if (index != -1) {
		flags |= OVERRIDE_ITEM_DEF;
		hWeapon.iItemIndex = index;
	}
	if (attribCount > 1) {
		hWeapon.iNumAttribs = (attribCount/2);
		int i2 = 0;
		for (int i=0; i<attribCount && i<32; i += 2)
		{
			hWeapon.SetAttribute(i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else hWeapon.iNumAttribs = 0;
	hWeapon.iFlags = flags;
	return hWeapon;
}

public char strCustomLR[64];	// Used for formatting the player custom lr say hook

int
	AmmoTable[2049],
	ClipTable[2049]
;

int EnumTNPS[4][eTextNodeParams];

//float flHolstered[PLYR][3];

StringMap hJailFields[PLYR];

methodmap JailFighter
{
	public JailFighter(const int ind, bool uid=false)
	{
		int player=0;
		if (uid && GetClientOfUserId(ind) > 0)
			player = ( ind );
		else if ( IsClientValid(ind) )
			player = GetClientUserId(ind);
		return view_as< JailFighter >( player );
	}

	property int userid {
		public get()				{ return view_as< int >(this); }
	}
	property int index {
		public get()				{ return GetClientOfUserId( view_as< int >(this) ); }
	}

	property int iCustom
	{
		public get()
		{
			int i; hJailFields[this.index].GetValue("iCustom", i);
			return i;
		}
		public set( const int val )
		{
			hJailFields[this.index].SetValue("iCustom", val);
		}
	}
	property int iKillCount
	{
		public get()
		{
			int i; hJailFields[this.index].GetValue("iKillCount", i);
			return i;
		}
		public set( const int val )
		{
			hJailFields[this.index].SetValue("iKillCount", val);
		}
	}
	property bool bIsWarden
	{
		public get()
		{
			bool i; hJailFields[this.index].GetValue("bIsWarden", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bIsWarden", val);
		}
	}
	property bool bIsMuted
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsMuted", i);
			return i;
		}
		public set( const bool val )		
		{
			hJailFields[this.index].SetValue("bIsMuted", val);
		}
	}
	property bool bIsQueuedFreeday
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsQueuedFreeday", i);
			return i;
		}
		public set( const bool val )		
		{
			hJailFields[this.index].SetValue("bIsQueuedFreeday", val);
		}
	}
	property bool bIsFreeday
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsFreeday", i);
			return i;
		}
		public set( const bool val )		
		{
			hJailFields[this.index].SetValue("bIsFreeday", val);
		}
	}
	property bool bLockedFromWarden
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bLockedFromWarden", i);
			return i;
		}
		public set( const bool val )		
		{
			hJailFields[this.index].SetValue("bLockedFromWarden", val);
		}
	}
	property bool bIsVIP
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsVIP", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bIsVIP", val);
		}
	}
	property bool bIsAdmin
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsAdmin", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bIsAdmin", val);
		}
	}
	property bool bIsHHH
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsHHH", i);
			return i;
		}
		public set( const bool val )		
		{
			hJailFields[this.index].SetValue("bIsHHH", val);
		}
	}
	property bool bInJump
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bInJump", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bInJump", val);
		}
	}
#if defined _clientprefs_included
	property bool bNoMusic
	{
		public get()
		{
			if (!AreClientCookiesCached(this.index))
				return false;
			char strMusic[6];
			GetClientCookie(this.index, MusicCookie, strMusic, sizeof(strMusic));
			return (StringToInt(strMusic) == 1);
		}
		public set( const bool val )
		{
			if (!AreClientCookiesCached(this.index))
				return;
			int value;
			if (val)
				value = 1;
			else value = 0;
			char strMusic[6];
			IntToString(value, strMusic, sizeof(strMusic));
			SetClientCookie(this.index, MusicCookie, strMusic);
		}
	}
#endif
	property bool bUnableToTeleport
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bUnableToTeleport", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bUnableToTeleport", val);
		}
	}
	property bool bIsZombie
	{
		public get()				
		{
			bool i; hJailFields[this.index].GetValue("bIsZombie", i);
			return i;
		}
		public set( const bool val )
		{
			hJailFields[this.index].SetValue("bIsZombie", val);
		}
	}

	property float flSpeed
	{
		public get()
		{
			float i; hJailFields[this.index].GetValue("flSpeed", i);
			return i;
		}
		public set( const float val )
		{
			hJailFields[this.index].SetValue("flSpeed", val);
		}
	}
	property float flKillSpree
	{
		public get()
		{
			float i; hJailFields[this.index].GetValue("flKillSpree", i);
			return i;
		}
		public set( const float val )
		{
			hJailFields[this.index].SetValue("flKillSpree", val);
		}
	}
	/**
	 * creates and spawns a weapon to a player
	 *
	 * @param name		entity name of the weapon, example: "tf_weapon_bat"
	 * @param index		the index of the desired weapon
	 * @param level		the level of the weapon
	 * @param qual		the weapon quality of the item
	 * @param att		the nested attribute string, example: "2 ; 2.0" - increases weapon damage by 100% aka 2x.
	 * @return		entity index of the newly created weapon
	 */
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att)
	{
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if ( !hWep )
			return -1;

		hWep.SetClassname(name);
		hWep.iItemIndex = index;
		hWep.iLevel = level;
		hWep.iQuality = qual;
		char atts[32][32];
		int count = ExplodeString(att, " ; ", atts, 32, 32);
		count &= ~1;	// Odd numbered attributes result in an error, remove the 1st bit so count will always be even.
		if (count > 0) {
			hWep.iNumAttribs = count/2;
			int i2=0;
			for (int i=0 ; i<count ; i+=2) {
				hWep.SetAttribute( i2, StringToInt(atts[i]), StringToFloat(atts[i+1]) );
				i2++;
			}
		}
		else hWep.iNumAttribs = 0;

		int entity = hWep.GiveNamedItem(this.index);
		delete hWep;
		EquipPlayerWeapon(this.index, entity);
		return entity;
	}
	/**
	 * gets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded max ammo of the weapon
	 */
	public int GetAmmotable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			return AmmoTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void SetAmmotable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			AmmoTable[weapon] = val;
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int GetCliptable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			return ClipTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void SetCliptable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			ClipTable[weapon] = val;
	}
	public int GetWeaponSlotIndex(const int slot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(const int alpha)
	{
		int transparent = alpha;
		int entity;
		for (int i=0; i<5; i++) {
			entity = GetPlayerWeaponSlot(this.index, i); 
			if ( IsValidEdict(entity) && IsValidEntity(entity) )
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
	/*public void SetOverlay(const char[] strOverlay)
	{
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);
		ClientCommand(this.index, "r_screenoverlay \"%s\"", strOverlay);
	}*/
	public void TeleToSpawn(int team = 0)
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
				if (GetEntProp(iEnt, Prop_Send, "m_iTeamNum") == team)
					hArray.Push(iEnt);
			}
		}
		iEnt = hArray.Get( GetRandomInt(0, hArray.Length-1) );
		delete hArray;

		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		TeleportEntity(this.index, vPos, vAng, NULL_VECTOR);
	}
	public void SpawnSmallHealthPack(int ownerteam=0)
	{
		if (!IsValidClient(this.index) || !IsPlayerAlive(this.index))
			return;
		int healthpack = CreateEntityByName("item_healthkit_small");
		if ( IsValidEntity(healthpack) ) 
		{
			float pos[3]; GetClientAbsOrigin(this.index, pos);
			pos[2] += 20.0;
			DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
			DispatchSpawn(healthpack);
			SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
			SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
			float vel[3];
			vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
			TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		}
	}
	public void ForceTeamChange(const int team, bool spawn = true)
	{
		int client = this.index;
		if (TF2_GetPlayerClass(client) > TFClass_Unknown) {
			SetEntProp(client, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(client, team);
			SetEntProp(client, Prop_Send, "m_lifeState", 0);
			if (spawn)
				TF2_RespawnPlayer(client);
		}
	}
	public void MutePlayer()
	{
		int client = this.index;
		if (!this.bIsMuted && !this.bIsAdmin && !AlreadyMuted(client))
		{
			SetClientListeningFlags(client, VOICE_MUTED);
			this.bIsMuted = true;
			PrintToConsole(client, "[JailRedux] You are muted by the plugin.");
		}
	}
	public void GiveFreeday()
	{
		ServerCommand("sm_evilbeam #%d", this.userid);
		int flags = GetEntityFlags(this.index) | FL_NOTARGET;
		SetEntityFlags(this.index, flags);
		
		if (this.bIsQueuedFreeday)
			this.bIsQueuedFreeday = false;
		this.bIsFreeday = true;
	}
	
	public void RemoveFreeday()
	{
		int client = this.index;
		int flags = GetEntityFlags(client) & ~FL_NOTARGET;
		SetEntityFlags(client, flags);
		ServerCommand("sm_evilbeam #%d", this.userid);
		this.bIsFreeday = false;
		//SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}
	public void StripToMelee()
	{
		int client = this.index;
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		TF2_RemoveWeaponSlot(client, 5);
		//TF2_SwitchToSlot(client, TFWeaponSlot_Melee);
		
		char sClassName[64];
		int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		{
			//FakeClientCommandEx(client, "use %s", sClassName); //wtf?
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		}
	}
	public void EmptyWeaponSlots()
	{
		int client = this.index;
		if (!IsClientValid(client) || TF2_GetClientTeam(client) != TFTeam_Red)
			return;

		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
	
		for (int i = 0; i < 2; i++)
		{
			offset += 4;
	
			int weapon = GetEntDataEnt2(client, offset);
	
			if (!IsValidEntity(weapon) || i == TFWeaponSlot_Melee)
				continue;
	
			int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
			if (clip != -1)
				SetEntProp(weapon, Prop_Data, "m_iClip1", 0);
	
			clip = GetEntProp(weapon, Prop_Data, "m_iClip2");
			if (clip != -1)
				SetEntProp(weapon, Prop_Data, "m_iClip2", 0);
				
			SetWeaponAmmo(weapon, 0);
			//Client_SetWeaponPlayerAmmoEx(client, weapon, 0, 0);
		}
	
		char sClassName[64];
		int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		{
			//FakeClientCommandEx(client, "use %s", sClassName); // wtf?
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		}
		
		//CPrintToChat(client, "{red}[JailRedux]{tan} Your weapons and ammo have been stripped.");
	}
	public void UnmutePlayer()
	{
		if (this.bIsMuted)
		{
			int client = this.index;
			SetClientListeningFlags(client, VOICE_NORMAL);
			this.bIsMuted = false;
			PrintToConsole(client, "[JailRedux] You are unmuted by the plugin.");
		}
	}
	public void WardenSet()
	{
		this.bIsWarden = true;	
		this.UnmutePlayer();
		char strWarden[256];
		int client = this.index;
		Format(strWarden, sizeof(strWarden), "%N is the current Warden.", client);
		SetTextNode(hTextNodes[2], strWarden, EnumTNPS[2][fCoord_X], EnumTNPS[2][fCoord_Y], EnumTNPS[2][fHoldTime], EnumTNPS[2][iRed], EnumTNPS[2][iGreen], EnumTNPS[2][iBlue], EnumTNPS[2][iAlpha], EnumTNPS[2][iEffect], EnumTNPS[2][fFXTime], EnumTNPS[2][fFadeIn], EnumTNPS[2][fFadeOut]);
		CPrintToChatAll("{red}[JailRedux]{fullred} %N{tan} is the new Warden", client);
	}
	/**	Props to VoIDed
	 * Sets the custom model of this player.
	 *
	 * @param model		The model to set on this player.
	*/
	public void SetCustomModel( const char[] model )
	{
		SetVariantString( model );
		AcceptEntityInput(this.index, "SetCustomModel" );
	}
	public void WardenUnset()
	{
		if (!this.bIsWarden)
			return;
		
		if (hTextNodes[2] != null)
		{
			for (int i = MaxClients; i; --i)
			{
				if (IsClientInGame(i))
					ClearSyncHud(i, hTextNodes[2]);
			}
		}
		this.bIsWarden = false;
		this.SetCustomModel("");
	}
	public void PreEquip()
	{
		int client = this.index;
		TF2_RemovePlayerDisguise(client);
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
		{
			if (GetOwner(ent) == client) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
		{
			if (GetOwner(ent) == client) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1)
		{
			if (GetOwner(ent) == client) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_razorback")) != -1)
		{
			if (GetOwner(ent) == client) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_campaign_item")) != -1)
		{
			if (GetOwner(ent) == client) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		TF2_RemoveAllWeapons(client);
	}
	public void MakeHorsemann()
	{
		int client = this.index;
		
		int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if (ragdoll > MaxClients && IsValidEntity(ragdoll)) 
			AcceptEntityInput(ragdoll, "Kill");
		char weaponname[32];
		GetClientWeapon(client, weaponname, sizeof(weaponname));
		if (strcmp(weaponname, "tf_weapon_minigun", false) == 0) 
		{
			SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_iWeaponState", 0);
			TF2_RemoveCondition(client, TFCond_Slowed);
		}
		//TF2_SwitchtoSlot(client, TFWeaponSlot_Melee);
		this.PreEquip();
		this.SpawnWeapon("tf_weapon_sword", 266, 100, 5, "264 ; 1.75 ; 263 ; 1.3 ; 15 ; 0 ; 2 ; 3.1 ; 107 ; 4.0 ; 109 ; 0.0 ; 68 ; -2 ; 53 ; 1.0 ; 27 ; 1.0");

		char sClassName[64];
		int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		
		this.SetCustomModel("models/bots/headless_hatman.mdl");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
		SetEntProp(wep, Prop_Send, "m_iWorldModelIndex", PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"));
		SetEntProp(wep, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"), _, 0);
		
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");

		SetEntProp(client, Prop_Send, "m_iHealth", 1500);
		DoHorsemannParticles(client);
		this.bIsHHH = true;
	}
	public void UnHorsemann()
	{
		int client = this.index;
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		SetEntPropFloat(client, Prop_Data, "m_flModelScale", 1.0);
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		ClearHorsemannParticles(client);
		if (IsPlayerAlive(client))
			ResetPlayer(client);
		this.bIsHHH = false;
	}
	public void Init_JB()
	{
		this.iCustom = 0;
		this.iKillCount = 0;
		this.bIsWarden = false;
		this.bIsMuted = false;
		this.bIsQueuedFreeday = false;
		this.bIsFreeday = false;
		this.bLockedFromWarden = false;
		this.bIsVIP = false;
		this.bIsAdmin = false;
		this.bIsHHH = false;
		this.bInJump = false;
		this.bUnableToTeleport = false;
		this.bIsZombie = false;
		this.flSpeed = 0.0;
		this.flKillSpree = 0.0;
	}
	public void TeleportToPosition(const int iLocation)
	{
		switch (iLocation)
		{
			case 1:TeleportEntity(this.index, flFreedayPosition, nullvec, nullvec);
			case 2:TeleportEntity(this.index, flWardayRed, nullvec, nullvec);
			case 3:TeleportEntity(this.index, flWardayBlu, nullvec, nullvec);
		}
	}
	public void ListLRS()
	{
		if (IsVoteInProgress())
			return;

		Menu menu = new Menu(ListLRsMenu);
		menu.SetTitle("Select a Last Request");
		//menu.AddItem("-1", "Random LR");	// Moved to handler
		AddLRToMenu(menu);
		menu.ExitButton = true;
		menu.Display(this.index, 30);
	}
	public void WardenMenu()
	{
		if (IsVoteInProgress())
			return;

		Menu wmenu = new Menu(WardenMenuHandler);
		wmenu.SetTitle("Warden Commands");
		ManageWardenMenu(wmenu);
		wmenu.ExitButton = true;
		wmenu.Display(this.index, MENU_TIME_FOREVER);
	}
	public void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay)
	//Credit to Mecha the Slag
	{
		if ( GetClientHealth(this.index) <= health )	// Have to baby players so they don't accidentally kill themselves trying to escape
			return;

		int client = this.index;
		char classname[64];
		float vecClientEyePos[3];
		float vecClientEyeAng[3];
		GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
		GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking

		// Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

		if ( !TR_DidHit(null) )
			return;

		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if (!StrEqual(classname, "worldspawn"))
			return;

		float fNormal[3];
		TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);

		if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0)
			return;
		if (fNormal[0] <= -30.0)
			return;

		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos);

		if (distance >= 100.0)
			return;

		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

		if (attackdelay)
			SetPawnTimer(NoAttacking, 0.1, EntIndexToEntRef(weapon));
	}
	public void ConvertToZombie()
	{
		this.bIsZombie = true;
		int client = this.index;
		this.ForceTeamChange(BLU);
		TF2_SetPlayerClass(client, TFClass_Scout);
		this.PreEquip();
		int weapon = this.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6 ; 0.5 ; 57 ; 15.0 ; 26 ; 75.0 ; 49 ; 1.0 ; 68 ; -2.0");
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		TF2_AddCondition(client, TFCond_Ubercharged, 3.0);
		SetEntityHealth(client, 200);
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		SetEntProp(client, Prop_Send, "m_nBody", 0);
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 30, 160, 255, 255);
	}
};
