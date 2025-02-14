ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Ephemeral = true

function ENT:Initialize()
	self:DrawShadow(false)
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
end

function ENT:AddDamage(damage, attacker)
	local owner = self:GetOwner()
	if damage > 0 and owner:IsValid() and owner.HFireDamageTakenMul then
		damage = damage * owner.HFireDamageTakenMul
	end

	self:SetDamage(self:GetDamage() + damage)
	if attacker then
		self.Damager = attacker
	end
end

function ENT:SetDamage(damage)
	self:SetDTFloat(0, damage)
end

function ENT:GetDamage()
	return self:GetDTFloat(0)
end