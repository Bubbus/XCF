
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	if IsValid(self:GetParent()) then
		self.Owner = self:GetParent()
		self:SetOwner(self:GetParent())
	end
	self:InitBulletData()
	self:UpdateFakeCrate()
	
	if SERVER and self.BulletData.IsShortForm and not self.IsGrenadeWeapon then
		//print("expand dong")
		self.BulletData = ACF_ExpandBulletData(self.BulletData)
	end
	
	if SERVER then
		self.BulletData.OnEndFlight = self.CallbackEndFlight
	end
end




function SWEP:UpdateFakeCrate(realcrate)

	if not IsValid(self.FakeCrate) then
		self.FakeCrate = ents.Create("acf_fakecrate")
	end

	self.FakeCrate:RegisterTo(self)
	
	self.BulletData["Crate"] = self.FakeCrate:EntIndex()
	self:SetNWString( "Sound", self.Primary.Sound )
end




function SWEP:OnRemove()

	if not IsValid(self.FakeCrate) then return end
	
	local crate = self.FakeCrate
	timer.Simple(15, function() if IsValid(crate) then crate:Remove() end end)

end




local nosplode = {AP = true, HP = true}
local nopen = {HE = true, SM = true}
function SWEP:DoAmmoStatDisplay()

	local bdata = self.BulletData

	if bdata.IsShortForm then
		bdata = ACF_ExpandBulletData(table.Copy(bdata))
	end

	local bType = bdata.Type
	local sendInfo = string.format( "%smm %s ammo: %im/s speed",
									tostring(bdata.Caliber * 10),
									bType,
									self.ThrowVel or bdata.MuzzleVel
								  )
	
	if not nopen[bType] then
		local maxpen = bdata.MaxPen or (ACF_Kinetic(
														(bdata.SlugMV or bdata.MuzzleVel)*39.37,
														(bdata.SlugMass or bdata.ProjMass),
														bdata.SlugMV and 999999 or bdata.LimitVel or 900
													  ).Penetration / (bdata.SlugPenAera or bdata.PenAera) * ACF.KEtoRHA
												 )
	
		sendInfo = sendInfo .. string.format( 	", %.1fmm pen",
												maxpen
											)
	end

	if not nosplode[bType] then
		sendInfo = sendInfo .. string.format( 	", %.1fm blast",
												(bdata.BlastRadius or (((bdata.FillerMass or 0) / 2) ^ 0.33 * 5 * 10 )) * 0.2
											)
	end
	
	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end




function SWEP:Deploy()
	self:DoAmmoStatDisplay()
end




function SWEP:FireBullet()

	--self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()	
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Flight"] = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity() + MuzzleVecFinal * 16
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	local filter = self.BulletData["Filter"] or {}
	filter[#filter + 1] = self.Owner
	filter[#filter + 1] = self.Owner:GetVehicle() or nil
	self.BulletData["Filter"] = filter
	
	if self.BeforeFire then
		self:BeforeFire()
	end
	
	ACF_CreateBulletSWEP(self.BulletData, self, ACF.SWEP.LagComp or false)
	
	self:MuzzleEffect( MuzzlePos2, MuzzleVec, true )
	
	--self.Owner:LagCompensation( false )
	
end



/*
local FlashID = "XCF_SWEPMuzzle"
util.AddNetworkString(FlashID)
//*/
function SWEP:MuzzleEffect( MuzzlePos, MuzzleDir, realcall )
	/*
	net.Start(FlashID)
		net.WriteEntity(self)
		net.WriteFloat(self.BulletData["PropMass"] or 1)
		net.WriteInt(ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1, 8)
	net.SendPVS(MuzzlePos)
	net.SendPAS(MuzzlePos)
	//*/
	//*
	if CLIENT or not realcall then return end
	
	/*
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData.PropMass or 1 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData.Type].netid or 1 )	--Encoding the ammo type into a table index
	util.Effect( "ACF_SWEPMuzzleFlash", Effect, true, true )
	//*/
	//*/
end




function SWEP.CallbackEndFlight(index, bullet, trace)
	if not (ACF.SWEP.AlwaysDust or (bullet.Gun and bullet.Gun.AlwaysDust)) then return end
	if not trace.Hit then return end
	
	local pos = trace.HitPos
	local dir = (pos - trace.StartPos):GetNormalized()
	
	local Effect = EffectData()
		if bullet.Gun then
			Effect:SetEntity(bullet.Gun)
		end
		
		Effect:SetOrigin(pos - trace.Normal)
		Effect:SetNormal(dir)
		Effect:SetRadius((bullet.ProjMass * (bullet.Flight:Length() / 39.37)) / 10) // ditched realism for more readability at range
	util.Effect( "acf_sniperimpact", Effect, true, true)
end
