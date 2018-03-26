methodmap JailGameMode < StringMap
{
	public JailGameMode()
	{
		return view_as< JailGameMode >(new StringMap());
	}
	property int iRoundState
	{
		IntGet("iRoundState")
		IntSet("iRoundState")
	}
	property int iPlaying
	{
		public get()
		{
			int playing;
			for (int i = MaxClients; i; --i) 
			{
				if (!IsClientInGame(i))
					continue;
				if (!IsPlayerAlive(i))
					continue;
				++playing;
			}
			return playing;
		}
	}
	property int iTimeLeft
	{
		IntGet("iTimeLeft")
		IntSet("iTimeLeft")
	}
	property int iRoundCount
	{
		IntGet("iRoundCount")
		IntSet("iRoundCount")
	}
	property int iLRPresetType
	{
		IntGet("iLRPresetType")
		IntSet("iLRPresetType")
	}
	property int iLRType
	{
		IntGet("iLRType")
		IntSet("iLRType")
	}
	
#if defined _steamtools_included
	property bool bSteam
	{
		BoolGet("bSteam")
		BoolSet("bSteam")
	}
#endif
#if defined _sourcebans_included || defined _sourcebanspp_included
	property bool bSB
	{
		BoolGet("bSB")
		BoolSet("bSB")
	}
#endif
	property bool bSC
	{
		BoolGet("bSC")
		BoolSet("bSC")
	}
#if defined _voiceannounce_ex_included
	property bool bVA
	{
		BoolGet("bVA")
		BoolSet("bVA")
	}
#endif
	property bool bTF2Attribs
	{
		BoolGet("bTF2Attribs")
		BoolSet("bTF2Attribs")
	}
	property bool bIsMapCompatible
	{
		BoolGet("bIsMapCompatible")
		BoolSet("bIsMapCompatible")
	}
	property bool bFreedayTeleportSet
	{
		BoolGet("bFreedayTeleportSet")
		BoolSet("bFreedayTeleportSet")
	}
	property bool bWardayTeleportSetBlue
	{
		BoolGet("bWardayTeleportSetBlue")
		BoolSet("bWardayTeleportSetBlue")
	}
	property bool bWardayTeleportSetRed
	{
		BoolGet("bWardayTeleportSetRed")
		BoolSet("bWardayTeleportSetRed")
	}
	property bool bCellsOpened
	{
		BoolGet("bCellsOpened")
		BoolSet("bCellsOpened")
	}
	property bool b1stRoundFreeday
	{
		BoolGet("b1stRoundFreeday")
		BoolSet("b1stRoundFreeday")
	}
	property bool bIsLRInUse
	{
		BoolGet("bIsLRInUse")
		BoolSet("bIsLRInUse")
	}
	property bool bIsWardenLocked
	{
		BoolGet("bIsWardenLocked")
		BoolSet("bIsWardenLocked")
	}
	property bool bOneGuardLeft
	{
		BoolGet("bOneGuardLeft")
		BoolSet("bOneGuardLeft")
	}
	property bool bOnePrisonerLeft
	{
		BoolGet("bOnePrisonerLeft")
		BoolSet("bOnePrisonerLeft")
	}
	property bool bAdminLockWarden
	{
		BoolGet("bAdminLockWarden")
		BoolSet("bAdminLockWarden")
	}
	property bool bAdminLockedLR
	{
		BoolGet("bAdminLockedLR")
		BoolSet("bAdminLockedLR")
	}
	property bool bDisableCriticals
	{
		BoolGet("bDisableCriticals")
		BoolSet("bDisableCriticals")
	}
	property bool bIsFreedayRound
	{
		BoolGet("bIsFreedayRound")
		BoolSet("bIsFreedayRound")
	}
	property bool bWardenExists
	{
		BoolGet("bWardenExists")
		BoolSet("bWardenExists")
	}
	property bool bFirstDoorOpening
	{
		BoolGet("bFirstDoorOpening")
		BoolSet("bFirstDoorOpening")
	}
	property bool bIsWarday
	{
		BoolGet("bIsWarday")
		BoolSet("bIsWarday")
	}
	property bool bMarkerExists
	{
		BoolGet("bMarkerExists")
		BoolSet("bMarkerExists")
	}

	property float flMusicTime
	{
		FloatGet("flMusicTime")
		FloatSet("flMusicTime")
	}
	/**
	 *	Initialize all JailGameMode Properties to a default.
	 *
	 *	@noreturn
	*/
	public void Init()	// When adding a new property, make sure you initialize it to a default 
	{
		this.iRoundState = 0;
		this.iTimeLeft = 0;
		this.iRoundCount = 0;
		this.iLRPresetType = -1;
		this.iLRType = -1;
		this.bFreedayTeleportSet = false;
		this.bTF2Attribs = false;
		this.bIsFreedayRound = false;
		this.bDisableCriticals = false;
		this.bWardenExists = false;
		this.bFirstDoorOpening = false;
		this.bAdminLockedLR = false;
		this.bAdminLockWarden = false;
		this.bIsWarday = false;
		this.bOneGuardLeft = false;
		this.bOnePrisonerLeft = false;
		this.bIsLRInUse = false;
		this.b1stRoundFreeday = false;
		this.bCellsOpened = false;
		this.bIsMapCompatible = false;
#if defined _steamtools_included
		this.bSteam = false;
#endif
#if defined _sourcebans_included || defined _sourcebanspp_included
		this.bSB = false;
#endif
		this.bSC = false;
#if defined _voiceannounce_ex_included
		this.bVA = false;
#endif
		this.bMarkerExists = false;
		this.flMusicTime = 0.0;
	}
	/**
	 *	Find and Initialize a random player as the warden.
	 *
	 *	@noreturn
	*/
	public void FindRandomWarden()
	{
		JailFighter(GetRandomPlayer(BLU, true)).WardenSet();
		this.bWardenExists = true;
	}
	/**
	 *	Handle the cell doors.
	 *
	 *	@param status 			Type of cell door usage found in the eDoorsMode enum.
	 *
	 *	@noreturn
	*/
	public void DoorHandler( const eDoorsMode status )
	{
		if (sCellNames[0] != '\0')
		{
			for (int i = 0; i < sizeof(sDoorsList); i++)
			{
				char sEntityName[128]; int ent = -1;
				while ((ent = FindEntityByClassnameSafe(ent, sDoorsList[i])) != -1)
				{
					GetEntPropString(ent, Prop_Data, "m_iName", sEntityName, sizeof(sEntityName));
					if (StrEqual(sEntityName, sCellNames, false))
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
			switch (status)
			{
				case OPEN:
				{
					this.bCellsOpened = true;
					if (!this.bFirstDoorOpening)
						this.bFirstDoorOpening = true;
				}
				case CLOSE:this.bCellsOpened = false;
				// case LOCK:CPrintToChatAll("{red}[TF2Jail]{tan} Cell doors have been locked.");
				// case UNLOCK:CPrintToChatAll("{red}[TF2Jail]{tan} Cell doors have been unlocked.");
			}
		}
	}
	/**
	 *	Find the current warden if one exists.
	 *
	 *	@return 				The current warden.
	 *
	*/
	public JailFighter FindWarden()
	{
		JailFighter player;
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i))
				continue;
			player = JailFighter(i);
			if (!player.bIsWarden)
				continue;
			return player;
		}
		return view_as< JailFighter >(0);
	}
	/** 
	 *	Find and terminate the current warden.
	 *
	 *	@param prevent 			Prevent the player from becoming warden again.
	 * 	@param announce 		Display to all players that the warden was fired.
	 *
	 *	@noreturn
	*/
	public void FireWarden( bool prevent = true, bool announce = true )
	{
		JailFighter player = this.FindWarden();
		player.WardenUnset();
		this.bWardenExists = false;
		if (this.iRoundState == StateRunning)
		{
			if (cvarTF2Jail[WardenTimer].BoolValue)
				SetPawnTimer(DisableWarden, cvarTF2Jail[WardenTimer].FloatValue, this.iRoundCount);
		}
		if (prevent)
			player.bLockedFromWarden = true;
		if (announce)
			CPrintToChatAll("{orange}[TF2Jail]{tan} Warden has been fired!");
	}
	/**
	 *	Open all of the doors on a map
	 *	@NOTE 					This ignores all name checks and opens every door possible.
	 *
	 *	@noreturn
	*/
	public void OpenAllDoors()
	{
		int ent;
		for (int i = 0; i < sizeof(sDoorsList); i++)
		{
			ent = -1;
			while ((ent = FindEntityByClassname(ent, sDoorsList[i])) != -1)
			{
				if (IsValidEntity(ent))
				{
					AcceptEntityInput(ent, "Unlock");
					AcceptEntityInput(ent, "Open");
				}
			}
		}
	}
};