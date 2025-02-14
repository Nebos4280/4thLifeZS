AddCSLuaFile()

SWEP.Base = "weapon_zs_turret_base"

SWEP.PrintName = "Blast Turret"
SWEP.Description = "An automated turret that fires spread shots.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 5.5

SWEP.GhostStatus = "ghost_turret_buckshot"
SWEP.DeployClass = "prop_turret_buckshot"
SWEP.TurretAmmoType = "buckshot"
SWEP.TurretAmmoStartAmount = 25
SWEP.TurretSpread = 5

SWEP.Primary.Ammo = "turret_buckshot"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.9)

SWEP.Tier = 4
