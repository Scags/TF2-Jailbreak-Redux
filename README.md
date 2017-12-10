# TF2Jail-Redux #
A current WIP

Born out of my dislike with the unorganized and jumbled mess the original TF2Jail plugin was, I went out and did a partial rewrite of it, combining features of different plugins to create a more unique and pristine version that combatted the bugs and issues from the original.
The entirety of the plugin is built with developers in mind, which is why much of it (including Last Requests) are hard coded within it rather than having a config file with limited control over gameplay. 
With the building from several other plugins, props to:

  Nergal/Assyrian with several aspects (plus the LR module) taken from [VSH2](https://forums.alliedmods.net/showthread.php?t=286701).
  
  Drixevel with the [original plugin](https://forums.alliedmods.net/showthread.php?p=2015905).
  
  FlaminSarge with the [Be the Horsemann](https://forums.alliedmods.net/showthread.php?t=166819) plugin.
  
  -MCG-retsam & Antithasys with [Aim Names](https://forums.alliedmods.net/showthread.php?t=114586).
  
  And others that aren't mentioned.

## Features ##
The entire plugin is organized into files associated with what part of the code they use:

  **TF2Jail_Redux.sp**- Contains the core structure of the plugin, CVars, native engineering, and functions called to and from jailhandler.
  
  **jailhandler.sp**- Gameplay structure. Just about everything gameplay oriented that happens within the plugin has some sort of function in here. Last requests are built and organized from here, being made almost as simple as possible.
  
  **jailevents.sp**- Structure of events contained in the plugin, very little happens here other than calls to jailhandler.
  
  **jailcommands.sp**- Commands obviously. Menus associated with them are also held in here.
  
  **jailbase.sp**- Methodmap structure that all players are initiated into throughout the plugin. Ints, floats, bools, and functions can be referenced in the [wiki](https://github.com/Ragenewb/TF2-Jailbreak-Redux/wiki/Player-Methodmap).
  
  **jailgamemode.sp**- Gamemode methodmap with more ints, floats, bools, and functions seen in the [wiki](https://github.com/Ragenewb/TF2-Jailbreak-Redux/wiki/GameMode-Methodmap).
  
  **stocks.inc**- Several stock functions used and some that could be used in the plugin.
  
  **jailforwards.sp**- Nergal saves the day! Forwards that allow events and functions to be used from third party plugins such as the VSH module.
  
  **tf2jailredux.inc**- Complete native and forward-hooking structure that allows third party plugins to derive from the JBPlayer methodmap and be able get/set properties from the internal stringmap.
  
  
## Sub Plugins ##
Versus Saxton Hale is the only current sub-plugin that relatively works as TFJR is still a WIP. It contains usage of the methodmap derivement from JBPlayer along with hooking to function calls and events from the core plugin. More information about this can be found on the [wiki](https://github.com/Ragenewb/TF2-Jailbreak-Redux/wiki/Forwards-and-Natives). (Prophunt is next on the list)

-----------------------------

If you have any ideas, thoughts, feature requests, don't be shy to fork (but don't do it yet, I'm not done) or just leave me a comment on my [Steam Profile](http://steamcommunity.com/profiles/76561198085502536)
