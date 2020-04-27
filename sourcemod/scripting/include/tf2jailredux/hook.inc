#if defined _tf2jr_hook_included
	#endinput
#endif
#define _tf2jr_hook_included

#include <tf2jailredux/player>

enum LastRequest{}

/**
 *	@section Forwards and Forward-oriented natives
*/

enum	// Hook Types
{
	OnDownloads = 0,
	OnRoundStart,
	OnRoundStartPlayer,
	OnRoundEnd,
	OnRoundEndPlayer,
	OnPreThink,
	OnRedThink,
	OnBlueThink,
	OnFreedayGiven,
	OnFreedayRemoved,
	OnWardenGet,
	OnWardenThink,
	OnWardenKilled,
	OnPlayerTouch,
	OnPlayerSpawned,
	OnPlayerDied,
	OnPlayerPrepped,
	OnPlayerPreppedPost,
	OnLastGuard,
	OnLastPrisoner,
	OnCheckLivingPlayers,
	OnTakeDamage,
	OnBuildingDestroyed,
	OnPlayerHurt,
	OnObjectDeflected,
	OnPlayerJarated,
	OnUberDeployed,
	OnClientInduction,
	OnVariableReset,
	OnTimeLeft,
	OnMenuAdd,
	OnShowHud,
	OnLRPicked,
	OnLRGiven,
	OnWMenuAdd,
	OnWMenuSelect,
	OnTimeEnd,
	OnFFTimer,
	OnDoorsOpen,
	OnDoorsClose,
	OnDoorsLock,
	OnDoorsUnlock,
	OnSoundHook,
	OnEntCreated,
	OnCalcAttack,
	OnRebelGiven,
	OnRebelRemoved,
	OnWardenRemoved,
	OnShouldAutobalance,
	OnShouldAutobalancePlayer,
	OnSetWardenLock,
	OnPlayMusic,
	OnLRDenied,
	OnLRActivate,
	OnLRActivatePlayer,

	JBFWD_LENGTH
};

/**
 *	Each callback function has a counterpart to it's LR hook
 *	Globally hooking a function (with JB_Hook) will be the first callback signature (the one without LastRequest as a param)
 *	LR hooked functions (LastRequest.AddHook) correspond the the second callback signature and will only fire if that LR is/was involved or is active
*/

/* SDKHook-Style Forwards */
typeset JBHookCB
{
	/*
		OnRoundStartPlayer2
		OnRedThink
		OnBlueThink
		OnWardenThink
		OnPlayerPrepped
		OnClientInduction
		OnVariableReset
		OnFreedayGiven
		OnFreedayRemoved
		OnLRGiven
		OnPreThink
		OnRebelRemoved
	*/
	function void (const JBPlayer player);
	function void (LastRequest lr, const JBPlayer player);

	/*
		OnPlayerSpawned
		OnRoundEndPlayer
	*/
	function void (const JBPlayer player, Event event);
	function void (LastRequest lr, const JBPlayer player, Event event);

	/*
		OnPlayerTouch
		OnPlayerJarated
		OnUberDeployed			Medic is player, Patient is victim
	*/
	function void (const JBPlayer player, const JBPlayer victim);
	function void (LastRequest lr, const JBPlayer player, const JBPlayer victim);

	//	OnBuildingDestroyed
	function void (const JBPlayer attacker, const int building, Event event);
	function void (LastRequest lr, const JBPlayer player, const int building, Event event);

	/*
		OnPlayerDied
		OnPlayerAirblasted
	*/
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);
	function void (LastRequest lr, const JBPlayer player, const JBPlayer attacker, Event event);

	/*
		OnDownloads
		OnCheckLivingPlayers
		OnRoundStart2
		OnLRActivate
	*/
	function void ();
	function void (LastRequest lr);

	//	OnLRActivatePlayer		Both JB_Hook and LastRequest.AddHook use the same callback signature
	function void (LastRequest lr, const JBPlayer player);
	
	//	OnRoundEnd
	function void (Event event);
	function void (LastRequest lr, Event event);

	// 	OnShowHud
	function void (char[] hud, int len);
	function void (LastRequest lr, char[] hud, int len);

	// 	OnHurtPlayer
	function void (const JBPlayer victim, const JBPlayer attacker, Event event);
	function void (LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event);

	// 	OnTakeDamage
	function Action (const JBPlayer victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	function Action (LastRequest lr, const JBPlayer victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);

	//	OnPlayMusic
	function Action (char song[PLATFORM_MAX_PATH], float &time);
	function Action (LastRequest lr, char song[PLATFORM_MAX_PATH], float &time);

	/*
		OnTimeEnd				Return > Continue to override forcing Blue team to win
		OnLastGuard				Return Handled to stop "One Guard Left" message. Return Stop to not fire OnCheckLivingPlayers
		OnLastPrisoner			Return Stop to not fire OnCheckLivingPlayers
		OnDoorsOpen 			Return > Continue to not fire
		OnDoorsClose 			Return > Continue to not fire
		OnDoorsLock 			Return > Continue to not fire
		OnDoorsUnlock 			Return > Continue to not fire
		OnShouldAutobalance 	Does not have LR counterpart
	*/
	function Action ();
	function Action (LastRequest lr);

	//	OnWardenKilled			Return > Continue to stop "Warden has been killed" message
	function Action (const JBPlayer victim, const JBPlayer attacker, Event event);
	function Action (LastRequest lr, const JBPlayer victim, const JBPlayer attacker, Event event);

	//	OnFFTimer
	function void (float &time);
	function void (LastRequest lr, float &time);

	//	OnTimeLeft
	function void (int &time);
	function void (LastRequest lr, int &time);

	/*
		OnWardenGet
		OnPlayerPreppedPre
		OnRebelGiven
		OnShouldAutobalancePlayer		LastRequest passed is the iPresetType
	*/
	function Action (const JBPlayer player);
	function Action (LastRequest lr, const JBPlayer player);

	//	OnSoundHook
	function Action (int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed);
	function Action (LastRequest lr, int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], JBPlayer player, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed);

	//	OnEntCreated
	function Action (int ent, const char[] classname);
	function Action (LastRequest lr, int ent, const char[] classname);

	//	OnCalcAttack
	function Action (JBPlayer player, int weapon, char[] weaponname, bool &result);
	function Action (LastRequest lr, JBPlayer player, int weapon, char[] weaponname, bool &result);

	//	OnSetWardenLock			Return > Continue to not fire
	function Action (const bool status);
	function Action (LastRequest lr, const bool status);

	//	OnWMenuSelect
	function Action (const JBPlayer player, const char[] index);
	function Action (LastRequest lr, const JBPlayer player, const char[] index);

	//	OnMenuAdd				Both JB_Hook and LastRequest.AddHook use the same callback signature
	function void (const JBPlayer player, LastRequest lr, int &menuflags);

	/*
	 	OnLRPicked				Return > Continue to prevent setting the next iLRPresetType to index
	 							Both JB_Hook and LastRequest.AddHook use the same callback signature
	*/
	function Action (LastRequest lr, const JBPlayer player);

	//	OnWMenuAdd
	function void (Menu &menu);
};

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
