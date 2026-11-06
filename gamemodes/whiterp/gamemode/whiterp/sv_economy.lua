local function SetMoney(ply, amount)
    amount = math.Clamp(math.floor(tonumber(amount) or 0), 0, WhiteRP.Config.MaxMoney)
    ply:SetNW2Int("wrp_money", amount)
    ply:SetPData("whiterp_money", amount)
    return amount
end

function WhiteRP.GetMoney(ply)
    return math.max(0, ply:GetNW2Int("wrp_money", WhiteRP.Config.StartMoney))
end

function WhiteRP.AddMoney(ply, amount, reason)
    if not IsValid(ply) then return false end
    amount = math.floor(tonumber(amount) or 0)
    if amount == 0 then return true end
    local nextAmount = math.Clamp(WhiteRP.GetMoney(ply) + amount, 0, WhiteRP.Config.MaxMoney)
    SetMoney(ply, nextAmount)
    if reason then WhiteRP.Notify(ply, (amount > 0 and "+" or "") .. WhiteRP.FormatMoney(amount) .. " · " .. reason) end
    return true
end

hook.Add("PlayerInitialSpawn", "WhiteRP.LoadWallet", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        local stored = tonumber(ply:GetPData("whiterp_money", ""))
        if stored then ply:SetNW2Int("wrp_money", math.Clamp(math.floor(stored), 0, WhiteRP.Config.MaxMoney)) end
        ply:SetNW2Float("wrp_next_payday", CurTime() + WhiteRP.Config.PaydayInterval)
        ply:SetNW2Bool("wrp_loaded", true)
    end)
end)

hook.Add("PlayerDisconnected", "WhiteRP.SaveWallet", function(ply)
    ply:SetPData("whiterp_money", WhiteRP.GetMoney(ply))
end)

timer.Create("WhiteRP.Payday", 1, 0, function()
    local now = CurTime()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNW2Bool("wrp_loaded", false) and now >= ply:GetNW2Float("wrp_next_payday", now + WhiteRP.Config.PaydayInterval) then
            local job = WhiteRP.GetJob(ply:GetNW2Int("wrp_job", 1))
            WhiteRP.AddMoney(ply, job.salary, "выплата за профессию " .. job.name)
            ply:SetNW2Float("wrp_next_payday", now + WhiteRP.Config.PaydayInterval)
        end
    end
end)

concommand.Add("wrp_setmoney", function(caller, _, args)
    if IsValid(caller) and not WhiteRP.IsAdmin(caller) then return end
    local target, amount = player.GetBySteamID(args[1] or ""), tonumber(args[2])
    if not IsValid(target) or not amount then return end
    amount = SetMoney(target, amount)
    print("[WhiteRP:Admin] " .. (IsValid(caller) and caller:Nick() or "CONSOLE") .. " set money for " .. target:Nick() .. " to " .. amount)
end)
