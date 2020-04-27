#define TINY 	"vo/scout_sf12_badmagic28.mp3"

static LastRequest g_LR;

public void Tiny_Init()
{
	g_LR = LastRequest.CreateFromConfig("Tiny Round");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRActivate, Tiny_OnLRActivate);
		g_LR.AddHook(OnLRActivatePlayer, Tiny_OnLRActivatePlayer);
		g_LR.AddHook(OnRoundEndPlayer, Tiny_OnRoundEndPlayer);

		JB_Hook(OnDownloads, Tiny_OnDownloads);		
	}
}

public void Tiny_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void Tiny_OnDownloads()
{
	PrecacheSound(TINY, true);
}

public void Tiny_OnLRActivate(LastRequest lr)
{
	EmitSoundToAll(TINY);
}

public void Tiny_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	SetEntPropFloat(player.index, Prop_Send, "m_flModelScale", 0.3);
}

public void Tiny_OnRoundEndPlayer(LastRequest lr, const JBPlayer player, Event event)
{
	SetEntPropFloat(player.index, Prop_Send, "m_flModelScale", 1.0);
}