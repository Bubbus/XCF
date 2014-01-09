
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()
	
	self.BulletData = {}	
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.ShouldTrace = false
	
	self.Model = "models/missiles/aim54.mdl"
	self:SetModelEasy(self.Model)
	
	self.Inputs = Wire_CreateInputs( self, { "Detonate" } )
	self.Outputs = Wire_CreateOutputs( self, {} )
	
end



function ENT:SpawnFunction( ply, tr, ClassName )

	self.BulletData["BlastRadius"]			= 39.263195040707
	self.BulletData["BoomPower"]			= 1.5974545032828
	self.BulletData["Caliber"]			= 7
	self.BulletData["CasingMass"]			= 3.4457734955399
	self.BulletData["ConeAng"]			= 54.6
	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.00085891013108803
	self.BulletData["FillerMass"]			= 0.96138103448276
	self.BulletData["FillerVol"]			= 844.85
	self.BulletData["FrAera"]			= 38.4846
	self.BulletData["FragMass"]			= 0.0082434772620573
	self.BulletData["FragVel"]			= 73.073728073422
	self.BulletData["Fragments"]			= 418
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["MaxConeAng"]			= 84.294265181837
	self.BulletData["MaxFillerVol"]			= 845.68288990122
	self.BulletData["MaxPen"]			= 55.047634652117
	self.BulletData["MaxProjLength"]			= 35.17
	self.BulletData["MaxPropLength"]			= 10.33
	self.BulletData["MaxTotalLength"]			= 45.5
	self.BulletData["MinConeAng"]			= 0
	self.BulletData["MinFillerVol"]			= 0
	self.BulletData["MinProjLength"]			= 10.5
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 546.00128166432
	self.BulletData["PenAera"]			= 22.258399368422
	self.BulletData["ProjLength"]			= 35.17
	self.BulletData["ProjMass"]			= 4.4806317456344
	self.BulletData["ProjVolume"]			= 1353.503382
	self.BulletData["PropLength"]			= 10.33
	self.BulletData["PropMass"]			= 0.6360734688
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 1751.0493
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 1.532122808214
	self.BulletData["SlugDragCoef"]			= 0.0025091427047692
	self.BulletData["SlugMV"]			= 1762.139633405
	self.BulletData["SlugMass"]			= 0.073477215611663
	self.BulletData["SlugPenAera"]			= 1.6820013680544
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "HE"
	self.BulletData["Id"]			= "8cmB4"



end



function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	if self.Detonated then return HitRes end
	
	local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
	if CanDo == false then return HitRes end
	
	HitRes.Kill = true
	self:Detonate()
	
	return HitRes --This function needs to return HitRes
end



function MakeXCF_Missile(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	if not Owner:CheckLimit("_xcf_missile") then return false end
	
	--print(Id, Data1, Data2)
	local weapon = ACF.Weapons.Guns[Data1]
	if not (weapon and weapon.roundclass and weapon.roundclass == "Rocket") then
		return false, "Can't make a missile with non-rocket round-data!"
	end
	
	local Missile = ents.Create("xcf_missile")
	if not Missile:IsValid() then return false end
	Missile:SetAngles(Angle)
	Missile:SetPos(Pos)
	Missile:Spawn()
	Missile:SetPlayer(Owner)
	Missile.Owner = Owner
	
	Mdl = Mdl or ACF.Weapons.Guns[Id].model
	
	Missile.Id = Id
	Missile:CreateMissile(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)
	
	Owner:AddCount( "_xcf_missile", Missile )
	Owner:AddCleanup( "acfmenu", Missile )
	
	return Missile
end
list.Set( "ACFCvars", "xcf_missile", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "mdl"} )
duplicator.RegisterEntityClass("xcf_missile", MakeXCF_Missile, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10", "Model" )




function ENT:CreateMissile(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	self:SetModelEasy(Mdl)

	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId = Data1		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = Data2		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3--Lenght of propellant
	self.RoundProjectile = Data4--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 )
	self.RoundData6 = ( Data6 or 0 )
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )
	
	local PlayerData = {}
		PlayerData.Id = self.RoundId
		PlayerData.Type = self.RoundType
		PlayerData.PropLength = self.RoundPropellant
		PlayerData.ProjLength = self.RoundProjectile
		PlayerData.Data5 = self.RoundData5
		PlayerData.Data6 = self.RoundData6
		PlayerData.Data7 = self.RoundData7
		PlayerData.Data8 = self.RoundData8
		PlayerData.Data9 = self.RoundData9
		PlayerData.Data10 = self.RoundData10
	
	
	local guntable = ACF.Weapons.Guns
	local gun = guntable[self.RoundId] or {}
	local roundclass = XCF.ProjClasses[gun.roundclass or "Rocket"] or error("Unrecognized projectile class " .. (gun.roundclass or "Rocket") .. "!")
	--print("omg jc a bomb!", roundclass)
	--PrintTable(PlayerData)
	self:SetBulletData(roundclass.GetExpanded(PlayerData))
	
end




function ENT:SetModelEasy(mdl)
	mdl = Model(mdl)
	if not mdl then return false end
	self:SetModel( Model(mdl) )
	self.Model = mdl
	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )     	
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass( 10 ) 
	end 
end




function ENT:SetBulletData(bdata)
	self.BulletData = table.Copy(bdata)
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:SetMass( bdata.ProjMass or bdata.RoundMass or bdata.Mass or 10 ) 
	end
end




local trace = {}
local thinktime = 0.1
function ENT:Think()
 	
	if self.ShouldTrace then
		local pos = self:GetPos()
		trace.start = pos
		trace.endpos = pos + self:GetVelocity() * thinktime
		trace.filter = self

		local res = util.TraceEntity( trace, self ) 
		if res.Hit then
			self:OnTraceContact(res)
		end
	end
	
	self:NextThink(CurTime() + thinktime)
	
	return true
		
end




function ENT:Detonate()
	
	--print("boom2!")
	self.Detonated = true
	self.Entity:Remove()
	
	--print(self.BulletData.Type, ACF.RoundTypes[self.BulletData.Type]["endflight"])
	ACF.RoundTypes[self.BulletData.Type]["endflight"]( -1337, self.BulletData, self:GetPos(), self:GetUp() )
	
	self.BulletData.SimPos = self:GetPos()
	local phys = self:GetPhysicsObject()
	self.BulletData.SimFlight = phys and phys:GetVelocity() or Vector(0, 0, 0.01)
	ACF.RoundTypes[self.BulletData.Type]["endeffect"]( nil, self.BulletData)
	
	--timer.Simple(15, function() if self and self.Entity and IsValid(self.Entity) then self.Entity:Remove() end end)
	--self.Entity:Remove()

end


--local undonked = true
function ENT:OnTraceContact(trace)
	/*
	if undonked then
		print("donk!")
		printByName(trace)
		undonked = false
	end
	//*/
end



function ENT:SetShouldTrace(bool)
	self.ShouldTrace = bool and true
	--print(self.ShouldTrace)
	self:NextThink(CurTime())
end