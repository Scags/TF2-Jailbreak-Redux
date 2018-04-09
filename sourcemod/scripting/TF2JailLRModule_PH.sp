#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <tf2_stocks>
#include <tf2attributes>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required
#include "TF2JailRedux/stocks.inc"

#define PLUGIN_VERSION		"1.0.3"

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

enum PropData
{
	String:PropData_Name[96],
	String:PropData_Offset[32], // 3 digits, plus 2 spaces, plus a null terminator
	String:PropData_Rotation[32], // 3 digits, plus 2 spaces, plus a null terminator
}

methodmap JailHunter < JBPlayer
{
	public JailHunter( const int w, bool userid = false )
	{
		return view_as< JailHunter >( JBPlayer(w, userid) );
	}

	property int iRolls
	{
		public get() 				{ return this.GetValue("iRolls"); }
		public set( const int i ) 	{ this.SetValue("iRolls", i); }
	}
	property int iLastProp
	{
		public get() 				{ return this.GetValue("iLastProp"); }
		public set( const int i ) 	{ this.SetValue("iLastProp", i); }
	}
	property int iFlameCount
	{
		public get() 				{ return this.GetValue("iFlameCount"); }
		public set( const int i ) 	{ this.SetValue("iFlameCount", i); }
	}

	property bool bTouched
	{
		public get() 				{ return this.GetValue("bTouched"); }
		public set( const bool i ) 	{ this.SetValue("bTouched", i); }
	}
	property bool bLast 
	{
		public get() 				{ return this.GetValue("bLast"); }
		public set( const bool i ) 	{ this.SetValue("bLast", i); }
	}
	/*property bool bRerolled 
	{
		public get() 				{ return this.GetValue("bRerolled"); }
		public set( const bool i ) 	{ this.SetValue("bRerolled", i); }
	}*/
	property bool bIsProp 
	{
		public get() 				{ return this.GetValue("bIsProp"); }
		public set( const bool i ) 	{ this.SetValue("bIsProp", i); }
	}
	property bool bFlaming 
	{
		public get() 				{ return this.GetValue("bFlaming"); }
		public set( const bool i ) 	{ this.SetValue("bFlaming", i); }
	}
	property bool bLocked 
	{
		public get() 				{ return this.GetValue("bLocked"); }
		public set( const bool i ) 	{ this.SetValue("bLocked", i); }
	}
	property bool bHoldingLMB 
	{
		public get() 				{ return this.GetValue("bHoldingLMB"); }
		public set( const bool i ) 	{ this.SetValue("bHoldingLMB", i); }
	}
	property bool bHoldingRMB 
	{
		public get() 				{ return this.GetValue("bHoldingRMB"); }
		public set( const bool i ) 	{ this.SetValue("bHoldingRMB", i); }
	}
	property bool bFirstPerson 
	{
		public get() 				{ return this.GetValue("bFirstPerson"); }
		public set( const bool i ) 	{ this.SetValue("bFirstPerson", i); }
	}
	property TFClassType iOldClass
	{
		public get() 				{ return this.GetValue("iOldClass"); }
		public set( const TFClassType i ){ this.SetValue("iOldClass", i); }
	}

	public void MakeProp(const bool announce, bool override = true, bool loseweps = true)
	{
		this.PreEquip(loseweps);
		int client = this.index;
		PropData propData[PropData];
		if (override)
			this.iLastProp = -1;

		// fire in a nice random model
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

		
		// This wackiness with [0] is required when dealing with enums containing strings
		char modelName[96];
		if (g_PropData.GetArray(model, propData[0], sizeof(propData)))
		{
			strcopy(modelName, sizeof(modelName), propData[PropData_Name]);
			strcopy(offset, sizeof(offset), propData[PropData_Offset]);
			strcopy(rotation, sizeof(rotation), propData[PropData_Rotation]);
		}
		
		if (announce)
			CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are now disguised as {default}%s{burlywood}.", modelName);
		
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
	public void Init_PH(bool compl = false)
	{
		this.iRolls = 0;
		this.iLastProp = -1;
		this.iFlameCount = 0;
		this.bTouched = false;
		this.bLast = false;
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

public JailHunter ToJailHunter(const JBPlayer Player)
{
	return view_as< JailHunter >(Player);
}

public Plugin myinfo =
{
	name = "TF2Jail PH LR Module",
	author = "Ragenewb, just about all props to Darkimmortal, Geit, and Powerlord",
	description = "Prophunt embedded as an LR for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = ""
};

enum 
{
	FallDamage = 0,
	Airblast,
	Reroll,
	RerollCount,
	RerollTime,
	StaticPropInfo,
	DamageBlocksPropChange,
	PropNameOnGive,
	ForceBluePyro,
	FreezeTime,
	Teleportation,
	RoundTime,
	Enabled,
	PickCount,
	ThisPlugin,
	MedicToggling,
	Version
};

bool 
	bFirstBlood,
	bAbleToReroll
;

int 
	iGameTime	// Pre-round-start global time
;

ConVar
	JBPH[Version + 1]
;

JBGameMode gamemode;

public void OnPluginStart()
{
	JBPH[Enabled]				 = CreateConVar("sm_jbph_enabled", "1", "Enabled the TF2Jail PH Sub-Plugin?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	JBPH[Version] 				 = CreateConVar("jbph_version", PLUGIN_VERSION, "PropHunt Version (Do not touch)", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	JBPH[FallDamage]			 = CreateConVar("sm_jbph_fall_damage", "1", "Enabled/Disable fall damage? (3: RED only, 2: BLU only, 1: ALL, 0: NONE)", FCVAR_NOTIFY, true, 0.0, true, 3.0); 
	JBPH[Airblast] 				 = CreateConVar("sm_jbph_airblast", "1", "Disable pyro's ability to airblast? (This doesn't matter if you've disabled it under the core TF2Jail plugin cfg)", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	JBPH[Reroll] 				 = CreateConVar("sm_jbph_propreroll", "1", "Allow players to reroll their props?", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	JBPH[RerollCount] 			 = CreateConVar("sm_jbph_propreroll_count", "1", "If enabled, how many times can players \"!propreroll\"?", FCVAR_NOTIFY, true, 0.0);
	JBPH[RerollTime] 			 = CreateConVar("sm_jbph_propreroll_time", "15", "Time (in seconds) that RED team has to reroll their props (If enabled)", FCVAR_NOTIFY, true, 0.0);
	JBPH[StaticPropInfo] 		 = CreateConVar("sm_jbph_prop_haxors", "1", "Kick players who have r_staticpropinfo set to 1? (Allows players to see prop path names within maps) ~~Keep in mind this is a Jailbreak server, and players are not joining specifically for Prophunt~~", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	JBPH[DamageBlocksPropChange] = CreateConVar("sm_jbph_damage_block", "1", "Are players able to reroll their props if they are on fire, bleeding, jarated, etc?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	JBPH[PropNameOnGive] 		 = CreateConVar("sm_jbph_prop_name", "1", "Upon receiving a prop, will players be given a message stating the name of their prop?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	JBPH[ForceBluePyro] 		 = CreateConVar("sm_jbph_forcepyro", "0", "Force BLU team as pyro?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	JBPH[FreezeTime] 			 = CreateConVar("sm_jbph_freeze_time", "30", "Freeze BLU team for 'x' seconds", FCVAR_NOTIFY, true, 0.0, true, 120.0);
	JBPH[Teleportation] 		 = CreateConVar("sm_jbph_teleport", "1", "Teleport players to warday/freeday locations? (0: Disabed, 1: BLU to Warday, 2: BLU to Freeday, 3: RED to Warday, 4: RED to Freeday, 5: BOTH to Warday)", FCVAR_NOTIFY, true, 0.0, true, 5.0);	
	JBPH[RoundTime] 			 = CreateConVar("sm_jbph_round_time", "300", "Round time in seconds. THIS ADDS TO YOUR \"sm_jbph_freeze_time\" CVAR.", FCVAR_NOTIFY, true, 0.0);
	JBPH[PickCount] 			 = CreateConVar("sm_jbvsh_lr_max", "5", "How many times can Prophunt be picked in a single map? 0 for no limit.", FCVAR_NOTIFY, true, 0.0);
	JBPH[ThisPlugin] 			 = CreateConVar("sm_jbph_ilrtype", "14", "This sub-plugin's last request index. DO NOT CHANGE THIS UNLESS YOU KNOW WHAT YOU'RE DOING", FCVAR_NOTIFY, true, 0.0);
	JBPH[MedicToggling] 		 = CreateConVar("sm_jbph_medic_toggle", "1", "Disable the medic room?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	JBPH[ThisPlugin].AddChangeHook(OnTypeChanged);

	RegConsoleCmd("sm_propreroll", Cmd_Reroll);

	AutoExecConfig(true, "LRModulePH");

	g_PropData = new StringMap();
	g_PropPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_PropNamesIndex = new ArrayList();
	g_ModelOffset = new ArrayList(ByteCountToCells(11));
	g_ModelRotation = new ArrayList(ByteCountToCells(11));
}

public void OnAllPluginsLoaded()
{
	TF2JailRedux_RegisterPlugin("LRModule_PH");
	gamemode = JBGameMode();
	CheckJBHooks();
}
int JBPHIndex;
public void OnConfigsExecuted()
{
	JBPHIndex = JBPH[ThisPlugin].IntValue;
}

public void OnTypeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	JBPHIndex = StringToInt(newValue);
}
#define NotPH 				( gamemode.GetProperty("iLRType") != (JBPHIndex) )

public void OnMapStart()
{
	// Sorry but all of the cfg is just too much
	// This is a Jailbreak server, things have to be a little different
	ParsePropCFG();
}

public void fwdOnClientInduction(const JBPlayer Player)
{
	JailHunter base = ToJailHunter(Player);
	base.iRolls = 0;
	base.iLastProp = -1;
	base.iFlameCount = 0;
	base.bTouched = false;
	base.bLast = false;
	base.bIsProp = false;
	base.bFlaming = false;
	base.bLocked = false;
	base.bHoldingLMB = false;
	base.bHoldingRMB = false;
	base.bFirstPerson = false;
	base.iOldClass = TFClass_Unknown;
}

public void fwdOnDownloads()
{
	char s[PLATFORM_MAX_PATH];
	for (int i = 1; i <= 6; i++)
	{
		if (i <= 4)
		{
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_am_roundstart0%i.mp3", i);
			PrecacheSound(s, true);
		}

		Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins60sec0%i.mp3", i);
		PrecacheSound(s, true);

		Format(s, PLATFORM_MAX_PATH, "vo/announcer_dec_missionbegins30sec0%i.mp3", i);
		PrecacheSound(s, true);

		Format(s, PLATFORM_MAX_PATH, "vo/announcer_am_firstblood0%i.mp3", i);
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
	PropData propData[PropData];
	do
	{
		kv.GetSectionName(modelPath, PLATFORM_MAX_PATH);
		kv.GetString("name", propData[PropData_Name], sizeof(propData[PropData_Name]), "");

		kv.GetString("offset", propData[PropData_Offset], sizeof(propData[PropData_Offset]), "0 0 0");
		kv.GetString("rotation", propData[PropData_Rotation], sizeof(propData[PropData_Rotation]), "0 0 0");

		if (!strlen(propData[PropData_Name]))
		{
			// No "name" or "en" block means no prop name, but this isn't an error that prevents us from using the prop for offset and rotation
			LogError("Error getting prop name for %s", modelPath);
		}

		if (!g_PropData.SetArray(modelPath, propData[0], sizeof(propData), false))
		{
			LogError("Error saving prop data for %s", modelPath);
			continue;
		}
		PrecacheModel(modelPath, true);
		g_PropNamesIndex.Push(counter);
		g_PropPath.PushString(modelPath);

		counter++;
	} while kv.GotoNextKey(false);
		
	delete kv;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
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

public void fwdOnCheckLivingPlayers()
{
	if (gamemode.GetProperty("iRoundState") != StateRunning || NotPH)
		return;

	JailHunter base;
	bool query = JBPH[StaticPropInfo].BoolValue;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (!IsPlayerAlive(i))
		{
			base = JailHunter(i);
			if (base.iOldClass != TFClass_Unknown)
			{
				TF2_SetPlayerClass(i, base.iOldClass);
				base.iOldClass = TFClass_Unknown;
			}
			continue;
		}
		if (query)
			QueryClientConVar(i, "r_staticpropinfo", KickCallBack);
	}
}

public Action fwdOnLastPrisoner()
{
	if (gamemode.GetProperty("iRoundState") != StateRunning || NotPH)
		return Plugin_Continue;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == RED)
		{
			TF2_RegeneratePlayer(i);
			SetEntityHealth(i, GetEntProp(i, Prop_Data, "m_iMaxHealth"));

			JailHunter player = JailHunter(i);
			player.MakeProp(JBPH[PropNameOnGive].BoolValue, false, false);
			player.SetWepInvis(0);
		}
		else TF2_AddCondition(i, TFCond_Jarated, 15.0);
	}

	EmitSoundToAll("prophunt/oneandonly.mp3");
	return Plugin_Continue;
}

public void DisallowRerolls(const int roundcount)
{
	if (gamemode.GetProperty("iRoundCount") == roundcount)
		bAbleToReroll = false;
}

public Action Cmd_Reroll(int client, int args)
{
	if (!IsClientValid(client) || NotPH || !IsPlayerAlive(client) || gamemode.GetProperty("iRoundState") != StateRunning)
		return Plugin_Handled;

	if (!JBPH[Reroll].BoolValue)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Rerolling has been disabled.");
		return Plugin_Handled;
	}
	JailHunter player = JailHunter(client);
	if (!player.bIsProp)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not a prop.");
		return Plugin_Handled;
	}
	if (GetClientTeam(client) != RED)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not on Red team.");
		return Plugin_Handled;
	}
	if (!bAbleToReroll)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are not allowed to reroll at this time.");
		return Plugin_Handled;
	}
	if (player.iRolls >= JBPH[RerollCount].IntValue)
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You have rerolled the maximum amount of times this round.");
		return Plugin_Handled;
	}
	if ( JBPH[DamageBlocksPropChange].BoolValue 
	 && (TF2_IsPlayerInCondition(client, TFCond_Bleeding)
	  || TF2_IsPlayerInCondition(client, TFCond_OnFire)
	  || TF2_IsPlayerInCondition(client, TFCond_LostFooting)
	  || TF2_IsPlayerInCondition(client, TFCond_Jarated) 
	  || TF2_IsPlayerInCondition(client, TFCond_Milked)) ) 
	{
		CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} You are under effects and can't change!");
		return Plugin_Handled;
	}

	player.MakeProp(JBPH[PropNameOnGive].BoolValue, true);
	player.iRolls++;

	return Plugin_Handled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool & result)
{
	if (!JBPH[Enabled].BoolValue || !IsClientValid(client) || gamemode.GetProperty("iRoundState") != StateRunning || NotPH)
		return Plugin_Continue;

	if (IsPlayerAlive(client) && GetClientTeam(client) == BLU && IsValidEntity(weapon))
	{
		if (!strcmp(weaponname, "tf_weapon_flamethrower"))
		{
			JailHunter player = JailHunter(client);
			player.bFlaming = true;
			player.iFlameCount = 0;
		}
		else DoSelfDamage(client, weapon);
		
		result = false;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action fwdOnHookDamage(const JBPlayer player, int &attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!JBPH[Enabled].BoolValue || NotPH || !IsClientValid(player.index))
		return Plugin_Continue;

	//JailHunter player = JailHunter(attacker);
	JailHunter victim = ToJailHunter(player);

	if (!victim.bTouched && GetClientTeam(victim.index) == RED)
	{
		EmitSoundToAll("prophunt/found.mp3", victim.index);
		victim.bTouched = true;
	}

	if (damagetype & DMG_DROWN && victim.bIsProp && attacker <= 0)
	{
		damage *= 0.0;
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
	if (NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
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
		CPrintToChatAll("{burlywood}Ready or not, here they come!");

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
	int propData[PropData];
		
	if (g_PropData.GetArray(modelName, propData[0], sizeof(propData)))
	{
		strcopy(name, maxlen, propData[PropData_Name]);
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
	/*SetEntPropEnt(target, Prop_Send, "m_hObserverTarget", observer ? target:-1);
	SetEntProp(target, Prop_Send, "m_iObserverMode", observer ? 1:0);
	SetEntData(target, g_oFOV, observer ? 100:GetEntData(target, g_oDefFOV, 4), 4, true);
	SetEntProp(target, Prop_Send, "m_bDrawViewmodel", viewmodel ? 1:0);*/
	
	SetVariantInt(observer ? 1 : 0);
	AcceptEntityInput(client, "SetForcedTauntCam");

	SetVariantInt(observer ? 1 : 0);
	AcceptEntityInput(client, "SetCustomModelVisibletoSelf");
}

public void OnGameFrame()
{
	if (!JBPH[Enabled].BoolValue || gamemode.GetProperty("iRoundState") != StateRunning || NotPH)
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


public void fwdOnPreThink(const JBPlayer Player, int buttons)
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	int client = Player.index;

	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	JailHunter player = ToJailHunter(Player);
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

// Same as in jailhandler.sp, forcing people as the sniper class crashes servers
int NoSS[6]  = { 3, 4, 5, 6, 7, 9 };
int NoHvy[5] = { 3, 4, 5, 6, 9 };
int iHeavy;
public void fwdOnLRRoundActivate(const JBPlayer player)
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	JailHunter base = ToJailHunter(player);
	int client = base.index;

	if (gamemode.GetProperty("bTF2Attribs"))
	{
		TF2Attrib_RemoveAll(client);
		switch (JBPH[FallDamage].IntValue)
		{
			case 1:TF2Attrib_SetByDefIndex(client, 275, 1.0);
			case 2:if (GetClientTeam(client) == BLU) TF2Attrib_SetByDefIndex(client, 275, 1.0);
			case 3:if (GetClientTeam(client) == RED) TF2Attrib_SetByDefIndex(client, 275, 1.0);
		}
	}
	switch (TF2_GetClientTeam(client))
	{
		case TFTeam_Red:
		{
			base.iOldClass = TF2_GetPlayerClass(client);
			TF2_SetPlayerClass(client, TFClass_Scout);
			base.MakeProp(JBPH[PropNameOnGive].BoolValue);
			SetEntityHealth(client, 125);

			switch (JBPH[Teleportation].IntValue)
			{
				case 3, 5:if (gamemode.GetProperty("bWardayTeleportSetRed")) base.TeleportToPosition(WRED);
				case 4:if (gamemode.GetProperty("bFreedayTeleportSet")) base.TeleportToPosition(FREEDAY);
			}

			base.bTouched = false;
			base.iRolls = 0;
		}
		case TFTeam_Blue:
		{
			if (JBPH[ForceBluePyro].BoolValue)
				TF2_SetPlayerClass(client, TFClass_Pyro);

			if (TF2_GetPlayerClass(client) == TFClass_Scout || TF2_GetPlayerClass(client) == TFClass_Spy)
			{
				TF2_SetPlayerClass(client, view_as< TFClassType >(NoSS[GetRandomInt(0, 5)]));
				CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} Your illegal class has been changed.");
			}
			if (TF2_GetPlayerClass(client) == TFClass_Heavy)
			{
				if (iHeavy < 2)
					iHeavy++;
				else
				{
					TF2_SetPlayerClass(client, view_as< TFClassType >(NoHvy[GetRandomInt(0, 4)]));
					CPrintToChat(client, "{crimson}[TF2Jail]{burlywood} There are too many Heavies on Blue team.");
				}
			}
			if (TF2_GetPlayerClass(client) == TFClass_Pyro && JBPH[Airblast].BoolValue && gamemode.GetProperty("bTF2Attribs"))
				TF2Attrib_SetByDefIndex(client, 823, 1.0);
			TF2_RegeneratePlayer(client);

			switch (JBPH[Teleportation].IntValue)
			{
				case 1, 5:base.TeleportToPosition(WBLU);
				case 2:base.TeleportToPosition(FREEDAY);
			}
		}
	}
	if (JBPH[StaticPropInfo].BoolValue)
		QueryClientConVar(client, "r_staticpropinfo", KickCallBack);
}
public void fwdOnManageRoundStart()
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	gamemode.SetProperty("bDisableCriticals", true);
	gamemode.SetProperty("bIsWardenLocked", true);
	gamemode.SetProperty("bFirstDoorOpening", true);
	gamemode.DoorHandler(OPEN);
	gamemode.OpenAllDoors();

	if (JBPH[MedicToggling].BoolValue)
		gamemode.ToggleMedic(false);
		
	float rerolltime = JBPH[RerollTime].FloatValue;
	if (rerolltime != 0.0)
		SetPawnTimer(DisallowRerolls, rerolltime, gamemode.GetProperty("iRoundCount"));

	bAbleToReroll = true;
	bFirstBlood = true;

	FindConVar("sv_gravity").SetInt(500);
	int freeze = JBPH[FreezeTime].IntValue;
	// ServerCommand("sm_freeze @blue %i", freeze);
	if (!freeze)
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, sizeof(s), "vo/announcer_am_roundstart0%i.mp3", GetRandomInt(1, 4));
		EmitSoundToAll(s);
		CPrintToChatAll("{burlywood}Ready or not, here they come!");
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
	CPrintToChatAll("{burlywood}Hunters will be released in %i seconds.", freeze);
}
public void fwdOnManageRoundEnd()
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	iHeavy = 0;
	FindConVar("sv_gravity").SetInt(800);
	bAbleToReroll = false;
}
public void fwdOnBlueTouchRed(const JBPlayer player, const JBPlayer victim)
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
		return;

	JailHunter base = ToJailHunter(victim);
	if (!base.bTouched)
	{
		base.bTouched = true;
		EmitSoundToAll("prophunt/found.mp3", base.index);
	}
}
public void fwdOnRedThink(const JBPlayer player)
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
		return;

	SetEntPropFloat(player.index, Prop_Send, "m_flMaxspeed", 400.0);
}
public void fwdOnBlueThink(const JBPlayer player)
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
		return;

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
public void fwdOnPlayerDied(const JBPlayer victim, const JBPlayer attacker, Event event)
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
		return;

	JailHunter player = ToJailHunter(victim);
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
public void fwdOnPlayerSpawned(const JBPlayer player)
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning)
		return;

	if (GetClientTeam(player.index) == RED)
		ToJailHunter(player).MakeProp(JBPH[PropNameOnGive].BoolValue);
}
public void fwdOnManageTimeLeft()
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	gamemode.SetProperty("iTimeLeft", JBPH[RoundTime].IntValue + JBPH[FreezeTime].IntValue);
}
public Action fwdOnLRPicked(const JBPlayer Player, const int selection, ArrayList arrLRS)
{
	if (JBPH[Enabled].BoolValue && selection == JBPHIndex)
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} %N has decided to play a round of {default}Prophunt{burlywood}.", Player.index);
	return Plugin_Continue;
}
public void fwdOnLRTextHud(char strHud[128])
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	strcopy(strHud, 128, "Prophunt");
}
public void fwdOnPanelAdd(const int index, char name[64])
{
	if (!JBPH[Enabled].BoolValue || index != JBPHIndex)
		return;

	strcopy(name, sizeof(name), "Prophunt- Find and kill all the cowardly props!");
}
public void fwdOnMenuAdd(const int index, int &max, char strName[32])
{
	if (!JBPH[Enabled].BoolValue || index != JBPHIndex)
		return;

	max = JBPH[PickCount].IntValue;
	strcopy(strName, sizeof(strName), "Prophunt");
}
public void fwdOnResetVariables(const JBPlayer Player)
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return;

	int client = Player.index;
	JailHunter player = ToJailHunter(Player);
	player.iRolls = 0;
	player.iLastProp = -1;
	player.iFlameCount = 0;
	player.bTouched = false;
	player.bLast = false;
	player.bIsProp = false;
	player.bFlaming = false;
	player.bLocked = false;
	player.bHoldingLMB = false;
	player.bHoldingRMB = false;
	player.bFirstPerson = false;
	player.iOldClass = TFClass_Unknown;
	
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

public Action fwdOnTimeEnd()
{
	if (!JBPH[Enabled].BoolValue || NotPH)
		return Plugin_Continue;
	ForceTeamWin(RED);
	return Plugin_Handled;
}
public void fwdOnPlayerPrepped(const JBPlayer Player, Event event)	// For safety, although OnPlayerSpawned should take care of autobalanced players
{
	if (!JBPH[Enabled].BoolValue || NotPH || gamemode.GetProperty("iRoundState") != StateRunning && GetLivingPlayers(RED) != 1)
		return;

	if (GetClientTeam(Player.index) != RED)
		return;

	JailHunter player = ToJailHunter(Player);
	if (!player.bIsProp)
		player.MakeProp(JBPH[PropNameOnGive].BoolValue);
}

public void CheckJBHooks()
{
	if (!JB_HookEx(OnLRRoundActivate, fwdOnLRRoundActivate))
		LogError("Error Loading OnLRRoundActivate Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnManageRoundStart, fwdOnManageRoundStart))
		LogError("Error Loading OnManageRoundStart, Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnManageRoundEnd, fwdOnManageRoundEnd))
		LogError("Error Loading OnManageRoundEnd Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnRedThink, fwdOnRedThink))
		LogError("Error Loading OnRedThink Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnBlueThink, fwdOnBlueThink))
		LogError("Error Loading OnBlueThink Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnPlayerDied, fwdOnPlayerDied))
		LogError("Error loading OnPlayerDied Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnPlayerSpawned, fwdOnPlayerSpawned))
		LogError("Error loading OnPlayerSpawned Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnHookDamage, fwdOnHookDamage))
		LogError("Error loading OnHookDamage Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnClientInduction, fwdOnClientInduction))
		LogError("Error loading OnClientInduction Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnManageTimeLeft, fwdOnManageTimeLeft))
		LogError("Error loading OnManageTimeLeft Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnLRPicked, fwdOnLRPicked))
		LogError("Error loading OnLRPicked Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnLRTextHud, fwdOnLRTextHud))
		LogError("Error loading OnLRTextHud Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnPanelAdd, fwdOnPanelAdd))
		LogError("Error loading OnPanelAdd Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnMenuAdd, fwdOnMenuAdd))
		LogError("Error loading OnMenuAdd Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnDownloads, fwdOnDownloads))
		LogError("Error loading OnDownloads Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnVariableReset, fwdOnResetVariables))
		LogError("Error loading OnVariableReset Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnTimeEnd, fwdOnTimeEnd))
		LogError("Error loading OnTimeEnd Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnLastPrisoner, fwdOnLastPrisoner))
		LogError("Error loading OnLastPrisoner Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnCheckLivingPlayers, fwdOnCheckLivingPlayers))
		LogError("Error loading OnCheckLivingPlayers Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnPlayerPrepped, fwdOnPlayerPrepped))
		LogError("Error loading OnPlayerPrepped Forwards for JB PH Sub-Plugin!");
	if (!JB_HookEx(OnPreThink, fwdOnPreThink))
		LogError("Error Loading OnPreThink Forwards for JB PH Sub-Plugin!");
}