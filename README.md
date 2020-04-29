# TF2Jail-Redux #
Born out of my dislike with the unorganized and jumbled mess the original TF2Jail plugin was, I went out and did a complete rewrite of it, opening up Jailbreak gameplay into a useable API that is very developer-friendly. The entirety of the plugin is built with developers in mind with the goal of making Last Request creation and event management as streamlined as possible.

Take a look at the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki) for not only a complete guide on custom Last Request configuration, but detailed instructions and explanations for each aspect of the plugin.

Special thanks to:

- Nergal/Assyrian with several aspects (plus the LR module) taken from [VSH2](https://forums.alliedmods.net/showthread.php?t=286701).
  
- Drixevel with the [original plugin](https://forums.alliedmods.net/showthread.php?p=2015905).
  
- FlaminSarge with the [Be the Horsemann](https://forums.alliedmods.net/showthread.php?t=166819) plugin.
  
- -MCG-retsam & Antithasys with [Aim Names](https://forums.alliedmods.net/showthread.php?t=114586).
  
- And others.
 
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
  
  **[Search](https://forums.alliedmods.net/showthread.php?p=2677653#post2677653)** - Allows guards to search prisoners.

## Requirements ##

###### [TF2Items](https://forums.alliedmods.net/showthread.php?p=1050170) ######

###### [TF2Attributes](https://forums.alliedmods.net/showthread.php?t=210221) (optional) ######

###### SourceMod 1.10+ ######

## Installation ##
Detailed installation can be found in the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki/Installation-Guide) along with config design.

## File Structure ##
The entire plugin is organized into files associated with what functionality is found within them:

- **TF2Jail_Redux.sp**- Contains the core structure of the plugin, CVars, native engineering, and functions called to and from jailhandler.
  
- **jailhandler.sp**- Handles most major gameplay functions. Mostly calls into forwards
  
- **jailevents.sp**- Event management.
  
- **jailcommands.sp**- Commands obviously. Menus associated with them are also held in here.
  
- **jailbase.sp**- Methodmap structure for players that contains the logic for natives found in player.inc.
  
- **jailgamemode.sp**- Methodmap struction for the gamemode that contains the logic for natives found in gamemode.inc.
  
- **stocks.inc**- Several handy stock functions.
  
- **jailforwards.sp**- Private forward calls. This also executes Last Request function hooks.
  
- **functable.sp**- Holds the manager for Last Request function hooks.
  
- **natives.sp**- Manages all native calls.
  
- **targetfilters.sp**- Handles callbacks and creation of custom target filters.
  
- **tf2jailredux.inc**- The main plugin API, includes player.inc, gamemode.inc, hook.inc, and lastrequest.inc.

- **TF2JR_BaseLRs.sp**- This is the included Last Request manager. Each included Last Request type pertains to its own file in the BaseLRs folder.
  
## Sub Plugins ##
Although the base plugin is well organized, sub-plugins are still an effective way to manage gameplay. There's a slew of private forwards that can be hooked into, and a massive set of natives for managing players, gameplay, and Last Requests. Check out the [wiki](https://github.com/Scags/TF2-Jailbreak-Redux/wiki/API) for more information.
