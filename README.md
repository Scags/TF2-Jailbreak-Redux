# TF2Jail-Redux #
A current WIP

Born out of my dislike with the unorganized and jumbled mess the original TF2Jail plugin was, I went out and did a partial rewrite of it, combining features of different plugins to create a more unique and pristine version that combatted the bugs and issues from the original.
The entirety of the plugin is built with developers in mind, which is why much of it (especially Last Requests) are hard coded within it rather than having a config file with limited control over gameplay. Take a look at the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki/Last-Requests) for a complete guide as to how to create and craft last requests.

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
  
  **jailbase.sp**- Methodmap structure that all players use to store variables and methods.
  
  **jailgamemode.sp**- Gamemode methodmap with more variables and methods corresponding to gameplay.
  
  **stocks.inc**- Several stock functions used and some that could be used in the plugin.
  
  **jailforwards.sp**- Nergal saves the day! Forwards that allow events and functions to be used from third party plugins such as the VSH and PH module.
  
  **tf2jailredux.inc**- Complete native and forward-hooking structure that allows third party plugins to derive from the JBPlayer methodmap and be able get/set properties from the internal stringmap.
  
  
## Sub Plugins ##
TF2JR uses an SDKHook-style format for its forwards. With sub-plugins such as Versus Saxton Hale and Prophunt, a developer is able to hook into the function calls that they need not only to create last requests, but to enhance regular gameplay. 

## Requirements ##

###### [TF2Items](https://forums.alliedmods.net/showthread.php?p=1050170) ######

###### [TF2Attributes](https://forums.alliedmods.net/showthread.php?t=210221) (optional) ######

## Installation ##
Detailed installation can be found in the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki/Installation-Guide) along with config design.
