

/**
	Creates and returns a clientside effect.
	Credit to Silverlan @ FP for the approach and code;
		http://facepunch.com/showthread.php?t=1251520&p=39805135&viewfull=1#post39805135
		
	Args;
		name	String
			The effect's classname
		date	CEffectData
			The effectdata to init the effect with.
	Return;	CLuaEffect
		The created effect
//*/

local req = false
local effect
function XCF.ClientsideEffect(name, data)
    req = true
    util.Effect(name, data)
    req = false
    local ent = effect
    effect = nil
    return ent
end
 
hook.Add("OnEntityCreated","XCF_CLuaEffect",function(ent)
    if(req) then effect = ent end
end)




local function recvSmokeWind(len)
	XCF.SmokeWind = net.ReadFloat()
end
net.Receive("xcf_smokewind", recvSmokeWind)




local function recvSWEPMuzzle(len)
	local ent = net.ReadEntity()
	local prop = net.ReadFloat()
	local type = net.ReadInt(8)
	
	local lply = LocalPlayer()
	if not (IsValid(lply) and IsValid(ent)) then return end
	if ent.Owner and ent.Owner == lply or ent:GetOwner() == lply then return end
	
	local Effect = EffectData()
		Effect:SetEntity( ent )
		Effect:SetScale( prop )
		Effect:SetMagnitude( 1 )
		Effect:SetSurfaceProp( type )	--Encoding the ammo type into a table index
	util.Effect( "XCF_SWEPMuzzleFlash", Effect, true)
end
net.Receive("XCF_SWEPMuzzle", recvSWEPMuzzle)


