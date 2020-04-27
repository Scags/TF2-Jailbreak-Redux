#if defined _tf2jailredux_included
	#endinput
#endif
#define _tf2jailredux_included

#include <tf2jailredux/player>
#include <tf2jailredux/lastrequest>
#include <tf2jailredux/gamemode>

#include <tf2_stocks>
#include <tf2items>

#define TAG 				"{crimson}[TF2Jail]{burlywood} "
#define ADMTAG 				"{orange}[TF2Jail]{burlywood} "

enum
{	// JBGameMode.iRoundStates
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};

enum
{	// Freeday/warday position integers
	FREEDAY = 1,
	WRED = 2,
	WBLU = 3
};

stock char strDoorsList[][] =  { "func_door", "func_door_rotating", "func_movelinear", "prop_door_rotating" };

/**
 *	@section TF2Jail compatibility forwards and functions
*/

#pragma deprecated Use JBGameMode_GetProperty("bWardenExists")
stock bool TF2Jail_WardenActive()
{
	return JBGameMode_GetProperty("bWardenExists");
}

#pragma deprecated Use JBPlayer.bIsWarden
stock bool TF2Jail_IsWarden(int client)
{
	return JBPlayer(client).bIsWarden;
}

#pragma deprecated Use JBPlayer.WardenSet()
stock void TF2Jail_WardenSet(int client)
{
	JBPlayer(client).WardenSet()
}

#pragma deprecated Use JBPlayer.WardenUnset()
stock void TF2Jail_WardenUnset(int client)
{
	JBPlayer(client).WardenUnset();
}

#pragma deprecated Use JBPlayer.bIsFreeday
stock bool TF2Jail_IsFreeday(int client)
{
	return JBPlayer(client).bIsFreeday;
}

#pragma deprecated Use JBPlayer.GiveFreeday()
stock void TF2Jail_GiveFreeday(int client)
{
	JBPlayer(client).GiveFreeday();
}

#pragma deprecated Use JBPlayer.RemoveFreeday()
stock void TF2Jail_RemoveFreeday(int client)
{
	JBPlayer(client).RemoveFreeday();
}

#pragma deprecated Use JBPlayer.bIsRebel
stock bool TF2Jail_IsRebel(int client)
{
	return JBPlayer(client).bIsRebel;
}

#pragma deprecated Use JBPlayer.MarkRebel()
stock void TF2Jail_MarkRebel(int client)
{
	JBPlayer(client).MarkRebel();
}

//stock bool TF2Jail_IsFreekiller(int client)
//stock void TF2Jail_MarkFreekiller(int client)

#pragma deprecated Use JBPlayer(client).EmptyWeaponSlots()
stock void TF2Jail_StripToMelee(int client)
{
	JBPlayer(client).EmptyWeaponSlots();
}

#pragma deprecated Use JBPlayer(client).StripToMelee()
stock void TF2Jail_StripAllWeapons(int client)
{
	JBPlayer(client).StripToMelee();
}

#pragma deprecated Use JBGameMode_SetProperty("bIsWardenLocked", true)
stock void TF2Jail_LockWarden()
{
	JBGameMode_SetProperty("bIsWardenLocked", true);
}

#pragma deprecated Use JBGameMode_SetProperty("bIsWardenLocked", false)
stock void TF2Jail_UnlockWarden()
{
	JBGameMode_SetProperty("bIsWardenLocked", false);
}

//stock void TF2Jail_Log(const char[] log, any ...);

#pragma deprecated Use JBGameMode_GetProperty("bIsLRRound")
stock bool TF2Jail_IsLRRound()
{
	return JBGameMode_GetProperty("bIsLRRound");
}

#pragma deprecated Use JBGameMode_ManageCells() instead
stock bool TF2Jail_ManageCells(eDoorsMode Status)
{
	JBGameMode_ManageCells(Status);
	return true;
}

#pragma deprecated JB_Hook Action OnWardenGet(JBPlayer) instead
forward void TF2Jail_OnWardenCreated(int client);

#pragma deprecated JB_Hook void OnWardenRemoved(JBPlayer) instead
forward void TF2Jail_OnWardenRemoved(int client);

//forward void TF2Jail_OnLastRequestExecute(const char[] Handler);

#pragma deprecated JB_Hook void OnFreedayGiven(JBPlayer) instead
forward void TF2Jail_OnFreedayGiven(int client);

#pragma deprecated JB_Hook void OnFreedayRemoved(JBPlayer) instead
forward void TF2Jail_OnFreedayRemoved(int client);

//forward void TF2Jail_OnFreekillerGiven(int client);
//forward void TF2Jail_OnFreekillerRemoved(int client);

#pragma deprecated JB_Hook void OnRebelGiven(JBPlayer) instead
forward void TF2Jail_OnRebelGiven(int client);

/**
 *	@endsection
*/


public SharedPlugin __pl_tf2jailredux = {
	name = "TF2Jail_Redux",
	file = "TF2Jail_Redux.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_tf2jailredux_SetNTVOptional()
{
	MarkNativeAsOptional("TF2JailRedux_RegisterPlugin");
	MarkNativeAsOptional("TF2JailRedux_RegisterLR");
	MarkNativeAsOptional("TF2JailRedux_UnRegisterPlugin");
	MarkNativeAsOptional("TF2JailRedux_UnRegisterLR");
	MarkNativeAsOptional("TF2JailRedux_LRIndex");

	MarkNativeAsOptional("JB_Hook");
	MarkNativeAsOptional("JB_HookEx");
	MarkNativeAsOptional("JB_Unhook");
	MarkNativeAsOptional("JB_UnhookEx");

	MarkNativeAsOptional("JBPlayer.bNoMusic.get");
	MarkNativeAsOptional("JBPlayer.hMap.get");

	MarkNativeAsOptional("JBPlayer.SpawnWeapon");
	MarkNativeAsOptional("JBPlayer.GetWeaponSlotIndex");
	MarkNativeAsOptional("JBPlayer.SetWepInvis");
	MarkNativeAsOptional("JBPlayer.ForceTeamChange");
	MarkNativeAsOptional("JBPlayer.TeleportToPosition");
	MarkNativeAsOptional("JBPlayer.ListLRS");
	MarkNativeAsOptional("JBPlayer.PreEquip");
	MarkNativeAsOptional("JBPlayer.TeleToSpawn");
	MarkNativeAsOptional("JBPlayer.SpawnSmallHealthPack");
	MarkNativeAsOptional("JBPlayer.MutePlayer");
	MarkNativeAsOptional("JBPlayer.GiveFreeday");
	MarkNativeAsOptional("JBPlayer.RemoveFreeday");
	MarkNativeAsOptional("JBPlayer.StripToMelee");
	MarkNativeAsOptional("JBPlayer.EmptyWeaponSlots");
	MarkNativeAsOptional("JBPlayer.UnmutePlayer");
	MarkNativeAsOptional("JBPlayer.WardenSet");
	MarkNativeAsOptional("JBPlayer.WardenUnset");
	MarkNativeAsOptional("JBPlayer.MakeHorsemann");
	MarkNativeAsOptional("JBPlayer.UnHorsemann");
	MarkNativeAsOptional("JBPlayer.WardenMenu");
	MarkNativeAsOptional("JBPlayer.ClimbWall");
	MarkNativeAsOptional("JBPlayer.AttemptFireWarden");
	MarkNativeAsOptional("JBPlayer.MarkRebel");
	MarkNativeAsOptional("JBPlayer.ClearRebel");

	MarkNativeAsOptional("JBGameMode_Playing");
	MarkNativeAsOptional("JBGameMode_ManageCells");
	MarkNativeAsOptional("JBGameMode_FindRandomWarden");
	MarkNativeAsOptional("JBGameMode_Warden");
	MarkNativeAsOptional("JBGameMode_FireWarden");
	MarkNativeAsOptional("JBGameMode_OpenAllDoors");
	MarkNativeAsOptional("JBGameMode_ToggleMedic");
	// MarkNativeAsOptional("JBGameMode_ToggleMedicTeam");
	MarkNativeAsOptional("JBGameMode_ResetVotes");
	MarkNativeAsOptional("JBGameMode_GetTelePosition");
	MarkNativeAsOptional("JBGameMode_SetWardenLock");

	MarkNativeAsOptional("JBGameMode_Instance");
	MarkNativeAsOptional("JBGameMode_GetProperty");
	MarkNativeAsOptional("JBGameMode_SetProperty");

	MarkNativeAsOptional("JBGameMode.JBGameMode");
}
#endif