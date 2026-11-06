AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/Male_07.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
    self:SetUseType(SIMPLE_USE)
    self:SetBoardTitle("ПРОФЕССИИ")
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    net.Start("wrp_jobboard_open")
    net.WriteEntity(self)
    net.Send(ply)
end
