TOOL.Category = "WhiteRP"
TOOL.Name = "Скрывающая дверь"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Mode = "wrp_door"

if CLIENT then
    language.Add("tool.wrp_door.name", "Скрывающая дверь")
    language.Add("tool.wrp_door.desc", "Пометить принадлежащий вам проп как скрывающуюся дверь")
    language.Add("tool.wrp_door.0", "ЛКМ — установить дверь, ПКМ — снять режим двери. E рядом с дверью — открыть или закрыть")
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsWorld() or ent:IsPlayer() then return false end
    if CLIENT then return true end
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetCreator()
    if IsValid(owner) and owner ~= self:GetOwner() and not WhiteRP.IsAdmin(self:GetOwner()) then return false end
    ent.WRP_DoorOwner = self:GetOwner():SteamID64()
    ent.WRP_DoorOpen = false
    ent:SetNW2Bool("wrp_door", true)
    ent:SetNW2Bool("wrp_door_open", false)
    ent:SetNoDraw(true)
    ent:SetNotSolid(false)
    self:GetOwner():EmitSound("buttons/button14.wav")
    return true
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsWorld() then return false end
    if CLIENT then return true end
    if not ent:GetNW2Bool("wrp_door", false) then return false end
    if ent.WRP_DoorOwner ~= self:GetOwner():SteamID64() and not WhiteRP.IsAdmin(self:GetOwner()) then return false end
    ent:SetNW2Bool("wrp_door", false)
    ent:SetNW2Bool("wrp_door_open", false)
    ent.WRP_DoorOwner = nil
    ent.WRP_KeypadPin = nil
    ent:SetNoDraw(false)
    ent:SetNotSolid(false)
    return true
end

function TOOL.BuildCPanel(panel)
    panel:Help("Скрытая дверь использует выбранный проп. Владелец открывает её клавишей E; при закрытии она скрыта и сохраняет коллизию.")
end
