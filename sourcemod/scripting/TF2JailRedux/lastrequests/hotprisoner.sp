
methodmap CHotPrisoner < JailGameMode
{
	public void Initialize()
	{
		CPrintToChatAll("{burlywood}I'm too hot! Hot damn!");
		EmitSoundToAll(Engulf);
	}

	public void Activate( const JailFighter player )
	{
		if (GetClientTeam(player.index) == RED)
		{
			SetEntityRenderMode(player.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(player.index, 255, 75, 75, 255);
		}
	}

	public void Terminate( Event event )
	{
		EmitSoundToAll(Extinguish);
	}

	public void ManageTouch( const JailFighter toucher, const JailFighter touchee )
	{
		TF2_IgnitePlayer(touchee.index, toucher.index);
		SDKHooks_TakeDamage(touchee.index, 0, toucher.index, 3.0, DMG_BURN, _, _, _);	
	}

	public void ManageEnd( const JailFighter player )
	{
		if (GetClientTeam(player.index) == RED)
			SetEntityRenderColor(player.index, 255, 255, 255, 255);
	}
};

public CHotPrisoner ToCHotPrisoner( JailGameMode handle )
{
	return view_as< CHotPrisoner >(handle);
}

public void HotPrisonerDownload()
{
	PrecacheSound(Engulf, true);
	PrecacheSound(Extinguish, true);
}