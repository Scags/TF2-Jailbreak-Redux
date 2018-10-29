#define HHHModel			"models/player/saxton_hale/hhh_jr_mk3.mdl"
// #define HHHModelPrefix			"models/player/saxton_hale/hhh_jr_mk3"

//HHH voicelines
#define HHHLaught			"vo/halloween_boss/knight_laugh"
#define HHHRage				"vo/halloween_boss/knight_attack01.mp3"
#define HHHRage2			"vo/halloween_boss/knight_alert.mp3"
#define HHHAttack			"vo/halloween_boss/knight_attack"
#define HHHPain				"vo/halloween_boss/knight_pain"

#define HHHTheme			"ui/holiday/gamestartup_halloween.mp3"

#define HALEHHH_TELEPORTCHARGETIME	2
#define HALEHHH_TELEPORTCHARGE		(25.0 * HALEHHH_TELEPORTCHARGETIME)


methodmap CHHHJr < JailBoss
{
	public CHHHJr(const int ind, bool uid = false)
	{
		if (uid)
			return view_as<CHHHJr>( JailBoss(ind, true) );
		return view_as<CHHHJr>( JailBoss(ind) );
	}

	public void PlaySpawnClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
		EmitSoundToAll(snd);
	}

	public void Think ()
	{
		if (!IsPlayerAlive(this.index))
			return;

		this.DoGenericThink();
		int client = this.index;
		int buttons = GetClientButtons(client);
		float currtime = GetGameTime();
		int flags = GetEntityFlags(client);
		
		if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) )
		{
			if (this.flCharge+2.5 < HALEHHH_TELEPORTCHARGE)
				this.flCharge += 2.5;
			else this.flCharge = HALEHHH_TELEPORTCHARGE;
		}
		else if (this.flCharge < 0.0)
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
			if ( this.flCharge == HALEHHH_TELEPORTCHARGE && EyeAngles[0] < -5.0 ) {
				int living;
				switch (GetClientTeam(client))
				{
					case 2: living = GetLivingPlayers(3);
					case 3: living = GetLivingPlayers(2);
				}
				int target = -1;
				while (living > 0) {
					target = GetRandomInt(1, MaxClients);
					if ( !IsValidClient(target) || !IsPlayerAlive(target) )
						continue;
					if (target == client || GetClientTeam(target) == GetClientTeam(client))
						continue;
					break;
				}
				if (IsValidClient(target)) {
					// Chdata's HHH teleport rework
					if (TF2_GetPlayerClass(target) != TFClass_Scout && TF2_GetPlayerClass(target) != TFClass_Soldier)
					{
						SetEntProp(client, Prop_Send, "m_CollisionGroup", 2); //Makes HHH clipping go away for player and some projectiles
						SetPawnTimer(HHHTeleCollisionReset, 2.0, this.userid);
						//hHHHTeleTimer = CreateTimer(bEnableSuperDuperJump ? 4.0 : 2.0, HHHTeleTimer, Hale, TIMER_FLAG_NO_MAPCHANGE);
					}

					AttachParticle(client, "ghost_appearation", 3.0);
					float pos[3]; GetClientAbsOrigin(target, pos);
					SetEntPropFloat(client, Prop_Send, "m_flNextAttack", currtime+2);
					if (GetEntProp(target, Prop_Send, "m_bDucked"))
					{
						float collisionvec[3] = {24.0, 24.0, 62.0};
						SetEntPropVector(client, Prop_Send, "m_vecMaxs", collisionvec);
						SetEntProp(client, Prop_Send, "m_bDucked", 1);
						SetEntityFlags(client, flags|FL_DUCKING);
						SetPawnTimer(StunHHH, 0.2, this.userid, GetClientUserId(target));
					}
					else
						TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
					TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
					SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
					AttachParticle(client, "ghost_appearation", 3.0, _, false);

					// Chdata's HHH teleport rework
					float vPos[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);

					//EmitSound("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_SCREAMING, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
					EmitSoundToClient(target, "misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_SCREAMING, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
					PrintCenterText(target, "You've been teleported!");

					this.flCharge = -1100.0;
				}
			}
			else this.flCharge = 0.0;
		}
		if ( flags & FL_ONGROUND ) {
			this.flWeighDown = 0.0;
			this.iClimbs = 0;
		}
		else this.flWeighDown += 0.1;
	}
	public void SetModel ()
	{
		SetVariantString(HHHModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		Format(snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_death0%d.mp3", GetRandomInt(1, 2));
		EmitSoundToAll(snd);
	}

	public void Equip ()
	{
		this.PreEquip();
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.3 ; 551 ; 1 ; 534 ; 0.3");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_sword", 266, 100, 5, attribs);
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

		this.DoGenericStun(HALERAGEDIST);

		strcopy(snd, PLATFORM_MAX_PATH, HHHRage2);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}

	public void KilledPlayer(const JailBoss victim, Event event)
	{
		int living = GetLivingPlayers(RED);

		Format(snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, GetRandomInt(1, 4));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

		float curtime = GetGameTime();
		if ( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if (this.iKills == 3 && living != 1) {
			Format(snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
			EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[] = "Horseless Headless Horsemann Jr.:\nTeleporter: Right-click, look up, and release when number reaches 100.\nWeigh-down: After 1 second in midair, look down and hold crouch\nRage (stun): Call for medic (e) when Rage is full to stun nearby enemies.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
	}
};

public CHHHJr ToCHHHJr (const JailBoss guy)
{
	return view_as<CHHHJr>(guy);
}

public void AddHHHToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	
	int i;

	PrepareModel(HHHModel);

	for (i = 1; i <= 4; i++) {
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHPain, i);
		PrecacheSound(s, true);

	}
	PrecacheSound(HHHRage, true);
	PrecacheSound(HHHRage2, true);
	PrecacheSound(HHHTheme, true);

	PrecacheSound("ui/halloween_boss_summoned_fx.wav", true);
	PrecacheSound("ui/halloween_boss_defeated_fx.wav", true);
	PrecacheSound("vo/halloween_boss/knight_pain01.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_pain02.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_pain03.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_death01.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_death02.mp3", true);
	PrecacheSound("misc/halloween/spell_teleport.wav", true);
}

public void AddHHHToMenu ( Menu& menu )
{
	menu.AddItem("3", "Horseless Headless Horsemann Jr.");
}

public void HHHTeleCollisionReset(const int userid)
{
	int client = GetClientOfUserId(userid);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5); //Fix HHH's clipping.
}
public void StunHHH(const int userid, const int targetid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	int target = GetClientOfUserId(targetid);
	if (!IsValidClient(target) || !IsPlayerAlive(target))
		target = 0;
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}
