local adminFrame
local roster = {}

local function SendAction(action, uid, value)
    net.Start("wrp_admin_action")
    net.WriteString(action)
    net.WriteUInt(uid,16)
    net.WriteInt(tonumber(value) or 0,32)
    net.SendToServer()
end

local function Refresh()
    net.Start("wrp_admin_roster_request") net.SendToServer()
end

local function BuildAdmin()
    if not IsValid(adminFrame) then return end
    local f = adminFrame
    f.Scroll:Clear()
    for _, target in ipairs(roster) do
        local row = vgui.Create("DPanel", f.Scroll)
        row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(102)
        row.Paint = function(_,w,h)
            surface.SetDrawColor(27,29,36,255); surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(241,143,38); surface.DrawRect(0,0,3,h)
            draw.SimpleText(target.name .. "  ·  " .. target.steamid,"WhiteRP.Menu.Item",14,18,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            local job = WhiteRP.GetJob(target.job)
            draw.SimpleText(job.name .. "  ·  " .. tostring(target.money) .. " ₽","WhiteRP.Menu.Small",14,41,Color(175,178,187),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end
        local jobs = vgui.Create("DComboBox",row); jobs:SetPos(14,60); jobs:SetSize(165,30); jobs:SetValue("Сменить профессию")
        for id, job in SortedPairs(WhiteRP.Jobs) do jobs:AddChoice(job.name,id) end
        jobs.OnSelect = function(_,_,_,id) SendAction("setjob",target.uid,id) end
        local amount = vgui.Create("DTextEntry",row); amount:SetPos(187,60); amount:SetSize(100,30); amount:SetNumeric(true); amount:SetPlaceholderText("Баланс")
        local money = vgui.Create("DButton",row); money:SetPos(293,60); money:SetSize(90,30); money:SetText("Задать ₽")
        money.DoClick = function() SendAction("setmoney",target.uid,amount:GetValue()) end
        local actions = {{"bring","К себе"},{"goto","К игроку"},{"freeze","Freeze"},{"kick","Kick"}}
        local x = 390
        for _, a in ipairs(actions) do
            local b = vgui.Create("DButton",row); b:SetPos(x,60); b:SetSize(68,30); b:SetText(a[2]); b.DoClick = function() SendAction(a[1],target.uid,0) end
            x = x + 72
        end
    end
end

local function OpenAdmin()
    if not LocalPlayer():IsAdmin() then return end
    if IsValid(adminFrame) then adminFrame:Remove() end
    local f = vgui.Create("DFrame"); adminFrame=f
    f:SetSize(math.min(920,ScrW()-50),math.min(760,ScrH()-50)); f:Center(); f:SetTitle(""); f:MakePopup(); f:ShowCloseButton(false)
    f.Paint = function(_,w,h)
        Derma_DrawBackgroundBlur(f,SysTime())
        surface.SetDrawColor(18,19,24,248); surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(241,143,38); surface.DrawRect(0,0,w,3)
        draw.SimpleText("АДМИНИСТРАТИВНАЯ ПАНЕЛЬ","WhiteRP.Menu.Title",22,28,Color(241,143,38),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        draw.SimpleText("Действия журналируются на сервере","WhiteRP.Menu.Small",22,53,Color(175,178,187),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    end
    local close=vgui.Create("DButton",f); close:SetText("×"); close:SetFont("WhiteRP.Menu.Title"); close:SetSize(38,34); close:SetPos(f:GetWide()-46,8); close.DoClick=function() f:Close() end
    local refresh=vgui.Create("DButton",f); refresh:SetText("Обновить список"); refresh:SetPos(22,72); refresh:SetSize(140,32); refresh.DoClick=Refresh
    local scroll=vgui.Create("DScrollPanel",f); scroll:SetPos(22,114); scroll:SetSize(f:GetWide()-44,f:GetTall()-136); f.Scroll=scroll
    BuildAdmin(); Refresh()
end

net.Receive("wrp_admin_roster", function()
    local count=net.ReadUInt(8); roster={}
    for i=1,count do
        roster[i]={uid=net.ReadUInt(16),name=net.ReadString(),steamid=net.ReadString(),job=net.ReadUInt(8),money=net.ReadUInt(32)}
    end
    BuildAdmin()
end)

concommand.Add("wrp_adminpanel",OpenAdmin)
hook.Add("PlayerButtonDown","WhiteRP.AdminHotkey",function(ply,key)
    if key == KEY_F3 and IsFirstTimePredicted() and ply == LocalPlayer() and ply:IsAdmin() then OpenAdmin() end
end)
