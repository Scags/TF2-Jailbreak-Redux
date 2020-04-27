
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
		/* Forwards */
	CreateNative("JB_Hook", Native_Hook);
	CreateNative("JB_HookEx", Native_HookEx);
	CreateNative("JB_Unhook", Native_Unhook);
	CreateNative("JB_UnhookEx", Native_UnhookEx);
		/* Player */
	CreateNative("JBPlayer.GetValue", Native_GetValue);
	CreateNative("JBPlayer.SetValue", Native_SetValue);
	CreateNative("JBPlayer.bNoMusic.get", Native_NoMusic_Get);
	CreateNative("JBPlayer.hMap.get", Native_StringMap_Get);
	CreateNative("JBPlayer.SpawnWeapon", Native_SpawnWeapon);
	CreateNative("JBPlayer.GetWeaponSlotIndex", Native_GetWeaponSlotIndex);
	CreateNative("JBPlayer.SetWepInvis", Native_SetWepInvis);
	CreateNative("JBPlayer.ForceTeamChange", Native_ForceTeamChange);
	CreateNative("JBPlayer.TeleportToPosition", Native_TeleportToPosition);
	CreateNative("JBPlayer.ListLRS", Native_ListLRS);
	CreateNative("JBPlayer.PreEquip", Native_PreEquip);
	CreateNative("JBPlayer.TeleToSpawn", Native_TeleToSpawn);
	CreateNative("JBPlayer.SpawnSmallHealthPack", Native_SpawnSmallHealthPack);
	CreateNative("JBPlayer.MutePlayer", Native_MutePlayer);
	CreateNative("JBPlayer.GiveFreeday", Native_GiveFreeday);
	CreateNative("JBPlayer.RemoveFreeday", Native_RemoveFreeday);
	CreateNative("JBPlayer.StripToMelee", Native_StripToMelee);
	CreateNative("JBPlayer.EmptyWeaponSlots", Native_EmptyWeaponSlots);
	CreateNative("JBPlayer.UnmutePlayer", Native_UnmutePlayer);
	CreateNative("JBPlayer.WardenSet", Native_WardenSet);
	CreateNative("JBPlayer.WardenUnset", Native_WardenUnset);
	CreateNative("JBPlayer.WardenMenu", Native_WardenMenu);
	CreateNative("JBPlayer.ClimbWall", Native_ClimbWall);
	CreateNative("JBPlayer.AttemptFireWarden", Native_AttemptFireWarden);
	CreateNative("JBPlayer.MarkRebel", Native_MarkRebel);
	CreateNative("JBPlayer.ClearRebel", Native_ClearRebel);
		/* Gamemode */
	CreateNative("JBGameMode_Playing", Native_JBGameMode_Playing);
	CreateNative("JBGameMode_ManageCells", Native_JBGameMode_ManageCells);
	CreateNative("JBGameMode_FindRandomWarden", Native_JBGameMode_FindRandomWarden);
	CreateNative("JBGameMode_Warden", Native_JBGameMode_Warden);
	CreateNative("JBGameMode_FireWarden", Native_JBGameMode_FireWarden);
	CreateNative("JBGameMode_OpenAllDoors", Native_JBGameMode_OpenAllDoors);
	CreateNative("JBGameMode_ToggleMedic", Native_JBGameMode_ToggleMedic);
	CreateNative("JBGameMode_ToggleMuting", Native_JBGameMode_ToggleMuting);
	CreateNative("JBGameMode_ResetVotes", Native_JBGameMode_ResetVotes);
	CreateNative("JBGameMode_GetTelePosition", Native_JBGameMode_GetTelePosition);
	CreateNative("JBGameMode_SetWardenLock", Native_JBGameMode_SetWardenLock);
	CreateNative("JBGameMode_AutobalanceTeams", Native_JBGameMode_AutobalanceTeams);
	CreateNative("JBGameMode_EvenTeams", Native_JBGameMode_EvenTeams);
		/* Gamemode StringMap */
	CreateNative("JBGameMode_Instance", Native_JBGameMode_Instance);
	CreateNative("JBGameMode_GetProperty", Native_JBGameMode_GetProperty);
	CreateNative("JBGameMode_SetProperty", Native_JBGameMode_SetProperty);
	CreateNative("JBGameMode_GetProp", Native_JBGameMode_GetProperty);
	CreateNative("JBGameMode_SetProp", Native_JBGameMode_SetProperty);
	CreateNative("JBGameMode_GetPropFloat", Native_JBGameMode_GetProperty);	// Still cells, just force the casting
	CreateNative("JBGameMode_SetPropFloat", Native_JBGameMode_SetProperty);
	CreateNative("JBGameMode_GetPropString", Native_JBGameMode_GetPropString);
	CreateNative("JBGameMode_SetPropString", Native_JBGameMode_SetPropString);
	CreateNative("JBGameMode_GetPropArray", Native_JBGameMode_GetPropArray);
	CreateNative("JBGameMode_SetPropArray", Native_JBGameMode_SetPropArray);
		/* Gamemode Methodmap */
	CreateNative("JBGameMode.JBGameMode", Native_JBGameMode_Instance);

		/* Last Requests */
	CreateNative("LastRequest.Create", Native_LastRequest_Instance);
	CreateNative("LastRequest.CreateFromConfig", Native_LastRequest_CreateFromConfig);
	CreateNative("LastRequest.FromIndex", Native_LastRequest_FromIndex);
	CreateNative("LastRequest.At", Native_LastRequest_FromIndex);
	CreateNative("LastRequest.ByName", Native_LastRequest_ByName);
	CreateNative("LastRequest.AddHook", Native_LastRequest_AddHook);
	CreateNative("LastRequest.RemoveHook", Native_LastRequest_RemoveHook);
//	CreateNative("LastRequest.GetFunction", Native_LastRequest_GetFunction);
//	CreateNative("LastRequest.SetFunction", Native_LastRequest_SetFunction);
	CreateNative("LastRequest.Execute", Native_LastRequest_Execute);
	CreateNative("LastRequest.Destroy", Native_LastRequest_Destroy);
	CreateNative("LastRequest.IsInConfig", Native_LastRequest_IsInConfig);
	CreateNative("LastRequest.ImportFromConfig", Native_LastRequest_ImportFromConfig);
	CreateNative("LastRequest.ExportToConfig", Native_LastRequest_ExportToConfig);
	CreateNative("LastRequest.DeleteFromConfig", Native_LastRequest_DeleteFromConfig);
	CreateNative("LastRequest.Refresh", Native_LastRequest_Refresh);

	InitializeForwards();

	RegPluginLibrary("TF2Jail_Redux");

	bLate = late;

	return APLRes_Success;
}

public any Native_Hook(Handle plugin, int numParams)
{
	int hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	if (hPrivFwds[hook])
		AddToForward(hPrivFwds[hook], plugin, func);
}
public any Native_HookEx(Handle plugin, int numParams)
{
	int hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	if (hPrivFwds[hook])
		return AddToForward(hPrivFwds[hook], plugin, func);
	return 0;
}
public any Native_Unhook(Handle plugin, int numParams)
{
	int hook = GetNativeCell(1);
	if (hPrivFwds[hook])
		RemoveFromForward(hPrivFwds[hook], plugin, GetNativeFunction(2));
}
public any Native_UnhookEx(Handle plugin, int numParams)
{
	int hook = GetNativeCell(1);
	if (hPrivFwds[hook])
		return RemoveFromForward(hPrivFwds[hook], plugin, GetNativeFunction(2));
	return 0;
}

public any Native_GetValue(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(2, key, 64);
	any item;
	if (hJailFields[GetNativeCell(1)].GetValue(key, item))
		return item;
	return 0;
}
public any Native_SetValue(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(2, key, 64);
	return hJailFields[GetNativeCell(1)].SetValue(key, GetNativeCell(3));
}
public any Native_NoMusic_Get(Handle plugin, int numParams)
{
	return JailFighter(GetNativeCell(1)).bNoMusic;
}
public any Native_StringMap_Get(Handle plugin, int numParams)
{
	return JailFighter(GetNativeCell(1)).hMap;
}
public any Native_SpawnWeapon(Handle plugin, int numParams)
{
	char classname[64]; GetNativeString(2, classname, 64);
	char attributes[128]; GetNativeString(6, attributes, 128);
	return JailFighter(GetNativeCell(1)).SpawnWeapon(classname, GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), attributes);
}
public any Native_GetWeaponSlotIndex(Handle plugin, int numParams)
{
	return JailFighter(GetNativeCell(1)).GetWeaponSlotIndex(GetNativeCell(1));
}
public any Native_SetWepInvis(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).SetWepInvis(GetNativeCell(1));
}
public any Native_ForceTeamChange(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).ForceTeamChange(GetNativeCell(2), GetNativeCell(3));
}
public any Native_TeleportToPosition(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).TeleportToPosition(GetNativeCell(2));
}
public any Native_ListLRS(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).ListLRS();
}
public any Native_PreEquip(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).PreEquip(GetNativeCell(2));
}
public any Native_TeleToSpawn(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).TeleToSpawn();
}
public any Native_SpawnSmallHealthPack(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).SpawnSmallHealthPack();
}
public any Native_MutePlayer(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).MutePlayer();
}
public any Native_GiveFreeday(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).GiveFreeday();
}
public any Native_RemoveFreeday(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).RemoveFreeday();
}
public any Native_StripToMelee(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).StripToMelee();
}
public any Native_EmptyWeaponSlots(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).EmptyWeaponSlots();
}
public any Native_UnmutePlayer(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).UnmutePlayer();
}
public any Native_WardenSet(Handle plugin, int numParams)
{
	return JailFighter(GetNativeCell(1)).WardenSet();
}
public any Native_WardenUnset(Handle plugin, int numParams)
{
	return JailFighter(GetNativeCell(1)).WardenUnset();
}
public any Native_WardenMenu(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).WardenMenu();
}
public any Native_ClimbWall(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).ClimbWall(GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5));
}
public any Native_AttemptFireWarden(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).AttemptFireWarden();
}
public any Native_MarkRebel(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).MarkRebel();
}
public any Native_ClearRebel(Handle plugin, int numParams)
{
	JailFighter(GetNativeCell(1)).ClearRebel();
}

/** GAMEMODE **/

public any Native_JBGameMode_Playing(Handle plugin, int numParams)
{
	return gamemode.iPlaying;
}
public any Native_JBGameMode_FindRandomWarden(Handle plugin, int numParams)
{
	return gamemode.FindRandomWarden();
}
public any Native_JBGameMode_ManageCells(Handle plugin, int numParams)
{
	gamemode.DoorHandler(GetNativeCell(1));
}
public any Native_JBGameMode_Warden(Handle plugin, int numParams)
{
	return view_as< int >(gamemode.iWarden);
}
public any Native_JBGameMode_FireWarden(Handle plugin, int numParams)
{
	gamemode.FireWarden(GetNativeCell(1), GetNativeCell(2));
}
public any Native_JBGameMode_OpenAllDoors(Handle plugin, int numParams)
{
	gamemode.OpenAllDoors();
}
public any Native_JBGameMode_ToggleMedic(Handle plugin, int numParams)
{
	gamemode.ToggleMedic(GetNativeCell(1));
}
/*public any Native_JBGameMode_ToggleMedicTeam(Handle plugin, int numParams)
{
	int team = GetNativeCell(1);
	gamemode.ToggleMedicTeam(team);
}*/
public any Native_JBGameMode_ToggleMuting(Handle plugin, int numParams)
{
	gamemode.ToggleMuting(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}
public any Native_JBGameMode_ResetVotes(Handle plugin, int numParams)
{
	gamemode.ResetVotes();
}
public any Native_JBGameMode_GetTelePosition(Handle plugin, int numParams)
{
	float vec[3];
	bool ret = gamemode.GetTelePosition(GetNativeCell(1), vec);
	SetNativeArray(2, vec, 3);
	return ret;
}
public any Native_JBGameMode_SetWardenLock(Handle plugin, int numParams)
{
	return gamemode.SetWardenLock(GetNativeCell(1), GetNativeCell(2));
}
public any Native_JBGameMode_AutobalanceTeams(Handle plugin, int numParams)
{
	gamemode.AutobalanceTeams(GetNativeCell(1));
}
public any Native_JBGameMode_EvenTeams(Handle plugin, int numParams)
{
	gamemode.EvenTeams(GetNativeCell(1), GetNativeCell(2));
}

public any Native_JBGameMode_GetProperty(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	any item;
	gamemode.GetValue(key, item);
	return item;
}
public any Native_JBGameMode_SetProperty(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	gamemode.SetValue(key, GetNativeCell(2));
}
public any Native_JBGameMode_GetPropString(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len = GetNativeCell(3);

	char[] buffer = new char[len];
	int written = gamemode.GetString(key, buffer, len);

	SetNativeString(2, buffer, len);
	return written;
}
public any Native_JBGameMode_SetPropString(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len; GetNativeStringLength(2, len);
	++len;

	char[] buffer = new char[len];
	GetNativeString(2, buffer, len);
	gamemode.SetString(key, buffer);
}
public any Native_JBGameMode_GetPropArray(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len = GetNativeCell(3);

	any[] buffer = new any[len];
	gamemode.GetArray(key, buffer, len);
	SetNativeArray(2, buffer, len);
}
public any Native_JBGameMode_SetPropArray(Handle plugin, int numParams)
{
	char key[64]; GetNativeString(1, key, 64);
	int len = GetNativeCell(3);

	any[] buffer = new any[len];
	GetNativeArray(2, buffer, len);
	gamemode.SetArray(key, buffer, len);
}

public any Native_JBGameMode_Instance(Handle plugin, int numParams)
{
	return gamemode;
}


/** LAST REQUESTS **/

public any Native_LastRequest_Instance(Handle plugin, int numParams)
{
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(1, buffer, sizeof(buffer));

	if (buffer[0] == '\0')	// Why
		return 0;

	LastRequest lr;
	if (gamemode.hLRS.GetValue(buffer, lr))
	{
		SetNativeCellRef(2, true);
		return lr;
	}

	lr = view_as< LastRequest >(new StringMap());
	lr.SetValue("__KV", new KeyValues(buffer));
	lr.SetValue("__LRID", gamemode.iLRs);
	lr.SetValue("__PL", plugin);
	lr.SetValue("__FUNCS", new FuncTable(JBFWD_LENGTH));
	lr.SetName(buffer);

	gamemode.hLRCount.Push(0);
	SetNativeCellRef(2, false);

	gamemode.hLRS.SetValue(buffer, lr);
	char id[4]; IntToString(gamemode.iLRs, id, sizeof(id));
	gamemode.hLRS.SetValue(id, lr);

	++gamemode.iLRs;

	return lr;
}
public any Native_LastRequest_CreateFromConfig(Handle plugin, int numParams)
{
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(1, buffer, sizeof(buffer));

	if (buffer[0] == '\0')	// Why
		return 0;

	LastRequest lr;

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!FileExists(strLRPath) || !kv.ImportFromFile(strLRPath))
	{
		delete kv;
		return 0;
	}


	if (!kv.JumpToKey(buffer))
	{
		delete kv;
		return 0;
	}

	// Check this last so that if it's not in config, we aren't just killing an LR
	if (gamemode.hLRS.GetValue(buffer, lr))
		lr.Destroy();	// If it already exists, destroy it and make anew

	lr = LastRequest.Create(buffer);
	lr.GetKv().Import(kv);
	lr.SetValue("__PL", plugin);	// Cheatsie doodles
	delete kv;

	return lr;
}
// Just make this a direct call?
public any Native_LastRequest_ByName(Handle plugin, int numParams)
{
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(1, buffer, sizeof(buffer));

	LastRequest lr; gamemode.hLRS.GetValue(buffer, lr);
	return lr;
}
public any Native_LastRequest_FromIndex(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	if (index == -1)	// Fail silently if its a regular round
		return 0;

	if (!(0 <= index < gamemode.hLRS.Size))	// Scream and shout if its a stupid index
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid index (%d) specified for LR!", index);

	char buffer[4]; IntToString(index, buffer, sizeof(buffer));

	if (buffer[0] == '\0')
		return 0;

	LastRequest lr; gamemode.hLRS.GetValue(buffer, lr);
	return lr;
}
public any Native_LastRequest_AddHook(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	int index = GetNativeCell(2);
	if (index < 0 || index >= JBFWD_LENGTH)	// >:(
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid index (%d) specified for hook!", index);

	Function func = GetNativeFunction(3);
	lr.SetFunction(index, view_as< JBHookCB>(func));
	return true;
}
public any Native_LastRequest_RemoveHook(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	int index = GetNativeCell(2);
	if (index < 0 || index >= JBFWD_LENGTH)	// >:(
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid index (%d) specified for hook!");

	lr.SetFunction(index, INVALID_FUNCTION);
	return true;
}
public any Native_LastRequest_Execute(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	ExecuteLR(lr);
}
public any Native_LastRequest_Destroy(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char name[MAX_LRNAME_LENGTH];
	GetNativeString(2, name, sizeof(name));

	if (name[0] == '\0')
		lr.GetName(name, sizeof(name));

	int index = lr.GetID();
	if (0 <= index < gamemode.iLRs)
	{
		char buffer[4], buffer2[4];
		int i;
		for (i = index; i < gamemode.iLRs - 1; ++i)
		{
			IntToString(i, buffer, sizeof(buffer));
			IntToString(i+1, buffer2, sizeof(buffer2));

			// Shift down
			LastRequest temp; gamemode.hLRS.GetValue(buffer2, temp);
			temp.SetValue("__LRID", temp.GetID()-1);
			gamemode.hLRS.SetValue(buffer, temp);
		}

		IntToString(i+1, buffer, sizeof(buffer));
		gamemode.hLRS.Remove(buffer);	// Get rid of the last index
		gamemode.hLRCount.Erase(index);
	}

	gamemode.hLRS.Remove(name);
	--gamemode.iLRs;

	delete lr.GetKv();
	FuncTable t; lr.GetValue("__FUNCS", t);		// I don't want functables exposed... yet...
	delete t;
	delete lr;
}
public any Native_LastRequest_IsInConfig(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(2, buffer, sizeof(buffer));

	if (buffer[0] == '\0')
		lr.GetName(buffer, sizeof(buffer));

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!kv.ImportFromFile(strLRPath))
	{
		delete kv;
		return false;
	}

	bool success = kv.JumpToKey(buffer);
	delete kv;
	return success;
}
public any Native_LastRequest_ImportFromConfig(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(2, buffer, sizeof(buffer));

	if (buffer[0] == '\0')
		lr.GetName(buffer, sizeof(buffer));

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!kv.ImportFromFile(strLRPath))
	{
		delete kv;
		return false;
	}

	bool success;
	if (kv.JumpToKey(buffer))
	{
		KeyValues lrkv = lr.GetKv();
		if (lrkv == null)
			lrkv = new KeyValues(buffer);

		lrkv.Import(kv);
		success = true;
	}
	delete kv;
	return success;
}
public any Native_LastRequest_ExportToConfig(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(2, buffer, sizeof(buffer));
	if (buffer[0] == '\0')
		lr.GetName(buffer, sizeof(buffer));

	bool create = GetNativeCell(3);
	bool createonly = GetNativeCell(4);
	bool append = GetNativeCell(5);

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!kv.ImportFromFile(strLRPath))
	{
		delete kv;
		return false;
	}

	bool success;
	if (kv.JumpToKey(buffer))
	{
		if (createonly)
		{
			delete kv;
			return false;
		}
		kv.Rewind();
	}


	if (kv.JumpToKey(buffer, create))
	{
		if (!append)
		{
			kv.DeleteThis();
			kv.Rewind();
			kv.JumpToKey(buffer, true);
		}

		KeyValues lrkv = lr.GetKv();
		if (lrkv == null)
			lrkv = new KeyValues(buffer);

		kv.Import(lrkv);
		kv.Rewind();
		success = kv.ExportToFile(strLRPath);
	}
	delete kv;
	return success;
}
public any Native_LastRequest_DeleteFromConfig(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(2, buffer, sizeof(buffer));
	if (buffer[0] == '\0')
		lr.GetName(buffer, sizeof(buffer));

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!kv.ImportFromFile(strLRPath))
	{
		delete kv;
		return false;
	}

	bool success;
	if (kv.JumpToKey(buffer))
	{
		kv.DeleteThis();
		success = true;
	}
	delete kv;
	return success;
}
public any Native_LastRequest_Refresh(Handle plugin, int numParams)
{
	LastRequest lr = GetNativeCell(1);
	char buffer[MAX_LRNAME_LENGTH];
	GetNativeString(2, buffer, sizeof(buffer));
	if (buffer[0] == '\0')
		lr.GetName(buffer, sizeof(buffer));

	KeyValues kv = new KeyValues("TF2Jail_LastRequests");
	if (!kv.ImportFromFile(strLRPath) || !kv.JumpToKey(buffer))
	{
		delete kv;
		return;
	}
	delete lr.GetKv();

	KeyValues me = new KeyValues(buffer);
	me.Import(kv);
	lr.SetValue("__KV", me);

	delete kv;
}