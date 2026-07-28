local player = game.Players.LocalPlayer
local adminCanvas = player:WaitForChild("PlayerGui"):WaitForChild("Admin")
local function updateAdminVisibility()
    for _, child in ipairs(adminCanvas:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.Visible = _G.g_adminmenu
        end
    end
end
updateAdminVisibility()
