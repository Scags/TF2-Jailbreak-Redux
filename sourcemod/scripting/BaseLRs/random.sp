static LastRequest g_LR;

public void Random_Init()
{
	g_LR = LastRequest.CreateFromConfig("Random");
	if (g_LR != null)
		g_LR.AddHook(OnLRPicked, Random_OnLRPicked);
}

public void Random_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public Action Random_OnLRPicked(LastRequest lr, const JBPlayer player)
{
	int id;
	int tries;
	LastRequest random;
	bool skip = !!lr.GetParameterNum("SkipMaxPicks", 0);
	ArrayList count = JBGameMode_GetProp("hLRCount");

	do
	{
		id = GetRandomInt(0, JBGameMode_GetProp("iLRs")-1);
		if (id == lr.GetID())
			continue;

		random = LastRequest.At(id);
		if (random == null)		// ._.
			continue;

		if (skip && count.Get(random.GetID()) >= random.UsesPerMap())
			continue;

		LastRequest exceptions = LastRequest.ByName("Commit Suicide");
		if (exceptions != null && exceptions.GetID() == id)
		{
//			exceptions.ForceFireFunction(OnLRPicked, Param_Cell, player, Param_Cell, exceptions);
			Function func = exceptions.GetFunction(OnLRPicked);
			if (func != INVALID_FUNCTION)
			{
				Call_StartFunction(exceptions.GetOwnerPlugin(), func);
				Call_PushCell(exceptions);
				Call_PushCell(player);
				Call_Finish();
			}
			break;
		}

		exceptions = LastRequest.ByName("Freeday for Others");
		if (exceptions != null && exceptions.GetID() == id)
			for (int i = 0; i < 3; i++)
				JBPlayer(GetRandomPlayer(RED)).bIsQueuedFreeday = true;

		exceptions = LastRequest.ByName("Freeday for Yourself");
		if (exceptions != null && exceptions.GetID() == id)
			player.bIsQueuedFreeday = true;

		break;
	}	while ++tries <= 50;	// Listen here jack, don't make random your only lr

	char buffer[256];
	lr.GetAnnounceMessage(buffer, sizeof(buffer));
	if (buffer[0] != '\0')
	{
		char name[32]; GetClientName(player.index, name, sizeof(name));
		ReplaceString(buffer, sizeof(buffer), "{NAME}", name);
		CPrintToChatAll("%t %s", "Plugin Tag", buffer);
	}

	JBGameMode_SetProp("iLRPresetType", id);
	JBGameMode_SetProp("bIsLRInUse", true);

	count.Set(lr.GetID(), count.Get(lr.GetID())+1);
	random.GetName(buffer, sizeof(buffer));

	if (lr.GetParameterNum("IncrementOther", 0) && count.Get(id) < random.UsesPerMap())
		count.Set(id, count.Get(id)+1);

	if (random.ActiveRound())
	{
		JBGameMode_SetProp("iLRPresetType", -1);
		JBGameMode_SetProp("iLRType", id);
		random.Execute();
	}

	return Plugin_Handled;	// Handle it because we're overriding this shit
}
