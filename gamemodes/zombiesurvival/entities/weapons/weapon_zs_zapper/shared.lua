SWEP.PrintName = "'Stinger' Zapper"
SWEP.Description = "Zaps any zombies that enter proximity, prioritizing headcrabs. Has a long recharge and uses pulse ammo.\nPress PRIMARY ATTACK to deploy the zapper.\nPress SECONDARY ATTACK and RELOAD to rotate the zapper."

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = Model("models/props_c17/utilityconnecter006c.mdl")

SWEP.AmmoIfHas = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "zapper"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 30

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

SWEP.ModelScale = 0.75

SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST

SWEP.ResupplyAmmoType = "pulse"

SWEP.GhostStatus = "ghost_zapper"
SWEP.DeployClass = "prop_zapper"

SWEP.NoDeploySpeedChange = true
SWEP.AllowQualityWeapons = true

SWEP.Tier = 3

SWEP.LegDamage = 10

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_LEG_DAMAGE, 2)

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
	self:SetDeploySpeed(1.1)
	self:HideViewAndWorldModel()
end

function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end
	
	local dCount = 0
	local dList = ents.FindByClassAndParent("prop_*", self:GetOwner())
	if dList then
		for k, v in pairs(dList) do
			local dLimited = {"zapper", "gunturret"}
			for k2, v2 in pairs(dLimited) do
				if string.match(v:GetClass(), v2) then
					dCount = dCount + 1
					if dCount >= 2 then
						if not timer.Exists("check") then
							self:GetOwner():PrintMessage(HUD_PRINTTALK, "Maximum deployables placed.")
							timer.Create("check", 5, 1)
						end
						return false
					end
				end
			end
		end
	end
		
	return true
end

function SWEP:Holster()
	return true
end
