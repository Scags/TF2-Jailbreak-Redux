static LastRequest g_Warday, g_ClassWars;

public void Warday_Init()
{
	g_Warday = LastRequest.CreateFromConfig("Warday");
	if (g_Warday != null)
	{
		g_Warday.AddHook(OnPlayerPrepped, Warday_OnPlayerPrepped);
		g_Warday.AddHook(OnLRActivatePlayer, Warday_OnLRActivatePlayer)
	}

	g_ClassWars = LastRequest.CreateFromConfig("Class Warfare");
	if (g_ClassWars != null)
	{
		g_ClassWars.AddHook(OnPlayerPrepped, Warday_OnPlayerPrepped);
		g_ClassWars.AddHook(OnLRActivate, ClassWars_OnLRActivate);
		g_ClassWars.AddHook(OnLRActivatePlayer, Warday_OnLRActivatePlayer)
	}
}

public void Warday_Destroy()
{
	if (g_Warday != null)
		g_Warday.Destroy();
	if (g_ClassWars != null)
		g_ClassWars.Destroy();
}

public Action Warday_OnPlayerPrepped(LastRequest lr, const JBPlayer player)
{
	return Plugin_Handled;
}

public void Warday_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	TF2_RegeneratePlayer(player.index);
}

public void ClassWars_OnLRActivate(LastRequest lr)
{
	TFClassType classes[2];
	classes[0] = view_as< TFClassType >(GetRandomInt(1, 9));
	classes[1] = view_as< TFClassType >(GetRandomInt(1, 9));
	
	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			TF2_SetPlayerClass(i, classes[GetClientTeam(i)-2], _, false);
}