public void ManageTargetFilters(const KeyValues kv)
{
	StringMapSnapshot snap = gamemode.hTargetFilters.Snapshot();

	if (snap)
	{
		char buffer[32];
		for (int i = 0; i < snap.Length; ++i)
		{
			snap.GetKey(i, buffer, sizeof(buffer));
			Format(buffer, sizeof(buffer), "@%s", buffer);
			RemoveMultiTargetFilter(buffer, CustomFilterGroup);
			Format(buffer, sizeof(buffer), "@!%s", buffer[1]);
			RemoveMultiTargetFilter(buffer, CustomFilterGroup);
		}
		delete snap;
	}
	gamemode.hTargetFilters.Clear();

	if (kv.JumpToKey("Target Filters") && kv.GotoFirstSubKey(false))
	{
		TargetFilter filter;
		do
		{
			kv.GetSectionName(filter.strName, sizeof(filter.strName));
			kv.GetString("Description_All", filter.strDescriptA, sizeof(filter.strDescriptA));
			kv.GetString("Description_None", filter.strDescriptN, sizeof(filter.strDescriptN));

			filter.bML = !!kv.GetNum("Description_ML");
			filter.vecLoc[0] = kv.GetFloat("Coordinate_X");
			filter.vecLoc[1] = kv.GetFloat("Coordinate_Y");
			filter.vecLoc[2] = kv.GetFloat("Coordinate_Z");
			filter.flDist = kv.GetFloat("Distance");

			if (gamemode.hTargetFilters.SetArray(filter.strName, filter, sizeof(TargetFilter), false))
			{
				char buffer[32];
				Format(buffer, sizeof(buffer), "@%s", filter.strName);
				AddMultiTargetFilter(buffer, CustomFilterGroup, filter.strDescriptA, filter.bML);
				Format(buffer, sizeof(filter.strName), "@!%s", filter.strName);
				AddMultiTargetFilter(buffer, CustomFilterGroup, filter.strDescriptN, filter.bML);
			}
		} while kv.GotoNextKey(false);
	}
}

public bool WardenGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		bool non = pattern[1] == '!';

		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if (clients.FindValue(i) != -1)
				continue;

			if (!non && JailFighter(i).bIsWarden) 
				clients.Push(i);
			else if (non)
				clients.Push(i);
		}
	}
	return true;
}

public bool FreedaysGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		bool non = pattern[1] == '!';

		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if (clients.FindValue(i) != -1)
				continue;

			if (!non && JailFighter(i).bIsFreeday) 
				clients.Push(i);
			else if (non)
				clients.Push(i);
		}
	}
	return true;
}

public bool RebelsGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		bool non = pattern[1] == '!';

		for (int i = MaxClients; i; --i) 
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if (clients.FindValue(i) != -1)
				continue;

			if (!non && JailFighter(i).bIsRebel) 
				clients.Push(i);
			else if (non)
				clients.Push(i);
		}
	}
	return true;
}

public bool FreedayLocGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
		return CalcLocGroup(FREEDAY, pattern[1] == '!', clients);
	return true;
}

public bool WardayRedLocGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
		return CalcLocGroup(WRED, pattern[1] == '!', clients);
	return true;
}

public bool WardayBluLocGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
		return CalcLocGroup(WBLU, pattern[1] == '!', clients);
	return true;
}

public bool WardayAnyLocGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		float vec[3], vec2[3], dist;
		int i;
		bool non = pattern[1] == '!';

		if (gamemode.GetTelePosition(WRED, vec))
		{
			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (clients.FindValue(i) != -1)
					continue;

				GetClientAbsOrigin(i, vec2);
				dist = GetVectorDistance(vec, vec2);

				if (!non && dist < cvarTF2Jail[LocDistance].FloatValue)
					clients.Push(i);
				else if (non)
					clients.Push(i);
			}
		}

		if (gamemode.GetTelePosition(WBLU, vec))
		{
			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (clients.FindValue(i) != -1)
					continue;

				GetClientAbsOrigin(i, vec2);
				dist = GetVectorDistance(vec, vec2);

				if (!non && dist < cvarTF2Jail[LocDistance].FloatValue)
					clients.Push(i);
				else if (non)
					clients.Push(i);
			}
		}
	}
	return true;
}

public bool MedicLocGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "trigger_hurt")) != -1)
		{
			if (GetEntPropFloat(ent, Prop_Data, "m_flDamage") > 0)
				continue;

			float vec[3], vec2[3], dist;
			bool non = pattern[1] == '!';

			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vec);

			for (int i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (clients.FindValue(i) != -1)
					continue;

				GetClientAbsOrigin(i, vec2);
				dist = GetVectorDistance(vec, vec2);

				if (!non && dist < cvarTF2Jail[LocDistance].FloatValue)
					clients.Push(i);
				else if (non)
					clients.Push(i);
			}
			break;
		}
	}
	return true;
}

public bool CalcLocGroup(const int type, const bool non, ArrayList &clients)
{
	float vec[3];
	if (!gamemode.GetTelePosition(type, vec))
		return false;

	float vec2[3], dist;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (clients.FindValue(i) != -1)
			continue;

		GetClientAbsOrigin(i, vec2);
		dist = GetVectorDistance(vec, vec2);

		if (!non && dist < cvarTF2Jail[LocDistance].FloatValue)
			clients.Push(i);
		else if (non)
			clients.Push(i);
	}
	return true;
}

public bool CustomFilterGroup(const char[] pattern, ArrayList clients)
{
	if (bEnabled.BoolValue)
	{
		TargetFilter filter;
		int offset = pattern[1] == '!' ? 2 : 1;

		char buffer[32];
		//Format(buffer, sizeof(buffer), "@%s", pattern[offset]);
		strcopy(buffer, sizeof(buffer), pattern[offset]);

		if (!gamemode.hTargetFilters.GetArray(buffer, filter, sizeof(TargetFilter)))	// Shouldn't happen
			return false;

		int i;
		float vec[3], dist;

		for (i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if (clients.FindValue(i) != -1)
				continue;

			GetClientAbsOrigin(i, vec);
			dist = GetVectorDistance(filter.vecLoc, vec);

			if (offset == 1 && dist < filter.flDist)
				clients.Push(i);
			else if (offset == 2)
				clients.Push(i);
		}
	}
	return true;
}