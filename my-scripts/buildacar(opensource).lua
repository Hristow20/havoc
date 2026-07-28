local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local vs, ve = workspace.__THINGS.__REMOTES.vehicle_spawn, workspace.__THINGS.__REMOTES.vehicle_stop
vs:InvokeServer()
task.wait(1)
local seat
for _, p in ipairs(workspace:GetDescendants()) do
    if (p:IsA("VehicleSeat") or p:IsA("Seat")) and p.Occupant == char:FindFirstChild("Humanoid") then
        seat = p break
    end
end
local pos = Vector3.new(10000000000,0,10000000000)
if seat then seat.CFrame = CFrame.new(pos) else root.CFrame = CFrame.new(pos) end
task.wait(0.2)
ve:InvokeServer()
