-- Include everything
include("shared.lua")
 
MsgN("_-_-_-_- Flood Client Side -_-_-_-_")
MsgN("Loading Clientside Files")
for _, file in pairs(file.Find("flood/gamemode/client/*.lua", "LUA")) do
	MsgN("-> "..file)
	include("flood/gamemode/client/"..file)
end

MsgN("Loading Clientside VGUI Files")
for _, file in pairs(file.Find("flood/gamemode/client/vgui/*.lua", "LUA")) do
	MsgN("-> "..file)
	include("flood/gamemode/client/vgui/"..file)
end

surface.CreateFont("FloodFontDefaultSmall", {
	font = "DermaDefault",
	extended = false,
	size = 20,
	antialias = true,
})

function GM:SpawnMenuOpen(ply)
	return false
end

function GM:ContextMenuOpen(ply)
	return false
end

function GM:CanProperty(ply, property, ent)
	return false
end

function GM:PostDrawViewModel(vm, pl, wep)
	if wep and wep:IsValid() then
		if wep.UseHands or not wep:IsScripted() then
			local hands = pl:GetHands()
			if hands and hands:IsValid() then
				hands:DrawModel()
			end
		end

		if wep.PostDrawViewModel then
			wep:PostDrawViewModel(vm)
		end
	end
end

local waiting = false
local index

net.Receive("CreateTeam", function()
	index = net.ReadInt(32)
	team.SetUp(index, net.ReadString(), net.ReadColor(), net.ReadBool())
	if net.ReadBool() then
		waiting = true
	end
end)

function RefreshTeamMenu()
	if waiting then
		if LocalPlayer():Team() == index then
			waiting = false
			MakepTeamMenu(3)
		end
	end
end
hook.Add("Think", "RefreshTeamMenu", RefreshTeamMenu)