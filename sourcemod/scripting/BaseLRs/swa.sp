static LastRequest g_LR;

public void SWA_Init()
{
	g_LR = LastRequest.CreateFromConfig("Stealy Wheely Automobiley");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRActivatePlayer, SWA_OnLRActivatePlayer);
		g_LR.AddHook(OnLRActivate, SWA_OnLRActivate);
		g_LR.AddHook(OnRoundEnd, SWA_OnRoundEnd);
		g_LR.AddHook(OnRoundEndPlayer, SWA_OnRoundEndPlayer);
		g_LR.AddHook(OnTimeEnd, SWA_OnTimeEnd);

		JB_Hook(OnDownloads, SWA_OnDownloads);		
	}
}

public void SWA_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void SWA_OnDownloads()
{
	PrecacheModel("models/player/items/taunts/bumpercar/parts/bumpercar.mdl", true);
	PrecacheModel("models/player/items/taunts/bumpercar/parts/bumpercar_nolights.mdl", true);
	PrecacheModel("models/props_halloween/bumpercar_cage.mdl", true);

	PrecacheSound(")weapons/bumper_car_accelerate.wav", true);
	PrecacheSound(")weapons/bumper_car_decelerate.wav", true);
	PrecacheSound(")weapons/bumper_car_decelerate_quick.wav", true);
	PrecacheSound(")weapons/bumper_car_go_loop.wav", true);
	PrecacheSound(")weapons/bumper_car_hit_ball.wav", true);
	PrecacheSound(")weapons/bumper_car_hit_ghost.wav", true);
	PrecacheSound(")weapons/bumper_car_hit_hard.wav", true);
	PrecacheSound(")weapons/bumper_car_hit_into_air.wav", true);
	PrecacheSound(")weapons/bumper_car_jump.wav", true);
	PrecacheSound(")weapons/bumper_car_jump_land.wav", true);
	PrecacheSound(")weapons/bumper_car_screech.wav", true);
	PrecacheSound(")weapons/bumper_car_spawn.wav", true);
	PrecacheSound(")weapons/bumper_car_spawn_from_lava.wav", true);
	PrecacheSound(")weapons/bumper_car_speed_boost_start.wav", true);
	PrecacheSound(")weapons/bumper_car_speed_boost_stop.wav", true);
	
	char s[PLATFORM_MAX_PATH]
	for(int i = 1; i <= 8; i++)
	{
		FormatEx(s, sizeof(s), "weapons/bumper_car_hit%i.wav", i);
		PrecacheSound(s, true);
	}

	PrecacheParticleSystem("kartimpacttrail");
	PrecacheParticleSystem("kart_dust_trail_red");
	PrecacheParticleSystem("kart_dust_trail_blue");
	PrecacheParticleSystem("kartdamage_4");
}

public void SWA_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	TF2_AddCondition(player.index, TFCond_HalloweenKart, -1.0);
	SDKHook(player.index, SDKHook_GetMaxHealth, SWA_MaxHealth);
	SetEntityHealth(player.index, 100);
}

public void SWA_OnLRActivate(LastRequest lr)
{
	AddCommandListener(ForceSuicide, "explode");
	AddCommandListener(ForceSuicide, "kill");
	AddCommandListener(ForceSlay, "sm_slay");
}

public void SWA_OnRoundEndPlayer(LastRequest lr, const JBPlayer player, Event event)
{
	SDKUnhook(player.index, SDKHook_GetMaxHealth, SWA_MaxHealth);
}

public void SWA_OnRoundEnd(LastRequest lr, Event event)
{
	RemoveCommandListener(ForceSuicide, "explode");
	RemoveCommandListener(ForceSuicide, "kill");
	RemoveCommandListener(ForceSlay, "sm_slay");
}

public Action SWA_OnTimeEnd(LastRequest lr)
{
	int players[2];
	int i;
	for (i = MaxClients; i; --i)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			++players[GetClientTeam(i)-2];

	if (players[0] > players[1])
		ForceTeamWin(RED);
	else if (players[1] > players[0])
		ForceTeamWin(BLU);
	else	// Draw, nobody wins
	{
		i = CreateEntityByName("game_round_win");
		if (i != -1)
		{
			SetVariantInt(0);
			AcceptEntityInput(i, "SetTeam");
			AcceptEntityInput(i, "RoundWin");
		}
		else
		{
			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				TF2_RemoveCondition(i, TFCond_HalloweenKart);
				ForcePlayerSuicide(i);
			}
		}
	}

	return Plugin_Handled;
}

public Action ForceSuicide(int client, const char[] command, int argc)
{
	TF2_RemoveCondition(client, TFCond_HalloweenKart);
	return Plugin_Continue;
}

public Action ForceSlay(int client, const char[] command, int argc)
{
	if (!argc)
		return Plugin_Continue;

	char arg[32]; GetCmdArg(1, arg, sizeof(arg));
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		return Plugin_Continue;
	}

	for (int i = 0; i < target_count; ++i)
		TF2_RemoveCondition(target_list[i], TFCond_HalloweenKart);		// playercommands takes care of whatever else happens, probably
	return Plugin_Continue;
}

public Action SWA_MaxHealth(int client, int &health)
{
	health = 100;
	return Plugin_Changed;
}