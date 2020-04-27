static LastRequest g_LR;

//static char g_strCustomLR[MAX_LRNAME_LENGTH];

public void Custom_Init()
{
	g_LR = LastRequest.CreateFromConfig("Custom Request");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRPicked, Custom_OnLRPicked);
		g_LR.AddHook(OnRoundEnd, Custom_OnRoundEnd);
	}
}

public void Custom_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
	g_LR = null;		// Exception here, Destroy() doesn't set to null obv so if
						// redux unloads, lots of errors to be had in the say hook
}

public Action Custom_OnLRPicked(LastRequest lr, const JBPlayer player)
{
	player.iCustom = player.userid;
}

public void Custom_OnClientSayCommand(int client, const char[] sCommand, const char[] cArgs)
{
	JBPlayer base = JBPlayer(client);
	if (!IsChatTrigger() && g_LR != null && base.iCustom > 0)
	{
		g_LR.SetHudName(cArgs);
//		strcopy(g_strCustomLR, sizeof(g_strCustomLR), cArgs);
		CPrintToChat(client, "%t %t", "Plugin Tag", "Custom Activate", cArgs);
		base.iCustom = 0;
	}
}

public void Custom_OnRoundEnd(LastRequest lr, Event event)
{
	lr.SetHudName("");
}