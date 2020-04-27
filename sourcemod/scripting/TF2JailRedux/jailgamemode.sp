methodmap JailGameMode < JBGameMode
{
	public JailGameMode()
	{
		JailGameMode gm = view_as< JailGameMode >(new StringMap());
		gm.iRoundState = 0;
		gm.iTimeLeft = 0;
		gm.iRoundCount = 0;
		gm.iLRPresetType = -1;
		gm.iLRType = -1;
		gm.iMuteType = 0;
		gm.iLivingMuteType = 0;
		gm.iVoters = 0;
		gm.iVotes = 0;
		gm.iVotesNeeded = 0;
		gm.iWarden = view_as< JBPlayer >(0);
		gm.bFreedayTeleportSet = false;
		gm.bIsFreedayRound = false;
		gm.bDisableCriticals = false;
		gm.bWardenExists = false;
		gm.bFirstDoorOpening = false;
		gm.bIsWardenLocked = false;
		gm.bAdminLockedLR = false;
		gm.bIsWarday = false;
		gm.bOneGuardLeft = false;
		gm.bOnePrisonerLeft = false;
		gm.bIsLRInUse = false;
		gm.b1stRoundFreeday = false;
		gm.bCellsOpened = false;
		gm.bIsMapCompatible = false;
		gm.bAllowBuilding = false;
		gm.bSilentWardenKills = false;
		gm.bMedicDisabled = false;
		gm.bDisableMuting = false;
		gm.bDisableKillSpree = false;
		gm.bIgnoreRebels = false;
		gm.bMarkerExists = false;
		gm.bIsLRRound = false;
		gm.flMusicTime = 0.0;
		gm.hTargetFilters = new StringMap();
		gm.hLRS = new StringMap();
		gm.hLRCount = new ArrayList();
		return gm;
	}

	property JailFighter iWarden
	{
		public get()
		{
			return view_as< JailFighter >(view_as< JBGameMode >(this).iWarden);
		}
		public set(const JailFighter i)
		{
			this.SetProp("iWarden", i ? i.userid : 0);
		}
	}
	
	/**
	 *	Handle the cell doors.
	 *
	 *	@param status 			Type of cell door usage found in the eDoorsMode enum.
	 *	@param announce 		Announce message to all clients.
	 *	@param fromwarden 		If true, current warden will be the client announced who activated cells. 
	 *							If false, undisclosed admin is the announced activator.
	 *							Do NOT set this param to true if there is no current Warden.
	 *	@param overridefwds 	If true, forwards will not be called for the according action.
	 *
	 *	@noreturn
	*/
	public void DoorHandler( const eDoorsMode status, bool announce = false, bool fromwarden = true, bool overridefwds = false )
	{
		if (strCellNames[0] != '\0')
		{
			char name[32];
			switch (status)
			{
				case OPEN:
				{
					if (!overridefwds)
						if (Call_OnDoorsOpen() != Plugin_Continue) 
							return;
					FormatEx(name, sizeof(name), "%t", "Opened");
					this.bCellsOpened = true;
					if (!this.bFirstDoorOpening)
						this.bFirstDoorOpening = true;
				}
				case CLOSE:
				{
					if (!overridefwds)
						if (Call_OnDoorsClose() != Plugin_Continue) 
							return;
					FormatEx(name, sizeof(name), "%t", "Closed");
					this.bCellsOpened = false;
				}
				case LOCK:
				{
					if (!overridefwds)
						if (Call_OnDoorsLock() != Plugin_Continue) 
							return;
					FormatEx(name, sizeof(name), "%t", "Locked");
				}
				case UNLOCK:
				{
					if (!overridefwds)
						if (Call_OnDoorsUnlock() != Plugin_Continue) 
							return;
					FormatEx(name, sizeof(name), "%t", "Unlocked");
				}
			}

			if (announce)
				if (fromwarden)
					CPrintToChatAll("%t %t", "Plugin Tag", "Warden Work Cells", this.iWarden.index, name);
				else CPrintToChatAll("%t %t", "Admin Tag", "Admin Work Cells", name);

			int i, ent = -1;
			for (i = 0; i < sizeof(strDoorsList); i++)
			{
				ent = -1;
				while ((ent = FindEntityByClassnameSafe(ent, strDoorsList[i])) != -1)
				{
					GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
					if (StrEqual(name, strCellNames, false))
					{
						switch (status)
						{
							case OPEN:AcceptEntityInput(ent, "Open");
							case CLOSE:AcceptEntityInput(ent, "Close");
							case LOCK:AcceptEntityInput(ent, "Lock");
							case UNLOCK:AcceptEntityInput(ent, "Unlock");
						}
					}
				}
			}
		}
	}
	/**
	 *	Reset the Warden-firing votes.
	 *
	 *	@noreturn
	*/
	public void ResetVotes()
	{
		this.iVotes = 0;

		for (int i = MaxClients; i; --i)
			if (IsClientConnected(i))
				JailFighter(i).bVoted = false;
	}
	/**
	 *	Find and terminate the current Warden.
	 *
	 *	@param prevent 			Prevent the player from becoming Warden again.
	 * 	@param announce 		Display to all players that the Warden was fired.
	 *
	 *	@noreturn
	*/
	public void FireWarden( bool prevent = true, bool announce = true )
	{
		JailFighter player = this.iWarden;
		if (!player)
			return;

		player.WardenUnset();

		if (prevent)
			player.bLockedFromWarden = true;
		if (announce)
		{
			CPrintToChatAll("%t %t", "Plugin Tag", "Warden Fired");
			PrintCenterTextAll("%t", "Warden Fired");
		}

		this.ResetVotes();
	}
	/**
	 *	Open all of the doors on a map.
	 *	@note 					This ignores all name checks and opens every door possible.
	 *							This also has the chance of opening doors that lead outside of the map, be wary of this.
	 *
	 *	@noreturn
	*/
	public void OpenAllDoors()
	{
		int ent;
		for (int i = 0; i < sizeof(strDoorsList); i++)
		{
			ent = -1;
			while ((ent = FindEntityByClassname(ent, strDoorsList[i])) != -1)
			{
				if (IsValidEntity(ent))
				{
					AcceptEntityInput(ent, "Unlock");
					AcceptEntityInput(ent, "Open");
				}
			}
		}
	}
	/**
	 *	Enable/Disable the medic room in a map.
	 *
	 *	@param status 			True to enable it, False otherwise.
	 *
	 *	@noreturn
	*/
	//	Props to Dr.Doctor
	public void ToggleMedic( const bool status )
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "trigger_hurt")) != -1)
				if (GetEntPropFloat(ent, Prop_Data, "m_flDamage") < 0)
				AcceptEntityInput(ent, status ? "Enable" : "Disable");

		this.bMedicDisabled = !status;
	}
	/**
	 *	Toggle team filtering on the medic room.
	 *
	 *	@param team 			Team to toggle.
	 *
	 *	@noreturn
	*/
	/*public void ToggleMedicTeam( int team = 0 )
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "trigger_hurt")) != -1)
			if (IsValidEntity(ent))
				if (GetEntPropFloat(ent, Prop_Data, "m_flDamage") < 0)
					SetEntProp(ent, Prop_Data, "m_iTeamNum", team);
	}*/

	/**
	 *	Trigger muting on clients.
	 *
	 *	@param player 			JailFighter instance of player to toggle muting for.
	 *	@param forcedead 		Force the client to be treated as dead, even if they aren't.
	 *	@param teamchange 		Force team-based muting onto the client, even if they aren't
	 *							on that team.
	 *
	 *	@noreturn
	*/
	public void ToggleMuting( const JailFighter player, bool forcedead = false, int teamchange = 0 )
	{
		if (this.iRoundState != StateRunning || this.bDisableMuting)
		{
			player.UnmutePlayer();
			return;
		}

		int type = (!forcedead && IsPlayerAlive(player.index)) ? this.iLivingMuteType : this.iMuteType;
		int team = teamchange ? teamchange : GetClientTeam(player.index);
		bool ismute = player.bIsMuted;

		if (!team)	// If player is in spec, assume red team rules of muting
			team = RED;

		switch (type)
		{
			case 0:player.UnmutePlayer();
			case 1:
				if (team == RED && !player.bIsVIP)
					player.MutePlayer();
				else player.UnmutePlayer();
			case 2:
				if (team == BLU && !player.bIsVIP)
					player.MutePlayer();
				else player.UnmutePlayer();
			case 3:if (!player.bIsVIP) player.MutePlayer();
			case 4:if (team == RED) player.MutePlayer();
			case 5:if (team == BLU) player.MutePlayer();
			default:player.MutePlayer();
		}

		char s[16];
		if (ismute && !player.bIsMuted)
			s = "Unmuted";
		else if (!ismute && player.bIsMuted)
			s = "Muted";

		if (s[0] != '\0')
			CPrintToChat(player.index, "%t %t", "Plugin Tag", s);
	}

	/**
	 *	Get the position of a certain teleportation location.
	 *
	 *	@param location  		Location index to get.
	 *	@param array 			Array to copy to.
	 *
	 *	@return 				True if the location property is valid.
	*/
	public bool GetTelePosition( const int location, float[] array )
	{
		switch (location)
		{
			case FREEDAY:
			{
				array[0] = vecFreedayPosition[0];
				array[1] = vecFreedayPosition[1];
				array[2] = vecFreedayPosition[2];
				return this.bFreedayTeleportSet;
			}
			case WRED:
			{
				array[0] = vecWardayRed[0];
				array[1] = vecWardayRed[1];
				array[2] = vecWardayRed[2];
				return this.bWardayTeleportSetRed;
			}
			case WBLU:
			{
				array[0] = vecWardayBlu[0];
				array[1] = vecWardayBlu[1];
				array[2] = vecWardayBlu[2];
				return this.bWardayTeleportSetBlue;
			}
		}
		return false;
	}

	// No private properties yet >:(
	/**
	 *	Toggle the Warden's lock status.
	 *	@note 					This is recommended rather than setting the raw property due
	 *							to a forward plugins can operate on.
	 *
	 *	@param status  			Location index to get.
	 *	@param unsetwarden 		If true, unset the current warden.
	 *
	 *	@return 				True on success, false otherwise.
	*/
	public bool SetWardenLock(const bool status, bool unsetwarden = false)
	{
		if (Call_OnSetWardenLock(status) != Plugin_Continue)
			return false;

		if (unsetwarden)
			this.iWarden.WardenUnset();
		this.bIsWardenLocked = status;
		return true;
	}

	/**
	 *	Autobalance the teams in accordance with the cvars.
	 *
	 *	@param announce 		Tell the player that they've been autobalanced.
	 *
	 *	@noreturn
	*/
	public void AutobalanceTeams(bool announce = true)
	{
		if (this.iPlaying <= 2)
			return;

		if (Call_OnShouldAutobalance() != Plugin_Continue)
			return;

		int immunity = cvarTF2Jail[AutobalanceImmunity].IntValue;
		float balance = cvarTF2Jail[BalanceRatio].FloatValue;
		float lBlue = float( GetLivingPlayers(BLU) );
		float lRed = float( GetLivingPlayers(RED) );
		JailFighter player;

		float ratio;
		int tries;
		do
		{
			ratio = lBlue / lRed;
			if (ratio <= balance)
				break;

			player = JailFighter(GetRandomPlayer(BLU, true));
			if (player.index == -1)		// Fake news
				break;

			if ((immunity == 2 && !player.bIsAdmin) || (immunity == 1 && !player.bIsVIP) || !immunity)
			{
				if (Call_OnShouldAutobalancePlayer(player) != Plugin_Continue)
					continue;

				KillFlameManager(player.index);
				player.ForceTeamChange(RED);
				if (announce)
					CPrintToChat(player.index, "%t %t", "Plugin Tag", "Autobalanced");

				--lBlue;	// Avoid loopception
				++lRed;
			}
		}	while ++tries < 50;	// Plenty
	}

	/**
	 *	Autobalance the teams as evenly as possible.
	 *	@note 					Guardbanned players are handled automatically.
	 *
	 *	@param announce			Tell the player that they've been autobalanced.
	 *	@param followimmun 		If true, follow autobalance immunity rules.
	 *
	 *	@noreturn
	*/
	public void EvenTeams(bool announce = true, bool followimmun = true)
	{
		if (this.iPlaying <= 2)		// Shouldn't they already be even then...?
			return;

		int countred, countblu;
		int immunity = cvarTF2Jail[AutobalanceImmunity].IntValue;
		JailFighter player;

		int tries, val;
		do
		{
			val = RoundFloat(FloatAbs(float((countred = GetLivingPlayers(RED)) - (countblu = GetLivingPlayers(BLU)))) / 2);

			if (val <= 1)
				break;

			if (tries > 50)
				break;

			player = JailFighter(GetRandomPlayer(countred > countblu ? RED : BLU, true));

			if (player.index == -1)
				break;

			// Could possibly hit an infinite loop here
			// Rare, however. Would take low player count and/or a lot of donors/admins
			// Which is why 'tries' exists
			if (followimmun && !((immunity == 2 && !player.bIsAdmin) || (immunity == 1 && !player.bIsVIP) || !immunity))
				continue;

			KillFlameManager(player.index);
			player.ForceTeamChange(countred > countblu ? BLU : RED);
			if (announce)
				CPrintToChat(player.index, "%t %t", "Plugin Tag", "Autobalanced");
		}	while ++tries <= 50;
	}
};
