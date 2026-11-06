local C = {
    panel = Color(18, 19, 24, 205), line = Color(255, 255, 255, 22), orange = Color(241, 143, 38),
    white = Color(245, 245, 248), muted = Color(175, 178, 187), green = Color(88, 200, 120), blue = Color(85, 155, 235), red = Color(230, 83, 82)
}

surface.CreateFont("WhiteRP.HUD.Brand", {font = "Montserrat", size = 34, weight = 700, antialias = true, extended = true})
surface.CreateFont("WhiteRP.HUD.Main", {font = "Montserrat", size = 19, weight = 600, antialias = true, extended = true})
surface.CreateFont("WhiteRP.HUD.Small", {font = "Montserrat", size = 15, weight = 500, antialias = true, extended = true})
surface.CreateFont("WhiteRP.HUD.Micro", {font = "Montserrat", size = 13, weight = 600, antialias = true, extended = true})

local hidden = {CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true, CHudCrosshair=true, DarkRP_HUD=true, DarkRP_LocalPlayerHUD=true}
hook.Add("HUDShouldDraw", "WhiteRP.HideDefaultHUD", function(name) if hidden[name] then return false end end)

local function Box(x, y, w, h, color)
    surface.SetDrawColor(color)
    surface.DrawRect(math.floor(x), math.floor(y), math.ceil(w), math.ceil(h))
end

local function Plate(x, y, w, h)
    Box(x, y, w, h, C.panel)
    surface.SetDrawColor(C.line)
    surface.DrawOutlinedRect(x, y, w, h, 1)
    Box(x, y, 0, h, C.orange)
end

local function Money(n)
    local s = tostring(math.floor(n or 0))
    while true do local changed; s, changed = s:gsub("^(%-?%d+)(%d%d%d)", "%1 %2"); if changed == 0 then break end end
    return s .. " ₽"
end

hook.Add("HUDPaint", "WhiteRP.HUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local w, h = ScrW(), ScrH()
    local scale = math.Clamp(h / 1080, 0.72, 1.15)
    local pad = 28 * scale

    local job = WhiteRP.GetJob(ply:GetNW2Int("wrp_job", 1))
    draw.SimpleText("WHITE", "WhiteRP.HUD.Brand", w - pad, pad - 3, C.orange, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText("RP", "WhiteRP.HUD.Main", w - pad, pad + 30 * scale, C.white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    local brandW = 150 * scale
    Plate(w - pad - brandW, pad + 64 * scale, brandW, 35 * scale)
    draw.SimpleText(job.name, "WhiteRP.HUD.Small", w - pad - brandW / 2, pad + 81.5 * scale, C.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local nextPay = ply:GetNW2Float("wrp_next_payday", CurTime() + WhiteRP.Config.PaydayInterval)
    local remain = math.max(0, math.ceil(nextPay - CurTime()))
    Plate(w - pad - 252 * scale, pad + 106 * scale, 252 * scale, 36 * scale)
    draw.SimpleText("ВЫПЛАТА ЧЕРЕЗ  " .. string.format("%02d:%02d", math.floor(remain / 60), remain % 60), "WhiteRP.HUD.Micro", w - pad - 126 * scale, pad + 124 * scale, C.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local x, y = pad, h - pad - 54 * scale
    local avatar = vgui.GetWorldPanel()
    local health = math.max(0, ply:Health())
    local armor = math.max(0, ply:Armor())
    local cells = {
        {"HP", health, C.red, 74}, {"БРОНЯ", armor, C.blue, 96}, {"БАЛАНС", Money(ply:GetNW2Int("wrp_money", 0)), C.green, 180}
    }
    Plate(x, y, 52 * scale, 54 * scale)
    draw.SimpleText(string.upper(string.sub(ply:Nick(), 1, 1)), "WhiteRP.HUD.Main", x + 26 * scale, y + 27 * scale, C.orange, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    x = x + 60 * scale
    for _, item in ipairs(cells) do
        local cw = item[4] * scale
        Plate(x, y, cw, 54 * scale)
        draw.SimpleText(item[1], "WhiteRP.HUD.Micro", x + 10 * scale, y + 8 * scale, C.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(tostring(item[2]), "WhiteRP.HUD.Small", x + 10 * scale, y + 31 * scale, item[3], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        x = x + cw + 7 * scale
    end

    local wep = ply:GetActiveWeapon()
    if ply:Alive() and IsValid(wep) then
        local name = wep:GetPrintName()
        if not name or name == "" then name = wep:GetClass() end
        local clip, ammo = wep:Clip1(), ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        if clip >= 0 then
            local right = w - pad
            surface.SetFont("WhiteRP.HUD.Main")
            local ammoText = clip .. "  /  " .. ammo
            local aw = surface.GetTextSize(ammoText) + 28 * scale
            local nw = math.min(250 * scale, surface.GetTextSize(name) + 28 * scale)
            Plate(right - aw, y, aw, 54 * scale)
            draw.SimpleText(ammoText, "WhiteRP.HUD.Main", right - aw / 2, y + 27 * scale, C.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            Plate(right - aw - nw - 7 * scale, y, nw, 54 * scale)
            draw.SimpleText(name, "WhiteRP.HUD.Small", right - aw - nw / 2 - 7 * scale, y + 27 * scale, C.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if ply:Alive() then
        local trace = ply:GetEyeTrace()
        local enemy = IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity ~= ply
        surface.SetDrawColor(enemy and C.red or C.white)
        surface.DrawRect(w / 2 - 1, h / 2 - 1, 2, 2)
        surface.DrawOutlinedRect(w / 2 - 7, h / 2 - 7, 14, 14, 1)
    end
end)
