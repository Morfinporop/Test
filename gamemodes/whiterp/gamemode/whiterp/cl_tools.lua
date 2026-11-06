net.Receive("wrp_keypad_prompt", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    Derma_StringRequest("КЕЙПАД", "Введите код доступа:", "", function(value)
        if not IsValid(ent) then return end
        net.Start("wrp_keypad_submit")
        net.WriteEntity(ent)
        net.WriteString(string.sub(tostring(value or ""), 1, 8))
        net.SendToServer()
    end)
end)
