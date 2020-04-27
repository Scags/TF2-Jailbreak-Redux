#define HHH 			"models/bots/headless_hatman.mdl"	// Taken from flaminsarge's bethehorsemann don't crucify me
#define AXE 			"models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"
#define SPAWN 			"ui/halloween_boss_summoned_fx.wav"
#define SPAWNRUMBLE 	"ui/halloween_boss_summon_rumble.wav"
#define SPAWNVO 		"vo/halloween_boss/knight_spawn.wav"
#define BOO 			"vo/halloween_boss/knight_alert.wav"
#define DEATH 			"ui/halloween_boss_defeated_fx.wav"
#define DEATHVO 		"vo/halloween_boss/knight_death02.wav"
#define DEATHVO2 		"vo/halloween_boss/knight_dying.wav"
#define LEFTFOOT 		"player/footsteps/giant1.wav"
#define RIGHTFOOT 		"player/footsteps/giant2.wav"


methodmap CHHHDay < JailGameMode
{
	public static void Initialize()
	{
		gamemode.bIsWardenLocked = true;	// Static methods can't use 'this' for semi-obvious reasons
		gamemode.bIsWarday = true;
		gamemode.bDisableCriticals = true;
		CPrintToChatAll("{burlywood}BOO!");
		EmitSoundToAll(SPAWN);
		EmitSoundToAll(SPAWNRUMBLE);
		gamemode.DoorHandler(OPEN);
	}

	public static void Activate( const JailFighter player )
	{
		player.MakeHorsemann();	// Fuck server commands, hard coding feels more solid
	}

	public static Action HookSound( const JailFighter player, char sample[PLATFORM_MAX_PATH], int &entity )
	{
		if (player.bIsHHH)
		{
			if (!strncmp(sample, "vo", 2, false))
				return Plugin_Handled;

			if (strncmp(sample, "player/footsteps/", 17, false) != -1)
			{
				if (StrContains(sample, "1.wav", false) != -1 || StrContains(sample, "3.wav", false) != -1) 
					sample = LEFTFOOT;
				else if (StrContains(sample, "2.wav", false) != -1 || StrContains(sample, "4.wav", false) != -1) 
					sample = RIGHTFOOT;
				EmitSoundToAll(sample, entity);
				return Plugin_Changed;
			}
		}
		return Plugin_Continue;
	}

	public static void Terminate( Event event )
	{
		EmitSoundToAll(DEATH);
		EmitSoundToAll(DEATHVO);
		EmitSoundToAll(DEATHVO2);
	}

	public static void ManageEnd( const JailFighter player )
	{
		if (player.bIsHHH)
			SetPawnTimer(UnHorsemannify, 1.0, player);
	}

	public static void ManageDeath( const JailFighter attacker, const JailFighter victim, Event event )
	{
		if (victim.bIsHHH)
		{
			EmitSoundToAll(DEATHVO, victim.index);
			SetPawnTimer(UnHorsemannify, 0.2, victim);
		}
	}

	public static void SetDownloads()
	{
		PrecacheModel(HHH, true);
		PrecacheModel(AXE, true);
		PrecacheSound(SPAWN, true);
		PrecacheSound(SPAWNRUMBLE, true);
		PrecacheSound(SPAWNVO, true);
		PrecacheSound(BOO, true);
		PrecacheSound(DEATH, true);
		PrecacheSound(DEATHVO, true);
		PrecacheSound(DEATHVO2, true);
		PrecacheSound(LEFTFOOT, true);
		PrecacheSound(RIGHTFOOT, true);
	}
};