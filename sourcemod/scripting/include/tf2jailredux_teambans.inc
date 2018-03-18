#if defined _tf2jailredux_teambans_included
  #endinput
#endif
#define _tf2jailredux_teambans_included


/**
 *	Called upon a Guardban occurrence.
 *
 *	@param client			Client being Guardbanned.
 *	@param admin			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
*/
forward void JB_OnBan(int client, int admin, int time);

/**
 *	Called upon an Unguardban occurrence.
 *
 *	@param client 			Client being Unguardbanned.
 *	@param admin 			Admin doing the Unguardban.
*/
forward void JB_OnUnBan(int client, int admin);

/**
 *	Called upon an offline Guardban occurrence.
 *
 *	@param id 				Steam ID being Guardbanned.
 *	@param admin 			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
*/
forward void JB_OnOfflineBan(const char[] id, int admin, int time);

/**
 *	Called upon an offline Unguardban occurrence.
 *
 *	@param id 				Steam ID being Unguardbanned.
 *	@param admin 			Admin doing the Unguardban.
*/
forward void JB_OnOfflineUnBan(const char[] id, int admin);


/**
 *	Guardban a client.
 *
 *	@param client 			Client to be Guardbanned.
 *	@param admin 			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
 *
 *	@noreturn
*/
native void JB_GuardBan(int client, int admin, int time);

/**
 *	Unguardban a client.
 *
 *	@param client 			Client to be Unguardbanned.
 *	@param admin 			Admin doing the Unguardban.
 *
 *	@noreturn
*/
native void JB_UnGuardBan(int client, int admin);

/**
 *	Guardban a Steam ID.
 *
 *	@param id 				Steam ID2 to Guardban.
 *	@param admin 			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
 *
 *	@noreturn
*/
native void JB_OfflineGuardBan(const char[] id, int admin, int time);

/**
 *	Unguardban a Steam ID.
 *
 *	@param id 				Steam ID2 to Unguardban.
 *	@param admin 			Admin doing the Unguardban.
 *
 *	@noreturn
*/
 native void JB_OfflineUnGuardBan(const char[] id, int admin);

/**
 *	Give a player the Rage Ban menu.
 *
 *	@param client 			Client to give the menu to.
 *
 *	@noreturn
*/
native void JB_RageBanMenu(int client);


public SharedPlugin __pl_tf2jailredux_teambans = {
	name = "TF2JailRedux_TeamBans",
	file = "TF2JailRedux_TeamBans.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_tf2jailredux_teambans_SetNTVOptional()
{
	MarkNativeAsOptional("JB_GuardBan");
	MarkNativeAsOptional("JB_UnGuardBan");
	MarkNativeAsOptional("JB_OfflineGuardBan");
	MarkNativeAsOptional("JB_OfflineUnGuardBan");

	MarkNativeAsOptional("JB_RageBanMenu");
}


