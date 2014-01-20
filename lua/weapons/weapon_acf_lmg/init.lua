
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false




local LOW_AMMO_COL = Color(255, 100, 0)
function SWEP:BeforeFire()
	local clip1 = self:Clip1()
	if clip1 <= 10 then
		self.BulletData["Tracer"] = 2.5
		self.BulletData["Colour"] = LOW_AMMO_COL
	elseif clip1 % 3 == 0 then
		self.BulletData["Tracer"] = 2.5
		self.BulletData["Colour"] = nil
	else
		self.BulletData["Tracer"] = 0
		self.BulletData["Colour"] = nil
	end
end