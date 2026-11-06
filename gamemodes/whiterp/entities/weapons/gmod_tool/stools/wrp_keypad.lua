TOOL.Category = "WhiteRP"
TOOL.Name = "Кейпад"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Mode = "wrp_keypad"
TOOL.ClientConVar = {pin = "1234"}

if CLIENT then
    language.Add("tool.wrp_keypad.name", "Кейпад")
    language.Add("tool.wrp_keypad.desc", "Назначить код для вашей скрывающейся двери")
    language.Add("tool.wrp_keypad.0", "Введите код в панели инструмента и нажмите ЛКМ по своей двери")
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsWorld() or not ent:GetNW2Bool("wrp_door", false) then return false end
    if CLIENT then return true end
    if ent.WRP_DoorOwner ~= self:GetOwner():SteamID64() and not WhiteRP.IsAdmin(self:GetOwner()) then return false end
    local pin = self:GetClientInfo("pin") or ""
    if not string.match(pin, "^%d%d%d%d%d?%d?%d?%d?$") then
        WhiteRP.Notify(self:GetOwner(), "Код должен содержать от 4 до 8 цифр")
        return false
    end
    ent.WRP_KeypadPin = pin
    WhiteRP.Notify(self:GetOwner(), "Кейпад настроен")
    return true
end

function TOOL.BuildCPanel(panel)
    panel:Help("Код от 4 до 8 цифр. Нажатие E рядом с дверью вызовет запрос кода для остальных игроков.")
    panel:TextEntry("Код доступа", "wrp_keypad_pin")
end
