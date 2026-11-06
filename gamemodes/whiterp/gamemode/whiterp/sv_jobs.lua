util.AddNetworkString("wrp_jobboard_open")
util.AddNetworkString("wrp_joblist")
util.AddNetworkString("wrp_job_select")

local changedAt = setmetatable({}, {__mode = "k"})
local boardRequests = setmetatable({}, {__mode = "k"})

local function SendJobs(ply, board)
    if not IsValid(board) or board:GetPos():DistToSqr(ply:GetPos()) > 220 * 220 then return end
    net.Start("wrp_joblist")
        net.WriteEntity(board)
        net.WriteUInt(table.Count(WhiteRP.Jobs), 8)
        for id, job in SortedPairs(WhiteRP.Jobs) do
            net.WriteUInt(id, 8)
            net.WriteString(job.name)
            net.WriteString(job.category)
            net.WriteUInt(job.salary, 16)
            net.WriteUInt(job.max, 8)
            net.WriteColor(job.color or color_white)
        end
    net.Send(ply)
end

net.Receive("wrp_jobboard_open", function(_, ply)
    local now = CurTime()
    if boardRequests[ply] and now - boardRequests[ply] < 1 then return end
    boardRequests[ply] = now
    local board = net.ReadEntity()
    SendJobs(ply, board)
end)

net.Receive("wrp_job_select", function(_, ply)
    local id = net.ReadUInt(8)
    local board = net.ReadEntity()
    local job = WhiteRP.Jobs[id]
    if not job or not IsValid(board) or board:GetClass() ~= "wrp_jobboard" or board:GetPos():DistToSqr(ply:GetPos()) > 220 * 220 then return end
    if changedAt[ply] and CurTime() - changedAt[ply] < WhiteRP.Config.JobChangeCooldown then
        WhiteRP.Notify(ply, "Подождите перед сменой профессии")
        return
    end
    if ply:GetNW2Int("wrp_job", 1) == id then return end
    if job.max > 0 then
        local count = 0
        for _, other in ipairs(player.GetAll()) do
            if other:GetNW2Int("wrp_job", 1) == id then count = count + 1 end
        end
        if count >= job.max then WhiteRP.Notify(ply, "На этой профессии нет свободных мест") return end
    end
    changedAt[ply] = CurTime()
    ply:SetNW2Int("wrp_job", id)
    ply:SetTeam(id)
    ply:Spawn()
    WhiteRP.Notify(ply, "Ваша профессия: " .. job.name)
end)

hook.Add("PlayerInitialSpawn", "WhiteRP.SetupTeams", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then ply:SetTeam(1) end
    end)
end)
