
AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Ammo Crate"
ENT.WireDebugName = "ACF Ammo Crate"

if CLIENT then
	
	--[[-------------------------------------
	Shamefully stolen from lua rollercoaster. I'M SO SORRY. I HAD TO.
	-------------------------------------]]--

	local function Bezier( a, b, c, d, t )
		local ab,bc,cd,abbc,bccd 
		
		ab = LerpVector(t, a, b)
		bc = LerpVector(t, b, c)
		cd = LerpVector(t, c, d)
		abbc = LerpVector(t, ab, bc)
		bccd = LerpVector(t, bc, cd)
		dest = LerpVector(t, abbc, bccd)
		
		return dest
	end


	local function BezPoint(perc, Table)
		perc = perc or self.Perc
		
		local vec = Vector(0, 0, 0)
		
		vec = Bezier(Table[1], Table[2], Table[3], Table[4], perc)
		
		return vec
	end
	
	function ACF_DrawRefillAmmo( Table )
		for k,v in pairs( Table ) do
			local St, En = v.EntFrom:LocalToWorld(v.EntFrom:OBBCenter()), v.EntTo:LocalToWorld(v.EntTo:OBBCenter())
			local Distance = (En - St):Length()
			local Amount = math.Clamp((Distance/50),2,100)
			local Time = (SysTime() - v.StTime)
			local En2, St2 = En + Vector(0,0,100), St + ((En-St):GetNormalized() * 10)
			local vectab = { St, St2, En2, En}
			local center = (St+En)/2
			for I = 1, Amount do
				local point = BezPoint(((((I+Time)%Amount))/Amount), vectab)
				local ang = (point - center):Angle()
				local MdlTbl = {
					model = v.Model,
					pos = point,
					angle = ang
				}
				render.Model( MdlTbl )
			end
		end
	end

	function ENT:Draw()
		
		self.BaseClass.Draw( self )
		
		if self.RefillAmmoEffect then
			ACF_DrawRefillAmmo( self.RefillAmmoEffect )
		end
		
	end
	
	usermessage.Hook("ACF_RefillEffect", function( msg )
		local EntFrom, EntTo, Weapon = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() ), msg:ReadString()
		if not IsValid( EntFrom ) or not IsValid( EntTo ) then return end
		local Mdl = ACF.Weapons.Guns[Weapon].round.model or "models/munitions/round_100mm_shot.mdl"
		--local Mdl = "models/munitions/round_100mm_shot.mdl"
		EntFrom.RefillAmmoEffect = EntFrom.RefillAmmoEffect or {}
		table.insert( EntFrom.RefillAmmoEffect, {EntFrom = EntFrom, EntTo = EntTo, Model = Mdl, StTime = SysTime()} )
	end)
	
	usermessage.Hook("ACF_StopRefillEffect", function( msg )
		local EntFrom, EntTo = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() )
		if not IsValid( EntFrom ) or not IsValid( EntTo )or not EntFrom.RefillAmmoEffect then return end
		for k,v in pairs( EntFrom.RefillAmmoEffect ) do
			if v.EntTo == EntTo then
				if #EntFrom.RefillAmmoEffect<=1 then 
					EntFrom.RefillAmmoEffect = nil
					return
				end
				table.remove(EntFrom.RefillAmmoEffect, k)
			end
		end
	end)
	
	return
	
end

function ENT:Initialize()
	
	self.SpecialHealth = true	--If true needs a special ACF_Activate function
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.IsExplosive = true
	self.Exploding = false
	self.Damaged = false
	self.CanUpdate = true
	self.Load = false
	self.EmptyMass = 0
	self.Ammo = 0
	
	self.LastBombPop = CurTime()
	
	self.Master = {}
	self.Sequence = 0
	
	self.Inputs = Wire_CreateInputs( self, { "Active" } ) --, "Fuse Length"
	self.Outputs = Wire_CreateOutputs( self, { "Munitions", "On Fire" } )
		
	self.NextThink = CurTime() +  1
	
	ACF.AmmoCrates = ACF.AmmoCrates or {}
	self.lastCol = self:GetColor() or Color(255, 255, 255)
	self:SetNetworkedVector("TracerColour", Vector( self.lastCol.r, self.lastCol.g, self.lastCol.b ) )
	self.nextColCheck = CurTime() + 2
	
end


function ENT:ACF_Activate( Recalc )
	
	local EmptyMass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - self:AmmoMass())

	self.ACF = self.ACF or {} 
	
	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end
	
	local Armour = EmptyMass*1000 / self.ACF.Aera / 0.78 --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume/ACF.Threshold							--Setting the threshold of the prop aera gone 
	local Percent = 1 
	
	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health/self.ACF.MaxHealth
	end
	
	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent/2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = (self:GetPhysicsObject():GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"
	
end

function ENT:ACF_OnDamage( Entity, Energy, FrAera, Angle, Inflictor )	--This function needs to return HitRes

	local HitRes = ACF_PropDamage( Entity, Energy, FrAera, Angle, Inflictor )	--Calling the standard damage prop function
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	
	if HitRes.Kill then
		if hook.Run("ACF_AmmoExplode", self, self.BulletData ) == false then return HitRes end
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		if self.Ammo > 1 then
			ACF_ScaledExplosion( self )
		else
			ACF_HEKill( self, VectorRand() )
		end
	end
	
	if self.Damaged then return HitRes end
	local Ratio = (HitRes.Damage/self.BulletData.RoundVolume)^0.2
	--print(Ratio)
	if ( Ratio * self.Capacity/self.Ammo ) > math.Rand(0,1) then  
		self.Inflictor = Inflictor
		self.Damaged = CurTime() + (5 - Ratio*3)
		Wire_TriggerOutput(self, "On Fire", 1)
	end
	
	return HitRes --This function needs to return HitRes
end

function MakeACF_Ammo(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	if not Owner:CheckLimit("_acf_ammo") then return false end
	
	--print(Id, Data1, Data2)
	local weapon = ACF.Weapons.Guns[Data1]
	if weapon and weapon.blacklist and weapon.blacklist[Data2] then
		return false, "Ammo for " .. Data1 .. " does not support " .. Data2 .. " warheads!"
	end
	
	local Ammo = ents.Create("acf_ammo")
	if not Ammo:IsValid() then return false end
	Ammo:SetAngles(Angle)
	Ammo:SetPos(Pos)
	Ammo:Spawn()
	Ammo:SetPlayer(Owner)
	Ammo.Owner = Owner
	
	Ammo.Model = ACF.Weapons.Ammo[Id].model
	Ammo:SetModel( Ammo.Model )	
	
	Ammo:PhysicsInit( SOLID_VPHYSICS )      	
	Ammo:SetMoveType( MOVETYPE_VPHYSICS )     	
	Ammo:SetSolid( SOLID_VPHYSICS )
	
	Ammo.Id = Id
	Ammo:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)
	
	Ammo.Ammo = Ammo.Capacity
	Ammo.EmptyMass = ACF.Weapons.Ammo[Ammo.Id].weight
	Ammo.Mass = Ammo.EmptyMass + Ammo:AmmoMass()
	
	local phys = Ammo:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass( Ammo.Mass ) 
	end
	
	Owner:AddCount( "_acf_ammo", Ammo )
	Owner:AddCleanup( "acfmenu", Ammo )
	
	table.insert(ACF.AmmoCrates, Ammo)
	
	return Ammo
end
list.Set( "ACFCvars", "acf_ammo", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10"} )
duplicator.RegisterEntityClass("acf_ammo", MakeACF_Ammo, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10" )

function ENT:Update( ArgsTable )
	
	-- That table is the player data, as sorted in the ACFCvars above, with player who shot, 
	-- and pos and angle of the tool trace inserted at the start

	local msg = "Ammo crate updated successfully!"
	
	if ArgsTable[1] ~= self.Owner then -- Argtable[1] is the player that shot the tool
		return false, "You don't own that ammo crate!"
	end
	
	if ArgsTable[6] == "Refill" then -- Argtable[6] is the round type. If it's refill it shouldn't be loaded into guns, so we refuse to change to it
		return false, "Refill ammo type is only avaliable for new crates!"
	end
	
	if ArgsTable[5] ~= self.RoundId then -- Argtable[5] is the weapon ID the new ammo loads into
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) then
				Gun:Unlink( self )
			end
		end
		msg = "New ammo type loaded, crate unlinked."
	else -- ammotype wasn't changed, but let's check if new roundtype is blacklisted
		local Blacklist = ACF.AmmoBlacklist[ ArgsTable[6] ] or {}
		
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) and table.HasValue( Blacklist, Gun.Class ) then
				Gun:Unlink( self )
				msg = "New round type cannot be used with linked gun, crate unlinked."
			end
		end
	end
	
	local AmmoPercent = self.Ammo/math.max(self.Capacity,1)
	
	self:CreateAmmo(ArgsTable[4], ArgsTable[5], ArgsTable[6], ArgsTable[7], ArgsTable[8], ArgsTable[9], ArgsTable[10], ArgsTable[11], ArgsTable[12], ArgsTable[13], ArgsTable[14])
	
	self.Ammo = math.floor(self.Capacity*AmmoPercent)
	local AmmoMass = self:AmmoMass()
	self.Mass = math.min(self.EmptyMass, self:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
	
	return true, msg
	
end

function ENT:UpdateOverlayText()
	
	local text = "Rounds: " .. self.Ammo .. " / " .. self.Capacity
	text = text .. "\nRound Type: " .. self.RoundType
	
	if self.BulletData.Tracer and self.BulletData.Tracer > 0 then 
		text = text .. "-T"
	end
	
	local RoundData = ACF.RoundTypes[ self.RoundType ]
	
	if RoundData and RoundData.cratetxt then
		text = text .. "\n" .. RoundData.cratetxt( self.BulletData )
	end
	
	self:SetOverlayText( text )
	
end

function ENT:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)
	
	local PlayerData = {
		Id 			= Data1,
		Type 		= Data2,
		PropLength	= Data3,
		ProjLength	= Data4,
		Data5		= Data5,
		Data6		= Data6,
		Data7		= Data7,
		Data8		= Data8,
		Data9		= Data9,
		Data10		= Data10
	}
	
	
	local guntable = ACF.Weapons.Guns
	local gun = guntable[PlayerData.Id] or {}
	local roundclass = XCF.ProjClasses[gun.roundclass or "Shell"] or error("Unrecognized projectile class " .. (gun.roundclass or "Shell") .. "!")
	PlayerData.ProjClass = roundclass
	--[[
	print("made a", gun.roundclass or "Shell", "crate!", roundclass)
	print("\n\n\nbefore\n\n\n")
	PrintTable(PlayerData)
	--]]--
	self.BulletData = roundclass.GetExpanded(PlayerData)
	self.BulletData.Colour = self:GetColor()
	--[[
	print("\n\n\nafter\n\n\n")
	PrintTable(self.BulletData)
	--]]--
	
	
	local bdata = self.BulletData
	bdata = bdata.ProjClass and (bdata.ProjClass.GetCompact(bdata)) or bdata
	
	--[[
	print("--", "AMMO bdata")
	printByName(bdata)
	print("--", "end AMMO bdata")
	--]]--
	
		--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId = bdata.Id		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = bdata.Type		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = bdata.PropLength or 0--Lenght of propellant
	self.RoundProjectile = bdata.ProjLength or 0--Lenght of the projectile
	self.RoundData5 = ( bdata.FillerVol or bdata.Flechettes or bdata.Data5 or 0 )
	self.RoundData6 = ( bdata.ConeAng or bdata.FlechetteSpread or bdata.Data6 or 0 )
	self.RoundData7 = ( bdata.Data7 or 0 )
	self.RoundData8 = ( bdata.Data8 or 0 )
	self.RoundData9 = ( bdata.Data9 or 0 )
	self.RoundData10 = ( bdata.Tracer or bdata.Data10 or 0 )
	
	
	local Size = (self:OBBMaxs() - self:OBBMins())
	local Efficiency = 0.11 * ACF.AmmoMod			--This is the part of space that's actually useful, the rest is wasted on interround gaps, loading systems ..
	self.Volume = math.floor(Size.x * Size.y * Size.z)*Efficiency
	self.Capacity = math.floor(self.Volume*16.38/self.BulletData.RoundVolume)
	self.Caliber = list.Get("ACFEnts").Guns[self.RoundId].caliber
	
	self:SetNetworkedString( "Ammo", self.Ammo )
	self:SetNetworkedString( "WireName", self.RoundId .. " Ammo" )
	
	self.NetworkData = ACF.RoundTypes[self.RoundType].network
	self:NetworkData( self.BulletData )
	
	self:UpdateOverlayText()
	
	hook.Call("ACF_AmmoCreate", nil, self)
	
end



local popdelay = 1

function ENT:Use(activator, caller, useType, value)

	local lastpop = self.LastBombPop
	self.LastBombPop = CurTime()

	if self.Ammo < 1 then return end
	
	if CurTime() < lastpop + popdelay then
		return
	end

	if not activator:IsPlayer() then return end
	
	local cantool = hook.Call("CanTool", SANDBOX, activator, activator:GetEyeTrace(), "")
	if cantool == false then return end
	
	local guntbl = ACF.Weapons.Guns[self.RoundId] or {round = {}}
	local visModel = guntbl.round.rackmdl or guntbl.round.model or "models/munitions/round_100mm_shot.mdl"
	
	local bomb, msg = MakeXCF_Bomb(self.Owner, self:GetPos() + Vector(0, 0, 64), self:GetAngles(),
					self.RoundId,
					self.RoundId,
					self.RoundType,
					self.RoundPropellant,
					self.RoundProjectile,
					self.RoundData5, 
					self.RoundData6, 
					self.RoundData7,
					self.RoundData8,
					self.RoundData9,
					self.RoundData10,
					visModel)
						
	if not IsValid(bomb) then
		if msg then
			ACF_SendNotify( activator, false, msg )
		end
		
		return
	end
				
	self.Ammo = self.Ammo - 1
				
	bomb:EnableClientInfo(true)
	self.LastBombPop = CurTime()
end


function ENT:AmmoMass() --Returns what the ammo mass would be if the crate was full
	return math.floor( (self.BulletData.ProjMass + self.BulletData.PropMass) * self.Capacity * 2 )
end

function ENT:TriggerInput( iname, value )

	if iname == "Active" then
		if value > 0 then
			self.Load = true
			self:FirstLoad()
		else
			self.Load = false
		end
	end

end

function ENT:FirstLoad()

	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() and self.Master[Key].BulletData.Type == "Empty" then
			--print("Send FirstLoad")
			self.Master[Key]:UnloadAmmo()
		end
	end
	
end



local doSupply = 
{
	["acf_ammo"] = function(self, Ammo, dist)
		local dist = self:GetPos():Distance(Ammo:GetPos())
		if dist > ACF.RefillDistance then return end
	
		if Ammo.Capacity > Ammo.Ammo then
			self.SupplyingTo = self.SupplyingTo or {}
			if not table.HasValue( self.SupplyingTo, Ammo:EntIndex() ) then
				table.insert(self.SupplyingTo, Ammo:EntIndex())
				self:RefillEffect( Ammo )
			end
					
			--print("ammo doing supply")
					
			local Supply = math.ceil((50000/((Ammo.BulletData["ProjMass"]+Ammo.BulletData["PropMass"])*1000))/dist)
			--Msg(tostring(50000).."/"..((Ammo.BulletData["ProjMass"]+Ammo.BulletData["PropMass"])*1000).."/"..dist.."="..Supply.."\n")
			local Transfert = math.min(Supply , Ammo.Capacity - Ammo.Ammo)
			Ammo.Ammo = Ammo.Ammo + Transfert
			self.Ammo = self.Ammo - Transfert
				
			Ammo.Supplied = true
			Ammo.Entity:EmitSound( "items/ammo_pickup.wav" , 500, 80 )
		end
	end,
	
	["acf_rack"] = function(self, Rack, dist)
		local dist = self:GetPos():Distance(Rack:GetPos())
		if dist > ACF.RefillDistance then return end
	
		if Rack.BulletData.Type ~= "Empty" and Rack.MagSize and (Rack.MagSize - Rack.CurrentShot < Rack.MagSize) or Rack.CurrentShot ~= 0 then
			self.SupplyingTo = self.SupplyingTo or {}
			if not table.HasValue( self.SupplyingTo, Rack:EntIndex() ) then
				table.insert(self.SupplyingTo, Rack:EntIndex())
				self:RefillEffect( Rack )
			end
					
			local Supply = math.ceil((50000/((Rack.BulletData["ProjMass"] + Rack.BulletData["PropMass"]) * 1000)) / dist)
			--Msg(tostring(50000).."/"..((Rack.BulletData["ProjMass"]+Rack.BulletData["PropMass"])*1000).."/"..dist.."="..Supply.."\n")
			local Transfert = math.min(Supply , Rack.CurrentShot)
			if Rack:LoadAmmo( 0, Transfert ) then
				self.Ammo = self.Ammo - Transfert
				
				Rack.Supplied = true
				Rack.Entity:EmitSound( "items/ammo_pickup.wav" , 500, 80 )
			end
		end
	end
}


local getFull = 
{
	["acf_ammo"] = function(Ammo)
		return Ammo.Capacity <= Ammo.Ammo
	end,
	
	["acf_rack"] = function(Rack)
		return Rack.CurrentShot == 0
	end
}





function ENT:Think()
	local AmmoMass = self:AmmoMass()
	self.Mass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
	self:GetPhysicsObject():SetMass(self.Mass) 
	
	if self.Ammo ~= self.AmmoLast then
		self:UpdateOverlayText()
		self.AmmoLast = self.Ammo
	end
	
	local color = self:GetColor()
	local lastCol = self.lastCol
	if (CurTime() > self.nextColCheck) and (color.r ~= lastCol.r or color.g ~= lastCol.g or color.b ~= lastCol.b or color.a ~= lastCol.a) then
		self.nextColCheck = CurTime() + 2
		self.lastCol = color
		self:SetNetworkedVector("TracerColour", Vector( color.r, color.g, color.b ) )
		self:CreateAmmo(self.Id, self.RoundId, self.RoundType, self.RoundPropellant, self.RoundProjectile, self.RoundData5, self.RoundData6, self.RoundData7, self.RoundData8, self.RoundData9, self.RoundData10)
	end
	
	local cvarGrav = GetConVar("sv_gravity")
	local vec = Vector(0,0,cvarGrav:GetInt()*-1)
	if( self.sitp_inspace ) then
		vec = Vector(0, 0, 0)
	end
		
	self:SetNetworkedVector("Accel", vec)
		
	self:NextThink( CurTime() +  1 )
	
	if self.Damaged then
		if self.Damaged < CurTime() then
			ACF_ScaledExplosion( self )
		else
			if not (self.BulletData.Type == "Refill") then
				if math.Rand(0,150) > self.BulletData.RoundVolume^0.5 and math.Rand(0,1) < self.Ammo/math.max(self.Capacity,1) and ACF.RoundTypes[self.BulletData.Type] then
					self:EmitSound( "ambient/explosions/explode_4.wav", 350, math.max(255 - self.BulletData.PropMass*100,60)  )	
					local MuzzlePos = self:GetPos()
					local MuzzleVec = VectorRand()
					local Speed = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass/2, self.Caliber )
					
					self.BulletData.Pos = MuzzlePos
					self.BulletData.Flight = (MuzzleVec):GetNormalized() * Speed * 39.37 + self:GetVelocity()
					self.BulletData.Owner = self.Inflictor or self.Owner
					self.BulletData.Gun = self
					self.BulletData.Crate = self:EntIndex()
					self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
					self:CreateShell( self.BulletData )
					
					self.Ammo = self.Ammo - 1
					
				end
			end
			self:NextThink( CurTime() + 0.01 + self.BulletData.RoundVolume^0.5/100 )
		end
		
	elseif self.RoundType == "Refill" and self.Ammo > 0 then -- Even newer, fresher, more genius, beautiful and flawless refill system.
		if self.Load then
			for _,Ammo in pairs( ACF.AmmoCrates ) do
				if Ammo.RoundType ~= "Refill" then
					local dist = self:GetPos():Distance(Ammo:GetPos())
					if dist < ACF.RefillDistance then
						doSupply["acf_ammo"](self, Ammo, dist)
					end
				end
			end
			
			for _, rack in pairs(ents.FindByClass("acf_rack")) do
				doSupply["acf_rack"](self, rack, dist)
			end
		end
	end
	
	if self.SupplyingTo then
		for k,v in pairs( self.SupplyingTo ) do
			local Ammo = ents.GetByIndex(v)
			if not IsValid( Ammo ) then 
				table.remove(self.SupplyingTo, k)
				self:StopRefillEffect( Ammo )
			else
				local dist = self:GetPos():Distance(Ammo:GetPos())
				if dist > ACF.RefillDistance or getFull[Ammo:GetClass()](Ammo) or self.Damaged or not self.Load then -- If ammo crate is out of refill max distance or is full or our refill crate is damaged or just in-active then stop refiliing it.
					table.remove(self.SupplyingTo, k)
					self:StopRefillEffect( Ammo )
				end
			end
		end
	end
	
	Wire_TriggerOutput(self, "Munitions", self.Ammo)
	return true

end



local getWeapon = 
{
	["acf_ammo"] = function(ammo)
		return ammo.RoundId
	end,
	
	["acf_rack"] = function(rack)
		return rack.BulletData.Id
	end
}



function ENT:RefillEffect( Target )
	umsg.Start("ACF_RefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( Target:EntIndex() )
		umsg.String( getWeapon[Target:GetClass()](Target) )
	umsg.End()
end

function ENT:StopRefillEffect( Target )
	umsg.Start("ACF_StopRefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( Target:EntIndex() )
	umsg.End()
end

function ENT:ConvertData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:NetworkData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:OnRemove()
	
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
			self.Ammo = 0
		end
	end
	for k,v in pairs(ACF.AmmoCrates) do
		if v == self then
			table.remove(ACF.AmmoCrates,k)
		end
	end
	
end
