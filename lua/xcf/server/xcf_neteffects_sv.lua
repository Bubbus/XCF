// rewrite of server->client effects using net library instead of effect hax

include("xcf/shared/xcf_util_sh.lua")

XCF.NetFX = XCF.NetFX or {}

local this = XCF.NetFX
local str = this.Strings
local ammouids = this.AmmoUIDs

if not (str or ammouids) then 
	include("xcf/shared/xcf_neteffects_sh.lua")
	str = this.Strings or error("Couldn't load XCF net strings.")
	ammouids = this.AmmoUIDs
end


local oldvec
// Make sure to pcall all code while hack is active - can't afford to mess up global functions for other code.
// doing this because WriteVector compression is horrendous and rewriting the entire WriteTable function is not my current focus.
local function vectorhack(bool)
	if oldvec then return end
	
	if bool then
		oldvec = net.WriteVector
		net.WriteVector = net.WriteVectorDouble
	else
		net.WriteVector = oldvec
		oldvec = nil
	end
end



local ammoAttribs
local function generateAmmoUID(ammo, bdata)
	//if not IsValid(ammo) then print("Got invalid ammo in net create hook: " .. tostring(ammo)) end
	/*
	if not ammoAttribs then
		local dupeEntTbl = duplicator.FindEntityClass("acf_ammo")
		if not dupeEntTbl then error("Couldn't find duplicator records for acf_ammo!") return end
		ammoAttribs = table.Copy(dupeEntTbl.Args)
		table.remove(ammoAttribs, 1)
		table.remove(ammoAttribs, 1)
		table.remove(ammoAttribs, 1)
		if not ammoAttribs then error("Couldn't find duplicator-replicable attributes for acf_ammo!") return end
	end
	
	local attribs = {}
	--printByName(ammoAttribs)
	for k, v in pairsByName(ammoAttribs) do
		--print(k, v, ammo[v])
		attribs[#attribs + 1] = ammo[v] or error("No ammo-data available for " .. tostring(v) .. "!")
	end
	
	local colour = ammo:GetColor()
	for k, v in pairsByName(colour) do
		attribs[#attribs + 1] = v
	end
	//*/
	
	ammo = IsValid(ammo) and ammo or {}
	bdata = bdata or ammo.BulletData
	
	if not bdata then error("Didn't get valid bullet data in UID generation function.") return end
	
	local attribs = {}
	
	for k, v in pairsByName(bdata) do
		attribs[#attribs+1] = tostring(k)
		attribs[#attribs+1] = tostring(v)
	end
	
	local ammoUID = util.CRC(table.concat(attribs))
	
	if IsValid(ammo) then
		ammo.NetUID = ammoUID
	end
	
	bdata.NetUID = ammoUID
	
	return ammoUID
end




local function bdataHook(bdata, ammo, parent)

	local uidBefore = ammo.NetUID
	local uid = parent and generateAmmoUID(nil, bdata) or generateAmmoUID(ammo, bdata)
	
	if parent then parent.ChildUID = uid end
	
	if uidBefore and uidBefore == uid then
		--print("Identical UID", uid)
		return
	end
	--print("Got UID", uid)
	
	ammo:CallOnRemove( "xcfammo_remUID", this.OnAmmoRemoved)
	
	this.AmmoRegisterNet(uid, bdata, ammo)
end



//TODO: better design: move ammo reg into munition class -> ammo type files.
local doNotReg = {Empty = true, Refill = true}
local function ammoHook(ammo)
	if XCF.Debug then printByNameTable(ammo.BulletData, "self.BulletData") end
	
	local bdata = ammo.BulletData
	
	if bdata and doNotReg[bdata.Type] then return end
	
	bdataHook(bdata, ammo)
	
	if bdata.Type == "FL" then
		bdataHook(ACF.RoundTypes.FL.getFlechetteData(bdata), ammo, bdata)
	end
	
end
hook.Add("ACF_AmmoCreate", "XCF_NetAmmo", ammoHook)
hook.Add("ACF_RackCreate", "XCF_NetAmmo", ammoHook)




local function gunCreateHook(gun)
	gun:CallOnRemove( "xcfammo_remUID", this.OnAmmoRemoved)
end
hook.Add("ACF_GunCreate", "XCF_NetAmmo", gunCreateHook)




local function gunHook(gun, oldammo, newammo)
	--local oldstr = oldammo.NetUID and oldammo.NetUID or (oldammo.Type and (oldammo.Type .. "/" .. tostring(oldammo.Id))) or "Old Ammo"
	--local newstr = newammo.NetUID and newammo.NetUID or (newammo.Type and (newammo.Type .. "/" .. tostring(newammo.Id))) or "New Ammo"
	--print("gunhook", oldstr, newstr)
	
	if oldammo.NetUID == newammo.NetUID then
		--print("Identical UID", uid) 
		return
	end
	
	if oldammo.NetUID and not doNotReg[oldammo.Type] then
		this.OnAmmoRemoved(gun, oldammo.NetUID)
	end
	
	if newammo.NetUID and not doNotReg[newammo.Type] then
		this.AddToAmmoRegistry(gun, newammo)
	end
end
hook.Add("ACF_GunReload", "XCF_NetAmmo", gunHook)




local function ammoJoinedHook(ply)

	for uid, reg in pairs(ammouids) do
		if reg.BulletData then
			net.Start(str.AMMOREG)
			net.WriteDouble(uid)
			vectorhack(true)
			local success, err = pcall(net.WriteTable, reg.BulletData)
			vectorhack(false)
			
			if not success then error("Failure to send ammo-uid " .. tostring(uid) .." to new user " .. tostring(ply) .. " : " .. err .. "\n" .. debug.traceback()) end
			
			net.Send(ply)
		else
			print("WARNING: Found a net-registered ammocrate without associated ammodata:", uid)
		end
	end
	
	local ammoct = #ammouids
	if ammoct > 0 then
		print("Sent ", ammoct, "ammo datas to new player", ply)
	end

end
hook.Add( "PlayerInitialSpawn", "XCF_SendAmmoRegs", ammoJoinedHook )




function this.OnAmmoRemoved(ammo, uid)
	--print("deregistering ammocrate!", ammo, uid)
	
	if not uid then 
	
		local uids = {}
		local found = nil
		
		for tbluid, reg in pairs(ammouids) do
			for k, v in pairs(reg) do
				if v == ammo then
					--print("found ammocrate to deregister!", tbluid, k, v)
					uid = tbluid
					uids[#uids+1] = reg
					found = v
					table.remove(reg, k)
				end
			end
		end
		
		
		if #uids == 0 then print("WARNING: Tried to de-register an ammocrate with an unregistered net-id!") return end		
		
		for _, reg in pairs(uids) do
			if #reg == 0 then
				this.AmmoDeregisterNet(uid)
			end
		end
		
		if not found then print("WARNING: Tried to de-register an unregistered ammocrate!") return end
	else
	
		local uids = ammouids[uid]
		if not uids then error("Tried to de-register an ammocrate with an unregistered net-id!") return end
		
		local found
		for k, v in pairs(uids) do
			if v == ammo then
				--print("found ammocrate to deregister!", k, v)
				table.remove(uids, k)
				found = v
				break
			end
		end
		
		if #uids == 0 then
			this.AmmoDeregisterNet(uid)
		end
		
		if not found then print("WARNING: Tried to de-register an unregistered ammocrate!") return end
	end
	
end




function this.AmmoRegisterNet(uid, ammodata, ammo)
	if not uid then error("Tried to register ammo across net without a net-id!") return end
	if not ammodata then error("Tried to register ammo across net without bullet data!") return end
	
	local tosend = ammodata.ProjClass.GetCompact(ammodata)
	
	/*
	print("TO AMMOREG:", uid)
	printByName(tosend)
	print("TO AMMOREG END\n\n")
	//*/
	
	//TODO: more this
	//*
	net.Start(str.AMMOREG)
	net.WriteDouble(uid)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to register new ammo across net: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()
	
	if ammo then this.AddToAmmoRegistry(ammo, tosend) end
	
	return tosend
	//*/
	
end




function this.ClientAmmoRequest(len, ply)

	local uid = net.ReadDouble()

	--print("Received resend request", ply, uid)
	
	if not uid then 
		--print("Bad uid!")
		return
	end
	
	local ammodata = ammouids[tostring(uid)]
	--print(ammodata and "Found" or "Didn't find", "ammo data for uid", uid)
	if not ammodata then return end
	
	--printByName(ammodata.BulletData)
	
	local tosend = ammodata.BulletData
	
	net.Start(str.AMMOREG)
	net.WriteDouble(uid)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to register requested ammo (" .. tostring(uid) .. ") to player (" .. tostring(ply) .. ") " .. err .. "\n" .. debug.traceback()) end
	
	net.Send(ply)
	
	return tosend
end
net.Receive(str.BADUID, this.ClientAmmoRequest)




function this.AddToAmmoRegistry(ammo, ammodata)

	if not ammouids then error("Couldn't find ammo registry!") return end
	if not IsValid(ammo) then error("Tried to add an invalid ammocrate to the registry!") return end
	local netuid = ammo.NetUID or ammodata.NetUID
	if not netuid then error("Tried to register ammo without a net id!") return end
	
	this.OnAmmoRemoved(ammo)
	
	if not ammodata then
		local bData = ammo.BulletData or error("Tried to register ammo across net without bullet data!")
		ammodata = bData.ProjClass.GetCompact(bData)
	end
	
	local crates = ammouids[netuid]
	if not crates then 
		crates = {BulletData = ammodata}
		ammouids[netuid] = crates
	end
	
	crates[#crates+1] = ammo
	
	return ammodata
end




function this.AmmoDeregisterNet(uid)
	if not uid then return end
	
	/*
	print("TO AMMODEREG:", uid)
	//*/
	
	//TODO: more this
	//*
	net.Start(str.AMMODEREG)
	net.WriteDouble(uid)	
	net.Broadcast()
	//*/

	this.RemoveUIDFromAmmoRegistry(uid)
	
end




function this.RemoveUIDFromAmmoRegistry(uid)
	if not uid then return end
	
	ammouids[uid] = nil
end




/**
	Send all clients a projectile definition to begin simulating.
//*/
function this.SendProj(Index, Proj)

	if Proj.NetUID then
		--print("Sending UID Proj " .. Proj.Type)
		this.SendUIDProj(Index, Proj)
	else
		--print("Sending Full Proj " .. Proj.Type)
		this.SendFullProj(Index, Proj)
	end

end




function this.SendUIDProj(Index, Proj)

	local tosend = {
		ID = Proj.NetUID,
		Pos = Proj.Pos or error("No projectile 'Pos' index for proj no. " .. tostring(Index)),
		Dir = Proj.Flight or error("No projectile 'Flight' index for proj no. " .. tostring(Index))
	}
	/*
	print("TO SENDUID:")
	printByName(tosend)
	print("TO SENDUID END\n\n")
	//*/
	
	net.Start(str.SENDUID)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to write new projectile: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()
	
end




function this.SendFullProj(Index, Proj)

	local tosend = Proj.ProjClass.GetCompact(Proj)
	
	/*
	print("TO SEND:")
	printByName(tosend)
	print("TO SEND END\n\n")
	//*/
	
	net.Start(str.SEND)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to write new projectile: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()
	
end




function this.EndProj(Index, Update)
	net.Start(str.END)
	net.WriteInt(Index, 16)
	if Update then
		vectorhack(true)
		pcall(net.WriteTable, Update)
		vectorhack(false)
	else	// signify no update (net lib requires)
		net.WriteTable({[0] = true})
	end
	net.Broadcast()
end




function this.EndProjQuiet(Index)
	net.Start(str.ENDQUIET)
	net.WriteInt(Index, 16)
	net.Broadcast()
end




function this.AlterProj(Index, Alterations)
	if not Alterations then error("Tried to send invalid projectile update (" .. Index .. ")") end
	
	/*
	print("UPDATE OUT:")
	printByName(Alterations)
	print("UPDATE END")
	//*/
	
	net.Start(str.ALTER)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, Alterations)
	vectorhack(false)
	
	if not success then error("Failure to write projectile alterations: " .. err .. "\n" .. debug.traceback()) end
	net.Broadcast()
end

