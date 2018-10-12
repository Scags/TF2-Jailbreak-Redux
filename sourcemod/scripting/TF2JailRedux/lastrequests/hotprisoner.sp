#define Extinguish		"player/flame_out.wav"
#define Engulf			"misc/flame_engulf.wav"

methodmap CHotPrisoner < JailGameMode
{
	public static void Initialize()
	{
		CPrintToChatAll("{burlywood}I'm too hot! Hot damn!");
		EmitSoundToAll(Engulf);
	}

	public static void Activate( const JailFighter player )
	{
		if (GetClientTeam(player.index) == RED)
		{
			SetEntityRenderMode(player.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(player.index, 255, 75, 75, 255);
		}
	}

	public static void Terminate( Event event )
	{
		EmitSoundToAll(Extinguish);
	}

	public static void ManageTouch( const JailFighter toucher, const JailFighter touchee )
	{
		TF2_IgnitePlayer(touchee.index, toucher.index);
		SDKHooks_TakeDamage(touchee.index, 0, toucher.index, 3.0, DMG_BURN, _, _, _);	
	}

	public static void ManageEnd( const JailFighter player )
	{
		if (GetClientTeam(player.index) == RED)
			SetEntityRenderColor(player.index, 255, 255, 255, 255);
	}

	public static void SetDownloads()
	{
		PrecacheSound(Engulf, true);
		PrecacheSound(Extinguish, true);
	}
};