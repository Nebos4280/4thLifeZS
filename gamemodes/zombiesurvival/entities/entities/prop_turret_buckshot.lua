AddCSLuaFile()

ENT.Base = "prop_turret_base"

ENT.SWEP = "weapon_zs_turret_buckshot"

ENT.AmmoType = "buckshot"
ENT.FireDelay = 0.75
ENT.NumShots = 8
ENT.Damage = 8
ENT.PlayLoopingShootSound = false
ENT.Spread = 5
ENT.SearchDistance = 225
ENT.MaxAmmo = 100
ENT.ScanAngle = 1
ENT.Burn = true

if CLIENT then

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	local ent = ClientsideModel("models/weapons/w_shotgun.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:Spawn()
		self.GunAttachment = ent
	end
end

function ENT:DrawTranslucent()
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	self.BaseClass.DrawTranslucent(self)
end

function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end

end

function ENT:PlayShootSound()
	self:EmitSound("Weapon_Shotgun.NPC_Single")
end
