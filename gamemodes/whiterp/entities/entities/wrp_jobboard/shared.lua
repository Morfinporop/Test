ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "WhiteRP · NPC-рекрутер профессий"
ENT.Category = "WhiteRP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "BoardTitle")
end
