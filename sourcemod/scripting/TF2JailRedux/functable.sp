// Cheating the system
//enum struct FuncWrapper
//{
//	Function funcs[JBFWD_LENGTH];
//}

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
			pack.WriteFunction(INVALID_FUNCTION);
		return view_as< FuncTable >(pack);
	}

	property int Size
	{
		public get()
		{
			this.Position = view_as< DataPackPos >(0);
			return this.ReadCell();
		}
	}

	public Function GetFunction(const int idx)
	{
		this.Position = view_as< DataPackPos >(idx + 1);
		return this.IsReadable() ? this.ReadFunction() : INVALID_FUNCTION;
	}

	public void SetFunction(Function func, const int idx)
	{
		this.Position = view_as< DataPackPos >(idx + 1);
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