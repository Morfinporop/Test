util.AddNetworkString("wrp_admin_roster_request")
util.AddNetworkString("wrp_admin_roster")
util.AddNetworkString("wrp_admin_action")

local nextAction = setmetatable({}, {__mode = "k"})
local nextRoster = setmetatable({}, {__mode = "k"})
local function Audit(admin, action, target, detail)
    local by = IsValid(admin) and (admin:Nick() .. " [" .. admin:SteamID() .. "]") or "CONSOLE"
    local to = IsValid(target) and (target:Nick() .. " [" .. target:SteamID() .. "]") or "n/a"
    print(string.format("[WhiteRP:Admin] %s -> %s: %s %s", by, to, action, tostring(detail or "")))
end

net.Receive("wrp_admin_roster_request", function(_, ply)
    if not WhiteRP.IsAdmin(ply) then return end
    local now = CurTime()
    if nextRoster[ply] and now < nextRoster[ply] then return end
    nextRoster[ply] = now + 0.5
    local list = player.GetAll()
    net.Start("wrp_admin_roster")
        net.WriteUInt(math.min(#list, 255), 8)
        for i = 1, math.min(#list, 255) do
            local target = list[i]
            net.WriteUInt(target:UserID(), 16)
            net.WriteString(string.sub(target:Nick(), 1, 64))
            net.WriteString(target:SteamID())
            net.WriteUInt(target:GetNW2Int("wrp_job", 1), 8)
            net.WriteUInt(math.Clamp(WhiteRP.GetMoney(target), 0, 4294967295), 32)
        end
    net.Send(ply)
end)

net.Receive("wrp_admin_action", function(_, ply)
    if not WhiteRP.IsAdmin(ply) then return end
    local now = CurTime()
    if nextAction[ply] and now < nextAction[ply] then return end
    nextAction[ply] = now + 0.25
    local action = net.ReadString()
    local userID = net.ReadUInt(16)
    local value = net.ReadInt(32)
    local target = player.GetByID(userID)
    if not IsValid(target) then return end

    if action == "setmoney" then
        if value < 0 or value > WhiteRP.Config.MaxMoney then return end
        target:SetNW2Int("wrp_money", value)
        target:SetPData("whiterp_money", value)
        WhiteRP.Notify(target, "Администратор изменил ваш баланс")
        Audit(ply, action, target, value)
    elseif action == "setjob" then
        local job = WhiteRP.Jobs[value]
        if not job then return end
        target:SetNW2Int("wrp_job", value)
        target:SetTeam(value)
        target:Spawn()
        WhiteRP.Notify(target, "Администратор назначил профессию: " .. job.name)
        Audit(ply, action, target, job.name)
    elseif action == "bring" then
        target:SetPos(ply:GetPos() + ply:GetForward() * 90)
        Audit(ply, action, target)
    elseif action == "goto" then
        ply:SetPos(target:GetPos() + target:GetForward() * 90)
        Audit(ply, action, target)
    elseif action == "freeze" then
        target:Freeze(not target:IsFrozen())
        Audit(ply, action, target, target:IsFrozen() and "frozen" or "unfrozen")
    elseif action == "kick" then
        Audit(ply, action, target, "admin menu")
        target:Kick("Администратор удалил вас с сервера")
    end
end)

