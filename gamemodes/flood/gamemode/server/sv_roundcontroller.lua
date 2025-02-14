util.AddNetworkString("RoundState")
GM.GameState = GAMEMODE and GAMEMODE.GameState or 0
GM.RoundTime = 0

--
-- Game States
-- 0 = Waiting for players to join
-- 1 = Building Phase
-- 2 = Flood Phase
-- 3 = Fight Phase
-- 4 = Reset Phase
--

-- 
function GM:GetGameState()
	return self.GameState
end

function GM:SetGameState(state)
	self.GameState = state
	
	if state == 3 then
		self.RoundTime = CurTime()
		for k, v in pairs(player.GetAll()) do
			if not v:IsBot() then
				v.SurvivalTime = CurTime()
			end
		end
	elseif state == 4 then
		self.RoundTime = CurTime() - self.RoundTime
		
		for k, v in pairs(player.GetAll()) do
			if not v:IsBot() and v: Alive() then
				v.SurvivalTime = CurTime() - v.SurvivalTime
			end
		end
		
		self:EndOfRound(self.RoundTime)
	end
end

function GM:EndOfRound(RoundTime)
	timer.Simple(1, function()
		for k, v in pairs(player.GetAll()) do
			if not v:IsBot() then
				local XPReward = 20 + math.Clamp(v.SurvivalTime / RoundTime * 40, 0, 40) + math.min(v.SurvivalTime / 10, 0)
				AddXP(v, XPReward)
			end
		end
	end)
end

function GM:GetStateStart()
	return self.StateStart
end

function GM:GetStateRunningTime()
	return CurTime() - self.StateStart
end

local tNextThink = 0
function GM:TimerController()
	if CurTime() >= tNextThink then
		if self:GetGameState() == 0 then
			self:CheckPhase()
		elseif self:GetGameState() == 1 then
			self:BuildPhase()
		elseif self:GetGameState() == 2 then
			self:FloodPhase()
		elseif self:GetGameState() == 3 then
			self:FightPhase()
		elseif self:GetGameState() == 4 then
			self:ResetPhase()
		end

		local gState = self:GetGameState() -- Because gamestate was nil every other way -_-
		net.Start("RoundState")
			net.WriteFloat(gState)
			net.WriteFloat(Flood_buildTime)
			net.WriteFloat(Flood_floodTime)
			net.WriteFloat(Flood_fightTime)
			net.WriteFloat(Flood_resetTime)
		net.Broadcast()

		tNextThink = CurTime() + 1
	end
end

function GM:CheckPhase()
	local count = 0
	for _, v in pairs(player.GetAll()) do
		if IsValid(v) and v:Alive() then
			count = count + 1
		end
	end

	if count >= 2 then
		-- Time to build
		self:SetGameState(1)

		-- Clean the map, game is about to start
		self:CleanupMap()

		-- Respawn all the players
		for _, v in pairs(player.GetAll()) do
			if IsValid(v) then
				v:Spawn()
			end
		end
	end
end

function GM:BuildPhase()
	if Flood_buildTime <= 0 then
		-- Time to Flood
		self:SetGameState(2) 

		-- Nobody can respawn now
		for _, v in pairs(player.GetAll()) do
			if IsValid(v) then
				v:SetCanRespawn(false)

				v.ClaimedARoom = false -- for func_teamblocker
			end
		end

		-- Prep phase two
		for _, v in pairs(self:GetActivePlayers()) do
			v:StripWeapons()
			v:RemoveAllAmmo()
			v:SetHealth(100)
			v:SetArmor(0)
		end
	
		for k, v in pairs(ents.FindByClass("func_teamblocker")) do
			v.Claimer = nil
			v.ClaimerTeamMembers = nil
			v.IsClaimed = false
			v.On = false
		end

		for k, v in pairs(ents.FindByClass("trigger_teleport")) do
			v:Fire("disable")
		end

		-- Remove teh shitty windows that are above players.
		for _, v in pairs(ents.FindByClass("func_breakable")) do
			v:Fire("Break", "", 0)
		end

		-- Unfreeze everything
		for _, v in pairs(ents.GetAll()) do
			if IsValid(v) then
				local phys = v:GetPhysicsObject()
			
				if phys:IsValid() then 
					phys:EnableMotion(true)
					phys:Wake()
				end

				if v:GetClass() == "prop_base" then -- change prop collisions to default if they were no-collided with physgun.
					v:SetCollisionGroup(COLLISION_GROUP_NONE)
				end
			end
		end

		-- Raise the water
		self:RiseAllWaterControllers()
	else
		Flood_buildTime = Flood_buildTime - 1
	end
end

function GM:FloodPhase()
	if SERVER then -- clears the undo table of all players so they cannot refund their props after the build phase.
		local asdf = undo.GetTable()

		table.Empty(asdf)
	end
	
	if Flood_floodTime <= 0 then
		-- Time to Kill
		self:SetGameState(3)

		-- Its time to fight!
		self:GivePlayerWeapons()
	else  
		Flood_floodTime = Flood_floodTime - 1
	end
end

function GM:FightPhase()
	if Flood_fightTime <= 0 then
		-- Time to Reset
		self:SetGameState(4)

		-- Lower Water
		self:LowerAllWaterControllers()

		-- Declare winner is nobody because time ran out
		self:DeclareWinner(3)
	else  
		Flood_fightTime = Flood_fightTime - 1
		self:ParticipationBonus()
	end
end

function GM:ResetPhase()
	if Flood_resetTime <= 0 then
		-- Time to wait for players (if players exist, should go to build phase)
		self:SetGameState(0) 

		-- Give people their money
		self:RefundAllProps()

		-- Game is over, lets tidy up the players
		for _, v in pairs(player.GetAll()) do
			if IsValid(v) then
				v:SetCanRespawn(true)

				-- Wait till they respawn
				timer.Simple(0, function()
					v:StripWeapons()
					v:RemoveAllAmmo()
					v:SetHealth(100)
					v:SetArmor(0)

					timer.Simple(0, function()
						v:Give("gmod_tool")
						v:Give("weapon_physgun")
						v:Give("flood_propseller")

						v:SelectWeapon("weapon_physgun")
					end)
				end)
			end
		end
	
		for k, v in pairs(ents.FindByClass("func_teamblocker")) do -- prevent people from claiming rooms again mid round
			v.On = true
		end

		for k, v in pairs(ents.FindByClass("trigger_teleport")) do
			v:Fire("enable")
		end

		self:ResetAllTimers() -- Reset all the round timers
	else  
		Flood_resetTime = Flood_resetTime - 1
	end	
end

function GM:InitializeRoundController()
	Flood_buildTime = GAMEMODE.buildtimeoverride or 15--GetConVar("flood_build_time"):GetFloat()
	Flood_floodTime = GAMEMODE.floodtimeoverride or 15--GetConVar("flood_flood_time"):GetFloat()
	Flood_fightTime = GAMEMODE.fighttimeoverride or 15--GetConVar("flood_fight_time"):GetFloat()
	Flood_resetTime = GAMEMODE.resettimeoverride or 15--GetConVar("flood_reset_time"):GetFloat()

	hook.Add("Think", "Flood_TimeController", function() hook.Call("TimerController", GAMEMODE) end)
end

function GM:ResetAllTimers()
	Flood_buildTime = GAMEMODE.buildtimeoverride or 15--GetConVar("flood_build_time"):GetFloat()
	Flood_floodTime = GAMEMODE.floodtimeoverride or 15--GetConVar("flood_flood_time"):GetFloat()
	Flood_fightTime = GAMEMODE.fighttimeoverride or 15--GetConVar("flood_fight_time"):GetFloat()
	Flood_resetTime = GAMEMODE.resettimeoverride or 15--GetConVar("flood_reset_time"):GetFloat()
end