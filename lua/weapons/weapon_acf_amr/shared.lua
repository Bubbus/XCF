	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Anti-Tank Rifle"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make tanks disappear."
	SWEP.Instructions       = "Reload at 37mm SA Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
--SWEP.ViewModel 			= "models/weapons/v_sniper.mdl";
--SWEP.WorldModel 		= "models/weapons/w_sniper.mdl";
SWEP.ViewModel 			= "models/weapons/v_snip_awp.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_awp.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 15
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 15
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "acf_extra/tankfx/gnomefather/40mm3.wav"

SWEP.ReloadTime				= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = Vector(0, 5, 0)
SWEP.ScopeChopAngle = Angle(0, 90, 0)
SWEP.WeaponBone = "v_weapon.sg550_Parent"

SWEP.MinInaccuracy = 3
SWEP.MaxInaccuracy = 16
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.06
SWEP.AccuracyDecay = 0.5
SWEP.InaccuracyPerShot = 16
SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 8

SWEP.HasZoom = true
SWEP.HasScope = true
SWEP.ZoomInaccuracyMod = 0.01
SWEP.ZoomDecayMod = 1.6
SWEP.ZoomFOV = 25

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.003 / 1
SWEP.StaminaJumpDrain = 0.1

SWEP.Class = "SA"
SWEP.FlashClass = "MO"
SWEP.Launcher = false


function SWEP:InitBulletData()

	self.BulletData = {}
	
	self.BulletData["Id"]			= "37mmSA"
	self.BulletData["Type"]			= "APHE"
	self.BulletData["BlastRadius"]			= 14.577878330004
	self.BulletData["BoomPower"]			= 0.587458936416
	self.BulletData["Caliber"]			= 3.7
	self.BulletData["DragCoef"]			= 0.0015733692094167
	self.BulletData["FillerMass"]			= 0.0238755
	self.BulletData["FillerVol"]			= 14.47
	self.BulletData["FrAera"]			= 10.752126
	self.BulletData["FragMass"]			= 0.012213088075815
	self.BulletData["FragVel"]			= 538.16023797266
	self.BulletData["Fragments"]			= 54
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 700
	self.BulletData["MaxFillerVol"]			= 34.856363124408
	self.BulletData["MaxPen"]			= 35.025173416703
	self.BulletData["MaxProjLength"]			= 10.888648648649
	self.BulletData["MaxPropLength"]			= 34.538648648649
	self.BulletData["MaxTotalLength"]			= 45
	self.BulletData["MinFillerVol"]			= 0
	self.BulletData["MinProjLength"]			= 5.55
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 1316.0030889388
	self.BulletData["PenAera"]			= 7.529570314926
	self.BulletData["ProjLength"]			= 9.11
	self.BulletData["ProjMass"]			= 0.683382256094
	self.BulletData["ProjVolume"]			= 97.95186786
	self.BulletData["PropLength"]			= 32.76
	self.BulletData["PropMass"]			= 0.563583436416
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 450.19151562
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["Tracer"]			= 1.3513513513514
	self.BulletData["InvalidateTraceback"]			= true

	if SERVER then
		self.BulletData.CallbackEndFlight = self.CallbackEndFlight
	end
	
end