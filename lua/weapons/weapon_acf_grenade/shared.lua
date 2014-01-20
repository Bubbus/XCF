	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "grenade"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Grenade"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make groups of dudes disappear."
	SWEP.Instructions       = "Reload at Bomb Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV               = 65

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel 		= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ThrowModel 		= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 3
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"
SWEP.Primary.Sound 			= "Weapon_Grenade.Fire"

SWEP.ReloadTime				= 3

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 4
SWEP.MaxInaccuracy = 16
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.2
SWEP.AccuracyDecay = 0.7
SWEP.InaccuracyPerShot = 12
SWEP.InaccuracyCrouchBonus = 1
SWEP.InaccuracyDuckPenalty = 4

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.07

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.GrenadeRemove		= true
SWEP.HasChargeTimer		= true
SWEP.ChargeTime = 3



function SWEP:InitBulletData()
	
	self.BulletData = {}
	self.BulletData["BoomPower"]	= 0.49494626772744
	self.BulletData["Caliber"]		= 8
	self.BulletData["DragCoef"]		= 0.0017372329950914
	self.BulletData["FillerMass"]	= 0.49414201812744
	self.BulletData["FrAera"]		= 50.2656
	self.BulletData["Id"]			= "8cmB4"
	self.BulletData["KETransfert"]	= 0.1
	self.BulletData["LimitVel"]		= 100
	self.BulletData["MuzzleVel"]	= 24.160096985541
	self.BulletData["PenAera"]		= 27.930598395101
	self.BulletData["ProjLength"]	= 12
	self.BulletData["ProjMass"]		= 2.8934288113354
	self.BulletData["PropLength"]	= 0.01
	self.BulletData["PropMass"]		= 0.0008042496
	self.BulletData["Ricochet"]		= 60
	self.BulletData["RoundVolume"]	= 603.689856
	self.BulletData["ShovePower"]	= 0.1
	self.BulletData["Tracer"]		= 0
	self.BulletData["Type"]			= "HE"
end



//*
function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.PressedTime = CurTime()
		if SERVER then
			self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		end
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end
//*/



function SWEP:ThinkBefore()
	
	if self.PressedTime and not self.Owner:KeyDown(IN_ATTACK) then
		
		self.PressedDuration = CurTime() - self.PressedTime
		self.PressedTime = nil
		
		if SERVER then
			self:ShootEffects()
			self.Weapon:EmitSound( self.Primary.Sound )
			self.Weapon:TakePrimaryAmmo(1)
			self:FireBullet()
		end
		
		self.PressedDuration = nil
		self:VisRecoil()
		self.Inaccuracy = math.Clamp(self.Inaccuracy + self.InaccuracyPerShot, self.MinInaccuracy, self.MaxInaccuracy)
	end
	
end


function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_THROW )		// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	// 3rd Person Animation
end