include("shared.lua")

local orange = Color(241, 143, 38)
local panel = Color(20, 20, 26, 225)

function ENT:Draw()
    self:DrawModel()
    local pos = self:GetPos() + self:GetUp() * 78 + self:GetForward() * -1
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    cam.Start3D2D(pos, ang, 0.08)
        surface.SetDrawColor(panel)
        surface.DrawRect(-130, -42, 260, 76)
        surface.SetDrawColor(orange)
        surface.DrawRect(-130, 32, 260, 3)
        draw.SimpleText(self:GetBoardTitle() ~= "" and self:GetBoardTitle() or "ПРОФЕССИИ", "DermaLarge", 0, -18, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Нажмите E · выбрать работу", "DermaDefaultBold", 0, 12, Color(210, 210, 215), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
