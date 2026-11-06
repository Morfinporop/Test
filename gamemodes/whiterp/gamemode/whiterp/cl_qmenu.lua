local orange = Color(241, 143, 38)
local bg = Color(18, 19, 24, 245)
local card = Color(27, 29, 36, 240)
local line = Color(255, 255, 255, 18)
local white = Color(245, 245, 248)
local muted = Color(165, 169, 179)
local favFile = "whiterp/favorites.json"
local defaultFavs = {"models/props_c17/FurnitureDrawer001a.mdl", "models/props_c17/oildrum001.mdl", "models/props_junk/wood_crate001a.mdl"}
local favs = {}
local frame

file.CreateDir("whiterp")
surface.CreateFont("WhiteRP.Menu.Title", {font="Montserrat", size=25, weight=700, antialias=true, extended=true})
surface.CreateFont("WhiteRP.Menu.Tab", {font="Montserrat", size=15, weight=700, antialias=true, extended=true})
surface.CreateFont("WhiteRP.Menu.Item", {font="Montserrat", size=14, weight=600, antialias=true, extended=true})
surface.CreateFont("WhiteRP.Menu.Small", {font="Montserrat", size=12, weight=500, antialias=true, extended=true})

local function IsAdmin() return IsValid(LocalPlayer()) and LocalPlayer():IsAdmin() end
local function LoadFavs()
    local raw = file.Read(favFile, "DATA")
    local data = raw and util.JSONToTable(raw)
    if istable(data) then for _, value in ipairs(data) do if isstring(value) then favs[value] = true end end
    else for _, value in ipairs(defaultFavs) do favs[value] = true end end
end
local function SaveFavs()
    local data = {}
    for model in pairs(favs) do data[#data + 1] = model end
    table.sort(data)
    file.Write(favFile, util.TableToJSON(data))
end
LoadFavs()

local propCache
local function PropModels()
    if propCache then return propCache end
    local result, seen = {}, {}
    local ok, lists = pcall(spawnmenu.GetPropTable)
    if ok and istable(lists) then
        for _, sub in pairs(lists) do
            for _, entry in pairs(istable(sub) and sub.contents or {}) do
                if istable(entry) and entry.type == "model" and isstring(entry.model) then
                    local model = string.lower(entry.model)
                    if not seen[model] then
                        seen[model] = true
                        result[#result + 1] = {id=model, name=string.StripExtension(string.GetFileFromFilename(model)), model=model}
                    end
                end
            end
        end
    end
    table.sort(result, function(a,b) return a.name < b.name end)
    while #result > 300 do result[#result] = nil end
    propCache = result
    return propCache
end

local toolItems = {
    {id="material", name="Материалы", info="Изменение материала пропа"},
    {id="wrp_door", name="Скрывающая дверь", info="Привязка пропа как двери"},
    {id="wrp_keypad", name="Кейпад", info="Кодовый доступ к двери"},
    {id="wrp_prop_push", name="Проталкиватель пропов", info="Импульс для своих пропов"},
    {id="remover", name="Удаление своих пропов", info="Безопасное удаление объектов"}
}

local function GetFrame()
    if IsValid(frame) then return frame end
    local f = vgui.Create("DFrame")
    frame = f
    f:SetSize(math.min(1180, ScrW() - 60), math.min(760, ScrH() - 60))
    f:Center()
    f:SetTitle("")
    f:ShowCloseButton(false)
    f:SetDraggable(false)
    f:SetVisible(false)
    f:SetAlpha(0)
    f.Paint = function(_, w, h)
        Derma_DrawBackgroundBlur(f, f.OpenAt or SysTime())
        surface.SetDrawColor(bg); surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(orange); surface.DrawRect(0, 0, w, 3)
        surface.SetDrawColor(line); surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("WHITE", "WhiteRP.Menu.Title", 28, 28, orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("RP  /  УПРАВЛЕНИЕ СЕРВЕРОМ", "WhiteRP.Menu.Small", 116, 31, muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    f.OnKeyCodePressed = function(self, key) if key == KEY_ESCAPE or key == KEY_Q then self:Close() end end

    local close = vgui.Create("DButton", f)
    close:SetText("×")
    close:SetFont("WhiteRP.Menu.Title")
    close:SetTextColor(white)
    close:SetSize(42, 36)
    close:SetPos(f:GetWide() - 52, 12)
    close.Paint = function(self,w,h) if self:IsHovered() then surface.SetDrawColor(orange); surface.DrawRect(0,0,w,h) end end
    close.DoClick = function() f:Close() end

    local search = vgui.Create("DTextEntry", f)
    search:SetSize(260, 38)
    search:SetPos(f:GetWide() - 330, 65)
    search:SetFont("WhiteRP.Menu.Item")
    search:SetPlaceholderText("Поиск")
    search:SetUpdateOnType(true)
    search.Paint = function(self,w,h)
        surface.SetDrawColor(card); surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(line); surface.DrawOutlinedRect(0,0,w,h,1)
        self:DrawTextEntryText(white, orange, white)
    end

    local tabs = vgui.Create("DPanel", f)
    tabs:SetPos(26, 65)
    tabs:SetSize(f:GetWide() - 370, 40)
    tabs.Paint = function() end
    local content = vgui.Create("DScrollPanel", f)
    content:SetPos(26, 120)
    content:SetSize(f:GetWide() - 52, f:GetTall() - 148)
    content.Paint = function(_,w,h) surface.SetDrawColor(Color(13,14,18,180)); surface.DrawRect(0,0,w,h) end
    local vbar = content:GetVBar()
    vbar:SetWide(5)
    vbar.Paint = function(_,w,h) surface.SetDrawColor(Color(255,255,255,12)); surface.DrawRect(0,0,w,h) end
    vbar.btnGrip.Paint = function(_,w,h) surface.SetDrawColor(orange); surface.DrawRect(0,0,w,h) end
    vbar.btnUp.Paint = function() end; vbar.btnDown.Paint = function() end

    f.CurrentTab = "fav"
    f.ActiveTool = nil
    f.ToolPanel = nil

    local function ClearContent()
        content:Clear()
        f.ToolPanel = nil
    end

    local function Cards(items, kind)
        ClearContent()
        local canvas = content:GetCanvas()
        local columns = math.max(1, math.floor((content:GetWide() - 20) / 150))
        local cellW, cellH, gap = 138, 150, 10
        local row, col = 0, 0
        for _, item in ipairs(items) do
            local searchText = string.lower((item.name or "") .. " " .. (item.id or ""))
            local q = string.lower(search:GetValue() or "")
            if q == "" or string.find(searchText, q, 1, true) then
                local x, y = 12 + col * (cellW + gap), 12 + row * (cellH + gap)
                local button = vgui.Create("DButton", canvas)
                button:SetText("")
                button:SetPos(x,y)
                button:SetSize(cellW,cellH)
                button.Item = item
                button.Hover = 0
                local icon
                if isstring(item.model) and item.model ~= "" then
                    icon = vgui.Create("SpawnIcon", button)
                    icon:SetPos(10, 9); icon:SetSize(cellW - 20, 102)
                    icon:SetModel(item.model)
                    icon:SetMouseInputEnabled(false)
                    icon:SetTooltip(item.name)
                end
                button.Paint = function(self,w,h)
                    self.Hover = Lerp(math.min(1, FrameTime()*12), self.Hover, self:IsHovered() and 1 or 0)
                    surface.SetDrawColor(card); surface.DrawRect(0,0,w,h)
                    surface.SetDrawColor(255,255,255,18); surface.DrawOutlinedRect(0,0,w,h,1)
                    if self.Hover > 0 then surface.SetDrawColor(orange.r,orange.g,orange.b,65*self.Hover); surface.DrawRect(0,0,w,h) end
                    if not item.model then
                        draw.SimpleText(string.upper(string.sub(item.name or "?",1,1)), "WhiteRP.Menu.Title", w/2, 52, Color(255,255,255,85), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    draw.SimpleText(item.name or item.id, "WhiteRP.Menu.Item", w/2, h-20, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    if item.model and favs[item.model] then draw.SimpleText("★", "WhiteRP.Menu.Item", w-14, 13, orange, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                end
                button.DoClick = function()
                    if kind == "prop" then RunConsoleCommand("gm_spawn", item.model)
                    elseif kind == "npc" then RunConsoleCommand("gmod_spawnnpc", item.id)
                    elseif kind == "ent" then RunConsoleCommand("gm_spawnsent", item.id)
                    elseif kind == "wep" then RunConsoleCommand("gm_giveswep", item.id) end
                end
                button.DoRightClick = function()
                    if not item.model then return end
                    favs[item.model] = not favs[item.model] and true or nil
                    SaveFavs()
                    if f.CurrentTab == "fav" then f:BuildTab("fav") else button:InvalidateLayout(true) end
                end
                col = col + 1
                if col >= columns then col = 0; row = row + 1 end
            end
        end
        local rows = row + (col > 0 and 1 or 0)
        canvas:SetTall(math.max(content:GetTall(), 24 + rows * (cellH + gap)))
    end

    local function FindTool(mode)
        local ok, menu = pcall(spawnmenu.GetToolMenu, "Main")
        if ok and istable(menu) then
            for _, category in pairs(menu) do
                local list = istable(category) and (category.Items or category) or {}
                for _, entry in pairs(list) do
                    if istable(entry) and entry.ItemName == mode then return entry end
                end
            end
        end
        local stored = weapons.GetStored("gmod_tool")
        local tool = stored and stored.Tool and stored.Tool[mode]
        if istable(tool) and isfunction(tool.BuildCPanel) then return {CPanelFunction = tool.BuildCPanel} end
    end

    local function ShowTools()
        ClearContent()
        local canvas = content:GetCanvas()
        local y = 12
        local selected = f.ActiveTool or toolItems[1].id
        for _, item in ipairs(toolItems) do
            local btn = vgui.Create("DButton", canvas)
            btn:SetText(""); btn:SetPos(12,y); btn:SetSize(250,58)
            btn.Paint = function(self,w,h)
                if selected == item.id then surface.SetDrawColor(orange.r,orange.g,orange.b,100)
                elseif self:IsHovered() then surface.SetDrawColor(Color(255,255,255,18))
                else surface.SetDrawColor(card) end
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(line); surface.DrawOutlinedRect(0,0,w,h,1)
                draw.SimpleText(item.name,"WhiteRP.Menu.Item",14,18,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                draw.SimpleText(item.info,"WhiteRP.Menu.Small",14,39,muted,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
            btn.DoClick = function()
                f.ActiveTool = item.id
                RunConsoleCommand("gmod_toolmode", item.id)
                f:BuildTab("tool")
            end
            y = y + 66
        end
        local info = vgui.Create("DPanel", canvas)
        info:SetPos(278,12); info:SetSize(math.max(300,content:GetWide()-302), 460)
        info.Paint = function(self,w,h)
            surface.SetDrawColor(card); surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(line); surface.DrawOutlinedRect(0,0,w,h,1)
            local current
            for _, t in ipairs(toolItems) do if t.id == (f.ActiveTool or toolItems[1].id) then current=t break end end
            draw.SimpleText(current and current.name or "ИНСТРУМЕНТ", "WhiteRP.Menu.Title", 24, 30, orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Выберите инструмент в списке слева, затем применяйте его на пропы.", "WhiteRP.Menu.Small", 24, 62, muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local mode = f.ActiveTool or toolItems[1].id
        local entry = FindTool(mode)
        local hasPanel = entry and isfunction(entry.CPanelFunction)
        if hasPanel then
            local cp = vgui.Create("ControlPanel", info)
            cp:SetPos(18,88); cp:SetSize(info:GetWide()-36,info:GetTall()-104)
            if cp.SetLabel then cp:SetLabel("") end
            local ok, err = pcall(entry.CPanelFunction, cp)
            if not ok then ErrorNoHalt("[WhiteRP] Tool panel error: " .. tostring(err) .. "\n") end
        elseif mode == "wrp_keypad" then
            local label = vgui.Create("DLabel", info)
            label:SetPos(24,98); label:SetSize(220,24); label:SetFont("WhiteRP.Menu.Small"); label:SetTextColor(muted); label:SetText("КОД ДОСТУПА")
            local pin = vgui.Create("DTextEntry", info)
            pin:SetPos(24,132); pin:SetSize(250,34); pin:SetNumeric(true); pin:SetPlaceholderText("4–8 цифр")
            local cv = GetConVar("wrp_keypad_pin")
            if cv then pin:SetText(cv:GetString()) end
            pin.OnEnter = function(self) RunConsoleCommand("wrp_keypad_pin", string.sub(self:GetValue(),1,8)) end
            pin.OnLoseFocus = function(self) RunConsoleCommand("wrp_keypad_pin", string.sub(self:GetValue(),1,8)) end
        elseif mode == "wrp_prop_push" then
            local force = vgui.Create("DNumSlider", info)
            force:SetPos(18,112); force:SetSize(info:GetWide()-36,45); force:SetText("Сила толчка"); force:SetMin(50); force:SetMax(700); force:SetDecimals(0); force:SetConVar("wrp_prop_push_force")
        elseif mode == "wrp_door" then
            local help = vgui.Create("DLabel", info)
            help:SetPos(24,112); help:SetSize(info:GetWide()-48,80); help:SetWrap(true); help:SetFont("WhiteRP.Menu.Small"); help:SetTextColor(muted)
            help:SetText("ЛКМ помечает ваш проп как дверь. Закрытая дверь скрыта, но блокирует движение; владелец взаимодействует с ней клавишей E.")
        end
        canvas:SetTall(math.max(content:GetTall(), 500))
    end

    function f:BuildTab(id)
        self.CurrentTab = id
        if id == "tool" then ShowTools() return end
        local items = {}
        if id == "fav" then
            for model in pairs(favs) do items[#items+1] = {id=model,name=string.StripExtension(string.GetFileFromFilename(model)),model=model} end
            table.sort(items,function(a,b) return a.name < b.name end)
            Cards(items,"prop")
        elseif id == "prop" then Cards(PropModels(),"prop")
        elseif id == "npc" then
            for class, npc in pairs(list.Get("NPC") or {}) do
                if istable(npc) and npc.Spawnable then items[#items+1] = {id=class,name=npc.Name or class,model=npc.Model} end
            end
            table.sort(items,function(a,b) return a.name < b.name end)
            Cards(items,"npc")
        elseif id == "ent" then
            items = {{id="wrp_jobboard",name="NPC-рекрутер профессий",model="models/Humans/Group01/Male_07.mdl"}}
            Cards(items,"ent")
        elseif id == "wep" then
            for class, wep in pairs(list.Get("Weapon") or {}) do
                if istable(wep) and wep.Spawnable then items[#items+1] = {id=class,name=wep.PrintName or class,model=wep.WorldModel} end
            end
            table.sort(items,function(a,b) return a.name < b.name end)
            Cards(items,"wep")
        end
    end

    local tabDefs = {{"fav","ИЗБРАННОЕ"},{"tool","ИНСТРУМЕНТЫ"}}
    if IsAdmin() then
        tabDefs[#tabDefs+1] = {"prop","ПРОПЫ"}
        tabDefs[#tabDefs+1] = {"wep","ОРУЖИЕ"}
        tabDefs[#tabDefs+1] = {"ent","СУЩНОСТИ"}
        tabDefs[#tabDefs+1] = {"npc","NPC"}
    end
    local tx = 0
    for _, def in ipairs(tabDefs) do
        surface.SetFont("WhiteRP.Menu.Tab")
        local tw = surface.GetTextSize(def[2]) + 24
        local btn = vgui.Create("DButton", tabs)
        btn:SetText(""); btn:SetPos(tx,0); btn:SetSize(tw,40)
        btn.Paint = function(self,w,h)
            local active = f.CurrentTab == def[1]
            surface.SetDrawColor(active and Color(241,143,38,85) or (self:IsHovered() and Color(255,255,255,12) or Color(0,0,0,0)))
            surface.DrawRect(0,0,w,h)
            if active then surface.SetDrawColor(orange); surface.DrawRect(0,h-2,w,2) end
            draw.SimpleText(def[2],"WhiteRP.Menu.Tab",w/2,h/2,active and white or muted,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function() f:BuildTab(def[1]) end
        tx = tx + tw + 5
    end
    f.Search = search
    search.OnValueChange = function() f:BuildTab(f.CurrentTab) end
    f:BuildTab("fav")
    f.PerformLayout = function(self,w,h)
        close:SetPos(w-52,12); search:SetPos(w-330,65); tabs:SetSize(w-370,40); content:SetSize(w-52,h-148)
    end
    return f
end

function OpenWhiteRPMenu()
    local f = GetFrame()
    f.OpenAt = SysTime()
    f:SetVisible(true)
    f:MakePopup()
    f:SetAlpha(255)
    f:BuildTab(f.CurrentTab or "fav")
end

hook.Add("OnSpawnMenuOpen", "WhiteRP.CustomQMenu", function()
    if hook.Run("SpawnMenuOpen") == false then return true end
    OpenWhiteRPMenu()
    return true
end)
hook.Add("OnSpawnMenuClose", "WhiteRP.CustomQMenuClose", function()
    if IsValid(frame) then frame:Close() end
    return true
end)

concommand.Add("wrp_menu", OpenWhiteRPMenu)
