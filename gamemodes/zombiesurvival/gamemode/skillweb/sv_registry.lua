GM:SetSkillModifierFunction(SKILLMOD_HEALTH, function(pl, amount)
	pl.HealthAdded = math.Clamp(amount, -10000, 10000)

	local current = pl:GetMaxHealth()
	local new = math.max(math.Round((100 + (pl.HealthAdded or 0)) * (pl.HealthMul or 1), 0),1)
	pl:SetMaxHealth(new)
	pl:SetHealth(math.max(1, pl:Health() / current * new))
end)

GM:SetSkillModifierFunction(SKILLMOD_HEALTH_MUL, function(pl, amount)
	pl.HealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
	
	local current = pl:GetMaxHealth()
	local new = math.max(math.Round((100 + (pl.HealthAdded or 0)) * (pl.HealthMul or 1), 0),1)
	pl:SetMaxHealth(new)
	pl:SetHealth(math.max(1, pl:Health() / current * new))
end)

GM:SetSkillModifierFunction(SKILLMOD_POINTS, function(pl, amount)
	if not pl.AdjustedStartPointsSkill then
		pl:SetPoints(pl:GetPoints() + amount)
		pl.AdjustedStartPointsSkill = true
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_SCRAP_START, function(pl, amount)
	if not pl.AdjustedStartScrapSkill then
		pl:GiveAmmo(amount, "scrap")
		pl.AdjustedStartScrapSkill = true
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_FOODRECOVERY_MUL, function(pl, amount)
	pl.FoodRecoveryMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_DAMAGE_MUL, function(pl, amount)
	pl.FallDamageDamageMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_RECOVERY_MUL, function(pl, amount)
	pl.FallDamageRecoveryMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_POINT_MULTIPLIER, function(pl, amount)
	pl.PointIncomeMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_SPEED_MUL, function(pl, amount)
	pl.ControllableSpeedMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_HANDLING_MUL, function(pl, amount)
	pl.ControllableHandlingMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_HEALTH_MUL, function(pl, amount)
	pl.ControllableHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MANHACK_HEALTH_MUL, function(pl, amount)
	pl.ManhackHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MANHACK_DAMAGE_MUL, function(pl, amount)
	pl.ManhackDamageMul = math.Clamp(amount + 1.0, 0.0, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DRONE_SPEED_MUL, function(pl, amount)
	pl.DroneSpeedMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DRONE_CARRYMASS_MUL, function(pl, amount)
	pl.DroneCarryMassMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_TURRET_HEALTH_MUL, function(pl, amount)
	pl.TurretHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_TURRET_SCANSPEED_MUL, function(pl, amount)
	pl.TurretScanSpeedMul = math.Clamp(amount + 1.0, 0, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_TURRET_SCANANGLE_MUL, function(pl, amount)
	pl.TurretScanAngleMul = math.Clamp(amount + 1.0, 0, 2.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DEPLOYABLE_HEALTH_MUL, function(pl, amount)
	pl.DeployableHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DEPLOYABLE_PACKTIME_MUL, function(pl, amount)
	pl.DeployablePackTimeMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RESUPPLY_DELAY_MUL, function(pl, amount)
	pl.ResupplyDelayMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_WELFARE_MUL, function(pl, amount)
	pl.WelfareMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FIELD_RANGE_MUL, function(pl, amount)
	pl.FieldRangeMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FIELD_DELAY_MUL, function(pl, amount)
	pl.FieldDelayMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DEP_DELAY_MUL, function(pl, amount)
	pl.DeployableDelayMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DEP_DAMAGE_MUL, function(pl, amount)
	pl.DeployableDamageMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DEP_RANGE_MUL, function(pl, amount)
	pl.DeployableRangeMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

GM:AddSkillModifier(SKILL_PITCHER, SKILLMOD_PROP_THROW_STRENGTH_MUL, 0.1)
