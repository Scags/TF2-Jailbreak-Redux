# TODO #

## High Priority ##
### Teambans ###
- Obviously a necessity in Jailbreak, however I want more than the stereotypical guardban/offline guardban/rageban abilities. 
- I've added ip detection to the prototype plugin I've written, however considering that bans times run down while a player is actively in the server, alternate account bans would remain after unban. Therefore I would have to search for ip addresses on unban. Not eactly hard per se, but seems unnecessary.

### ~~Better AddLRToMenu() Forward~~ ###
- ~~In the plugin's current state, sub-plugin last requests must have indexes that are last in the enumeration.~~
- ~~This comes out of laziness as there's an array of the current, included last request names.~~
- ~~Only idea I have currently is firing the forward in the loop itself with the index being passed.~~ ✅

### ~~Revised Weaponblocker Plugin~~ ###
- ~~The `*PlayerBack` stocks are shoddy and are fairly expensive to run a multitude of times in a loop, especially if configs are chock full of indexes.~~ ✅

## Low Priority ##
### Translations ###
- Even though I don't know a lick of any other language, why not.
### ~~Depecrating SetPawnTimer()~~ ###
- ~~Another method made out of laziness. A regular timer would suffice.~~
- ~~Global handles would be helpful as I could kill them during parts of the round, especially on round end.~~ ❌ Works too well with both timed and async function calls. Oh well.

### ~~Undoing Macro Laziness~~ ###
~~- After the methodmap macro addition, I concluded that they're fairly ugly.~~
~~- Most if not all of the non-string macros will most likely be removed fairly soon.~~ ✅

### ~~Breaking up Plugin into Separate Sub-Plugins~~ ###
- ~~The core plugin is overkill, and contains a whole lot of stuff that may or may not be wanted.~~
- ~~I could make a trillion cvars but it'd be a hassle to manage all in one plugin~~
- ~~Breaking them up into warden/lastrequest plugins would be easier to manage.~~ ❌ jailhandler.sp does its job well enough

## Undecided Possibilities ##
### ~~Global Forwards~~ ###
- ~~The SDKHook-style private forward hooking system is pretty cool and works to a tee.~~
- ~~However global forwards would provide easier access to the multitude of forwards TF2JR has (at the cost of me slapping all the code down).~~ ❌ I've actually been thinking of adapting a function-pointer-grabbing style seen in Boss Fight Fortress, not too sure yet

### ~~Last Request Configs~~ ###
- ~~TF2JR's purpose was to create a Jailbreak plugin that would be easier for developers to maintain and enhance their servers.~~
- ~~This easiness was the stricter, hard-coded structure in the plugin that isn't as flaccid as config files. Let's face it, having a server command fire on round start takes no skill whatsoever. Therefore the hard-coded style was preferential in my opinion.~~
- ~~Even without any changes or additions by server owners, TF2JR could function as a fine replacement for the original plugin.~~
- ~~But because of this replacement ability, giving server owners that lack SourceMod skills the ability to create their own last request, no matter how simple, could be a possibility.~~ ❌ Crossing out for now...
