--[[
Don't skid and reupload this open sourced code without crediting me, mcdaggitt!
--]]

local p = game.Players.LocalPlayer
local r, c, h = game.ReplicatedStorage.Remotes.Compass, p.Backpack:WaitForChild("Compass"), p.Character:WaitForChild("Humanoid")
h:EquipTool(c)
task.wait()
r:FireServer("Vote Map", 3)
r:FireServer("Vote Map", 4)
task.wait()
h:UnequipTools()
