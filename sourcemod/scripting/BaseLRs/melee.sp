#define NO_GUNS 			"vo/heavy_meleedare02.mp3"

static LastRequest g_LR;

public void Melee_Init()
{
	g_LR = LastRequest.CreateFromConfig("Guards Melee Only Round");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRActivate, Melee_OnLRActivate);
		g_LR.AddHook(OnLRActivatePlayer, Melee_OnLRActivatePlayer);

		JB_Hook(OnDownloads, Melee_OnDownloads);
	}
}

public void Melee_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void Melee_OnDownloads()
{
	PrecacheSound(NO_GUNS, true);
}

public void Melee_OnLRActivate(LastRequest lr)
{
	EmitSoundToAll(NO_GUNS);
}

public void Melee_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	if (GetClientTeam(player.index) == BLU)
	{
		int wep = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee);
		if (wep > MaxClients && IsValidEntity(wep))
		{
			int idx = GetItemIndex(wep);
			if (idx == 44 || idx == 648)
			{
				TF2_RemoveWeaponSlot(player.index, TFWeaponSlot_Melee);
				player.SpawnWeapon("tf_weapon_bat", 0, 1, 0, "");
				SetEntityHealth(player.index, 125);
			}
		}
	}
}