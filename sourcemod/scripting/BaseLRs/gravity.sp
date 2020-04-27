#define GRAVITY 	"vo/scout_sf12_badmagic11.mp3"

// Almost completely managed by config
static LastRequest g_LR;

public void Gravity_Init()
{
	g_LR = LastRequest.CreateFromConfig("Low Gravity");
	if (g_LR != null)
	{
		g_LR.AddHook(OnLRActivate, Gravity_OnLRActivate);

		JB_Hook(OnDownloads, Gravity_OnDownloads);
	}
}

public void Gravity_Destroy()
{
	if (g_LR != null)
		g_LR.Destroy();
}

public void Gravity_OnDownloads()
{
	PrecacheSound(GRAVITY, true);
}

public void Gravity_OnLRActivate(LastRequest lr)
{
	EmitSoundToAll(GRAVITY);
}