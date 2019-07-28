#include <sourcemod>
#include <morecolors>
#include <tf2jailredux>

#pragma semicolon 1
#pragma newdecls required
// #include "TF2JailRedux/stocks.inc"

#define PLUGIN_VERSION 		"1.0.0"

public Plugin myinfo =
{
	name = "TF2Jail LR Module Template",
	author = "",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar PickCount;

public void OnPluginStart()
{
	PickCount = CreateConVar("sm_jb -- _pickcount", "5", "Maximum number of times this LR can be picked in a single map. 0 for no limit", FCVAR_NOTIFY, true, 0.0);

	AutoExecConfig(true, "LRModule --");
}

#define CHECK() 				if ( JBGameMode_GetProperty("iLRType") != TF2JailRedux_LRIndex() ) return

public void OnAllPluginsLoaded()
{
	TF2JailRedux_RegisterPlugin();
	JB_Hook(OnHudShow, 					fwdOnHudShow);
	JB_Hook(OnLRPicked, 				fwdOnLRPicked);
	JB_Hook(OnPanelAdd,					fwdOnPanelAdd);
	JB_Hook(OnMenuAdd, 					fwdOnMenuAdd);	// The necessities

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
	//JB_Hook(OnPlayerPreppedPre, 		fwdOnPlayerPreppedPre);
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

public void OnPluginEnd()
{
	TF2JailRedux_UnRegisterPlugin();
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{}
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
		OnAllPluginsLoaded();
}

public void fwdOnHudShow(char strHud[128])
{
	CHECK();

	strcopy(strHud, 128, "--");
}
public Action fwdOnLRPicked(const JBPlayer Player, const int selection, ArrayList arrLRS)
{
	if (selection == TF2JailRedux_LRIndex())
		CPrintToChatAll("{crimson}[TF2Jail]{burlywood} %N has chosen {default}--{burlywood} as their last request.", Player.index);
	return Plugin_Continue;
}

public void fwdOnPanelAdd(const int index, char name[64])
{
	if (index != TF2JailRedux_LRIndex())
		return;

	strcopy(name, sizeof(name), "-- - ");
}

public void fwdOnMenuAdd(const int index, int &max, char strName[64])
{
	if (index != TF2JailRedux_LRIndex())
		return;

	max = PickCount.IntValue;
	strcopy(strName, sizeof(strName), "--");
}
