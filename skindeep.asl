state("skindeep") {
	string32 map : 0x010B90E0, 0x490, 0x4;
	float mapTime: 0x01D9C0C0, 0x0, 0x1F4;
}

startup
{
	settings.Add("hubSplit", true, "Don't split when leaving vig_hub");
	settings.Add("ilMode", false, "Start timer when loading into any map (for ILs)");
	settings.Add("restartReset", false, "Reset timer whenever map is restarted");
}

init
{
	vars.loading = false;
	vars.mapRestart = false;

	vars.totalIgt = 0.0;
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
		vars.loading = true;
	}
	
	else if (vars.delta < 0)
	{
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
}

isLoading
{
	return vars.loading;
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

reset
{
	vars.mapRestart = false;
	if(settings["restartReset"])
	{
		if((current.map == old.map) && (current.mapTime - old.mapTime < 0))
		{
			vars.mapRestart = true;
			return true;
		}
	}
}
