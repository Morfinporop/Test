DeriveGamemode("sandbox")

GM.Name = "WhiteRP"
GM.Author = "WhiteRP Team"
GM.Email = ""
GM.Website = ""
GM.TeamBased = true

WhiteRP = WhiteRP or {}
WhiteRP.Config = {
    StartMoney = 1500,
    PaydayInterval = 300,
    DefaultPropLimit = 25,
    AdminPropLimit = 250,
    SpawnCooldown = 0.12,
    JobChangeCooldown = 15,
    MaxMoney = 100000000,
    Currency = "₽"
}

WhiteRP.Jobs = {
    [1] = {name = "Житель", category = "Гражданские", salary = 45, max = 0, model = "models/player/group01/male_07.mdl", color = Color(160, 170, 185)},
    [2] = {name = "Строитель", category = "Гражданские", salary = 65, max = 0, model = "models/player/group01/male_04.mdl", color = Color(220, 155, 65)},
    [3] = {name = "Полицейский", category = "Государство", salary = 110, max = 4, model = "models/player/police.mdl", color = Color(75, 135, 220), weapons = {"weapon_stunstick", "weapon_wrp_pistol"}},
    [4] = {name = "Медик", category = "Государство", salary = 95, max = 3, model = "models/player/odessa.mdl", color = Color(80, 190, 145)},
    [5] = {name = "Механик", category = "Гражданские", salary = 75, max = 3, model = "models/player/group03/male_06.mdl", color = Color(205, 120, 70)}
}

WhiteRP.AllowedTools = {
    material = true,
    wrp_door = true,
    wrp_keypad = true,
    wrp_prop_push = true,
    remover = true
}

function WhiteRP.GetJob(jobID)
    return WhiteRP.Jobs[tonumber(jobID) or -1] or WhiteRP.Jobs[1]
end

function WhiteRP.FormatMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    local str = tostring(amount)
    while true do
        local changed
        str, changed = str:gsub("^(%-?%d+)(%d%d%d)", "%1 %2")
        if changed == 0 then break end
    end
    return str .. " " .. WhiteRP.Config.Currency
end

function WhiteRP.IsAdmin(ply)
    return IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin())
end

function WhiteRP.CanUseTool(mode)
    return WhiteRP.AllowedTools[mode] == true
end
