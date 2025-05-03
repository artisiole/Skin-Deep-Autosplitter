state("skindeep") {
	string32 map : 0x010B90E0, 0x490, 0x4;
	float mapTime: 0x01D9C0C0, 0x0, 0x1F4;
}

startup
{
	settings.Add("hubSplit", true, "Don't split when returning to vig_hub");
	settings.Add("ilMode", false, "Start timer when loading into any map (for ILs)");
	settings.Add("restartReset", false, "Reset timer whenever map is restarted");
}

init
{
	vars.loading = false;
}

update
{
	vars.subMap = current.map.Substring(1, current.map.IndexOf(".")-1);
	vars.subOld = old.map.Substring(1, current.map.IndexOf(".")-1);
	
	// this is #Scuffed but really who cares
	if(current.mapTime - old.mapTime > 5)
	{
		vars.loading = true;
	}
	
	else if (current.mapTime - old.mapTime < 0)
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
	return current.map != old.map && vars.subMap.Equals("vig_tutorial");
}

isLoading
{
	return (current.mapTime == old.mapTime) || vars.loading;
}