/*
--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId = Data1				--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = Data2				--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3		--Lenght of propellant
	self.RoundProjectile = Data4	 	--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 ) 	-- (HE, HEAT, SM): filler vol, HP: cavity vol
	self.RoundData6 = ( Data6 or 0 )	-- HEAT: crush cone angle
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )	-- Tracer
//*/

//*
local verbose = {}
verbose["AP"]		= "Armour Piercing"
verbose["APHE"]		= "Armour Piercing, High Explosive"
verbose["HE"]		= "High Explosive"
verbose["HEAT"]		= "High Explosive, Anti-Tank"
verbose["FL"]		= "Flechette"
verbose["HP"]		= "Hollow Point"
verbose["SM"]		= "Smoke"
verbose["Refill"]	= "Refill"
//*/

//*
local createSlidersForAmmo = {}


createSlidersForAmmo["base"] = function(self, entrylist, spacer)
	self.SliderWatchList = {}
	local watch = self.SliderWatchList
	
	self.PropLengthSlider = nil
	self.ProjLengthSlider = nil
	self.FillerSlider = nil
	self.CrushSlider = nil
	self.CavitySlider = nil
	
	self.PenLabel = nil
	self.VelLabel = nil
	self.BoomRadLabel = nil
	self.KineticLabel = nil
	
	-- propellant label
	local label = vgui.Create( "DLabel" )
	label:SetText("Propellant Length (cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- propellant body
	self.PropLengthSlider = self.PropLengthSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.PropLengthSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data3")
	watch["PropLength"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	
	-- projectile label
	local label = vgui.Create( "DLabel" )
	label:SetText("Projectile Length (cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- projectile body
	self.ProjLengthSlider = self.ProjLengthSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.ProjLengthSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data4")
	watch["ProjLength"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
end


createSlidersForAmmo["after"] = function(self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- tracer checkbox
	self.TracerBox = vgui.Create( "DCheckBoxLabel" )
	local tracerbox = self.TracerBox
	tracerbox:SetText( "Tracer" )
	//tracerbox:SetConVar( "xcfmenu_data10" ) -- ConCommand must be a 1 or 0 value
	tracerbox.OnChange = function(box, val)
		self:InvalidateLayout()
	end
	tracerbox:SizeToContents()
	
	entrylist:AddItem(tracerbox)
	entrylist:AddItem(spacer)
	
	self:InvalidateLayout()
end


createSlidersForAmmo["AP"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.PenLabel = vgui.Create( "DLabel" )
	local label = self.PenLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
end


createSlidersForAmmo["HE"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- filler label
	local label = vgui.Create( "DLabel" )
	label:SetText("HE Filler Volume (cubic cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- filler body
	self.FillerSlider = self.FillerSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.FillerSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data5")
	watch["Data5"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.BoomRadLabel = vgui.Create( "DLabel" )
	local label = self.BoomRadLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
end


createSlidersForAmmo["APHE"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- filler label
	local label = vgui.Create( "DLabel" )
	label:SetText("HE Filler Volume (cubic cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- filler body
	self.FillerSlider = self.FillerSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.FillerSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data5")
	watch["Data5"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.PenLabel = vgui.Create( "DLabel" )
	local label = self.PenLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.BoomRadLabel = vgui.Create( "DLabel" )
	local label = self.BoomRadLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
end


createSlidersForAmmo["HEAT"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- filler label
	local label = vgui.Create( "DLabel" )
	label:SetText("HE Filler Volume (cubic cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- filler body
	self.FillerSlider = self.FillerSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.FillerSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data5")
	watch["Data5"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	local watch = self.SliderWatchList
	
	-- crushcone label
	local label = vgui.Create( "DLabel" )
	label:SetText("Crush Cone Angle (degrees):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- crushcone body
	self.CrushSlider = self.CrushSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.CrushSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data6")
	watch["Data6"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.PenLabel = vgui.Create( "DLabel" )
	local label = self.PenLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.BoomRadLabel = vgui.Create( "DLabel" )
	local label = self.BoomRadLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
end


createSlidersForAmmo["FL"] = function(self, entrylist, spacer)
	-- lol!
	local label = vgui.Create( "DLabel" )
	label:SetText("XCFMenu support for Flechettes is coming!\nUse the normal ACF menu for now!")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(200, 30, 0))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	self:InvalidateLayout()
end


createSlidersForAmmo["HP"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- cavity label
	local label = vgui.Create( "DLabel" )
	label:SetText("Hollow Cavity Volume (cubic cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- cavity body
	self.CavitySlider = self.CavitySlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.CavitySlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data5")
	watch["Data5"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.PenLabel = vgui.Create( "DLabel" )
	local label = self.PenLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	self.KineticLabel = vgui.Create( "DLabel" )
	local label = self.KineticLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
end


createSlidersForAmmo["SM"] = function(self, entrylist, spacer)
	createSlidersForAmmo["base"](self, entrylist, spacer)
	
	local watch = self.SliderWatchList
	
	-- filler label
	local label = vgui.Create( "DLabel" )
	label:SetText("WP Filler Volume (cubic cm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	-- filler body
	self.FillerSlider = self.FillerSlider or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.FillerSlider
	label:SetExtents(0, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data5")
	watch["Data5"] = label
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	createSlidersForAmmo["after"](self, entrylist, spacer)
	
	-- info labels
	
	self.VelLabel = vgui.Create( "DLabel" )
	local label = self.VelLabel
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
end


createSlidersForAmmo["Refill"] = function(self, entrylist, spacer)
	-- lol!
	local label = vgui.Create( "DLabel" )
	label:SetText("Refill boxes have no options!")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	self:InvalidateLayout()
end
//*/

//*
-- table of functions for gui modification.
local modifyControlsWith = {}

-- SLIDER MODIFICATION;

-- for some reason i had the idea that filler and cavity were represented as the same thing.  keeping this assumption in place in case i had a good reason to believe it.
modifyControlsWith["MaxFillerVol"] = function(self, val)
	if self.FillerSlider and IsValid(self.FillerSlider) then
		self.FillerSlider:SetMax(val)
	end
	if self.CavitySlider and IsValid(self.CavitySlider) then
		self.CavitySlider:SetMax(val)
	end
end


modifyControlsWith["MinFillerVol"] = function(self, val)
	if self.FillerSlider and IsValid(self.FillerSlider) then
		self.FillerSlider:SetMin(val)
	end
	if self.CavitySlider and IsValid(self.CavitySlider) then
		self.CavitySlider:SetMin(val)
	end
end


modifyControlsWith["MaxCavVol"] = function(self, val)
	if self.FillerSlider and IsValid(self.FillerSlider) then
		self.FillerSlider:SetMax(val)
	end
	if self.CavitySlider and IsValid(self.CavitySlider) then
		self.CavitySlider:SetMax(val)
	end
end


modifyControlsWith["MinCavVol"] = function(self, val)
	if self.FillerSlider and IsValid(self.FillerSlider) then
		self.FillerSlider:SetMin(val)
	end
	if self.CavitySlider and IsValid(self.CavitySlider) then
		self.CavitySlider:SetMin(val)
	end
end


modifyControlsWith["MaxProjLength"] = function(self, val)
	if self.ProjLengthSlider and IsValid(self.ProjLengthSlider) then
		self.ProjLengthSlider:SetMax(val)
	end
end


modifyControlsWith["MinProjLength"] = function(self, val)
	if self.ProjLengthSlider and IsValid(self.ProjLengthSlider) then
		self.ProjLengthSlider:SetMin(val)
	end
end


modifyControlsWith["MaxPropLength"] = function(self, val)
	if self.PropLengthSlider and IsValid(self.PropLengthSlider) then
		self.PropLengthSlider:SetMax(val)
	end
end


modifyControlsWith["MinPropLength"] = function(self, val)
	if self.PropLengthSlider and IsValid(self.PropLengthSlider) then
		self.PropLengthSlider:SetMin(val)
	end
end


modifyControlsWith["MaxConeAng"] = function(self, val)
	if self.CrushSlider and IsValid(self.CrushSlider) then
		self.CrushSlider:SetMax(val)
	end
end

modifyControlsWith["MinConeAng"] = function(self, val)
	if self.CrushSlider and IsValid(self.CrushSlider) then
		self.CrushSlider:SetMin(val)
	end
end


-- INFO MODIFICATION;
local pentext = "Max. Penetration (mm RHA)"
local veltext = "Muzzle Velocity (m/s)"
local boomradtext = "Blast Radius (m)"
local kinetictext = "Max. Energy Transfer (KJ)"


modifyControlsWith["MaxPen"] = function(self, val)
	if self.PenLabel and IsValid(self.PenLabel) then
		self.PenLabel:SetText(pentext .. ": " .. math.Round(val))
		self.PenLabel:SizeToContents()
	end
end

modifyControlsWith["MuzzleVel"] = function(self, val)
	if self.VelLabel and IsValid(self.VelLabel) then
		self.VelLabel:SetText(veltext .. ": " .. math.Round(val, 1))
		self.VelLabel:SizeToContents()
	end
end

-- blast radius is meters*10 for some reason?
modifyControlsWith["BlastRadius"] = function(self, val)
	if self.BoomRadLabel and IsValid(self.BoomRadLabel) then
		self.BoomRadLabel:SetText(boomradtext .. ": " .. math.Round(val/10, 1))
		self.BoomRadLabel:SizeToContents()
	end
end

modifyControlsWith["MaxKETransfert"] = function(self, val)
	if self.KineticLabel and IsValid(self.KineticLabel) then
		self.KineticLabel:SetText(kinetictext .. ": " .. math.Round(val, 1))
		self.KineticLabel:SizeToContents()
	end
end


local PANEL = {}


local function constructAmmoTypeList(self, ammolist)
	ammolist:Clear()
	self.AmmoChoices = {}
	local ammos = self.AmmoChoices

	local blacklist = XCF.AmmoBlacklist[self.Gun.gunclass] or {}
	local roundblst = self.Gun.blacklist or {}
	for k, v in pairsByKeys(ACF.IdRounds) do
		if blacklist[v] or roundblst[v] then
			continue
		end
		
		ammolist:AddChoice(verbose[v] or v, v)
		ammos[v] = true
	end
	ammolist:AddChoice(verbose["Refill"] or "Refill", "Refill")
	ammos["Refill"] = true
end


function PANEL:Init( )

	self.Categories = {}
	self.Meters = {}
	self.SliderWatchList = {}
	self.Gun = ACF.Weapons.Guns["12.7mmMG"]
	self.Ammo = "AP"
	self.AmmoChoices = {}
	self.Crate = ACF.Weapons.Ammo["Ammo2x2x1"]	
	
	self.CrateLabel = vgui.Create( "DLabel", self )
	local label = self.CrateLabel
	label:SetText("Ammo Crate:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	-- data is static for this, can create it now.
	self.CrateList = vgui.Create("DComboBox", self)
	for k, v in pairsByKeys(ACF.Weapons.Ammo) do
		self.CrateList:AddChoice(k, v)
	end
	self.CrateList.OnSelect = function(list, idx, name, tbl)
		self.Crate = tbl
		RunConsoleCommand("xcfmenu_id", tbl.id)
		RunConsoleCommand("xcfmenu_mdl", tbl.model)
		RunConsoleCommand("xcfmenu_type", tbl.ent)
	end
	
	self.AmmoTypeLabel = vgui.Create( "DLabel", self )
	local label = self.AmmoTypeLabel
	label:SetText("Ammo Type:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	-- Create the ammotype list now and update according to gun's blacklist upon gun selection
	self.AmmoTypeList = vgui.Create("DComboBox", self)
	
	constructAmmoTypeList(self, self.AmmoTypeList)
	
	self.AmmoTypeList.OnSelect = function(list, idx, name, ammoid)
		self.Ammo = ammoid
		self:SetGunAmmo(self.Gun, self.Ammo)
	end
	
	
	self.ClassPanel = nil
	
end



local function sortByName(a, b)
	local startnuma, startnumb 
	startnuma = string.match(a.name, "^(%d+)[^%d]")
	if startnuma then
		startnumb = string.match(b.name, "^(%d+)[^%d]")
		return tonumber(startnuma) < tonumber(startnumb)
	end
	
	return a.name < b.name
end


/**
	This function populates the tab with the appropriate info.
	This function modifies the input (re-orders the class members)
	Make sure the table is in the following format to parse successfully into the tab;
	data =
	{
		<1..n or class id> =
		{
			Class = -- entry class table
			{
				name = <verbose class name>
			}
			<1..n>ClassMember = 
			{
				name = <verbose entry name>
				desc = <verbose entry description>
			}
		}
	}	
 */
function PANEL:SetGunAmmo(guntable, ammotype)
	self.Gun = guntable or self.Gun
	self.Ammo = ammotype or self.Ammo
	
	if not (self.Gun and self.Ammo) then return end
	
	constructAmmoTypeList(self, self.AmmoTypeList)
	
	-- pick a valid ammotype if we're trying to use an invalid one.
	if not self.AmmoChoices[self.Ammo] then
		self.Ammo = next(self.AmmoChoices) or "AP"
	end
	
	-- replace gun info panel with info about this gun.
	if self.ClassPanel and IsValid(self.ClassPanel) then 
		self.ClassPanel:Remove()
		self.ClassPanel = nil
	end
	
	self.ClassPanel = vgui.Create( "DCollapsibleCategory", self )
	self.ClassPanel:SetLabel(guntable.name .. "; " .. verbose[ammotype])
	self.ClassPanel.Header.DoClick = function() end
		
	local entrylist = vgui.Create("DPanelList", category)
	entrylist:SetAutoSize( true )
	entrylist:SetPadding( 5 )
	entrylist:EnableVerticalScrollbar( false )
	
	-- label spam below; gun description text
	
	-- description header
	local label = vgui.Create( "DLabel" )
	label:SetText("Description:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	local spacer = vgui.Create( "DPanel" )
	spacer:SetSize(5, 5)
	spacer.Paint = function() end
	
	--description body
	label = vgui.Create( "DLabel" )
	label:SetColor(Color(40, 40, 40))
	label:SetWrap(true)
	label:SetAutoStretchVertical( true )
	label:SetText(tostring(ACF.RoundTypes[self.Ammo].desc or "Description unavailable!") .. "\n")
	label:SetSize(self:GetWide(), 10)
	label:SizeToContentsY()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	-- header panel, contains save/load buttons
	local gearheadpanel = vgui.Create( "DPanel" )
	gearheadpanel.Paint = function() end
	
	local label = vgui.Create( "DLabel", gearheadpanel)
	label:SetText(verbose[self.Ammo] or "Unknown Ammo" .. ":")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	-- [[
	local function doSave(success, filepath)
		self.fileDialogue = nil
		if success and filepath then
			savefile = {}
			
			for i=1, 10 do
				savefile[i] = GetConVarNumber("xcfmenu_data"..i) or 0
			end
			
			savefile.id		= self.Gun.id
			savefile.mdl	= GetConVarString("xcfmenu_mdl")	or ACF.Weapons.Ammo["Ammo2x2x1"]
			savefile.type	= GetConVarString("xcfmenu_type")	or "acf_ammo"
			
			savefile[1] = savefile.id
			savefile[2] = self.Ammo
					
			file.CreateDir(string.match(filepath, "^(.*/)[^/]*$"))
			file.Write(filepath, util.TableToJSON(savefile))
		end
	end
	
	
	local function createSaveMenu()
		if self.fileDialogue and IsValid(self.fileDialogue) then
			if self.fileDialogue != NULL then 
				self.fileDialogue:Close()
			end
			self.fileDialogue = nil
		end
		
		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
		self.fileDialogue:SetRootFolder("xcfmenu/ammo", true)
		self.fileDialogue:SetTitle("XCFMenu; Save Ammo Profile")
		self.fileDialogue:SetDeleteOnClose(true)
		self.fileDialogue:Center()
		self.fileDialogue:MakePopup()
		self.fileDialogue:SetCallback(doSave)
	end
	
	
	local function doLoad(success, filepath)
		self.fileDialogue = nil
		
		if success and filepath then		
			local content = file.Read(filepath, "DATA")
			local conttable = util.JSONToTable(content)
			
			for i=1, #conttable do
				RunConsoleCommand("xcfmenu_data" .. i, conttable[i] or 0)
			end
			
			RunConsoleCommand("xcfmenu_id", conttable.id)
			RunConsoleCommand("xcfmenu_mdl", conttable.mdl)
			RunConsoleCommand("xcfmenu_type", conttable.type)
			
			local gun = ACF.Weapons.Guns[conttable[1]]
			self:GetParent().SelectPanel:SetSelectedEntry(gun)
			self:SetGunAmmo(gun, conttable[2])
			
			local input2 = {}
			
			input2["Id"] = 			conttable[1]
			input2["Type"] = 		conttable[2]
			input2["PropLength"] = 	conttable[3]
			input2["ProjLength"] = 	conttable[4]
			input2["Data5"] = 		conttable[5]
			input2["Data6"] = 		conttable[6]
			input2["Data10"] = 		conttable[10]
			
			local res, input = self:GetAmmoData(input2)
			
			for k, v in pairs(res) do
				func = modifyControlsWith[k]
				if func then func(self, v) end
			end
			
			for k, v in pairs(self.SliderWatchList) do
				v:SetValue(input[k])
			end
			
			if self.TracerBox and IsValid(self.TracerBox) then
				self.TracerBox:SetChecked(conttable[10] == 1 and true or false)
			end
				
			self:InvalidateLayout()
			
		end
	end
	
	
	local function createLoadMenu()
		if self.fileDialogue and IsValid(self.fileDialogue) then
			if self.fileDialogue != NULL then 
				self.fileDialogue:Close()
			end
			self.fileDialogue = nil
		end
		
		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
		self.fileDialogue:SetRootFolder("xcfmenu/ammo", true)
		self.fileDialogue:SetLoading(true)
		self.fileDialogue:SetTitle("XCFMenu; Load Ammo Profile")
		self.fileDialogue:SetDeleteOnClose(true)
		self.fileDialogue:Center()
		self.fileDialogue:MakePopup()
		self.fileDialogue:SetCallback(doLoad)
	end
	-- ]]--
	
	local save = vgui.Create("DButton", gearheadpanel)
	save:SetText("Save...")
	save:SizeToContentsX()
	save:SetWide(save:GetWide() + 4)
	save:SetTall(label:GetTall() + 2)
	save:SetPos(label:GetWide() + 5, 0)
	save.DoClick = createSaveMenu
	
	
	local load = vgui.Create("DButton", gearheadpanel)
	load:SetText("Load...")
	load:SizeToContentsX()
	load:SetWide(save:GetWide() + 4)
	load:SetTall(label:GetTall() + 2)
	load:SetPos(label:GetWide() + save:GetWide() + 10, 0)
	load.DoClick = createLoadMenu
	
	gearheadpanel:SizeToContentsX()
	gearheadpanel:SetTall(load:GetTall())
	entrylist:AddItem(gearheadpanel)
	entrylist:AddItem(spacer)
	
	
	createSlidersForAmmo[ammotype](self, entrylist, spacer)
	
	-- TODO: ammo stats
	
	entrylist:SizeToContents()
	
	self.ClassPanel:SetContents(entrylist)
	self.ClassPanel:SetExpanded(true)
	
	-- this overrides the selection behaviour of the gun select list
	RunConsoleCommand("xcfmenu_id", self.Crate.id)
	RunConsoleCommand("xcfmenu_mdl", self.Crate.model)
	RunConsoleCommand("xcfmenu_type", self.Crate.ent)
	
	self:InvalidateLayout()
	
end


function PANEL:GetAmmoData(input2)
	if not (self.Gun and self.Ammo) then return nil end
	
	local input = {}
	input2 = input2 or {}
		input["Id"] = 			input2["Id"] or self.Gun.id
		input["Type"] = 		input2["Type"] or self.Ammo
		input["PropLength"] = 	input2["PropLength"] or (self.PropLengthSlider and IsValid(self.PropLengthSlider) and self.PropLengthSlider:GetValue() or 0)
		input["ProjLength"] = 	input2["ProjLength"] or (self.ProjLengthSlider and IsValid(self.ProjLengthSlider) and self.ProjLengthSlider:GetValue() or 0)
		input["Data5"] = 		input2["Data5"] or (self.FillerSlider and IsValid(self.FillerSlider) and self.FillerSlider:GetValue() or self.CavitySlider and IsValid(self.CavitySlider) and self.CavitySlider:GetValue() or 0)
		input["Data6"] = 		input2["Data6"] or (self.CrushSlider and IsValid(self.CrushSlider) and self.CrushSlider:GetValue() or 0)
		input["Data7"] = 		0
		input["Data8"] = 		0
		input["Data9"] = 		0
		input["Data10"] = 		input2["Data10"] or (self.TracerBox and IsValid(self.TracerBox) and self.TracerBox:GetChecked() and 1 or 0)
	local conversion = ACF.RoundTypes[self.Ammo].convert
	
	if not conversion then return nil end
	return conversion( nil, input ), input
end


local maxCPTall = surface.ScreenHeight()/2 - 20


function PANEL:PerformLayout()	

	local ypos = 0
	
	self.CrateLabel:SetPos(0, 0)
	ypos = ypos + self.CrateLabel:GetTall()
	
	self.CrateList:SetPos(0, ypos)
	self.CrateList:SetSize(self:GetWide(), 20)
	
	ypos = ypos + self.CrateList:GetTall() + 5
	
	self.AmmoTypeLabel:SetPos(0, ypos)
	ypos = ypos + self.AmmoTypeLabel:GetTall()
	
	self.AmmoTypeList:SetPos(0, ypos)
	self.AmmoTypeList:SetSize(self:GetWide(), 20)
	
	ypos = ypos + self.AmmoTypeList:GetTall()
	
	if self.ClassPanel and IsValid(self.ClassPanel) then
		self.ClassPanel:SetPos(0, ypos)
		self.ClassPanel:SizeToContents()
		self.ClassPanel:SetWide(self:GetWide())
		
		ypos = ypos + self.ClassPanel:GetTall()
		
		self:SetTall(ypos)
		
		local bulletdata = self:GetAmmoData()
		
		if XCF.Debug then printByNameTable(bulletdata, "self.BulletData") print("\n\n\n") end
		
		if bulletdata then			
			local func
			for k, v in pairs(bulletdata) do
				func = modifyControlsWith[k]
				if func then func(self, v) end
			end
			
			RunConsoleCommand( "xcfmenu_data1",  self.Gun.id )
			RunConsoleCommand( "xcfmenu_data2",  self.Ammo )
			RunConsoleCommand( "xcfmenu_data3",  math.Round(bulletdata.PropLength or 0, 3) )
			RunConsoleCommand( "xcfmenu_data4",  math.Round(bulletdata.ProjLength or 0, 3) )
			RunConsoleCommand( "xcfmenu_data5",  math.Round(bulletdata.FillerVol or bulletdata.CavVol or 0, 3) )
			RunConsoleCommand( "xcfmenu_data6",  math.Round(bulletdata.ConeAng or 0, 3) )
			RunConsoleCommand( "xcfmenu_data10", bulletdata.Tracer or 0 )
		end
		
	else
		self:SetTall(ypos)
	end	
	
	if self:GetTall() > maxCPTall then
		self:SetTall(maxCPTall)
	end
end


function PANEL:WatchSliders()
	local last, val
	for k, v in pairs(self.SliderWatchList) do
		//print(k, v)
		if not (v and IsValid(v)) then continue end
		last = v.lastValWatched or 0
		val = v:GetValue()
		
		if last != val then
			self:InvalidateLayout()
		end
		
		v.lastValWatched = val
	end
end



function PANEL:GetInfoTable()
	
	local tbl = {
		["ent"] = self.Crate.ent,
		["id"]	= self.Crate.id,
	}
	
	tbl[1] = self.Crate.id
	tbl[2] = self.Gun.id
	tbl[3] = self.Ammo
	
	local bulletdata = self:GetAmmoData()
	
	tbl[4] = math.Round(bulletdata.PropLength or 0, 3)
	tbl[5] = math.Round(bulletdata.ProjLength or 0, 3)
	tbl[6] = math.Round(bulletdata.FillerVol or bulletdata.CavVol or 0, 3)
	tbl[7] = math.Round(bulletdata.ConeAng or 0, 3)
	tbl[11] = bulletdata.Tracer or 0
	
	return tbl
end



function PANEL:Think()
	local selpanel = self:GetParent().SelectPanel
	
	if self:GetParent() and selpanel then
		local entry = selpanel:GetSelectedEntry()
		if entry and entry != self.Gun then
			self:SetGunAmmo(entry, self.Ammo or "AP")
		end
	end
	
	local ent = GetConVarString("xcfmenu_type")
	
	if ent != self.Crate.ent then
		self:SetGunAmmo(self.Gun, self.Ammo or "AP")
	end
	
	self:WatchSliders()
end

derma.DefineControl( "XCF_ToolMenuAmmoPanel", "Menu panel for an XCF gun", PANEL, "DPanel" )
