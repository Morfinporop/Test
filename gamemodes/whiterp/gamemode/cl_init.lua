include("shared.lua")

include("whiterp/cl_hud.lua")
include("whiterp/cl_qmenu.lua")
include("whiterp/cl_jobs.lua")
include("whiterp/cl_admin.lua")
include("whiterp/cl_tools.lua")

net.Receive("wrp_notify", function()
    notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, 3)
    surface.PlaySound("buttons/button15.wav")
end)
