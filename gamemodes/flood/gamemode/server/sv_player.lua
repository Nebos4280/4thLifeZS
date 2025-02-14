local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("CreateTeam")

function GM:PlayerInitialSpawn(ply)
	ply.Allow = false
 
	local data = { }
	data = ply:LoadData()

	ply:SetCash(data.cash)
	ply.Weapons = string.Explode("\n", data.weapons)
	ply.SurvivalTime = 0
	
	ply:SetTeam(TEAM_PLAYER)

	local col = team.GetColor(TEAM_PLAYER)
	ply:SetPlayerColor(Vector(col.r / 255, col.g / 255, col.b / 255))

	if self:GetGameState() >= 2 then
		timer.Simple(0, function ()
			if IsValid(ply) then
				ply:KillSilent()
				ply:SetCanRespawn(false)
			end
		end)
	end
	ply.SpawnTime = CurTime()
	
	PrintMessage(HUD_PRINTCENTER, ply:Nick().." has joined the server!")
	
	for k, _ in pairs(team.GetAllTeams()) do
		net.Start("CreateTeam")
			net.WriteInt(k, 32)
			net.WriteString(team.GetName(k))
			net.WriteColor(team.GetColor(k))
			net.WriteBool(team.Joinable(k))
			net.WriteBool(false)
		net.Broadcast()
	end
	
	DemoteTeamLeader(ply)
end

function GM:PlayerSpawn( ply )
	hook.Call( "PlayerLoadout", GAMEMODE, ply )
	hook.Call( "PlayerSetModel", GAMEMODE, ply )
	ply:UnSpectate()
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	--our F1 menu allows changing of playermodels, so we're going to do it this way now.
	local desiredname = ply:GetInfo("flood_playermodel")
	local desiredskin = ply:GetInfo("flood_playerskin")
	local modelname = player_manager.TranslatePlayerModel(desiredname)
	ply:SetModel(modelname)

	if tonumber(desiredskin) then
		ply:SetSkin(desiredskin)
	end

    -- Get playermodel color and apply it
	local pcol = Vector(ply:GetInfo("cl_playercolor"))
	pcol.x = math.Clamp(pcol.x, 0, 2.5)
	pcol.y = math.Clamp(pcol.y, 0, 2.5)
	pcol.z = math.Clamp(pcol.z, 0, 2.5)
	ply:SetPlayerColor(pcol)

	-- Get weaponcolor info and apply it
	local wcol = Vector(ply:GetInfo("cl_weaponcolor"))
	wcol.x = math.Clamp(wcol.x, 0, 2.5)
	wcol.y = math.Clamp(wcol.y, 0, 2.5)
	wcol.z = math.Clamp(wcol.z, 0, 2.5)
	ply:SetWeaponColor(wcol)

	local oldhands = ply:GetHands()
	if IsValid(oldhands) then
		oldhands:Remove()
	end

	local hands = ents.Create("fm_hands")
	if hands:IsValid() then
		hands:DoSetup(ply)
		hands:Spawn()
		if tonumber(desiredskin) and tonumber(desiredskin) <= (hands:SkinCount() - 1) then
			hands:SetSkin(desiredskin)
		end
	end
end

function GM:ForcePlayerSpawn()
	for _, v in pairs(player.GetAll()) do
		if v:CanRespawn() then
			if v.NextSpawnTime && v.NextSpawnTime > CurTime() then return end
			if not v:Alive() and IsValid(v) then
				v:Spawn()	
			end
		end
	end
end

function GM:PlayerLoadout(ply)
	ply:Give("gmod_tool")
	ply:Give("weapon_physgun")
	ply:Give("flood_propseller")

	ply:SelectWeapon("weapon_physgun")
end

function GM:PlayerSetModel(ply)
	ply:SetModel("models/player/Group03/Male_06.mdl")
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerDeathThink(ply)
end

function GM:PlayerDeath(ply, inflictor, attacker )
	ply.NextSpawnTime = CurTime() + 5
	ply.SpectateTime = CurTime() + 2

	if IsValid(inflictor) && inflictor == attacker && (inflictor:IsPlayer() || inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()
		if !IsValid(inflictor) then inflictor = attacker end
	end

	-- Don't spawn for at least 2 seconds
	ply.NextSpawnTime = CurTime() + 2
	ply.DeathTime = CurTime()
	
	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ply end
	
	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end
	
	if GAMEMODE:GetGameState() == 3 then
		ply.SurvivalTime = CurTime() - ply.SurvivalTime
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a 
	-- pistol but kill you by hitting you with their arm.
	if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then
	
		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( inflictor ) ) then inflictor = attacker end

	end

	if ( attacker == ply ) then
	
		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( ply )
		net.Broadcast()
		
		MsgAll( attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( attacker:IsPlayer() ) then
	
		net.Start( "PlayerKilledByPlayer" )
		
			net.WriteEntity( ply )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
		
		net.Broadcast()
		
		MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n" )
		
	return end
	
	net.Start( "PlayerKilled" )
	
		net.WriteEntity( ply )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )

	net.Broadcast()
	
	MsgAll( ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
end

function GM:PlayerSwitchWeapon(ply, oldwep, newwep)
end

function GM:PlayerSwitchFlashlight(ply)
	return true
end

function GM:PlayerShouldTaunt( ply, actid )
	return false
end

function GM:CanPlayerSuicide(ply)
	return false
end

-----------------------------------------------------------------------------------------------
----                                 Give the player their weapons                         ----
-----------------------------------------------------------------------------------------------
function GM:GivePlayerWeapons()
	for _, v in pairs(self:GetActivePlayers()) do
		-- Because the player always needs a pistol
		v:Give("weapon_pistol")
		timer.Simple(0, function() 
			v:GiveAmmo(9999, "Pistol") 
		end)


		if v.Weapons and Weapons then
			for __, pWeapon in pairs(v.Weapons) do
				for ___, Weapon in pairs(Weapons) do
					if pWeapon == Weapon.Class then
						v:Give(Weapon.Class)
						timer.Simple(0, function() 
							v:GiveAmmo(Weapon.Ammo, Weapon.AmmoClass)
						end)
					end
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
----                                 Player Data Loading                                   ----
-----------------------------------------------------------------------------------------------
function PlayerMeta:LoadData()
	local data = {}
	if file.Exists("flood/"..self:UniqueID()..".txt", "DATA") then
		data = util.KeyValuesToTable(file.Read("flood/"..self:UniqueID()..".txt", "DATA"))
		self.Allow = true
		return data
	else
		self:Save()
		data = util.KeyValuesToTable(file.Read("flood/"..self:UniqueID()..".txt", "DATA"))
		
		-- Initialize cash to a value
		data.cash = 5000
		-- Weapons are initialized elsewhere

		self:Save()
		self.Allow = true
		return data
	end
end

function PlayerLeft(ply)
	ply:Save()
end
hook.Add("PlayerDisconnected", "PlayerDisconnect", PlayerLeft)

function ServerDown()
	for k, v in pairs(player.GetAll()) do
		v:Save()
	end
end
hook.Add("ShutDown", "ServerShutDown", ServerDown)

-----------------------------------------------------------------------------------------------
----                                 Prop/Weapon Purchasing                                ----
-----------------------------------------------------------------------------------------------
function GM:PurchaseProp(ply, cmd, args)
	if not ply.PropSpawnDelay then ply.PropSpawnDelay = 0 end
	if not IsValid(ply) or not args[1] then return end
	
	local Prop = Props[math.floor(args[1])]
	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	local ct = ChatText()

	if ply.Allow and Prop and self:GetGameState() <= 1 then
		if Prop.DonatorOnly == true and not ply:IsDonator() then 
			ct:AddText("[Flood] ", Color(158, 49, 49, 255))
			ct:AddText(Prop.Description.." is a donator only item!")
			ct:Send(ply)
			return 
		else
			if ply.PropSpawnDelay <= CurTime() then
				
				-- Checking to see if they can even spawn props.
				if ply:IsAdmin() then
					if ply:GetCount("flood_props") >= GetConVar("flood_max_admin_props"):GetInt() then
						ct:AddText("[Flood] ", Color(158, 49, 49, 255))
						ct:AddText("You have reached the admin's prop spawning limit!")
						ct:Send(ply)
						return
					end 
				elseif ply:IsDonator() then
					if ply:GetCount("flood_props") >= GetConVar("flood_max_donator_props"):GetInt() then
						ct:AddText("[Flood] ", Color(158, 49, 49, 255))
						ct:AddText("You have reached the donator's prop spawning limit!")
						ct:Send(ply)
						return
					end
				else
					if ply:GetCount("flood_props") >= GetConVar("flood_max_player_props"):GetInt() then 
						ct:AddText("[Flood] ", Color(158, 49, 49, 255))
						ct:AddText("You have reached the player's prop spawning limit!")
						ct:Send(ply)
						return
					end
				end

				if ply:CanAfford(Prop.Price) then
					ply:SubCash(Prop.Price)

					local ent = ents.Create("prop_base")
					ent:SetModel(Prop.Model)
					ent:SetPos(tr.HitPos + Vector(0, 0, (ent:OBBCenter():Distance(ent:OBBMins()) + 5)))
					ent:CPPISetOwner(ply)
					ent:Spawn()
					ent:Activate()
					ent:SetHealth(Prop.Health)
					ent:SetPropHealth(math.floor(Prop.Health))
					ent:SetPropMaxHealth(math.floor(Prop.Health))
					ent:SetPropName(Prop.Description)
					ent:SetPropOwner(ply)
					ent:SetPropCost(Prop.Price)

					ct:AddText("[Flood] ", Color(132, 199, 29, 255))
					ct:AddText("You have purchased a(n) "..Prop.Description..".")
					ct:Send(ply)

					undo.Create("prop")
					undo.AddEntity(ent)
					undo.SetPlayer(ply)
					undo.AddFunction(function() ply:AddCash(Prop.Price) end)
					undo.Finish()
						
					hook.Call("PlayerSpawnedProp", gmod.GetGamemode(), ply, ent:GetModel(), ent)
					ply:AddCount("flood_props", ent)
				else
					ct:AddText("[Flood] ", Color(158, 49, 49, 255))
					ct:AddText("You do not have enough cash to purchase a(n) "..Prop.Description..".")
					ct:Send(ply)
				end
			else
				ct:AddText("[Flood] ", Color(158, 49, 49, 255))
				ct:AddText("You are attempting to spawn props too quickly.")
				ct:Send(ply)
			end
			ply.PropSpawnDelay = CurTime() + 0.25
		end
	else
		ct:AddText("[Flood] ", Color(158, 49, 49, 255))
		ct:AddText("You can not purcahse a(n) "..Prop.Description.." at this time.")
		ct:Send(ply)
	end
end
concommand.Add("FloodPurchaseProp", function(ply, cmd, args) hook.Call("PurchaseProp", GAMEMODE, ply, cmd, args) end)

function GM:PurchaseWeapon(ply, cmd, args)
	if not ply.PropSpawnDelay then ply.PropSpawnDelay = 0 end
	if not IsValid(ply) or not args[1] then return end
	
	local Weapon = Weapons[math.floor(args[1])]
	local ct = ChatText()

	if ply.Allow and Weapon and self:GetGameState() <= 1 then
		if table.HasValue(ply.Weapons, Weapon.Class) then
			ct:AddText("[Flood] ", Color(158, 49, 49, 255))
			ct:AddText("You already own a(n) "..Weapon.Name.."!")
			ct:Send(ply)
			return
		else
			if Weapon.DonatorOnly == true and not ply:IsDonator() then 
				ct:AddText("[Flood] ", Color(158, 49, 49, 255))
				ct:AddText(Weapon.Name.." is a donator only item!")
				ct:Send(ply)
				return 
			else
				if ply:CanAfford(Weapon.Price) then
					ply:SubCash(Weapon.Price)
					table.insert(ply.Weapons, Weapon.Class)
					ply:Save()

					ct:AddText("[Flood] ", Color(132, 199, 29, 255))
					ct:AddText("You have purchased a(n) "..Weapon.Name..".")
					ct:Send(ply)
				else
					ct:AddText("[Flood] ", Color(158, 49, 49, 255))
					ct:AddText("You do not have enough cash to purchase a(n) "..Weapon.Name..".")
					ct:Send(ply)
				end
			end
		end
	else
		ct:AddText("[Flood] ", Color(158, 49, 49, 255))
		ct:AddText("You can not purcahse a(n) "..Weapon.Name.." at this time.")
		ct:Send(ply)
	end
end
concommand.Add("FloodPurchaseWeapon", function(ply, cmd, args) hook.Call("PurchaseWeapon", GAMEMODE, ply, cmd, args) end)

function GM:JoinTeam(pl, cmd, args)
	if not IsValid(pl) or not args[1] then return end
	args[1] = math.Round(args[1], 0)
	if not table.HasValue(team.GetPlayers(args[1]), pl) and team.NumPlayers(args[1]) < 4 then
		pl:SetTeam(args[1])
	end
	DemoteTeamLeaderTeamLeader(pl)
end
concommand.Add("JoinTeam", function(pl, cmd, args) hook.Call("JoinTeam", GAMEMODE, pl, cmd, args) end)

function GM:CreateTeam(pl, cmd, args)
	local teamname = args[1]
	local teamcolor = Color(args[2], args[3], args[4], 255)
	local teamowner = pl
	local teamisjoinable = tobool(args[5])
	local allteams = team.GetAllTeams()
	local teamnumber = #allteams + 1
	
	team.SetUp(teamnumber, teamname, teamcolor, teamisjoinable)
	
	if teamowner:Team() == teamnumber then return end
	teamowner:SetTeam(teamnumber)
	MakeTeamLeader(pl)
	
	net.Start("CreateTeam")
		net.WriteInt(teamnumber, 32)
		net.WriteString(teamname)
		net.WriteColor(teamcolor)
		net.WriteBool(teamisjoinable)
		net.WriteBool(true)
	net.Broadcast()
end
concommand.Add("CreateTeam", function(pl, cmd, args) hook.Call("CreateTeam", GAMEMODE, pl, cmd, args) end)

function MakeTeamLeader(pl)
	pl:SetNWBool("TeamLeader", true)
end

function DemoteTeamLeader(pl)
	pl:SetNWBool("TeamLeader", false)
end

--Used only for the teams menu.
function GM:PromoteTeamLeader(pl, cmd, args)
	local pl2 = args[1]
	DemoteTeamLeader(pl)
	MakeTeamLeader(pl2)
end
concommand.Add("PromoteTeamLeader", function(pl, cmd, args) hook.Call("PromoteTeamLeader", GAMEMODE, pl, cmd, args) end)

--Used only for the teams menu.
function GM:LeaveTeam(pl, cmd, args)
	pl:SetTeam(2)
end
concommand.Add("LeaveTeam", function(pl, cmd, args) hook.Call("LeaveTeam", GAMEMODE, pl, cmd, args) end)

--Used only for the teams menu.
function GM:KickFromTeam(pl, cmd, args)
	local pl2 = args[1]
	if pl:GetNWBool("TeamLeader") then
		pl2:SetTeam(2)
	end
end
concommand.Add("KickFromTeam", function(pl, cmd, args) hook.Call("KickFromTeam", GAMEMODE, pl, cmd, args) end)

hook.Add("OnPhysgunFreeze", "nocollidepropsthing", function(weapon, phys, ent, ply) -- nocollides a prop if the player is holding shift.
	if ply:KeyDown(IN_SPEED) and ent:GetClass() == "prop_base" then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	elseif !ply:KeyDown(IN_SPEED) and ent:GetClass() == "prop_base" then
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
end)