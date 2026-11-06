util.AddNetworkString("wrp_notify")

local spawnAt = setmetatable({}, {__mode = "k"})
local function Notify(ply, text)
    if not IsValid(ply) then return end
    net.Start("wrp_notify")
    net.WriteString(string.sub(tostring(text or ""), 1, 180))
    net.Send(ply)
end
WhiteRP.Notify = Notify

hook.Add("PlayerSpawnProp", "WhiteRP.PropGuard", function(ply, model)
    if not isstring(model) or model == "" or (util.IsValidModel and not util.IsValidModel(model)) then return false end
    local now = CurTime()
    if spawnAt[ply] and now - spawnAt[ply] < WhiteRP.Config.SpawnCooldown then return false end
    spawnAt[ply] = now
    local limit = WhiteRP.IsAdmin(ply) and WhiteRP.Config.AdminPropLimit or WhiteRP.Config.DefaultPropLimit
    if ply:GetCount("props") >= limit then
        Notify(ply, "Достигнут лимит пропов: " .. limit)
        return false
    end
end)

hook.Add("PlayerSpawnSENT", "WhiteRP.EntityGuard", function(ply, class)
    if class == "wrp_jobboard" and WhiteRP.IsAdmin(ply) then return end
    Notify(ply, "Спавн сущностей доступен только администраторам")
    return false
end)

hook.Add("PlayerSpawnNPC", "WhiteRP.NPCGuard", function(ply)
    if not WhiteRP.IsAdmin(ply) then return false end
end)

hook.Add("PlayerSpawnVehicle", "WhiteRP.VehicleGuard", function(ply)
    if not WhiteRP.IsAdmin(ply) then return false end
end)

hook.Add("PlayerSpawnSWEP", "WhiteRP.WeaponSpawnGuard", function(ply)
    if not WhiteRP.IsAdmin(ply) then return false end
end)

hook.Add("PlayerGiveSWEP", "WhiteRP.WeaponGiveGuard", function(ply)
    if not WhiteRP.IsAdmin(ply) then return false end
end)

local function OwnsEntity(ply, ent)
    if not IsValid(ent) or ent:IsWorld() then return true end
    if ent:IsPlayer() then return ent == ply end
    if WhiteRP.IsAdmin(ply) then return true end
    local owner
    if ent.CPPIGetOwner then owner = ent:CPPIGetOwner() end
    owner = IsValid(owner) and owner or ent:GetCreator()
    return not IsValid(owner) or owner == ply
end

hook.Add("PhysgunPickup", "WhiteRP.PhysgunGuard", function(ply, ent)
    if IsValid(ent) and ent:GetClass() == "wrp_jobboard" and not WhiteRP.IsAdmin(ply) then return false end
    if not OwnsEntity(ply, ent) then return false end
end)

hook.Add("CanTool", "WhiteRP.ToolGuard", function(ply, tr, mode)
    if not WhiteRP.CanUseTool(mode) then return false end
    if tr and IsValid(tr.Entity) then
        if tr.Entity:GetClass() == "wrp_jobboard" and not WhiteRP.IsAdmin(ply) then return false end
        if not OwnsEntity(ply, tr.Entity) then return false end
    end
end)

hook.Add("CanProperty", "WhiteRP.PropertyGuard", function(ply, property, ent)
    if IsValid(ent) and ent:GetClass() == "wrp_jobboard" and not WhiteRP.IsAdmin(ply) then return false end
    if not OwnsEntity(ply, ent) then return false end
end)

hook.Add("PlayerDisconnected", "WhiteRP.CleanupSpawnGuard", function(ply)
    spawnAt[ply] = nil
end)
