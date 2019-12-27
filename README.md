# TF2Jail-Redux #
Born out of my dislike with the unorganized and jumbled mess the original TF2Jail plugin was, I went out and did a complete rewrite of it, combining features of different plugins to create a more unique and pristine version that is very developer-friendly.

The entirety of the plugin is built with developers in mind, which is why much of it (especially Last Requests) are hard coded within it rather than having a config file with limited control over gameplay. The plugin is essentially developer framework with enough cvars to allow server owners to adjust the plugin to their liking without having to dabble in the source code.

Take a look at the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki) for a complete guide as to how to create and craft last requests. The plugin comes with it's own API found in the wiki as well.

With the building from several other plugins, props to:

  Nergal/Assyrian with several aspects (plus the LR module) taken from [VSH2](https://forums.alliedmods.net/showthread.php?t=286701).
  
  Drixevel with the [original plugin](https://forums.alliedmods.net/showthread.php?p=2015905).
  
  FlaminSarge with the [Be the Horsemann](https://forums.alliedmods.net/showthread.php?t=166819) plugin.
  
  -MCG-retsam & Antithasys with [Aim Names](https://forums.alliedmods.net/showthread.php?t=114586).
  
  And others.
 
## Features ##
- 13 spanking, ready-to-go last requests to use in your server.
- About half were in the original TF2Jail, the other half I just pulled out of my ass.
- The random last request is also an addition, because who doesn't love a good bit of RNG?
- More pristine ammo management. Might've fixed the age old DemoMan shield bug, don't ask me.
- No more Razorback freeday abuse, smacking those removes your freeday now
- More muting options controlled via cvar.
- Extra warden stuff, such as beacons and a laser pointer.
- Warday gamemodes are built into the plugin.
- Doubled the length of last request names.
- Grabbing ammo as a freeday can be a no-no if desired.
- Eureka Effect isn't disgustingly cheap to use on a Warday
- Muted players can't join blue team if desired.
- A lot of target filters:
    - @warden
    - @!warden
    - @freedays
    - @!freedays
    - @rebels
    - @!rebels
    - *Use the below at your own risk:*
    - @freedayloc
    - @!freedayloc
    - @wardayred
    - @!wardayred
    - @wardayblue
    - @!wardayblue
    - @wardayloc
    - @!wardayloc
    - @medic
    - @!medic
 - And more!

## Other Addons ##
  **[WeaponBlocker](https://github.com/Scags/TF2JailRedux-WeaponBlocker)** - A weapon blocker that actually works with this plugin.
  
  **[Mechanized Mercenaries](https://github.com/Scags/TF2-LRModule-MechMercs)** - A last request where everyone turns into tanks!

## File Structure ##
The entire plugin is organized into files associated with what functionality is found within them:

  **TF2Jail_Redux.sp**- Contains the core structure of the plugin, CVars, native engineering, and functions called to and from jailhandler.
  
  **jailhandler.sp**- Gameplay and backend structure. Just about everything gameplay oriented that happens within the plugin has some sort of function in here. Last requests are built and organized from here, being made almost as simple as possible.
  
  **jailevents.sp**- Event management.
  
  **jailcommands.sp**- Commands obviously. Menus associated with them are also held in here.
  
  **jailbase.sp**- Methodmap structure that contains player-based properties and methods.
  
  **jailgamemode.sp**- Gamemode methodmap with gameplay-based properties and methods.
  
  **stocks.inc**- Several stock functions used and some that could be used in the plugin.
  
  **jailforwards.sp**- Forwards that allow events and functions to be used from third party plugins such as the VSH and PH module. Note that these are all private forwards.
  
  **lastrequests,sp**- Organized file that includes last request .sp files. If you wish to take the methodmap road while crafting a last request, place the .sp file in the lastrequests/ folder and organize it by including it from here.
  
  **tf2jailredux.inc**- Complete native and forward-hooking structure that allows third party plugins to derive from the JBPlayer methodmap and be able get/set properties from the internal stringmap.
  
## Sub Plugins ##
TF2JR uses an SDKHook-style format for its forwards, and plenty of natives exposed for developers to have a great grasp on gameplay. With sub-plugins that can be made such as Versus Saxton Hale and Prophunt, the sky's the limit for what can be done. 

## Requirements ##

###### [TF2Items](https://forums.alliedmods.net/showthread.php?p=1050170) ######

###### [TF2Attributes](https://forums.alliedmods.net/showthread.php?t=210221) (optional) ######

###### SourceMod 1.10+ ######

## Installation ##
Detailed installation can be found in the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki/Installation-Guide) along with config design.
