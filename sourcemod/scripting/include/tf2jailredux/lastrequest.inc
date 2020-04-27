#if defined _tf2jr_lr_included
	#endinput
#endif
#define _tf2jr_lr_included

#include <tf2jailredux/hook>

#define MAX_LRNAME_LENGTH 	128

methodmap LastRequest < StringMap
{
	/**
	 *	Create an instance of a new last request. If an LR of this name
	 *	already exists in memory, then it will link up with that
	 *	LR. Otherwise, it will create a new, empty LR.
	 *	@note 					DO *NOT* DELETE THIS, EVER. IF YOU WANT TO 
	 *							REMOVE IT, USE Destroy()!!!
	 *
	 *	@param name 			Name of the last request. This is case-insensitive!
	 *	@param exists 			If this LR is already cached, this will be set
	 *							to true, false otherwise.
	 *
	 *	@return 				Link to LR if it existed before, otherwise
	 *							It creates a new, empty LR. If new, this will
	 * 							set the "Name" entry as name.
	*/
	public static native LastRequest Create(const char[] name, bool &exists = false);

	/**
	 *	Create an instance of a new last request directly from the config. 
	 *	If an LR of this name already exists in the config, then it will
	 *	copy the data in that config. Otherwise, it will return null.
	 *	Contrary to LastRequest(), this will only fail if the LR does
	 *	not exist in the config.
	 *	Note that the purpose of this native is to be able to delete and 
	 *	recreate Last Request instances with LRs that can be deleted from memory, 
	 *	and import their data. See Destroy() for more information.
	 *
	 *	@note 					DO *NOT* DELETE THIS, EVER. IF YOU WANT TO 
	 *							REMOVE IT, USE Destroy()!!!
	 *							This will overwrite and replace an LR of the same
	 *							name if it exists.
	 *
	 *	@param name 			Name of the last request. This is the config SECTION
	 * 							name and is case-insensitive!
	 *
	 *	@return 				New LR instance if it exists in config, null otherwise.
	 *							If it exists, this will set the "Name" entry as name.
	*/
	public static native LastRequest CreateFromConfig(const char[] name);

	/**
	 *	Retrieve an LR at this index.
	 *	@note 					This will silently fail if index is -1.
	 *
	 *	@param index 			Index of the last request.
	 *
	 *	@error 					Index < 0 or index >= JBGameMode.iLRs.
	 *	@return 				Handle to LR at said index.
	*/
	public static native LastRequest At(const int index);

	/**
	 *	Retrieve an LR from memory by it's name. This is the same as the name 
	 *	it was created with or its config SECTION name and is CASE-SENSITIVE.
	 *
	 *	@param name 			Name of the last request. This is case-sensitive!
	 *
	 *	@return 				Handle to LR of that name, null if
	 *							it does not exist.
	*/
	public static native LastRequest ByName(const char[] name);

	/**
	 *	Add a hook to Jailbreak function callback. This is 
	 *	the same as JB_Hook, but it only fires if this LR was involved.
	 *	@note 					Only one hook allowed per LR per index.
	 *							Re-hooking at the same index will
	 *							simply replace the function that was
	 *							there with the new function.
	 *
	 *	@param callbacktype 	Index of the callback (see hook.inc)
	 *	@param func 			Function the call when this event
	 *							happens (see JBHookCB in hook.inc).
	 *
	 *	@error 					Index < 0 or >= JBFWD_LENGTH.
	 *	@noreturn
	 *
	*/
	public native void AddHook(const int callbacktype, const JBHookCB func);

	/**
	 *	Remove a hook from a Jailbreak function at this index.
	 *
	 *	@param callbacktype 	Index of the callback (see hook.inc).
	 *
	 *	@error 					Index < 0 or >= JBFWD_LENGTH.
	 *	@noreturn
	*/
	public native void RemoveHook(const int callbacktype);

	public Function GetFunction(const int callbacktype)
	{
		if (!(0 <= callbacktype < JBFWD_LENGTH))
			return INVALID_FUNCTION;

		DataPack p; this.GetValue("__FUNCS", p);
		p.Position = view_as< DataPackPos >(callbacktype + 1);
		return p.ReadFunction();
	}

	public bool SetFunction(const int callbacktype, const JBHookCB func)
	{
		if (!(0 <= callbacktype < JBFWD_LENGTH))
			return false;

		DataPack p; this.GetValue("__FUNCS", p);
		p.Position = view_as< DataPackPos >(callbacktype + 1);
		p.WriteFunction(func);
		return true;
	}

	/**
	 *	Execute a Last Request's activation logic. This is 
	 *	as if the LR was executed on the round start.
	 *	@note 					This fires OnLRActivate, OnLRActivatePlayer,
	 *							and OnFFTimer if FF is set.
	 *	@noreturn
	*/
	public native void Execute();

	/**
	 *	Remove this Last Request.
	 *	@note 					This will not remove it from the config.
	 *							It's advised to use this OnPluginEnd() so
	 *							that there aren't "dead" or logic-less LRs
	 *							in the selection. See below for information
	 *							on recreating destroyed LRs.
	 *
	 *	@param name 			Name to seek. If empty, LR name is used.
	 *							This is the same as its creation name or 
	 *							SECTION name in the config and is case-sensitive!
	 *
	 *	@noreturn
	 *							If you Destroy() an LR, you are deleting
	 * 							it completely from memory! This means that,
	 *							should you call LastRequest.Create() with the
	 *							same name afterwards, you will receive an empty LR.
	 * 							If you wish to destroy and recreate an LR
	 *							(say, when reloading a sub-plugin), you should
	 *							use LastRequest.CreateFromConfig()!
	*/
	public native void Destroy(const char[] name = "");

	/**
	 *	Detect if this LR exists in the config file.
	 *
	 * 	@param name 			Name to seek. If empty, LR name is used.
	 *							This is its config SECTION name and is case-insensitive!
	 *
	 *	@return 				True if there is an entry, false otherwise.
	*/
	public native bool IsInConfig(const char[] name = "");

	/**
	 *	Import LR data from the last request config.
	 *
	 *	@param name 			Name of the entry to import. If empty,
	 *							the LR's name is used. This is it's config 
	 *							SECTION name and is case-sensitive.
	 *
	 *	@return 				True if import was successfuly, false if
	 *							Entry didnt exist or both name and LR
	 *							name were empty.
	*/
	public native bool ImportFromConfig(const char[] name = "");

	/**
	 *	Export this LR's data into the config.
	 *	@note 					This will delete comments in the config file!
	 *
	 *	@param name 			Name of the entry to export as, if empty,
	 *							the LR's name is used. NOTE THAT EXPORTING
	 *							IS CASE INSENSITIVE. EXPORTING AS 'Name'
	 *							CAN/WILL OVERWRITE AN ENTRY NAMED 'nAme'.
	 *
	 *	@param overwrite 		If true, entry will be created if it does
	 * 							not exist. If false and there is no key,
	 * 							this will silently fail.
	 * 	@param createonly 		If true, export will only be successful if
	 * 							there is no key in the config.
	 *	@param append 			If true, data will be appended to file,
	 * 							however keys will be overwritten if there
	 * 							are multiple instances of the same key.
	 *
	 *	@return 				True on success, false on failure.
	*/
	public native bool ExportToConfig(const char[] name = "", bool create = false, bool createonly = false, bool append = true);

	/**
	 *	Delete this LR from the config.
	 *	@note 					This will delete comments in the config file!
	 *
	 * 	@param name 			Name of the entry to delete, if empty,
	 *							the LR's name is used. NOTE THAT NAMES
	 *							ARE CASE INSENSITIVE. DELETING AS 'Name'
	 *							CAN/WILL DELETE AN ENTRY NAMED 'nAme'.
	 *
	 *	@return 				True on success, false on failure or
	 * 							if key did not exist.
	*/
	public native bool DeleteFromConfig(const char[] name = "");

	/**
	 *	Refresh this LR's data from the config. If the LR is not in the config,
	 * 	this will silently fail.
	 *	@note 					This is the same as deleting and creating
	 * 							a new last request of the same name. However
	 * 							|this| is not deleted.
	 *
	 *	@param name 			Name of the entry to delete, if empty,
	 *							the LR's name is used. This is its SECTION name
	 *							in the config and is case-insensitive.
	*/
	public native void Refresh(const char[] name = "");


	/**
	 *	** ** INTERNAL PROPERTIES ** **
	 *
	 *	THESE SHOULD NOT BE SET, EVER
	 * 	THESE ARE ALL CREATED ONCE YOU INITIALIZE A LastRequest HANDLE
	*/
	public int GetID()
	{
		int val; this.GetValue("__LRID", val);
		return val;
	}

	public Handle GetOwnerPlugin()
	{
		Handle val; this.GetValue("__PL", val);
		return val;
	}

	public KeyValues GetKv()
	{
		KeyValues val; this.GetValue("__KV", val);
		if (val != null)
			val.Rewind();
		return val;
	}

	/** Do not use this unless you know what you're doing **/
	public KeyValues CreateKv(const char[] name)
	{
		KeyValues val; this.GetValue("__KV", val);
		if (val == null)
			val = new KeyValues(name);
		return val;
	}

	public KeyValues GetParameterKv(bool create = false)
	{
		KeyValues val = this.GetKv();
		if (val != null)
			if (val.JumpToKey("Parameters", create))
				return val;
		return null;
	}

	public KeyValues CreateParameterKv()
	{
		KeyValues val = this.GetKv();
		if (val != null)
			if (val.JumpToKey("Parameters", true))
				return val;
		return null;
	}

	/** ** ** PARAMETERS ** ** */
	/**
	 *	These are the entries under "Parameters" in the LR config
	*/
	public int GetParameterNum(const char[] name, int defaultvalue = 0, bool &found = false)
	{
		int val = defaultvalue;
		KeyValues k = this.GetParameterKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;	// Idek if this works, might be true if its empty o_0
			val = k.GetNum(name, defaultvalue);
		}
		return val;
	}

	public float GetParameterFloat(const char[] name, float defaultvalue = 0.0, bool &found = false)
	{
		float val = defaultvalue;
		KeyValues k = this.GetParameterKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;	// Idek if this works, might be true if its empty o_0
			val = k.GetFloat(name, defaultvalue);
		}
		return val;
	}

	public void GetParameterString(const char[] name, char[] buffer, int len, const char[] defaultvalue = "", bool &found = false)
	{
		KeyValues k = this.GetParameterKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;	// Idek if this works, might be true if its empty o_0
			k.GetString(name, buffer, len, defaultvalue);
		}
	}

	public void GetParameterVector(const char[] name, float vec[3], const float defaultvalue[3] = {0.0, 0.0, 0.0}, bool &found = false)
	{
		KeyValues k = this.GetParameterKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;	// Idek if this works, might be true if its empty o_0
			k.GetVector(name, vec, defaultvalue);
		}
	}

	public void GetParameterColor(const char[] name, int color[4], bool &found = false)
	{
		KeyValues k = this.GetParameterKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;	// Idek if this works, might be true if its empty o_0
			k.GetColor4(name, color);
		}
	}

	public void SetParameterNum(const char[] name, int val)
	{
		KeyValues k = this.GetParameterKv(true);
		if (k != null)
			k.SetNum(name, val);
	}

	public void SetParameterFloat(const char[] name, float val)
	{
		KeyValues k = this.GetParameterKv(true);
		if (k != null)
			k.SetFloat(name, val);
	}

	public void SetParameterString(const char[] name, const char[] buffer)
	{
		KeyValues k = this.GetParameterKv(true);
		if (k != null)
			k.SetString(name, buffer);
	}

	public void SetParameterVector(const char[] name, const float vec[3])
	{
		KeyValues k = this.GetParameterKv(true);
		if (k != null)
			k.SetVector(name, vec);
	}

	public void SetParameterColor(const char[] name, const int color[4])
	{
		KeyValues k = this.GetParameterKv(true);
		if (k != null)
			k.SetColor4(name, color);
	}

	public KeyValues GetPropertyKv(bool create = false)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			if (k.JumpToKey("Properties", create))
				return k;
		return null;
	}

	public int GetPropertyNum(const char[] name, int defaultvalue = 0, bool &found = false)
	{
		int val = defaultvalue;
		KeyValues k = this.GetPropertyKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;
			val = k.GetNum(name, defaultvalue);
		}
		return val;
	}

	public float GetPropertyFloat(const char[] name, float defaultvalue = 0.0, bool &found = false)
	{
		float val = defaultvalue;
		KeyValues k = this.GetPropertyKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;
			val = k.GetFloat(name, defaultvalue);
		}
		return val;
	}

	public void GetPropertyString(const char[] name, char[] buffer, int len, const char[] defaultvalue = "", bool &found = false)
	{
		KeyValues k = this.GetPropertyKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;
			k.GetString(name, buffer, len, defaultvalue);
		}
	}

	public void GetPropertyVector(const char[] name, float vec[3], const float defaultvalue[3] = {0.0, 0.0, 0.0}, bool &found = false)
	{
		KeyValues k = this.GetPropertyKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;
			k.GetVector(name, vec, defaultvalue);
		}
	}

	public void GetPropertyColor(const char[] name, int color[4], bool &found = false)
	{
		KeyValues k = this.GetPropertyKv();
		if (k != null)
		{
			found = k.GetDataType(name) != KvData_None;
			k.GetColor4(name, color);
		}
	}

	public void SetPropertyNum(const char[] name, int val)
	{
		KeyValues k = this.GetPropertyKv(true);
		if (k != null)
			k.SetNum(name, val);
	}

	public void SetPropertyFloat(const char[] name, float val)
	{
		KeyValues k = this.GetPropertyKv(true);
		if (k != null)
			k.SetFloat(name, val);
	}

	public void SetPropertyString(const char[] name, const char[] buffer)
	{
		KeyValues k = this.GetPropertyKv(true);
		if (k != null)
			k.SetString(name, buffer);
	}

	public void SetPropertyVector(const char[] name, const float vec[3])
	{
		KeyValues k = this.GetPropertyKv(true);
		if (k != null)
			k.SetVector(name, vec);
	}

	public void SetPropertyColor(const char[] name, const int color[4])
	{
		KeyValues k = this.GetPropertyKv(true);
		if (k != null)
			k.SetColor4(name, color);
	}

	public void GetName(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Name", buffer, len);
	}

	public void SetName(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Name", name);
	}

	public void GetDescription(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Description", buffer, len);
	}

	public void SetDescription(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Description", name);
	}

	public void GetAnnounceMessage(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Queue_Announce", buffer, len);
	}

	public void SetAnnounceMessage(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Queue_Announce", name);
	}

	public void GetActivationMessage(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Activated", buffer, len);
	}

	public void SetActivationMessage(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Activated", name);
	}

	public void GetActivationCommand(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Execute_Cmd", buffer, len);
	}

	public void SetActivationCommand(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Execute_Cmd", name);
	}

	public void GetEndCommand(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.GetString("Ending_Cmd", buffer, len);
	}

	public void SetEndCommand(const char[] name)
	{
		KeyValues k = this.GetKv();
		if (k != null)
			k.SetString("Ending_Cmd", name);
	}

	public bool IsDisabled()
	{
		return !!this.GetParameterNum("Disabled", 0);
	}

	public void SetDisabled(bool val)
	{
		this.SetParameterNum("Disabled", val);
	}

	public bool IsVIPOnly()
	{
		return !!this.GetParameterNum("IsVIPOnly", 0);
	}

	public void SetVIPOnly(bool val)
	{
		this.SetParameterNum("IsVIPOnly", val);
	}

	public int GetFreedayType()
	{
		return this.GetParameterNum("IsFreedayType", 0);
	}

	public void SetFreedayType(int val)
	{
		this.SetParameterNum("IsFreedayType", val);
	}

	public bool ActiveRound()
	{
		return !!this.GetParameterNum("ActiveRound", 0);
	}

	public void SetActiveRound(bool val)
	{
		this.SetParameterNum("ActiveRound", val);
	}

	public bool OpenCells()
	{
		return !!this.GetParameterNum("OpenCells", 0);
	}

	public void SetOpenCells(bool val)
	{
		this.SetParameterNum("OpenCells", val);
	}

	public bool TimerStatus()
	{
		return !!this.GetParameterNum("TimerStatus", 1);
	}

	public void SetTimerStatus(bool val)
	{
		this.SetParameterNum("TimerStatus", val);
	}

	public bool LockWarden()
	{
		return !!this.GetParameterNum("LockWarden", 0);		// AdminLockWarden
	}

	public void SetLockWarden(bool val)
	{
		this.SetParameterNum("LockWarden", val);
	}

	public bool EnableCriticals()
	{
		return !!this.GetParameterNum("EnableCriticals", 1);
	}

	public bool KillWeapons_Red()
	{
		bool val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("KillWeapons"))
			val = !!k.GetNum("Red", 0);
		return val;
	}

	public bool KillWeapons_Blue()
	{
		bool val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("KillWeapons"))
			val = !!k.GetNum("Blue", 0);
		return val;
	}

	public bool KillWeapons_Warden()
	{
		bool val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("KillWeapons"))
			val = !!k.GetNum("Warden", 0);
		return val;
	}

	public bool KillWeapons_Melee()
	{
		bool val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("KillWeapons"))
			val = !!k.GetNum("Melee", 0);
		return val;
	}

	public bool FriendlyFire()
	{
		bool val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("FriendlyFire"))
			val = !!k.GetNum("Status", 0);
		return val;
	}

	public float FriendlyFire_Timer()
	{
		float val;
		KeyValues k = this.GetParameterKv();
		if (k != null && k.JumpToKey("FriendlyFire"))
			val = k.GetFloat("Timer");
		return val;
	}

	public int UsesPerMap()
	{
		return this.GetParameterNum("UsesPerMap", 3);
	}

	public void SetUsesPerMap(int val)
	{
		this.SetParameterNum("UsesPerMap", val);
	}

	public int TimerTime()
	{
		return this.GetParameterNum("TimerTime", 0);
	}

	public void SetTimerTime(int val)
	{
		this.SetParameterNum("TimerTime", val);
	}

	public bool BalanceTeams()
	{
		return !!this.GetParameterNum("BalanceTeams", 0);
	}

	public void SetBalanceTeams(bool val)
	{
		this.SetParameterNum("BalanceTeams", val);
	}

	public bool IsWarday()
	{
		return !!this.GetParameterNum("IsWarday", 0);
	}

	public void SetWarday(bool val)
	{
		this.SetParameterNum("Warday", val);
	}

	public bool NoMuting()
	{
		return !!this.GetParameterNum("NoMuting", 0);
	}

	public void SetNoMuting(bool val)
	{
		this.SetParameterNum("NoMuting", val);
	}

	public bool DisableMedic()
	{
		return !!this.GetParameterNum("DisableMedic", 0);
	}

	public void SetDisableMedic(bool val)
	{
		this.SetParameterNum("DisableMedic", val);
	}

	public bool AllowBuilding()
	{
		return !!this.GetParameterNum("AllowBuilding", 0);
	}

	public void SetAllowBuilding(bool val)
	{
		this.SetParameterNum("AllowBuilding", val);
	}

	public bool RegenerateReds()
	{
		return !!this.GetParameterNum("RegenerateReds", 0);
	}

	public void SetRegenerateReds(bool val)
	{
		this.SetParameterNum("RegenerateReds", val);
	}

	// Unused
	public int ForceIndex()
	{
		return this.GetParameterNum("ForceIndex", 0x7FFFFFFF);
	}

	public void SetForceIndex(int val)
	{
		this.SetParameterNum("ForceIndex", 0x7FFFFFFF);
	}

	public void GetHudName(char[] buffer, int len)
	{
		this.GetParameterString("HudName", buffer, len);
	}

	public void SetHudName(const char[] buffer)
	{
		this.SetParameterString("HudName", buffer);
	}

	public bool GetMusicStatus()
	{
		bool val;
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music"))
			val = !!k.GetNum("Status", 0);
		return val;
	}

	public void SetMusicStatus(bool val)
	{
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music", true))
			k.SetNum("Status", val);
	}

	public void GetMusicFileName(char[] buffer, int len)
	{
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music"))
			k.GetString("File", buffer, len);
	}

	public void SetMusicFileName(const char[] buffer)
	{
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music", true))
			k.SetString("File", buffer);
	}

	public float GetMusicTime()
	{
		float val;
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music"))
			val = k.GetFloat("Time", -1.0);
		return val;
	}

	public void SetMusicTime(float val)
	{
		KeyValues k = this.GetKv();
		if (k != null && k.JumpToKey("Music"))
			k.SetFloat("Time", 0.0);
	}

	public any GetProp(const char[] key)
	{
		any val; this.GetValue(key, val);
		return val;
	}

	public void SetProp(const char[] key, any val)
	{
		this.SetValue(key, val);
	}

	public float GetPropFloat(const char[] key)
	{
		float val; this.GetValue(key, val);
		return val;
	}

	public void SetPropFloat(const char[] key, float val)
	{
		this.SetValue(key, val);
	}
}