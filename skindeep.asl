state("skindeep") {
	string32 map : 0x00BF3998, 0x0;
	float mapTime: 0x00BD7DE0, 0x18;
}

startup
{
	settings.Add("hubSplit", true, "Don't split when leaving vig_hub");
	settings.Add("ilMode", false, "Start timer when loading into any map");
	settings.Add("resetMode", false, "Reset timer when restarting map");
}

init
{
	vars.loading = false;
	vars.loadTimeDiff = 1.0;
	
	vars.pauseTime = 0.0;
	// total IGT of the current level
	vars.totalIgt = 0.0;
	// total IGT across the whole run
	vars.totalGameIgt = 0.0;

	vars.preLoadMap = ""; vars.onReload = false;
	vars.resetting = false;
}

update
{
	vars.subMap = current.map.Substring(0);
	vars.subOld = old.map.Substring(0);

	vars.delta = current.mapTime - old.mapTime;
	
	// this is kinda #Scuffed but honestly really who cares
	// the float at mapTime jumps up a very large amount during loading screens
	// and then when the load ends it returns to its original value, making the delta negative
	// so this works i guess.
	// i also did a bunch of other stuff to it to ensure the timer doesn't flicker during loads so its a fucking Mess now
	if(vars.delta > 2)
	{
		vars.loadTimeDiff = current.mapTime;
	} 
	else if (vars.delta > 0 && current.mapTime < vars.loadTimeDiff && current.mapTime > 0.1)
	{
		vars.pauseTime = current.mapTime;
		vars.preLoadMap = current.map;
	}

	if(vars.delta > 2 || vars.delta < 0)
	{
		vars.loading = true;
	} else { vars.loading = false;}
	
	if (current.mapTime - vars.pauseTime > 0 && current.mapTime - vars.pauseTime < 2 )
	{
		vars.loading = false;
	}

	// stuff to do as soon as loading back in
	if(vars.loading == false && vars.onReload == false && current.mapTime > 0.1 && current.mapTime == vars.pauseTime)
	{
		//lol what is this
		if(vars.preLoadMap == current.map && current.mapTime < 0.5 && vars.totalIgt < vars.loadTimeDiff) // && !settings["hubSplit"]
		{
			if(!settings["resetMode"] && vars.subMap != "vig_tutorial")
			{vars.totalGameIgt += vars.totalIgt;}
			vars.totalIgt = 0.0;
		}

		vars.onReload = true;
	}
}

split 
{
	// TODO: Fix time being added to split twice? Might be related to the update() method
	if(settings["hubSplit"] && current.map != old.map)
	{
		vars.totalGameIgt += vars.totalIgt;
		vars.preLoadIgt = 0;
		vars.totalIgt = 0;

		if(!vars.subOld.Equals("vig_hub"))
		{return true;}
	}
	
	else if (!settings["hubSplit"] && current.map != old.map)
	{
		vars.totalGameIgt += vars.totalIgt;
		vars.preLoadIgt = 0;
		vars.totalIgt = 0;
		return true;
	}
}

// don't feel like formatting this better
start
{
	if(!settings["ilMode"])
	{
		if ((current.map != old.map && vars.subMap.Equals("vig_tutorial")))
		{
			vars.loadTimeDiff = 0.0;
			vars.totalIgt = 0.0;
			vars.totalGameIgt = 0.0;
			vars.preLoadIgt = 0.0;
			vars.pauseTime = 0.0;
			return true;
		}
	}

	else
	{
		if ((current.map != old.map))
		{
			vars.loadTimeDiff = 0.0;
			vars.totalIgt = 0.0;
			vars.totalGameIgt = 0.0;
			vars.preLoadIgt = 0.0;
			vars.pauseTime = 0.0;
			return true;
		}
	}
}

isLoading
{
	if(vars.loading){ vars.onReload = false;}
	return vars.loading || vars.delta == 0;
}

gameTime
{
	vars.igtDiff = (current.mapTime) - vars.totalIgt;

	//grrrrrrrrrrrrr
	if(!vars.loading && (vars.igtDiff > -1) && (vars.igtDiff < 5) && ((vars.igtDiff < 1) || current.mapTime < vars.loadTimeDiff))
	{
		//print(current.mapTime.ToString() + " " + vars.loadTimeDiff.ToString());
		vars.totalIgt = current.mapTime;
	}
	return TimeSpan.FromSeconds(vars.totalIgt + vars.totalGameIgt);
}
