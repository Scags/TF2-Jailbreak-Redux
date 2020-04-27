#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <tf2_stocks>
#include <tf2attributes>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required
#include "TF2JailRedux/stocks.inc"

#define PLUGIN_VERSION		"1.1.0"

#define RED 				2
#define BLU 				3

char g_PlayerModel[MAXPLAYERS+1][PLATFORM_MAX_PATH];

ArrayList
	g_PropNamesIndex,
	g_PropPath,
	g_ModelOffset,
	g_ModelRotation
;

StringMap
	g_PropData
;

enum struct PropData
{
	char PropData_Name[96];
	char PropData_Offset[32]; // 3 digits, plus 2 spaces, plus a null terminator
	char PropData_Rotation[32]; // 3 digits, plus 2 spaces, plus a null terminator
}

methodmap JailHunter < JBPlayer
{
	public JailHunter( const int w )
	{
		return view_as< JailHunter >(w);
	}
	public static JailHunter OfUserId( const int id )
	{
		return view_as< JailHunter >(GetClientOfUserId(id));
	}
	public static JailHunter Of( const JBPlayer player )
	{
		return view_as< JailHunter >(player);
	}

	property int iRolls
	{
		public get() 				{ return this.GetProp("iRolls"); }
		public set( const int i ) 	{ this.SetProp("iRolls", i); }
	}
	property int iLastProp
	{
		public get() 				{ return this.GetProp("iLastProp"); }
		public set( const int i ) 	{ this.SetProp("iLastProp", i); }
	}
	property int iFlameCount
	{
		public get() 				{ return this.GetProp("iFlameCount"); }
		public set( const int i ) 	{ this.SetProp("iFlameCount", i); }
	}

	property bool bTouched
	{
		public get() 				{ return this.GetProp("bTouched"); }
		public set( const bool i ) 	{ this.SetProp("bTouched", i); }
	}
	property bool bIsProp
	{
		public get() 				{ return this.GetProp("bIsProp"); }
		public set( const bool i ) 	{ this.SetProp("bIsProp", i); }
	}
	property bool bFlaming
	{
		public get() 				{ return this.GetProp("bFlaming"); }
		public set( const bool i ) 	{ this.SetProp("bFlaming", i); }
	}
	property bool bLocked
	{
		public get() 				{ return this.GetProp("bLocked"); }
		public set( const bool i ) 	{ this.SetProp("bLocked", i); }
	}
	property bool bHoldingLMB
	{
		public get() 				{ return this.GetProp("bHoldingLMB"); }
		public set( const bool i ) 	{ this.SetProp("bHoldingLMB", i); }
	}
	property bool bHoldingRMB
	{
		public get() 				{ return this.GetProp("bHoldingRMB"); }
		public set( const bool i ) 	{ this.SetProp("bHoldingRMB", i); }
	}
	property bool bFirstPerson
	{
		public get() 				{ return this.GetProp("bFirstPerson"); }
		public set( const bool i ) 	{ this.SetProp("bFirstPerson", i); }
	}

	public void MakeProp( const bool announce, bool override = true, bool loseweps = true )
	{
		this.PreEquip(loseweps);
		int client = this.index;
		PropData propData;
		if (override)
			this.iLastProp = -1;

		// Fire in a nice random model
		char model[PLATFORM_MAX_PATH];
		char offset[32] = "0 0 0";
		char rotation[32] = "0 0 0";
		model = g_PlayerModel[client];

		if (this.iLastProp > -1)
		{
			char tempOffset[32];
			char tempRotation[32];
			g_ModelOffset.GetString(this.iLastProp, tempOffset, sizeof(tempOffset));
			g_ModelRotation.GetString(this.iLastProp, tempRotation, sizeof(tempRotation));
			TrimString(tempOffset);
			TrimString(tempRotation);
			// We don't want to override the default value unless it's set to something other than "0 0 0"
			if (!StrEqual(tempOffset, "0 0 0"))
				strcopy(offset, sizeof(offset), tempOffset);
			if (!StrEqual(tempRotation, "0 0 0"))
				strcopy(rotation, sizeof(rotation), tempRotation);
		}
		else
		{
			this.iLastProp = GetRandomInt(0, g_PropNamesIndex.Length-1);
			g_PropPath.GetString(this.iLastProp, model, PLATFORM_MAX_PATH);
			g_PlayerModel[client] = model;
		}

		char modelName[96];
		if (g_PropData.GetArray(model, propData, sizeof(propData)))
		{
			strcopy(modelName, sizeof(modelName), propData.PropData_Name);
			strcopy(offset, sizeof(offset), propData.PropData_Offset);
			strcopy(rotation, sizeof(rotation), propData.PropData_Rotation);
		}
		
		if (announce)
			CPrintToChat(client, "%t You are now disguised as {default}%s{burlywood}.", "Plugin Tag", modelName);
		
		// This is to kill the particle effects from the Harvest Ghost prop and the like
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(client, "DispatchEffect");
		
		g_PlayerModel[client] = model;
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");

		SetVariantString(offset);
		AcceptEntityInput(client, "SetCustomModelOffset");
		if (StrEqual(rotation, "0 0 0"))
			AcceptEntityInput(client, "ClearCustomModelRotation");
		else
		{
			SetVariantString(rotation);
			AcceptEntityInput(client, "SetCustomModelRotation");
		}
		SetVariantInt(1);
		AcceptEntityInput(client, "SetCustomModelRotates");

		SwitchView(client, true, false);
		this.bIsProp = true;
	}
	public void Init_PH( bool compl = false )
	{
		this.iRolls = 0;
		this.iLastProp = -1;
		this.iFlameCount = 0;
		this.bTouched = false;
		this.bIsProp = false;
		this.bFlaming = false;
		this.bLocked = false;
		this.bHoldingLMB = false;
		this.bHoldingRMB = false;
		this.bFirstPerson = false;
		if (compl)
		{
			int client = this.index;
			if (GetClientTeam(client) == RED)
			{
				SetVariantString("ParticleEffectStop");
				AcceptEntityInput(client, "DispatchEffect");

				SetVariantString("");
				AcceptEntityInput(client, "SetCustomModel");

				SetVariantString("0 0 0");
				AcceptEntityInput(client, "SetCustomModelOffset");
				AcceptEntityInput(client, "ClearCustomModelRotation");
			}
		}
	}
};

public Plugin myinfo =
{
	name = "TF2Jail PH LR Module",
	author = "Scag/Ragenewb, just about all props to Darkimmortal, Geit, and Powerlord",
	description = "Prophunt embedded as an LR for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

bool
	bFirstBlood,
	bAbleToReroll,
	bDisabled = true
;

int
	iGameTime	// Pre-round-start global time
;

LastRequest
	g_LR
;

JBGameMode
	gamemode
;

public void OnPluginStart()
{
	RegConsoleCmd("sm_propreroll", Cmd_Reroll);
//	RegAdminCmd("sm_unregisterph", Cmd_UnLoad, ADMFLAG_ROOT);
//	RegAdminCmd("sm_registerph", Cmd_ReLoad, ADMFLAG_ROOT);

	LoadTranslations("common.phrases");
	LoadTranslations("tf2jail_redux.phrases");

	g_PropData = new StringMap();
	g_PropPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_PropNamesIndex = new ArrayList();
	g_ModelOffset = new ArrayList(ByteCountToCells(11));
	g_ModelRotation = new ArrayList(ByteCountToCells(11));
}

public void InitSubPlugin()
{
	gamemode = new JBGameMode();

	g_LR = LastRequest.CreateFromConfig("PropHunt");

	if (g_LR == null)	// If it's her first time, set the mood
	{
		g_LR = LastRequest.Create("PropHunt");
		g_LR.SetDescription("Play a nice round of PropHunt");
		g_LR.SetAnnounceMessage("{default}{NAME}{burlywood} has selected {default}PropHunt{burlywood} as their last request.");

//		g_LR.SetActivationMessage("Hunters will be released in {default}{TIME}{burlywood} seconds.");	// We're overriding this

		g_LR.SetParameterNum("Disabled", 0);
		g_LR.SetParameterNum("OpenCells", 1);
		g_LR.SetParameterNum("TimerStatus", 1);
		g_LR.SetParameterNum("TimerTime", 330);
		g_LR.SetParameterNum("LockWarden", 1);
		g_LR.SetParameterNum("UsesPerMap", 3);
//		g_LR.SetParameterNum("IsWarday", 1);
		g_LR.SetParameterNum("NoMuting", 1);
		g_LR.SetParameterNum("DisableMedic", 1);
		g_LR.SetParameterNum("AllowBuilding", 1);
//		g_LR.SetParameterNum("RegenerateReds", 0);
		g_LR.SetParameterNum("EnableCriticals", 0);
		g_LR.SetParameterNum("VoidFreekills", 1);
		g_LR.SetParameterNum("IgnoreRebels", 1);

		// Custom config
		// It'd be cool if there was a way to add comments to kv cfg
		g_LR.SetParameterNum("PropReroll", 1);				// Allow players to !propreroll. Number of times allowed
		g_LR.SetParameterFloat("PropRerollTime", 15.0);		// Time after round starts to allow prop rerolling
		g_LR.SetParameterNum("DamageBlocksReroll", 1);		// Damage and harmful effects prevent !propreroll
		g_LR.SetParameterNum("StaticPropInfo", 1);			// If player's have r_staticpropinfo enabled, kick them
		g_LR.SetParameterNum("PropNameOnGive", 1);			// Tell players what prop they are on give
		g_LR.SetParameterNum("ForceBluePyro", 1);			// Force blue team as pyro
		g_LR.SetParameterNum("FreezeTime", 30);				// Freeze time at start
		g_LR.SetParameterNum("TeleportBehavior", 1);		// 0: Disabed, 1: BLU to Warday, 2: BLU to Freeday, 3: RED to Warday, 4: RED to Freeday, 5: BOTH to Warday
		g_LR.SetParameterNum("LeechDamage", 1);				// Damage dealt to props comes back as health
		g_LR.GetParameterNum("FallDamage", 0); 				// Disable fall damage. (0 = none, 1 = all players, 2 = blue only, 3 = red only)

		g_LR.SetParameterString("ActivationMessage", "Hunters will be released in {default}{TIME}{burlywood} seconds.");
		g_LR.SetParameterString("HuntersReleasedMessage", "Ready or not, here they come!");

		g_LR.ExportToConfig(.create = true, .createonly = true);
	}
	LoadJBHooks();
}

public void OnPluginEnd()
{
	if (LibraryExists("TF2Jail_Redux"))
		g_LR.Destroy();
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true))
	{
		g_LR = null;
		bDisabled = true;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true) && bDisabled)
	{
		InitSubPlugin();
		bDisabled = false;
	}
}

#define NOTPH 				( g_LR == null || g_LR.GetID() != gamemode.iLRType )

public void OnMapStart()
{
	// Sorry but all of the cfg is just too much
	// This is a Jailbreak server, things have to be a little different
	ParsePropCFG();
}

public void fwdOnClientInduction(const JBPlayer Player)
{
	JailHunter base = JailHunter.Of(Player);
	base.iRolls = 0;
	base.iLastProp = -1;
	base.iFlameCount = 0;
	base.bTouched = false;
	base.bIsProp = false;
	base.bFlaming = false;
	base.bLocked = false;
	base.bHoldingLMB = false;
	base.bHoldingRMB = false;
	base.bFirstPerson = false;
}

public void fwdOnDownloads()
{
	char s[PLATFORM_MAX_PATH];
	for (int i = 1; i <= 6; i++)
	{
		if (i <= 4)
		{
			FormatEx(s, PLATFORM_MAX_PATH, "vo/announcer_am_roundstart0%i.mp3", i);
			PrecacheSound(s, true);
		}

		FormatEx(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins60sec0%i.mp3", i);
		PrecacheSound(s, true);

		FormatEx(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins30sec0%i.mp3", i);
		PrecacheSound(s, true);

		FormatEx(s, PLATFORM_MAX_PATH, "vo/announcer_am_firstblood0%i.mp3", i);
		PrecacheSound(s, true);
	}

	PrepareSound("prophunt/oneandonly.mp3");
	PrepareSound("prophunt/found.mp3");
	PrepareSound("prophunt/snaaake.mp3");

	PrecacheSound("vo/announcer_dec_missionbegins10sec01.mp3", true);
	PrecacheSound("buttons/button24.wav", true);
	PrecacheSound("buttons/button3.wav", true);
}

public void ParsePropCFG()
{
	char Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "data/prophunt/prop_common.txt");

	KeyValues kv = CreateKeyValues("propcommon");
	if (!kv.ImportFromFile(Path))
	{
		LogError("Could not load the Prop Common file %s", Path);
		delete kv;
		return;
	}

	if (!kv.GotoFirstSubKey())
	{
		LogError("Prop Common file is empty!");
		delete kv;
		return;
	}

	g_PropData.Clear();
	g_PropNamesIndex.Clear();
	g_PropPath.Clear();

	int counter;
	char modelPath[PLATFORM_MAX_PATH];
	PropData propData;
	do
	{
		kv.GetSectionName(modelPath, PLATFORM_MAX_PATH);
		kv.GetString("name", propData.PropData_Name, sizeof(propData.PropData_Name), "");

		kv.GetString("offset", propData.PropData_Offset, sizeof(propData.PropData_Offset), "0 0 0");
		g_ModelOffset.PushString(propData.PropData_Offset);
		kv.GetString("rotation", propData.PropData_Rotation, sizeof(propData.PropData_Rotation), "0 0 0");
		g_ModelRotation.PushString(propData.PropData_Rotation);

		if (!strlen(propData.PropData_Name))
		{
			// No "name" or "en" block means no prop name, but this isn't an error that prevents us from using the prop for offset and rotation
			LogError("Error getting prop name for %s", modelPath);
		}

		if (!g_PropData.SetArray(modelPath, propData, sizeof(propData), false))
		{
			LogError("Error saving prop data for %s", modelPath);
			continue;
		}
		PrecacheModel(modelPath, true);
		g_PropNamesIndex.Push(counter);
		g_PropPath.PushString(modelPath);

		counter++;
	}	while kv.GotoNextKey(false);

	delete kv;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (NOTPH)
		return Plugin_Continue;

	JailHunter player = JailHunter(client);
	if (!player.bFlaming)
		return Plugin_Continue;

	if (!(buttons & IN_ATTACK))
	{
		player.bFlaming = false;
		player.iFlameCount = 0;
	}
	return Plugin_Continue;
}

public void KickCallBack(const QueryCookie cookie, const int client, const ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (result == ConVarQuery_Okay)
	{
		if (!StringToInt(cvarValue))
			return;
		KickClient(client, "Client ConVar r_staticpropinfo is enabled");
		return;
	}
	KickClient(client, "Could not detect client ConVar r_staticpropinfo");
}

public void fwdOnCheckLivingPlayers(LastRequest lr)
{
	if (NOTPH)
		return;

	if (!g_LR.GetParameterNum("StaticPropInfo", 0))
		return;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
			continue;

		QueryClientConVar(i, "r_staticpropinfo", KickCallBack);
	}
}

public Action fwdOnLastPrisoner(LastRequest lr)
{
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == RED)
		{
			TF2_RegeneratePlayer(i);
			SetEntityHealth(i, GetEntProp(i, Prop_Data, "m_iMaxHealth"));

			JailHunter player = JailHunter(i);
			player.MakeProp(!!g_LR.GetParameterNum("PropNameOnGive"), false, false);
			player.SetWepInvis(0);
		}
		else TF2_AddCondition(i, TFCond_Jarated, 15.0);
	}

	EmitSoundToAll("prophunt/oneandonly.mp3");
	return Plugin_Continue;
}

public void DisallowRerolls(const int roundcount)
{
	if (gamemode.iRoundCount == roundcount)
		bAbleToReroll = false;
}

public Action Cmd_Reroll(int client, int args)
{
	if (!client || NOTPH || !IsPlayerAlive(client))
		return Plugin_Handled;

	if (!g_LR.GetParameterNum("Rerolling", 0))
	{
		CPrintToChat(client, "%t Rerolling has been disabled.", "Plugin Tag");
		return Plugin_Handled;
	}
	JailHunter player = JailHunter(client);
	if (!player.bIsProp)
	{
		CPrintToChat(client, "%t You are not a prop.", "Plugin Tag");
		return Plugin_Handled;
	}
	if (GetClientTeam(client) != RED)
	{
		CPrintToChat(client, "%t You are not on Red team.", "Plugin Tag");
		return Plugin_Handled;
	}
	if (!bAbleToReroll)
	{
		CPrintToChat(client, "%t You are not allowed to reroll at this time.", "Plugin Tag");
		return Plugin_Handled;
	}
	if (player.iRolls >= g_LR.GetParameterNum("Rerolling", 0))
	{
		CPrintToChat(client, "%t You have rerolled the maximum amount of times this round.", "Plugin Tag");
		return Plugin_Handled;
	}
	if (g_LR.GetParameterNum("DamageBlocksReroll", 0) 
	 && (TF2_IsPlayerInCondition(client, TFCond_Bleeding)
	  || TF2_IsPlayerInCondition(client, TFCond_OnFire)
	  || TF2_IsPlayerInCondition(client, TFCond_LostFooting)
	  || TF2_IsPlayerInCondition(client, TFCond_Jarated) 
	  || TF2_IsPlayerInCondition(client, TFCond_Milked)
	  || TF2_IsPlayerInCondition(client, TFCond_Gas)))
	{
		CPrintToChat(client, "%t You are under effects and can't change!", "Plugin Tag");
		return Plugin_Handled;
	}

	player.MakeProp(!!g_LR.GetParameterNum("PropNameOnGive"), true);
	player.iRolls++;

	return Plugin_Handled;
}

#if 0
/**
 *	Purpose: Disable the plugin without unloading it.
 *	This is more for testing, but technical users can use this to their advantage.
 *	Prophunt will not re-register unless you reload the plugin manually or sm_registerph.
*/
public Action Cmd_UnLoad(int client, int args)
{
	if (g_LR != null)
	{
		g_LR.Destroy();
		g_LR = null;
		CReplyToCommand(client, "%t Prophunt has been successfully unregistered.", "Admin Tag");
	}
	else CReplyToCommand(client, "%t Prophunt was not unregistered. Was it registered to begin with?", "Admin Tag");

	return Plugin_Handled;
}

public Action Cmd_ReLoad(int client, int args)
{
	if (g_LR != null)
	{
		CReplyToCommand(client, "%t Prophunt is already registered.", "Admin Tag");
		return Plugin_Handled;
	}

	g_LR = new LastRequest("PropHunt");
	CReplyToCommand(client, "%t Prophunt has been re-registered.", "Admin Tag");
	return Plugin_Handled;
}
#endif

public Action fwdOnCalcAttack(LastRequest lr, JBPlayer player, int weapon, char[] weaponname, bool &result)
{
	int client = player.index;
	if (GetClientTeam(client) == BLU && IsValidEntity(weapon))
	{
		if (!strcmp(weaponname, "tf_weapon_flamethrower"))
		{
			JailHunter base = JailHunter.Of(player);
			base.bFlaming = true;
			base.iFlameCount = 0;
		}
		else DoSelfDamage(client, weapon);

		if (!TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged))	// First blood crits
		{
			result = false;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action fwdOnTakeDamage(LastRequest lr, const JBPlayer player, int &attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//JailHunter player = JailHunter(attacker);
	JailHunter victim = JailHunter.Of(player);
	bool validatkr = IsClientValid(attacker);

	if (!victim.bTouched && GetClientTeam(victim.index) == RED && validatkr)
	{
		EmitSoundToAll("prophunt/found.mp3", victim.index);
		victim.bTouched = true;
	}

	if (damagetype & DMG_DROWN && victim.bIsProp && attacker <= 0)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	if (damagetype & DMG_BLAST)
	{
		damage /= 2.5;
		damagetype |= DMG_PREVENT_PHYSICS_FORCE;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action Timer_Round(Handle timer)	// Same structure as the core plugin's timer system
{
	if (NOTPH)
		return Plugin_Stop;

	int time = iGameTime;
	iGameTime--;
	switch (time)
	{
		case 60:
		{
			char s[PLATFORM_MAX_PATH];
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins60sec0%i.mp3", GetRandomInt(1, 6));
			EmitSoundToAll(s);
		}
		case 30:
		{
			char s[PLATFORM_MAX_PATH];
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins30sec0%i.mp3", GetRandomInt(1, 6));
			EmitSoundToAll(s);
		}
		case 10:EmitSoundToAll("vo/announcer_dec_missionbegins10sec01.mp3");
	}

	if (!time)
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, sizeof(s), "vo/announcer_am_roundstart0%i.mp3", GetRandomInt(1, 4));
		EmitSoundToAll(s);

		char buffer[256];
		g_LR.GetParameterString("HuntersReleasedMessage", buffer, sizeof(buffer));

		if (buffer[0] != '\0')
			CPrintToChatAll("%t %s", "Plugin Tag", buffer);

		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i))
				continue;
			if (!IsPlayerAlive(i))
				continue;
			if (GetClientTeam(i) != BLU)
				continue;

			SetEntityMoveType(i, MOVETYPE_WALK);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock bool GetModelNameForClient(const int client, const char[] modelName, char[] name, int maxlen)
{
	PropData propData;

	if (g_PropData.GetArray(modelName, propData, sizeof(propData)))
	{
		strcopy(name, maxlen, propData.PropData_Name);
		return true;
	}
	else
	{
		strcopy(name, maxlen, modelName);
		return false;
	}
}

stock void SwitchView(const int client, bool observer, bool viewmodel)
{
	JailHunter(client).bFirstPerson = !observer;

	SetVariantInt(observer ? 1 : 0);
	AcceptEntityInput(client, "SetForcedTauntCam");

	SetVariantInt(observer ? 1 : 0);
	AcceptEntityInput(client, "SetCustomModelVisibletoSelf");
}

public void OnGameFrame()
{
	if (NOTPH)
		return;

	JailHunter player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		player = JailHunter(i);
		if (!player.bFlaming)
			continue;

		if (player.iFlameCount++ % 3)
			continue;

		int weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");

		if (IsValidEntity(weapon))
		{
			DoSelfDamage(i, weapon);
			AddVelocity(i, 1.0);
		}
	}
}

public void RemoveRagdoll(const int client)
{
	if (!IsClientValid(client))
		return;

	int rag = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (rag > MaxClients && IsValidEntity(rag))
		AcceptEntityInput(rag, "Kill");

	RemoveAnimeModel(client);
}

stock void RemoveAnimeModel(const int client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(client))
	{
		SetVariantString("0 0 0");
		AcceptEntityInput(client, "SetCustomModelOffset");

		AcceptEntityInput(client, "ClearCustomModelRotation");

		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");

		SetEntProp(client, Prop_Send, "m_bForcedSkin", false);
		SetEntProp(client, Prop_Send, "m_nForcedSkin", 0);
	}
}
// TODO: Use the prophunt config with this. This is UGLY
stock void DoSelfDamage(const int client, const int weapon)
{
	float damage;
	char classname[32]; GetEntityClassname(weapon, classname, sizeof(classname));

	if (!strcmp(classname, "tf_weapon_flamethrower", false))
		damage = 1.0;
	else if (!strcmp(classname, "tf_weapon_pipebomblauncher", false) || !strcmp(classname, "tf_weapon_rocketlauncher", false)
	 	  || !strcmp(classname, "tf_weapon_rocketlauncher_directhit", false) || !strcmp(classname, "tf_weapon_grenadelauncher", false))
		damage = 6.0;
	else if (!strcmp(classname, "tf_weapon_shotgun_primary", false) || !strcmp(classname, "tf_weapon_sentry_revenge", false)
		  || !strcmp(classname, "tf_weapon_shotgun_hwg", false) || !strcmp(classname, "tf_weapon_flaregun", false)
		  || !strcmp(classname, "tf_weapon_shotgun_pyro", false) || !strcmp(classname, "tf_weapon_sniperrifle", false)
		  || !strcmp(classname, "tf_weapon_jar", false) || !strcmp(classname, "tf_weapon_shotgun_soldier", false))
		damage = 5.0;
	else if (!strcmp(classname, "tf_weapon_pistol", false) || !strcmp(classname, "tf_weapon_smg", false))
		damage = 3.0;
	else if (!strcmp(classname, "tf_weapon_minigun", false) || !strcmp(classname, "tf_weapon_syringegun_medic", false))
		damage = 2.0;
	else damage = 10.0;

	SDKHooks_TakeDamage(client, client, client, damage, DMG_PREVENT_PHYSICS_FORCE);
}

stock void AddVelocity(const int client, const float speed)
{
	float velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

	if (velocity[0] < 200 && velocity[0] > -200)
		velocity[0] *= (1.08 * speed);
	if (velocity[1] < 200 && velocity[1] > -200)
		velocity[1] *= (1.08 * speed);
	if (velocity[2] > 0 && velocity[2] < 400)
		velocity[2] = velocity[2] * 1.15 * speed;

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

public void fwdOnPreThink(LastRequest lr, const JBPlayer Player)
{
	int client = Player.index;
	JailHunter player = JailHunter.Of(Player);
	int buttons = GetClientButtons(client);

	if (GetClientTeam(client) == BLU)
	{
		if (!(buttons & IN_ATTACK))
		{
			player.bFlaming = false;
			player.iFlameCount = 0;
		}
		return;
	}

	if (player.bIsProp)
	{
		if ((buttons & IN_ATTACK) && !player.bHoldingLMB)
		{
			player.bHoldingLMB = true;
			if (!player.bLocked && (buttons & IN_ATTACK) && !(buttons & (IN_FORWARD|IN_MOVELEFT|IN_MOVERIGHT|IN_BACK|IN_JUMP)))
			{
				// If the client is moving, don't allow them to lock in place
				float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
				if (flIsWithin(vel[0], -5.0, 5.0) && flIsWithin(vel[1], -5.0, 5.0) && flIsWithin(vel[2], -5.0, 5.0))
				{
					SetVariantInt(0);
					AcceptEntityInput(client, "SetCustomModelRotates");
					EmitSoundToClient(client, "buttons/button24.wav");
					player.bLocked = true;
				}
			}
		}
		else player.bHoldingLMB = false;

		if (player.bLocked && (buttons & (IN_FORWARD|IN_MOVELEFT|IN_MOVERIGHT|IN_BACK|IN_JUMP)))
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetCustomModelRotates");
			EmitSoundToClient(client, "buttons/button3.wav");
			player.bLocked = false;
		}

		if ((buttons & IN_ATTACK2) && !player.bHoldingRMB)
		{
			player.bHoldingRMB = true;
			if (player.bFirstPerson)
			{
				PrintHintText(client, "Third Person mode selected");
				SwitchView(client, true, false);
			}
			else
			{
				PrintHintText(client, "First Person mode selected");
				SwitchView(client, false, false);
			}
		}
		else if ((buttons & IN_ATTACK2) != IN_ATTACK2)
			player.bHoldingRMB = false;
	}
}

int NoSS[7]  = { 2, 3, 4, 5, 6, 7, 9 };
int NoHvy[6] = { 2, 3, 4, 5, 6, 9 };
int iHeavy;
public void fwdOnRoundStartPlayer(LastRequest lr, const JBPlayer player)
{
	JailHunter base = JailHunter.Of(player);
	int client = base.index;

	TF2Attrib_RemoveAll(client);
	switch (g_LR.GetParameterNum("FallDamage", 0))
	{
		case 1:TF2Attrib_SetByDefIndex(client, 275, 1.0);
		case 2:if (GetClientTeam(client) == BLU) TF2Attrib_SetByDefIndex(client, 275, 1.0);
		case 3:if (GetClientTeam(client) == RED) TF2Attrib_SetByDefIndex(client, 275, 1.0);
	}
	switch (TF2_GetClientTeam(client))
	{
		case TFTeam_Red:
		{
			TF2_SetPlayerClass(client, TFClass_Scout, _, false);
			TF2_RegeneratePlayer(client);	// Fixes first-person viewmodels
			base.MakeProp(!!g_LR.GetParameterNum("PropNameOnGive", 0));

			switch (g_LR.GetParameterNum("TeleportBehavior", 0))
			{
				case 3, 5:base.TeleportToPosition(WRED);
				case 4:base.TeleportToPosition(FREEDAY);
			}

			base.bTouched = false;
			base.iRolls = 0;
		}
		case TFTeam_Blue:
		{
			if (g_LR.GetParameterNum("ForceBluePyro", 0))
				TF2_SetPlayerClass(client, TFClass_Pyro, _, false);

			TFClassType class = TF2_GetPlayerClass(client);

			if (class == TFClass_Scout || class == TFClass_Spy)
			{
				TF2_SetPlayerClass(client, view_as< TFClassType >(NoSS[GetRandomInt(0, 5)]), _, false);
				CPrintToChat(client, "%t Your illegal class has been changed.", "Plugin Tag");
			}
			else if (class == TFClass_Heavy && ++iHeavy > 2)
			{
				TF2_SetPlayerClass(client, view_as< TFClassType >(NoHvy[GetRandomInt(0, 4)]), _, false);
				CPrintToChat(client, "%t There are too many Heavies on Blue team.", "Plugin Tag");
			}
			else if (class == TFClass_Pyro && g_LR.GetParameterNum("Airblast", 0))
				TF2Attrib_SetByDefIndex(client, 823, 1.0);
			TF2_RegeneratePlayer(client);

			switch (g_LR.GetParameterNum("TeleportBehavior", 0))
			{
				case 1, 5:base.TeleportToPosition(WBLU);
				case 2:base.TeleportToPosition(FREEDAY);
			}
		}
	}
	if (g_LR.GetParameterNum("StaticPropInfo", 0))
		QueryClientConVar(client, "r_staticpropinfo", KickCallBack);
}
public void fwdOnRoundStart(LastRequest lr)
{
	float rerolltime = g_LR.GetParameterFloat("RerollTime", 0.0);
	if (rerolltime != 0.0)
		SetPawnTimer(DisallowRerolls, rerolltime, gamemode.iRoundCount);

	bAbleToReroll = true;
	bFirstBlood = true;

	FindConVar("sv_gravity").SetInt(500);
	int freeze = g_LR.GetParameterNum("FreezeTime", 0);
	// ServerCommand("sm_freeze @blue %i", freeze);
	if (!freeze)
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, sizeof(s), "vo/announcer_am_roundstart0%i.mp3", GetRandomInt(1, 4));
		EmitSoundToAll(s);

		char buffer[256];
		g_LR.GetParameterString("HuntersReleasedMessage", buffer, sizeof(buffer));

		if (buffer[0] != '\0')
			CPrintToChatAll("%t %s", "Plugin Tag", buffer);
		return;
	}

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		if (GetClientTeam(i) != BLU)
			continue;
		SetEntityMoveType(i, MOVETYPE_NONE);
	}

	switch (freeze)
	{
		case 60:
		{
			char s[PLATFORM_MAX_PATH];
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins60sec0%i.mp3", GetRandomInt(1, 6));
			EmitSoundToAll(s);
		}
		case 30:
		{
			char s[PLATFORM_MAX_PATH];
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins30sec0%i.mp3", GetRandomInt(1, 6));
			EmitSoundToAll(s);
		}
		case 10:EmitSoundToAll("vo/announcer_dec_missionbegins10sec01.mp3");
	}

	iGameTime = freeze;
	CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT);
	char buffer[256];
	g_LR.GetParameterString("ActivationMessage", buffer, sizeof(buffer));
	if (buffer[0] != '\0')
	{
		char timestr[8]; IntToString(freeze, timestr, sizeof(timestr));
		ReplaceString(buffer, sizeof(buffer), "{TIME}", timestr);
		CPrintToChatAll("%t %s", "Plugin Tag", buffer);
	}
}
public void fwdOnRoundEnd(LastRequest lr, Event event)
{
	iHeavy = 0;
	FindConVar("sv_gravity").SetInt(800);
	bAbleToReroll = false;
}
public void fwdOnBlueTouchRed(LastRequest lr, const JBPlayer player, const JBPlayer victim)
{
	JailHunter base = JailHunter.Of(victim);
	if (!base.bTouched && base.bIsProp)
	{
		base.bTouched = true;
		EmitSoundToAll("prophunt/found.mp3", base.index);
	}
}
public void fwdOnRedThink(LastRequest lr, const JBPlayer player)
{
	SetEntPropFloat(player.index, Prop_Send, "m_flMaxspeed", 400.0);
}
public void fwdOnBlueThink(LastRequest lr, const JBPlayer player)
{
	int client = player.index;
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 300.0);

	if (TF2_GetPlayerClass(client) == TFClass_Pyro)
	{
		int shotgun = GetPlayerWeaponSlot(client, 1);
		if (IsValidEntity(shotgun))
		{
			char classname[32]; GetEntityClassname(shotgun, classname, sizeof(classname));
			if (StrEqual(classname, "tf_weapon_shotgun_pyro", false))
			{
				int ammoOffset = GetEntProp(shotgun, Prop_Send, "m_iPrimaryAmmoType");
				int clip = GetEntProp(shotgun, Prop_Send, "m_iClip1");
				SetEntProp(client, Prop_Send, "m_iAmmo", 2 - clip, _, ammoOffset);
				if (clip > 2)
					SetEntProp(shotgun, Prop_Send, "m_iClip1", 2);
			}
		}
	}
}
public void fwdOnPlayerDied(LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event)
{
	JailHunter player = JailHunter.Of(victim);
	player.Init_PH(true);

	if (GetClientTeam(victim.index) == BLU)
		return;

	RequestFrame(RemoveRagdoll, victim.index);
	if (player.index != attacker.index)
		EmitSoundToClient(player.index, "prophunt/snaaake.mp3");

	if (!IsClientValid(attacker.index))
		return;

	SetEntityHealth(attacker.index, GetEntProp(attacker.index, Prop_Data, "m_iMaxHealth"));

	if (bFirstBlood && attacker.index != victim.index)
	{
		TF2_AddCondition(attacker.index, TFCond_Kritzkrieged, 8.0);
		char s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "vo/announcer_am_firstblood0%i.mp3", GetRandomInt(1, 6));
		EmitSoundToAll(s);
		bFirstBlood = false;
	}
}
public void fwdOnPlayerSpawned(LastRequest lr, const JBPlayer player)
{
	if (GetClientTeam(player.index) == RED)
		JailHunter.Of(player).MakeProp(!!g_LR.GetParameterNum("PropNameOnGive", 0));
}
public void fwdOnResetVariables(LastRequest lr, const JBPlayer Player)
{
	int client = Player.index;
	JailHunter player = JailHunter.Of(Player);
	player.iRolls = 0;
	player.iLastProp = -1;
	player.iFlameCount = 0;
	player.bTouched = false;
	player.bIsProp = false;
	player.bFlaming = false;
	player.bLocked = false;
	player.bHoldingLMB = false;
	player.bHoldingRMB = false;
	player.bFirstPerson = false;

	if (GetClientTeam(client) == RED)
	{
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(client, "DispatchEffect");
		
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");

		SetVariantString("0 0 0");
		AcceptEntityInput(client, "SetCustomModelOffset");
		AcceptEntityInput(client, "ClearCustomModelRotation");
	}
}

public Action fwdOnTimeEnd(LastRequest lr)
{
	ForceTeamWin(RED);
	return Plugin_Handled;
}

public Action fwdOnPlayerPreppedPre(LastRequest lr, const JBPlayer Player)
{
	if (GetClientTeam(Player.index) != RED)
		return Plugin_Continue;

	if (GetLivingPlayers(RED) == 1)	// If the last prop
		return Plugin_Handled;

	JailHunter player = JailHunter.Of(Player);
	if (!player.bIsProp)
		player.MakeProp(!!g_LR.GetParameterNum("PropNameOnGive", 0));

	return Plugin_Handled;
}

public Action fwdOnSetWardenLock(LastRequest lr, const bool status)
{
	return !status ? Plugin_Handled : Plugin_Continue;
}

public void fwdOnPlayerHurt(LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event)
{
	bool validatkr = IsClientValid(attacker.index);
	if (validatkr && g_LR.GetParameterNum("LeechDamage", 0) && JailHunter.Of(victim).bIsProp)
	{
		int hp, maxhp;
		hp = GetEntProp(attacker.index, Prop_Data, "m_iHealth");
		maxhp = GetEntProp(attacker.index, Prop_Data, "m_iMaxHealth");
		hp += event.GetInt("damageamount");
		if (hp > maxhp)
			hp = maxhp;

		SetEntityHealth(attacker.index, hp);
	}
}

public void LoadJBHooks()
{
	g_LR.AddHook(OnLRActivate, fwdOnRoundStart);
	g_LR.AddHook(OnLRActivatePlayer, fwdOnRoundStartPlayer);
	g_LR.AddHook(OnRoundEnd, fwdOnRoundEnd);
	g_LR.AddHook(OnRedThink, fwdOnRedThink);
	g_LR.AddHook(OnBlueThink, fwdOnBlueThink);
	g_LR.AddHook(OnPlayerDied, fwdOnPlayerDied);
	g_LR.AddHook(OnPlayerSpawned, fwdOnPlayerSpawned);
	g_LR.AddHook(OnTakeDamage, fwdOnTakeDamage);
	g_LR.AddHook(OnVariableReset, fwdOnResetVariables);
	g_LR.AddHook(OnTimeEnd, fwdOnTimeEnd);
	g_LR.AddHook(OnLastPrisoner, fwdOnLastPrisoner);
	g_LR.AddHook(OnCheckLivingPlayers, fwdOnCheckLivingPlayers);
	g_LR.AddHook(OnPlayerPrepped, fwdOnPlayerPreppedPre);
	g_LR.AddHook(OnPreThink, fwdOnPreThink);
	g_LR.AddHook(OnCalcAttack, fwdOnCalcAttack);
	g_LR.AddHook(OnSetWardenLock, fwdOnSetWardenLock);
	g_LR.AddHook(OnPlayerTouch, fwdOnBlueTouchRed);
	g_LR.AddHook(OnPlayerHurt, fwdOnPlayerHurt);

	JB_Hook(OnDownloads, fwdOnDownloads);
	JB_Hook(OnClientInduction, fwdOnClientInduction);
}