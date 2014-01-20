	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Heavy Rifle"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes disappear."
	SWEP.Instructions       = "Reload at 12.7mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_snip_sg550.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_SG550.Single"

SWEP.ReloadTime				= 4

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = Vector(0, 5, 0)
SWEP.ScopeChopAngle = Angle(0, 90, 0)
SWEP.WeaponBone = "v_weapon.sg550_Parent"

SWEP.MinInaccuracy = 0.25
SWEP.MaxInaccuracy = 8
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.12
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 6
SWEP.InaccuracyCrouchBonus = 1.4
SWEP.InaccuracyDuckPenalty = 6

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.1

SWEP.HasZoom = true
SWEP.HasScope = true
SWEP.ZoomInaccuracyMod = 0.5
SWEP.ZoomDecayMod = 1.3
SWEP.ZoomFOV = 30

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false


function SWEP:InitBulletData()

	self.BulletData = {}	
	
	self.BulletData["Type"]			= "AP"
	self.BulletData["Id"]			= "12.7mmMG"
	self.BulletData["BoomPower"]			= 0.01770197352
	self.BulletData["Caliber"]			= 1.45
	self.BulletData["DragCoef"]			= 0.0036166365280289
	self.BulletData["FrAera"]			= 1.6513035
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 12.541676305848
	self.BulletData["MaxProjLength"]			= 12.8
	self.BulletData["MaxPropLength"]			= 15.139554903142
	self.BulletData["MaxTotalLength"]			= 19.5
	self.BulletData["MinProjLength"]			= 2.175
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 902.31769083282
	self.BulletData["PenAera"]			= 1.5316264800639
	self.BulletData["ProjLength"]			= 3.5
	self.BulletData["ProjMass"]			= 0.045658541775
	self.BulletData["ProjVolume"]			= 5.77956225
	self.BulletData["PropLength"]			= 6.7
	self.BulletData["PropMass"]			= 0.01770197352
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 16.8432957
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["InvalidateTraceback"]			= true
	
	
	if SERVER then
		self.BulletData.CallbackEndFlight = self.CallbackEndFlight
	end
	
end