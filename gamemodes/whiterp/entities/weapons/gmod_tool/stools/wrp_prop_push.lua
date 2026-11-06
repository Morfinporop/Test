TOOL.Category = "WhiteRP"
TOOL.Name = "Проталкиватель пропов"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Mode = "wrp_prop_push"
TOOL.ClientConVar = {force = "350"}

if CLIENT then
    language.Add("tool.wrp_prop_push.name", "Проталкиватель пропов")
    language.Add("tool.wrp_prop_push.desc", "Аккуратный импульс для принадлежащего вам пропа")
    language.Add("tool.wrp_prop_push.0", "ЛКМ — толкнуть проп от себя")
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsWorld() or ent:IsPlayer() then return false end
    if CLIENT then return true end
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetCreator()
    if IsValid(owner) and owner ~= self:GetOwner() and not WhiteRP.IsAdmin(self:GetOwner()) then return false end
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) or not phys:IsMotionEnabled() then return false end
    local force = math.Clamp(self:GetClientNumber("force", 350), 50, 700)
    local impulse = self:GetOwner():GetAimVector() * force * math.Clamp(phys:GetMass(), 1, 35)
    phys:ApplyForceCenter(impulse)
    return true
end

function TOOL.BuildCPanel(panel)
    panel:Help("Толкает только физические объекты. Сила ограничена сервером.")
    panel:NumSlider("Сила", "wrp_prop_push_force", 50, 700, 0)
end
