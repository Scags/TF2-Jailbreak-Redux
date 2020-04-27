#define BANG 			"weapons/csgo_awp_shoot.wav"

static LastRequest g_LR;

public void Suicide_Init()
{
	g_LR = LastRequest.CreateFromConfig("Commit Suicide");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRPicked, Suicide_OnLRPicked);

		JB_Hook(OnDownloads, Suicide_OnDownloads);		
	}
}

public void Suicide_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void Suicide_OnDownloads()
{
	PrecacheSound(BANG, true);
}

public Action Suicide_OnLRPicked(LastRequest lr, const JBPlayer player)
{
	SetPawnTimer(PerformSuicide, GetRandomFloat(0.5, 7.0), player.userid);
}

stock static void PerformSuicide(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (client)
	{
		EmitSoundToAll(BANG);
		ForcePlayerSuicide(client);
		if (IsPlayerAlive(client))	// In case they're kartified or something idk
			SDKHooks_TakeDamage(client, 0, 0, 9001.0, DMG_DIRECT);
	}
}