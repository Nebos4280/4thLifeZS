INC_CLIENT()

include("cl_animations.lua")

ENT.NextEmit = 0

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/gas/steam2.wav")
	local weptab = weapons.Get("weapon_zs_pulsegasgrenade")
	if weptab then
		if weptab.WElements then
			self.WElements = table.FullCopy(weptab.WElements)
			self:CreateModels(self.WElements)
		end
	end
end

function ENT:Think()
	if not self:GetGasEmit() then return end

	self.AmbientSound:PlayEx(0.80, 250 + CurTime() % 1)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	self:RemoveModels()
end

local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	if (not self.NoDrawSubModels) then
		self:RenderModels()
	end

	render.SetBlend(0)
	self:DrawModel()

	if not self:GetGasEmit() then return end

	local time = CurTime()

	if time < self.NextEmit then return end
	self.NextEmit = time + 0.07

	local particle
	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	local vel = Vector(0, 0, 170)
	for i=1, 7 do
		local angler = AngleRand()
		local dist = math.Rand(0, self.Radius)
		particle = emitter:Add(math.random(2) == 1 and "particle/smokesprites_0003" or "particle/smokestack", pos)
		particle:SetColor(110, 70, 110)
		particle:SetVelocity(vel * math.Rand(0.5, 1) + Vector(math.cos(angler.y) * dist, math.sin(angler.y) * dist, 0)/1.21)
		particle:SetGravity(vel * -0.95)
		particle:SetDieTime(math.Rand(1.85, 2.4))
		particle:SetStartAlpha(math.random(150, 200))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(11, 19))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetCollide(true)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end