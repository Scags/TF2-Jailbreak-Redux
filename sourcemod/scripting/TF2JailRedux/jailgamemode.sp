
StringMap hGameModeFields;

methodmap JailGameMode
{
	public JailGameMode()
	{
		hGameModeFields = new StringMap();
	}
	property int iRoundState
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iRoundState", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iRoundState", i);
		}
	}
	property int iPlaying
	{
		public get()
		{
			int playing = 0;
			for (int i=MaxClients ; i ; --i) {
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
			int i; hGameModeFields.GetValue("iTimeLeft", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iTimeLeft", i);
		}
	}
	property int iRoundCount
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iRoundCount", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iRoundCount", i);
		}
	}
	property int iLRPresetType
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iLRPresetType", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iLRPresetType", i);
		}
	}
	property int iLRType
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iLRType", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iLRType", i);
		}
	}
	property int iFreedayLimit
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iFreedayLimit", i);
			return i;
		}
		public set( const int i )
		{
			hGameModeFields.SetValue("iFreedayLimit", i);
		}
	}
	
#if defined _steamtools_included
	property bool bSteam
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bSteam", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bSteam", i);
		}
	}
#endif
#if defined _sourcebans_included
	property bool bSB
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bSB", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bSB", i);
		}
	}
#endif
	property bool bSC
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bSC", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bSC", i);
		}
	}
#if defined _voiceannounce_ex_included
	property bool bVA
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bVA", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bVA", i);
		}
	}
#endif
	property bool bTF2Attribs // REQUIRED
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bTF2Attribs", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bTF2Attribs", i);
		}
	}
	property bool bIsMapCompatible
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsMapCompatible", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bIsMapCompatible", i);
		}
	}
	property bool bFreedayTeleportSet
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bFreedayTeleportSet", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bFreedayTeleportSet", i);
		}
	}
	property bool bWardayTeleportSetBlue
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardayTeleportSetBlue", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bWardayTeleportSetBlue", i);
		}
	}
	property bool bWardayTeleportSetRed
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardayTeleportSetRed", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bWardayTeleportSetRed", i);
		}
	}
	property bool bCellsOpened
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bCellsOpened", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bCellsOpened", i);
		}
	}
	property bool b1stRoundFreeday
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("b1stRoundFreeday", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("b1stRoundFreeday", i);
		}
	}
	property bool bIsLRInUse
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsLRInUse", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bIsLRInUse", i);
		}
	}
	property bool bIsWardenLocked
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsWardenLocked", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bIsWardenLocked", i);
		}
	}
	property bool bOneGuardLeft
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bOneGuardLeft", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bOneGuardLeft", i);
		}
	}
	property bool bAdminLockWarden
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bAdminLockWarden", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bAdminLockWarden", i);
		}
	}
	property bool bAdminLockedLR
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bAdminLockedLR", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bAdminLockedLR", i);
		}
	}
	property bool bDisableCriticals
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bDisableCriticals", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bDisableCriticals", i);
		}
	}
	property bool bIsFreedayRound
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsFreedayRound", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bIsFreedayRound", i);
		}
	}
	property bool bWardenExists
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardenExists", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bWardenExists", i);
		}
	}
	property bool bFirstDoorOpening
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bFirstDoorOpening", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bFirstDoorOpening", i);
		}
	}
	/** PROPERTIES BELOW ARE A PART OF LAST REQUEST PROPERTIES **/
	property bool bIsWarday
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsWarday", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bIsWarday", i);
		}
	}
	property bool bMarkerExists
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bMarkerExists", i);
			return i;
		}
		public set( const bool i )
		{
			hGameModeFields.SetValue("bMarkerExists", i);
		}
	}

	property float flMusicTime
	{
		public get()
		{
			float i; hGameModeFields.GetValue("flMusicTime", i);
			return i;
		}
		public set( const float i )
		{
			hGameModeFields.SetValue("flMusicTime", i);
		}
	}

	public void Init()	// When adding a new property, make sure you initialize it to a default 
	{
		this.iRoundState = 0;
		this.iTimeLeft = 0;
		this.iRoundCount = 0;
		this.iLRPresetType = -1;
		this.iLRType = -1;
		this.iFreedayLimit = 0;
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
		this.bMarkerExists = false;
		this.flMusicTime = 0.0;
	}

	public void FindRandomWarden()
	{
		JailFighter( GetRandomPlayer(BLU, true) ).WardenSet();
		this.bWardenExists = true;
	}
	public void DoorHandler(const eDoorsMode status)
	{
		if (strlen(sCellNames) != 0)
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
				case LOCK:CPrintToChatAll("{red}[TF2Jail]{tan} Cell doors have been locked.");
				case UNLOCK:CPrintToChatAll("{red}[TF2Jail]{tan} Cell doors have been unlocked.");
			}
		}
	}
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
	public void FireWarden(bool prevent = true, bool announce = true)
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
};