# Changelog #

### 2.0.0Beta ###
- Complete overhaul of the plugin system.
- Last Requests can now be made via config. LRs can be imported and exported to and from config via plugin.
- LR config supercedes the original TF2Jail config and uses most of the previous entries, with several more included.
- Last Requests now are a Handle that can be created and/or imported from config.
- Implemented a function table that Last Request handles have. This table is used for hooked functions, similar to JB_Hook.
- Sub-plugin last requests now have config in their LR config, rather than with CVars.
- Methodmaps pertaining to gamemode and players are now unified into a singleton. This way properties are all contained in the respective include files rather than split across multiples.
- Removed library bools from the gamemode StringMap.
- Added forwards for when LR is given, LR activation, and LR denial.
- Added a player property to skip weapon/ammo management.
- Added a gamemode property to skip weapon/ammo management.
- Separated included Last Requests into a separate plugin.
- Patched bugs surrounding freedays and their application.
- Separated include file API into separate, respective files.

### V2.0.1Beta ###
- Added parameter to LastRequest.CreateFromConfig to fail if an LR is disabled.
- Updated LRModuleTemplate.sp to line up with the new API.
- Patch issue with prop rerolling in PropHunt.
- Exposed natives for loading up Jailbreak config files.
- Added extra stocks for cleaner wearable and building management.
- Added CVar to give prisoners godmode while they are selecting an LR
- Damage dealt by prisoners will refresh their rebel timer, if it's enabled.
- Added logging and activity for most admin commands.
- Adjusted translations for admin command activity.
- Hotfixed a bug where players could spawn as spectators.
- Added CVars to give wardens backstab protection.
- Added forward for round reset.
- Added CVar to give random warden at a delay.
- Added return value to DoorHandler().
- Patched a few bugs where last request length was an incorrect value.
- Added CVar to have warden friendly fire only work with prisoners, where guards would not deal damage to each other.
- Added various optimizations to the teambans plugin.
- Added CVar to allow warden to set the health of prisoners.
- Added descriptions to the hook enum.
- Added property for warden backstab count, if player is selecting Lr, and the rebel timer.

### V2.0.2Beta ###
- Added post hooks for several pre hook forwards.
- Organized hook.inc to help with forward callbacks.
- Patched a bug where FF would not work for non-warden-toggled FF.
- Enhanced door handler function where success/return value relies on door status.
- Removed support for prop_door_rotating cell doors. They probably didn't work anyway.
- Removed old LR files that were no longer used.
- Added a property to detect if warden was locked by the plugin manually, rather than by other means.
- Added forwards for cells after they fully open and fully close.

### V2.0.3Beta ###
- Removed redundancies with some entity code.
- Patched a bug where teambanned players could not be re-teambanned.
- Patched a bug where an engineer's existence could crash the server on a VSH round.
- Future-proofed last request function tables.
- Extended the freeday beam CVar to where beams can be disabled if the CVar is 0.
- Patched killing warden weapons via LR if warden is auto-selected on round start.
- Fixed errors revolving around rebel timer handles.
- Fixed random-wardening failing if it happened to select a player who was warden-banned by the teambans plugin.
- Cleaned up some more Teamban plugin code.
- Patched a bug with setting internal LR music.
- Fixed another bad crash with the VSH LR.
- Extended LR music to allow "sound/" in the file path.

### V2.0.4 ###
- Added a native for refreshing the LR Hud element.
- Fixed up marking natives as optional.
- Added a return value to JBGameMode_ManageCells/JBGameMode.DoorHandler
- Implemented a Freekiller system with CVars to control it.
- Added natives and forwards for the Freekiller system.
- Fixed an awful memory leak in the LR menu handler.
- Removed an old CVar that isn't used anymore.
- Moved enum structs to jailbase.sp.
- Reworked TextNodeParam enum struct to hold a Hud Handle.
- Patched weapon management extending beyond the size of the weapon netprop array.
- Added support for particle attachments for roles in rolerenderers.cfg.
- Removed a bogus native.
- Fool-proofed the wearable stocks in stocks.inc.
- Removed an invalid stock function.
- Fixed a bug where Hale materials were not downloading properly.
- Removed weaponblocker.cfg and assigned it to it's own repository.
- Revamped the weaponblocker plugin to be able to operate under different sub-gamemodes including freedays and wardays.
- Added "VoidFreekills" to the proper LR config files.
- Added last resort command overrides for VIPs and Admins with TF2Jail_VIP and TF2Jail_Admin respectively.