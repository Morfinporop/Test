local jobsFrame

local function OpenJobs(board, jobs)
    if IsValid(jobsFrame) then jobsFrame:Remove() end
    local f = vgui.Create("DFrame")
    jobsFrame = f
    f:SetSize(570, math.min(620, ScrH()-80)); f:Center(); f:SetTitle(""); f:MakePopup()
    f:ShowCloseButton(false)
    f.Paint = function(_,w,h)
        Derma_DrawBackgroundBlur(f, SysTime())
        surface.SetDrawColor(18,19,24,248); surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(241,143,38); surface.DrawRect(0,0,w,3)
        draw.SimpleText("ПРОФЕССИИ", "WhiteRP.Menu.Title", 24, 30, Color(241,143,38), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Выберите занятие и получайте регулярный доход", "WhiteRP.Menu.Small", 24, 56, Color(175,178,187), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    local close = vgui.Create("DButton", f); close:SetText("×"); close:SetFont("WhiteRP.Menu.Title"); close:SetTextColor(color_white); close:SetSize(38,34); close:SetPos(f:GetWide()-46,8)
    close.DoClick = function() f:Close() end
    close.Paint = function(self,w,h) if self:IsHovered() then surface.SetDrawColor(241,143,38); surface.DrawRect(0,0,w,h) end end
    local scroll = vgui.Create("DScrollPanel", f); scroll:SetPos(18,82); scroll:SetSize(f:GetWide()-36,f:GetTall()-100)
    for _, job in ipairs(jobs) do
        local row = vgui.Create("DButton", scroll); row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(78); row:SetText("")
        row.Paint = function(self,w,h)
            surface.SetDrawColor(self:IsHovered() and Color(39,41,48,255) or Color(27,29,36,255)); surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(job.color or Color(241,143,38)); surface.DrawRect(0,0,4,h)
            draw.SimpleText(job.name,"WhiteRP.Menu.Item",18,23,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            draw.SimpleText(job.category .. " · " .. (job.max == 0 and "без лимита" or "мест: " .. job.max),"WhiteRP.Menu.Small",18,52,Color(175,178,187),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            draw.SimpleText("+" .. job.salary .. " ₽ / выплата","WhiteRP.Menu.Item",w-16,37,Color(241,143,38),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end
        row.DoClick = function()
            net.Start("wrp_job_select"); net.WriteUInt(job.id,8); net.WriteEntity(board); net.SendToServer()
            f:Close()
        end
    end
end

net.Receive("wrp_joblist", function()
    local board = net.ReadEntity()
    local count = net.ReadUInt(8)
    local jobs = {}
    for i=1,count do
        jobs[i] = {id=net.ReadUInt(8),name=net.ReadString(),category=net.ReadString(),salary=net.ReadUInt(16),max=net.ReadUInt(8),color=net.ReadColor()}
    end
    OpenJobs(board,jobs)
end)
