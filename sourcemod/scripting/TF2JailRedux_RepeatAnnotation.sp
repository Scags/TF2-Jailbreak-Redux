#include <sourcemod>
#include <morecolors>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION 		"1.0.0"


methodmap JailRepeater < JBPlayer
{
	public JailRepeater( const int q )
	{
		return view_as< JailRepeater >(JBPlayer(q));
	}
	public static JailRepeater Of( const JBPlayer player )
	{
		return view_as< JailRepeater >(player);
	}
	property int iRepeats
	{
		public get()
		{
			return this.GetProp("iRepeats");
		}
		public set( const int i )
		{
			this.SetProp("iRepeats", i);
		}
	}
	property float flRepeatTime
	{
		public get()
		{
			return this.GetPropFloat("flRepeatTime");
		}
		public set( const float i )
		{
			this.SetPropFloat("flRepeatTime", i);
		}
	}
};

public Plugin myinfo =
{
	name = "TF2Jail Repeat Annotaions",
	author = "Scag/Ragenewb",
	description = "Head annotations repeat-asking prisoners",
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

ConVar
	cvRepeatMax,
	cvMessage,
	cvTargeting,
	cvRange,
	cvLifeTime
;

public void OnPluginStart()
{
	CreateConVar("jbrp_version", PLUGIN_VERSION, "TF2Jail Repeat Sprite Version (Do not touch)", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvRepeatMax = CreateConVar("sm_jbrp_max", "10", "Maximum amount of repeats annotations each player gets per round.", FCVAR_NOTIFY, true, 0.0);
	cvMessage = CreateConVar("sm_jbrp_message", "{NAME} has asked for a repeat", "Message to display via annotation, \"{NAME}\" is replaced with client name.", FCVAR_NOTIFY);
	cvTargeting = CreateConVar("sm_jbrp_targeting", "0", "Display annotation to certain clients? 0 for everyone; 1 for Blue team only; 2 for Warden only", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvRange = CreateConVar("sm_jbrp_range", "1000", "Range in hammer units for clients to see the annotation.", FCVAR_NOTIFY, true, 0.0);
	cvLifeTime = CreateConVar("sm_jbrp_lifetime", "7", "Lifetime for annotations in seconds.", FCVAR_NOTIFY, true, 0.0);

	AutoExecConfig(true, "TF2Jail_Repeat");

	LoadTranslations("tf2jail_redux.phrases");

	RegConsoleCmd("sm_repeat", SayRepeat);
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true))
	{
		JB_Hook(OnRoundStartPlayer, fwdOnRoundStartPlayer);
		JB_Hook(OnClientInduction, fwdOnClientInduction);
	}
}

public Action SayRepeat(int client, int args)
{
	if (JBGameMode_GetProp("iRoundState") != StateRunning || !client || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
		return Plugin_Handled;

	JailRepeater player = JailRepeater(client);

	float currtime = GetGameTime();
	if (player.flRepeatTime >= currtime)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Slow Down");
		return Plugin_Handled;
	}

	if (player.iRepeats >= cvRepeatMax.IntValue)
	{
		CPrintToChat(client, "%t %t", "Plugin Tag", "Repeats Surpassed");
		return Plugin_Handled;
	}

	Event event = CreateEvent("show_annotation");
	if (!event)
		return Plugin_Handled;

	event.SetInt("follow_entindex", client);

	int clients = FilterClients(client);
	if (!clients)
	{
		delete event;
		return Plugin_Handled;
	}

	event.SetInt("visibilityBitfield", clients);

	float time = cvLifeTime.FloatValue;
	event.SetFloat("lifetime", time);

	char s[64]; cvMessage.GetString(s, sizeof(s));
	char name[32]; GetClientName(client, name, sizeof(name));
	ReplaceString(s, sizeof(s), "{NAME}", name, false);
	event.SetString("text", s);
	event.Fire();

	player.iRepeats++;
	player.flRepeatTime = currtime + time;
	return Plugin_Handled;
}

public int FilterClients(const int client)
{
	int target = cvTargeting.IntValue;
	if (target == 2)
		if (JBGameMode_GetProp("bWardenExists"))
			return (1 << JBGameMode_Warden().index);
		else return 0;

	int bits, i;
	float vecOrigin[3], vecOrigin2[3], dist = cvRange.FloatValue;
	GetClientAbsOrigin(client, vecOrigin);

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (target == 1 && GetClientTeam(i) != 3)
			continue;

		GetClientAbsOrigin(i, vecOrigin2);
		if (GetVectorDistance(vecOrigin, vecOrigin2) > dist)
			continue;

		bits |= (1 << i);
	}
	return bits;
}

public void fwdOnRoundStartPlayer(const JBPlayer Player)
{
	JailRepeater player = JailRepeater.Of(Player);
	player.iRepeats = 0;
	player.flRepeatTime = 0.0;
}

public void fwdOnClientInduction(const JBPlayer Player)
{
	JailRepeater player = JailRepeater.Of(Player);
	player.iRepeats = 0;
	player.flRepeatTime = 0.0;
}