util.AddNetworkString("wrp_keypad_prompt")
util.AddNetworkString("wrp_keypad_submit")

local function IsOwner(ply, ent)
    return WhiteRP.IsAdmin(ply) or (IsValid(ent) and ent.WRP_DoorOwner == ply:SteamID64())
end

local function SetDoorOpen(ent, open)
    if not IsValid(ent) or not ent:GetNW2Bool("wrp_door", false) then return end
    ent.WRP_DoorOpen = open and true or false
    ent:SetNoDraw(not open)
    ent:SetNotSolid(open)
    ent:SetNW2Bool("wrp_door_open", open and true or false)
    if open then
        timer.Create("WhiteRP.DoorClose." .. ent:EntIndex(), 8, 1, function()
            if IsValid(ent) then SetDoorOpen(ent, false) end
        end)
    else
        timer.Remove("WhiteRP.DoorClose." .. ent:EntIndex())
    end
end

WhiteRP.SetDoorOpen = SetDoorOpen

local function UseDoor(ply, ent)
    if not IsValid(ply) or not ply:IsPlayer() or not IsValid(ent) then return end
    if IsOwner(ply, ent) then
        SetDoorOpen(ent, not ent.WRP_DoorOpen)
        return
    end
    if not isstring(ent.WRP_KeypadPin) or ent.WRP_KeypadPin == "" then
        WhiteRP.Notify(ply, "Дверь заперта")
        return
    end
    net.Start("wrp_keypad_prompt") net.WriteEntity(ent) net.Send(ply)
end

hook.Add("KeyPress", "WhiteRP.HiddenDoorUse", function(ply, key)
    if key ~= IN_USE or not IsValid(ply) or not ply:Alive() then return end
    local doors = ents.FindInSphere(ply:GetPos(), 100)
    local nearest, distance
    for _, ent in ipairs(doors) do
        if ent:GetNW2Bool("wrp_door", false) then
            local d = ent:WorldSpaceCenter():DistToSqr(ply:EyePos())
            if not distance or d < distance then nearest, distance = ent, d end
        end
    end
    if IsValid(nearest) then UseDoor(ply, nearest) end
end)

local lastKeypad = setmetatable({}, {__mode="k"})
net.Receive("wrp_keypad_submit", function(_, ply)
    local now = CurTime()
    if lastKeypad[ply] and now - lastKeypad[ply] < 1 then return end
    lastKeypad[ply] = now
    local ent = net.ReadEntity()
    local pin = string.sub(net.ReadString(), 1, 8)
    if not IsValid(ent) or not ent:GetNW2Bool("wrp_door", false) then return end
    if ent:GetPos():DistToSqr(ply:GetPos()) > 150 * 150 then return end
    if not isstring(ent.WRP_KeypadPin) or pin ~= ent.WRP_KeypadPin then
        WhiteRP.Notify(ply, "Неверный код")
        return
    end
    SetDoorOpen(ent, true)
end)

hook.Add("EntityRemoved", "WhiteRP.DoorTimerCleanup", function(ent)
    timer.Remove("WhiteRP.DoorClose." .. ent:EntIndex())
end)
