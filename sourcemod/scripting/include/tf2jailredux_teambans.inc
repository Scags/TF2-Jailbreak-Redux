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
 *	@param reason 			Reason to put into the log database.
 *
 *	@return 				Plugin_Handled or Plugin_Stop to stop the Guardban, 
 *							anything else otherwise.
*/
forward Action JB_OnBan(int client, int admin, int &time, char reason[256]);

/**
 *	Called upon an Unguardban occurrence.
 *
 *	@param client 			Client being Unguardbanned.
 *	@param admin 			Admin doing the Unguardban.
 *
 *	@return 				Anything but Plugin_Continue to stop the Unguardban,
 *							anything else otherwise.
*/
forward Action JB_OnUnBan(int client, int admin);

/**
 *	Called upon an offline Guardban occurrence.
 *
 *	@param id 				Steam ID being Guardbanned.
 *	@param admin 			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
 *	@param reason 			Reason to put into the log database.
 *
 *	@return 				Plugin_Handled or Plugin_Stop to stop the Guardban, 
 *							anything else otherwise.
*/
forward Action JB_OnOfflineBan(const char[] id, int admin);

/**
 *	Called upon an offline Unguardban occurrence.
 *
 *	@param id 				Steam ID being Unguardbanned.
 *	@param admin 			Admin doing the Unguardban.
 *
 *	@return 				Anything but Plugin_Continue to stop the Unguardban,
 *							anything else otherwise.
*/
forward Action JB_OnOfflineUnBan(const char[] id, int admin);


/**
 *	Called upon a WardenBan occurrence.
 *
 *	@param client			Client being WardenBanned.
 *	@param admin			Admin doing the WardenBan.
 *	@param time 			Time in minutes of the duration of the WardenBan.
 *
 *	@return 				Plugin_Handled or Plugin_Stop to stop the WardenBan, 
 *							anything else otherwise.
*/
forward Action JB_OnWardenBan(int client, int admin, int &time);

/**
 *	Called upon an UnWardenBan occurrence.
 *
 *	@param client 			Client being UnWardenBanned.
 *	@param admin 			Admin doing the UnWardenBan.
 *
 *	@return 				Anything but Plugin_Continue to stop the UnWardenBan,
 *							anything else otherwise.
*/
forward Action JB_OnWardenUnBan(int client, int admin);

/**
 *	Called upon an offline WardenBan occurrence.
 *
 *	@param id 				Steam ID being WardenBanned.
 *	@param admin 			Admin doing the WardenBan.
 *
 *	@return 				Plugin_Handled or Plugin_Stop to stop the WardenBan, 
 *							anything else otherwise.
*/
forward Action JB_OnOfflineWardenBan(const char[] id, int admin);

/**
 *	Called upon an offline UnWardenBan occurrence.
 *
 *	@param id 				Steam ID being UnWardenBanned.
 *	@param admin 			Admin doing the UnWardenBan.
 *
 *	@return 				Anything but Plugin_Continue to stop the UnWardenBan,
 *							anything else otherwise.
*/
forward Action JB_OnOfflineWardenUnBan(const char[] id, int admin);

/**
 *	Guardban a client.
 *
 *	@param client 			Client to be Guardbanned.
 *	@param admin 			Admin doing the Guardban.
 *	@param time 			Time in minutes of the duration of the Guardban.
 *	@param reason 			Reason to put into the log database.
 *
 *	@noreturn
*/
native void JB_GuardBan(int client, int admin, int time, char reason[256]);

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
 *
 *	@noreturn
*/
native void JB_OfflineGuardBan(const char[] id, int admin);

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

/**
 *	Give a player a menu of all guardbannable clients.
 *	@note 					Operation will fail of there are no guardbannable clients.
 *
 *	@param client 			Client to give the menu to.
 *							Client will not appear in menu.
 *
 *	@noreturn
*/
native void JB_DisplayBanMenu(int client);

/**
 *	Give a player a menu of all unguardbannable clients.
 *	@note 					Operation will fail of there are no unguardbannable clients.
 *
 *	@param client 			Client to give the menu to.
 *							Client will not appear in menu.
 *
 *	@noreturn
*/
native void JB_DisplayUnbanMenu(int client);

/**
 *	WardenBan a client.
 *
 *	@param client 			Client to be WardenBanned.
 *	@param admin 			Admin doing the WardenBan.
 *	@param time 			Time in minutes of the duration of the WardenBan.
 *
 *	@noreturn
*/
native void JB_WardenBan(int client, int admin, int time);

/**
 *	UnWardenBan a client.
 *
 *	@param client 			Client to be UnWardenBanned.
 *	@param admin 			Admin doing the UnWardenBan.
 *
 *	@noreturn
*/
native void JB_UnWardenBan(int client, int admin);

/**
 *	WardenBan a Steam ID.
 *
 *	@param id 				Steam ID2 to WardenBan.
 *	@param admin 			Admin doing the WardenBan.
 *	@param time 			Time in minutes of the duration of the WardenBan.
 *
 *	@noreturn
*/
native void JB_OfflineWardenBan(const char[] id, int admin);

/**
 *	UnWardenBan a Steam ID.
 *
 *	@param id 				Steam ID2 to UnWardenBan.
 *	@param admin 			Admin doing the UnWardenBan.
 *
 *	@noreturn
*/
native void JB_OfflineUnWardenBan(const char[] id, int admin);


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
public void __pl_tf2jailredux_teambans_SetNTVOptional()
{
	MarkNativeAsOptional("JB_GuardBan");
	MarkNativeAsOptional("JB_UnGuardBan");
	MarkNativeAsOptional("JB_OfflineGuardBan");
	MarkNativeAsOptional("JB_OfflineUnGuardBan");

	MarkNativeAsOptional("JB_RageBanMenu");
	MarkNativeAsOptional("JB_DisplayBanMenu");
	MarkNativeAsOptional("JB_DisplayUnbanMenu");

	MarkNativeAsOptional("JB_WardenBan");
	MarkNativeAsOptional("JB_UnWardenBan");
	MarkNativeAsOptional("JB_OfflineWardenBan");
	MarkNativeAsOptional("JB_OfflineUnWardenBan");
}
#endif

