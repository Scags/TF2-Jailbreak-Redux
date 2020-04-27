// These are all completely managed in the core, but they're included here just in case

static LastRequest g_FreedaySelf, g_FreedayOther, g_FreedayAll;

public void Freedays_Init()
{
	g_FreedaySelf = LastRequest.CreateFromConfig("Freeday for Yourself");
	g_FreedayOther = LastRequest.CreateFromConfig("Freeday for Others");
	g_FreedayAll = LastRequest.CreateFromConfig("Freeday for All");
}

public void Freedays_Destroy()
{
	if (g_FreedaySelf != null)
		g_FreedaySelf.Destroy();
	if (g_FreedayOther != null)
		g_FreedayOther.Destroy();
	if (g_FreedayAll != null)
		g_FreedayAll.Destroy();
}
