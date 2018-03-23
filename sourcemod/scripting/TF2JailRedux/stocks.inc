stock char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
stock char extensionsb[2][5] = { ".vtf", ".vmt" };

stock int GetHealingTarget(const int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (!IsValidEdict(medigun) || !IsValidEntity(medigun))
		return -1;
	char s[32]; GetEdictClassname(medigun, s, sizeof(s));
	if ( !strcmp(s, "tf_weapon_medigun", false) ) {
		if ( GetEntProp(medigun, Prop_Send, "m_bHealing") )
			return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
	}
	return -1;
}
stock int GetActiveWep(const int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
		return weapon;
	return -1;
}
stock float GetMediCharge(const int medigun)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(const int medigun, const float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock bool IsNearSpencer(const int client)
{
	int medics = 0;
	for (int i=MaxClients ; i ; --i) {
		if (IsValidClient(i) && GetHealingTarget(i) == client)
			medics++;
	}
	return (GetEntProp(client, Prop_Send, "m_nNumHealers") > medics);
}
// Prepare content stocks
stock void CheckDownload(const char[] dlpath)
{
	if ( FileExists(dlpath) )
		AddFileToDownloadsTable(dlpath);
}
// Following 'Prepare' stocks taken from VSH1
//'Prepare' stocks will precache AND add to the downloads table (if file exists).
stock void PrepareSound(const char[] szSoundPath) // For single custom sound files
{
	PrecacheSound(szSoundPath, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", szSoundPath);
	CheckDownload(s);
}
stock void DownloadSoundList(const char[][] szFileList, int iSize) // For arrays of custom sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrepareSound(szFileList[i]);
	}
}
stock void PrecacheSoundList(const char[][] szFileList, int iSize) // For arrays of stock TF2 sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrecacheSound(szFileList[i], true);
	}
}
stock void PrepareMaterial(const char[] szMaterialPath) // For single custom materials, omit file extensions as it prepares VMT + VTF
{
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vtf");
	CheckDownload(s);
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vmt");
	CheckDownload(s);
}
stock void DownloadMaterialList(const char[][] szFileList, int iSize) // For arrays of custom materials
{
	char s[PLATFORM_MAX_PATH];
	for (int i = 0; i < iSize; i++)
	{
		strcopy(s, sizeof(s), szFileList[i]);
		CheckDownload(s);
	}
}
stock int PrepareModel(const char[] szModelPath, bool bMdlOnly = false) // For custom models, do not omit .MDL extension
{
	char szBase[PLATFORM_MAX_PATH];
	char szPath[PLATFORM_MAX_PATH];
	int i;
	strcopy(szBase, sizeof(szBase), szModelPath);
	SplitString(szBase, ".mdl", szBase, sizeof(szBase)); // Kind of redundant, but eh.
	
	if (!bMdlOnly)
	{
		for (i = 0; i < sizeof(extensions); i++)
		{
			Format(szPath, PLATFORM_MAX_PATH, "%s%s", szBase, extensions[i]);
			CheckDownload(szPath);
		}
	}
	else CheckDownload(szModelPath);
	
	return PrecacheModel(szModelPath, true);
}
// End 'Prepare' stocks
stock void ForceTeamWin(const int team)
{
	int entity = FindEntityByClassname(-1, "team_control_point_master");
	if (entity <= 0) {
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int GetItemIndex(const int item)
{
	if (IsValidEdict(item) && IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetItemQuality(const int item)
{
	if (IsValidEdict(item) && IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iEntityQuality");
	return -1;
}
stock bool IsInRange(const int entity, const int target, const float dist, bool pTrace = false)
{
	float entitypos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", entitypos);
	float targetpos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetpos);

	if ( GetVectorDistance(entitypos, targetpos) <= dist )
	{
		if (!pTrace)
			return true;
		else {
			TR_TraceRayFilter( entitypos, targetpos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, entity );
			if ( TR_GetFraction() > 0.98 )
				return true;
		}
	}
	return false;
}
stock int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	CreateTimer(3.0, EraseEntity, EntIndexToEntRef(particle));
	return particle;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle)) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, EraseEntity, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int ShootRocket(const int client, bool bCrit = false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false)
{
//new String:strEntname[45] = "tf_projectile_spellfireball";
/*
switch (spell)
	{
		case FIREBALL: 		strEntname = "tf_projectile_spellfireball";
		case LIGHTNING: 	strEntname = "tf_projectile_lightningorb";
		case PUMPKIN: 		strEntname = "tf_projectile_spellmirv";
		case PUMPKIN2: 		strEntname = "tf_projectile_spellpumpkin";
		case BATS: 			strEntname = "tf_projectile_spellbats";
		case METEOR: 		strEntname = "tf_projectile_spellmeteorshower";
		case TELE: 			strEntname = "tf_projectile_spelltransposeteleport";
		case BOSS:			strEntname = "tf_projectile_spellspawnboss";
		case ZOMBIEH:		strEntname = "tf_projectile_spellspawnhorde";
		case ZOMBIE:		strEntname = "tf_projectile_spellspawnzombie";
	}
	switch(spell)
	{
		//These spells have arcs.
		case BATS, METEOR, TELE:
		{
			vVelocity[2] += 32.0;
		}
	}

CTFGrenadePipebombProjectile m_bCritical
CTFProjectile_Rocket m_bCritical
CTFProjectile_SentryRocket m_bCritical
CTFWeaponBaseGrenadeProj m_bCritical
CTFMinigun m_bCritShot
CTFFlameThrower m_bCritFire
CTFProjectile_Syringe
CTFPlayer m_iCritMult
SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	}
*/
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	
	if (!IsValidEdict(iProjectile))
		return 0;

	float vVelocity[3];
	GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);

	if (!arc)
		NormalizeVector(vVelocity, vVelocity);
	else
		vVelocity[2] -= 0.025;

	ScaleVector(vVelocity, flSpeed);
	SetEntPropEnt(iProjectile,	Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,		Prop_Send, "m_bCritical", (bCrit ? 1 : 0));
	SetEntProp(iProjectile,		Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,		Prop_Send, "m_nSkin", (iTeam-2));

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);

	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	if (arc)
		SetEntityMoveType(iProjectile, MOVETYPE_FLYGRAVITY);
	if ( model[0] != '\0' )
		SetEntityModel(iProjectile, model);
	return iProjectile;
}

stock void SetClientOverlay(const int client, const char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}

stock bool IsValidClient(const int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients)
		return false;
	if (!IsClientInGame(client))
		return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
		return false;
	if (replaycheck)
		if (IsClientSourceTV(client) || IsClientReplay(client))
			return false;
	if (TF2_GetPlayerClass(client) == TFClass_Unknown)
		return false;
	return true;
}
stock int GetOwner(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetBuilder(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
	return -1;
}
stock int GetGroundEntity(const int client)
{
	if ( IsValidClient(client, false)) )
		return GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	return -1;
}
stock void DoExplosion(const int owner, const int damage, const int radius, float pos[3])
{
	int explode = CreateEntityByName("env_explosion");
	if ( !IsValidEntity(explode) )
		return;

	DispatchKeyValue(explode, "targetname", "exploder");
	DispatchKeyValue(explode, "spawnflags", "4");
	DispatchKeyValue(explode, "rendermode", "5");

	SetEntPropEnt(explode, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(explode, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(explode, Prop_Data, "m_iRadiusOverride", radius);

	int team = GetClientTeam(owner);
	SetVariantInt(team); AcceptEntityInput(explode, "TeamNum");
	SetVariantInt(team); AcceptEntityInput(explode, "SetTeam");

	TeleportEntity(explode, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(explode);
	ActivateEntity(explode);
	AcceptEntityInput(explode, "Explode");
	AcceptEntityInput(explode, "Kill");
}

stock float[] nSubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] - vec2[0];
	result[1] = vec1[1] - vec2[1];
	result[2] = vec1[2] - vec2[2];
	return result;
}
stock float[] nAddVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] + vec2[0];
	result[1] = vec1[1] + vec2[1];
	result[2] = vec1[2] + vec2[2];
	return result;
}
stock float[] nScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] nNegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock bool VectorCompare (const float v1[3], const float v2[3])
{
	for (int i=0 ; i<3 ; i++)
		if (v1[i] != v2[i])
			return false;
			
	return true;
}
stock int GetLivingPlayers(const int team)
{
	int AlivePlayers = 0;
	for (int i=MaxClients ; i ; --i) {
		if ( IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team )
			++AlivePlayers;
	}
	return AlivePlayers;
}
stock void IncrementHeadCount(const int client, bool addhealth = true, int addheads = 1)
{
	if ( (TF2_GetPlayerClass(client) == TFClass_DemoMan) &&  !TF2_IsPlayerInCondition(client, TFCond_DemoBuff) )
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite); // Apply this condition to Demomen to give them their glowing eye effect.
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if ( addhealth )
	{
		int health = GetClientHealth(client);
		//health += (decapitations >= 4 ? 10 : 15);
		if ( health + (15 * addheads) <= 300 ) // TODO: Replace this with an overheal calculation (MaxHP * 1.5) OR add a maxhealth arg. 
			health += 15 * addheads;
		else
			health = 300;
		SetEntProp(client, Prop_Data, "m_iHealth", health);
		SetEntProp(client, Prop_Send, "m_iHealth", health);
	}
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   // Recalc their speed
}
stock void SetNextAttack(const int weapon, float duration = 0.0)
{
	if (weapon <= MaxClients || !IsValidEntity(weapon))
		return;
	float next = GetGameTime()+duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}
stock void ResetPlayer(const int client)
{
	TF2_RegeneratePlayer(client);
	SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );
	SetEntProp( client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth") );
}


/**
 * Wrapper function for easily setting up non-repeating timers
 *
 * @param func			Function pointer to call desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */

/*
If you need to use this and your function uses 3 parameters, modify it if necessary.
BUG/GLITCH: For some strange reason, SetPawnTimer doesn't work when u attempt to callback stock functions, interesting...
*/
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);

	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();

	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);

	Call_Finish();
	return Plugin_Continue;
}
stock void SetArenaCapEnableTime(const float time)
{
	int ent = -1;
	char strTime[32]; FloatToString(time, strTime, sizeof(strTime));
	if ( (ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1 )
		DispatchKeyValue(ent, "CapEnableDelay", strTime);
}
stock void SetClientGlow(const int client, const float time1, float clampfl = 0.0, float &glowtimer)
{
	if (IsValidClient(client)) {
		glowtimer += time1;
		if (clampfl > 0.0)
			glowtimer = clampfl;
		if (glowtimer <= 0.0) {
			glowtimer = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
stock int GetTeamPlayerCount(const int team)
{
	int count = 0;
	for (int i=MaxClients ; i ; --i) {
		if (IsValidClient(i) && GetClientTeam(i) == team)
			{count++;}
	}
	return count;
}
stock int GetClientCloakIndex(const int client)
{
	if (!IsValidClient(client))
		return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep))
		return -1;
	char classname[32];
	GetEntityClassname(wep, classname, sizeof(classname));
	if ( !strncmp(classname, "tf_wea", 6, false) )
		return GetItemIndex(wep);
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if ( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			{return i;}
	}
	return -1;
}
stock bool RemoveDemoShield(int iClient)
{
	int iEnt = MaxClients + 1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable_demoshield")) != -1)
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && !GetEntProp(iEnt, Prop_Send, "m_bDisguiseWearable"))
		{
			TF2_RemoveWearable(iClient, iEnt);
			return true; //Returns true if Shield was removed...
		}
	}
	return false; //...and returns False if one wasn't found.
}
stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i=0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return -1;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	return -1;
}
stock int FindSentry(const int client)
{
	int i = -1;
	while ( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 )
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client)
			return i;
	return -1;
}
stock bool TF2_IsPlayerCritBuffed(const int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(34))
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(35))
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			);
}
stock int GetMaxAmmo(const int client, const int slot)
{
	if (!IsValidClient(client))
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		switch (slot)
		{ //FindDataMapInfo(client, "m_iAmmo");
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool IsWeaponSlotActive(const int client, const int slot)
{
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}
stock bool IsValidAdmin(const int client, const char[] flags)
{
	if (!IsClientInGame(client))
		return false;
	int ibFlags = ReadFlagString(flags);
	if (!StrEqual(flags, "")) {
		if ( (GetUserFlagBits(client) & ibFlags) == ibFlags )
			return true;
	}
	if ( GetUserFlagBits(client) & ADMFLAG_ROOT )
		return true;
	return false;
}
stock int AttachProjectileModel(const int entity, const char[] strModel, char[] strAnim = "")
{
	if (!IsValidEntity(entity))
		return -1;
	int model = CreateEntityByName("prop_dynamic");
	if (IsValidEdict(model)) {
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if (strAnim[0] != '\0') {
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	}
	else LogError("(AttachProjectileModel): Could not create prop_dynamic");
	return -1;
}
stock bool GetRandomBool()
{
	return ( !GetRandomInt(0, 1) ? false : true );
}
stock void _SetCapOwner(const int iCapTeam, float flEnableTime = 30.0)
{
	int i = -1;
	int cap_master = FindEntityByClassname(-1, "team_control_point_master");
	while ( (i = FindEntityByClassname(i, "team_control_point")) != -1 )
	{
		if (IsValidEntity(i)) {	// Adapted from Arena:Respawn
			SetVariantInt(iCapTeam);
			AcceptEntityInput(i, "SetOwner", -1, cap_master); // Must have team_control_point_master as the activator, less it will just ignore the Input
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			SetPawnTimer(EnableCap, flEnableTime);
		}
	}
}
stock bool StrStarts(const char[] szStr, const char[] szSubStr, bool bCaseSensitive = true)
{
	return !StrContains(szStr, szSubStr, bCaseSensitive);
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i=0 ; i<length ; ++i) {
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores and normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_'))
			return false;
	}
	// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
stock int GetRandomPlayer(int team, bool alive = false)  
{  
	int[] clients = new int[MaxClients];  
	int clientCount;  
	for (int i = MaxClients; i; --i)  
	{
		if (!IsClientInGame(i))
			continue;
		if (GetClientTeam(i) != team) 
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		clients[clientCount++] = i;  
	}  
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];  
}
stock int GetRandomClient(bool alive = true, bool nobots = false)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		if (nobots && IsFakeClient(i))
			continue;
			
		clients[clientCount++] = i;
	}  
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];  
}
stock void SetControlPoint(const bool enable)
{
	int CPm = -1;
	while ( (CPm = FindEntityByClassname(CPm, "team_control_point")) != -1 )
	{
		if ( CPm > MaxClients && IsValidEdict(CPm) ) 
		{
			AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}
stock int FindEntityByClassnameSafe(int iStart, char[] sClassName)
{
	while (iStart > -1 && !IsValidEntity(iStart))
		iStart--;

	return FindEntityByClassname(iStart, sClassName);
}
stock void RemoveValveHat(int client, bool unhide = false)
{
	char sNetClass[32];

	int edict = MaxClients + 1;
	while ((edict = FindEntityByClassnameSafe(edict, "tf_wearable")) != -1)
	{
		if (GetEntityNetClass(edict, sNetClass, sizeof(sNetClass)) && strcmp(sNetClass, "CTFWearable") == 0)
		{
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (idx != 57 && idx != 133 && idx != 231 && idx != 444 && idx != 405 && idx != 608 && idx != 642 && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client)
			{
				SetEntityRenderMode(edict, (unhide ? RENDER_NORMAL : RENDER_TRANSCOLOR));
				SetEntityRenderColor(edict, 255, 255, 255, (unhide ? 255 : 0));
			}
		}
	}
	edict = MaxClients + 1;
	while ((edict = FindEntityByClassnameSafe(edict, "tf_powerup_bottle")) != -1)
	{
		if (GetEntityNetClass(edict, sNetClass, sizeof(sNetClass)) && strcmp(sNetClass, "CTFPowerupBottle") == 0)
		{
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (idx != 57 && idx != 133 && idx != 231 && idx != 444 && idx != 405 && idx != 608 && idx != 642 && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client)
			{
				SetEntityRenderMode(edict, (unhide ? RENDER_NORMAL : RENDER_TRANSCOLOR));
				SetEntityRenderColor(edict, 255, 255, 255, (unhide ? 255 : 0));
			}
		}
	}
}
/*stock int CreateParticle2(const char[] sType, float refresh = 2.0, int client, int attach = NO_ATTACH, float xOffs = 0.0, float yOffs = 0.0, float zOffs = 0.0)
{
	int particle = CreateEntityByName("info_particle_system");

	if (IsValidEntity(particle))
	{
		float pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);

		pos[0] += xOffs;
		pos[1] += yOffs;
		pos[2] += zOffs;

		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);

		DispatchKeyValue(particle, "effect_name", sType);

		if (attach != NO_ATTACH)
		{
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", client, particle, 0);

			if (attach == ATTACH_HEAD)
			{
				SetVariantString("head");
				AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
			}
		}
		DispatchKeyValue(particle, "targetname", "present");
		DispatchSpawn(particle);

		ActivateEntity(particle);
		AcceptEntityInput(particle, "Start");

		if (refresh > 0.0)
		{
			Handle hPack;
			CreateDataTimer(1.0, CheckClient, hPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			WritePackFloat(hPack, 0.0);
			WritePackCell(hPack, GetClientUserId(client));
			WritePackCell(hPack, EntIndexToEntRef(particle));
			WritePackString(hPack, sType);
			WritePackFloat(hPack, refresh);
			WritePackCell(hPack, attach);
			WritePackFloat(hPack, xOffs);
			WritePackFloat(hPack, yOffs);
			WritePackFloat(hPack, zOffs);
		}
	}

	return EntIndexToEntRef(particle);
}*/
stock void TF2_SwitchToSlot(const int client, const int slot)
{
	if (slot >= 0 && slot <= 5 && IsClientValid(client) && IsPlayerAlive(client))
	{
		char sClassName[64];
		int wep = GetPlayerWeaponSlot(client, slot);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		{
			//FakeClientCommandEx(client, "use %s", sClassName); //wtf?
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		}
	}
}
stock int MakeParticle(int client, char[] effect, char[] attachment)
{
		float pos[3];
		float ang[3];
		char buffer[128];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		GetClientEyeAngles(client, ang);
		ang[0] *= -1;
		ang[1] += 180.0;
		if (ang[1] > 180.0) ang[1] -= 360.0;
		ang[2] = 0.0;
	//	GetAngleVectors(ang, pos2, NULL_VECTOR, NULL_VECTOR);
		int particle = CreateEntityByName("info_particle_system");
		if (!IsValidEntity(particle)) return -1;
		TeleportEntity(particle, pos, ang, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", effect);
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client, particle, 0);
		if (attachment[0] != '\0')
		{
			SetVariantString(attachment);
			AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
		}
		Format(buffer, sizeof(buffer), "%s_%s%d", effect, attachment, particle);
		DispatchKeyValue(particle, "targetname", buffer);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", client);
		AcceptEntityInput(particle, "Start");
		return particle;
}
stock bool IsClientValid(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
		return true;
	return false;
}
stock void PreModel(int client)
{
	TF2_RemovePlayerDisguise(client);
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == client) 
		{
			if (GetItemIndex(ent) != 405 && GetItemIndex(ent) != 608) 
			{
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
}
stock void KillShields(const int client)
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
}
stock void RandomModelSizes(const int client)
{
	if (!GetRandomInt(0, 1))
		SetEntPropFloat(client, Prop_Send, "m_flHeadScale", GetRandomFloat(0.1, 0.5));
	else SetEntPropFloat(client, Prop_Send, "m_flHeadScale", GetRandomFloat(1.5, 4.0));
			
	if (!GetRandomInt(0, 1))
		SetEntPropFloat(client, Prop_Send, "m_flTorsoScale", GetRandomFloat(0.1, 0.5));
	else SetEntPropFloat(client, Prop_Send, "m_flTorsoScale", GetRandomFloat(1.5, 4.0));
					
	if (!GetRandomInt(0, 1))
		SetEntPropFloat(client, Prop_Send, "m_flHandScale", GetRandomFloat(0.1, 0.5));
	else SetEntPropFloat(client, Prop_Send, "m_flHandScale", GetRandomFloat(1.5, 4.0));
}
stock void SetTextNode(Handle node, const char[] sText, float X = -1.0, float Y = -1.0, float HoldTime = 5.0, int Red = 255, int Green = 255, int Blue = 255, int Alpha = 255, int Effect = 0, float fXTime = 6.0, float FadeIn = 0.1, float FadeOut = 0.2)
{
	SetHudTextParams(X, Y, HoldTime, Red, Green, Blue, Alpha, Effect, fXTime, FadeIn, FadeOut);

	for (int i = MaxClients; i; --i)
	{
		if (IsClientValid(i))
			ShowSyncHudText(i, node, sText);
	}
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients ; i ; --i) {
		if ( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout)
			return false;
	}
	return true;
}
stock void RemoveParachute(const int client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Parachute))
		TF2_RemoveCondition(client, TFCond_Parachute);
}
stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return (entity != data);
}
stock void OverNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}
// From smlib
stock int FindEntity(const char[] name, const char[] className = "")
{
	char strName[64];
	if (className[0] == '\0') 
	{
		// Hack: Double the limit to gets none-networked entities too.
		int realMaxEntities = GetMaxEntities() * 2;
		for (int i = 0; i < realMaxEntities; i++) 
		{			
			if (!IsValidEntity(i))
				continue;

			GetEntPropString(i, Prop_Data, "m_iName", strName, 64);			
			if (StrEqual(strName, name))
				return i;
		}
	}
	else 
	{
		int entity = -1;
		while ((entity = FindEntityByClassname(entity, className)) != -1) 
		{
			GetEntPropString(entity, Prop_Data, "m_iName", strName, 64);
			if (StrEqual(strName, name))
				return entity;
		}
	}
	return -1;
}
stock Handle PrepareItemHandle(Handle hItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
	static Handle hWeapon = null;
	int addattribs = 0;

	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	int flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve) 
		flags |= PRESERVE_ATTRIBUTES;
	if (hWeapon == null) 
		hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);

	if (hItem != null)
	{
		addattribs = TF2Items_GetNumAttributes(hItem);
		if (addattribs > 0)
		{
			for (int i = 0; i < 2 * addattribs; i += 2)
			{
				bool dontAdd = false;
				int attribIndex = TF2Items_GetAttributeId(hItem, i);
				for (int j = 0; j < attribCount+i; j += 2)
				{
					if (StringToInt(weaponAttribsArray[j]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		delete hItem;
	}

	if (name[0] != '\0')
	{
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1)
	{
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
		int i2 = 0;
		for (int i = 0; i < attribCount && i < 32; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);

	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}
stock void Clamp(int &returner, const int lowest, const int highest)
{
	if (returner < lowest)
		returner = lowest;
	else if (returner > highest)
		returner = highest;
}
stock bool iIsWithin(const int num, const int lowest, const int highest, bool inclusion = false)
{
	return (inclusion ? num >= lowest && num <= highest : num > lowest && num < highest);
}
stock bool flIsWithin(const float fl, const float lowest, const float highest, bool inclusion = false)
{
	return (inclusion ? fl >= lowest && fl <= highest : fl > lowest && fl < highest);
}
