#if defined _tf2jr_hook_included
	#endinput
#endif
#define _tf2jr_hook_included

#include <tf2jailredux/player>

enum LastRequest{}

/**
 *	@section Forward Hook types
*/

enum	// Hook Types
{
	OnDownloads = 0,			// After OnMapStart
	OnRoundStart,				// When the round activates, players can move
	OnRoundStartPlayer,			// When the round activates, per player
	OnRoundEnd,					// When the round ends
	OnRoundEndPlayer,			// When the round ends, per player
	OnPreThink,					// After SDKHook_PreThink
	OnRedThink,					// Think, for red team
	OnBlueThink,				// Think, for blue team
	OnFreedayGiven,				// When a player is given a freeday
	OnFreedayRemoved,			// When a player's freeday is removed
	OnWardenGet,				// Right before a player receives warden status
	OnWardenThink,				// Think, for the warden
	OnWardenKilled,				// When the warden is killed
	OnPlayerTouch,				// When 2 players touch (SDKHook_Touch)
	OnPlayerSpawned,			// After a player spawns
	OnPlayerDied,				// When a player dies
	OnPlayerPrepped,			// Right before a player is about to have their weapons managed
	OnPlayerPreppedPost,		// After a player's weapons have been managed
	OnLastGuard,				// When there is only 1 guard remaining
	OnLastPrisoner,				// When there is only 1 prisoner remaining
	OnCheckLivingPlayers,		// After a player dies, or right after the round starts
	OnTakeDamage,				// SDKHook_OnTakeDamage
	OnBuildingDestroyed,		// When a building is destroyed
	OnPlayerHurt,				// A player_hurt event
	OnObjectDeflected,			// When a player is airblasted
	OnPlayerJarated,			// When a player is jarated
	OnUberDeployed,				// When a player deploys an ubercharge
	OnClientInduction,			// After a players internal StringMap is created (OnClientPutInServer)
	OnVariableReset,			// When the round resets, for every player
	OnTimeLeft,					// When the round time is about to be set
	OnMenuAdd,					// When an LR is added to the menu
	OnShowHud,					// When the LR hud is about to be shown
	OnLRPicked,					// When an LR is picked from the menu
	OnLRGiven,					// When a player receives the LR menu
	OnWMenuAdd,					// To add to the warden menu (It's easier to simply use hWardenMenu in gamemode.inc)
	OnWMenuSelect,				// When the warden selects an item in the warden menu
	OnTimeEnd,					// When the round time expires
	OnFFTimer,					// When the Friendly-Fire timer is about to be set
	OnDoorsOpen,				// Right before the cell doors open
	OnDoorsClose,				// Right before the cell doors close
	OnDoorsLock,				// Right before the cell doors lock
	OnDoorsUnlock,				// Right before the cell doors unlock
	OnSoundHook,				// When a player is the entity in an AddNormalSoundHook() callback
	OnEntCreated,				// OnEntityCreated, before TF2JR can do anything with it
	OnCalcAttack,				// TF2_CalcIsAttackCritical
	OnRebelGiven,				// When a player receives rebel status
	OnRebelRemoved,				// When a player's rebel status is removed
	OnWardenRemoved,			// When a player loses warden status
	OnShouldAutobalance,		// Right before players are about to be autobalanced by the plugin
	OnShouldAutobalancePlayer,	// Right before a player is autobalanced by the plugin
	OnSetWardenLock,			// When the warden lock status is about to be set
	OnPlayMusic,				// When background music is about to be played
	OnLRDenied,					// When the next LR is denied
	OnLRActivate,				// When an LR activates
	OnLRActivatePlayer,			// When an LR activates, per player
	OnRoundReset, 				// teamplay_round_start, same as OnVariableReset but excludes players
	OnCellsManaged, 			// After the cells have been worked on either by Warden or by plugin
	OnWardenGetPost, 			// After a player has been initialized as Warden
	OnRebelGivenPost, 			// After a player has been marked as a Rebel
	OnLRPickedPost, 			// After a player selects an LR from the LR menu, after all properties are set
	OnWMenuSelectPost,			// After the warden selects an item in the warden menu and executes the command
	OnCellsFullyOpened,			// When the cell doors finish their opening action
	OnCellsFullyClosed,			// When the cell doors finish their closing action
	OnMarkedFreekiller,			// Right before a player is marked as a freekiller
	OnMarkedFreekillerPost, 	// After a player is marked as a freekiller
	OnFreekillerStatusRemoved, 	// When a freekiller's freekiller status is removed

	JBFWD_LENGTH
};

/**
 *	@endsection
*/

/**
 *	Each callback function has a counterpart to it's LR hook
 *	Globally hooking a function (with JB_Hook) will be the first callback signature (the one without LastRequest as a param)
 *	LR hooked functions (LastRequest.AddHook) correspond the the second callback signature and will only fire if that LR is/was involved or is active
*/

/**
 *	@section Hook typeset
*/

/* SDKHook-Style Forwards */
typeset JBHookCB
{
	/**	Thinks
	 *	OnRedThink
	 *	OnBlueThink
	 *	OnWardenThink
	 *	OnPreThink
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/**	Weapon management
	 *	OnPlayerPrepped			>> Return > Plugin_Continue to deny weapon management
	*/
	function Action (const JBPlayer player);
	function Action (LastRequest lr, const JBPlayer player);

	/** After weapon management
	 *	OnPlayerPreppedPost
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** Variable/property management
	 *	OnClientInduction
	 *	OnVariableReset			>> Every LR that is hooked will fire its function
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** When a role is given to a player
	 *	OnWardenGet				>> Return > Plugin_Continue to prevent player from becoming Warden
	 *	OnRebelGiven			>> Return > Plugin_Continue to prevent player from becoming a Rebel
	 *	OnMarkedFreekiller		>> Return > Plugin_Continue to prevent player from becoming a Freekiller
	*/
	function Action (const JBPlayer player);
	function Action (LastRequest lr, const JBPlayer player);

	/** When a role is given to a player, post
	 *	OnWardenGetPost
	 *	OnRebelGivenPost
	 *	OnFreedayGiven
	 *	OnMarkedFreekillerPost
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** When a role is removed from a player
	 *	OnWardenRemoved
	 *	OnRebelRemoved
	 *	OnFreedayRemoved
	 *	OnFreekillerStatusRemoved
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** Touch
	 *	OnPlayerTouch
	*/
	function void (const JBPlayer player, const JBPlayer other);
	function void (LastRequest lr, const JBPlayer player, const JBPlayer other);

	/**	player_spawn
	 *	OnPlayerSpawned
	*/
	function void (const JBPlayer player, Event event);
	function void (LastRequest lr, const JBPlayer player, Event event);

	/** Attack events
	 *	OnPlayerHurt
	 *	OnPlayerDied
	*/
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);
	function void (LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event);

	/** TakeDamage hook
	 * 	OnTakeDamage
	*/
	function Action (const JBPlayer victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	function Action (LastRequest lr, const JBPlayer victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	/**	Warden killed
	 *	OnWardenKilled			>> Return > Continue to stop "Warden has been killed" message
	*/
	function Action (const JBPlayer warden, const JBPlayer attacker, Event event);
	function Action (LastRequest lr, const JBPlayer warden, const JBPlayer attacker, Event event);

	/** Jarate attack
	 *	OnPlayerJarated
	*/
	function void (const JBPlayer jarateer, const JBPlayer jarateed);
	function void (LastRequest lr, const JBPlayer jarateer, const JBPlayer jarateed);

	/** Uber deployment
	 *	OnUberDeployed
	*/
	function void (const JBPlayer medic, const JBPlayer patient);
	function void (LastRequest lr, const JBPlayer medic, const JBPlayer patient);

	/** When a player is airblasted
	 *	OnPlayerAirblasted
	*/
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);
	function void (LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event);

	/** Building destruction
	 *	OnBuildingDestroyed
	*/
	function void (const JBPlayer attacker, const int building, Event event);
	function void (LastRequest lr, const JBPlayer attacker, const int building, Event event);

	/** Round reset
	 *	OnRoundReset			>> Every LR that is hooked will fire its function
	*/
	function void ();
	function void (LastRequest lr);

	/** Round start
	 *	OnRoundStart
	*/
	function void ();
	function void (LastRequest lr);

	/** Round start, per player
	 *	OnRoundStartPlayer
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** Round end
	 *	OnRoundEnd
	*/
	function void (Event event);
	function void (LastRequest lr, Event event);

	/** Round end, per player
	 *	OnRoundEndPlayer
	*/
	function void (const JBPlayer player, Event event);
	function void (LastRequest lr, const JBPlayer player, Event event);

	/** LR denial
	 *	OnLRDenied				>> Both LastRequest.AddHook and JB_Hook have the same callback signature
	*/
	function void (LastRequest lr);

	/** LR activation
	 *	OnLRActivate			>> Both LastRequest.AddHook and JB_Hook have the same callback signature
	*/
	function void (LastRequest lr);

	/** LR activation, per player
	 *	OnLRActivatePlayer		>> Both LastRequest.AddHook and JB_Hook have the same callback signature
	*/
	function void (LastRequest lr, const JBPlayer player);

	/** Player receives the LR menu
	 *	OnLRGiven
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/** Player picks from the LR menu
	 *	OnLRPicked				>> Both LastRequest.AddHook and JB_Hook have the same callback signature
	 *							   Return > Plugin_Continue to prevent this LR from becoming the iPresetType and have it's count increment
	*/
	function Action (LastRequest lr, const JBPlayer player);

	/** Downloads
	 *	OnDownloads
	*/
	function void ();
	function void (LastRequest lr);

	/** Living player checks
	 *	OnCheckLivingPlayers
	*/
	function void ();
	function void (LastRequest lr);

	/** Last guard/prisoner
	 *	OnLastGuard				>> Return Handled to stop "One Guard Left" message. Return Stop to not fire OnCheckLivingPlayers
	 *	OnLastPrisoner			>> Return Stop to not fire OnCheckLivingPlayers
	*/
	function Action ();
	function Action (LastRequest lr);

	/** Cell door management
	 *	OnDoorsOpen				>> Return > Continue to prevent cell opening
	 *	OnDoorsClose			>> Return > Continue to prevent cell closing
	 *	OnDoorsLock				>> Return > Continue to prevent cell locking
	 *	OnDoorsUnlock			>> Return > Continue to prevent cell unlocking
	*/
	function Action ();
	function Action (LastRequest lr);

	/** Cell door management, post
	 *	OnCellsManaged
	*/
	function void (eDoorsMode status);
	function void (LastRequest lr, eDoorsMode status);

	/** Cell door management, complete
	 *	OnCellsFullyOpened
	 *	OnCellsFullyClosed
	*/
	function Action ();
	function Action (LastRequest lr);

	/** Round timer initialized
	 *	OnTimeLeft
	*/
	function void (int &time);
	function void (LastRequest lr, int &time);

	/** Round time ends
	 *	OnTimeEnd				>> Return > Continue to override forcing Blue team to win
	*/
	function Action ();
	function Action (LastRequest lr);

	/** Friendly Fire timer initialized
	 *	OnFFTimer
	*/
	function void (float &time);
	function void (LastRequest lr, float &time);

	/** LR HUD
	 *	OnShowHud				>> Mostly redundant due to the LR "HudName" entry
	*/
	function void (char[] hud, int len);
	function void (LastRequest lr, char[] hud, int len);

	/** Sound hook
	 *	OnSoundHook
	*/
	function Action (int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed);
	function Action (LastRequest lr, int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed);

	/** Music
	 *	OnPlayMusic
	*/
	function Action (char song[PLATFORM_MAX_PATH], float &time);
	function Action (LastRequest lr, char song[PLATFORM_MAX_PATH], float &time);

	/** OnEntityCreated, before TF2JR does anything
	 *	OnEntCreated
	*/
	function Action (int ent, const char[] classname);
	function Action (LastRequest lr, int ent, const char[] classname);

	/** TF2_CalcIsAttackCritical
	 *	OnCalcAttack
	*/
	function Action (JBPlayer player, int weapon, char[] weaponname, bool &result);
	function Action (LastRequest lr, JBPlayer player, int weapon, char[] weaponname, bool &result);

	/** When warden is about to be locked or unlock
	 *	OnSetWardenLock			>> Return > Continue to prevent bIsWardenLocked from being set to status
	*/
	function Action (const bool status);
	function Action (LastRequest lr, const bool status);

	/** Warden menu selection
	 *	OnWMenuSelect			>> Return > Continue to prevent command from being executed
	*/
	function Action (const JBPlayer player, const char[] command);
	function Action (LastRequest lr, const JBPlayer player, const char[] command);

	/** Warden menu selection, post
	 *	OnWMenuSelectPost
	*/
	function void (const JBPlayer player, const char[] command);
	function void (LastRequest lr, const JBPlayer player, const char[] command);

	// The below do not have LR Hooks!

	/** On perform autobalance
		OnShouldAutobalance
	*/
	function Action ();

	/** On perform autobalance, on a player to be autobalanced
	 *	OnShouldAutobalancePlayer
	*/
	function Action (const JBPlayer player);

	/**	Adding to the LR menu
	 *	OnMenuAdd				>> This is @deprecated, LRs are added and managed by the JBGameMode.hLRMenu automatically
	*/
	function void (const JBPlayer player, LastRequest lr, int &menuflags);

	/**	Adding to the warden menu
	 *	OnWMenuAdd				>> It's advised to use the JBGameMode.hWardenMenu to add to the warden menu
	*/
	function void (Menu &menu);
};

/**
 *	@endsection
*/

/**
 *	@section Hook natives
*/

/**
 *	Hook a function from the core plugin and use them within another plugin.
 *
 *	@param callbacktype 	Enum type to hook into.
 *	@param callback 		Function to call when the forward is called.
 *	
 *	@noreturn
*/
native void JB_Hook(const int callbacktype, JBHookCB callback);

/**
 *	Determine if this function is hooked into forward calls.
 *	@note 					This automatically hooks functions into forwards if it wasn't already (if possible).
 *
 *	@param callbacktype 	Enum type to hook into.
 *	@param callback 		Function to call when the forward is called.
 *
 *	@return 				True on success or if the function was already hooked.
*/	
native bool JB_HookEx(const int callbacktype, JBHookCB callback);

/**
 *	Unhook a function from forward calls.
 *
 *	@param callbacktype 	Enum type to unhook from.
 *	@param callback 		Function to unhook calls from.
 *
 *	@noreturn
*/
native void JB_Unhook(const int callbacktype, JBHookCB callback);

/**
 *	Determine if a function is unhooked from forward calls.
 *	@note 					This automatically unhooks functions from forwards if they weren't already (if possible).
 *	
 *	@param callbacktype 	Enum type to unhook from.
 *	@param callback 		Function to hunhook calls from.
 *
 *	@return 				True on successful unhook, false otherwise or if function wasn't hooked.
*/
native bool JB_UnhookEx(const int callbacktype, JBHookCB callback);

/**
 *	@endsection
*/
