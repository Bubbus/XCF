


// This is the classname of this type in the shared state.  Make sure the name matches in the client and server files, and is unique.
local classname = "Shell"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]
this.Class = classname

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




local fillerdensity = {}
fillerdensity["SM"] = 2000
fillerdensity["HE"] = 1000
fillerdensity["HP"] = 1
fillerdensity["HEAT"] = 1450
fillerdensity["APHE"] = fillerdensity["HE"]

/**
	Reduce a full bulletinfo table to the minimum data set required to reconstruct that bulletinfo.
	Useful for net transportation, serialization etc
//*/
function this.GetCompact(bullet)
	local hasfiller = fillerdensity[bullet.Type]
	
	if hasfiller then
		hasfiller = bullet.FillerVol or bullet.CavVol or bullet.FillerMass / ACF.HEDensity * fillerdensity[bullet.Type]
	end
	/*
	print("\n\nBEFORE COMPACT:\n")
	printByName(bullet)
	//*/
	local ret = {
		["Id"] 		= bullet.Id,
		["Type"] 	= bullet.Type,
		["PropLength"]	= bullet.PropLength,
		["ProjLength"]	= bullet.ProjLength,
		//TODO: remove this hack when warheads are implemented
		["FillerVol"]	= hasfiller,
		["ConeAng"]		= bullet.ConeAng,
		["Tracer"]		= (bullet.Tracer and bullet.Tracer > 0) and bullet.Tracer or nil,
		["Colour"]		= bullet.Colour or nil,
		
		["Flechettes"]      = bullet.Flechettes,
		["FlechetteSpread"] = bullet.FlechetteSpread,
		
		["Pos"]			= bullet.Pos,
		["Flight"]		= bullet.Flight,
		
		["ProjClass"]	= "Shell"
	}
	
	/*
	print("\n\nAFTER COMPACT:\n")
	printByName(ret)
	printByName(ret.Colour or {255, 255, 255})
	//*/
	return ret
end


/*
	
//*/
function this.GetExpanded(bullet)

	/*
	print("\n\nBEFORE EXPAND:\n")
	printByName(bullet)
	//*/

	local toconvert = {}
	toconvert["Id"] = 			bullet["Id"] or "12.7mmMG"
	toconvert["Type"] = 		bullet["Type"] or "AP"
	toconvert["PropLength"] = 	bullet["PropLength"] or 0
	toconvert["ProjLength"] = 	bullet["ProjLength"] or 0
	toconvert["Data5"] = 		bullet["FillerVol"] or bullet["Flechettes"] or bullet["Data5"] or 0
	toconvert["Data6"] = 		bullet["ConeAng"] or bullet["FlechetteSpread"] or bullet["Data6"] or 0
	toconvert["Data7"] = 		bullet["Data7"] or 0
	toconvert["Data8"] = 		bullet["Data8"] or 0
	toconvert["Data9"] = 		bullet["Data9"] or 0
	toconvert["Data10"] = 		bullet["Tracer"] or bullet["Data10"] or 0
	toconvert["Colour"] = 		bullet["Colour"] or Color(255, 255, 255)
		
	/*
	print("\n\nTO EXPAND:\n")
	printByName(toconvert)
	//*/
		
	local rounddef = ACF.RoundTypes[bullet.Type] or error("No definition for the shell-type", bullet.Type)
	local conversion = rounddef.convert
	--print("rdcv", rounddef, conversion)
	
	if not conversion then error("No conversion available for this shell!") end
	local ret = conversion( nil, toconvert )
	
	ret.ProjClass = this
	
	ret.Pos = bullet.Pos or Vector(0,0,0)
	ret.Flight = bullet.Flight or Vector(0,0,0)
	ret.Type = ret.Type or bullet.Type
	
	local cvarGrav = GetConVar("sv_gravity")
	ret.Accel = Vector(0,0,cvarGrav:GetInt()*-1)
	if ret.Tracer == 0 and bullet["Tracer"] and bullet["Tracer"] > 0 then ret.Tracer = bullet["Tracer"] end
	ret.Colour = toconvert["Colour"]
	/*
	print("\n\nAFTER EXPAND:\n")
	printByName(ret)
	//*/
	
	return ret

end
