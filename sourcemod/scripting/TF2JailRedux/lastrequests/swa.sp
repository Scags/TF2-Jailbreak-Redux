methodmap CSWA < JailGameMode
{
	public static void Initialize()
	{
		gamemode.ToggleMedic(false);
		gamemode.bIsWarday = true;
		gamemode.bIsWardenLocked = true;
		gamemode.DoorHandler(OPEN);
		gamemode.EvenTeams();
		AddCommandListener(ForceSuicide, "explode");
		AddCommandListener(ForceSuicide, "kill");
		AddCommandListener(ForceSlay, "sm_slay");
	}

	public static void Activate( const JailFighter player )
	{
		TF2_AddCondition(player.index, TFCond_HalloweenKart, -1.0);
		SDKHook(player.index, SDKHook_GetMaxHealth, SWA_MaxHealth);
		SetEntityHealth(player.index, 100);
		player.iHealth = 100;
	}

	public static void Terminate( Event event )
	{
		RemoveCommandListener(ForceSuicide, "explode");
		RemoveCommandListener(ForceSuicide, "kill");
		RemoveCommandListener(ForceSlay, "sm_slay");
	}

	public static void ManageEnd( const JailFighter player )
	{
		SDKUnhook(player.index, SDKHook_GetMaxHealth, SWA_MaxHealth);
	}

	public static Action ManageTimeEnd()
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

	public static void SetDownloads()
	{
		PrecacheSound(")weapons/bumper_car_speed_boost_start.wav", true);
		PrecacheSound(")weapons/bumper_car_speed_boost_stop.wav", true);
		PrecacheSound(")weapons/bumper_car_jump.wav", true);
		PrecacheSound(")weapons/bumper_car_jump_land.wav", true);
		PrecacheSound(")weapons/bumper_car_hit_hard.wav", true);
		PrecacheSound(")weapons/bumper_car_hit_into_air.wav", true);

		char s[PLATFORM_MAX_PATH];
		for (int i = 1; i <= 8; i++)
		{
			Format(s, PLATFORM_MAX_PATH, "weapons/bumper_car_hit%i.wav", i);
			PrecacheSound(s, true);
		}
	}

	public static void ManageHurtPlayer(const JailFighter attacker, const JailFighter victim, Event event)
	{
		victim.iHealth -= event.GetInt("damageamount");
		if (victim.iHealth < 0)
		{
//			SDKHooks_TakeDamage(victim.index, attacker.index, attacker.index, 100.0, DMG_VEHICLE);
			victim.iHealth = 0;
		}
	}

	public static void ManageThink(const JailFighter player)
	{
		if (IsPlayerAlive(player.index))
		{
			if (player.iHealth <= 0)
				SDKHooks_TakeDamage(player.index, 0, 0, 9001.0, DMG_DIRECT);
			else SetEntityHealth(player.index, player.iHealth);
		}
	}
};

public Action ForceSuicide(int client, const char[] command, int argc)
{
	TF2_RemoveCondition(client, TFCond_HalloweenKart);
	return Plugin_Continue;
}

public Action ForceSlay(int client, const char[] command, int argc)
{
	if (!GetCmdArgs())
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