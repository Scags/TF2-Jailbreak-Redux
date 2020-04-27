// Taken from FlaminSarge's bethehorsemann don't crucify me

#define HHH 			"models/bots/headless_hatman.mdl"
#define AXE 			"models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"
#define SPAWN 			"ui/halloween_boss_summoned_fx.wav"
#define SPAWNRUMBLE 	"ui/halloween_boss_summon_rumble.wav"
#define SPAWNVO 		"vo/halloween_boss/knight_spawn.wav"
#define BOO 			"vo/halloween_boss/knight_alert.wav"
#define DEATH 			"ui/halloween_boss_defeated_fx.wav"
#define DEATHVO 		"vo/halloween_boss/knight_death02.wav"
#define DEATHVO2 		"vo/halloween_boss/knight_dying.wav"
#define LEFTFOOT 		"player/footsteps/giant1.wav"
#define RIGHTFOOT 		"player/footsteps/giant2.wav"

int iHHHParticle[34][3];

static LastRequest g_LR;

public void HHH_Init()
{
	g_LR = LastRequest.CreateFromConfig("HHH Kill Round");
	if (g_LR)
	{
		g_LR.AddHook(OnLRActivate, HHH_OnLRActivate);
		g_LR.AddHook(OnLRActivatePlayer, HHH_OnLRActivatePlayer);
		g_LR.AddHook(OnSoundHook, HHH_OnSoundHook);
		g_LR.AddHook(OnPlayerDied, HHH_OnPlayerDied);
		g_LR.AddHook(OnPlayerSpawned, HHH_OnPlayerSpawned);
		g_LR.AddHook(OnPlayerPrepped, HHH_OnPlayerPrepped);
		g_LR.AddHook(OnRoundEndPlayer, HHH_OnRoundEndPlayer);

		JB_Hook(OnVariableReset, HHH_OnVariableReset);
		JB_Hook(OnDownloads, HHH_OnDownloads);
	}
}

public void HHH_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void HHH_OnDownloads()
{
	PrecacheModel(HHH, true);
	PrecacheModel(AXE, true);
	PrecacheSound(SPAWN, true);
	PrecacheSound(SPAWNRUMBLE, true);
	PrecacheSound(SPAWNVO, true);
	PrecacheSound(BOO, true);
	PrecacheSound(DEATH, true);
	PrecacheSound(DEATHVO, true);
	PrecacheSound(DEATHVO2, true);
	PrecacheSound(LEFTFOOT, true);
	PrecacheSound(RIGHTFOOT, true);
}

public void HHH_OnLRActivate(LastRequest lr)
{
	EmitSoundToAll(SPAWN);
	EmitSoundToAll(SPAWNRUMBLE);
}

public void HHH_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	MakeHorsemann(player);
	SDKHook(player.index, SDKHook_GetMaxHealth, HHH_OnGetMaxHealth);
}

public void MakeHorsemann(const JBPlayer player)
{
	if (!IsClientValid(player.index))
		return;

	int client = player.index;

	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (ragdoll > MaxClients && IsValidEntity(ragdoll)) 
		RemoveEntity(ragdoll);

	char weaponname[32];
	GetClientWeapon(client, weaponname, sizeof(weaponname));
	if (!strcmp(weaponname, "tf_weapon_minigun", false)) 
	{
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_iWeaponState", 0);
		TF2_RemoveCondition(client, TFCond_Slowed);
	}
	//TF2_SwitchtoSlot(client, TFWeaponSlot_Melee);
	player.PreEquip();
	player.SpawnWeapon("tf_weapon_sword", 266, 100, 5, "264 ; 1.75 ; 263 ; 1.3 ; 15 ; 0 ; 2 ; 3.1 ; 107 ; 4.0 ; 109 ; 0.0 ; 68 ; -2 ; 53 ; 1.0 ; 27 ; 1.0");

	char sClassName[64];
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (wep > MaxClients && IsValidEntity(wep) && GetEdictClassname(wep, sClassName, sizeof(sClassName)))
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);

	SetVariantString("models/bots/headless_hatman.mdl");
	AcceptEntityInput(client, "SetCustomModel");

	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	SetEntProp(wep, Prop_Send, "m_iWorldModelIndex", PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"));
	SetEntProp(wep, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"), _, 0);

	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");

	SetEntProp(client, Prop_Send, "m_iHealth", 1500);
	DoHorsemannParticles(client);
}

public void UnHorsemann(const JBPlayer player)
{
	if (!IsClientValid(player.index))
		return;

	int client = player.index;

	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");
	SetEntPropFloat(client, Prop_Data, "m_flModelScale", 1.0);
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	ClearHorsemannParticles(client);

	TF2_RemoveAllWeapons(client);
	if (IsPlayerAlive(client))
		TF2_RegeneratePlayer(client);
}

public Action HHH_OnSoundHook(LastRequest lr, int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!strncmp(sample, "vo", 2, false))
		return Plugin_Handled;

	if (strncmp(sample, "player/footsteps/", 17, false) != -1)
	{
		if (StrContains(sample, "1.wav", false) != -1 || StrContains(sample, "3.wav", false) != -1) 
			sample = LEFTFOOT;
		else if (StrContains(sample, "2.wav", false) != -1 || StrContains(sample, "4.wav", false) != -1) 
			sample = RIGHTFOOT;
		EmitSoundToAll(sample, player.index);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock static void DoHorsemannParticles(const int client)
{
	int lefteye = MakeParticle(client, "halloween_boss_eye_glow", "lefteye");
	if (IsValidEntity(lefteye))
		iHHHParticle[client][0] = EntIndexToEntRef(lefteye);

	int righteye = MakeParticle(client, "halloween_boss_eye_glow", "righteye");
	if (IsValidEntity(righteye))
		iHHHParticle[client][1] = EntIndexToEntRef(righteye);
}

stock static void ClearHorsemannParticles(const int client)
{
	int ent;
	for (int i = 0; i < 3; i++)
	{
		ent = EntRefToEntIndex(iHHHParticle[client][i]);
		if (ent > MaxClients && IsValidEntity(ent))
			RemoveEntity(ent);
		iHHHParticle[client][i] = -1;
	}
}

public void HHH_OnPlayerDied(LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event)
{
	EmitSoundToAll(DEATHVO, victim.index);
	SetPawnTimer(UnHorsemann, 0.2, victim);
}

public void HHH_OnPlayerSpawned(LastRequest lr, const JBPlayer player)
{
	SetPawnTimer(MakeHorsemann, 0.1, player)
}

public void HHH_OnVariableReset(const JBPlayer player)
{
	ClearHorsemannParticles(player.index);
	SDKUnhook(player.index, SDKHook_GetMaxHealth, HHH_OnGetMaxHealth);
}

public void HHH_OnRoundEndPlayer(LastRequest lr, const JBPlayer player, Event event)
{
	ClearHorsemannParticles(player.index);
	SDKUnhook(player.index, SDKHook_GetMaxHealth, HHH_OnGetMaxHealth);
}

public Action HHH_OnGetMaxHealth(int client, int &health)
{
	health = 1500;
	return Plugin_Changed;
}

public Action HHH_OnPlayerPrepped(LastRequest lr, const JBPlayer player)
{
	return Plugin_Handled;
}