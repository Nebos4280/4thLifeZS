ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Ephemeral = true

AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
		hook.Add("PlayerHurt", self, self.PlayerHurt)

		self:SetDTInt(1, 0)
	end

	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end
