
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
	
	--self.ACF_HEIgnore = true
	
end



function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	if self.Detonated then return HitRes end
	
	local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
	if CanDo == false then return HitRes end
	
	HitRes.Kill = false
	self:Detonate()
	
	return HitRes --This function needs to return HitRes
end




function ENT:TriggerInput( inp, value )
	if inp == "Detonate" and value ~= 0 then
		self:Detonate()
	end
end




function MakeXCF_Bomb(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	--print(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	if not Owner:CheckLimit("_xcf_bomb") then return false end
	
	--print(Id, Data1, Data2)
	local weapon = ACF.Weapons.Guns[Data1]
	---[[
	if not (weapon and weapon.roundclass and weapon.roundclass == "Bomb") then
		return false, "Can't make a bomb with non-bomb round-data!"
	end
	--]]--
	
	local Bomb = ents.Create("xcf_bomb")
	if not Bomb:IsValid() then return false end
	Bomb:SetAngles(Angle)
	Bomb:SetPos(Pos)
	Bomb:Spawn()
	Bomb:SetPlayer(Owner)
	Bomb.Owner = Owner
	
	Mdl = Mdl or ACF.Weapons.Guns[Id].model
	
	Bomb.Id = Id
	Bomb:CreateBomb(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)
	
	Owner:AddCount( "_xcf_bomb", Bomb )
	Owner:AddCleanup( "acfmenu", Bomb )
	
	return Bomb
end
list.Set( "ACFCvars", "xcf_bomb", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "mdl"} )
duplicator.RegisterEntityClass("xcf_bomb", MakeXCF_Bomb, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10", "Model" )




function ENT:CreateBomb(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

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
	local roundclass = XCF.ProjClasses[gun.roundclass or "Bomb"] or error("Unrecognized projectile class " .. (gun.roundclass or "Bomb") .. "!")
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
	self.BulletData.Entity = self
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
	
	if self.Detonated then return end
	
	--print("boom2!")
	self.Detonated = true
	
	--print(self.BulletData.Type, ACF.RoundTypes[self.BulletData.Type]["endflight"])
	ACF.RoundTypes[self.BulletData.Type]["endflight"]( -1337, self.BulletData, self:GetPos(), self:GetUp() )
	
	self.BulletData.SimPos = self:GetPos()
	local phys = self:GetPhysicsObject()
	self.BulletData.SimFlight = phys and phys:GetVelocity() or Vector(0, 0, 0.01)
	ACF.RoundTypes[self.BulletData.Type]["endeffect"]( nil, self.BulletData)
	
	self.Entity:Remove()
	
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




function ENT:EnableClientInfo(bool)
	self.ClientInfo = bool
	self:SetNetworkedBool("VisInfo", bool)
	
	if bool then
		self:RefreshClientInfo()
	end
end



function ENT:RefreshClientInfo()
	self:SetNetworkedString("RoundId", self.RoundId)
	self:SetNetworkedString("RoundType", self.RoundType)
	self:SetNetworkedFloat("FillerVol", self.RoundData5)
end