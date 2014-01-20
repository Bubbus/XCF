
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



local MIN_DONK_DELAY = 0.2
local MIN_DONK_VEL = 50
function SWEP.grenadeDonk(nade)

	local phys = nade:GetPhysicsObject()
	if not phys then return end
	
	local vel = phys:GetVelocity():Length()
	if vel < MIN_DONK_VEL then return end
	
	local curtime = CurTime()
	if not nade.lastDonk or nade.lastDonk < curtime - MIN_DONK_DELAY then	
		local decibels 	= math.Clamp(vel / 3, 30, 70) + math.random()*5
		local pitch 	= math.Clamp(vel / 5, 80, 110) + math.random()*15
		sound.Play( "weapons/smokegrenade/grenade_hit1.wav", nade:GetPos(), decibels, pitch, 1 )
		nade.lastDonk = curtime
	end
end




function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		bomb:Detonate()
	end
end




function SWEP.grenadeTraceHit(bomb, trace)
	if not trace.HitWorld and IsValid(trace.Entity) then
		local setpos = trace.HitPos - (trace.HitPos - trace.StartPos):GetNormalized() * (bomb:BoundingRadius() * 1.1)
		
		--debugoverlay.Sphere( setpos, bomb:BoundingRadius(), 10, Color(255, 0, 0), true )
		--debugoverlay.Cross( trace.HitPos, 10, 10, Color(0, 255, 0), true )
		
		bomb:SetPos(setpos)
		bomb.grenadeExplode(bomb)
	end
end




function SWEP:FireBullet()

	self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	self.BulletData.ProjClass = XCF.ProjClasses.Bomb or error("Could not find the Bomb projectile type!")
	
	local flight = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
	local throwmod = math.Clamp((self.PressedDuration or self.ChargeTime) / self.ChargeTime, 0.33, 1) * 1.5
	self.BulletData["Flight"] = flight * throwmod
	
	local bomb = ents.Create("xcf_bomb")
	bomb:SetPos(MuzzlePos2)
	bomb:SetOwner(self.Owner)
	bomb:Spawn()
	bomb:SetModelEasy(self.ThrowModel)
	bomb:SetBulletData(self.BulletData)
	local expfunc = self.grenadeExplode
	bomb.grenadeExplode = expfunc
	timer.Simple(5, function() expfunc(bomb) end)
	
	
	bomb:SetShouldTrace(true)
	bomb.OnTraceContact = self.grenadeTraceHit
	
	constraint.NoCollide(bomb, self.Owner)
	local phys = bomb:GetPhysicsObject()
	if phys then
		phys:SetVelocityInstantaneous(self.BulletData["Flight"])
		local angvel = self.Owner:LocalToWorld(Vector(400 + math.random()*300, 1000 + math.random()*1000, 40 + math.random()*30)) - self.Owner:GetPos()
		phys:AddAngleVelocity( angvel * throwmod)
		bomb.PhysicsCollide = self.grenadeDonk
	end
	
	
	local owner = self.Owner
	timer.Simple(self.Primary.Delay or 3, function()
			local wep = owner:GetActiveWeapon()
			wep:SendWeaponAnim(ACT_VM_DRAW)
			if owner:GetAmmoCount( self.Primary.Ammo ) <= 0 and wep.GrenadeRemove then
				self.Weapon:Remove()
				owner:ConCommand("lastinv")
			end
		end)
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end