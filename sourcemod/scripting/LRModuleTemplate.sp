#include <sourcemod>
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

LastRequest g_LR;

// Only useful with SM forwards or callbacks where you used JB_Hook
#define CHECK() 				if (g_LR == null || g_LR.GetID() != JBGameMode_GetPrope("iLRType")) return
#define CHECK_ACT(%0) 			if (g_LR == null || g_LR.GetID() != JBGameMode_GetPrope("iLRType")) return %0

public void OnPluginEnd()
{
	if (LibraryExists("TF2Jail_Redux") && g_LR != null)
	{
		g_LR.Destroy();
		g_LR = null;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{
		// This creates a last request, importing it's data from the config
		// If there is no entry named in the config, this will fail
		g_LR = LastRequest.CreateFromConfig("My Custom LR");

		// Not in the config, so let's create a fresh one
		// Then we can export the default data to the config, if needed
		if (g_LR == null)
		{
			// Note that if an lr already exists of this name,
			// LastRequest.Create will simply just link up with that LR
			// This will never fail, and it set's the LR name automatically
			g_LR = LastRequest.Create("My Custom LR");

			// Now you can set config entries as you see fit
			g_LR.SetDescription("I made this!!");
			g_LR.SetAnnounceMessage("{default}{NAME}{burlywood} Selected an awesome last request!");
			g_LR.SetActivationCommand("sm_resize @all 0.5");

			// The below are what is under "Parameters" in the config
			// Most of these have wrapper getters and setters in lastrequests.inc
			g_LR.SetPropertyNum("UsesPerMap", 5);
			g_LR.SetPropertyNum("TimerTime", 300);
			g_LR.SetPropertyNum("BalanceTeams", 1);

			// You can also set custom keys which can be retrieved later!
			// This can be a replacement for cvars, which can let server owners
			// an LR's data within a single file
			// If you want to get a custom value later, use LastRequest.GetProperty*()
			g_LR.SetPropertyNum("MyCustomKey", 100);

			// Done with all of the config data, now export it to the config file!
			// .create means "yes, create an entry if it does not exist"
			// .createonly means "do not overwrite an entry if it exists"
			// We already know that the LR is not in the config, but it's good practice
			g_LR.ExportToConfig(.create = true, .createonly = true);
		}

		// The cool thing is that you don't *have* to use config with LRs
		// You can simply just LastRequest.Create and go to town

		// Note that you can only hook one function per index per LR

		// Now we should hook into functions that we want
		// Just un-comment the ones that you need and make a callback for it!

		//g_LR.AddHook(OnDownloads, MyLR_OnDownloads);
		//g_LR.AddHook(OnRoundStart, MyLR_OnRoundStart);
		//g_LR.AddHook(OnRoundStartPlayer, MyLR_OnRoundStartPlayer);
		//g_LR.AddHook(OnRoundEnd, MyLR_OnRoundEnd);
		//g_LR.AddHook(OnRoundEndPlayer, MyLR_OnRoundEndPlayer);
		//g_LR.AddHook(OnPreThink, MyLR_OnPreThink);
		//g_LR.AddHook(OnRedThink, MyLR_OnRedThink);
		//g_LR.AddHook(OnBlueThink, MyLR_OnBlueThink);
		//g_LR.AddHook(OnFreedayGiven, MyLR_OnFreedayGiven);
		//g_LR.AddHook(OnFreedayRemoved, MyLR_OnFreedayRemoved);
		//g_LR.AddHook(OnWardenGet, MyLR_OnWardenGet);
		//g_LR.AddHook(OnWardenThink, MyLR_OnWardenThink);
		//g_LR.AddHook(OnWardenKilled, MyLR_OnWardenKilled);
		//g_LR.AddHook(OnPlayerTouch, MyLR_OnPlayerTouch);
		//g_LR.AddHook(OnPlayerSpawned, MyLR_OnPlayerSpawned);
		//g_LR.AddHook(OnPlayerDied, MyLR_OnPlayerDied);
		//g_LR.AddHook(OnPlayerPrepped, MyLR_OnPlayerPrepped);
		//g_LR.AddHook(OnPlayerPreppedPost, MyLR_OnPlayerPreppedPost);
		//g_LR.AddHook(OnLastGuard, MyLR_OnLastGuard);
		//g_LR.AddHook(OnLastPrisoner, MyLR_OnLastPrisoner);
		//g_LR.AddHook(OnCheckLivingPlayers, MyLR_OnCheckLivingPlayers);
		//g_LR.AddHook(OnTakeDamage, MyLR_OnTakeDamage);
		//g_LR.AddHook(OnBuildingDestroyed, MyLR_OnBuildingDestroyed);
		//g_LR.AddHook(OnPlayerHurt, MyLR_OnPlayerHurt);
		//g_LR.AddHook(OnObjectDeflected, MyLR_OnObjectDeflected);
		//g_LR.AddHook(OnPlayerJarated, MyLR_OnPlayerJarated);
		//g_LR.AddHook(OnUberDeployed, MyLR_OnUberDeployed);
		//g_LR.AddHook(OnClientInduction, MyLR_OnClientInduction);
		//g_LR.AddHook(OnVariableReset, MyLR_OnVariableReset);
		//g_LR.AddHook(OnTimeLeft, MyLR_OnTimeLeft);
		//g_LR.AddHook(OnMenuAdd, MyLR_OnMenuAdd);
		//g_LR.AddHook(OnShowHud, MyLR_OnShowHud);
		//g_LR.AddHook(OnLRPicked, MyLR_OnLRPicked);
		//g_LR.AddHook(OnWMenuSelect, MyLR_OnWMenuSelect);
		//g_LR.AddHook(OnTimeEnd, MyLR_OnTimeEnd);
		//g_LR.AddHook(OnFFTimer, MyLR_OnFFTimer);
		//g_LR.AddHook(OnDoorsOpen, MyLR_OnDoorsOpen);
		//g_LR.AddHook(OnDoorsClose, MyLR_OnDoorsClose);
		//g_LR.AddHook(OnDoorsLock, MyLR_OnDoorsLock);
		//g_LR.AddHook(OnDoorsUnlock, MyLR_OnDoorsUnlock);
		//g_LR.AddHook(OnSoundHook, MyLR_OnSoundHook);
		//g_LR.AddHook(OnEntCreated, MyLR_OnEntCreated);
		//g_LR.AddHook(OnCalcAttack, MyLR_OnCalcAttack);
		//g_LR.AddHook(OnRebelGiven, MyLR_OnRebelGiven);
		//g_LR.AddHook(OnRebelRemoved, MyLR_OnRebelRemoved);
		//g_LR.AddHook(OnWardenRemoved, MyLR_OnWardenRemoved);
		//g_LR.AddHook(OnShouldAutobalance, MyLR_OnShouldAutobalance);
		//g_LR.AddHook(OnShouldAutobalancePlayer, MyLR_OnShouldAutobalancePlayer);
		//g_LR.AddHook(OnSetWardenLock, MyLR_OnSetWardenLock);
		//g_LR.AddHook(OnPlayMusic, MyLR_OnPlayMusic);
		//g_LR.AddHook(OnLRDenied, MyLR_OnLRDenied);
		//g_LR.AddHook(OnLRActivate, MyLR_OnLRActivate);
		//g_LR.AddHook(OnLRActivatePlayer, MyLR_OnLRActivatePlayer);

		// These do not have LR hooks, so use JB_Hook if u need it
		//g_LR.AddHook(OnLRGiven, MyLR_OnLRGiven);
		//g_LR.AddHook(OnWMenuAdd, MyLR_OnWMenuAdd);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", false))
	{
		if (g_LR != null)
		{
			g_LR.Destroy();
			g_LR = null;
		}
	}
}
