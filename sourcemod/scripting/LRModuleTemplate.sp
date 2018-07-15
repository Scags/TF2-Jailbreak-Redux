#include <sourcemod>
#include <morecolors>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION 		"1.0.0"

public Plugin myinfo =
{
	name = "TF2Jail LR Module Template",
	author = "",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar ThisPlugin, PickCount;

public void OnPluginStart()
{
	ThisPlugin = CreateConVar("sm_jb -- _ilrtype", "", "This sub-plugin's last request index. DO NOT CHANGE THIS UNLESS YOU KNOW WHAT YOU'RE DOING", FCVAR_NOTIFY, true, 0.0);
	PickCount = CreateConVar("sm_jb -- _pickcount", "5", "Maximum number of times this LR can be picked in a single map. 0 for no limit", FCVAR_NOTIFY, true, 0.0);
	ThisPlugin.AddChangeHook(OnTypeChanged);

	AutoExecConfig(true, "LRModule --");
}

public void OnAllPluginsLoaded()
{
	TF2JailRedux_RegisterPlugin("LRModule_AA");
	JB_Hook(OnHudShow, fwdOnHudShow);
	JB_Hook(OnLRPicked, fwdOnLRPicked);
	JB_Hook(OnPanelAdd, fwdOnPanelAdd);
	JB_Hook(OnMenuAdd, fwdOnMenuAdd);	// The necessities

	//JB_Hook(OnDownloads, 				fwdOnDownloads);
	//JB_Hook(OnRoundStart, 			fwdOnRoundStart);
	//JB_Hook(OnRoundStartPlayer, 		fwdOnRoundStartPlayer);
	//JB_Hook(OnRoundEnd, 				fwdOnRoundEnd);
	//JB_Hook(OnRoundEndPlayer, 		fwdOnRoundEndPlayer);
	//JB_Hook(OnPreThink, 				fwdOnPreThink);
	//JB_Hook(OnRedThink, 				fwdOnRedThink);
	//JB_Hook(OnBlueThink, 				fwdOnBlueThink);
	//JB_Hook(OnWardenGet, 				fwdOnWardenGet);
	//JB_Hook(OnClientTouch, 			fwdOnClientTouch);
	//JB_Hook(OnWardenThink, 			fwdOnWardenThink);
	//JB_Hook(OnPlayerSpawned, 			fwdOnPlayerSpawned);
	//JB_Hook(OnPlayerDied, 			fwdOnPlayerDied);
	//JB_Hook(OnWardenKilled, 			fwdOnWardenKilled);
	//JB_Hook(OnTimeLeft, 				fwdOnTimeLeft);
	//JB_Hook(OnPlayerPrepped, 			fwdOnPlayerPrepped);
	//JB_Hook(OnHurtPlayer, 			fwdOnHurtPlayer);
	//JB_Hook(OnTakeDamage, 			fwdOnTakeDamage);
	//JB_Hook(OnLastGuard, 				fwdOnLastGuard);
	//JB_Hook(OnLastPrisoner, 			fwdOnLastPrisoner);
	//JB_Hook(OnCheckLivingPlayers, 	fwdOnCheckLivingPlayers);
	//JB_Hook(OnBuildingDestroyed, 		fwdOnBuildingDestroyed);
	//JB_Hook(OnObjectDeflected, 		fwdOnObjectDeflected);
	//JB_Hook(OnPlayerJarated, 			fwdOnPlayerJarated);
	//JB_Hook(OnUberDeployed, 			fwdOnUberDeployed);
	//JB_Hook(OnWMenuAdd, 				fwdOnWMenuAdd);
	//JB_Hook(OnWMenuSelect, 			fwdOnWMenuSelect);
	//JB_Hook(OnClientInduction, 		fwdOnClientInduction);
	//JB_Hook(OnVariableReset, 			fwdOnVariableReset);
	//JB_Hook(OnTimeEnd, 				fwdOnTimeEnd);
	//JB_Hook(OnFreedayGiven, 			fwdOnFreedayGiven);
	//JB_Hook(OnFreedayRemoved, 		fwdOnFreedayRemoved);
	//JB_Hook(OnFFTimer, 				fwdOnFFTimer);
	//JB_Hook(OnDoorsOpen, 				fwdOnDoorsOpen);
	//JB_Hook(OnDoorsClose, 			fwdOnDoorsClose);
	//JB_Hook(OnDoorsLock, 				fwdOnDoorsLock);
	//JB_Hook(OnDoorsUnlock, 			fwdOnDoorsUnlock);
	//JB_Hook(OnPlayMusic, 				fwdOnPlayMusic);
}

int ThisPluginIndex;
public void OnConfigsExecuted()
{
	ThisPluginIndex = ThisPlugin.IntValue;
}

public void OnTypeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ThisPluginIndex = StringToInt(newValue);
}
#define CHECK(%1) 				if ( JBGameMode_GetProperty("iLRType") != (%1) ) return

public void fwdOnHudShow(char strHud[128])
{
	CHECK(ThisPluginIndex);

	strcopy(strHud, 128, "--");
}
public Action fwdOnLRPicked(const JBPlayer Player, const int selection, ArrayList arrLRS)
{
	if (selection == ThisPluginIndex)
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} %N has chosen {default}--{burlywood} as their last request.", Player.index);
	return Plugin_Continue;
}

public void fwdOnPanelAdd(const int index, char name[64])
{
	if (index != ThisPluginIndex)
		return;

	strcopy(name, sizeof(name), "-- - ");
}

public void fwdOnMenuAdd(const int index, int &max, char strName[32])
{
	if (index != ThisPluginIndex)
		return;

	max = PickCount.IntValue;
	strcopy(strName, sizeof(strName), "--");
}
