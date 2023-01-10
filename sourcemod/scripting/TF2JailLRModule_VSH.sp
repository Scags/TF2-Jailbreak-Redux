#include <sourcemod>
#include <sdkhooks>
#include <tf2items>
#include <morecolors>
#include <tf2_stocks>
#include <tf2attributes>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required

//#define USE_NEW_HALE_MODEL	// Un-comment this to use the Jungle Inferno Saxton Hale model (if you have it in your server)

#define RED 				2
#define BLU 				3

#include "TF2JailRedux/stocks.inc"

#define PLUGIN_VERSION		"1.3.0"

Handle
	hHudText, 
	// rageHUD, 
	// MusicCookie,
	jumpHUD
;

JBGameMode
	gamemode
;

char
	snd[PLATFORM_MAX_PATH],
	gameMessage[256]
;

methodmap JailBoss < JBPlayer
{	// Here we inherit all of the properties and functions that we made as natives
	public JailBoss( const int q )
	{
		return view_as< JailBoss >(q);
	}
	public static JailBoss OfUserId( const int id )
	{
		return view_as< JailBoss >(GetClientOfUserId(id));
	}
	public static JailBoss Of( const JBPlayer player )
	{
		return view_as< JailBoss >(player);
	}

	property int iUberTarget
	{	// And then add new ones that we need
		public get() 				{ return this.GetProp("iUberTarget"); }
		public set( const int i ) 	{ this.SetProp("iUberTarget", i); }
	}
	property int iHealth
	{
		public get() 				{ return this.GetProp("iHealth"); }
		public set( const int i ) 	{ this.SetProp("iHealth", i); }
	}
	property int iMaxHealth
	{
		public get() 				{ return this.GetProp("iMaxHealth"); }
		public set( const int i ) 	{ this.SetProp("iMaxHealth", i); }
	}
	property int iAirDamage
	{
		public get() 				{ return this.GetProp("iAirDamage"); }
		public set( const int i ) 	{ this.SetProp("iAirDamage", i); }
	}
	property int iType
	{
		public get() 				{ return this.GetProp("iType"); }
		public set( const int i ) 	{ this.SetProp("iType", i); }
	}
	property int iStabbed
	{
		public get() 				{ return this.GetProp("iStabbed"); }
		public set( const int i ) 	{ this.SetProp("iStabbed", i); }
	}
	property int iMarketted
	{
		public get() 				{ return this.GetProp("iMarketted"); }
		public set( const int i ) 	{ this.SetProp("iMarketted", i); }
	}
	property int iDamage
	{
		public get() 				{ return this.GetProp("iDamage"); }
		public set( const int i ) 	{ this.SetProp("iDamage", i); }
	}
	property int bGlow
	{
		public get()				{ return GetEntProp(this.index, Prop_Send, "m_bGlowEnabled"); }
		public set( int i )
		{
			Clamp(i, 0, 1);
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", i);
		}
	}
	property int iKills
	{
		public get() 				{ return this.GetProp("iKills"); }
		public set( const int i ) 	{ this.SetProp("iKills", i); }
	}
	property int iClimbs
	{
		public get() 				{ return this.GetProp("iClimbs"); }
		public set( const int i ) 	{ this.SetProp("iClimbs", i); }
	}

	property bool bIsBoss
	{
		public get() 				{ return this.GetProp("bIsBoss"); }
		public set( const bool i ) 	{ this.SetProp("bIsBoss", i); }
	}
	property bool bNeedsToGoBackToBlue
	{
		public get() 				{ return this.GetProp("bNeedsToGoBackToBlue"); }
		public set( const bool i ) 	{ this.SetProp("bNeedsToGoBackToBlue", i); }
	}

	property float flRAGE
	{
		public get() 				{ return this.GetProp("flRAGE"); }
		public set( const float i ) { this.SetProp("flRAGE", i); }
	}
	property float flWeighDown
	{
		public get() 				{ return this.GetProp("flWeighDown"); }
		public set( const float i ) { this.SetProp("flWeighDown", i); }
	}
	property float flGlowtime
	{
		public get()
		{
			float i = this.GetProp("flGlowtime");
			if (i < 0.0) i = 0.0;
			return i;
		}
		public set( const float i )	{ this.SetProp("flGlowtime", i); }
	}
	property float flCharge
	{
		public get() 				{ return this.GetProp("flCharge"); }
		public set( const float i ) { this.SetProp("flCharge", i); }
	}
	property float flKillSpree
	{
		public get() 				{ return this.GetProp("flKillSpree"); }
		public set( const float i ) { this.SetProp("flKillSpree", i); }
	}

	public void ConvertToBoss( const int bossid )
	{	// Happens directly on round start, given to a random player
		this.iType = bossid;	// I wanted to set up a queue system like regular VSH but meh effort
		this.bIsBoss = true;
		this.flRAGE = 0.0;
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}
	public void GiveRage( const int damage )
	{	// On player_hurt
		this.flRAGE += ( damage/SquareRoot(30000.0)*4.0 );
	}
	public void DoGenericStun( const float rageDist )
	{
		int i;
		float pos[3], pos2[3], distance;
		int client = this.index;
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		for( i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || i == client )
				continue;
			else if( GetClientTeam(i) == GetClientTeam(client) )
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if( !TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < rageDist ) {
				AttachParticle(i, "yikes_fx", 5.0, 75.0);
				TF2_StunPlayer(i, 5.0, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 ) 
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 5.0, 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_dispenser")) != -1 ) 
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_teleporter")) != -1 ) 
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
	}
	public void DoGenericThink( bool jump = false, bool sound = false, char[] strSound = "", int random = 0, bool mp3 = true )
	{
		if ( !IsPlayerAlive(this.index) )
			return;

		int client = this.index;

		int buttons = GetClientButtons(client);
		//float currtime = GetGameTime();
		int flags = GetEntityFlags(client);

		//int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		int health = this.iHealth;
		float speed = 340.0 + 0.7 * (100-health*100/this.iMaxHealth);
		SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);

		if (this.flGlowtime > 0.0) {
			this.bGlow = 1;
			this.flGlowtime -= 0.1;
		}
		else if (this.flGlowtime <= 0.0)
			this.bGlow = 0;

		if (OnlyScoutsLeft(RED))
			this.flRAGE += 0.25;

		if (jump)
		{
			if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) )
			{
				if (this.flCharge+2.5 < 25.0)
					this.flCharge += 1.25;
				else this.flCharge = 25.0;
			}
			else if (this.flCharge < 0.0)
				this.flCharge += 2.0;
			else {
				float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
				if ( this.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
					float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
					vel[2] = 750 + this.flCharge * 13.0;

					SetEntProp(client, Prop_Send, "m_bJumping", 1);
					vel[0] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
					vel[1] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
					this.flCharge = -100.0;
					if (sound)
					{
						float pos[3]; GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
						if (random)
							Format(snd, PLATFORM_MAX_PATH, "%s%d.%s", strSound, GetRandomInt(1, random), mp3 ? "mp3" : "wav");
						else strcopy(snd, PLATFORM_MAX_PATH, strSound);
						EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_DISHWASHER, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, pos, NULL_VECTOR, false, 0.0);
					}
				}
				else this.flCharge = 0.0;
			}
		}

		if ( flags & FL_ONGROUND )
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;

		if ( (buttons & IN_DUCK) && this.flWeighDown >= 3.0)
		{
			float ang[3]; GetClientEyeAngles(client, ang);
			if ( ang[0] > 60.0 ) {
				//float fVelocity[3];
				//GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
				//fVelocity[2] = -500.0;
				//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
				SetEntityGravity(client, 6.0);
				SetPawnTimer(SetGravityNormal, 1.0, this.userid);
				this.flWeighDown = 0.0;
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if (jmp > 0.0)
			jmp *= 4.0;
		if (this.flRAGE >= 100.0)
			ShowSyncHudText(client, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", (this.iType == 3 && jmp > 0.0) ? RoundFloat(jmp)/2 : RoundFloat(jmp));
		else ShowSyncHudText(client, hHudText, "Jump: %i | Rage: %0.1f", (this.iType == 3 && jmp > 0.0) ? RoundFloat(jmp)/2 : RoundFloat(jmp), this.flRAGE);
	}
};

public Plugin myinfo =
{
	name = "TF2Jail VSH LR Module",
	author = "Scag/Ragenewb, just about all probs to Nergal/Assyrian",
	description = "Versus Saxton Hale embedded as an LR for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

ConVar
	hTeamBansCVar,
	hNoChargeCVar,
	hDroppedWeaponsCVar
;

int
	iHealthChecks,		// For !halehp
	iTeamBansCVar,		// Mid-round detection in case a player is guardbanned
	iNoChargeCVar,		// Allow for charging
	iDroppedWeaponsCVar	// Allow dropped weapons
//	iHealthBar			// Healthbar
;

bool
	bDisabled = true	// Handling core late-loading
;

float
	flHealthTime		// For !halehp
;

JailBoss
	iCurrBoss			// The boss
;

LastRequest
	g_LR				// Me!
;

public void OnPluginStart()
{
	RegConsoleCmd("sm_hale_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_halehp", Command_GetHPCmd);
	RegConsoleCmd("sm_boss_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_bosshp", Command_GetHPCmd);
	RegConsoleCmd("sm_ff2_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_ff2hp", Command_GetHPCmd);

//	RegAdminCmd("sm_unregistervsh", Cmd_UnLoad, ADMFLAG_ROOT);
//	RegAdminCmd("sm_registervsh", Cmd_ReLoad, ADMFLAG_ROOT);

	AddCommandListener(BlockSuicide, "explode");
	AddCommandListener(BlockSuicide, "kill");
	AddCommandListener(BlockSuicide, "jointeam");
	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(cdVoiceMenu, "voicemenu");

	hHudText = CreateHudSynchronizer();
	// rageHUD = CreateHudSynchronizer();
	jumpHUD = CreateHudSynchronizer();

	LoadTranslations("tf2jail_redux.phrases");

	AddMultiTargetFilter("@boss", HaleTargetFilter, "The current Boss/Bosses", false);
	AddMultiTargetFilter("@hale", HaleTargetFilter, "The current Boss/Bosses", false);
	AddMultiTargetFilter("@!boss", HaleTargetFilter, "All non-Boss players", false);
	AddMultiTargetFilter("@!hale", HaleTargetFilter, "All non-Boss players", false);
}

public void InitSubPlugin()
{
	gamemode = new JBGameMode();

	g_LR = LastRequest.CreateFromConfig("Versus Saxton Hale");

	if (g_LR == null)		// If it's her first time, set the mood
	{
		g_LR = LastRequest.Create("Versus Saxton Hale");
		g_LR.SetDescription("Play a nice round of VSH");
		g_LR.SetAnnounceMessage("{default}{NAME}{burlywood} has selected {default}Versus Saxton Hale{burlywood} as their last request.");

		g_LR.SetParameterNum("Disabled", 0);
		g_LR.SetParameterNum("OpenCells", 1);
		g_LR.SetParameterNum("TimerStatus", 1);
		g_LR.SetParameterNum("TimerTime", 600);
		g_LR.SetParameterNum("LockWarden", 1);
		g_LR.SetParameterNum("UsesPerMap", 3);
		g_LR.SetParameterNum("IsWarday", 1);
		g_LR.SetParameterNum("NoMuting", 1);
		g_LR.SetParameterNum("DisableMedic", 1);
		g_LR.SetParameterNum("AllowBuilding", 1);
		g_LR.SetParameterNum("RegenerateReds", 0);	// Changing this does nothing in this mode
		g_LR.SetParameterNum("EnableCriticals", 0);
		g_LR.SetParameterNum("IgnoreRebels", 1);
		g_LR.SetParameterNum("VoidFreekills", 1);
		g_LR.SetParameterNum("AllowWeapons", 1);

		g_LR.SetPropertyNum("bOneGuardLeft", 1);

		// Custom config
		// It'd be cool if there was a way to add comments to kv cfg
		g_LR.SetParameterNum("DamagePoints", 600);			// Damage for points on the scoreboard
		g_LR.SetParameterFloat("MedigunReset", 0.31);		// Medigun reset %
		g_LR.SetParameterFloat("StopTickleTime", 3.0);		// Time after landing a mitten smack to reset laugh taunt
		g_LR.SetParameterNum("AirStrikeDamage", 200);		// Airstrike damage per kill gained
		g_LR.SetParameterFloat("AirblastRage", 8.0);		// Rage given when Hale is airblasted
		g_LR.SetParameterFloat("JarateRage", 8.0);			// Rage removed when Hale is jarated
		g_LR.SetParameterFloat("FanoWarRage", 5.0);			// Rage removed when Hale is FanoWar'd
		g_LR.SetParameterNum("EngieBuildings", 1);			// Engie building behavior on death, 0 = nothing; 1 = sentry dies; 2 = all buildings die
		g_LR.SetParameterNum("PermOverheal", 0);			// Allow permanent overheal
		g_LR.SetParameterNum("DemoShieldCrits", 1);			// Demo shield crit behavior, 0 = no crits; 1 = minicrits; 2 = full crits; 3 = scales with charge
		g_LR.SetParameterNum("Anchoring", 1);				// Allow Hale anchoring
		g_LR.SetParameterNum("AmmoSpawn", 4);				// Number of ammopacks to spawn on round start
		g_LR.SetParameterNum("HealthSpawn", 4);				// Number of healthpacks to spawn on round start
		g_LR.SetParameterNum("HealthBar", 1);				// Enable the boss health bar

		g_LR.ExportToConfig(.create = true, .createonly = true);
	}
	hTeamBansCVar = FindConVar("sm_jbans_ignore_midround");
	hNoChargeCVar = FindConVar("sm_tf2jr_demo_charge");
	hDroppedWeaponsCVar = FindConVar("sm_tf2jr_dropped_weapons");

	LoadJBHooks();
}

public void OnPluginEnd()
{
	if (LibraryExists("TF2Jail_Redux"))
	{
		if (g_LR != null)
		{
			g_LR.Destroy();
			g_LR = null;
		}
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{
		bDisabled = true;
		g_LR.Destroy();
		g_LR = null;
	}
	else if (!strcmp(name, "TF2JailRedux_TeamBans", false))
		hTeamBansCVar = null;
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false) && bDisabled)
	{
		InitSubPlugin();
		bDisabled = false;
	}
	else if (!strcmp(name, "TF2JailRedux_TeamBans", false))
		hTeamBansCVar = FindConVar("sm_jbans_ignore_midround");
}

#define NOTVSH 				( g_LR == null || g_LR.GetID() != gamemode.iLRType )

public bool HaleTargetFilter(const char[] pattern, ArrayList clients)
{
	if (NOTVSH)
		return false;	// What am I supposed to return here?

	bool non = StrContains(pattern, "!", false) != - 1;
	for (int i = MaxClients; i; --i) 
	{
		if (IsClientInGame(i) && clients.FindValue(i) == - 1)
		{
			if (JailBoss(i).bIsBoss) 
			{
				if (!non)
					clients.Push(i);
			}
			else if (non)
				clients.Push(i);
		}
	}
	return true;
}

public void fwdOnClientInduction(LastRequest lr, const JBPlayer Player)
{
	JailBoss player = JailBoss.Of(Player);
	player.bIsBoss = false;
	player.bNeedsToGoBackToBlue = false;
	player.iType = -1;
	player.iStabbed = 0;
	player.iMarketted = 0;
	player.flRAGE = 0.0;
	player.iDamage = 0;
	player.iAirDamage = 0;
	player.iUberTarget = 0;
	player.flCharge = 0.0;
	player.bGlow = 0;
	player.flGlowtime = 0.0;
	player.iHealth = 0;
	player.iMaxHealth = 0;
}

public Action BlockSuicide(int client, const char[] command, int argc)
{
	if (NOTVSH)
		return Plugin_Continue;

	JailBoss player = JailBoss(client);
	if (player.bIsBoss) 
	{
		float flhp_percent = float(player.iHealth) / float(player.iMaxHealth);
		if (flhp_percent > 0.30) 
		{  // Allow bosses to suicide if their total health is under 30%.
			CPrintToChat(client, "{salmon}Nope.avi, you have to play.");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (JailBoss(client).bIsBoss && gamemode.iRoundState >= StateRunning)
		CPrintToChatAll("%t {red}Boss has disconnected!", "Plugin Tag");
}

public void OnMapStart()
{
	CreateTimer(5.0, MakeModelTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);	// Model isn't always set OnPlayerSpawned() so this'll do under certain circumstances
}

public Action MakeModelTimer(Handle hTimer)
{
	if (NOTVSH)
		return Plugin_Continue;

	JailBoss player;
	for (int i = MaxClients; i; --i) 
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;
		player = JailBoss(i);
		if (!player.bIsBoss) 
			continue;
		ManageBossModels(player);
	}
	return Plugin_Continue;
}

public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if (IsClientValid(i))
		SetEntityGravity(i, 1.0);
}

public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{	// Boss help panel
	return;
}

public void _MakePlayerBoss(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client)) 
	{
		JailBoss player = JailBoss(client);
		ManageBossTransition(player);
	}
}

public void OnPreThinkPost(int client)
{
	if (NOTVSH)
		return;

	if (IsClientObserver(client) || !IsPlayerAlive(client))
		return;
	
	if (IsNearSpencer(client)) 
	{
		if (TF2_IsPlayerInCondition(client, TFCond_Cloaked)) 
		{
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
			if (cloak < 0.0)
				cloak = 0.0;
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
	return;
}

public Action EraseEntity(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		RemoveEntity(ent);
	return Plugin_Continue;
}

public void RemoveEnt(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
}

public Action cdVoiceMenu(int client, const char[] command, int argc)
{
	if (NOTVSH)
		return Plugin_Continue;
	if (argc < 2 || !IsPlayerAlive(client))
		return Plugin_Handled;
	
	char szCmd1[8]; GetCmdArg(1, szCmd1, sizeof(szCmd1));
	char szCmd2[8]; GetCmdArg(2, szCmd2, sizeof(szCmd2));
	
	// Capture call for medic commands (represented by "voicemenu 0 0")
	JailBoss player = JailBoss(client);
	if (szCmd1[0] == '0' && szCmd2[0] == '0' && player.bIsBoss)
		ManageBossMedicCall(player);
	
	return Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
	if (NOTVSH)
		return Plugin_Continue;
	
	JailBoss player = JailBoss(client);
	if (player.flRAGE >= 100.0) 
	{
		ManageBossTaunt(player);
		player.flRAGE = 0.0;
	}
	return Plugin_Continue;
}

public Action fwdOnEntCreated(int entity, const char[] classname)
{
	if (NOTVSH)
		return Plugin_Continue;
	
	if (!strcmp(classname, "tf_projectile_pipe", false))
		SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
	else if (!strcmp(classname, "tf_ammo_pack", false))	// Let people have ammo
		return Plugin_Handled;

	return Plugin_Continue;
}

stock void SpawnRandomAmmo()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int limit = g_LR.GetParameterNum("AmmoSpawn", 0);
	if (!limit)
		return;

	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( spawned >= limit )
			break;
		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int ammo = CreateEntityByName("item_ammopack_small");
		TeleportEntity(ammo, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(ammo);
		SetEntProp(ammo, Prop_Send, "m_iTeamNum", 2, 4);
		++spawned;
	}
}
stock void SpawnRandomHealth()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int limit = g_LR.GetParameterNum("HealthSpawn", 0);
	if (!limit)
		return;

	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( spawned >= limit )
			break;
		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int healthkit = CreateEntityByName("item_healthkit_small");
		TeleportEntity(healthkit, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(healthkit);
		SetEntProp(healthkit, Prop_Send, "m_iTeamNum", 2, 4);
		++spawned;
	}
}

public void ShowPlayerScores()
{
	JailBoss hTop[3];
	
	JailBoss(0).iDamage = 0;
	JailBoss player;

	int fraction = g_LR.GetPropertyNum("DamagePoints", 1);
	int i;
	int totaldamage;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetClientTeam(i) < RED)
			continue;
		
		player = JailBoss(i);
		if (player.bIsBoss)
		{
			player.iDamage = 0;
			continue;
		}
		
		if (player.iDamage >= hTop[0].iDamage)
		{
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = player;
		}
		else if (player.iDamage >= hTop[1].iDamage)
		{
			hTop[2] = hTop[1];
			hTop[1] = player;
		}
		else if (player.iDamage >= hTop[2].iDamage)
			hTop[2] = player;

		totaldamage += player.iDamage;
	}
	if (hTop[0].iDamage > 9000)
		SetPawnTimer(OverNineThousand, 1.0);

	SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	PrintCenterTextAll(""); // Should clear center text
	char names[3][32];
	for (i = 0; i < 3; ++i)
		if (hTop[i].index && hTop[i].iDamage > 0)
			GetClientName(hTop[i].index, names[i], 32);
		else names[i] = "NaN";

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (!(GetClientButtons(i) & IN_SCORE))
			ShowHudText(i, -1, "Most damage dealt by:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i\nScore for this round: %i", hTop[0].iDamage, names[0], hTop[1].iDamage, names[1], hTop[2].iDamage, names[2], player.iDamage, (player.iDamage / fraction));
	}
}

public void CalcScores()
{
	int j, damage, amount = g_LR.GetParameterNum("DamagePoints", 0);
	JailBoss player;
	Event scoring;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (GetClientTeam(i) < RED)
			continue;
		
		player = JailBoss(i);
		if (player.bIsBoss)
		{
			player.iDamage = 0;
			continue;
		}
	
		scoring = CreateEvent("player_escort_score", true);	
		damage = player.iDamage;
		scoring.SetInt("player", i);
		for (j = 0; damage - amount > 0; damage -= amount, j++) {  }
		scoring.SetInt("points", j);
		scoring.Fire();
		CPrintToChat(i, "%t You scored %i point%s.", "Plugin Tag", j, j == 1 ? "" : "s");
	}
}

public void _NoHonorBound(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client) && IsPlayerAlive(client)) 
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[32];
		if ( IsValidEdict(active) )
			GetEdictClassname(active, classname, sizeof(classname));
		if ( index == 357 && active == weapon && !strcmp(classname, "tf_weapon_katana", false) )
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
}

public void _StopTickle(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
		TF2_RemoveCondition(client, TFCond_Taunting);
}

public void _ResetMediCharge(const int entid)
{
	int medigun = EntRefToEntIndex(entid);
	if (medigun > MaxClients && IsValidEntity(medigun))
		SetMediCharge(medigun, GetMediCharge(medigun) + g_LR.GetParameterFloat("MedigunReset", 0.0));
}

public void _BossDeath(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsClientValid(client)) 
	{
		JailBoss player = JailBoss(client);
		player.iHealth = 0;
		ManageBossDeath(player);
	}
}

public Action TimerLazor(Handle timer, any medigunid)
{	// All mediguns give uber + crits (and crits to the medic)
	int medigun = EntRefToEntIndex(medigunid);
	if (medigun && IsValidEntity(medigun) && gamemode.iRoundState == StateRunning)
	{
		int client = GetOwner(medigun);
		float charge = GetMediCharge(medigun);
		if (charge > 0.05) 
		{
			TF2_AddCondition(client, TFCond_CritOnWin, 0.5);
			
			int target = GetHealingTarget(client);
			if (IsClientValid(target) && IsPlayerAlive(target))
			{
				TF2_AddCondition(target, TFCond_CritOnWin, 0.5);
				JailBoss(client).iUberTarget = GetClientUserId(target);
			}
			else JailBoss(client).iUberTarget = 0;
		}
		else if (charge < 0.05) 
		{
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}

public void MakePlayerBoss(const int userid, int iBossid)
{
	JailBoss player = JailBoss.OfUserId(userid);
	player.iType = iBossid;
	player.flRAGE = 0.0;
	ManageBossTransition(player);
}

public void NoAttacking(const int wepref)
{
	int weapon = EntRefToEntIndex(wepref);
	SetNextAttack(weapon, 1.56);
}

/********************************************************************
						COMMANDS
********************************************************************/

public Action Command_GetHPCmd(int client, int args)
{
	if (NOTVSH)
		return Plugin_Handled;
	
	JailBoss player = JailBoss(client);
	ManageBossCheckHealth(player);

	return Plugin_Handled;
}

#if 0
/**
 *	Purpose: Disable the plugin without unloading it.
 *	This is more for testing, but technical users can use this to their advantage.
 *	VSH will not re-register unless you reload the plugin manually or sm_registervsh.
*/
public Action Cmd_UnLoad(int client, int args)
{
	if (g_LR != null)
	{
		OnLibraryRemoved("TF2Jail_Redux");
		CReplyToCommand(client, "%t Versus Saxton Hale has been successfully unregistered.", "Admin Tag");
	}
	else CReplyToCommand(client, "%t Versus Saxton Hale was not unregistered. Was it registered to begin with?", "Admin Tag");

	return Plugin_Handled;
}

public Action Cmd_ReLoad(int client, int args)
{
	if (g_LR != null)
	{
		CReplyToCommand(client, "%t Versus Saxton Hale is already registered.", "Admin Tag");
		return Plugin_Handled;
	}

	OnLibraryAdded("TF2Jail_Redux");
	CReplyToCommand(client, "%t Versus Saxton Hale has been re-registered.", "Admin Tag");
	return Plugin_Handled;
}
#endif

/********************************************************************
						FUNCTIONS
********************************************************************/
// From VSH2... along with everything else in this sub-plugin
enum/* Bosses *//* When you add custom Bosses, add to the anonymous enum as the Boss' ID */
{
	Hale = 0, 
	Vagineer = 1, 
	CBS = 2, 
	HHHjr = 3, 
	Bunny = 4, 
};

#include "LRModVSH/bosses.sp"

#define MAXBOSS		Bunny 		// When adding new bosses, increase the MAXBOSS define for the newest boss id


public void ManageBossModels(const JailBoss base)
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:ToCHale(base).SetModel();
		case Vagineer:ToCVagineer(base).SetModel();
		case CBS:ToCChristian(base).SetModel();
		case HHHjr:ToCHHHJr(base).SetModel();
		case Bunny:ToCBunny(base).SetModel();
	}
}

public void ManagePlayBossIntro(const JailBoss base)
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).PlaySpawnClip();
		case Vagineer:ToCVagineer(base).PlaySpawnClip();
		case CBS:ToCChristian(base).PlaySpawnClip();
		case HHHjr:ToCHHHJr(base).PlaySpawnClip();
		case Bunny:ToCBunny(base).PlaySpawnClip();
	}
}

public void ManageRoundEndBossInfo(bool bossWon)
{
	char victory[PLATFORM_MAX_PATH];
	gameMessage[0] = '\0';
	int i;
	if (!IsClientValid(iCurrBoss.index))
		return;

	switch (iCurrBoss.iType) 
	{
		case Vagineer:Format(gameMessage, 256, "\nThe Vagineer (%N) had %i (of %i) health left.", iCurrBoss.index, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
		case HHHjr:Format(gameMessage, 256, "\nThe Horseless Headless Horsemann Jr. (%N) had %i (of %i) health left.", iCurrBoss.index, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
		case CBS:Format(gameMessage, 256, "\nThe Christian Brutal Sniper (%N) had %i (of %i) health left.", iCurrBoss.index, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
		case Bunny:Format(gameMessage, 256, "\nThe Easter Bunny (%N) had %i (of %i) health left.", iCurrBoss.index, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
		case Hale:Format(gameMessage, 256, "\nSaxton Hale (%N) had %i (of %i) health left.", iCurrBoss.index, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
	}
	if (bossWon) 
	{
		victory[0] = '\0';
		switch (iCurrBoss.iType) 
		{
			case  - 1: {  }
			case Vagineer:Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			case Bunny:strcopy(victory, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin) - 1)]);
			case Hale:Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
		}
		if (victory[0] != '\0')
			EmitSoundToAll(victory);
	}

	if (gameMessage[0] !='\0') 
	{
		CPrintToChatAll("%t %s", "Plugin Tag", gameMessage[1]);
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for (i = MaxClients; i; --i) 
			if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
				ShowHudText(i, -1, "%s", gameMessage);
	}
}

public void ManageBossEquipment(const JailBoss base)
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Equip();
		case Vagineer:ToCVagineer(base).Equip();
		case CBS:ToCChristian(base).Equip();
		case HHHjr:ToCHHHJr(base).Equip();
		case Bunny:ToCBunny(base).Equip();
	}
}

public void ManageBossMedicCall(const JailBoss base)
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale, Vagineer, CBS, HHHjr, Bunny:
		{
			if (base.flRAGE < 100.0)
				return;
			DoTaunt(base.index, "", 0);
		}
	}
}

public void ManageBossTaunt(const JailBoss base)
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:ToCHale(base).RageAbility();
		case Vagineer:ToCVagineer(base).RageAbility();
		case CBS:ToCChristian(base).RageAbility();
		case HHHjr:ToCHHHJr(base).RageAbility();
		case Bunny:ToCBunny(base).RageAbility();
	}
}

public void ManagePlayerJarated(const JailBoss attacker, const JailBoss victim)
{
	switch (victim.iType) 
	{
		case  - 1: {  }
		case Hale, Vagineer, CBS, HHHjr, Bunny:
		victim.flRAGE -= g_LR.GetParameterFloat("JarateRage", 0.0);
	}
}

public void ManageBossDeath(const JailBoss base)
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Death();
		case Vagineer:ToCVagineer(base).Death();
		case CBS:ToCChristian(base).Death();
		case HHHjr:ToCHHHJr(base).Death();
		case Bunny:ToCBunny(base).Death();
	}
}

public void OnEggBombSpawned(int entity)
{
	int owner = GetOwner(entity);
	JailBoss boss = JailBoss(owner);
	if (IsClientValid(owner) && boss.bIsBoss && boss.iType == Bunny)
		CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

public void UpdateBossHealth()
{
	if (IsValidEntity(iHealthBar))
	{
		int pct = RoundToCeil(float(iCurrBoss.iHealth)/float(iCurrBoss.iMaxHealth)*255.0);
		Clamp(pct, 0, 255);
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", pct);
	}
}

public void ManageBossTransition(const JailBoss base)/* whatever stuff needs initializing should be done here */
{
	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:
		TF2_SetPlayerClass(base.index, TFClass_Soldier, _, false);
		case Vagineer:
		TF2_SetPlayerClass(base.index, TFClass_Engineer, _, false);
		case CBS:
		TF2_SetPlayerClass(base.index, TFClass_Sniper, _, false);
		case HHHjr, Bunny:
		TF2_SetPlayerClass(base.index, TFClass_DemoMan, _, false);
	}
	ManageBossModels(base);
	switch (base.iType) 
	{
		case  - 1: {  }
		case HHHjr:ToCHHHJr(base).flCharge = -1000.0;
	}
	ManageBossEquipment(base);
}

public Action ManageOnBossTakeDamage(const JailBoss victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	switch (victim.iType) 
	{
		case  - 1: {  }
		case Hale, Vagineer, CBS, HHHjr, Bunny: 
		{
			char trigger[32];
			if (GetEdictClassname(attacker, trigger, sizeof(trigger)) && !strcmp(trigger, "trigger_hurt", false))
			{
				if (damage >= 100.0)
				{
					if (gamemode.bWardayTeleportSetBlue)
						victim.TeleportToPosition(WBLU);
					else TeleportToSpawn(victim.index, BLU);
					victim.iHealth -= (damage > 1000.0 ? 1000 : RoundToFloor(damage));
				}
			}
			if (attacker <= 0 || attacker > MaxClients)
				return Plugin_Continue;
			
			char classname[64], strEntname[32];
			if (IsValidEdict(inflictor))
				GetEntityClassname(inflictor, strEntname, sizeof(strEntname));
			if (IsValidEdict(weapon))
				GetEdictClassname(weapon, classname, sizeof(classname));

			int weap = GetPlayerWeaponSlot(victim.index, TFWeaponSlot_Melee);
			int index = GetItemIndex(weap);
			int active = GetEntPropEnt(victim.index, Prop_Send, "m_hActiveWeapon");
			
			int wepindex = GetItemIndex(weapon);
			if (damagecustom == TF_CUSTOM_BACKSTAB || (!strcmp(classname, "tf_weapon_knife", false) && damage > victim.iHealth))
				// Bosses shouldn't die from a single backstab
			{
				switch (victim.iType) 
				{
					case Hale:Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
					case Vagineer:strcopy(snd, PLATFORM_MAX_PATH, "vo/engineer_positivevocalization01.mp3");
					case HHHjr:Format(snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_pain0%d.mp3", GetRandomInt(1, 3));
					case Bunny:strcopy(snd, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain) - 1)]);
				}
				EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				
				float changedamage = ((Pow(float(victim.iMaxHealth) * 0.0014, 2.0) + 899.0) - (float(victim.iMaxHealth) * (float(victim.iStabbed) / 100)));
				if (victim.iStabbed < 4)
					victim.iStabbed++;
				damage = changedamage / 3; // You can level "damage dealt" with backstabs
				damagetype |= DMG_CRIT;
				
				EmitSoundToAll("player/spy_shield_break.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				EmitSoundToAll("player/crit_received3.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				float curtime = GetGameTime();
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime + 1.0);
				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 1.5);
				TF2_AddCondition(attacker, TFCond_Ubercharged, 2.0);
				int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if (vm > MaxClients && IsValidEntity(vm) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int anim = 15;
					switch (melee) 
					{
						case 727:anim = 41;
						case 4, 194, 665, 794, 803, 883, 892, 901, 910:anim = 10;
						case 638:anim = 31;
					}
					SetEntProp(vm, Prop_Send, "m_nSequence", anim);
				}
				PrintCenterText(attacker, "You Tickled The Boss!");
				PrintCenterText(victim.index, "You Were Just Backstabbed!");
				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);
				if (pistol == 525) 
				{  //Diamondback gives 2 crits on backstab
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits + 2);
				}
				if (wepindex == 356) 
				{
					int health = GetClientHealth(attacker) + 180;
					if (health > 195)
						health = 300;
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				}
				if (wepindex == 461) //Big Earner gives full cloak on backstab
					SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);
				
				return Plugin_Changed;
			}
			if (damagecustom == TF_CUSTOM_TELEFRAG) 
			{
				damage = victim.iHealth + 0.2;
				return Plugin_Changed;
			}
			if (damagecustom == TF_CUSTOM_TAUNT_BARBARIAN_SWING) // Gives 4 heads if successful sword killtaunt!
			{
				for (int i = 0; i < 4; ++i)
					IncrementHeadCount(attacker);
			}
			if (damagecustom == TF_CUSTOM_BOOTS_STOMP && IsValidEntity(FindPlayerBack(attacker, { 405, 444, 608 }, 3)))
			{
				damage = 1024.0;
				return Plugin_Changed;
			}
			if (!strcmp(classname, "tf_weapon_shotgun_hwg", false))
			{
				int health = GetClientHealth(attacker);
				int newHealth;
				int maxhp = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
				if (health < RoundFloat(maxhp * 1.5)) 
				{
					newHealth = RoundFloat(damage + health);
					if (damage + health > RoundFloat(maxhp * 1.5))
						newHealth = RoundFloat(maxhp * 1.5);
					SetEntityHealth(attacker, newHealth);
				}
			}
			if (g_LR.GetParameterNum("Anchoring", 0))
			{
				int iFlags = GetEntityFlags(victim.index);
				// If Hale is ducking on the ground, it's harder to knock him back
				if ((iFlags & (FL_ONGROUND | FL_DUCKING)) == (FL_ONGROUND | FL_DUCKING))
					TF2Attrib_SetByDefIndex(victim.index, 252, 0.0);						
				else TF2Attrib_RemoveByDefIndex(victim.index, 252);
			}

			switch (wepindex) 
			{
				case 593: //Third Degree
				{
					int healers[MAXPLAYERS];
					int healercount = 0;
					for (int i = MaxClients; i; --i) 
					{
						if (IsClientInGame(i) && IsPlayerAlive(i) && GetHealingTarget(i) == attacker)
						{
							healers[healercount] = i;
							healercount++;
						}
					}
					for (int i = 0; i < healercount; i++) 
					{
						if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
						{
							int medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
							if (IsValidEntity(medigun)) 
							{
								char cls[32];
								GetEdictClassname(medigun, cls, sizeof(cls));
								if (!strcmp(cls, "tf_weapon_medigun", false)) 
								{
									float uber = GetMediCharge(medigun) + (0.1 / healercount);
									float max = 1.0;
									if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
										max = 1.5;
									if (uber > max)
										uber = max;
									SetMediCharge(medigun, uber);
								}
							}
						}
					}
				}
				case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154, 30665:
				{
					switch (wepindex) //cleaner to read than if wepindex == || wepindex == || etc
					{
						case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154:
						{

							float bossGlow = victim.flGlowtime;
							float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
							float time = (bossGlow > 10 ? 1.0 : 2.0);
							time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4) * (chargelevel / 100);
							bossGlow += RoundToCeil(time);
							if (bossGlow > 30.0)
								bossGlow = 30.0;
							victim.flGlowtime = bossGlow;
						}
					}
					if (wepindex == 402) 
					{
						if (damagecustom == TF_CUSTOM_HEADSHOT)
							IncrementHeadCount(attacker, false);
					}
					if (wepindex == 752)
					{
						float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						float add = 10 + (chargelevel / 10);
						if (TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)))
							add /= 3;
						float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
						SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
					}
					if (!(damagetype & DMG_CRIT)) 
					{
						bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
						
						damage *= (ministatus) ? 2.222222 : 3.0;
						if (wepindex == 230) 
							victim.flRAGE -= (damage * 0.0);
						return Plugin_Changed;
					}
					else if (wepindex == 230)
						victim.flRAGE -= (damage * 0.0);
				}
				case 132, 266, 482, 1082:IncrementHeadCount(attacker);
				case 355:victim.flRAGE -= g_LR.GetParameterFloat("FanoWarRage", 0.0);
				case 317, 327:SpawnSmallHealthPackAt(attacker, GetClientTeam(attacker));
				case 416, 609: // Chdata's Market Gardener backstab
				{
					if (JailBoss(attacker).bInJump)
					{
						damage = (Pow(float(victim.iMaxHealth), (0.74074))/*512.0*/-(victim.iMarketted / 128 * float(victim.iMaxHealth))) / (wepindex == 416 ? 3.0 : 2.5);
						//divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;
						
						if (victim.iMarketted < 5)
							victim.iMarketted++;
						
						PrintCenterText(attacker, "You %s Gardened the Boss!", (wepindex == 416 ? "Market" : "Sticky"));
						PrintCenterText(victim.index, "You Were Just %s Gardened!", (wepindex == 416 ? "Market" : "Sticky"));
						
						EmitSoundToAll("player/doubledonk.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
						
						if (TF2_IsPlayerInCondition(attacker, TFCond_Parachute))
						{
							damage *= 0.67;
							TF2_RemoveCondition(attacker, TFCond_Parachute);
						}
						return Plugin_Changed;
					}
				}
				case 154, 214, 310:
				{
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health + 25;
					if (health < max + 50) 
					{
						if (newhealth > max + 50)
							newhealth = max + 50;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				case 357:
				{
					SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
					if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
						SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health + 35;
					if (TF2_GetPlayerClass(attacker) == TFClass_Soldier) 
					{
						if (health < max + 25) 
						{
							if (newhealth > max + 25)
							{ newhealth = max + 25; }
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
					}
					else if (TF2_GetPlayerClass(attacker) == TFClass_DemoMan) 
					{	// Because Demoman obviously needs more methods of damage in VSH
						if (health < max + 100) 
						{
							if (newhealth > max + 100)
							{ newhealth = max + 100; }
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						TF2_RemoveCondition(attacker, TFCond_OnFire);
					if (index == 357 && active == weap) 
					{
						damage = 195.0;
						return Plugin_Changed;
					}
				}
				case 61, 1006: // Ambassador does 2.5x damage on headshot
				{
					if (damagecustom == TF_CUSTOM_HEADSHOT)
					{
						damage *= 2.5; 
						return Plugin_Changed;
					}
				}
//				case 751: // Cleaner's Carbine does 2.5x damage on headshot
//				{
//					if (damagecustom == TF_CUSTOM_HEADSHOT)
//					{
//						damage = 27.0;
//						damagetype |= DMG_CRIT;
//						return Plugin_Changed;
//					}
//				}
				case 525, 595:
				{
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if (iCrits) 
					{  // If a revenge crit was used, give a damage bonus
						damage = 85.0;
						return Plugin_Changed;
					}
				}
				case 656:
				{	// Holiday Punch
					SetPawnTimer(_StopTickle, g_LR.GetParameterFloat("StopTickleTime", 0.0), victim.userid);
					if (TF2_IsPlayerInCondition(attacker, TFCond_Dazed))
						TF2_RemoveCondition(attacker, TFCond_Dazed);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action ManageOnBossDealDamage(const JailBoss victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	JailBoss fighter = JailBoss(attacker);
	switch (fighter.iType) 
	{
		case  -1: {  }
		case Hale, Vagineer, CBS, HHHjr, Bunny: 
		{
			if (damagetype & DMG_CRIT)
				damagetype &= ~DMG_CRIT;
			
			int client = victim.index;
			
			if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
			{	// Hale stomps should do a fair bit of damage, but shouldn't always insta-kill classes
				float flFallVelocity = GetEntPropFloat(inflictor, Prop_Send, "m_flFallVelocity");
				damage = 10.0 * (GetRandomFloat(0.8, 1.2) * (5.0 * (flFallVelocity / 300.0)));
				return Plugin_Changed;
			}
			
			if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{	// Buff Banner
				ScaleVector(damageForce, 9.0);
				damage *= 0.3;
				return Plugin_Changed;
			}
			if (TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
			{	// Phlog obv
				damage *= 0.25;
				return Plugin_Changed;
			}
			
			int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if (IsValidEdict(medigun)
				 && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname))
				 && !strcmp(mediclassname, "tf_weapon_medigun", false)
				 && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				 && weapon == GetPlayerWeaponSlot(attacker, 2)) 
			{

				if (GetMediCharge(medigun) >= 0.90) 
				{
					SetMediCharge(medigun, 0.5);
					damage *= 10;
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					return Plugin_Changed;
				}
			}
			if (TF2_GetPlayerClass(client) == TFClass_Spy) // Eggs probably do melee damage to spies, then? That's not ideal, but eh.
			{
				float numerator;
				float denominator;
				if (GetEntProp(client, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
				{
					static ConVar feigndmg;
					if (!feigndmg)
						feigndmg = FindConVar("tf_feign_death_activate_damage_scale");

					numerator = 62.0;
					denominator = feigndmg.FloatValue;
				}
				if (TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
				{
					static ConVar drdmg;
					if (!drdmg)
						drdmg = FindConVar("tf_feign_death_damage_scale");

					numerator = 62.0;
					denominator = drdmg.FloatValue;
				}
				if (TF2_IsPlayerInCondition(client, TFCond_Cloaked))
				{
					static ConVar cloakdmg;
					if (!cloakdmg)
						cloakdmg = FindConVar("tf_stealth_damage_reduction");

					numerator = 69.0;
					damage = cloakdmg.FloatValue;
				}

				if (numerator != 0.0 && denominator != 0.0)
				{
					damage = numerator/denominator;
					damagetype &= ~DMG_CRIT;
					return Plugin_Changed;
				}
			}
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
			{
				if (GetOwner(ent) == client
					//&& damage >= float(GetClientHealth(client))
					&& !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
					&& !GetEntProp(ent, Prop_Send, "m_bDisguiseWearable")
					&& weapon == GetPlayerWeaponSlot(attacker, 2))
				{
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					TF2_RemoveWearable(client, ent);
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					break;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle & hItem)
{
	if (NOTVSH)
		return Plugin_Continue;
	
	Handle hItemOverride = null;
	switch (iItemDefinitionIndex) 
	{
		case 59: // Dead ringer
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "35 ; 2.0 ; 729 ; 0.0");
		}
		case 1103: // Backscatter
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1.0");
		}
		case 40, 1146: // Backburner
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1.0");
		}
		case 220: // Shortstop
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "525 ; 1 ; 526 ; 1.2 ; 533 ; 1.4 ; 534 ; 1.4 ; 328 ; 1 ; 241 ; 1.5 ; 78 ; 1.389 ; 97 ; 0.75", true);
		}
		case 349: // Sun on a stick
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "134 ; 13 ; 208 ; 1");
		}
		/*case 444: //Mantreads
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "275 ; 1.0");
		}*/
		case 648: // Wrap assassin
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 3.0 ; 208 ; 1.0");
		}
		/*case 224: //Letranger
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);
		}*/
		case 225, 574: //YER
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");
		}
		case 226: // The Battalion's Backup
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25");
		}
		case 305, 1079: // Medic Xbow
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.15 ; 2 ; 1.45"); // ; 266 ; 1.0");
		}
		case 56, 1005, 1092: // Huntsman
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 2.0 ; 2 ; 1.5");
		}
		case 239, 1084, 1100: // GRU
		{
			hItemOverride = PrepareItemHandle(hItem, _, iItemDefinitionIndex, "107 ; 1.5 ; 1 ; 0.5 ; 128 ; 1 ; 206 ; 2.0 ; 772 ; 1.5", true);
		}
		case 415: // Reserve shooter
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 114 ; 1.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66", true);
		}
		case 405, 608: // Demo boots have falling stomp damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "259 ; 1 ; 252 ; 0.25");
		}
		case 36, 412: // Blutsauger and Overdose
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.01");
		}
		case 772: // Baby Face Blaster
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "106 ; 0.3 ; 4 ; 1.33 ; 45 ; 0.6 ; 114 ; 1.0", true);
		}
		case 609: // Sticky gardener
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "267 ; 1");
		}
	}
	if (hItemOverride != null) {
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	
	TFClassType iClass = TF2_GetPlayerClass(client);
	
	if (!strncmp(classname, "tf_weapon_rocketlauncher", 24, false) || !strncmp(classname, "tf_weapon_particle_cannon", 25, false))
	{
		switch (iItemDefinitionIndex) {
			case 127:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 179 ; 1.0");
			case 414:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 99 ; 1.25");
			case 1104:hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 1.25 ; 114 ; 1.0");
			//case 730:hItemOverride = PrepareItemHandle(hItem, _, _, "394 ; 0.1 ; 241 ; 1.3 ; 3 ; 0.75 ; 411 ; 5 ; 6 ; 0.2 ; 642 ; 1 ; 413 ; 1 ; 109 ; 0.40", true);
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
		}
	}
	if (!strncmp(classname, "tf_weapon_grenadelauncher", 25, false) || !strncmp(classname, "tf_weapon_cannon", 16, false))
	{
		switch (iItemDefinitionIndex) {
			// loch n load
			case 308:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 208 ; 1.0");
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 128 ; 1 ; 135 ; 0.5");
		}
	}
	/*if (!strncmp(classname, "tf_weapon_sword", 15, false))
	{
		hItemOverride = PrepareItemHandle(hItem, _, _, "178 ; 0.8");
	}*/
	if (!strncmp(classname, "tf_weapon_shotgun", 17, false) || !strncmp(classname, "tf_weapon_sentry_revenge", 24, false))
	{
		switch (iClass) {
			case TFClass_Soldier:
			hItemOverride = PrepareItemHandle(hItem, _, _, "135 ; 0.6 ; 114 ; 1.0");
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
		}
		//hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
	}
	if (!strncmp(classname, "tf_weapon_wrench", 16, false) || !strncmp(classname, "tf_weapon_robot_arm", 19, false))
	{
		if (iItemDefinitionIndex == 142)
			hItemOverride = PrepareItemHandle(hItem, _, _, "26 ; 55");
		else hItemOverride = PrepareItemHandle(hItem, _, _, "26 ; 25");
	}
	if (!strncmp(classname, "tf_weapon_minigun", 17, false))
	{
		switch (iItemDefinitionIndex) {
			case 41: // Natascha
			hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 1.5", true);
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "233 ; 1.25");
		}
	}
	if (hItemOverride != null) {
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void fwdOnLastPrisoner()
{
	if (NOTVSH)
		return;

	if (IsClientValid(iCurrBoss.index) && iCurrBoss.bIsBoss)
	{
		switch (iCurrBoss.iType)
		{
			case  - 1: {  }
			case Hale:ToCHale(iCurrBoss).LastPlayerSoundClip();
			case Vagineer:ToCVagineer(iCurrBoss).LastPlayerSoundClip();
			case CBS:ToCChristian(iCurrBoss).LastPlayerSoundClip();
			case Bunny:ToCBunny(iCurrBoss).LastPlayerSoundClip();
		}
	}
}

public void ManageUberDeploy(const JailBoss medic, const JailBoss patient)
{
	int medigun = GetPlayerWeaponSlot(medic.index, TFWeaponSlot_Secondary);
	if (IsValidEntity(medigun)) 
	{
		char strMedigun[32]; GetEdictClassname(medigun, strMedigun, sizeof(strMedigun));
		if (!strcmp(strMedigun, "tf_weapon_medigun", false))
		{
			SetMediCharge(medigun, 1.51);
			TF2_AddCondition(medic.index, TFCond_CritOnWin, 0.5, medic.index);
			if (IsValidClient(patient.index) && IsPlayerAlive(patient.index))
			{
				TF2_AddCondition(patient.index, TFCond_CritOnWin, 0.5, medic.index);
				medic.iUberTarget = patient.userid;
			}
			else medic.iUberTarget = 0;
			CreateTimer(0.1, TimerLazor, EntIndexToEntRef(medigun), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void PrepPlayers(const int userid)
{
	JailBoss player = JailBoss.OfUserId(userid);
	int client = player.index;

	if (!IsValidClient(client))
		return;
	if (!IsPlayerAlive(client) || player.bIsBoss)
		return;

	if (GetClientTeam(client) != RED && GetClientTeam(client) > view_as< int >(TFTeam_Spectator))
	{
		player.ForceTeamChange(RED);
		return;
	}

	TF2_RegeneratePlayer(client);
	TF2Attrib_RemoveAll(client);
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	
	if (IsValidEntity(FindPlayerBack(client, { 444 }, 1))) //  Fixes mantreads to have jump height again
	{
		TF2Attrib_SetByDefIndex(client, 58, 1.3); //  "Self dmg push force increased"
	}
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index) {
			case 237:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon = player.SpawnWeapon("tf_weapon_rocketlauncher", 18, 1, 0, "114 ; 1.0");
				SetWeaponAmmo(weapon, 20);
			}
			case 17, 204:
			{
				if (GetItemQuality(weapon) != 10) {
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					player.SpawnWeapon("tf_weapon_syringegun_medic", 17, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index) {
			/*case 57:	// Razorback
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_smg", 16, 1, 0, "");
			}*/
			case 265: // Stickyjumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_pipebomblauncher", 20, 1, 0, "");
				SetWeaponAmmo(weapon, 24);
			}
			/*case 311, 433:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_pipebomblauncher", 20, 5, 10, "280 ; 3 ; 6 ; 0.7 ; 97 ; 0.5 ; 78 ; 1.2");
				SetWeaponAmmo(weapon, GetMaxAmmo(client, 1));
			}*/
			case 528: //Short Circuit
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_laser_pointer", 140, 1, 0, "");
			}
			case 735, 736, 810, 831, 933, 1080, 1102: // Replace sapper with more useful nail-firing Pistol
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
				SetWeaponAmmo(weapon, 200);
			}
			/*case 46, 1145: //bonk atomic punch
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_lunchbox_drink", 163, 1, 0, "144 ; 2");
			}*/
			case 39, 351, 1081:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_flaregun", index, 5, 10, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.66 ; 144 ; 1 ; 58 ; 3.0");
				SetWeaponAmmo(weapon, 16);
			}
			case 740:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_flaregun", index, 5, 10, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.33 ; 416 ; 3 ; 58 ; 2.08 ; 1 ; 0.65");
				SetWeaponAmmo(weapon, 16);
			}
		}
	}
	/*if ( IsValidEntity (FindPlayerBack(client, { 57 }, 1)) )
	{
		RemovePlayerBack(client, { 57 }, 1);
		weapon = player.SpawnWeapon("tf_weapon_smg", 16, 1, 0, "");
	}*/
	if (IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
	{
		player.SpawnWeapon("tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 1 ; 0.85");
	}
	if (IsValidEntity(FindPlayerBack(client, { 231 }, 1)))
	{
		player.SpawnWeapon("tf_weapon_smg", 16, 1, 6, "16 ; 1.0 ; 1 ; 0.85");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (weapon > MaxClients && IsValidEdict(weapon)) 
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			/*case 331: {
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				weapon = player.SpawnWeapon("tf_weapon_fists", 195, 1, 6, "");
			}*/
			case 357:SetPawnTimer(_NoHonorBound, 1.0, player.userid);
			case 171:
			{  // Remove and replace shiv to avoid idiots hitting themselves while climbing walls
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				weapon = player.SpawnWeapon("tf_weapon_club", 3, 1, 0, "");
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (weapon > MaxClients && IsValidEdict(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
	{
		TF2_RemoveWeaponSlot(client, 4);
		weapon = player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "");
	}
	TFClassType equip = TF2_GetPlayerClass(client);
	switch (equip) 
	{
		case TFClass_Medic:
		{
			weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			int mediquality = GetItemQuality(weapon);
			if (mediquality != 10) {
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				if (g_LR.GetParameterNum("PermOverheal", 0))
					weapon = player.SpawnWeapon("tf_weapon_medigun", 35, 5, 10, "14 ; 0.0 ; 18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75");
				else weapon = player.SpawnWeapon("tf_weapon_medigun", 35, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75");
				//200 ; 1 for area of effect healing, 178 ; 0.75 Faster switch-to, 14 ; 0.0 perm overheal, 11 ; 1.25 Higher overheal
				if (GetMediCharge(weapon) < 0.41)
					SetMediCharge(weapon, 0.41);
			}
		}
	}
}

public void ManageBossCheckHealth(const JailBoss base)
{
	static int LastBossTotalHealth;
	float currtime = GetGameTime();
	if (base.bIsBoss) 
	{  // If a boss reveals their own health, only show that one boss' health.
		switch (base.iType) 
		{
			case  - 1: {  }
			case Hale:PrintCenterTextAll("Saxton Hale showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case Vagineer:PrintCenterTextAll("The Vagineer showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case CBS:PrintCenterTextAll("The Christian Brutal Sniper showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case HHHjr:PrintCenterTextAll("The Horseless Headless Horsemann Jr. showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case Bunny:PrintCenterTextAll("The Easter Bunny showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);

		}
		LastBossTotalHealth = base.iHealth;
		return;
	}
	if (IsClientValid(iCurrBoss.index))
	{
		if (currtime >= flHealthTime)
		{  // If a non-boss is checking health, reveal all Boss' hp
			iHealthChecks++;
			gameMessage[0] = '\0';
			switch (iCurrBoss.iType) 
			{
				case Vagineer:Format(gameMessage, 256, "%s\nThe Vagineer's current health is: %i of %i", gameMessage, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
				case HHHjr:Format(gameMessage, 256, "%s\nThe Horseless Headless Horsemann Jr's current health is: %i of %i", gameMessage, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
				case CBS:Format(gameMessage, 256, "%s\nThe Christian Brutal Sniper's current health is: %i of %i", gameMessage, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
				case Hale:Format(gameMessage, 256, "%s\nSaxton Hale's current health is: %i of %i", gameMessage, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
				case Bunny:Format(gameMessage, 256, "%s\nThe Easter Bunny's current health is: %i of %i", gameMessage, iCurrBoss.iHealth, iCurrBoss.iMaxHealth);
			}
			PrintCenterTextAll(gameMessage);
			CPrintToChatAll("%t %s", "Plugin Tag", gameMessage);
			LastBossTotalHealth = iCurrBoss.iHealth;
			flHealthTime = currtime + (iHealthChecks < 3 ? 10.0 : 60.0);
		}
		else CPrintToChat(base.index, "%t You can see the Boss HP now (wait %i seconds). Last known total health was %i.", "Plugin Tag", RoundFloat(flHealthTime - currtime), LastBossTotalHealth);
	}
}

public void ManageMessageIntro()
{
	gameMessage[0] = '\0';
	//gamemode.OpenAllDoors();

	if (!IsClientValid(iCurrBoss.index))
		return;
	int i;
	switch (iCurrBoss.iType) 
	{
		case  - 1: {  }
		case Hale:Format(gameMessage, 256, "\n%N has become Saxton Hale with %i Health", iCurrBoss.index, iCurrBoss.iHealth);
		case Vagineer:Format(gameMessage, 256, "\n%N has become the Vagineer with %i Health", iCurrBoss.index, iCurrBoss.iHealth);
		case CBS:Format(gameMessage, 256, "\n%N has become the Christian Brutal Sniper with %i Health", iCurrBoss.index, iCurrBoss.iHealth);
		case HHHjr:Format(gameMessage, 256, "\n%N has become The Horseless Headless Horsemann Jr. with %i Health", iCurrBoss.index, iCurrBoss.iHealth);
		case Bunny:Format(gameMessage, 256, "\n%N has become The Easter Bunny with %i Health", iCurrBoss.index, iCurrBoss.iHealth);
	}
	SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
	for (i = MaxClients; i; --i) {
		if (IsValidClient(i))
			ShowHudText(i, -1, "%s", gameMessage);
	}
	gamemode.flMusicTime = GetGameTime() + 4.0;
}

/********************************************************************
						[F*O*R*W*A*R*D*S]
********************************************************************/
// Obviously, here we place what would normally go under the proper, called function in the core plugin
public void fwdOnDownloads()
{
	PrecacheSound("ui/item_store_add_to_cart.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
	PrecacheSound("saxton_hale/9000.wav", true);
	CheckDownload("sound/saxton_hale/9000.wav");
	PrecacheSound("items/pumpkin_pickup.wav", true);
	PrecacheModel("models/player/saxton_hale/w_easteregg.mdl", true);
	AddHaleToDownloads();
	AddVagToDownloads();
	AddCBSToDownloads();
	AddHHHToDownloads();
	AddBunnyToDownloads();
}
public void fwdOnRoundStartPlayer(LastRequest lr, const JBPlayer Player)
{
	JailBoss base = JailBoss.Of(Player);
	base.iDamage = 0;
	TF2_RemoveAllWeapons(base.index);	// Hacky bug patch: Remove weapons to force TF2Items_OnGiveNamedItem to fire for each

	if (GetClientTeam(base.index) == BLU && !base.bIsBoss)
	{
		SetEntityMoveType(base.index, MOVETYPE_WALK);
		base.ForceTeamChange(RED);
		base.bNeedsToGoBackToBlue = true;
	}
	else SetPawnTimer(PrepPlayers, 0.2, base.userid);
}
public void fwdOnRoundStart(LastRequest lr)
{
	SpawnRandomHealth();
	SpawnRandomAmmo();

	if (hTeamBansCVar != null && !hTeamBansCVar.BoolValue)
	{
		hTeamBansCVar.SetBool(true);
		iTeamBansCVar = 1;
	}

	if (hTeamBansCVar != null && !hTeamBansCVar.BoolValue)
	{
		hTeamBansCVar.SetBool(true);
		iTeamBansCVar = 1;
	}

	if (hNoChargeCVar != null)
	{
		iNoChargeCVar = hNoChargeCVar.IntValue;
		hNoChargeCVar.SetInt(0);
	}

	if (hDroppedWeaponsCVar != null)
	{
		iDroppedWeaponsCVar = hDroppedWeaponsCVar.IntValue;
		hDroppedWeaponsCVar.SetInt(1);
	}

	iHealthBar = -1;
	if (g_LR.GetParameterNum("HealthBar", 0))
	{
		iHealthBar = FindEntityByClassname(-1, "monster_resource");
		if (iHealthBar == -1)
		{
			iHealthBar = CreateEntityByName("monster_resource");
			DispatchSpawn(iHealthBar);
		}
		iHealthBar = EntIndexToEntRef(iHealthBar);
	}

	JailBoss rand = JailBoss( GetRandomClient(true) );	// It's probably best to keep the second param true
	if (rand.index <= 0)
		ForceTeamWin(RED);

	int client = rand.index;
	rand.ConvertToBoss(GetRandomInt(Hale, MAXBOSS));
	if (GetClientTeam(client) == RED)
		rand.ForceTeamChange(BLU);

	if (!IsPlayerAlive(client))
		TF2_RespawnPlayer(client);

	rand.iMaxHealth = CalcBossHealth(760.8, gamemode.iPlaying, 1.0, 1.0341, 2046.0);
	int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	TF2Attrib_RemoveAll(client);
	TF2Attrib_SetByDefIndex( client, 26, float(rand.iMaxHealth)-maxhp );

	rand.iHealth = rand.iMaxHealth;
	SetEntityHealth(client, rand.iHealth);

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_healthkit_*")) != -1)
		SetEntProp(ent, Prop_Send, "m_iTeamNum", 2, 4);

	SetPawnTimer(ManagePlayBossIntro, 0.2, rand);
	ManageMessageIntro();
	iCurrBoss = rand;
}
public void fwdOnRoundEnd(LastRequest lr, Event event)
{
	gamemode.DoorHandler(OPEN);
	ShowPlayerScores();
	SetPawnTimer(CalcScores, 3.0);

	if (hTeamBansCVar != null && iTeamBansCVar)
	{
		hTeamBansCVar.SetBool(false);
		iTeamBansCVar = 0;
	}

	if (hNoChargeCVar != null)
		hNoChargeCVar.SetInt(iNoChargeCVar);

	if (hDroppedWeaponsCVar != null)
		hDroppedWeaponsCVar.SetInt(iDroppedWeaponsCVar);

	ManageRoundEndBossInfo( event.GetInt("team") == BLU );
}
public void fwdOnRedThink(LastRequest lr, const JBPlayer Player)
{
	JailBoss fighter = JailBoss.Of(Player);
	int i = fighter.index;
	char wepclassname[64];
	int buttons = GetClientButtons(i);

	SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
	/*if (!IsPlayerAlive(i)) 
	{
		int obstarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
		if (IsValidClient(obstarget) && GetClientTeam(obstarget) != 3 && obstarget != i)
		{
			if (!(buttons & IN_SCORE))
				ShowSyncHudText(i, rageHUD, "Damage: %d - %N's Damage: %d", fighter.iDamage, obstarget, JailBoss(obstarget).iDamage);
		}
		else 
		{
			if (!(buttons & IN_SCORE))
				ShowSyncHudText(i, rageHUD, "Damage: %d", fighter.iDamage);
		}
		return;
	}*/
	/*if (HasEntProp(i, Prop_Send, "m_nStreaks")) {
		int killstreaker = fighter.iDamage / 500;
		if (killstreaker && GetEntProp(i, Prop_Send, "m_nStreaks") >= 0)
			SetEntProp(i, Prop_Send, "m_nStreaks", killstreaker);
	}*/
	TFClassType TFClass = TF2_GetPlayerClass(i);
	int weapon = GetActiveWep(i);
	if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)))
		strcopy(wepclassname, sizeof(wepclassname), "");
	bool validwep = (!strncmp(wepclassname, "tf_wea", 6, false));
	int index = GetItemIndex(weapon);

	switch (TFClass) 
	{	// Chdata's Deadringer Notifier
		case TFClass_Spy:
		{
			if (GetClientCloakIndex(i) == 59)
			{
				int drstatus = TF2_IsPlayerInCondition(i, TFCond_Cloaked) ? 2 : GetEntProp(i, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
				char s[32];
				switch (drstatus) 
				{
					case 1:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Feign-Death Ready");
					}
					case 2:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Dead-Ringered");
					}
					default:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Inactive");
					}
				}
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "%s", s);
			}
		}
		case TFClass_Medic:
		{
			int medigun = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if (IsValidEdict(medigun) && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) && !strcmp(mediclassname, "tf_weapon_medigun", false))
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				int charge = RoundToFloor(GetMediCharge(medigun) * 100);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Ubercharge: %i", charge);
			}
			
			if (validwep && weapon == medigun)
			{
//				int healtarget = GetHealingTarget(i);
//				if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
//					TF2_AddCondition(i, TFCond_SpeedBuffAlly, 0.2);
				if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") > 0.0)
					TF2_AddCondition(i, TFCond_Ubercharged, 1.0); // Fixes Ubercharges ending prematurely on Medics.
			}
		}
		case TFClass_Soldier:
		{
			if (GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary) == 1104)
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Air Strike Damage: %i", fighter.iDamage);
			}
		}
	}
	int living = GetLivingPlayers(RED);
	if (living == 1 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked))
	{
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
		int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
		if (TFClass == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
			SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
		TF2_AddCondition(i, TFCond_Buffed, 0.2);
		return;
	}
	
	else if (living == 2 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		TF2_AddCondition(i, TFCond_Buffed, 0.2);

	TFCond cond = TFCond_CritOnWin;
	if (TF2_IsPlayerInCondition(i, TFCond_CritCola) && (TFClass == TFClass_Scout || TFClass == TFClass_Heavy))
	{
		TF2_AddCondition(i, cond, 0.2);
		return;
	}
	
	bool addthecrit = false;
	bool addmini = false;
	for (int u = MaxClients; u; --u) 
	{
		if (IsValidClient(u) && IsPlayerAlive(i) && GetHealingTarget(u) == i)
		{
			addmini = true;
			break;
		}
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
	{
		// Slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
		if (strcmp(wepclassname, "tf_weapon_knife", false))
			addthecrit = true;
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary)) // Primary weapon crit list
	{
		if (!StrContains(wepclassname, "tf_weapon_compound_bow") ||  // Sniper bows
			!StrContains(wepclassname, "tf_weapon_crossbow") ||  // Medic crossbows
			StrEqual(wepclassname, "tf_weapon_shotgun_building_rescue") ||  // Engineer Rescue Ranger
			StrEqual(wepclassname, "tf_weapon_drg_pomson")) // Engineer Pomson
		{
			addthecrit = true;
		}
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)) // Secondary weapon crit list
	{
		if (!StrContains(wepclassname, "tf_weapon_pistol") ||  // Engineer/Scout pistols
			!StrContains(wepclassname, "tf_weapon_handgun_scout_secondary") ||  // Scout pistols
			!StrContains(wepclassname, "tf_weapon_raygun") ||  //Bison
			!StrContains(wepclassname, "tf_weapon_flaregun") ||  // Flare guns
			StrEqual(wepclassname, "tf_weapon_smg")) // Sniper SMGs minus Cleaner's Carbine
		{
			if (TFClass == TFClass_Scout && cond == TFCond_CritOnWin) cond = TFCond_Buffed;
			int PrimaryIndex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
			if ((TFClass == TFClass_Pyro && PrimaryIndex == 594) || (IsValidEntity(FindPlayerBack(i, { 642, 231 }, 2)))) // No crits if using Phlogistinator or Cozy Camper or Darwin's Danger Shield
				addthecrit = false;
			else addthecrit = true;
		}
		if (!StrContains(wepclassname, "tf_weapon_jar") ||  // Jarate/Milk
			StrEqual(wepclassname, "tf_weapon_cleaver")) // Flying Guillotine
		addthecrit = true;
	}
	switch (index) //Specific weapon crit list
	{
		/*case :
		{
			addthecrit = true;
		}*/
		case 997:
		{
			addthecrit = true;
		}
		case 656: //Holiday Punch
		{
			addthecrit = true;
			cond = TFCond_Buffed;
		}
		case 416: //Market Gardener
		{
			addthecrit = false;
		}
		case 307: //caber
		{
			addthecrit = true;
		}
		case 38, 348, 457, 1000: //Axtinguisher, Postal Pummeler, volcano fragment
		{
			addthecrit = false;
		}
		case 609: //scottish handshake
		{
			addthecrit = false;
		}
		case 460: //enforcer
		{
			addthecrit = false;
		}
		case 413: //solemn vow
		{
			addthecrit = false;
		}
		case 11, 199, 425, 1141, 1153, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:
		{
			if (TFClass == TFClass_Heavy)
			{
				addthecrit = true;
				cond = TFCond_Buffed;
			}
		}
		case 23:
		{	// Crits fucked up for the spy nailgun, had to force it here
			if (TFClass == TFClass_Spy)
				addthecrit = false;
			else cond = TFCond_Buffed;
		}
	}
	
	// if ( TFClass == TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)) )
	int democrits = g_LR.GetParameterNum("DemoShieldCrits", 0);
	if (TFClass == TFClass_DemoMan && democrits && validwep && weapon != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
	{
		float flShieldMeter = GetEntPropFloat(i, Prop_Send, "m_flChargeMeter");
		
		if (democrits >= 1)
		{
			addthecrit = true;
			if (democrits == 1 || (democrits == 3 && flShieldMeter < 100.0))
				cond = TFCond_Buffed;
			if (democrits == 3 && (flShieldMeter < 35.0 || !GetEntProp(i, Prop_Send, "m_bShieldEquipped")))
				addthecrit = false;
		}
	}
	
	if (addthecrit) 
	{
		TF2_AddCondition(i, cond, 0.2);
		if (addmini && cond != TFCond_Buffed)
			TF2_AddCondition(i, TFCond_Buffed, 0.2);
	}
	if (TFClass == TFClass_Spy && validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
	{
		if (!TF2_IsPlayerCritBuffed(i)
			&& !TF2_IsPlayerInCondition(i, TFCond_Buffed)
			&& !TF2_IsPlayerInCondition(i, TFCond_Cloaked)
			&& !TF2_IsPlayerInCondition(i, TFCond_Disguised)
			&& !GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
		{
			TF2_AddCondition(i, TFCond_CritCola, 0.2);
		}
	}
	if (TFClass == TFClass_Engineer
		&& weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary)
		&& StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
	{
		int sentry = FindSentry(i);
		if (IsValidEntity(sentry)) 
		{
			int enemy = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
			if (enemy > 0 && GetClientTeam(enemy) == 3) {  // Trying to target minions as well
				SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
				TF2_AddCondition(i, TFCond_Kritzkrieged, 0.2);
			}
			else
			{
				if (GetEntProp(i, Prop_Send, "m_iRevengeCrits"))
					SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
				else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing))
					TF2_RemoveCondition(i, TFCond_Kritzkrieged);
			}
		}
	}
}
public void fwdOnBlueThink(LastRequest lr, const JBPlayer Player)
{
	JailBoss base = JailBoss.Of(Player);
	if (!base.bIsBoss)
		return;

	UpdateBossHealth();		// This way it only fires once within the think loop

	switch (base.iType) 
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Think();
		case Vagineer:ToCVagineer(base).Think();
		case CBS:ToCChristian(base).Think();
		case HHHjr:ToCHHHJr(base).Think();
		case Bunny:ToCBunny(base).Think();
	}

	SetEntityHealth(base.index, base.iHealth);
	if (base.iHealth <= 0)
		SDKHooks_TakeDamage(base.index, 0, 0, 100.0, DMG_DIRECT, _, _, _);

	/* Adding this so bosses can take minicrits if airborne */
	TF2_AddCondition(base.index, TFCond_GrapplingHookSafeFall, 0.2);
}
public void fwdOnPlayerDied(LastRequest lr, const JBPlayer Victim, const JBPlayer Attacker, Event event)
{
	JailBoss victim = JailBoss.Of(Victim);
	JailBoss attacker = JailBoss.Of(Attacker);

	int deathflags = event.GetInt("death_flags");
	if (victim.bIsBoss) // If victim is a boss, kill him off
		SetPawnTimer(_BossDeath, 0.1, victim.userid);
	
	if (attacker.bIsBoss && !victim.bIsBoss)
	{
		switch (attacker.iType) 
		{
			case  - 1: {  }
			case Hale:
			{
				if (deathflags & TF_DEATHFLAG_DEADRINGER)
					event.SetString("weapon", "fists");
				else ToCHale(attacker).KilledPlayer(victim, event);
			}
			case Vagineer:ToCVagineer(attacker).KilledPlayer(victim, event);
			case CBS:ToCChristian(attacker).KilledPlayer(victim, event);
			case HHHjr:ToCHHHJr(attacker).KilledPlayer(victim, event);
			case Bunny:ToCBunny(attacker).KilledPlayer(victim, event);
		}
	}
	
	if ( (TF2_GetPlayerClass(victim.index) == TFClass_Engineer) && !(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
		switch (g_LR.GetParameterNum("EngieBuildings", 0)) 
		{
			case 1: 
			{
				int sentry = FindSentry(victim.index);
				if (sentry != -1) 
				{
					SetVariantInt(GetEntProp(sentry, Prop_Send, "m_iMaxHealth")+8);
					AcceptEntityInput(sentry, "RemoveHealth");
				}
			}
			case 2: 
			{
				for (int ent=MaxClients+1 ; ent<2048 ; ++ent) 
				{
					if (!IsValidEdict(ent)) 
						continue;
					else if (!HasEntProp(ent, Prop_Send, "m_hBuilder"))
						continue;
					else if (GetBuilder(ent) != victim.index)
						continue;

					SetVariantInt(GetEntProp(ent, Prop_Send, "m_iMaxHealth")+8);
					AcceptEntityInput(ent, "RemoveHealth");
				}
			}
		}
	}
	if (!victim.bIsBoss)
		TF2_RemoveWeaponSlot(victim.index, 3);		// Ugh
}
public void fwdOnBuildingDestroyed(LastRequest lr, const JBPlayer Attacker, const int building, Event event)
{
	JailBoss attacker = JailBoss.Of(Attacker);

	switch (attacker.iType) 
	{
		case  - 1: {  }
		case Hale: 
		{
			event.SetString("weapon", "fists");
			if (!GetRandomInt(0, 3)) 
			{
				strcopy(snd, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
				EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
		}
	}
}
public void fwdOnObjectDeflected(LastRequest lr, const JBPlayer Victim, const JBPlayer Attacker, Event event)
{
	//JailBoss airblaster = JailBoss.Of(Attacker);
	JailBoss airblasted = JailBoss.Of(Victim);

	switch (airblasted.iType) 
	{
		case  - 1: {  }
		case Hale, CBS, HHHjr, Bunny:airblasted.flRAGE += g_LR.GetParameterFloat("AirblastRage", 0.0);
		case Vagineer:
		{
			if (TF2_IsPlayerInCondition(airblasted.index, TFCond_Ubercharged))
				TF2_AddCondition(airblasted.index, TFCond_Ubercharged, 2.0);
			else airblasted.flRAGE += g_LR.GetParameterFloat("AirblastRage", 0.0);
		}
	}
}
public void fwdOnPlayerJarated(LastRequest lr, const JBPlayer Attacker, const JBPlayer Victim)
{
	ManagePlayerJarated(JailBoss.Of(Attacker), JailBoss.Of(Victim));
}
public void fwdOnUberDeployed(LastRequest lr, const JBPlayer Medic, const JBPlayer Patient)
{
	ManageUberDeploy(JailBoss.Of(Medic), JailBoss.Of(Patient));
}
public void fwdOnPlayerSpawned(LastRequest lr, const JBPlayer Player, Event event)
{
	JailBoss spawn = JailBoss.Of(Player);

	if (spawn.bIsBoss)
	{
		if (GetClientTeam(spawn.index) != BLU)
			spawn.ForceTeamChange(BLU);
		ManageBossModels(spawn);

		if (!spawn.iHealth)
			spawn.iHealth = spawn.iMaxHealth;
		return;
	}

	SetVariantString(""); AcceptEntityInput(spawn.index, "SetCustomModel");
	if (GetClientTeam(spawn.index) != RED)
		spawn.ForceTeamChange(RED);
	else SetPawnTimer(PrepPlayers, 0.2, spawn.userid);
}
public void fwdOnHurtPlayer(LastRequest lr, const JBPlayer Victim, const JBPlayer Attacker, Event event)
{
	if (!IsClientValid(Victim.index) || !IsClientValid(Attacker.index) || Attacker.index == Victim.index)
		return;

	JailBoss victim = JailBoss.Of(Victim);

	if (!victim.bIsBoss)
		return;

	int damage = event.GetInt("damageamount");
	int custom = event.GetInt("custom");
	int weapon = event.GetInt("weaponid");
	
	JailBoss attacker = JailBoss.Of(Attacker);
	if (damage > 0)
	{
		switch (victim.iType) 
		{
			case  -1: {  }
			default: 
			{
				victim.iHealth -= damage;
				victim.GiveRage(damage);
			}
		}
	}

	if (custom == TF_CUSTOM_TELEFRAG)
		damage = (IsPlayerAlive(attacker.index) ? 9001 : 1); // Telefrags normally 1-shot the boss but let's cap damage at 9k
	
	attacker.iDamage += damage;
	int primary = GetPlayerWeaponSlot(attacker.index, TFWeaponSlot_Primary);
	if (IsValidEntity(primary))
	{
		if (GetItemIndex(primary) == 1104)
		{
			if (weapon == TF_WEAPON_ROCKETLAUNCHER)
				attacker.iAirDamage += damage;
			int div = g_LR.GetParameterNum("AirStrikeDamage", 1);
			if (div)
				SetEntProp(attacker.index, Prop_Send, "m_iDecapitations", attacker.iAirDamage / div);
		}
	}
	
	int healers[MAXPLAYERS];
	int healercount = 0;
	for (int i = MaxClients; i; --i) {
		if (!IsValidClient(i))
			continue;
		else if (!IsPlayerAlive(i))
			continue;
		
		if (GetHealingTarget(i) == attacker.index) {
			healers[healercount] = i;
			healercount++;
		}
	}
	JailBoss medic;
	for (int r = 0; r < healercount; r++) 
	{  // Medics now count as 3/5 of a backstab, similar to telefrag assists.
		if (!IsValidClient(healers[r]))
			continue;
		else if (!IsPlayerAlive(healers[r]))
			continue;
		
		medic = JailBoss(healers[r]);
		if (damage < 10 || medic.iUberTarget == attacker.userid)
			medic.iDamage += damage;
		else medic.iDamage += damage / (healercount + 1);
	}
}
public Action fwdOnTakeDamage(LastRequest lr, const JBPlayer Victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	JailBoss victim = JailBoss.Of(Victim);
	int bFallDamage = (damagetype & DMG_FALL);
	if (victim.bIsBoss && attacker <= 0 && bFallDamage)
	{
		damage = (victim.iHealth > 100) ? 1.0 : 30.0;
		return Plugin_Changed;
	}
	if (!victim.bIsBoss && attacker <= 0 && bFallDamage && IsValidEntity(FindPlayerBack(victim.index, { 608, 405, 133, 444 }, 4))) 
	{
		damage /= 10.0;
		return Plugin_Changed;
	}

	if (victim.bIsBoss)
		return ManageOnBossTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	if (!IsClientValid(attacker))
		return Plugin_Continue;

	if (JailBoss(attacker).bIsBoss)
		return ManageOnBossDealDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	return Plugin_Continue;
}
public Action fwdOnMusicPlay(LastRequest lr, char song[PLATFORM_MAX_PATH], float &time)
{
	if (IsClientValid(iCurrBoss.index))
		return Plugin_Handled;

	switch (iCurrBoss.iType) 
	{
		case  - 1: { song[0] = '\0'; time = -1.0; return Plugin_Handled; }
		case CBS: 
		{
			strcopy(song, sizeof(song), CBSTheme);
			time = 140.0;
		}
		case HHHjr: 
		{
			strcopy(song, sizeof(song), HHHTheme);
			time = 90.0;
		}
	}
	return Plugin_Continue;
}
public void fwdOnVariableReset(LastRequest lr, const JBPlayer Player)
{
	JailBoss base = JailBoss.Of(Player);

	base.iUberTarget = 0;
	base.iHealth = 0;
	base.iMaxHealth = 0;
	base.iAirDamage = 0;
	base.iType = -1;
	base.iStabbed = 0;
	base.iDamage = 0;
	base.iMarketted = 0;
	// base.bGlow = 0;
	base.iClimbs = 0;
	base.bIsBoss = false;
	base.flRAGE = 0.0;
	base.flWeighDown = 0.0;
	base.flGlowtime = 0.0;
	base.flCharge = 0.0;
	base.flKillSpree = 0.0;

	if (base.bNeedsToGoBackToBlue && GetClientTeam(base.index) != BLU)
		ChangeClientTeam(base.index, BLU);
	base.bNeedsToGoBackToBlue = false;
}
public void fwdOnCheckLivingPlayers(LastRequest lr)
{
	JailBoss base;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		base = JailBoss(i);
		if (base.bNeedsToGoBackToBlue && GetClientTeam(i) != BLU && !IsPlayerAlive(i))
		{
			ChangeClientTeam(i, BLU);
			base.bNeedsToGoBackToBlue = false;
		}
	}
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	if (NOTVSH)
		return Plugin_Continue;

	if (!IsPlayerAlive(client))
		return Plugin_Continue;
	
	JailBoss base = JailBoss(client);
	switch (base.iType) {
		case  - 1: {  }
		case Bunny:
		{
			if (GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetActiveWep(client))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
		case HHHjr: {
			if (base.flCharge >= 47.0 && (buttons & IN_ATTACK))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void fwdOnRoundEndPlayer(LastRequest lr, const JBPlayer player, Event event)
{
	JailBoss base = JailBoss.Of(player);
	if (base.bIsBoss)
		return;

	SetPawnTimer(TF2ItemsFix, _, base.index);
}

public Action fwdOnSoundHook(LastRequest lr, int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	switch (JailBoss.Of(player).iType) 
	{
		case Hale: 
		{
			if (!strncmp(sample, "vo", 2, false))
				return Plugin_Handled;
		}
		case Vagineer: 
		{
			if (StrContains(sample, "vo/engineer_laughlong01", false) != -1)
			{
				strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
				return Plugin_Changed;
			}
			
			if (!strncmp(sample, "vo", 2, false))
			{
				if (StrContains(sample, "positivevocalization01", false) != -1) // For backstab sound
					return Plugin_Continue;
				if (StrContains(sample, "engineer_moveup", false) != - 1)
					Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				
				else if (StrContains(sample, "engineer_no", false) != - 1 || GetRandomInt(0, 9) > 6)
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.mp3");
				
				else strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.mp3");
				return Plugin_Changed;
			}
			else return Plugin_Continue;
		}
		case HHHjr: 
		{
			if (!strncmp(sample, "vo", 2, false))
			{
				if (GetRandomInt(0, 30) <= 10) 
				{
					Format(sample, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if (StrContains(sample, "halloween_boss") == -1)
					return Plugin_Handled;
			}
		}
		case Bunny: 
		{
			if (StrContains(sample, "gibberish", false) == -1
				 && StrContains(sample, "burp", false) == -1
				 && !GetRandomInt(0, 2)) // Do sound things
			{
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice) - 1)]);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action fwdOnCalcAttack(LastRequest lr, JBPlayer player, int weapon, char[] weaponname, bool &result)
{
	JailBoss base = JailBoss.Of(player);
	switch (base.iType) 
	{
		case  - 1: {  }
		case HHHjr: 
		{
			if (base.iClimbs < 10) 
			{
				base.ClimbWall(weapon, 600.0, 0.0, false);
				base.flWeighDown = 0.0;
				base.iClimbs++;
			}
		}
	}
	if (base.bIsBoss)
	{  // Fuck random crits
		if (TF2_IsPlayerCritBuffed(base.index))
			return Plugin_Continue;
		result = false;
		return Plugin_Changed;
	}
	
	if (!base.bIsBoss) 
	{
		if (TF2_GetPlayerClass(base.index) == TFClass_Sniper && IsWeaponSlotActive(base.index, TFWeaponSlot_Melee))
			base.ClimbWall(weapon, 600.0, 15.0, true);
	}
	return Plugin_Continue;
}

public void TF2ItemsFix(const int client)
{
	if (!IsClientInGame(client))
		return;

// CRASH! BUGBUG; what the fuck why does this crash with engineer PDA's?
//	TF2_RemoveAllWeapons(client);

// When an engineer pulls out his PDA, a building is created (usually a sentry) and is our culprit
// This happens when the engineer needs a new builder
// Since we're removing his old builder to fix TF2Items, the game gives a new one, engi
// starts trying to place a new building (which he might already have), which hits our segfault

	for (int i = 0; i <= TFWeaponSlot_Melee; ++i)
	{
		int wep = GetPlayerWeaponSlot(client, i);
		if (wep != -1)
			TF2_RemoveWeaponSlot(client, i);
	}
	if (IsPlayerAlive(client))
		TF2_RegeneratePlayer(client);
}

public Action fwdOnSetWardenLock(LastRequest lr, const bool status)
{
	return !status ? Plugin_Handled : Plugin_Continue;
}

public void LoadJBHooks()
{
	g_LR.AddHook(OnLRActivate, fwdOnRoundStart);
	g_LR.AddHook(OnLRActivatePlayer, fwdOnRoundStartPlayer);
	g_LR.AddHook(OnRoundEnd, fwdOnRoundEnd);
	g_LR.AddHook(OnRoundEndPlayer, fwdOnRoundEndPlayer);
	g_LR.AddHook(OnRedThink, fwdOnRedThink);
	g_LR.AddHook(OnBlueThink, fwdOnBlueThink);
	g_LR.AddHook(OnPlayerDied, fwdOnPlayerDied);
	g_LR.AddHook(OnBuildingDestroyed, fwdOnBuildingDestroyed);
	g_LR.AddHook(OnObjectDeflected, fwdOnObjectDeflected);
	g_LR.AddHook(OnPlayerJarated, fwdOnPlayerJarated);
	g_LR.AddHook(OnUberDeployed, fwdOnUberDeployed);
	g_LR.AddHook(OnPlayerSpawned, fwdOnPlayerSpawned);
	g_LR.AddHook(OnTakeDamage, fwdOnTakeDamage);
	g_LR.AddHook(OnClientInduction, fwdOnClientInduction);
	g_LR.AddHook(OnPlayMusic, fwdOnMusicPlay);
	g_LR.AddHook(OnVariableReset, fwdOnVariableReset);
	g_LR.AddHook(OnLastPrisoner, fwdOnLastPrisoner);
	g_LR.AddHook(OnCheckLivingPlayers, fwdOnCheckLivingPlayers);
	g_LR.AddHook(OnSoundHook, fwdOnSoundHook);
	g_LR.AddHook(OnEntCreated, fwdOnEntCreated);
	g_LR.AddHook(OnSetWardenLock, fwdOnSetWardenLock);
	g_LR.AddHook(OnPlayerHurt, fwdOnHurtPlayer);

	JB_Hook(OnDownloads, fwdOnDownloads);
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
stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
stock void OverNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}
