#define EXTINGUISH		"player/flame_out.wav"
#define ENGULF			"misc/flame_engulf.wav"

static LastRequest g_LR;

public void Hot_Init()
{
	g_LR = LastRequest.CreateFromConfig("Hot Prisoner");
	if (g_LR != null)
	{
		g_LR.AddHook(OnPlayerTouch, Hot_OnPlayerTouch);
		g_LR.AddHook(OnLRActivatePlayer, Hot_OnLRActivatePlayer);
		g_LR.AddHook(OnRoundEndPlayer, Hot_OnRoundEndPlayer);
		g_LR.AddHook(OnLRActivate, Hot_OnLRActivate);
		g_LR.AddHook(OnRoundEnd, Hot_OnRoundEnd);

		JB_Hook(OnDownloads, Hot_OnDownloads);
	}
}

public void Hot_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void Hot_OnDownloads()
{
	PrecacheSound(EXTINGUISH, true);
	PrecacheSound(ENGULF, true)
}

public void Hot_OnPlayerTouch(LastRequest lr, const JBPlayer player, const JBPlayer other)
{
	if (GetClientTeam(player.index) == RED)
	{
		TF2_IgnitePlayer(other.index, player.index);
		SDKHooks_TakeDamage(other.index, 0, player.index, 3.0, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE);	
	}
}

public void Hot_OnLRActivatePlayer(LastRequest lr, const JBPlayer player)
{
	if (GetClientTeam(player.index) == RED)
	{
		SetEntityRenderMode(player.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(player.index, 255, 75, 75, 255);
	}
}

public void Hot_OnRoundEndPlayer(LastRequest lr, const JBPlayer player, Event event)
{
	if (GetClientTeam(player.index) == RED)
		SetEntityRenderColor(player.index, 255, 255, 255, 255);
}

public void Hot_OnLRActivate(LastRequest lr)
{
	EmitSoundToAll(ENGULF);
}

public void Hot_OnRoundEnd(LastRequest lr, Event event)
{
	EmitSoundToAll(EXTINGUISH)
}