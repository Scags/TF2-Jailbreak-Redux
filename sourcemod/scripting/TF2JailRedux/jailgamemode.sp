
StringMap hGameModeFields;

methodmap JailGameMode //< StringMap
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
		public set(const int val)
		{
			hGameModeFields.SetValue("iRoundState", val);
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
		public set(const int val)
		{
			hGameModeFields.SetValue("iTimeLeft", val);
		}
	}
	property int iRoundCount
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iRoundCount", i);
			return i;
		}
		public set(const int val)
		{
			hGameModeFields.SetValue("iRoundCount", val);
		}
	}
	property int iLRPresetType
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iLRPresetType", i);
			return i;
		}
		public set( const int val )
		{
			hGameModeFields.SetValue("iLRPresetType", val);
		}
	}
	property int iLRType
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iLRType", i);
			return i;
		}
		public set(const int val)
		{
			hGameModeFields.SetValue("iLRType", val);
		}
	}
	property int iFreedayLimit
	{
		public get()
		{
			int i; hGameModeFields.GetValue("iFreedayLimit", i);
			return i;
		}
		public set(const int val)
		{
			hGameModeFields.SetValue("iFreedayLimit", val);
		}
	}
	property int iBeam
	{
		public get()
		{
			return PrecacheModel("materials/sprites/laserbeam.vmt");
		}
	}
	property int iHalo
	{
		public get()
		{
			return PrecacheModel("materials/sprites/glow01.vmt");
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bSteam", val);
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bSB", val);
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bSC", val);
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bVA", val);
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bTF2Attribs", val);
		}
	}
	property bool bIsMapCompatible
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsMapCompatible", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bIsMapCompatible", val);
		}
	}
	property bool bFreedayTeleportSet
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bFreedayTeleportSet", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bFreedayTeleportSet", val);
		}
	}
	property bool bWardayTeleportSetBlue
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardayTeleportSetBlue", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bWardayTeleportSetBlue", val);
		}
	}
	property bool bWardayTeleportSetRed
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardayTeleportSetRed", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bWardayTeleportSetRed", val);
		}
	}
	property bool bCellsOpened
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bCellsOpened", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bCellsOpened", val);
		}
	}
	property bool b1stRoundFreeday
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("b1stRoundFreeday", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("b1stRoundFreeday", val);
		}
	}
	property bool bIsLRInUse
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsLRInUse", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bIsLRInUse", val);
		}
	}
	property bool bIsWardenLocked
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsWardenLocked", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bIsWardenLocked", val);
		}
	}
	property bool bOneGuardLeft
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bOneGuardLeft", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bOneGuardLeft", val);
		}
	}
	property bool bAdminLockWarden
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bAdminLockWarden", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bAdminLockWarden", val);
		}
	}
	property bool bAdminLockedLR
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bAdminLockedLR", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bAdminLockedLR", val);
		}
	}
	property bool bDisableCriticals
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bDisableCriticals", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bDisableCriticals", val);
		}
	}
	property bool bIsFreedayRound
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bIsFreedayRound", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bIsFreedayRound", val);
		}
	}
	property bool bWardenExists
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bWardenExists", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bWardenExists", val);
		}
	}
	property bool bFirstDoorOpening
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bFirstDoorOpening", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bFirstDoorOpening", val);
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
		public set(const bool val)
		{
			hGameModeFields.SetValue("bIsWarday", val);
		}
	}
	property bool bMarkerExists
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bMarkerExists", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bMarkerExists", val);
		}
	}

	property float flMusicTime
	{
		public get()
		{
			float i; hGameModeFields.GetValue("flMusicTime", i);
			return i;
		}
		public set(const float val)
		{
			hGameModeFields.SetValue("flMusicTime", val);
		}
	}
	/*property float flFreedayPosition
	{
		public get()
		{
			float i; hGameModeFields.GetValue("flFreedayPosition", i);
			return i;
		}
		public set(const float val)
		{
			hGameModeFields.SetValue("flFreedayPosition", val);
		}
	}
	property float flWardayBlu
	{
		public get()
		{
			float i; hGameModeFields.GetValue("flWardayBlu", i);
			return i;
		}
		public set(const float val)
		{
			hGameModeFields.SetValue("flWardayBlu", val);
		}
	}
	property float flWardayRed
	{
		public get()
		{
			float i; hGameModeFields.GetValue("flWardayRed", i);
			return i;
		}
		public set(const float val)
		{
			hGameModeFields.SetValue("flWardayRed", val);
		}
	}*/

/* Parameters like above can't be arrays. It's a sad day for those who would love to hook teleports in subplugins */	

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
				case LOCK:CPrintToChatAll("{red}[JailRedux]{tan} Cell doors have been locked.");
				case UNLOCK:CPrintToChatAll("{red}[JailRedux]{tan} Cell doors have been unlocked.");
			}
		}
	}
	public JailFighter FindWarden()
	{
		if (this.bWardenExists)
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
			CPrintToChatAll("{orange}[JailRedux]{tan} Warden has been fired!");
	}
};