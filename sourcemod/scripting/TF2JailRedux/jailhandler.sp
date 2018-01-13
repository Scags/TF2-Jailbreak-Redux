#define GravSound 		"vo/scout_sf12_badmagic11.mp3"
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
#define Extinguish		"player/flame_out.wav"
#define Engulf			"misc/flame_engulf.wav"
#define SuicideSound	"weapons/csgo_awp_shoot.wav"
#define GunSound		"vo/heavy_meleedare02.mp3"
#define TinySound		"vo/scout_sf12_badmagic28.mp3"
// #define WardaySound		"tf2jailredux/warday.mp3"
#define NO 				"vo/heavy_no02.mp3"

/** 
 *	Simply add your new lr name to the enum to register it with function calls and switch statements
 *	Add them to the calls accordingly 
*/
enum /** LRs **/
{
	// RegularGameplay = -1,
	Suicide = 0,	//
	Custom = 1,		// These 2 shouldn't register with gameplay orientation and are kept out of randlr, -1 is regular gameplay btw
	FreedaySelf = 2,
	FreedayOther = 3,
	FreedayAll = 4,
	GuardMelee = 5,
	HHHDay = 6,
	TinyRound = 7,
	HotPrisoner = 8,
	Gravity = 9,
	RandomKill = 10,
	Warday = 11,
	ClassWars = 12,
	VSH = 13			// DO NOT SET ANY NEW LRS UNDER THESE NUMBERS UNLESS YOU DISABLE OR ADJUST THE SUB PLUGIN!
	//PH = 14,			// THEY WILL OVERLAP!
};
/** 
 *	When adding a new lr, increase the LRMAX to the proper/latest enum value
 *	Reminder that random lr grabs a random int from 2 to LRMAX
 *	Having breaks or skips within the enum will result in nothing happening the following round if that number is selected
*/
#define LRMAX		VSH// + (g_hPluginsRegistered.Length)

#include "TF2JailRedux/jailbase.sp"
#include "TF2JailRedux/jailgamemode.sp"

JailGameMode gamemode; // Sticking this sucker right here because it works

/** 
 *	SINCE THE PYRO UPDATE, FORCING PLAYERS AS THE SNIPER CLASS CAN AND WILL CAUSE SERVER CRASHES
*/
int arrClass[8] = { 1, 3, 4, 5, 6, 7, 8, 9 };

/** 
 *	Array of LR usage
 *	You can determine the maximum picks per round under menu selection
 *	Since array values default at 0, we can keep this blank
*/
int arrLRS[LRMAX + 1] = {	/* Plus 1 to counterbalance the 0 in the enum*/ 	};

/** 
 *	Add your LR name to the array, referred back to in LRMenuAdd()
*/
char strLRNames[][] = {
	"Suicide",
	"Custom",
	"Freeday for Yourself",
	"Freeday for Others",
	"Freeday for All",
	"Guards Melee Only",
	"Headless Horsemann Day",
	"Tiny Round",
	"Hot Prisoner",
	"Low Gravity",
	"Sniper!",
	"Warday",
	"Class Wars",
	"Versus Saxton Hale"
};

/** 
 *	Calls on map start, don't forget 'Prepare' stocks precache and set downloads at the same time! 
*/
public void ManageDownloads()
{
	PrecacheSound("vo/announcer_ends_60sec.mp3", true);
	PrecacheSound("vo/announcer_ends_30sec.mp3", true);
	PrecacheSound("vo/announcer_ends_10sec.mp3", true);
	for (int s = 1; s <= 5; s++)
	{
		Format(snd, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", s);
		PrecacheSound(snd, true);
	}
	PrecacheSound(GravSound, true);
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
	PrecacheSound(Extinguish, true);
	PrecacheSound(Engulf, true);
	PrecacheSound(SuicideSound, true);
	PrecacheSound(GunSound, true);
	PrecacheSound(TinySound, true);
	PrecacheSound(NO, true);

	// PrepareSound(WardaySound);
	// Call_OnDownloads();
}
/**
 *	Called on map start again but this time for the starting lr count
*/
public void LRMapStartVariables()
{
	for (int i = 0; i < LRMAX; i++)
		arrLRS[i] = 0;
}
/** 
 *	Calls on map end, resets for lr variables
*/
public void ManageMapResetVariables(const JailFighter player)
{
	if (player.bIsHHH)
		player.UnHorsemann();
		
	ResetModelProps(player.index);
	player.SetCustomModel("");
	//RemoveModel(player.index);
}
/**
 *	Another reset, but calls on disconnect for safety
*/
public void ManageClientDisconnect(const JailFighter player)
{
	if (player.bIsWarden)
	{
		player.WardenUnset();
		PrintCenterTextAll("Warden has disconnected!");
		gamemode.bWardenExists = false;
	}
	
	if (player.bIsFreeday)
		player.RemoveFreeday();
}
/**
 *	Add lr to the LR menu obviously
*/
public void AddLRToMenu(Menu & menu)
{
	char strName[32];
	char strID[4];
	int iMax;

	menu.AddItem("0", "Random LR");
	for (int i = 0; i < sizeof(strLRNames); i++)	// Can also do '<= LRMAX' but either way is fine
	{
		iMax = LR_DEFAULT;	// 5
		// if (i == 2)	// If you want a certain last request to have a different max, do something like this
			// iMax = 3;
		Format(strName, sizeof(strName), "%s (%i/%i)", strLRNames[i][0], arrLRS[i], iMax);
		Format(strID, sizeof(strID), "%i", i+1);	// Bleh, also +1 because of the random LR
		menu.AddItem(strID, strName, arrLRS[i] >= iMax ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT); // Disables the LR selection if the max is too high
	}
	//Call_OnMenuAdd(menu);
}
/**
 *	Add a 'short' description to your last request for the !listlrs command
*/
public void AddLRToPanel(Panel& panel)
{
	panel.DrawItem("Custom- Type your own last request");
	panel.DrawItem("Freeday for Yourself- Give yourself a freeday");
	panel.DrawItem("Freeday for Others- Give up to %i freedays to others", cvarTF2Jail[FreedayLimit].IntValue);
	panel.DrawItem("Freeday for All- Give everybody a freeday");
	panel.DrawItem("Suicide- Kill yourself on the spot");
	panel.DrawItem("Guards Melee Only- Those guns are for babies!");
	panel.DrawItem("Headless Horsemann Day- Turns all players into the HHH");
	panel.DrawItem("Rapid Rockets Day- Completely obliterate everything");
	panel.DrawItem("Tiny Round- Honey I shrunk the players");
	panel.DrawItem("Hot Prisoner- Prisoners are too hot to touch");
	panel.DrawItem("Low Gravity- Where did the gravity go");
	panel.DrawItem("Sniper- A hired gun to take out some folks");
	panel.DrawItem("Warday- Team Deathmatch");
	panel.DrawItem("Class Wars- Warday but it's class versus class");
	panel.DrawItem("Versus Saxton Hale- A nice round of VSH");
}
/** 
 *	Called when player is given lr and is selecting. Place your lr under the MenuAction_Select case
 *	Use the already given lr's as a guide if you need help
*/
public int ListLRsMenu(Menu menu, MenuAction action, int client, int select)
{
	if (!IsClientValid(client) || !IsPlayerAlive(client))
		return;
		
	JailFighter base = JailFighter(client);
	switch (action)
	{
		case MenuAction_Select:
		{
			if (cvarTF2Jail[RemoveFreedayOnLR].BoolValue)
			{
				for (int i = MaxClients; i; --i)
				{
					if (!IsClientValid(i) || !JailFighter(i).bIsFreeday)
						continue;
					JailFighter(i).RemoveFreeday();
				}
				CPrintToChatAll("{red}[JailRedux]{tan} Last request has been chosen. Freedays have been stripped.");
			}
			gamemode.bIsLRInUse = true;
			
			switch (select)
			{
				case 0:	// Random
				{
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen a {default}Random Last Request{tan} as their last request!", client);
					int randlr = GetRandomInt(2, LRMAX);
					gamemode.iLRPresetType = randlr;
					arrLRS[randlr]++;
					if (randlr == FreedaySelf)
						base.bIsQueuedFreeday = true;
					else if (randlr == FreedayOther)
					{
						for (int i = 0; i < 3; i++)
							JailFighter( Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_NOBOTS) ).bIsQueuedFreeday = true;
					}
					return;
				}
				case (Suicide+1):
				{
					if (!CheckSet(client, arrLRS[Suicide], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to kill themselves. What a shame...", client);
					SetPawnTimer(KillThatBitch, (GetRandomFloat(0.5, 7.0)), client);	// Meme lol
					arrLRS[Suicide]++;
					return;
				}
				case (Custom+1):
				{
					if (!CheckSet(client, arrLRS[Custom], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to type out their LR in chat.", client);
					gamemode.iLRPresetType = Custom;
					arrLRS[Custom]++;
					base.iCustom = base.userid;
					return;
				}
				case (FreedaySelf+1):
				{
					if (!CheckSet(client, arrLRS[FreedaySelf], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Freeday for Themselves{tan} next round.", client);
					gamemode.iLRPresetType = FreedaySelf;
					base.bIsQueuedFreeday = true;
					arrLRS[FreedaySelf]++;
					return;
				}
				case (FreedayOther+1):
				{
					if (!CheckSet(client, arrLRS[FreedayOther], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N is picking Freedays for next round...", client);
					GiveFreedaysMenu(client);
					gamemode.iLRPresetType = FreedayOther;
					arrLRS[FreedayOther]++;
					return;
				}
				case (FreedayAll+1):
				{
					if (!CheckSet(client, arrLRS[FreedayAll], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to grant {default}Freeday for All{tan} next round.", client);
					gamemode.iLRPresetType = FreedayAll;
					arrLRS[FreedayAll]++;
					return;
				}
				case (GuardMelee+1):
				{
					if (!CheckSet(client, arrLRS[GuardMelee], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to strip the guards of their weapons.", client);
					gamemode.iLRPresetType = GuardMelee;
					arrLRS[GuardMelee]++;
					return;
				}
				case (HHHDay+1):
				{
					if (!CheckSet(client, arrLRS[HHHDay], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Horseless Headless Horsemann Kill Round{tan} next round.", client);
					gamemode.iLRPresetType = HHHDay;
					arrLRS[HHHDay]++;
					return;
				}
				case (TinyRound+1):
				{
					if (!CheckSet(client, arrLRS[TinyRound], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Super Small{tan} for everyone.", client);
					gamemode.iLRPresetType = TinyRound;
					arrLRS[TinyRound]++;
					return;
				}
				case (HotPrisoner+1):
				{
					if (!CheckSet(client, arrLRS[HotPrisoner], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to ignite all of the prisoners next round!", client);
					gamemode.iLRPresetType = HotPrisoner;
					arrLRS[HotPrisoner]++;
					return;
				}
				case (Gravity+1):
				{
					if (!CheckSet(client, arrLRS[Gravity], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Low Gravity{tan} as their last request.", client);
					gamemode.iLRPresetType = Gravity;
					arrLRS[Gravity]++;
					return;
				}
				case (RandomKill+1):
				{
					if (!CheckSet(client, arrLRS[RandomKill], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to hire a Sniper for next round!", client);
					gamemode.iLRPresetType = RandomKill;
					arrLRS[RandomKill]++;
					return;
				}
				case (Warday+1):
				{
					if (!CheckSet(client, arrLRS[Warday], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to do a {default}warday{tan}.", client);
					gamemode.iLRPresetType = Warday;
					arrLRS[Warday]++;
					return;
				}
				case (ClassWars+1):
				{
					if (!CheckSet(client, arrLRS[ClassWars], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Class Warfare{tan} as their last request.", client);
					gamemode.iLRPresetType = ClassWars;
					arrLRS[ClassWars]++;
					return;
				}
				case (VSH+1):
				{
					if (!CheckSet(client, arrLRS[VSH], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to have a round of {default}Versus Saxton Hale{tan}.", client);
					gamemode.iLRPresetType = VSH;
					arrLRS[VSH]++;
					return;
				}
			}
		}
		case MenuAction_Cancel:delete menu;
	}
	//Call_OnLRPicked(menu, action, base, select);
}
/**
 *	Displays lr HUD text during the round, Format() the name accordingly
*/
public void ManageHUDText()
{
	char strHudName[128];
	switch (gamemode.iLRType)
	{
		//case FreedaySelf, FreedayOther:Format(strHudName, sizeof(strHudName), "");	// Should be blank
		case Custom:		strcopy(strHudName, sizeof(strHudName), strCustomLR);
		case FreedayAll:	Format(strHudName, sizeof(strHudName), "Freeday For All");
		case GuardMelee:	Format(strHudName, sizeof(strHudName), "Guards Melee Only");
		case HHHDay:		Format(strHudName, sizeof(strHudName), "Headless Horsemann Day");
		case TinyRound:		Format(strHudName, sizeof(strHudName), "Tiny Round");
		case HotPrisoner:	Format(strHudName, sizeof(strHudName), "Hot Prisoners");
		case Gravity:		Format(strHudName, sizeof(strHudName), "Low Gravity");
		case RandomKill:	Format(strHudName, sizeof(strHudName), "Sniper!");
		case Warday:		Format(strHudName, sizeof(strHudName), "Warday");
		case ClassWars:		Format(strHudName, sizeof(strHudName), "Class Warfare");
		case VSH:			Format(strHudName, sizeof(strHudName), "Versus Saxton Hale");
		default: {	}
	}
	if (strHudName[0] != '\0')
		SetTextNode(hTextNodes[1], strHudName, EnumTNPS[1][fCoord_X], EnumTNPS[1][fCoord_Y], EnumTNPS[1][fHoldTime], EnumTNPS[1][iRed], EnumTNPS[1][iGreen], EnumTNPS[1][iBlue], EnumTNPS[1][iAlpha], EnumTNPS[1][iEffect], EnumTNPS[1][fFXTime], EnumTNPS[1][fFadeIn], EnumTNPS[1][fFadeOut]);
	// Call_OnLRTextHud();
}
/**
 *	Calls on lr round start for each living player
*/
public void OnLRActivate(const JailFighter player)
{
	int client = player.index;
	switch (gamemode.iLRType)
	{
		case FreedaySelf, FreedayOther:
		{
			if (player.bIsQueuedFreeday)
				CPrintToChatAll("{tan}Freeday is now active for {default}%N{tan}.", client);
		}
		case GuardMelee:
		{
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
			{
				player.StripToMelee();
				if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 44 || GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 648)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					player.SpawnWeapon("tf_weapon_bat", 0, 1, 0, "");
					SetPawnTimer(ManageHealth, 0.2, client);	//SetEntProp(player.index, Prop_Data, "m_iHealth", (GetEntProp(player.index, Prop_Data, "m_iMaxHealth")));
				}
			}
		}
		case HHHDay:player.MakeHorsemann();	// Fuck server commands, hard coding feels more solid
		case TinyRound:SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.3);
		case HotPrisoner:
		{
			if (TF2_GetClientTeam(client) == TFTeam_Red)
			{
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 255, 75, 75, 255);
			}
		}
		case Warday, ClassWars:ResetPlayer(client);
		default: {	}
	}

	if (gamemode.bIsWarday)
	{
		if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589 && GetClientTeam(client) == BLU)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_wrench", 7, 1, 0, "");
		}

		int _4wep = GetPlayerWeaponSlot(client, 4);
		if (_4wep > MaxClients && IsValidEdict(_4wep) && GetEntProp(_4wep, Prop_Send, "m_iItemDefinitionIndex") == 60)
		{
			TF2_RemoveWeaponSlot(client, 4);
			player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "2 ; 1.0");
		}
	}
	Call_OnLRRoundActivate(player);
}
/**
 *	Calls without including players, so we don't fire the same thing for every player
*/
public void ManageRoundStart()
{
	switch (gamemode.iLRType)
	{
		case FreedayAll:
		{
			gamemode.bIsWardenLocked = true;
			CPrintToChatAll("{tan}Freeday is now active for {default}ALL players{tan}.");
		}
		case GuardMelee:EmitSoundToAll(GunSound);
		case HHHDay:
		{
			gamemode.bIsWardenLocked = true;
			gamemode.bIsWarday = true;
			CPrintToChatAll("{tan}BOO!");
			EmitSoundToAll(SPAWN);
			EmitSoundToAll(SPAWNRUMBLE);
		}
		case TinyRound:
		{
			EmitSoundToAll(TinySound);
			CPrintToChatAll("{red}[JailRedux]{tan} SuperSmall for everyone activated.");
			gamemode.bIsWardenLocked = true;
		}
		case Gravity:
		{
			CPrintToChatAll("{tan}Where did the gravity go?");
			EmitSoundToAll(GravSound);
			//ServerCommand("sm_cvar sv_gravity 100");
			FindConVar("sv_gravity").SetInt(100);
		}
		case HotPrisoner:
		{
			CPrintToChatAll("{tan}I'm too hot! Hot damn!");
			EmitSoundToAll(Engulf);
		}
		case RandomKill:
		{
			CPrintToChatAll("{tan}Look out! Sniper!");
			ForcePlayerSuicide( Client_GetRandom(CLIENTFILTER_ALIVE) );	// Lol rip, no fun for this guy
			EmitSoundToAll(SuicideSound);
			SetPawnTimer(RandSniper, GetRandomFloat(30.0, 60.0), gamemode.iRoundCount);
		}
		case Warday:
		{
			gamemode.bIsWarday = true;
			gamemode.bIsWardenLocked = true;
			// EmitSoundToAll(WardaySound);
		}
		case ClassWars:
		{
			int iClassRED = arrClass[GetRandomInt(0, 7)];
			int iClassBLU = arrClass[GetRandomInt(0, 7)];
			for (int i = MaxClients; i; --i)
			{
				if (!IsClientValid(i) || !IsPlayerAlive(i))
					continue;

				if (GetClientTeam(i) == RED)
					TF2_SetPlayerClass(i, view_as< TFClassType >(iClassRED));
				else TF2_SetPlayerClass(i, view_as< TFClassType >(iClassBLU));
			}
			// EmitSoundToAll(WardaySound);
			gamemode.bIsWarday = true;
			gamemode.bIsWardenLocked = true;
		}
		default: {	}
	}
	Call_OnManageRoundStart();
}
/** 
 *	Calls on round end obviously, resets should be put here as well 
*/
public void ManageRoundEnd(const JailFighter player)
{
	switch(gamemode.iLRType)
	{
		case HHHDay:
		{
			if (player.bIsHHH)
				SetPawnTimer(UnHorsemannify, 1.0, player);	//player.UnHorsemann();
		}
		case TinyRound:SetPawnTimer(ResetModelProps, 1.0, player.index);
		case HotPrisoner:
		{
			if (TF2_GetClientTeam(player.index) == TFTeam_Red)
				SetEntityRenderColor(player.index, 255, 255, 255, 255);
		}
		default: {	}
	}
	Call_OnLRRoundEnd(player);
}
/**
 *	Calls on round end without players so we don't fire again for every player
*/
public void ManageOnRoundEnd(Event event)
{
	switch (gamemode.iLRType)
	{
		case HHHDay:
		{
			EmitSoundToAll(DEATH);
			EmitSoundToAll(DEATHVO);
			EmitSoundToAll(DEATHVO2);
		}
		case Gravity:FindConVar("sv_gravity").SetInt(800);	//ServerCommand("sm_cvar sv_gravity 800");
		case HotPrisoner:EmitSoundToAll(Extinguish);
		case RandomKill:SetPawnTimer(EndRandSniper, GetRandomFloat(0.1, 0.3), gamemode.iRoundCount);
		default: {	}
	}
	Call_OnManageRoundEnd(event);
}
/**
 *	Is the round a freeday? Set the lr on the proper case
*/
public void IsFreedayLR()
{
	switch (gamemode.iLRType)
	{
		case FreedayAll:gamemode.bIsFreedayRound = true;
		default:gamemode.bIsFreedayRound = false;
	}
}
/** 
 *	Determines if criticals are enabled for blue team
*/
public void CriticalEnable()
{
	switch (gamemode.iLRType)
	{
		case HHHDay:gamemode.bDisableCriticals = true;
		default:gamemode.bDisableCriticals = false;
	}
}
/**
 *	Manage jail cell behavior on round start choose OPEN/CLOSE/LOCK/UNLOCK
*/
public void ManageCells()
{
	switch(gamemode.iLRType)
	{
		case FreedayAll, 
			TinyRound, 
			HHHDay, 
			Warday, 
			ClassWars
			:gamemode.DoorHandler(OPEN);
		default: {	}
		/*case example:gamemode.DoorHandler(OPEN or CLOSE or LOCK or UNLOCK);*/
	}
}
/**
 *	Kills weapons for team/player
*/
public void KillWeapons(const JailFighter player)
{	
	if (TF2_GetClientTeam(player.index) == TFTeam_Red)
		player.EmptyWeaponSlots();

	switch (gamemode.iLRType)
	{
		default: {	}
	}
	/** IF YOU NEED A MORE SPECIFIC WEAPON CONFIGURATION, IGNORE AND USE 'ManageWeaponStatus' INSTEAD **/
}
/**
 *	If you want something specific to happen to warden on get, stick it here
*/
public void ManageWarden(const JailFighter player)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnWardenGet(player);
}
/**
 *	Called on model collision between players, Red player in this case is the 'toucher'
*/
public void ManageRedTouchBlue(const JailFighter toucher, const JailFighter touchee)
{
	switch (gamemode.iLRType)
	{
		case HotPrisoner:
		{
			//TF2_AddCondition(touchee.index, TFCond_OnFire, 8.0);
			TF2_IgnitePlayer(touchee.index, toucher.index);
			SDKHooks_TakeDamage(touchee.index, 0, 0, 50.0, DMG_BURN, _, _, _);	
		}
		default: {	}
	}
	Call_OnClientTouch(toucher, touchee);
}
/**
 *	Set Friendly Fire timer on round start
*/
public void ManageFFTimer()
{
	switch (gamemode.iLRType)
	{
		case 
		HHHDay, 
		TinyRound
		:SetPawnTimer(EnableFFTimer, 10.0, gamemode.iRoundCount);
		default: {	}
	}
}
/**
 *	Weapon configuration, more specific than KillWeapons
*/
public void ManageWeaponStatus(const JailFighter player)
{
	int client = player.index;
	int _1wep = GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary);
	int _2wep = GetIndexOfWeaponSlot(client, TFWeaponSlot_Secondary);
	int _3wep = GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee);
	//int _4wep = GetIndexOfWeaponSlot(client, TFWeaponSlot_PDA);

	switch (_1wep)
	{
		case 220:
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
				player.SpawnWeapon("tf_weapon_scattergun", 13, 1, 0, "");
		}
	}
	switch (_2wep)
	{
		case 36, 767, 222, 1121:
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
				player.SpawnWeapon("tf_weapon_pistol", 23, 1, 0, "");
		}
		case 1179, 58, 1083:
		{
			if (TF2_GetClientTeam(client) == TFTeam_Red)
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		}
		case 1180:
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
				player.SpawnWeapon("tf_weapon_shotgun_pyro", 12, 1, 0, "");
		}
	}
	switch (_3wep)
	{
		case 225, 574:
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_knife", 4, 1, 0, "");
		}
	}
	
	/*if (TF2_GetClientTeam(client) == TFTeam_Red)
	{
		switch (_2wep)
		{
			case 1179:TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		}
	}*/

	TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item1);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item2);
}
/**
 *	Register what happens when a player receives a TFCond condition
*/
public void TF2_OnConditionAdded(int client, TFCond cond)
{	
	switch (cond)
	{
		case TFCond_Disguising, TFCond_Disguised:if (TF2_GetClientTeam(client) == TFTeam_Blue) TF2_RemoveCondition(client, cond);
	}
}
/**
 *	Vice versa as above
*/
public void TF2_OnConditionRemoved(int client, TFCond cond)
{
	switch (cond)
	{
		default: {	}
	}
}
/** 
 *	If lr requires the same think properties from both teams, set it under both team thinks
 *	Thinks will overlap if you use more than 1 Blue Team think
 *	Red Team think
*/
public void ManageRedThink(const JailFighter player)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnRedThink(player);
}
/**
 *	Manage complete Blue Team think 
*/
public void ManageAllBlueThink(const JailFighter player)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnAllBlueThink(player);
}
/**
 *	Blue Team think. Does NOT include warden
*/
public void ManageBlueNotWardenThink(const JailFighter player)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnBlueNotWardenThink(player);
}
/**
 *	Warden think only
*/
public void ManageWardenThink(const JailFighter player)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnWardenThink(player);
}
/**
 *	Sound hooking for certain scenarios
*/
public Action SoundHook(int clients[64], int & numClients, char sample[PLATFORM_MAX_PATH], int & entity, int & channel, float & volume, int & level, int & pitch, int & flags)
{
	if (!bEnabled.BoolValue  || !IsValidClient(entity))
		return Plugin_Continue;
		
	JailFighter player = JailFighter(entity);
	switch (gamemode.iLRType)
	{
		case HHHDay:
		{
			if (!strncmp(sample, "vo", 2, false) && player.bIsHHH)
				return Plugin_Handled;
			if (strncmp(sample, "player/footsteps/", 17, false) != -1 && player.bIsHHH)
			{
				if (StrContains(sample, "1.wav", false) != -1 || StrContains(sample, "3.wav", false) != -1) 
					sample = LEFTFOOT;
				else if (StrContains(sample, "2.wav", false) != -1 || StrContains(sample, "4.wav", false) != -1) 
					sample = RIGHTFOOT;
				EmitSoundToAll(sample, entity);
				return Plugin_Changed;
			}
		}
		default: {	}
	}
	return Plugin_Continue;
}
/**
 *	Calls when a a player is hurt without SDKHooks
*/
public void ManageHurtPlayer(const JailFighter attacker, const JailFighter victim, Event event)
{
	//int damage = event.GetInt("damageamount");
	//int custom = event.GetInt("custom");
	//int weapon = event.GetInt("weaponid");
	
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	//Call_OnHurtPlayer(attacker, victim, damage, custom, weapon, event);
}
/** 
 *	Calls when damage is taken/given during lr with SDKHooks
*/
public Action ManageOnTakeDamage(const JailFighter victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	JailFighter player = JailFighter(attacker);

	switch (gamemode.iLRType)
	{
		default:
		{
			if (player.bIsFreeday)
			{	// Registers with Razorbacks ^^
				player.RemoveFreeday();
				PrintCenterTextAll("%N has attacked a guard and lost their freeday!", attacker);
			}
		
			if (victim.bIsFreeday && !player.bIsWarden)
			{
				damage = 0.0;
				return Plugin_Changed;
			}
			if (!gamemode.bDisableCriticals)
			{
				if (TF2_GetClientTeam(attacker) == TFTeam_Blue)
				{
					damagetype = damagetype | DMG_CRIT;
					return Plugin_Changed;
				}
			}
			if (victim.bIsWarden)
				SetPawnTimer(DisableWarden, cvarTF2Jail[WardenTimer].FloatValue, gamemode.iRoundCount);
		}
	}
	return Plugin_Continue;
}
/** 
 *	Called when a player dies obviously
*/
public void ManagePlayerDeath(const JailFighter attacker, const JailFighter victim, Event event)
{
	FreeKillSystem(attacker);
	TF2Attrib_RemoveAll(victim.index);
	SetPawnTimer(CheckLivingPlayers, 0.2);

	switch (gamemode.iLRType)
	{
		case HHHDay:
		{
			if (victim.bIsHHH)
			{
				EmitSoundToAll(DEATHVO, victim.index);
				victim.UnHorsemann();
			}
		}
		case RandomKill:
		{
			if (!attacker)
			{
				EmitSoundToAll(SuicideSound);
				event.SetString("weapon", "sniperrifle");
			}
		}
		case VSH: {	}
		default:
		{
			if (victim.bIsWarden)
				PrintCenterTextAll("Warden has been killed!");
		}
	}
	Call_OnPlayerDied(attacker, victim, event);
}
/**
 *	Sticking this in Handler just in case someone wants to be incredibly specific with their lr 
*/
public void ManageEntityCreated(int ent, const char[] strClassName)
{
	if (StrContains(strClassName, "tf_ammo_pack", false) != -1)
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
		//CreateTimer(0.1, RemoveEnt, EntIndexToEntRef(ent));

	if (cvarTF2Jail[KillPointServerCommand].BoolValue && StrContains(strClassName, "point_servercommand", false) != -1)
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
		//CreateTimer(0.1, RemoveEnt, EntIndexToEntRef(ent));
	
	if (StrContains(strClassName, "rune")!= - 1)	// oWo what's this?
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
		//CreateTimer(0.1, RemoveEnt, EntIndexToEntRef(ent));
	
	if (cvarTF2Jail[DroppedWeapons].BoolValue && StrEqual(strClassName, "tf_dropped_weapon"))
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
	/*{
		AcceptEntityInput(entity, "kill");
		return;
	}*/
	/*if ( StrEqual(strClassName, "item_ammopack_full")
		|| StrEqual(strClassName, "item_ammopack_medium")
		|| StrEqual(strClassName, "item_ammopack_small")
		|| StrEqual(strClassName, "tf_ammo_pack") )
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerTouch, true);
	}
	if (StrEqual(strClassName, "func_breakable"))
	{
		if (IsValidEntity(ent))
			HookSingleEntityOutput(ent, "OnBreak", VentTouch, true);
	}*/
}
/**
 *	Called directly when a player spawns, be sure to note iRoundState(s) if being specific
*/
public void ManageSpawn(const JailFighter player, Event event)
{
	switch (TF2_GetClientTeam(player.index))
	{
		case TFTeam_Red:
		{
			switch (TF2_GetPlayerClass(player.index))
			{
				case TFClass_Scout:TF2Attrib_SetByDefIndex(player.index, 49, 1.0);
				case TFClass_Pyro:TF2Attrib_SetByDefIndex(player.index, 823, 1.0);
			}
	
			if (!player.bIsVIP && gamemode.iRoundState == StateRunning)
				player.MutePlayer();
			else player.UnmutePlayer();
					
			if (player.bIsQueuedFreeday)
			{
				player.GiveFreeday();
				player.TeleportToPosition(FREEDAY);
			}

			if (gamemode.bIsWarday)
				player.TeleportToPosition(WRED);

			player.RedEquip();
		}
		case TFTeam_Blue:
		{
			player.UnmutePlayer();
			switch (TF2_GetPlayerClass(player.index))
			{
				case TFClass_Scout:TF2Attrib_SetByDefIndex(player.index, 49, 1.0);
				case TFClass_Pyro:TF2Attrib_SetByDefIndex(player.index, 823, 1.0);
			}
			if (gamemode.bIsWarday)
				player.TeleportToPosition(WBLU);
			player.BlueEquip();
			player.bIsQueuedFreeday = false;

			if (cvarTF2Jail[CritFallOff].BoolValue)
				TF2Attrib_SetByDefIndex(player.index, 868, 1.0);
		}
	}

	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnPlayerSpawned(player, event);
}
/** 
 *	Determines if player attack is to be critical
*/
/*public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool & result)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	switch (gamemode.iLRType)
	{
		default:
		{
			for (int i = MaxClients; i; --i)
			{	// Crits shouldn't exist for Red Team, in my opinion at least
				if (TF2_IsPlayerCritBuffed(i) && TF2_GetClientTeam(i) == TFTeam_Red)
					return Plugin_Continue;
				result = false;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}*/
/**
 *	Unique to the player Custom lr, formats the public char sCustomLR
*/
public void OnClientSayCommand_Post(int client, const char[] sCommand, const char[] cArgs)
{
	JailFighter player = JailFighter(client);
	if (player.iCustom > 0)
	{
		strcopy(strCustomLR, sizeof(strCustomLR), cArgs);
		CPrintToChat(client, "{red}[JailRedux]{tan} Your custom last request is {green}%s", strCustomLR);
		player.iCustom = 0;
	}
}
/** 
 *	This is all VSH stuff. Doing this to make more of a grasp with forwards
 *
 *	Since when can people build buildings? Oh wait map buildings
*/
public void ManageBuildingDestroyed(const JailFighter base, const int building, const int objecttype, Event event)
{
	switch (gamemode.iLRType) 
	{
		default: {	}
	}
	Call_OnBuildingDestroyed(base, building, event);
}
/**
 *	If airblast is disabled then leave this alone obviously
*/
public void ManageOnAirblast(const JailFighter airblaster, const JailFighter airblasted, Event event)
{
	switch (gamemode.iLRType) 
	{
		default: {  }
	}
	Call_OnObjectDeflected(airblaster, airblasted, event);
}
/**
 *	Calls when a player is wetted, kinky. Memes aside remember that this also called with Mad Milk and Sydney Sleeper headshots/charged shots
*/
public void ManageOnPlayerJarated(const JailFighter jarateer, const JailFighter jarateed, Event event)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnPlayerJarated(jarateer, jarateed, event);
}
/**
 *	In my opinion mediguns shouldn't exist in JB, but hey do whatcha want
*/
public void ManageUberDeployed(const JailFighter patient, const JailFighter medic, Event event)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnUberDeployed(patient, medic, event);
}
/**
 *	Self explanatory, set the gamemode.iTimeLeft to whatever time (in seconds) you desire
*/
public void ManageTimeLeft()
{
	switch (gamemode.iLRType)
	{
		default:gamemode.iTimeLeft = cvarTF2Jail[RoundTime].IntValue;
	}
	Call_OnManageTimeLeft();
}
/**
 *	Music that can play during your LR, use the commented example as reference. Don't forget that "time" is in seconds
*/
public void ManageMusic(char song[PLATFORM_MAX_PATH], float & time)
{
	switch (gamemode.iLRType)
	{
		default: { song = ""; time = -1.0; }
		/* case example:
		{
			song = "SomeBadassSong.mp3";
			time = 9001.0;
		}*/
	}
	Call_OnMusicPlay(song, time);
}
/**
 *	Whenever a player dies, this is called
*/
public void CheckLivingPlayers()
{
	if (gamemode.iRoundState < StateRunning)
		return;

	switch (gamemode.iLRType)
	{
		case VSH: {	}	// 'One guard left' is pointless during this round along with freedays
		default:
		{
			if (GetLivingPlayers(BLU) == 1)
			{
				if (cvarTF2Jail[RemoveFreedayOnLastGuard].BoolValue)
				{
					for (int i = MaxClients; i; --i)
					{
						JailFighter player = JailFighter(i);
						if (IsClientValid(player.index) && player.bIsFreeday)
							player.RemoveFreeday();
					}
				}
				
				if (!gamemode.bOneGuardLeft)
				{
					gamemode.bOneGuardLeft = true;
					PrintCenterTextAll("One guard left...");
				}
			}
		}
	}
}
