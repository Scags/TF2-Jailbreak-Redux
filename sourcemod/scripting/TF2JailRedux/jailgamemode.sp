methodmap JailGameMode < StringMap
{
	public JailGameMode()
	{
		return view_as< JailGameMode >(new StringMap());
	}
	property int iRoundState
	{
		public get()
		{
			int i; this.GetValue("iRoundState", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iRoundState", i);
		}
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
				else if (!IsPlayerAlive(i))
					continue;
				++playing;
			}
			return playing;
		}
	}
	property int iTimeLeft
	{
		public get()
		{
			int i; this.GetValue("iTimeLeft", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iTimeLeft", i);
		}
	}
	property int iRoundCount
	{
		public get()
		{
			int i; this.GetValue("iRoundCount", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iRoundCount", i);
		}
	}
	property int iLRPresetType
	{
		public get()
		{
			int i; this.GetValue("iLRPresetType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLRPresetType", i);
		}
	}
	property int iLRType
	{
		public get()
		{
			int i; this.GetValue("iLRType", i);
			return i;
		}
		public set( const int i )
		{
			this.SetValue("iLRType", i);
		}
	}
	
#if defined _steamtools_included
	property bool bSteam
	{
		public get()
		{
			bool i; this.GetValue("bSteam", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSteam", i);
		}
	}
#endif
#if defined _sourcebans_included
	property bool bSB
	{
		public get()
		{
			bool i; this.GetValue("bSB", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSB", i);
		}
	}
#endif
	property bool bSC
	{
		public get()
		{
			bool i; this.GetValue("bSC", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bSC", i);
		}
	}
#if defined _voiceannounce_ex_included
	property bool bVA
	{
		public get()
		{
			bool i; this.GetValue("bVA", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bVA", i);
		}
	}
#endif
	property bool bTF2Attribs
	{
		public get()
		{
			bool i; this.GetValue("bTF2Attribs", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bTF2Attribs", i);
		}
	}
	property bool bIsMapCompatible
	{
		public get()
		{
			bool i; this.GetValue("bIsMapCompatible", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsMapCompatible", i);
		}
	}
	property bool bFreedayTeleportSet
	{
		public get()
		{
			bool i; this.GetValue("bFreedayTeleportSet", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bFreedayTeleportSet", i);
		}
	}
	property bool bWardayTeleportSetBlue
	{
		public get()
		{
			bool i; this.GetValue("bWardayTeleportSetBlue", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardayTeleportSetBlue", i);
		}
	}
	property bool bWardayTeleportSetRed
	{
		public get()
		{
			bool i; this.GetValue("bWardayTeleportSetRed", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardayTeleportSetRed", i);
		}
	}
	property bool bCellsOpened
	{
		public get()
		{
			bool i; this.GetValue("bCellsOpened", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bCellsOpened", i);
		}
	}
	property bool b1stRoundFreeday
	{
		public get()
		{
			bool i; this.GetValue("b1stRoundFreeday", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("b1stRoundFreeday", i);
		}
	}
	property bool bIsLRInUse
	{
		public get()
		{
			bool i; this.GetValue("bIsLRInUse", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsLRInUse", i);
		}
	}
	property bool bIsWardenLocked
	{
		public get()
		{
			bool i; this.GetValue("bIsWardenLocked", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsWardenLocked", i);
		}
	}
	property bool bOneGuardLeft
	{
		public get()
		{
			bool i; this.GetValue("bOneGuardLeft", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bOneGuardLeft", i);
		}
	}
	property bool bOnePrisonerLeft
	{
		public get()
		{
			bool i; this.GetValue("bOnePrisonerLeft", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bOnePrisonerLeft", i);
		}
	}
	property bool bAdminLockWarden
	{
		public get()
		{
			bool i; this.GetValue("bAdminLockWarden", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAdminLockWarden", i);
		}
	}
	property bool bAdminLockedLR
	{
		public get()
		{
			bool i; this.GetValue("bAdminLockedLR", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bAdminLockedLR", i);
		}
	}
	property bool bDisableCriticals
	{
		public get()
		{
			bool i; this.GetValue("bDisableCriticals", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bDisableCriticals", i);
		}
	}
	property bool bIsFreedayRound
	{
		public get()
		{
			bool i; this.GetValue("bIsFreedayRound", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsFreedayRound", i);
		}
	}
	property bool bWardenExists
	{
		public get()
		{
			bool i; this.GetValue("bWardenExists", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bWardenExists", i);
		}
	}
	property bool bFirstDoorOpening
	{
		public get()
		{
			bool i; this.GetValue("bFirstDoorOpening", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bFirstDoorOpening", i);
		}
	}
	property bool bIsWarday
	{
		public get()
		{
			bool i; this.GetValue("bIsWarday", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bIsWarday", i);
		}
	}
	property bool bMarkerExists
	{
		public get()
		{
			bool i; this.GetValue("bMarkerExists", i);
			return i;
		}
		public set( const bool i )
		{
			this.SetValue("bMarkerExists", i);
		}
	}

	property float flMusicTime
	{
		public get()
		{
			float i; this.GetValue("flMusicTime", i);
			return i;
		}
		public set( const float i )
		{
			this.SetValue("flMusicTime", i);
		}
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
#if defined _sourcebans_included
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
					AcceptEntityInput(ent, "Open");
					AcceptEntityInput(ent, "Unlock");
				}
			}
		}
	}
};