


// This is the classname of this type in the shared state.  Make sure the name matches in the client and server files, and is unique.
local classname = "Rocket"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




local fillerdensity = {}
fillerdensity["SM"] = 2000
fillerdensity["HE"] = 1000
fillerdensity["HP"] = 1
fillerdensity["HEAT"] = fillerdensity["HE"]
fillerdensity["APHE"] = fillerdensity["HE"]

/**
	Reduce a full rocketinfo table to the minimum data set required to reconstruct that rocketinfo.
	Useful for net transportation, serialization etc
//*/
function this.GetCompact(rocket)
	local hasfiller = fillerdensity[rocket.Type]
	
	if hasfiller then
		hasfiller = rocket.FillerVol or rocket.CavVol or rocket.FillerMass / ACF.HEDensity * fillerdensity[rocket.Type]
	end
	
	return
	{
		["Id"] 		= rocket.Id,
		["Type"] 	= rocket.Type,
		["PropLength"]	= rocket.PropLength,
		["ProjLength"]	= rocket.ProjLength,
		//TODO: remove this hack when warheads are implemented
		["FillerVol"]	= hasfiller,
		["ConeAng"]		= rocket.ConeAng,
		
		["Pos"]			= rocket.Pos,
		["Flight"]		= rocket.Flight,
		["Seed"]		= rocket.Seed,
		
		["ProjClass"]	= "Rocket"
	}
end




function this.GetExpanded(rocket)

	//printByName(rocket)
	
	local input = {}
	local input2 = rocket
		input["Id"] = 			input2["Id"] or "85mmRK"
		input["Type"] = 		input2["Type"] or "AP"
		input["PropLength"] = 	input2["PropLength"] or 0
		input["ProjLength"] = 	input2["ProjLength"] or 0
		input["Data5"] = 		input2["FillerVol"] or 0
		input["Data6"] = 		input2["ConeAng"] or 0
		input["Data7"] = 		0
		input["Data8"] = 		0
		input["Data9"] = 		0
		input["Data10"] = 		input2["Tracer"] or 0

	local ret = XCF_GenerateMissileInfo( input, true )
	
	ret.ProjClass = this
	
	ret.Pos = rocket.Pos or Vector(0,0,0)
	ret.Flight = rocket.Flight or Vector(0,0,0)
	ret.Type = ret.Type or rocket.Type
	
	local cvarGrav = GetConVar("sv_gravity")
	ret.Accel = Vector(0,0,cvarGrav:GetInt()*-1)
	
	return ret

end




/*
	For the rocket drifting, we need a source of time-dependent pseudorandomness which can be replicated on the client and server for non-matching timesteps.
	I'm working on it.
//*/
function this.pseudorandom(seed)
	
	// some implementations give shitty numbers the first few times.
	math.randomseed(seed)
	math.random()
	math.random()
	math.random()
	
	local sin = math.sin
	local cos = math.cos
	local b = 2  + math.random() * 3
	local c = 10 + math.random() * 20
	local d = 1  + math.random()
	local f = 15 + math.random() * 15
	// it's just a compound sine wave.
	return function(x)
		return Vector(	sin(b * sin(x) * x) * sin(c * x + d * sin(f * x)), 
						cos(c * cos(x + b) * x) * cos(b * x + d * cos(f * x)),
						cos(b * sin(x + c) * x) * cos(b * x + d * sin(f * x)))
	end
	
end

