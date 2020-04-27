#include <sourcemod>
#include <tf2jailredux>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <morecolors>

#define PLUGIN_VERSION 		"1.0.0"

#define RED 2
#define BLU 3

public Plugin myinfo =
{
	name = "TF2Jail Redux Base Last Requests",
	author = "Scag",
	description = "Base last request pack for TF2Jail Redux",
	version = PLUGIN_VERSION,
	url = "https://github.com/Scags/TF2-Jailbreak-Redux"
};

#include "TF2JailRedux/stocks.inc"

#include "BaseLRs/random.sp"
#include "BaseLRs/suicide.sp"
#include "BaseLRs/freedays.sp"
#include "BaseLRs/custom.sp"
#include "BaseLRs/melee.sp"
#include "BaseLRs/hhh.sp"
#include "BaseLRs/tiny.sp"
#include "BaseLRs/hot.sp"
#include "BaseLRs/gravity.sp"
#include "BaseLRs/swa.sp"
#include "BaseLRs/warday.sp"

public void OnPluginStart()
{
	LoadTranslations("tf2jail_redux.phrases");
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true))
	{
		Random_Init();
		Suicide_Init();
		Freedays_Init();
		Custom_Init();
		Melee_Init();
		HHH_Init();
		Tiny_Init();
		Hot_Init();
		Gravity_Init();
		SWA_Init();
		Warday_Init();
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "TF2Jail_Redux", true))
		Kaboom();	// Tbh, you shouldn't need to destroy when jr is unloaded,
					// but you *should* set to null at the least
}

public void OnPluginEnd()
{
	Kaboom();
}

public void Kaboom()
{
	Random_Destroy();
	Suicide_Destroy();
	Freedays_Destroy();
	Custom_Destroy();
	Melee_Destroy();
	HHH_Destroy();
	Tiny_Destroy();
	Hot_Destroy();
	Gravity_Destroy();
	SWA_Destroy();
	Warday_Destroy();
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] argc)
{
	Custom_OnClientSayCommand(client, command, argc);
}