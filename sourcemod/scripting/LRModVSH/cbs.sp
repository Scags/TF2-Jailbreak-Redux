//defines
#define CBSModel		"models/player/saxton_hale/cbs_v4.mdl"
// #define CBSModelPrefix		"models/player/saxton_hale/cbs_v4"

//CBS voicelines
#define CBS0			"vo/sniper_specialweapon08.mp3"
#define CBS1			"vo/taunts/sniper_taunts02.mp3"
#define CBS2			"vo/sniper_award"
#define CBS3			"vo/sniper_battlecry03.mp3"
#define CBS4			"vo/sniper_domination"
#define CBSJump1		"vo/sniper_specialcompleted02.mp3"

#define CBSTheme		"saxton_hale/the_millionaires_holiday.mp3"

#define CBSRAGEDIST		320.0
#define CBS_MAX_ARROWS		5



methodmap CChristian < JailBoss
{
	public CChristian(const int ind, bool uid = false)
	{
		if (uid)
			return view_as<CChristian>( JailBoss(ind, true) );
		return view_as<CChristian>( JailBoss(ind) );
	}

	public void PlaySpawnClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, CBS0);
		EmitSoundToAll(snd);
	}

	public void Think ()
	{
		this.DoGenericThink(true, true, CBSJump1);
	}
	public void SetModel ()
	{
		SetVariantString(CBSModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		//EmitSoundToAll(snd, this.index);
	}

	public void Equip ()
	{
		this.PreEquip();
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_club", 171, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if ( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); //MakeModelTimer(null);
		}

		this.DoGenericStun(CBSRAGEDIST);

		if (GetRandomInt(0, 1))
			Format(snd, PLATFORM_MAX_PATH, "%s", CBS1);
		else Format(snd, PLATFORM_MAX_PATH, "%s", CBS3);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int bow = this.SpawnWeapon("tf_weapon_compound_bow", 1005, 100, 5, "2 ; 2.1 ; 6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19 ; 551 ; 1");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", bow); //266 ; 1.0 - penetration
		
		int living = GetLivingPlayers(RED);
		SetWeaponAmmo(bow, ((living >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : living));
	}

	public void KilledPlayer(const JailBoss victim, Event event)
	{
		int living = GetLivingPlayers(RED);

		if (!GetRandomInt(0, 3) && living != 1) {
			switch (TF2_GetPlayerClass(victim.index))
			{
				case TFClass_Spy:
				{
					strcopy(snd, PLATFORM_MAX_PATH, "vo/sniper_dominationspy04.mp3");
					EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				}
			}
		}
		int weapon = GetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon");
		if (weapon == GetPlayerWeaponSlot(this.index, TFWeaponSlot_Melee))
		{
			TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Melee);
			int clubindex;
			switch ( GetRandomInt(0, 14) ) {
				case 0: clubindex = 171;
				case 1: clubindex = 3;
				case 2: clubindex = 232;
				case 3: clubindex = 401;
				case 4: clubindex = 264;
				case 5: clubindex = 423;
				case 6: clubindex = 474;
				case 7: clubindex = 880;
				case 8: clubindex = 939;
				case 9: clubindex = 954;
				case 10: clubindex = 1013;
				case 11: clubindex = 1071;
				case 12: clubindex = 1123;
				case 13: clubindex = 1127;
				case 14: clubindex = 30758;
			}
			weapon = this.SpawnWeapon("tf_weapon_club", clubindex, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
			SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		}

		float curtime = GetGameTime();
		if ( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if (this.iKills == 3 && living != 1) {
			if (!GetRandomInt(0, 3))
				Format(snd, PLATFORM_MAX_PATH, CBS0);
			else if (!GetRandomInt(0, 3))
				Format(snd, PLATFORM_MAX_PATH, CBS1);
			else Format(snd, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, GetRandomInt(1, 9));
			EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[] = "Christian Brutal Sniper:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Huntsman Bow): Call for medic (e) when Rage is full (5 max arrows).\nVery close-by enemies are stunned.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
	}
	public void LastPlayerSoundClip()
	{
		if (!GetRandomInt(0, 2))
			Format(snd, PLATFORM_MAX_PATH, "%s", CBS0);
		else Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, GetRandomInt(1, 25));
		EmitSoundToAll(snd);
	}
};

public CChristian ToCChristian (const JailBoss guy)
{
	return view_as<CChristian>(guy);
}

public void AddCBSToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	
	int i;

	PrepareModel(CBSModel);

	PrepareMaterial("materials/models/player/saxton_hale/sniper_red");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_lens");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_head");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_head_red");

	PrecacheSound(CBS0, true);
	PrecacheSound(CBS1, true);
	PrecacheSound(CBS3, true);
	PrecacheSound(CBSJump1, true);
	PrepareSound(CBSTheme);

	for (i = 1; i <= 25; i++)
	{
		if (i <= 9)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, i);
			PrecacheSound(s, true);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS4, i);
		PrecacheSound(s, true);
	}

	PrecacheSound("vo/sniper_dominationspy04.mp3", true);
}

public void AddCBSToMenu ( Menu& menu )
{
	menu.AddItem("2", "Christian Brutal Sniper");
}

