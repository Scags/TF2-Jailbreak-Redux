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
#define CBSTheme2		"saxton_hale/cbstheme2.mp3"
#define CBSTheme3		"saxton_hale/cbstheme3.mp3"

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
		if (!IsPlayerAlive(this.index) )
			return;

		int buttons = GetClientButtons(this.index);
		//float currtime = GetGameTime();
		int flags = GetEntityFlags(this.index);

		//int maxhp = GetEntProp(this.index, Prop_Data, "m_iMaxHealth");
		int health = this.iHealth;
		float speed = HALESPEED + 0.7 * (100-health*100/this.iMaxHealth);
		SetEntPropFloat(this.index, Prop_Send, "m_flMaxspeed", speed);
		
		if (this.flGlowtime > 0.0) {
			this.bGlow = 1;
			this.flGlowtime -= 0.1;
		}
		else if (this.flGlowtime <= 0.0)
			this.bGlow = 0;

		if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) )
		{
			if (this.flCharge+2.5 < HALE_JUMPCHARGE)
				this.flCharge += 1.25;
			else this.flCharge = HALE_JUMPCHARGE;
		}
		else if (this.flCharge < 0.0)
			this.flCharge += 1.25;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if ( this.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
				float vel[3]; GetEntPropVector(this.index, Prop_Data, "m_vecVelocity", vel);
				vel[2] = 750 + this.flCharge * 13.0;

				SetEntProp(this.index, Prop_Send, "m_bJumping", 1);
				vel[0] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				vel[1] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				TeleportEntity(this.index, nullvec, nullvec, vel);
				this.flCharge = -100.0;
				strcopy(snd, PLATFORM_MAX_PATH, CBSJump1);
				
				EmitSoundToAll(snd, this.index);
				EmitSoundToAll(snd, this.index);
			}
			else this.flCharge = 0.0;
		}
		if (OnlyScoutsLeft(RED))
			this.flRAGE += 0.25;

		if ( flags & FL_ONGROUND )
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;

		if ( (buttons & IN_DUCK) && this.flWeighDown >= HALE_WEIGHDOWN_TIME)
		{
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if ( ang[0] > 60.0 ) {
				//float fVelocity[3];
				//GetEntPropVector(this.index, Prop_Data, "m_vecVelocity", fVelocity);
				//fVelocity[2] = -500.0;
				//TeleportEntity(this.index, NULL_VECTOR, NULL_VECTOR, fVelocity);
				SetEntityGravity(this.index, 6.0);
				SetPawnTimer(SetGravityNormal, 1.0, this.userid);
				this.flWeighDown = 0.0;
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if (jmp > 0.0)
			jmp *= 4.0;
		if (this.flRAGE >= 100.0)
                        ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp));
                else ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: %0.1f", RoundFloat(jmp), this.flRAGE);
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
		if (!GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); //MakeModelTimer(null);
		}
		int i;
		float pos[3], pos2[3], distance;
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);

		for ( i = MaxClients ; i; --i )
		{
			if (!IsValidClient(i) || !IsPlayerAlive(i) || i == this.index )
				continue;
			else if (GetClientTeam(i) == GetClientTeam(this.index))
				continue;

			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < CBSRAGEDIST)
			{
				int flags = TF_STUNFLAGS_GHOSTSCARE;
				flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				CreateTimer(5.0, RemoveEntity, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, 5.0, _, flags, this.index);
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < CBSRAGEDIST) {
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_dispenser")) != -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < CBSRAGEDIST) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_teleporter")) != -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < CBSRAGEDIST) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}

		if (GetRandomInt(0, 1))
			Format(snd, PLATFORM_MAX_PATH, "%s", CBS1);
		else Format(snd, PLATFORM_MAX_PATH, "%s", CBS3);
		EmitSoundToAll(snd);
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
					EmitSoundToAll(snd);
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
			EmitSoundToAll(snd);
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
	PrepareSound(CBSTheme2);
	PrepareSound(CBSTheme3);

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
