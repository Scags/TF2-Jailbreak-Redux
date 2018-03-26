#include <sourcemod>
#include <morecolors>
#include <tf2jailredux>
#include <tf2_stocks>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define RED 				2
#define BLU 				3

#define PLUGIN_VERSION 		"1.0.0"

public Plugin myinfo =
{
	name = "TF2Jail Redux Weapon-Blocker",
	author = "Scag/Ragenewb",
	description = "Weapon/Wearable blocker made explicitly for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

ArrayList
	hWeaponList[2]	// 0 for Red team, 1 for Blue team
;

ConVar
	bEnabled
;

public void OnPluginStart()
{
	bEnabled = CreateConVar("sm_jbwb_enable", "1", "Enable the TF2Jail Redux Weapon Blocker?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("jbwb_version", PLUGIN_VERSION, "TF2Jail Redux Weapon Blocker version.", FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);

	RegAdminCmd("sm_refreshlist", Cmd_RefreshList, ADMFLAG_GENERIC);

	hWeaponList[0] = new ArrayList();
	hWeaponList[1] = new ArrayList();
}

public void OnAllPluginsLoaded()
{	// Hook into our forward
	JB_Hook(OnPlayerPrepped, fwdOnPlayerPrepped);
}

public void OnMapStart()
{
	RunConfig();
}

public Action Cmd_RefreshList(int client, int args)
{
	CReplyToCommand(client, "{red}[TF2Jail]{tan} Running Weapon Blocker config.");
	RunConfig();
	return Plugin_Handled;
}

public void RunConfig()
{
	char cfg[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, cfg, sizeof(cfg), "configs/tf2jail/weaponblocker.cfg");

	KeyValues kv = new KeyValues("TF2JailRedux_WeaponBlocker");
	if (!kv.ImportFromFile(cfg))
	{
		delete kv;
		SetFailState("Unable to find TF2Jail Redux Weapon Blocker config in path %s!", cfg);
		return;
	}

	if (!kv.GotoFirstSubKey(false))
	{
		delete kv;
		SetFailState("Unable to find TF2Jail Redux Weapon Blocker config in path %s!", cfg);
		return;
	}

	int count, check, team;
	char index[4];
	for (count = 0; count < 2; count++)
		hWeaponList[count].Clear();
	count = 0;

	do
	{
		for (;;)
		{
			IntToString(count, index, 4);
			hWeaponList[team].Push( kv.GetNum(index, -1) );
			count++;
			check = hWeaponList[team].Length-1;
			if (hWeaponList[team].Get(check) == -1)	// Bleh
			{ hWeaponList[team].Erase(check); break; }
		}
		count = 0;
		team++;
	} while kv.GotoNextKey(false);

	delete kv;

	for (count = 0; count < 2; count++)
		if (hWeaponList[count].Get(0) == -1)
			hWeaponList[count].Clear();
}

public void fwdOnPlayerPrepped(const JBPlayer Player)
{
	if (!bEnabled.BoolValue)
		return;

	int team = GetClientTeam(Player.index) == RED ? 0 : 1;
	int len = hWeaponList[team].Length;

	if (len)
	{
		int[] prepwep = new int[1];
		int client = Player.index, i, index, u, wep;
		char classname[64];
		int active;
		for (i = 0; i < 3; i++)	// Prepare for wicked laziness and hacky coding
		{
			active = 0;
			wep = GetPlayerWeaponSlot(client, i);
			wep = (wep > MaxClients && IsValidEntity(wep)) ? GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") : -1;

			for (u = 0; u < len; u++)
			{
				prepwep[0] = hWeaponList[team].Get(u);

				if (wep == prepwep[0])
				{ active = 1; break; }	// 1 is weapon

				switch (prepwep[0])
				{
					case 57, 131, 133, 230, 231, 406, 444, 642:	// Secondaries
					{
						if (IsValidEntity(FindPlayerBack(client, prepwep, 1)) && i)
						{ active = 2; break; }
					}
					case 405, 608:								// Primaries
					{
						if (IsValidEntity(FindPlayerBack(client, prepwep, 1)) && !i)
						{ active = 2; break; }
					}
				}
			}

			if (!active)	// If no valid weapon to be spawned, try again
				continue;

			switch (TF2_GetPlayerClass(client))
			{
				case TFClass_Scout:
				{
					classname = (!i ? "tf_weapon_scattergun" : (i == 1 ? "tf_weapon_pistol_scout" : "tf_weapon_bat"));
					index = (!i ? 13 : (i == 1 ? 23 : 0));
				}
				case TFClass_Soldier:
				{
					classname = (!i ? "tf_weapon_rocketlauncher" : (i == 1 ? "tf_weapon_shotgun_soldier" : "tf_weapon_shovel"));
					index = (!i ? 18 : (i == 1 ? 10 : 6));
				}
				case TFClass_Pyro:
				{
					classname = (!i ? "tf_weapon_flamethrower" : (i == 1 ? "tf_weapon_shotgun_pyro" : "tf_weapon_fireaxe"));
					index = (!i ? 21 : (i == 1 ? 12 : 2));
				}
				case TFClass_DemoMan:
				{
					classname = (!i ? "tf_weapon_grenadelauncher" : (i == 1 ? "tf_weapon_pipebomblauncher" : "tf_weapon_bottle"));
					index = (!i ? 19 : (i == 1 ? 20 : 1));
				}
				case TFClass_Heavy:
				{
					classname = (!i ? "tf_weapon_minigun" : (i == 1 ? "tf_weapon_shotgun_hwg" : "tf_weapon_fists"));
					index = (!i ? 15 : (i == 1 ? 11 : 5));
				}
				case TFClass_Engineer:
				{
					classname = (!i ? "tf_weapon_shotgun_primary" : (i == 1 ? "tf_weapon_pistol" : "tf_weapon_wrench"));
					index = (!i ? 9 : (i == 1 ? 22 : 7));
				}
				case TFClass_Medic:
				{
					classname = (!i ? "tf_weapon_syringegun_medic" : (i == 1 ? "tf_weapon_medigun" : "tf_weapon_bonesaw"));
					index = (!i ? 17 : (i == 1 ? 29 : 8));
				}
				case TFClass_Sniper:
				{
					classname = (!i ? "tf_weapon_sniperrifle" : (i == 1 ? "tf_weapon_smg" : "tf_weapon_club"));
					index = (!i ? 14 : (i == 1 ? 16 : 3));
				}
				case TFClass_Spy:
				{
					classname = (!i ? "tf_weapon_revolver" : (i == 1 ? "tf_weapon_pda_spy" : "tf_weapon_knife"));
					index = (!i ? 24 : (i == 1 ? 735 : 4));
				}
			}

			if (active == 1)
				TF2_RemoveWeaponSlot(client, i);
			else if (active == 2)
				RemovePlayerBack(client, prepwep[0], 1);

/*	Flamethrower attributes are fucked up after Jungle Inferno, these static attribs are required whenever spawning them
"flame_gravity"                         "0"
"flame_drag"                            "8.5"
"flame_up_speed"                        "50"
"flame_speed"                           "2450"
"flame_spread_degree"                   "2.8"
"flame_lifetime"                        "0.6"
"flame_random_life_time_offset"         "0.1"
*/

			wep = Player.SpawnWeapon(classname, index, 1, 0, (index == 21 ? "841 ; 0 ; 843 ; 8.5 ; 865 ; 50 ; 844 ; 2450 ; 839 ; 2.8 ; 862 ; 0.6 ; 863 ; 0.1" : ""));
			if (GetClientTeam(client) == RED)
			{ SetWeaponAmmo(wep, 0); SetWeaponClip(wep, 0); }
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
            int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (int i = 0; i < len; i++)
                    if (idx == indices[i])
                        return edict;
            }
        }
    }
    edict = MaxClients+1;
    while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
    {
        char netclass[32];
        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
        {
            int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (int i = 0; i < len; i++) 
                    if (idx == indices[i])
                        return edict;
            }
        }
    }
    edict = MaxClients+1;
    while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
    {
        char netclass[32];
        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
        {
            int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (int i = 0; i < len; i++)
                    if (idx == indices[i])
                        return edict;
            }
        }
    }
    return -1;
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
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
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
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
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
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
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
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}