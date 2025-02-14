SWEP.PrintName = "Tachyonic 'Spinfusor' Pulse Disc Launcher"
SWEP.Description = "A device capable of firing volatile pulse discs that detonate upon impact."

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

sound.Add(
{
	name = "Weapon_Slayer.Single",
	channel = CHAN_AUTO,
	volume = 1,
	soundlevel = 100,
	pitch = {125, 135},
	sound = {"weapons/physcannon/superphys_launch2.wav", "weapons/physcannon/superphys_launch3.wav"}
})

SWEP.Base = "weapon_zs_baseproj"

SWEP.HoldType = "crossbow"

SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Damage = 80
SWEP.Primary.Delay = 0.3
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pulse"
SWEP.Primary.Sound = Sound("Weapon_Slayer.Single")

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 30
SWEP.RequiredClip = 5

SWEP.ReloadSpeed = 1

SWEP.Recoil = 3

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.ConeMax = 0
SWEP.ConeMin = 0

SWEP.Tier = 5

SWEP.FireAnimSpeed = 0.3

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)

function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/ar2/ar2_reload.wav", 75, 100, 1, CHAN_WEAPON + 21)
		self:EmitSound("weapons/smg1/smg1_reload.wav", 75, 100, 1, CHAN_WEAPON + 22)
	end
end

util.PrecacheSound("weapons/ar2/ar2_reload.wav")
util.PrecacheSound("weapons/smg1/smg1_reload.wav")
