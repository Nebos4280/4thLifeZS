AddCSLuaFile()

SWEP.PrintName = "Pot"
SWEP.Description = "A simple culinary weapon that heals you on kill."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/pot02a.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 40
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.15

SWEP.UseMelee1 = true

SWEP.Primary.Delay = 0.8

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.3
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true

SWEP.Tier = 1

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1)

function SWEP:OnZombieKilled(zombie)
	local killer = self:GetOwner()

	killer:SetHealth(math.Clamp(killer:Health() + 5, 0, killer:GetMaxHealth()))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg")
end
