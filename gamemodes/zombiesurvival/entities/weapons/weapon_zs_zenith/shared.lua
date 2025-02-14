SWEP.PrintName = "Zenith Blade"
SWEP.Description = "Much was conquered and this blade had reached its zenith."

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee"

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 75
SWEP.MeleeRange = 70
SWEP.MeleeSize = 3
SWEP.MeleeKnockBack = 25

SWEP.Primary.Delay = 1.4

SWEP.DamageType = DMG_CLUB

SWEP.Tier = 5

SWEP.WalkSpeed = SPEED_SLOWEST

SWEP.SwingRotation = Angle(0, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.4
SWEP.SwingHoldType = "melee"

SWEP.Secondary.Automatic = false

SWEP.Pulse = true
SWEP.PulseSlowPower = 9

SWEP.Burn = false
SWEP.BurnChance = 1
SWEP.BurnDamage = 8

SWEP.Ice = false
SWEP.IceSlowPower = 9

SWEP.AllowQualityWeapons = true

function SWEP:Initialize()
    self:SetElementalState(0)

	self.BaseClass.Initialize(self)
end

function SWEP:SetElementalState(ElementalState)
	self:SetDTInt(2, ElementalState)
end

function SWEP:GetElementalState()
	return self:GetDTInt(2)
end

function SWEP:DoElementalStuff()
	self:SetElementalState(self:GetElementalState() + 1)

	if self:GetElementalState() >= 3 then
		self:SetElementalState(0)
	end

    if self:GetElementalState() == 0 then
        self.Pulse = true
        self.Ice = false
        self.Burn = false

        if CLIENT then
            self.VElements["zenith_blade"].color = Color(75, 0, 130, 255)
            self.VElements["zenith_grip"].color = Color(75, 0, 130, 255)
            self.VElements["zenith_cutaway"].color = Color(75, 0, 130, 255)

            self.WElements["zenith_blade"].color = Color(75, 0, 130, 255)
            self.WElements["zenith_grip"].color = Color(75, 0, 130, 255)
            self.WElements["zenith_cutaway"].color = Color(75, 0, 130, 255)
        end
    end
    
    if self:GetElementalState() == 1 then
        self.Pulse = false
        self.Ice = false
        self.Burn = true

        if CLIENT then
            self.VElements["zenith_blade"].color = Color(225, 25, 0, 255)
            self.VElements["zenith_grip"].color = Color(225, 25, 0, 255)
            self.VElements["zenith_cutaway"].color = Color(225, 25, 0, 255)
    
            self.WElements["zenith_blade"].color = Color(225, 25, 0, 255)
            self.WElements["zenith_grip"].color = Color(225, 25, 0, 255)
            self.WElements["zenith_cutaway"].color = Color(225, 25, 0, 255)
        end
    end

    if self:GetElementalState() == 2 then
        self.Pulse = false
        self.Burn = false
        self.Ice = true

        if CLIENT then
            self.VElements["zenith_blade"].color = Color(100, 160, 255, 255)
            self.VElements["zenith_grip"].color = Color(100, 160, 255, 255)
            self.VElements["zenith_cutaway"].color = Color(100, 160, 255, 255)
    
            self.WElements["zenith_blade"].color = Color(100, 160, 255, 255)
            self.WElements["zenith_grip"].color = Color(100, 160, 255, 255)
            self.WElements["zenith_cutaway"].color = Color(100, 160, 255, 255)
        end
    end
end

function SWEP:SecondaryAttack()
    self:DoElementalStuff()
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 85))
end

function SWEP:PlayHitSound()
	self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 75)
end

function SWEP:GetTracesNumPlayers(traces)
	local numplayers = 0

	local ent
	for _, trace in pairs(traces) do
		ent = trace.Entity
		if ent and ent:IsValidPlayer() then
			numplayers = numplayers + 1
		end
	end

	return numplayers
end

function SWEP:GetDamage(numplayers, basedamage)
	basedamage = basedamage or self.MeleeDamage

	if numplayers then
		return basedamage * math.Clamp(1.25 - numplayers * 0.25, 0.5, 1)
	end

	return basedamage
end

function SWEP:MeleeSwing()
	local owner = self:GetOwner()

	owner:DoAttackEvent()
	self:SendWeaponAnim(self.MissAnim)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	local hit = false
	local tr = owner:CompensatedPenetratingMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)
	local damage = self:GetDamage(self:GetTracesNumPlayers(tr))
	local ent

	local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1 --(owner.BuffMuscular and owner:Team()==TEAM_HUMAN) and 1.2 or 1
	if owner:IsSkillActive(SKILL_LASTSTAND) then
		if owner:Health() <= owner:GetMaxHealth() * 0.25 then
			damagemultiplier = damagemultiplier * 2
		else
			damagemultiplier = damagemultiplier * 0.85
		end
	end
	
	for _, trace in ipairs(tr) do
		if not trace.Hit then continue end

		ent = trace.Entity

		hit = true
		
		local hitflesh = trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH

		if hitflesh then
			util.Decal(self.BloodDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)

			if SERVER then
				self:ServerHitFleshEffects(ent, trace, damagemultiplier)
			end

		end

		if ent and ent:IsValid() then
			
			if SERVER then
				self:ServerMeleeHitEntity(trace, ent, damagemultiplier)
			end

			self:MeleeHitEntity(trace, ent, damagemultiplier, damage)

			if SERVER then
				self:ServerMeleePostHitEntity(trace, ent, damagemultiplier)
			end

			if owner.GlassWeaponShouldBreak then break end
		end
	end

	if hit then
		self:PlayHitSound()
	else
		self:PlaySwingSound()

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end
end

function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier, damage)
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	if SERVER and hitent:IsPlayer() and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
		damagemultiplier = damagemultiplier * 3.5
		owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
	end

	damage = damage * damagemultiplier

	local dmginfo = DamageInfo()
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetAttacker(owner)
	dmginfo:SetDamageType(self.DamageType)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(damage)
	dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

	local vel
	if hitent:IsPlayer() then

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(self:GetPowerCombo() + 1)

			damage = damage + damage * (owner.MeleePowerAttackMul - 1) * (self:GetPowerCombo()/4)
			dmginfo:SetDamage(damage)

			if self:GetPowerCombo() >= 4 then
				self:SetPowerCombo(0)
				if SERVER then
					local pitch = math.Clamp(math.random(90, 110) + 15 * (1 - damage/45), 50 , 200)
					owner:EmitSound("npc/strider/strider_skewer1.wav", 75, pitch)
				end
			end
		end

		hitent:MeleeViewPunch(damage)
		if hitent:IsHeadcrab() then
			damage = damage * 2
			dmginfo:SetDamage(damage)
		end

		if SERVER then
			hitent:SetLastHitGroup(tr.HitGroup)
			if tr.HitGroup == HITGROUP_HEAD then
				hitent:SetWasHitInHead()
			end

			if hitent:WouldDieFrom(damage, tr.HitPos) then
				dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
			end
		end

		vel = hitent:GetVelocity()
	else
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end

	--if not hitent.LastHeld or CurTime() >= hitent.LastHeld + 0.1 then -- Don't allow people to shoot props out of their hands
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end

		hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())

		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- Invalidate the engine knockback vs. players
		if vel then
			hitent:SetLocalVelocity(vel)
		end
	--end

	-- Perform our own knockback vs. players
	if hitent:IsPlayer() then
		local knockback = self.MeleeKnockBack * (owner.MeleeKnockbackMultiplier or 1)
		if knockback > 0 then
			hitent:ThrowFromPositionSetZ(tr.StartPos, knockback, nil, true)
		end

		if owner.MeleeLegDamageAdd and owner.MeleeLegDamageAdd > 0 then
			hitent:AddLegDamage(owner.MeleeLegDamageAdd)
		end
	end

	local owner = self:GetOwner()
	if not owner:IsValidLivingHuman() then owner = self end

   if SERVER then 
	 if hitent then
		 local target = hitent
		 local shocked = {}
		 
		 if target then
			 shocked[target] = true
			 for i = 1, 3 do
				 local tpos = target:WorldSpaceCenter()
 
				 for k, ent in pairs(ents.FindInSphere(tpos, 120)) do
					 if not shocked[ent] and ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
						 if WorldVisible(tpos, ent:NearestPoint(tpos)) then
							 shocked[ent] = true
							 target = ent
 
							 timer.Simple(i * 0.07, function()
								 if not ent:IsValid() or not ent:IsValidLivingZombie() or not WorldVisible(tpos, ent:NearestPoint(tpos)) then return end
 
								 target:TakeSpecialDamage(self.MeleeDamage * 0.55, DMG_DISSOLVE, owner, owner:GetActiveWeapon())
 
								 if self.Burn and not ent:IsOnFire() then
									local fire = ent:GiveStatus("human_fire")
									if fire and fire:IsValid() then
										fire:AddDamage(self.BurnDamage)
										fire.Damager = owner
									end
								end
								if self.Ice then
									ent:AddLegDamageExt(4, owner, self, SLOWTYPE_COLD)
								end

								if self.Pulse then
									ent:AddLegDamageExt(4, owner, self, SLOWTYPE_PULSE)
								end
 
								 local worldspace = ent:WorldSpaceCenter()
								 effectdata = EffectData()
									 effectdata:SetOrigin(worldspace)
									 effectdata:SetStart(tpos)
									 effectdata:SetEntity(target)
								 util.Effect("tracer_zapper", effectdata)
							 end)
 
							 break
						 end
					 end
				 end
			 end
		 end
	 end
 end
 
	 local effectdata = EffectData()
	 effectdata:SetOrigin(tr.HitPos)
	 effectdata:SetStart(tr.StartPos)
	 effectdata:SetNormal(tr.HitNormal)
	 util.Effect("RagdollImpact", effectdata)
	 if not tr.HitSky then
		 effectdata:SetSurfaceProp(tr.SurfaceProps)
		 effectdata:SetHitBox(tr.HitBox)
		 effectdata:SetEntity(hitent)
		 util.Effect("Impact", effectdata)
	 end
 end