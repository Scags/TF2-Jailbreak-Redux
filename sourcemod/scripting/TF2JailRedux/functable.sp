// Cheating the system
//enum struct FuncWrapper
//{
//	Function funcs[JBFWD_LENGTH];
//}

// Store the positions of each callback index
// This is because SourceMod's DataPack system breaks every 20 seconds, and 
// setting the position manually/statically will eventually break and that would make people sad
// Thanks asherkin for the idea \o/
static DataPackPos
	g_PackPos[JBFWD_LENGTH]
;

methodmap FuncTable < DataPack
{
	/*
		Probably why forcing Function types into cells isn't supported, but 
		I kept getting garbage values as parameters when Call_StartFunction'ing
		hooked function callbacks. So, using a datapack as a function holder
		to store function pointers (the supported way) is the best route.
		Function byte size will change one fateful day but this is still the
		only way for now.
	*/
	public FuncTable(int size)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(size);
		for (int i = 0; i < size; ++i)
		{
			g_PackPos[i] = pack.Position;	// This resets every time but it doesn't really matter
			pack.WriteFunction(INVALID_FUNCTION);
		}
		return view_as< FuncTable >(pack);
	}

	property int Size
	{
		public get()
		{
			this.Reset();
			return this.ReadCell();
		}
	}

	public Function GetFunction(const int idx)
	{
		this.Position = g_PackPos[idx];
		return this.IsReadable() ? this.ReadFunction() : INVALID_FUNCTION;
	}

	public void SetFunction(Function func, const int idx)
	{
		this.Position = g_PackPos[idx];
		this.WriteFunction(func);
	}

	public bool StartFunction(Handle hndl, const int idx)
	{
		Function f = this.GetFunction(idx);
		if (f != INVALID_FUNCTION)
		{
			Call_StartFunction(hndl, f);
			return true;
		}
		return false;
	}

	public void Refresh()
	{
		int size = this.Size;
		for (int i = 0; i < size; ++i)
			this.WriteFunction(INVALID_FUNCTION);
	}

	public void ToArray(Function[] funcs)
	{
		int size = this.Size;
		for (int i = 0; i < size; ++i)
			funcs[i] = this.ReadFunction();
	}
};