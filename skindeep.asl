state("skindeep") {
	string32 map : 0x010B90E0, 0x490, 0x4;
	float mapTime: 0x01D9C0C0, 0x0, 0x1F4;
}

startup
{
	settings.Add("hubSplit", true, "Don't split when leaving vig_hub");
	settings.Add("ilMode", false, "Start timer when loading into any map (for ILs)");
}

init
{
	vars.loading = false;
	vars.mapRestart = false;

	vars.totalIgt = 0.0;
	vars.preLoadMap = ""; vars.postLoadMap = "";
}

update
{
	vars.subMap = current.map.Substring(1, current.map.IndexOf(".")-1);
	vars.subOld = old.map.Substring(1, current.map.IndexOf(".")-1);

	vars.delta = current.mapTime - old.mapTime;
	vars.dDelta = (double)vars.delta;
	
	// this is kinda #Scuffed but honestly really who cares
	// the float at mapTime jumps up a very large amount during loading screens
	// and then when the load ends it returns to its original value, making the delta negative
	// so this works i guess.
	if(vars.delta > 2)
	{
		vars.preLoadMap = current.map;
		vars.loading = true;
	}
	
	else if (vars.delta < 0)
	{
		vars.postLoadMap = current.map;
		vars.loading = false;
	}
}

split 
{
	if(settings["hubSplit"])
	{
		return current.map != old.map && !vars.subOld.Equals("vig_hub");
	}
	
	else
	{
		return current.map != old.map;
	}
}

start
{
	if(!settings["ilMode"])
	{
		return (current.map != old.map && vars.subMap.Equals("vig_tutorial")) || vars.mapRestart;
	}

	else
	{
		return (current.map != old.map) || vars.mapRestart;
	}

	vars.mapRestart = false;
}

isLoading
{
	return vars.loading || vars.delta == 0;
}

gameTime
{
	// only increment totalIGT if delta isnt going sicko mode due to loads
	// and the game currently isnt loading
	if(vars.delta > 0 && vars.delta < 1 && !vars.loading)
	{
		vars.totalIgt += vars.delta;
	}
	
	return TimeSpan.FromSeconds(vars.totalIgt);
}
