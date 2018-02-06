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
	Custom = 1,		// These 2 shouldn't register with gameplay orientation and are kept out of randlr
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
	// VSH = 13			// DO NOT SET ANY NEW LRS UNDER THESE NUMBERS UNLESS YOU DISABLE OR ADJUST THE SUB PLUGIN!
	// PH = 14,			// THEY WILL OVERLAP!
};
/** 
 *	When adding a new lr, increase the LRMAX to the proper/latest enum value
 *	Reminder that random lr grabs a random int from 2 to LRMAX
 *	Having breaks or skips within the enum will result in nothing happening the following round if that number is selected
*/
#define LRMAX		ClassWars+ (g_hPluginsRegistered.Length)

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
 *	Add your LR name to the array, referred back to in AddLRToMenu()
*/
char strLRNames[LRMAX][] = {
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

	Call_OnDownloads();
}
/**
 *	Called on map start again but this time for the starting lr count
*/
public void LRMapStartVariables()
{
	for (int i = 0; i <= LRMAX; i++)
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

	menu.AddItem("-1", "Random LR");
	for (int i = 0; i < sizeof(strLRNames); i++)	// If we do '<= LRMAX' and you have a sub-plugin, array indexes will be out of bounds
	{												// So don't add sub-plugin LR names to this plugin, simply do it within your own
		iMax = LR_DEFAULT;	// 5
		// if (i == 2)	// If you want a certain last request to have a different max, do something like this
			// iMax = 3;
		Format(strName, sizeof(strName), "%s (%i/%i)", strLRNames[i][0], arrLRS[i], iMax);
		IntToString(i, strID, sizeof(strID));
		menu.AddItem(strID, strName, arrLRS[i] >= iMax ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT); // Disables the LR selection if the max is too high
	}
	Call_OnMenuAdd(menu);	
/**
 *	According to this, you have to have your sub-plugin LR as the last in the enum, always
 *	Secondly, you have to format strLRNames yourself on the menu item 
 *	arrLRs[] handles the picks in this plugin, but you have to handle the increase on pick (consult the CheckSet() function and use it in your sub-plugin)
*/
}
/**
 *	Add a 'short' description to your last request for the !listlrs command
*/
public void AddLRToPanel(Panel & panel)
{
	panel.DrawItem("Suicide- Kill yourself on the spot");
	panel.DrawItem("Custom- Type your own last request");
	panel.DrawItem("Freeday for Yourself- Give yourself a freeday");
	panel.DrawItem("Freeday for Others- Give up to %i freedays to others", cvarTF2Jail[FreedayLimit].IntValue);
	panel.DrawItem("Freeday for All- Give everybody a freeday");
	panel.DrawItem("Guards Melee Only- Those guns are for babies!");
	panel.DrawItem("Headless Horsemann Day- Turns all players into the HHH");
	panel.DrawItem("Tiny Round- Honey I shrunk the players");
	panel.DrawItem("Hot Prisoner- Prisoners are too hot to touch");
	panel.DrawItem("Low Gravity- Where did the gravity go");
	panel.DrawItem("Sniper- A hired gun to take out some folks");
	panel.DrawItem("Warday- Team Deathmatch");
	panel.DrawItem("Class Wars- Warday but it's class versus class");

	Call_OnPanelAdd(panel);
}
/** 
 *	Called when player is given lr and is selecting. Place your lr under the MenuAction_Select case
 *	Use the already given lr's as a guide if you need help
*/
public int ListLRsMenu(Menu menu, MenuAction action, int client, int select)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return;
		
	switch (action)
	{
		case MenuAction_Select:
		{
			JailFighter base = JailFighter(client);
			char strIndex[4]; menu.GetItem(select, strIndex, sizeof(strIndex));
			if (cvarTF2Jail[RemoveFreedayOnLR].BoolValue)
			{
				JailFighter player;
				for (int i = MaxClients; i; --i)
				{
					if (!IsClientInGame(i))
						continue;
					player = JailFighter(i);
					if (!player.bIsFreeday)
						continue;
						
					player.RemoveFreeday();
				}
				CPrintToChatAll("{red}[JailRedux]{tan} Last request has been chosen. Freedays have been stripped.");
			}
			gamemode.bIsLRInUse = true;
			int request = StringToInt(strIndex);
			
			switch (request)
			{
				case -1:	// Random
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
							JailFighter( GetRandomPlayer(RED) ).bIsQueuedFreeday = true;
					}
					return;
				}
				case Suicide:
				{
					if (!CheckSet(client, arrLRS[Suicide], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to kill themselves. What a shame...", client);
					SetPawnTimer(KillThatBitch, (GetRandomFloat(0.5, 7.0)), client);	// Meme lol
					arrLRS[Suicide]++;
					return;
				}
				case Custom:
				{
					if (!CheckSet(client, arrLRS[Custom], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to type out their LR in chat.", client);
					gamemode.iLRPresetType = Custom;
					arrLRS[Custom]++;
					base.iCustom = base.userid;
					return;
				}
				case FreedaySelf:
				{
					if (!CheckSet(client, arrLRS[FreedaySelf], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Freeday for Themselves{tan} next round.", client);
					gamemode.iLRPresetType = FreedaySelf;
					base.bIsQueuedFreeday = true;
					arrLRS[FreedaySelf]++;
					return;
				}
				case FreedayOther:
				{
					if (!CheckSet(client, arrLRS[FreedayOther], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N is picking Freedays for next round...", client);
					GiveFreedaysMenu(client);
					gamemode.iLRPresetType = FreedayOther;
					arrLRS[FreedayOther]++;
					return;
				}
				case FreedayAll:
				{
					if (!CheckSet(client, arrLRS[FreedayAll], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to grant {default}Freeday for All{tan} next round.", client);
					gamemode.iLRPresetType = FreedayAll;
					arrLRS[FreedayAll]++;
					return;
				}
				case GuardMelee:
				{
					if (!CheckSet(client, arrLRS[GuardMelee], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to strip the guards of their weapons.", client);
					gamemode.iLRPresetType = GuardMelee;
					arrLRS[GuardMelee]++;
					return;
				}
				case HHHDay:
				{
					if (!CheckSet(client, arrLRS[HHHDay], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Horseless Headless Horsemann Kill Round{tan} next round.", client);
					gamemode.iLRPresetType = HHHDay;
					arrLRS[HHHDay]++;
					return;
				}
				case TinyRound:
				{
					if (!CheckSet(client, arrLRS[TinyRound], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Super Small{tan} for everyone.", client);
					gamemode.iLRPresetType = TinyRound;
					arrLRS[TinyRound]++;
					return;
				}
				case HotPrisoner:
				{
					if (!CheckSet(client, arrLRS[HotPrisoner], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to ignite all of the prisoners next round!", client);
					gamemode.iLRPresetType = HotPrisoner;
					arrLRS[HotPrisoner]++;
					return;
				}
				case Gravity:
				{
					if (!CheckSet(client, arrLRS[Gravity], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Low Gravity{tan} as their last request.", client);
					gamemode.iLRPresetType = Gravity;
					arrLRS[Gravity]++;
					return;
				}
				case RandomKill:
				{
					if (!CheckSet(client, arrLRS[RandomKill], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to hire a Sniper for next round!", client);
					gamemode.iLRPresetType = RandomKill;
					arrLRS[RandomKill]++;
					return;
				}
				case Warday:
				{
					if (!CheckSet(client, arrLRS[Warday], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen to do a {default}Warday{tan}.", client);
					gamemode.iLRPresetType = Warday;
					arrLRS[Warday]++;
					return;
				}
				case ClassWars:
				{
					if (!CheckSet(client, arrLRS[ClassWars], LR_DEFAULT))
						return;
					CPrintToChatAll("{red}[JailRedux]{tan} %N has chosen {default}Class Warfare{tan} as their last request.", client);
					gamemode.iLRPresetType = ClassWars;
					arrLRS[ClassWars]++;
					return;
				}
				default:Call_OnLRPicked(base, request);	// Menu functions aren't needed
			}
		}
		case MenuAction_End:delete menu;
	}
}
/**
 *	Displays lr HUD text during the round, Format() the name accordingly
*/
public void ManageHUDText()
{
	char strHudName[128];
	switch (gamemode.iLRType)
	{
		case -1: {	}
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
		default: 			Call_OnLRTextHud(strHudName);
	}

	if (strHudName[0] != '\0')
		SetTextNode(hTextNodes[1], strHudName, EnumTNPS[1][fCoord_X], EnumTNPS[1][fCoord_Y], EnumTNPS[1][fHoldTime], EnumTNPS[1][iRed], EnumTNPS[1][iGreen], EnumTNPS[1][iBlue], EnumTNPS[1][iAlpha], EnumTNPS[1][iEffect], EnumTNPS[1][fFXTime], EnumTNPS[1][fFadeIn], EnumTNPS[1][fFadeOut]);
}
/**
 *	Called directly when a player spawns, be sure to note iRoundState(s) if being specific
*/
public void ManageSpawn(const JailFighter base, Event event)
{
	int client = base.index;
	switch (TF2_GetClientTeam(client))
	{
		case TFTeam_Red:
		{
			switch (TF2_GetPlayerClass(client))
			{
				case TFClass_Scout:TF2Attrib_SetByDefIndex(client, 49, 1.0);
				case TFClass_Pyro:TF2Attrib_SetByDefIndex(client, 823, 1.0);
			}
	
			if (!base.bIsVIP && gamemode.iRoundState == StateRunning)
				base.MutePlayer();
			else base.UnmutePlayer();
					
			if (base.bIsQueuedFreeday)
			{
				base.GiveFreeday();
				base.TeleportToPosition(FREEDAY);
			}
		}
		case TFTeam_Blue:
		{
			base.UnmutePlayer();
			switch (TF2_GetPlayerClass(client))
			{
				case TFClass_Scout:TF2Attrib_SetByDefIndex(client, 49, 1.0);
				case TFClass_Pyro:TF2Attrib_SetByDefIndex(client, 823, 1.0);
			}
			base.bIsQueuedFreeday = false;

			if (cvarTF2Jail[CritFallOff].BoolValue)	// Does this even work lmao
				TF2Attrib_SetByDefIndex(client, 868, 1.0);
		}
	}
	if (gamemode.bIsWarday)
		base.TeleportToPosition(GetClientTeam(client));	// Enum value is the same as team value, so we can cheat it

	Call_OnPlayerSpawned(base, event);
}
/**
 *	Manage each player just after spawn
 *	gamemode.iLRType is initialized beforehand, so we can switch it if needed
*/
public void PrepPlayer(const int userid)
{
	JailFighter base = JailFighter(userid, true);
	int client = base.index;
	if (!IsPlayerAlive(client))
		return;

	int len = hWeaponList.Length, i, index, wep;
	TFClassType class = TF2_GetPlayerClass(client);
	char strClassName[64];
	if (len)
	{
		int u;
		bool active;
		for (i = 0; i < 3; i++)	// Prepare for wicked laziness and hacky coding
		{
			wep = GetIndexOfWeaponSlot(client, i);
			for (u = 0; u < len; u++)
			{
				if (wep != hWeaponList.Get(u))
					continue;
				active = true;
			}

			if (!active)
				continue;

			switch (class)
			{
				case TFClass_Scout:
				{
					strClassName = (!i ? "tf_weapon_scattergun" : (i == 1 ? "tf_weapon_pistol" : "tf_weapon_bat"));
					index = (!i ? 13 : (i == 1 ? 23 : 0));
				}
				case TFClass_Soldier:
				{
					strClassName = (!i ? "tf_weapon_rocketlauncher" : (i == 1 ? "tf_weapon_shotgun" : "tf_weapon_shovel"));
					index = (!i ? 18 : (i == 1 ? 10 : 6));
				}
				case TFClass_Pyro:
				{
					strClassName = (!i ? "tf_weapon_flamethrower" : (i == 1 ? "tf_weapon_shotgun" : "tf_weapon_fireaxe"));
					index = (!i ? 21 : (i == 1 ? 12 : 2));
				}
				case TFClass_DemoMan:
				{
					strClassName = (!i ? "tf_weapon_grenadelauncher" : (i == 1 ? "tf_weapon_pipebomblauncher" : "tf_weapon_bottle"));
					index = (!i ? 19 : (i == 1 ? 20 : 1));
				}
				case TFClass_Heavy:
				{
					strClassName = (!i ? "tf_weapon_minigun" : (i == 1 ? "tf_weapon_shotgun" : "tf_weapon_fists"));
					index = (!i ? 15 : (i == 1 ? 11 : 5));
				}
				case TFClass_Engineer:
				{
					strClassName = (!i ? "tf_weapon_shotgun" : (i == 1 ? "tf_weapon_shotgun" : "tf_weapon_wrench"));
					index = (!i ? 9 : (i == 1 ? 22 : 7));
				}
				case TFClass_Medic:
				{
					strClassName = (!i ? "tf_weapon_syringegun_medic" : (i == 1 ? "tf_weapon_medigun" : "tf_weapon_bonesaw"));
					index = (!i ? 17 : (i == 1 ? 29 : 8));
				}
				case TFClass_Sniper:
				{
					strClassName = (!i ? "tf_weapon_sniperrifle" : (i == 1 ? "tf_weapon_smg" : "tf_weapon_club"));
					index = (!i ? 14 : (i == 1 ? 16 : 3));
				}
				case TFClass_Spy:
				{
					strClassName = (!i ? "tf_weapon_revolver" : (i == 1 ? "tf_weapon_builder" : "tf_weapon_knife"));
					index = (!i ? 24 : (i == 1 ? 735 : 4));
				}
			}

			TF2_RemoveWeaponSlot(client, i);
			base.SpawnWeapon(strClassName, index, 1, 0, "");	// That was fun, let's do it again but with wearables
		}
	}

	len = hWearableList.Length;
	if (len)
	{	// FORTUNATELY, there are only a few wearables per class so we can do a cleaner? switch statement
		int[] prepwep = new int[1];
		for (i = 0; i < len; i++)
		{
			prepwep[0] = hWearableList.Get(i);
			switch (prepwep[0])
			{
				case 133, 444:
				{
					wep = 10;
					strClassName = "tf_weapon_shotgun";
				}
				case 405, 608:
				{
					wep = 19;
					strClassName = "tf_weapon_grenadelauncher";
				}
				case 131, 406:
				{
					wep = 20;
					strClassName = "tf_weapon_pipebomblauncher";
				}
				case 203, 231, 642:
				{
					wep = 16;
					strClassName = "tf_weapon_smg";
				}
				default:wep = 0;	// "False" because then they aren't a weapon(slot)
			}
			if ( IsValidEntity(FindPlayerBack(client, prepwep, 1)) )
				RemovePlayerBack(client, prepwep, 1);
			if (wep)
				base.SpawnWeapon(strClassName, wep, 1, 0, "");
		}
	}

	TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item1);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item2);

	if (GetClientTeam(client) == BLU)
	{
		if (AlreadyMuted(client) && gamemode.iLRType != VSH && cvarTF2Jail[DisableBlueMute].BoolValue)
		{
			base.ForceTeamChange(RED);
			EmitSoundToClient(client, NO);
			CPrintToChat(client, "{red}[JailRedux]{tan} You are muted, therefore you cannot join Blue team.");
		}
	}
	base.EmptyWeaponSlots();	// We call this last so the spawned weapons are registered with the function

	Call_OnPlayerPrepped(base);
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
			player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "");
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
			ForcePlayerSuicide( GetRandomClient() );	// Lol rip, no fun for this guy
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
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
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
		case Gravity:FindConVar("sv_gravity").SetInt(800);
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
	switch (gamemode.iLRType)
	{
		case FreedayAll, 
			TinyRound, 
			HHHDay, 
			Warday, 
			ClassWars
			:gamemode.DoorHandler(OPEN);
		/*case example:gamemode.DoorHandler(OPEN or CLOSE or LOCK or UNLOCK);*/
		default: {	}
	}
}
/**
 *	If you want something specific to happen to warden on get, stick it here
*/
public void ManageWarden(const JailFighter base)
{
	switch (gamemode.iLRType)
	{
		default: {	}
	}
	Call_OnWardenGet(base);
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
		
	JailFighter base = JailFighter(entity);
	switch (gamemode.iLRType)
	{
		case HHHDay:
		{
			if (!strncmp(sample, "vo", 2, false) && base.bIsHHH)
				return Plugin_Handled;
			if (strncmp(sample, "player/footsteps/", 17, false) != -1 && base.bIsHHH)
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

	switch (gamemode.iLRType)
	{
		default:
		{
			JailFighter base = JailFighter(attacker);
			if (base.bIsFreeday)
			{	// Registers with Razorbacks ^^
				base.RemoveFreeday();
				PrintCenterTextAll("%N has attacked a guard and lost their freeday!", attacker);
			}
		
			if (victim.bIsFreeday && !base.bIsWarden)
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
	if (gamemode.iLRType != VSH)
		FreeKillSystem(attacker);

	TF2Attrib_RemoveAll(victim.index);
	SetPawnTimer(CheckLivingPlayers, 0.2);

	if (victim.bIsFreeday)
		victim.RemoveFreeday();

	victim.MutePlayer();

	if (victim.iCustom > 0)
		victim.iCustom = 0;
		
	if (victim.bIsWarden)
	{
		victim.WardenUnset();
		gamemode.bWardenExists = false;
		if (gamemode.iRoundState == StateRunning)
		{
			if (cvarTF2Jail[WardenTimer].IntValue != 0)
			{
				int iTimer = gamemode.iRoundCount;
				SetPawnTimer(DisableWarden, cvarTF2Jail[WardenTimer].FloatValue, iTimer);
			}
		}
	}

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
				EmitSoundToAll(SuicideSound);
		}
		default:
		{
			if (victim.bIsWarden)
				PrintCenterTextAll("Warden has been killed!");
		}
	}
	Call_OnPlayerDied(attacker, victim, event);
}
/**
 *	Whenever a player dies POST, this is called
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
					JailFighter base;
					for (int i = MaxClients; i; --i)
					{
						if (!IsClientInGame(i))
							continue;

						base = JailFighter(i);
						if (base.bIsFreeday)
							base.RemoveFreeday();
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
	
	if (StrContains(strClassName, "rune") != - 1)	// oWo what's this?
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
		//CreateTimer(0.1, RemoveEnt, EntIndexToEntRef(ent));
	
	if (cvarTF2Jail[DroppedWeapons].BoolValue && StrEqual(strClassName, "tf_dropped_weapon"))
		RequestFrame(RemoveEnt, EntIndexToEntRef(ent));
	/*{
		AcceptEntityInput(entity, "kill");
		return;
	}*/
	if ( StrEqual(strClassName, "item_ammopack_full")
		|| StrEqual(strClassName, "item_ammopack_medium")
		|| StrEqual(strClassName, "item_ammopack_small")
		|| StrEqual(strClassName, "tf_ammo_pack")
		&& cvarTF2Jail[RebelAmmo].BoolValue)
	{
		if (IsValidEntity(ent))
			RequestFrame(HookAmmo, EntIndexToEntRef(ent));
	}
	if (StrEqual(strClassName, "func_breakable") && cvarTF2Jail[VentHit].BoolValue)
	{
		if (IsValidEntity(ent))
			RequestFrame(HookVent, EntIndexToEntRef(ent));
	}
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
 *	Unique to the player Custom lr, formats the public char sCustomLR
*/
public void OnClientSayCommand_Post(int client, const char[] sCommand, const char[] cArgs)
{
	JailFighter base = JailFighter(client);
	if (base.iCustom > 0)
	{
		strcopy(strCustomLR, sizeof(strCustomLR), cArgs);
		CPrintToChat(client, "{red}[JailRedux]{tan} Your custom last request is {green}%s", strCustomLR);
		base.iCustom = 0;
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
 *	Music that can play during your LR, use the commented example as reference. Don't forget that "time" is in seconds
*/
public void ManageMusic(char song[PLATFORM_MAX_PATH], float & time)
{
	switch (gamemode.iLRType)
	{
		/* case example:
		{
			song = "SomeBadassSong.mp3";
			time = 9001.0;
		}*/
		default: { song = ""; time = -1.0; }
	}
	Call_OnMusicPlay(song, time);
}