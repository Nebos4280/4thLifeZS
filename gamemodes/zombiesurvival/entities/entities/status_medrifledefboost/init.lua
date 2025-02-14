INC_SERVER()

if SERVER then
	function ENT:SetDie(fTime)
		if fTime == 0 or not fTime then
			self.DieTime = 0
		elseif fTime == -1 then
			self.DieTime = 999999999
		else
			self.DieTime = CurTime() + fTime
			self:SetDuration(fTime)
		end
	end
end

function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if ent ~= self:GetOwner() then return end

		if attacker:IsValidZombie() and ent:IsPlayer() then
		local dmgfraction = dmginfo:GetDamage() * 0.3
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.7)

		local points = dmginfo:GetDamage() * 0.015
		if self.Applier and self.Applier:IsValidLivingHuman() and ent:IsPlayer() and ent:Team() == TEAM_ZOMBIE then
		local applier = self.Applier

		if applier:IsValidLivingHuman() then
			applier.DefenceDamage = (applier.DefenceDamage or 0) + dmgfraction
			applier.PointQueue = self.Applier.PointQueue + points * 1.15
		    end
		end
	end
end
