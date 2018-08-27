# TODO # 
**Has been cleared since last time**

## High Priority ##
### Re-Working Plugin Muting ###
- The way plugin muting works now is running PlayerThink. It's basically an idiot friendly way to make sure people stay properly muted and unmuted properly because of all of it's fail-safes. But because of this, mute natives are pointless and redundant, and setting a bIsMutedProperty property incorrectly could be catastrophic (IE, players being muted permanently, see [this](https://github.com/Scags/TF2-Jailbreak-Redux/blob/master/sourcemod/scripting/TF2Jail_Redux.sp#L521-L527) for extreme details.
- This could also allow the usage of issue #6 
- This may also fix the question-mark bug in issue #15 as well

### Re-Working Warden Menu ###
- I've been thinking about going back to the original TF2Jail's method of the warden menu. The way it work's now is talentlessly hard-coded and forced to work, rather than performing the actual command.
