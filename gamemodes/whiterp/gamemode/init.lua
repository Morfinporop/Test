AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

include("whiterp/sv_security.lua")
include("whiterp/sv_economy.lua")
include("whiterp/sv_jobs.lua")
include("whiterp/sv_tools.lua")
include("whiterp/sv_admin.lua")

function GM:Initialize()
    for id, job in pairs(WhiteRP.Jobs) do
        team.SetUp(id, job.name, job.color or Color(160, 170, 185))
    end
    self.BaseClass.Initialize(self)
    print("[WhiteRP] Gamemode initialized")
end

function GM:PlayerInitialSpawn(ply)
    self.BaseClass.PlayerInitialSpawn(self, ply)
    ply:SetNW2Int("wrp_job", 1)
    ply:SetNW2Int("wrp_money", WhiteRP.Config.StartMoney)
    ply:SetNW2Bool("wrp_loaded", false)
end

function GM:PlayerSpawn(ply, transition)
    self.BaseClass.PlayerSpawn(self, ply, transition)
    local job = WhiteRP.GetJob(ply:GetNW2Int("wrp_job", 1))
    ply:SetModel(job.model)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:SetArmor(0)
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:Give("weapon_physgun")
    ply:Give("gmod_tool")
    ply:Give("weapon_fists")
    local job = WhiteRP.GetJob(ply:GetNW2Int("wrp_job", 1))
    for _, class in ipairs(job.weapons or {}) do
        if weapons.Get(class) then ply:Give(class) end
    end
    return true
end

function GM:PlayerSetModel(ply)
    ply:SetModel(WhiteRP.GetJob(ply:GetNW2Int("wrp_job", 1)).model)
end

function GM:PlayerDeath(ply)
    ply:StripWeapons()
end

function GM:PlayerShouldTakeDamage(victim, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker == victim then return true end
end
