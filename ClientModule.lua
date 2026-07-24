local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

game:GetService("Debris")

local Storage = ReplicatedStorage:WaitForChild("Storage")
local Maid = require(Storage.Modules.Utils.Maid)

return function(p1, p2) --[[ Line: 12 | Upvalues: ReplicatedStorage (copy), Players (copy), Storage (copy), RunService (copy), Maid (copy), TweenService (copy), UserInputService (copy) ]]
    local __config = ReplicatedStorage:WaitForChild("__config")

    if not p2 then
        while not __config:GetAttribute("loaded") do
            task.wait()
        end
    end

    local v1 = not p2 and Players.LocalPlayer
    local v2 = not p2 and v1:GetMouse()
    local CurrentCamera = workspace.CurrentCamera
    local v3 = p2 or v1.Character

    if not p2 then
        if v3 then
            while not (v1.Character and v1.Character:IsDescendantOf(workspace)) do
                task.wait()
            end

            task.wait(0.03333333333333333)
        else
            v1.CharacterAdded:Wait()
        end

        v3 = v1.Character
    end

    local v4 = p2 and v3:GetAttribute("Boss")
    local Humanoid = v3:WaitForChild("Humanoid")
    local RootPart = Humanoid.RootPart
    local Animator = Humanoid:WaitForChild("Animator")
    local v5 = false
    local v6 = p1.Parent
    local Handle = v6:WaitForChild("_mod"):WaitForChild("Handle")
    local activateEvent = Instance.new("BindableEvent")

    activateEvent.Name = "activateEvent"
    activateEvent.Parent = v6

    local communicator = Instance.new("BindableFunction")

    communicator.Name = "communicator"
    communicator.Parent = v6

    local v7 = require(Storage.Modules.Weapons:WaitForChild(v6.Name))

    v6:SetAttribute("FireRate", v7.rate)
    v6:SetAttribute("FireMode", v7.mode)

    if v7.canFinish then
        v6:SetAttribute("CanFinish", true)
    end

    if p2 and v7.rate then
        v7.rate = math.min(v7.rate, 750)
    end

    local v8 = v1 and v1.PlayerGui:WaitForChild("UI", 1000)

    local function lerp(p1, p2, p3) --[[ lerp | Line: 69 ]]
        return p1 + (p2 - p1) * p3
    end

    local function loadAnim(p1) --[[ loadAnim | Line: 73 | Upvalues: RunService (ref), Animator (copy) ]]
        local Animation = Instance.new("Animation")

        Animation.AnimationId = "rbxassetid://" .. p1
        RunService.Stepped:Wait()

        return Animator:LoadAnimation(Animation), Animation:Destroy()
    end

    local t = {}

    for k, v in pairs(v6:WaitForChild("_data"):GetChildren()) do
        if v:IsA("ValueBase") then
            t[v.Name] = v.Value
        end
    end

    if not t.durability then
        t.durability = 100
        t.maxDurability = 100
    end

    v6._data.ChildAdded:Connect(function(p1) --[[ Line: 93 | Upvalues: t (copy) ]]
        if not p1:IsA("ValueBase") then
            return
        end

        t[p1.Name] = p1.Value
    end)

    if p2 and (v4 and v7.bossInfAmmo) then
        v6._data.ammoCurrent.Value = math.random(1, v6._data.ammoSize.Value)
    end

    local t2 = {}

    for k, v in pairs(v7.anims) do
        local Animation = Instance.new("Animation")

        Animation.AnimationId = "rbxassetid://" .. v
        RunService.Stepped:Wait()

        local v9 = Animator:LoadAnimation(Animation)

        Animation:Destroy()
        t2[k] = v9
    end

    if t2.noammo then
        t2.noammo.Priority = Enum.AnimationPriority.Action4
    end

    local function getGlobal(p1) --[[ getGlobal | Line: 111 | Upvalues: p2 (copy), v3 (ref) ]]
        return p2 and v3:GetAttribute(p1) or shared[p1]
    end

    local function setGlobal(p1, p22) --[[ setGlobal | Line: 115 | Upvalues: p2 (copy), v3 (ref) ]]
        if p2 then
            v3:SetAttribute(p1, p22)
        else
            shared[p1] = p22
        end
    end

    local function isReloadProcessing() --[[ isReloadProcessing | Line: 123 | Upvalues: t2 (copy) ]]
        return (t2.rechamber and t2.rechamber.IsPlaying or (t2.afterload and t2.afterload.IsPlaying or (t2.preload and t2.preload.IsPlaying or t2.load and t2.load.IsPlaying))) and true or false
    end

    local v10 = false
    local v11 = false
    local v12 = false

    if p2 then
        v3:SetAttribute("reload", false)
    else
        shared.reload = false
    end

    local function getDistance(p1, p2) --[[ getDistance | Line: 140 ]]
        local v1 = typeof(p1) == "Instance" and p1.Position or p1

        return (v1 - (typeof(p2) == "Instance" and p2.Position or p2)).magnitude
    end

    local function getRandomChild(p1) --[[ getRandomChild | Line: 144 ]]
        local v1 = p1:GetChildren()

        return v1[math.random(#v1)]
    end

    local v13 = 0
    local v14 = 0
    local v15 = 0
    local mode = v7.mode
    local v16 = 1
    local v17 = 0

    t.fireMode = mode

    local function isEquipped() --[[ isEquipped | Line: 159 | Upvalues: v13 (ref), v7 (copy) ]]
        return os.clock() - v13 >= v7.equipTime
    end

    local function isFPS() --[[ isFPS | Line: 163 ]]
        local CurrentCamera = workspace.CurrentCamera

        if CurrentCamera then
            return CurrentCamera:GetAttribute("FPS")
        end

        return false
    end

    local function v18(p1) --[[ isHumanoid | Line: 184 | Upvalues: v18 (copy) ]]
        if p1.Parent:FindFirstChild("Humanoid") then
            return p1.Parent
        end

        if p1.Parent == workspace then
            return false
        end

        return v18(p1.Parent)
    end

    local function clampDistanceBetweenVectors(p1, p2, p3) --[[ clampDistanceBetweenVectors | Line: 194 ]]
        return p1 + (p2 - p1).Unit * math.min((p2 - p1).Magnitude, p3)
    end

    local function getHitPos(p1, p2) --[[ getHitPos | Line: 198 | Upvalues: Handle (copy), v2 (copy) ]]
        print("Printing from getHitPos")
        local v1 = if shared.aimPos then if typeof(shared.aimPos) == "Instance" then shared.aimPos.WorldCFrame.LookVector.unit * 10000 else v2.UnitRay.Direction.unit * 10000 else v2.UnitRay.Direction.unit * 10000

        if shared.freeLook then
            p2 = 0
        end

        return p1.WorldPosition, Handle.FireDir.WorldCFrame.LookVector.unit:Lerp(v1, p2).unit
    end

    Humanoid.Running:Connect(function(p1) --[[ Line: 218 | Upvalues: v15 (ref) ]]
        v15 = p1
    end)

    local t3 = {}

    t3.H = t2.inspect and {
        info = "Inspect"
    } or nil
    t3.B = v7.mode_switch and {
        info = "Switch Mode"
    } or nil
    t3["ADS - B"] = {
        info = "Canted Sight"
    }

    local function getAvailableMags() --[[ getAvailableMags | Line: 228 | Upvalues: p2 (copy), v7 (copy), v6 (copy), t (copy), Storage (ref) ]]
        if p2 or (not v7.defaultMag or v6:GetAttribute("oldReload")) then
            return t.mag
        end

        return #Storage.Events.client_callback:Invoke("get_mags", v7, v6._data.magAttached.Value)
    end

    local t4 = {}

    local function finisherFunction(p1) --[[ finisherFunction | Line: 237 | Upvalues: t2 (copy), Humanoid (copy), RootPart (copy), v7 (copy), p2 (copy), v3 (ref) ]]
        if t2.inspect then
            t2.inspect:Stop()
        end

        Humanoid.WalkSpeed = 20

        local Position = p1.Humanoid.RootPart.Position
        local Position2 = RootPart.Position

        Humanoid:MoveTo(Position + (Position2 - Position).Unit * math.min((Position2 - Position).Magnitude, v7.finisherClampDist or 3))

        if p2 then
            v3:SetAttribute("meleeFinisherAnim", true)
        else
            shared.meleeFinisherAnim = true
        end

        if p2 then
            v3:SetAttribute("meleeFinisher", true)
        else
            shared.meleeFinisher = true
        end

        if p2 then
            v3:SetAttribute("isCrouch", false)
        else
            shared.isCrouch = false
        end

        if p2 then
            v3:SetAttribute("isProne", false)
        else
            shared.isProne = false
        end

        shared.Network:InvokeServer("varsFunction", "finish_special", {
            target = p1
        })

        if p2 then
            v3:SetAttribute("meleeFinisherAnim", false)
        else
            shared.meleeFinisherAnim = false
        end

        if p2 then
            v3:SetAttribute("meleeFinisher", false)
        else
            shared.meleeFinisher = false
        end
    end

    local v21 = RaycastParams.new()

    v21.FilterDescendantsInstances = { v3, workspace.Ignored }
    v21.FilterType = Enum.RaycastFilterType.Exclude
    v21.IgnoreWater = true
    v21.CollisionGroup = "Raycast"

    local function tryCast(p1, p2, p3) --[[ tryCast | Line: 261 | Upvalues: v21 (copy) ]]
        local v1 = workspace:Raycast(p1, p2.Unit * p3, v21)

        if v1 then
            return v1
        end

        return false
    end

    local v22 = 0
    local v23 = Maid.new()

    local function fire(p1, p22, p3) --[[ fire | Line: 272 | Upvalues: t (copy), v5 (ref), v6 (copy), t2 (copy), v14 (ref), p2 (copy), v4 (copy), v7 (copy), CurrentCamera (copy), v3 (ref), getHitPos (copy), Handle (copy), Storage (ref), v23 (copy), Humanoid (copy), v21 (copy), v18 (copy), t4 (ref), v22 (ref) ]]
        if t.durability > 0 and (t.ammoCurrent > 0 and (v5 and (v6._mod:FindFirstChild("Handle") and not (t2.rechamber and t2.rechamber.IsPlaying)))) and not (t2.afterload and t2.afterload.IsPlaying) then
            v14 = os.clock()

            if not (p2 and (v4 and v7.bossInfAmmo)) then
                t.ammoCurrent = math.max(t.ammoCurrent - 1, 0)
            end

            local fire = t2.fire

            fire.Priority = not p1 and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action4

            if (v7.gunType ~= "diy_ft" or not t2.fire.IsPlaying) and (p2 or (v7.recoil.canPlayFireAnim or not CurrentCamera:GetAttribute("FPS"))) then
                t2.fire:Stop(1e-14)
                t2.fire:Play()

                if t2.rechamber then
                    t2.fire.Stopped:Once(function() --[[ Line: 283 | Upvalues: t2 (ref) ]]
                        t2.rechamber.Priority = Enum.AnimationPriority.Action4
                        t2.rechamber:Play(1e-9)
                    end)
                end
            end

            local v42 = os.clock()

            if p2 then
                v3:SetAttribute("fireActive", v42)
            else
                shared.fireActive = v42
            end

            if p2 then
                local v52, v62, v72, v8 = unpack(p3)
                local v9 = if typeof(v52) == "Instance" then v52:IsA("BasePart") else false
                local v10 = v9 and v52.CFrame or v52

                local function getAimDirection() --[[ getAimDirection | Line: 331 | Upvalues: v7 (ref), v52 (copy), v72 (copy), v8 (copy), v10 (copy), v3 (ref), v62 (copy) ]]
                    local v1 = if math.random() < 0.3 then math.random(50, 150) or 0 else 0
                    local v32 = typeof(v52) == "Instance" and v52.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                    local v4 = v72.leadFactor or 0.35

                    if v8 then
                        v4 = v4 * 2
                    end

                    local v5 = v10.Position + v32 * v4 + v10.UpVector * (math.random(-25, -5) / 100)
                    local Magnitude = (v10.Position - v3.Head.Position).Magnitude
                    local v82 = v62 + v72.aimAccuracy + (if v8 then 2 else 0) + v1 / 400
                    local v9

                    if v7.sniper then
                        v9 = math.clamp(Magnitude / 250, 0.05, 0.5)
                    else
                        local v11 = Magnitude / 35

                        v9 = math.clamp(v11 * v11 * 0.18, 0.08, 2.8)
                    end

                    local v14 = v5 - v3.Head.Position
                    local Unit = v14.Unit
                    local Unit2 = Unit:Cross(if math.abs((Unit:Dot(Vector3.new(0, 1, 0)))) < 0.99 then Vector3.new(0, 1, 0) else Vector3.new(1, 0, 0)).Unit
                    local Unit3 = Unit2:Cross(Unit).Unit
                    local v17 = math.random() * math.pi * 2
                    local v19 = math.sqrt((math.random())) * (v82 * v9)

                    return v14 + (Unit2 * math.cos(v17) + Unit3 * math.sin(v17)) * v19
                end

                local v11 = getAimDirection()

                v6:SetAttribute("AimDir", v11)
                Storage.Events.server:Fire("fire", v3, v6, false, false, v3.Head.Position + v11.Unit * 1500, false, v4)

                for i = 1, v7.amountPerRound do
                    local v12
                    local v13 = workspace:Raycast(v3.Head.Position, v11.Unit * 800, v21)
                    local v142 = if v13 then v13 else false

                    if v142 then
                        local v15 = v142.Instance

                        v12 = if v15.Parent:FindFirstChild("Humanoid") then v15.Parent elseif v15.Parent == workspace then false else v18(v15.Parent)

                        if v12 then
                            if v9 and v52:IsDescendantOf(v12) then
                                Storage.Events.server:Fire("damage", v3, v12, v6, v142.Instance, v11, {
                                    Instance = v142.Instance,
                                    Position = v142.Position,
                                    Normal = v142.Normal
                                }, v11, v11)
                            elseif v12.Humanoid:GetAttribute("Team") == Humanoid:GetAttribute("Team") then
                                if v142.Instance:IsDescendantOf(workspace.Buildings.Glass) then
                                    Storage.Events.server:Fire("breakGlass", v3, {
                                        t = v6,
                                        glass = v142.Instance,
                                        position = v142.Position
                                    })
                                end
                            else
                                Storage.Events.server:Fire("damage", v3, v12, v6, v142.Instance, v11, {
                                    Instance = v142.Instance,
                                    Position = v142.Position,
                                    Normal = v142.Normal
                                }, v11, v11)
                            end
                        elseif v142.Instance:IsDescendantOf(workspace.Buildings.Glass) then
                            Storage.Events.server:Fire("breakGlass", v3, {
                                t = v6,
                                glass = v142.Instance,
                                position = v142.Position
                            })
                        end
                    end

                    local v17 = getAimDirection()

                    v6:SetAttribute("AimDir", v17)
                    v11 = v17
                end
            else
                local v182, v19 = getHitPos(Handle.MuzzleFX, shared.aimAlpha)

                if not v7.customFire then
                    if v7.degradePoint then
                        t.durability = math.max(t.durability - v7.degradePoint, 0)
                    end

                    shared.Network:FireServer("fire2", v6, v182, v19)
                    Storage.Events.client:Fire("fire", v6.Name, v182, v19, v3, Handle)
                end

                if v6:GetAttribute("RateHeat") and not (os.clock() - v6:GetAttribute("LastFired") >= 1 / (v7.rate / 60) * 2) then
                    if not (v7.spreadRequireFPS or v7.shotgun) then
                        if v6:GetAttribute("LastFired") and not (os.clock() - v6:GetAttribute("LastFired") >= 0.5) then
                            local v232 = v6:GetAttribute("RateHeat")

                            v6:SetAttribute("RateHeat", v232 + (1 - v232) * 0.2)
                        else
                            v6:SetAttribute("RateHeat", 0)
                        end
                    end
                else
                    v6:SetAttribute("RateHeat", if v7.spreadRequireFPS or v7.shotgun then 1 else 0)
                end

                v6:SetAttribute("LastFired", os.clock())

                if v7.customFire then
                    if v7.gunType == "flare" then
                        v23:GiveTask(t2.fire:GetMarkerReachedSignal("fire"):Once(function() --[[ Line: 315 | Upvalues: v6 (ref), v182 (copy), v19 (copy), Storage (ref), v3 (ref), Handle (ref) ]]
                            shared.Network:FireServer("fire2", v6, v182, v19)
                            Storage.Events.client:Fire("fire", v6.Name, v182, v19, v3, Handle)
                        end))
                        v23:GiveTask(t2.fire:GetMarkerReachedSignal("finish"):Once(function() --[[ Line: 320 | Upvalues: v6 (ref), v3 (ref), Humanoid (ref) ]]
                            if v6.Parent ~= v3 then
                                return
                            end

                            Humanoid:UnequipTools()
                        end))
                    end
                else
                    Storage.Events.client:Fire("cGunFire", v6, v7, p22)
                end
            end

            if t2.noammo and t.ammoCurrent <= 0 then
                t2.fire.Priority = Enum.AnimationPriority.Action2
                t2.noammo:Play()

                return false
            end

            return true
        end

        if not p2 then
            if t.durability > 0 and not (t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                t4.reload = shared.setKeyHint("R", "Reload", 5)
            end

            if t.durability <= 0 and tick() - v22 >= 1 then
                v22 = tick()
                shared.displayMessageNotification({
                    display_duration = 3,
                    fade_duration = 0.5,
                    remove_duplicate = true,
                    message = ("Your <b><font color=\"#ff5454\">%*</font></b> has broken."):format(v6.Name),
                    color = Color3.fromRGB(255, 255, 255)
                })
            end
        end

        if t2.noammo and (t.durability > 0 or t.ammoCurrent <= 0) then
            t2.noammo:Play()
        end

        if not Handle.MuzzleFX:FindFirstChild("Empty") then
            return false
        end

        Handle.MuzzleFX.Empty:Play()

        return false
    end

    local function gunFunctionBegan(p1, ...) --[[ gunFunctionBegan | Line: 463 | Upvalues: p2 (copy), v8 (copy), v7 (copy), v10 (ref), t (copy), v6 (copy), Storage (ref), v13 (ref), v3 (ref), t2 (copy), v5 (ref), Humanoid (copy), TweenService (ref), UserInputService (ref), v11 (ref), v12 (ref), v14 (ref), v17 (ref), v16 (ref), mode (ref), v1 (copy), ReplicatedStorage (ref), fire (copy), t4 (ref), Handle (copy) ]]
        local t3 = { ... }

        if not p2 and (v8.HUD.backpackFrame.Visible and unpack(t3) ~= "bypass") then
            return
        end

        if p1 == Enum.KeyCode.R and (not v7.noReload and (not v10 and (v7.defaultMag or t.ammoCurrent < t.ammoSize))) then
            local v2 = if p2 or (not v7.defaultMag or v6:GetAttribute("oldReload")) then t.mag else #Storage.Events.client_callback:Invoke("get_mags", v7, v6._data.magAttached.Value)

            if v2 > 0 then
                local v32 = os.clock() - v13 >= v7.equipTime

                if v32 then
                    local v4 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                    if not v4 then
                        local v52 = if t2.rechamber and t2.rechamber.IsPlaying or (t2.afterload and t2.afterload.IsPlaying or t2.preload and t2.preload.IsPlaying) then true else t2.load and t2.load.IsPlaying and true or false

                        if v52 then
                            return
                        end

                        v10 = true

                        if p2 then
                            v3:SetAttribute("reload", true)
                        else
                            shared.reload = true
                        end

                        while (v7.shotgun and (not v7.db and (not v7.ar_feed and t2.load.Length <= 0)) or (not v7.shotgun or (v7.db or v7.ar_feed)) and t2.reload.Length <= 0) and v5 do
                            task.wait()
                        end

                        while t2.rechamber and (t2.fire.IsPlaying or t2.rechamber.IsPlaying) do
                            task.wait()
                        end

                        if v5 then
                            local v62 = v7.shotgun and (not v7.db and not v7.ar_feed)

                            if v62 and t.ammoCurrent >= t.ammoSize then
                                v10 = false

                                if p2 then
                                    v3:SetAttribute("reload", false)
                                else
                                    shared.reload = false
                                end

                                return
                            end

                            t2.fire.Priority = Enum.AnimationPriority.Core
                            t2.fire:Play()
                            t2.fire:Stop()

                            if t2.inspect then
                                t2.inspect:Stop(1e-8)
                            end

                            if t2.inspect_empty then
                                t2.inspect_empty:Stop(1e-8)
                            end

                            if t2.fanfire then
                                t2.fanfire:Stop()
                            end

                            if not p2 then
                                v8.circularBar.Visible = true
                                v8.circularBar.right.image.UIGradient.Rotation = 0
                                v8.circularBar.left.image.UIGradient.Rotation = 180
                                task.spawn(function() --[[ Line: 509 | Upvalues: v10 (ref), v8 (ref) ]]
                                    while v10 do
                                        local v3 = math.abs(math.sin(os.clock() * 3.5) * 0.5) + 0.5

                                        v8.circularBar.right.image.ImageColor3 = Color3.fromRGB(60, 60, 60):Lerp(Color3.fromRGB(255, 255, 255), v3)
                                        v8.circularBar.left.image.ImageColor3 = Color3.fromRGB(60, 60, 60):Lerp(Color3.fromRGB(255, 255, 255), v3)
                                        task.wait()
                                    end

                                    pcall(function() --[[ Line: 517 | Upvalues: v8 (ref) ]]
                                        v8.circularBar.right.image.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                        v8.circularBar.left.image.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                    end)
                                end)
                            end

                            if v62 then
                                local function checkMatchingAmmo(p1) --[[ checkMatchingAmmo | Line: 525 | Upvalues: v6 (ref) ]]
                                    return if v6._data.magAttached.Value == "" or v6._data.ammoCurrent.Value <= 0 then true else v6._data.magAttached.Value == p1.Name
                                end

                                local function getAmmoPile() --[[ getAmmoPile | Line: 529 | Upvalues: p2 (ref), Storage (ref), v7 (ref), v6 (ref) ]]
                                    local t = {}
                                    local v1 = nil
                                    local v2 = (1 / 0)
                                    local v3 = not p2 and Storage.Events.client_callback:Invoke("get_mags", v7, v6._data.magAttached.Value)

                                    if v3 then
                                        for k, v in pairs(v3) do
                                            if v.data.amount.Value <= v2 and (if v6._data.magAttached.Value == "" or v6._data.ammoCurrent.Value <= 0 then true elseif v6._data.magAttached.Value == v.Name then true else false) then
                                                v2 = v.data.amount.Value
                                                v1 = v
                                            end

                                            table.insert(t, v)
                                        end
                                    end

                                    return v1, t
                                end

                                local v72, v82 = getAmmoPile()

                                if not p2 and v7.defaultMag then
                                    if v72 then
                                        shared.Network:FireServer("vars", "reload", {
                                            state = true,
                                            tool = v6,
                                            mag = v72
                                        })
                                    end
                                elseif not p2 then
                                    shared.Network:FireServer("vars", "reload_old", {
                                        state = true,
                                        tool = v6
                                    })
                                end

                                if t.ammoCurrent <= 0 then
                                    if not v7.defaultMag or v72 then
                                        if t2.preload_empty then
                                            t2.preload_empty.Priority = Enum.AnimationPriority.Action3
                                            t2.preload_empty:Play()
                                            task.wait(t2.preload_empty.Length / 2)
                                        else
                                            t2.preload.Priority = Enum.AnimationPriority.Action3
                                            t2.preload:Play()
                                            task.wait(t2.preload.Length - 0.1)
                                        end
                                    end

                                    if v5 and v10 then
                                        if not p2 then
                                            if not v72 or (not v72:IsDescendantOf(game) or v72.data.amount.Value <= 0) then
                                                local v9, v102 = getAmmoPile()

                                                v72 = v9
                                                v82 = v102
                                            end

                                            if v7.defaultMag then
                                                if v72 then
                                                    shared.Network:FireServer("vars", "reload", {
                                                        tool = v6,
                                                        add = v72
                                                    })
                                                end
                                            else
                                                shared.Network:FireServer("vars", "reload_old", {
                                                    add = true,
                                                    tool = v6
                                                })
                                            end
                                        end

                                        if not v7.defaultMag or v72 then
                                            local v112 = t

                                            v112.ammoCurrent = v112.ammoCurrent + 1
                                            t.mag = math.max(t.mag - 1, 0)
                                        end

                                        if p2 then
                                            v6._data.ammoCurrent.Value = t.ammoCurrent
                                            v6._data.mag.Value = t.mag
                                        end
                                    end

                                    if t2.preload_empty then
                                        task.wait(t2.preload_empty.Length / 2 - 0.1)
                                    end
                                elseif not v7.defaultMag or v72 then
                                    t2.preload.Priority = Enum.AnimationPriority.Action3
                                    t2.preload:Play()
                                    task.wait(t2.preload.Length - 0.1)
                                end

                                local v142 = false

                                if v5 and (v10 and (not Humanoid:GetAttribute("Ragdoll") and (Humanoid.Health > 0 and (t.ammoCurrent < t.ammoSize and t.mag > 0)))) then
                                    t2.load.Priority = Enum.AnimationPriority.Action4

                                    if not p2 then
                                        task.spawn(function() --[[ Line: 607 | Upvalues: v10 (ref), v5 (ref), t2 (ref), v8 (ref), TweenService (ref) ]]
                                            while v10 and v5 do
                                                local v1 = t2.load.TimePosition / t2.load.Length * 100

                                                if v1 > 50 then
                                                    v8.circularBar.right.image.UIGradient.Rotation = 180
                                                    TweenService:Create(v8.circularBar.left.image.UIGradient, TweenInfo.new(0.06666666666666667), {
                                                        Rotation = v1 / 100 * 360
                                                    }):Play()
                                                else
                                                    v8.circularBar.left.image.UIGradient.Rotation = 180
                                                    TweenService:Create(v8.circularBar.right.image.UIGradient, TweenInfo.new(0.06666666666666667), {
                                                        Rotation = v1 / 50 * 180
                                                    }):Play()
                                                end

                                                task.wait(0.06666666666666667)
                                            end
                                        end)
                                    end

                                    local v152 = false

                                    repeat
                                        if not v5 or (not v10 or (Humanoid:GetAttribute("Ragdoll") or (not (Humanoid.Health > 0) or not p2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)))) or (not (t.ammoCurrent < t.ammoSize) or (not (t.mag > 0) or not p2 and (v7.defaultMag and not v72))) then
                                            break
                                        end

                                        if not p2 and (not v72 or (not v72:IsDescendantOf(game) or v72.data.amount.Value <= 0)) then
                                            local v162, v172 = getAmmoPile()

                                            if v162 then
                                                v72 = v162
                                                v82 = v172
                                            else
                                                v82 = v172

                                                break
                                            end
                                        end

                                        t2.load:Play(1e-9)

                                        while true do
                                            if t2.load.TimePosition >= t2.load.Length then
                                                v152 = true

                                                break
                                            end

                                            if not t2.load.IsPlaying then
                                                break
                                            end

                                            task.wait()
                                        end

                                        if v5 and (v10 and v152) then
                                            if not p2 then
                                                v142 = true

                                                if v7.defaultMag then
                                                    shared.Network:FireServer("vars", "reload", {
                                                        tool = v6,
                                                        add = getAmmoPile()
                                                    })
                                                else
                                                    shared.Network:FireServer("vars", "reload_old", {
                                                        add = true,
                                                        tool = v6
                                                    })
                                                end
                                            end

                                            local v18 = t

                                            v18.ammoCurrent = v18.ammoCurrent + 1
                                            t.mag = math.max(t.mag - 1, 0)

                                            if p2 then
                                                v6._data.ammoCurrent.Value = t.ammoCurrent
                                                v6._data.mag.Value = t.mag
                                            end
                                        end
                                    until t.ammoCurrent >= t.ammoSize

                                    if (v5 or not v3:FindFirstChildWhichIsA("Tool")) and v8 then
                                        v8.circularBar.Visible = false
                                    end
                                end

                                if v5 then
                                    if not p2 and v7.defaultMag then
                                        shared.Network:FireServer("vars", "reload", {
                                            client = true,
                                            tool = v6
                                        })
                                    elseif not p2 then
                                        shared.Network:FireServer("vars", "reload_old", {
                                            client = true,
                                            tool = v6
                                        })
                                    end

                                    t2.load:Stop(1e-9)
                                    t2.load.Priority = Enum.AnimationPriority.Core
                                    t2.preload.Priority = Enum.AnimationPriority.Core
                                    t2.afterload.Priority = Enum.AnimationPriority.Action3
                                    t2.afterload:Play(1e-9)

                                    if v7.defaultMag and (#v82 > 0 and (v142 and v6._data.magAttached.Value ~= v82[1].Name)) then
                                        shared.displayMessageNotification({
                                            display_duration = 8,
                                            fade_duration = 0.5,
                                            remove_duplicate = true,
                                            message = ("<font color=\"#FF4444\"><b>Incompatible cartridge type</b></font>: Loaded magazine contains <font color=\"rgb(255, 84, 84)\">%*</font>, but you\'re trying to load <font color=\"rgb(255, 84, 84)\">%*</font>."):format(v6._data.magAttached.Value, v82[1].Name),
                                            color = Color3.fromRGB(255, 255, 255)
                                        })
                                    end
                                end
                            else
                                local v21 = nil
                                local v22 = 0
                                local v23 = not p2

                                if v23 then
                                    v23 = Storage.Events.client_callback:Invoke("get_mags", v7, v7.db and v6._data.magAttached.Value)
                                end

                                if v23 then
                                    for k, v in pairs(v23) do
                                        local v27

                                        if v.data:FindFirstChild("currentAmmo") and v22 <= v.data.currentAmmo.Value or v.data:FindFirstChild("amount") and v22 <= v.data.amount.Value then
                                            local v28

                                            if v.data:FindFirstChild("currentAmmo") then
                                                v27 = v.data.currentAmmo.Value

                                                if not v27 then
                                                    v28 = v
                                                    v27 = v.data.amount.Value
                                                end
                                            else
                                                v28 = v
                                                v27 = v.data.amount.Value
                                            end

                                            v21 = v
                                            v22 = v27
                                        end
                                    end
                                end

                                local v29 = (t.ammoCurrent > 0 or v21 and (v21.data:FindFirstChild("amount") and v21.data.amount.Value < t.ammoSize)) and t2.tac_reload or t2.reload

                                v29.Priority = Enum.AnimationPriority.Action3
                                v29:Play()

                                local v31 = v29:GetMarkerReachedSignal(if v7.tacReloadMarker then "tacReload" else "clipIn"):Connect(function() --[[ Line: 726 | Upvalues: t2 (ref) ]]
                                    if not t2.noammo then
                                        return
                                    end

                                    t2.noammo:Stop(1e-10)
                                end)

                                if p2 or v7.defaultMag and not v6:GetAttribute("oldReload") then
                                    if not p2 then
                                        shared.Network:FireServer("vars", "reload", {
                                            state = true,
                                            tool = v6,
                                            mag = v21
                                        })
                                    end
                                else
                                    shared.Network:FireServer("vars", "reload_old", {
                                        state = true,
                                        tool = v6
                                    })
                                end

                                local v322 = v31
                                local v33 = false

                                while true do
                                    if not v5 or (not v10 or (Humanoid:GetAttribute("Ragdoll") or not (Humanoid.Health > 0))) then
                                        break
                                    end

                                    local Length = v29.Length

                                    if v29.TimePosition >= v29.Length then
                                        v33 = true

                                        if t2.noammo then
                                            t2.noammo:Stop(1e-9)
                                        end

                                        if p2 then
                                            t.ammoCurrent = t.ammoSize
                                            t.mag = math.max(t.mag - 1, 0)
                                            v6._data.ammoCurrent.Value = t.ammoCurrent
                                            v6._data.mag.Value = t.mag
                                        elseif v7.db then
                                            task.spawn(function() --[[ Line: 756 | Upvalues: v6 (ref), t (ref) ]]
                                                if v6._data.reload.Value then
                                                    v6._data.reload.Changed:Wait()
                                                end

                                                t.ammoCurrent = v6._data.ammoCurrent.Value
                                                t.ammoSize = v6._data.ammoSize.Value
                                            end)
                                        elseif v7.defaultMag and not v6:GetAttribute("oldReload") then
                                            t.ammoCurrent = v22
                                        else
                                            t.ammoCurrent = t.ammoSize
                                            t.mag = math.max(t.mag - 1, 0)
                                        end

                                        if p2 or v7.defaultMag and not v6:GetAttribute("oldReload") then
                                            if not p2 then
                                                shared.Network:FireServer("vars", "reload", {
                                                    client = true,
                                                    tool = v6
                                                })
                                            end
                                        else
                                            shared.Network:FireServer("vars", "reload_old", {
                                                client = true,
                                                tool = v6
                                            })
                                        end

                                        v29:Stop(0.25)

                                        break
                                    end

                                    task.wait(0.06666666666666667)
                                end

                                if (v5 or not v3:FindFirstChildWhichIsA("Tool")) and not p2 then
                                    v8.circularBar.Visible = false
                                end

                                if v322 then
                                    v322:Disconnect()
                                end

                                if not v33 and (t2.noammo and t.ammoCurrent <= 0) then
                                    t2.noammo:Play(1e-10)
                                end

                                t2.reload:Stop()

                                if t2.tac_reload then
                                    t2.tac_reload:Stop()
                                end
                            end
                        end

                        v10 = false

                        if p2 then
                            v3:SetAttribute("reload", false)
                        else
                            shared.reload = false
                        end

                        return
                    end
                end
            end
        end

        if p1 == Enum.KeyCode.H and (not v11 and (not v12 and (os.clock() - v14 >= 1 / (v7.rate / 60) and (Humanoid.Health > 0 and not v10)))) and (os.clock() - v13 >= v7.equipTime and (t2.inspect and not t2.inspect.IsPlaying) and (t2.inspect_empty and not t2.inspect_empty.IsPlaying or not t2.inspect_empty)) then
            t2.fire.Priority = Enum.AnimationPriority.Core

            if t.ammoCurrent > 0 or not t2.inspect_empty then
                t2.inspect:Play()

                return
            end

            t2.inspect_empty:Play()

            if t2.noammo then
                t2.noammo:Stop()
                t2.inspect_empty.Stopped:Connect(function() --[[ Line: 816 | Upvalues: t2 (ref) ]]
                    t2.noammo:Play(1e-7)
                end)
            end

            return
        end

        if p1 == Enum.KeyCode.Backspace and not p2 then
            local itemFolder = v6:FindFirstChild("itemFolder")

            if itemFolder and itemFolder.Value ~= nil then
                Humanoid:UnequipTools()
                task.wait(0.03333333333333333)
                Storage.Events.InventoryFunction:InvokeServer("discardItem", itemFolder.Value)
            else
                Humanoid:UnequipTools()
                task.wait(0.03333333333333333)
                Storage.Events.InventoryFunction:InvokeServer("discardItem_Alt", v6)
            end
        else
            if p1 == Enum.KeyCode.B and (not shared.aim and (not v11 and (not v12 and (os.clock() - v14 >= 1 / (v7.rate / 60) and (Humanoid.Health > 0 and not v10))))) then
                local v39 = os.clock() - v13 >= v7.equipTime

                if v39 and (v7.mode_switch and os.clock() - v17 >= 0.5) then
                    v17 = os.clock()
                    v16 = v16 + 1

                    if v16 > #v7.mode_switch then
                        v16 = 1
                    end

                    mode = v7.mode_switch[v16]
                    t.fireMode = mode

                    if not p2 then
                        shared.Network:FireServer("vars", "switch_firemode", {
                            tool = v6,
                            currentFireMode = v16
                        })
                    end

                    if t2.switch then
                        t2.switch.Priority = Enum.AnimationPriority.Action4
                        t2.switch:Play()
                    else
                        shared.createSound(v1.PlayerGui.SOUNDS.fireSwitch, v1.PlayerGui):Play()
                    end

                    return
                end
            end

            if p1 ~= Enum.UserInputType.MouseButton1 or (v11 or (v12 or not (os.clock() - v14 >= 1 / (v7.rate / 60) and Humanoid.Health > 0))) then
                return
            end

            if not (if os.clock() - v13 >= v7.equipTime then true else false) or shared.unableToShoot then
                return
            end

            if ReplicatedStorage.__tempSTORAGE["self-revive"]:FindFirstChild(p2 and v3.Name or v1.Name) then
                return
            end

            if t2.inspect and t2.inspect.IsPlaying then
                t2.inspect:Stop()

                if v7.gunType ~= "diy_ft" then
                    return
                end

                t2.light:Play()
            else
                if not p2 and v8.HUD.backpackFrame.Visible then
                    return
                end

                if t2.inspect_empty and t2.inspect_empty.IsPlaying then
                    t2.inspect_empty:Stop()

                    return
                end

                if t2.rechamber and t2.rechamber.IsPlaying or (t2.afterload and t2.afterload.IsPlaying or (t2.preload and t2.preload.IsPlaying or t2.load and t2.load.IsPlaying)) then
                    v10 = false

                    if p2 then
                        v3:SetAttribute("reload", false)
                    else
                        shared.reload = false
                    end
                else
                    if t2.switch and t2.switch.IsPlaying then
                        return
                    end

                    if p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher then
                        return
                    end

                    if p2 and v3:GetAttribute("characterLocked") or shared.characterLocked then
                        return
                    end

                    if v10 then
                        if t2.reload and not (t2.reload.TimePosition / t2.reload.Length < 0.65) then
                            return
                        end

                        if v7.shotgun and not (v7.db or v7.ar_feed) then
                            t2.load:Stop(0.25)
                        else
                            t2.reload:Stop(0.25)

                            if t2.tac_reload then
                                t2.tac_reload:Stop(0.25)
                            end
                        end

                        v10 = false

                        if p2 then
                            v3:SetAttribute("reload", false)
                        else
                            shared.reload = false
                        end

                        if p2 then
                            return
                        end

                        shared.Network:FireServer("vars", "reload_old", {
                            state = false,
                            tool = v6
                        })
                        shared.Network:FireServer("vars", "reload", {
                            state = false,
                            tool = v6
                        })
                    else
                        v11 = true

                        local v46 = false
                        local v47, _, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57

                        if v7.prefireDelay then
                            t2.prefire:Play()

                            local v58 = os.clock()
                            local v59 = false

                            while true do
                                if not (v11 and v5) then
                                    break
                                end

                                if os.clock() - v58 >= v7.prefireDelay then
                                    v59 = true

                                    break
                                end

                                task.wait()
                            end

                            if not v5 then
                                t2.prefire:Stop()

                                return
                            end

                            if not v59 and t2.fanfire then
                                if p2 and v3:GetAttribute("aim") or shared.aim then
                                    if not p2 then
                                        local CurrentCamera = workspace.CurrentCamera

                                        if not (if CurrentCamera then CurrentCamera:GetAttribute("FPS") else false) then
                                            t2.prefire:Stop()
                                            t2.fanfire:Play()
                                            v46 = true
                                            v12 = true

                                            if t.ammoCurrent > 0 then
                                                if v7.shotgun and not (v7.ar_feed or (v7.db or t2.afterload.IsPlaying)) then
                                                    v6:SetAttribute("lastClick", os.clock())
                                                    v6:SetAttribute("inverted", 1)
                                                    v47 = 0
                                                    _ = t.ammoCurrent
                                                    v48 = false

                                                    if v7.gunType == "diy_ft" then
                                                        t2.after:Stop()
                                                        t2.shake:Play()
                                                    end

                                                    v49 = 1 / (v7.rate / 60)

                                                    while v5 and (v11 or v46) do
                                                        if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                            break
                                                        end

                                                        v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                                        if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                            break
                                                        end

                                                        v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                                        v52 = p2 and v3.Name or v1.Name

                                                        if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                            break
                                                        end

                                                        v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                                        if v53 then
                                                            break
                                                        end

                                                        v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                                        if v54 then
                                                            break
                                                        end

                                                        if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                            t2.fire_start:Play()
                                                            v48 = true
                                                        end

                                                        if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                            v55 = os.clock() - v47
                                                            v56 = os.clock()

                                                            if v6._data.reload.Value == true then
                                                                v10 = false
                                                                shared.Network:FireServer("vars", "reload_old", {
                                                                    state = false,
                                                                    tool = v6
                                                                })
                                                                shared.Network:FireServer("vars", "reload", {
                                                                    state = false,
                                                                    tool = v6
                                                                })
                                                            end

                                                            if mode == 2 then
                                                                if not v7.burstAmount then
                                                                    warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                                end

                                                                for i = 1, v7.burstAmount or 1 do
                                                                    if not (v5 and fire(v46, v55, t3)) then
                                                                        break
                                                                    end

                                                                    v57 = task.wait(v49 * 0.9)
                                                                    v55 = v57
                                                                end

                                                                task.wait(1 / (v7.rate / 60) * 0.8)

                                                                break
                                                            end

                                                            if mode == 4 then
                                                                if v5 and (fire(v46, v55, t3) and v5) then
                                                                    fire(v46, v55, t3)
                                                                end

                                                                task.wait(v49 * 0.8)

                                                                break
                                                            end

                                                            if not fire(v46, v49, t3) or mode == 1 then
                                                                break
                                                            end

                                                            v47 = v56
                                                        end

                                                        task.wait()
                                                    end

                                                    if v7.gunType ~= "diy_ft" then
                                                        v12 = false

                                                        return
                                                    end

                                                    t2.shake:Stop()
                                                    t2.fire_start:Stop()
                                                    t2.fire:Stop()
                                                    t2.cancel:Play()
                                                    t2.after:Play()
                                                elseif v7.shotgun and not (v7.db or v7.ar_feed) or t2.reload and t2.reload.IsPlaying then
                                                    if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                                        t4.reload = shared.setKeyHint("R", "Reload", 5)
                                                    end

                                                    if t2.noammo then
                                                        t2.noammo:Play()
                                                    end

                                                    Handle.MuzzleFX.Empty:Play()

                                                    if not v7.prefireDelay then
                                                        v12 = false

                                                        return
                                                    end

                                                    t2.prefire:Stop()
                                                else
                                                    v6:SetAttribute("lastClick", os.clock())
                                                    v6:SetAttribute("inverted", 1)
                                                    v47 = 0
                                                    _ = t.ammoCurrent
                                                    v48 = false

                                                    if v7.gunType == "diy_ft" then
                                                        t2.after:Stop()
                                                        t2.shake:Play()
                                                    end

                                                    v49 = 1 / (v7.rate / 60)

                                                    while v5 and (v11 or v46) do
                                                        if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                            break
                                                        end

                                                        v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                                        if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                            break
                                                        end

                                                        v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                                        v52 = p2 and v3.Name or v1.Name

                                                        if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                            break
                                                        end

                                                        v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                                        if v53 then
                                                            break
                                                        end

                                                        v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                                        if v54 then
                                                            break
                                                        end

                                                        if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                            t2.fire_start:Play()
                                                            v48 = true
                                                        end

                                                        if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                            v55 = os.clock() - v47
                                                            v56 = os.clock()

                                                            if v6._data.reload.Value == true then
                                                                v10 = false
                                                                shared.Network:FireServer("vars", "reload_old", {
                                                                    state = false,
                                                                    tool = v6
                                                                })
                                                                shared.Network:FireServer("vars", "reload", {
                                                                    state = false,
                                                                    tool = v6
                                                                })
                                                            end

                                                            if mode == 2 then
                                                                if not v7.burstAmount then
                                                                    warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                                end

                                                                for i = 1, v7.burstAmount or 1 do
                                                                    if not (v5 and fire(v46, v55, t3)) then
                                                                        break
                                                                    end

                                                                    v57 = task.wait(v49 * 0.9)
                                                                    v55 = v57
                                                                end

                                                                task.wait(1 / (v7.rate / 60) * 0.8)

                                                                break
                                                            end

                                                            if mode == 4 then
                                                                if v5 and (fire(v46, v55, t3) and v5) then
                                                                    fire(v46, v55, t3)
                                                                end

                                                                task.wait(v49 * 0.8)

                                                                break
                                                            end

                                                            if not fire(v46, v49, t3) or mode == 1 then
                                                                break
                                                            end

                                                            v47 = v56
                                                        end

                                                        task.wait()
                                                    end

                                                    if v7.gunType ~= "diy_ft" then
                                                        v12 = false

                                                        return
                                                    end

                                                    t2.shake:Stop()
                                                    t2.fire_start:Stop()
                                                    t2.fire:Stop()
                                                    t2.cancel:Play()
                                                    t2.after:Play()
                                                end
                                            else
                                                if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                                    t4.reload = shared.setKeyHint("R", "Reload", 5)
                                                end

                                                if t2.noammo then
                                                    t2.noammo:Play()
                                                end

                                                Handle.MuzzleFX.Empty:Play()

                                                if not v7.prefireDelay then
                                                    v12 = false

                                                    return
                                                end

                                                t2.prefire:Stop()
                                            end

                                            v12 = false

                                            return
                                        end
                                    end

                                    if not v59 then
                                        t2.prefire:Stop()

                                        return
                                    end

                                    v12 = true

                                    if t.ammoCurrent > 0 then
                                        if v7.shotgun and not (v7.ar_feed or (v7.db or t2.afterload.IsPlaying)) then
                                            v6:SetAttribute("lastClick", os.clock())
                                            v6:SetAttribute("inverted", 1)
                                            v47 = 0
                                            _ = t.ammoCurrent
                                            v48 = false

                                            if v7.gunType == "diy_ft" then
                                                t2.after:Stop()
                                                t2.shake:Play()
                                            end

                                            v49 = 1 / (v7.rate / 60)

                                            while v5 and (v11 or v46) do
                                                if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                    break
                                                end

                                                v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                                if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                    break
                                                end

                                                v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                                v52 = p2 and v3.Name or v1.Name

                                                if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                    break
                                                end

                                                v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                                if v53 then
                                                    break
                                                end

                                                v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                                if v54 then
                                                    break
                                                end

                                                if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                    t2.fire_start:Play()
                                                    v48 = true
                                                end

                                                if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                    v55 = os.clock() - v47
                                                    v56 = os.clock()

                                                    if v6._data.reload.Value == true then
                                                        v10 = false
                                                        shared.Network:FireServer("vars", "reload_old", {
                                                            state = false,
                                                            tool = v6
                                                        })
                                                        shared.Network:FireServer("vars", "reload", {
                                                            state = false,
                                                            tool = v6
                                                        })
                                                    end

                                                    if mode == 2 then
                                                        if not v7.burstAmount then
                                                            warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                        end

                                                        for i = 1, v7.burstAmount or 1 do
                                                            if not (v5 and fire(v46, v55, t3)) then
                                                                break
                                                            end

                                                            v57 = task.wait(v49 * 0.9)
                                                            v55 = v57
                                                        end

                                                        task.wait(1 / (v7.rate / 60) * 0.8)

                                                        break
                                                    end

                                                    if mode == 4 then
                                                        if v5 and (fire(v46, v55, t3) and v5) then
                                                            fire(v46, v55, t3)
                                                        end

                                                        task.wait(v49 * 0.8)

                                                        break
                                                    end

                                                    if not fire(v46, v49, t3) or mode == 1 then
                                                        break
                                                    end

                                                    v47 = v56
                                                end

                                                task.wait()
                                            end

                                            if v7.gunType ~= "diy_ft" then
                                                v12 = false

                                                return
                                            end

                                            t2.shake:Stop()
                                            t2.fire_start:Stop()
                                            t2.fire:Stop()
                                            t2.cancel:Play()
                                            t2.after:Play()
                                        elseif v7.shotgun and not (v7.db or v7.ar_feed) or t2.reload and t2.reload.IsPlaying then
                                            if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                                t4.reload = shared.setKeyHint("R", "Reload", 5)
                                            end

                                            if t2.noammo then
                                                t2.noammo:Play()
                                            end

                                            Handle.MuzzleFX.Empty:Play()

                                            if not v7.prefireDelay then
                                                v12 = false

                                                return
                                            end

                                            t2.prefire:Stop()
                                        else
                                            v6:SetAttribute("lastClick", os.clock())
                                            v6:SetAttribute("inverted", 1)
                                            v47 = 0
                                            _ = t.ammoCurrent
                                            v48 = false

                                            if v7.gunType == "diy_ft" then
                                                t2.after:Stop()
                                                t2.shake:Play()
                                            end

                                            v49 = 1 / (v7.rate / 60)

                                            while v5 and (v11 or v46) do
                                                if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                    break
                                                end

                                                v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                                if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                    break
                                                end

                                                v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                                v52 = p2 and v3.Name or v1.Name

                                                if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                    break
                                                end

                                                v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                                if v53 then
                                                    break
                                                end

                                                v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                                if v54 then
                                                    break
                                                end

                                                if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                    t2.fire_start:Play()
                                                    v48 = true
                                                end

                                                if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                    v55 = os.clock() - v47
                                                    v56 = os.clock()

                                                    if v6._data.reload.Value == true then
                                                        v10 = false
                                                        shared.Network:FireServer("vars", "reload_old", {
                                                            state = false,
                                                            tool = v6
                                                        })
                                                        shared.Network:FireServer("vars", "reload", {
                                                            state = false,
                                                            tool = v6
                                                        })
                                                    end

                                                    if mode == 2 then
                                                        if not v7.burstAmount then
                                                            warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                        end

                                                        for i = 1, v7.burstAmount or 1 do
                                                            if not (v5 and fire(v46, v55, t3)) then
                                                                break
                                                            end

                                                            v57 = task.wait(v49 * 0.9)
                                                            v55 = v57
                                                        end

                                                        task.wait(1 / (v7.rate / 60) * 0.8)

                                                        break
                                                    end

                                                    if mode == 4 then
                                                        if v5 and (fire(v46, v55, t3) and v5) then
                                                            fire(v46, v55, t3)
                                                        end

                                                        task.wait(v49 * 0.8)

                                                        break
                                                    end

                                                    if not fire(v46, v49, t3) or mode == 1 then
                                                        break
                                                    end

                                                    v47 = v56
                                                end

                                                task.wait()
                                            end

                                            if v7.gunType ~= "diy_ft" then
                                                v12 = false

                                                return
                                            end

                                            t2.shake:Stop()
                                            t2.fire_start:Stop()
                                            t2.fire:Stop()
                                            t2.cancel:Play()
                                            t2.after:Play()
                                        end
                                    else
                                        if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                            t4.reload = shared.setKeyHint("R", "Reload", 5)
                                        end

                                        if t2.noammo then
                                            t2.noammo:Play()
                                        end

                                        Handle.MuzzleFX.Empty:Play()

                                        if not v7.prefireDelay then
                                            v12 = false

                                            return
                                        end

                                        t2.prefire:Stop()
                                    end

                                    v12 = false

                                    return
                                end

                                t2.prefire:Stop()
                                t2.fanfire:Play()
                                v46 = true
                                v12 = true

                                if t.ammoCurrent > 0 then
                                    if v7.shotgun and not (v7.ar_feed or (v7.db or t2.afterload.IsPlaying)) then
                                        v6:SetAttribute("lastClick", os.clock())
                                        v6:SetAttribute("inverted", 1)
                                        v47 = 0
                                        _ = t.ammoCurrent
                                        v48 = false

                                        if v7.gunType == "diy_ft" then
                                            t2.after:Stop()
                                            t2.shake:Play()
                                        end

                                        v49 = 1 / (v7.rate / 60)

                                        while v5 and (v11 or v46) do
                                            if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                break
                                            end

                                            v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                            if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                break
                                            end

                                            v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                            v52 = p2 and v3.Name or v1.Name

                                            if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                break
                                            end

                                            v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                            if v53 then
                                                break
                                            end

                                            v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                            if v54 then
                                                break
                                            end

                                            if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                t2.fire_start:Play()
                                                v48 = true
                                            end

                                            if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                v55 = os.clock() - v47
                                                v56 = os.clock()

                                                if v6._data.reload.Value == true then
                                                    v10 = false
                                                    shared.Network:FireServer("vars", "reload_old", {
                                                        state = false,
                                                        tool = v6
                                                    })
                                                    shared.Network:FireServer("vars", "reload", {
                                                        state = false,
                                                        tool = v6
                                                    })
                                                end

                                                if mode == 2 then
                                                    if not v7.burstAmount then
                                                        warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                    end

                                                    for i = 1, v7.burstAmount or 1 do
                                                        if not (v5 and fire(v46, v55, t3)) then
                                                            break
                                                        end

                                                        v57 = task.wait(v49 * 0.9)
                                                        v55 = v57
                                                    end

                                                    task.wait(1 / (v7.rate / 60) * 0.8)

                                                    break
                                                end

                                                if mode == 4 then
                                                    if v5 and (fire(v46, v55, t3) and v5) then
                                                        fire(v46, v55, t3)
                                                    end

                                                    task.wait(v49 * 0.8)

                                                    break
                                                end

                                                if not fire(v46, v49, t3) or mode == 1 then
                                                    break
                                                end

                                                v47 = v56
                                            end

                                            task.wait()
                                        end

                                        if v7.gunType ~= "diy_ft" then
                                            v12 = false

                                            return
                                        end

                                        t2.shake:Stop()
                                        t2.fire_start:Stop()
                                        t2.fire:Stop()
                                        t2.cancel:Play()
                                        t2.after:Play()
                                    elseif v7.shotgun and not (v7.db or v7.ar_feed) or t2.reload and t2.reload.IsPlaying then
                                        if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                            t4.reload = shared.setKeyHint("R", "Reload", 5)
                                        end

                                        if t2.noammo then
                                            t2.noammo:Play()
                                        end

                                        Handle.MuzzleFX.Empty:Play()

                                        if not v7.prefireDelay then
                                            v12 = false

                                            return
                                        end

                                        t2.prefire:Stop()
                                    else
                                        v6:SetAttribute("lastClick", os.clock())
                                        v6:SetAttribute("inverted", 1)
                                        v47 = 0
                                        _ = t.ammoCurrent
                                        v48 = false

                                        if v7.gunType == "diy_ft" then
                                            t2.after:Stop()
                                            t2.shake:Play()
                                        end

                                        v49 = 1 / (v7.rate / 60)

                                        while v5 and (v11 or v46) do
                                            if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                                break
                                            end

                                            v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                            if v50 or Humanoid:GetAttribute("meleeAttack") then
                                                break
                                            end

                                            v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                            v52 = p2 and v3.Name or v1.Name

                                            if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                                break
                                            end

                                            v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                            if v53 then
                                                break
                                            end

                                            v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                            if v54 then
                                                break
                                            end

                                            if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                                t2.fire_start:Play()
                                                v48 = true
                                            end

                                            if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                                v55 = os.clock() - v47
                                                v56 = os.clock()

                                                if v6._data.reload.Value == true then
                                                    v10 = false
                                                    shared.Network:FireServer("vars", "reload_old", {
                                                        state = false,
                                                        tool = v6
                                                    })
                                                    shared.Network:FireServer("vars", "reload", {
                                                        state = false,
                                                        tool = v6
                                                    })
                                                end

                                                if mode == 2 then
                                                    if not v7.burstAmount then
                                                        warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                                    end

                                                    for i = 1, v7.burstAmount or 1 do
                                                        if not (v5 and fire(v46, v55, t3)) then
                                                            break
                                                        end

                                                        v57 = task.wait(v49 * 0.9)
                                                        v55 = v57
                                                    end

                                                    task.wait(1 / (v7.rate / 60) * 0.8)

                                                    break
                                                end

                                                if mode == 4 then
                                                    if v5 and (fire(v46, v55, t3) and v5) then
                                                        fire(v46, v55, t3)
                                                    end

                                                    task.wait(v49 * 0.8)

                                                    break
                                                end

                                                if not fire(v46, v49, t3) or mode == 1 then
                                                    break
                                                end

                                                v47 = v56
                                            end

                                            task.wait()
                                        end

                                        if v7.gunType ~= "diy_ft" then
                                            v12 = false

                                            return
                                        end

                                        t2.shake:Stop()
                                        t2.fire_start:Stop()
                                        t2.fire:Stop()
                                        t2.cancel:Play()
                                        t2.after:Play()
                                    end
                                else
                                    if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                        t4.reload = shared.setKeyHint("R", "Reload", 5)
                                    end

                                    if t2.noammo then
                                        t2.noammo:Play()
                                    end

                                    Handle.MuzzleFX.Empty:Play()

                                    if not v7.prefireDelay then
                                        v12 = false

                                        return
                                    end

                                    t2.prefire:Stop()
                                end

                                v12 = false

                                return
                            end

                            if not v59 then
                                t2.prefire:Stop()

                                return
                            end
                        end

                        v12 = true

                        if t.ammoCurrent > 0 then
                            if v7.shotgun and not (v7.ar_feed or (v7.db or t2.afterload.IsPlaying)) then
                                v6:SetAttribute("lastClick", os.clock())
                                v6:SetAttribute("inverted", 1)
                                v47 = 0
                                _ = t.ammoCurrent
                                v48 = false

                                if v7.gunType == "diy_ft" then
                                    t2.after:Stop()
                                    t2.shake:Play()
                                end

                                v49 = 1 / (v7.rate / 60)

                                while v5 and (v11 or v46) do
                                    if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                        break
                                    end

                                    v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                    if v50 or Humanoid:GetAttribute("meleeAttack") then
                                        break
                                    end

                                    v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                    v52 = p2 and v3.Name or v1.Name

                                    if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                        break
                                    end

                                    v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                    if v53 then
                                        break
                                    end

                                    v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                    if v54 then
                                        break
                                    end

                                    if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                        t2.fire_start:Play()
                                        v48 = true
                                    end

                                    if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                        v55 = os.clock() - v47
                                        v56 = os.clock()

                                        if v6._data.reload.Value == true then
                                            v10 = false
                                            shared.Network:FireServer("vars", "reload_old", {
                                                state = false,
                                                tool = v6
                                            })
                                            shared.Network:FireServer("vars", "reload", {
                                                state = false,
                                                tool = v6
                                            })
                                        end

                                        if mode == 2 then
                                            if not v7.burstAmount then
                                                warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                            end

                                            for i = 1, v7.burstAmount or 1 do
                                                if not (v5 and fire(v46, v55, t3)) then
                                                    break
                                                end

                                                v57 = task.wait(v49 * 0.9)
                                                v55 = v57
                                            end

                                            task.wait(1 / (v7.rate / 60) * 0.8)

                                            break
                                        end

                                        if mode == 4 then
                                            if v5 and (fire(v46, v55, t3) and v5) then
                                                fire(v46, v55, t3)
                                            end

                                            task.wait(v49 * 0.8)

                                            break
                                        end

                                        if not fire(v46, v49, t3) or mode == 1 then
                                            break
                                        end

                                        v47 = v56
                                    end

                                    task.wait()
                                end

                                if v7.gunType ~= "diy_ft" then
                                    v12 = false

                                    return
                                end

                                t2.shake:Stop()
                                t2.fire_start:Stop()
                                t2.fire:Stop()
                                t2.cancel:Play()
                                t2.after:Play()
                            elseif v7.shotgun and not (v7.db or v7.ar_feed) or t2.reload and t2.reload.IsPlaying then
                                if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                    t4.reload = shared.setKeyHint("R", "Reload", 5)
                                end

                                if t2.noammo then
                                    t2.noammo:Play()
                                end

                                Handle.MuzzleFX.Empty:Play()

                                if not v7.prefireDelay then
                                    v12 = false

                                    return
                                end

                                t2.prefire:Stop()
                            else
                                v6:SetAttribute("lastClick", os.clock())
                                v6:SetAttribute("inverted", 1)
                                v47 = 0
                                _ = t.ammoCurrent
                                v48 = false

                                if v7.gunType == "diy_ft" then
                                    t2.after:Stop()
                                    t2.shake:Play()
                                end

                                v49 = 1 / (v7.rate / 60)

                                while v5 and (v11 or v46) do
                                    if v10 or (not (Humanoid.Health > 0) or Humanoid:GetAttribute("Ragdoll")) then
                                        break
                                    end

                                    v50 = p2 and v3:GetAttribute("unableToShoot") or shared.unableToShoot

                                    if v50 or Humanoid:GetAttribute("meleeAttack") then
                                        break
                                    end

                                    v51 = ReplicatedStorage.__tempSTORAGE["self-revive"]
                                    v52 = p2 and v3.Name or v1.Name

                                    if v51:FindFirstChild(v52) or t2.switch and t2.switch.IsPlaying then
                                        break
                                    end

                                    v53 = p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher

                                    if v53 then
                                        break
                                    end

                                    v54 = p2 and v3:GetAttribute("characterLocked") or shared.characterLocked

                                    if v54 then
                                        break
                                    end

                                    if t.ammoCurrent > 0 and (v7.gunType == "diy_ft" and not (t2.shake.IsPlaying or v48)) then
                                        t2.fire_start:Play()
                                        v48 = true
                                    end

                                    if v49 <= os.clock() - v47 and (v7.gunType ~= "diy_ft" or v48) then
                                        v55 = os.clock() - v47
                                        v56 = os.clock()

                                        if v6._data.reload.Value == true then
                                            v10 = false
                                            shared.Network:FireServer("vars", "reload_old", {
                                                state = false,
                                                tool = v6
                                            })
                                            shared.Network:FireServer("vars", "reload", {
                                                state = false,
                                                tool = v6
                                            })
                                        end

                                        if mode == 2 then
                                            if not v7.burstAmount then
                                                warn("burstAmount not found in " .. v6.Name .. "\'s config.")
                                            end

                                            for i = 1, v7.burstAmount or 1 do
                                                if not (v5 and fire(v46, v55, t3)) then
                                                    break
                                                end

                                                v57 = task.wait(v49 * 0.9)
                                                v55 = v57
                                            end

                                            task.wait(1 / (v7.rate / 60) * 0.8)

                                            break
                                        end

                                        if mode == 4 then
                                            if v5 and (fire(v46, v55, t3) and v5) then
                                                fire(v46, v55, t3)
                                            end

                                            task.wait(v49 * 0.8)

                                            break
                                        end

                                        if not fire(v46, v49, t3) or mode == 1 then
                                            break
                                        end

                                        v47 = v56
                                    end

                                    task.wait()
                                end

                                if v7.gunType ~= "diy_ft" then
                                    v12 = false

                                    return
                                end

                                t2.shake:Stop()
                                t2.fire_start:Stop()
                                t2.fire:Stop()
                                t2.cancel:Play()
                                t2.after:Play()
                            end
                        else
                            if not (p2 or t4.reload and t4.reload:IsDescendantOf(game)) and (t.mag > 0 and not v7.noReloadHint) then
                                t4.reload = shared.setKeyHint("R", "Reload", 5)
                            end

                            if t2.noammo then
                                t2.noammo:Play()
                            end

                            Handle.MuzzleFX.Empty:Play()

                            if not v7.prefireDelay then
                                v12 = false

                                return
                            end

                            t2.prefire:Stop()
                        end

                        v12 = false
                    end
                end
            end
        end
    end

    local function gunFunctionEnded(p1) --[[ gunFunctionEnded | Line: 1041 | Upvalues: v11 (ref), t (copy), t2 (copy), v7 (copy) ]]
        if p1 == Enum.UserInputType.MouseButton1 then
            v11 = false

            return
        end

        if p1 ~= Enum.UserInputType.MouseButton2 or not (t.ammoCurrent > 0) then
            return
        end

        if t2.inspect then
            t2.inspect:Stop()

            if v7.gunType == "diy_ft" then
                t2.light:Play()
            end
        end

        if not t2.inspect_empty then
            return
        end

        t2.inspect_empty:Stop()
    end

    local function getAimFOV() --[[ getAimFOV | Line: 1058 | Upvalues: v6 (copy), Storage (ref), v7 (copy) ]]
        if not shared.cantedSight then
            local tbl = {}

            tbl[1] = workspace.CurrentCamera:FindFirstChild("__viewmodel") and workspace.CurrentCamera.__viewmodel.at
            tbl[2] = v6._at

            for k, v in pairs(tbl) do
                for k2, v2 in pairs(v:QueryDescendants("> :has(> #FOV)")) do
                    return v2.FOV.Value, require(Storage.Modules.Items.attachments[v2.Name]).tweenInfo
                end
            end
        end

        if shared.cantedSight then
            return 60
        end

        return v7.ads_config.fovIn
    end

    local aim = shared.aim

    local function onUnequipped(p1) --[[ onUnequipped | Line: 1074 | Upvalues: p2 (copy), CurrentCamera (copy), ReplicatedStorage (ref), v11 (ref), v10 (ref), v5 (ref), v3 (ref), v23 (copy), t4 (ref), TweenService (ref), __config (copy), t2 (copy) ]]
        if not p2 then
            local v1 = CurrentCamera:FindFirstChild("__viewmodel") or ReplicatedStorage.__tempSTORAGE.clean:FindFirstChild("__viewmodel")

            if v1 then
                v1["Left Arm"].Mesh.Scale = Vector3.new(0.8, 1, 0.8)
                v1["Right Arm"].Mesh.Scale = Vector3.new(0.8, 1, 0.8)
            end
        end

        v11 = false
        v10 = false
        v5 = false

        if p2 then
            v3:SetAttribute("gunEquipped", false)
        else
            shared.gunEquipped = false
        end

        if p2 then
            v3:SetAttribute("inspect", false)
        else
            shared.inspect = false
        end

        if p2 then
            v3:SetAttribute("equipping", false)
        else
            shared.equipping = false
        end

        if p2 then
            v3:SetAttribute("reload", false)
        else
            shared.reload = false
        end

        if p2 then
            v3:SetAttribute("unequipped", true)
        else
            shared.unequipped = true
        end

        if p2 then
            v3:SetAttribute("chambering", false)
        else
            shared.chambering = false
        end

        shared.aim = false
        v23:DoCleaning()

        if not p2 then
            for k, v in pairs(t4) do
                if v:IsDescendantOf(game) then
                    shared.clearKeyHint(v)
                end

                t4[k] = nil
            end

            t4 = {}
            TweenService:Create(CurrentCamera.FOV, TweenInfo.new(0.00016, Enum.EasingStyle.Sine), {
                Value = __config.fov.Value
            }):Play()
        end

        if p1 then
            return
        end

        for k, v in pairs(t2) do
            v:AdjustWeight(0)
            v:Stop(1e-11)
        end
    end

    local v24 = true

    local function onEquipped() --[[ onEquipped | Line: 1123 | Upvalues: Humanoid (copy), p2 (copy), v3 (ref), v6 (copy), v1 (copy), CurrentCamera (copy), ReplicatedStorage (ref), v7 (copy), v23 (copy), v8 (copy), v5 (ref), v14 (ref), v13 (ref), t3 (copy), t4 (ref), t2 (copy), t (copy), v24 (ref), UserInputService (ref), gunFunctionBegan (copy), gunFunctionEnded (copy), activateEvent (copy), onUnequipped (copy), RunService (ref), RootPart (copy), mode (ref), Handle (copy), Storage (ref), aim (ref), getAimFOV (copy), TweenService (ref), __config (copy), finisherFunction (copy) ]]
        if Humanoid.Health <= 0 then
            return
        end

        if not p2 and #v3:QueryDescendants(">Tool") > 1 then
            v6.Parent = v1.Backpack
        end

        if not p2 then
            local v12 = CurrentCamera:FindFirstChild("__viewmodel") or ReplicatedStorage.__tempSTORAGE.clean:FindFirstChild("__viewmodel")

            if v7.armSize and v12 then
                local armSize = v7.armSize

                v12["Left Arm"].Mesh.Scale = Vector3.new(armSize, 1, armSize)
                v12["Right Arm"].Mesh.Scale = Vector3.new(armSize, 1, armSize)
            end
        end

        v23:DoCleaning()

        if not p2 then
            v8.circularBar.Visible = false
        end

        v5 = true

        if p2 then
            v3:SetAttribute("gunEquipped", true)
        else
            shared.gunEquipped = true
        end

        if p2 then
            v3:SetAttribute("unequipped", false)
        else
            shared.unequipped = false
        end

        shared.aim = false
        v14 = 0
        v13 = os.clock()

        if not p2 then
            for k, v in pairs(t3) do
                t4[#t4 + 1] = shared.setKeyHint(k, v.info, 5)
            end
        end

        t2.idle.Priority = Enum.AnimationPriority.Action
        t2.equip.Priority = Enum.AnimationPriority.Action4
        t2.fire.Priority = Enum.AnimationPriority.Movement

        if t2.inspect then
            t2.inspect.Priority = Enum.AnimationPriority.Action3
        end

        if t2.equip_empty then
            t2.equip_empty.Priority = Enum.AnimationPriority.Action4
        end

        if t2.equip_loaded then
            t2.equip_loaded.Priority = Enum.AnimationPriority.Action4
        end

        if t2.inspect_empty then
            t2.inspect_empty.Priority = Enum.AnimationPriority.Action3
        end

        t2.idle:Play(1e-12)

        if not t.ammoCurrent then
            while not t.ammoCurrent do
                task.wait(0.1)
            end
        end

        if v24 and (t.ammoCurrent > 0 and t2.equip_loaded) then
            t2.equip_loaded:Play(1e-11)
        elseif t.ammoCurrent > 0 or not t2.equip_empty then
            t2.equip:Play(1e-11)
        else
            t2.equip_empty:Play(1e-9)
        end

        v24 = false

        if t2.noammo and t.ammoCurrent <= 0 then
            t2.noammo.Priority = Enum.AnimationPriority.Action4
            t2.noammo:Play(1e-10)
        end

        if not p2 then
            v23:GiveTask(UserInputService.InputBegan:Connect(function(p1, p2) --[[ Line: 1200 | Upvalues: gunFunctionBegan (ref) ]]
                if p2 then
                    return
                end

                gunFunctionBegan(p1.UserInputType == Enum.UserInputType.Keyboard and p1.KeyCode or p1.UserInputType)
            end))
            v23:GiveTask(UserInputService.InputEnded:Connect(function(p1) --[[ Line: 1206 | Upvalues: gunFunctionEnded (ref) ]]
                gunFunctionEnded(p1.UserInputType == Enum.UserInputType.Keyboard and p1.KeyCode or p1.UserInputType)
            end))
        end

        v23:GiveTask(activateEvent.Event:Connect(function(p1, p2, ...) --[[ Line: 1211 | Upvalues: gunFunctionBegan (ref), gunFunctionEnded (ref) ]]
            if p2 == "began" then
                gunFunctionBegan(p1, ...)

                return
            end

            if p2 ~= "ended" then
                return
            end

            gunFunctionEnded(p1, ...)
        end))
        v23:GiveTask(Humanoid.Died:Connect(onUnequipped))

        local CurrentCamera2 = workspace.CurrentCamera

        if CurrentCamera2 then
            CurrentCamera2:GetAttribute("FPS")
        end

        local v2 = p2 and v3:GetAttribute("aim") or shared.aim
        local v32 = v2 and v7.aimWeight or (v7.unAimWeight or 1)
        local v4 = 0

        v23:GiveTask(RunService.Heartbeat:Connect(function() --[[ Line: 1225 | Upvalues: v5 (ref), RootPart (ref), p2 (ref), t2 (ref), v32 (ref), v3 (ref), v7 (ref), v4 (ref), v6 (ref), mode (ref), Humanoid (ref), Handle (ref), Storage (ref), aim (ref), getAimFOV (ref), TweenService (ref), CurrentCamera (ref), __config (ref) ]]
            if not (v5 and RootPart) then
                return
            end

            if v5 and RootPart then
                if not p2 and t2.fire.IsPlaying then
                    v32 = (p2 and v3:GetAttribute("aim") or shared.aim) and v7.aimWeight or (v7.unAimWeight or 1)

                    if t2.fire.WeightCurrent ~= v32 then
                        t2.fire:AdjustWeight(v32, 0.25)
                    end
                end

                if not (os.clock() - v4 >= 0.1) then
                    return
                end

                if p2 then
                    v4 = os.clock()
                end

                v6:SetAttribute("FireMode", mode)
                Vector3.new(RootPart.AssemblyLinearVelocity.y, 0, RootPart.AssemblyLinearVelocity.z)

                if t2.holster then
                    local v42, v52, v62, v72

                    if (p2 and v3:GetAttribute("run") or shared.run) and not (t2.fire.IsPlaying or t2.equip.IsPlaying) then
                        if p2 and v3:GetAttribute("isProne") or shared.isProne then
                            v42 = p2 and v3:GetAttribute("aim") or shared.aim

                            if v42 then
                                if p2 then
                                    if not t2.holster.IsPlaying then
                                        t2.holster:Play()
                                    end

                                    t2.holster:Stop(0.15)
                                else
                                    v52 = workspace.CurrentCamera

                                    if v52 then
                                        v62 = v52:GetAttribute("FPS")
                                        v72 = v62
                                    else
                                        v72 = false
                                    end

                                    if v72 then
                                        if not t2.holster.IsPlaying then
                                            t2.holster:Play()
                                        end

                                        t2.holster:Stop(0.15)
                                    elseif t2.holster.IsPlaying then
                                        t2.holster:Stop(0.25)
                                    end
                                end
                            elseif t2.holster.IsPlaying then
                                t2.holster:Stop(0.25)
                            end

                            if t2.holsterIdle and t2.holsterIdle.IsPlaying then
                                t2.holsterIdle:Stop(0.2)
                            end
                        else
                            local v9 = p2 and v3:GetAttribute("isCrouch") or shared.isCrouch

                            if v9 or (Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Jumping) then
                                v42 = p2 and v3:GetAttribute("aim") or shared.aim

                                if v42 then
                                    if p2 then
                                        if not t2.holster.IsPlaying then
                                            t2.holster:Play()
                                        end

                                        t2.holster:Stop(0.15)
                                    else
                                        v52 = workspace.CurrentCamera

                                        if v52 then
                                            v62 = v52:GetAttribute("FPS")
                                            v72 = v62
                                        else
                                            v72 = false
                                        end

                                        if v72 then
                                            if not t2.holster.IsPlaying then
                                                t2.holster:Play()
                                            end

                                            t2.holster:Stop(0.15)
                                        elseif t2.holster.IsPlaying then
                                            t2.holster:Stop(0.25)
                                        end
                                    end
                                elseif t2.holster.IsPlaying then
                                    t2.holster:Stop(0.25)
                                end

                                if t2.holsterIdle and t2.holsterIdle.IsPlaying then
                                    t2.holsterIdle:Stop(0.2)
                                end
                            else
                                if t2.holsterIdle and t2.holsterIdle.IsPlaying then
                                    t2.holsterIdle:Stop()
                                end

                                t2.holster.Priority = Enum.AnimationPriority.Action

                                if not t2.holster.IsPlaying then
                                    t2.fire.Priority = Enum.AnimationPriority.Core
                                    t2.holster:Play(0.15)
                                end
                            end
                        end
                    else
                        v42 = p2 and v3:GetAttribute("aim") or shared.aim

                        if v42 then
                            if p2 then
                                if not t2.holster.IsPlaying then
                                    t2.holster:Play()
                                end

                                t2.holster:Stop(0.15)
                            else
                                v52 = workspace.CurrentCamera

                                if v52 then
                                    v62 = v52:GetAttribute("FPS")
                                    v72 = v62
                                else
                                    v72 = false
                                end

                                if v72 then
                                    if not t2.holster.IsPlaying then
                                        t2.holster:Play()
                                    end

                                    t2.holster:Stop(0.15)
                                elseif t2.holster.IsPlaying then
                                    t2.holster:Stop(0.25)
                                end
                            end
                        elseif t2.holster.IsPlaying then
                            t2.holster:Stop(0.25)
                        end

                        if t2.holsterIdle and t2.holsterIdle.IsPlaying then
                            t2.holsterIdle:Stop(0.2)
                        end
                    end
                end

                if not p2 then
                    local IsPlaying = t2.equip.IsPlaying

                    if p2 then
                        v3:SetAttribute("gunEquip", IsPlaying)
                    else
                        shared.gunEquip = IsPlaying
                    end
                end

                local v10 = p2 and v3:GetAttribute("aim") or shared.aim

                if v10 and p2 then
                    if t2.idle.IsPlaying then
                        t2.idle:Stop(1e-9)
                    end
                elseif v10 then
                    local CurrentCamera2 = workspace.CurrentCamera

                    if (if CurrentCamera2 then CurrentCamera2:GetAttribute("FPS") else false) and t2.idle.IsPlaying then
                        t2.idle:Stop(1e-9)
                    end
                end

                if t2.inspect and t2.inspect.IsPlaying then
                    if p2 then
                        v3:SetAttribute("aim", false)
                    else
                        shared.aim = false
                    end
                end

                if t2.inspect_empty and t2.inspect_empty.IsPlaying then
                    if p2 then
                        v3:SetAttribute("aim", false)
                    else
                        shared.aim = false
                    end
                end

                if not p2 then
                    local v13 = t2.inspect and t2.inspect.IsPlaying or t2.inspect_empty and t2.inspect_empty.IsPlaying

                    if p2 then
                        v3:SetAttribute("inspect", v13)
                    else
                        shared.inspect = v13
                    end
                end

                local IsPlaying = t2.equip.IsPlaying

                if p2 then
                    v3:SetAttribute("equipping", IsPlaying)
                else
                    shared.equipping = IsPlaying
                end

                if t2.holster and t2.holster.IsPlaying then
                    t2.idle:Stop(0.25)
                elseif not t2.idle.IsPlaying then
                    local v15

                    if p2 and v3:GetAttribute("aim") or shared.aim then
                        if p2 then
                            v15 = 1e-9
                        else
                            local CurrentCamera2 = workspace.CurrentCamera

                            v15 = if if CurrentCamera2 then CurrentCamera2:GetAttribute("FPS") else false then 1e-9 else nil
                        end
                    else
                        v15 = nil
                    end

                    t2.idle:Play(v15)
                end

                local v18, v19

                if t2.holsterIdle then
                    local v20 = p2 and v3:GetAttribute("run") or shared.run

                    if v20 or (p2 and v3:GetAttribute("reload") or shared.reload) then
                        v18 = p2 and v3:GetAttribute("run") or shared.run

                        if v18 then
                            if t2.holsterIdle then
                                t2.holsterIdle:Stop(0.25)
                            end
                        else
                            v19 = p2 and v3:GetAttribute("reload") or shared.reload

                            if v19 and t2.holsterIdle then
                                t2.holsterIdle:Stop(0.25)
                            end
                        end
                    else
                        t2.holsterIdle:AdjustSpeed(0)
                    end
                else
                    v18 = p2 and v3:GetAttribute("run") or shared.run

                    if v18 then
                        if t2.holsterIdle then
                            t2.holsterIdle:Stop(0.25)
                        end
                    else
                        v19 = p2 and v3:GetAttribute("reload") or shared.reload

                        if v19 and t2.holsterIdle then
                            t2.holsterIdle:Stop(0.25)
                        end
                    end
                end

                if p2 or not Handle:FindFirstChild("MuzzleFX") then
                    return
                end

                local CurrentCamera2 = workspace.CurrentCamera

                if if CurrentCamera2 then CurrentCamera2:GetAttribute("FPS") else false then
                    Storage.Events.client:Fire("crosshair", not shared.aim, v7.crosshairRadius)
                else
                    Storage.Events.client:Fire("crosshair", true, v7.crosshairRadius * (if shared.aim then 0.5 else 1))

                    if aim and not shared.aim then
                        aim = false
                        Storage.Events.client:Fire("setCrosshair", v7.crosshairRadius, true, nil, nil, 0.25)
                    elseif not aim and shared.aim then
                        aim = true
                        Storage.Events.client:Fire("setCrosshair", v7.crosshairRadius * 0.5, true, nil, nil, 0.25)
                    end
                end

                if not (v6:FindFirstChild("_mod") and (v6._mod:FindFirstChild("Handle") and v6._mod.Handle:FindFirstChild("aimPos"))) then
                    return
                end

                if shared.aim then
                    local CurrentCamera3 = workspace.CurrentCamera

                    if (if CurrentCamera3 then CurrentCamera3:GetAttribute("FPS") else false) and not shared.freeLook then
                        local v29, v30 = getAimFOV()

                        TweenService:Create(CurrentCamera.FOV, if v30 then v30 else v7.ads_config.tweenInfoIn, {
                            Value = v29
                        }):Play()

                        return
                    end
                end

                if shared.aim then
                    local CurrentCamera3 = workspace.CurrentCamera

                    if (if CurrentCamera3 then CurrentCamera3:GetAttribute("FPS") else false) and not shared.freeLook then
                        return
                    end
                end

                TweenService:Create(CurrentCamera.FOV, v7.ads_config.tweenInfoOut, {
                    Value = __config.fov.Value
                }):Play()
                shared.aimTickTimer = if v7.ads_config.aimOutTime then v7.ads_config.aimOutTime + 0.1 or 0.35 else 0.35

                return
            end

            if v5 or p2 then
                return
            end

            TweenService:Create(CurrentCamera.FOV, TweenInfo.new(0.00016, Enum.EasingStyle.Sine), {
                Value = __config.fov.Value
            }):Play()
        end))

        if not p2 then
            t.ammoCurrent = v6._data.ammoCurrent.Value
            v23:GiveTask(Storage.Events.melee.Event:Connect(function(p1, ...) --[[ Line: 1360 | Upvalues: v7 (ref), p2 (ref), v3 (ref), t2 (ref), finisherFunction (ref), Storage (ref), onUnequipped (ref) ]]
                if p1 == "finish" then
                    if not v7.anims.SF_cam then
                        return false
                    end

                    if p2 and v3:GetAttribute("reload") or shared.reload then
                        return false
                    end

                    local v2 = unpack({ ... })

                    if t2.SF_finisher_1.IsPlaying or (t2.SF_finisher_2.IsPlaying or t2.SF_cam.IsPlaying) then
                        return
                    end

                    if p2 and v3:GetAttribute("meleeFinisher") or shared.meleeFinisher then
                        return
                    end

                    if shared.staminaFunction("getStaminaCurrent") >= v7.staminaUsage then
                        shared.staminaFunction("drain", v7.staminaUsage)
                        finisherFunction(v2)
                    else
                        shared.staminaFunction("error")
                    end

                    return
                end

                if p1 ~= "unequip" or not t2.unequip then
                    return
                end

                for k, v in pairs(t2) do
                    v.Priority = Enum.AnimationPriority.Core
                end

                t2.unequip.Priority = Enum.AnimationPriority.Action2
                t2.unequip:Play(1e-11)
                task.spawn(function() --[[ Line: 1382 | Upvalues: t2 (ref), Storage (ref) ]]
                    local v1 = t2.unequip.Length - 0.08

                    while t2.unequip.TimePosition < v1 do
                        task.wait()
                    end

                    t2.unequip.Priority = Enum.AnimationPriority.Core
                    t2.unequip:Stop()
                    Storage.Events.melee:Fire()
                end)
                onUnequipped(true)
            end))
        end
    end

    if v5 then
        onEquipped()
    end

    v6.Equipped:Connect(onEquipped)
    v6.Unequipped:Connect(onUnequipped)

    if v6._data:FindFirstChild("magAttached") then
        v6._data.magAttached.Changed:Connect(function() --[[ Line: 1404 | Upvalues: v6 (copy), t (copy), v24 (ref), Storage (ref), v7 (copy) ]]
            task.wait(0.06666666666666667)

            local magAttached = v6._data.magAttached.Value

            if magAttached ~= "" and t.ammoCurrent <= 0 then
                v24 = true
            end

            t.ammoCurrent = v6._data.ammoCurrent.Value

            if magAttached == "" then
                return
            end

            t.ammoSize = require(Storage.Modules.Items:FindFirstChild(v6._data.magAttached.Value, true)).maxAmmo or v7.ammoSize
        end)
    end

    if v7.shotgun then
        v6._data.ammoCurrent.Changed:Connect(function() --[[ Line: 1420 | Upvalues: t (copy), v24 (ref), v6 (copy), t2 (copy) ]]
            if t.ammoCurrent <= 0 then
                v24 = true
            end

            t.ammoCurrent = v6._data.ammoCurrent.Value

            if not (t.ammoSize > 0 and t2.noammo) then
                return
            end

            t2.noammo:Stop(1e-10)
        end)
    end

    local durability = v6._data:FindFirstChild("durability")
    local maxDurability = v6._data:FindFirstChild("maxDurability")

    if durability and maxDurability then
        durability.Changed:Connect(function(p1) --[[ Line: 1436 | Upvalues: t (copy), durability (copy) ]]
            t.durability = durability.Value
        end)
        maxDurability.Changed:Connect(function() --[[ Line: 1440 | Upvalues: t (copy), maxDurability (copy) ]]
            t.maxDurability = maxDurability.Value
        end)
    end

    function communicator.OnInvoke(p1, ...) --[[ Line: 1445 | Upvalues: t (copy), v7 (copy), t2 (copy) ]]
        if p1 == "getData" then
            return t
        end

        if p1 == "getSettings" then
            return v7
        end

        if p1 == "isToolAnimationActive" then
            for k, v in pairs(t2) do
                if typeof(t2[k]) == "table" then
                    for k2, v2 in pairs(t2[k]) do
                        if k2 ~= "fire" and v2.IsPlaying then
                            return true
                        end
                    end

                    continue
                end

                if k ~= "idle" and (k ~= "fire" and v.IsPlaying) then
                    return true
                end
            end
        else
            if p1 ~= "getToolAnimationActiveRatio" then
                return false
            end

            local sum = 0
            local count = 0

            local function addAnimProgress(p1) --[[ addAnimProgress | Line: 1470 | Upvalues: sum (ref), count (ref) ]]
                if not (p1 and (p1.IsPlaying and (p1.Length and p1.Length > 0))) then
                    return
                end

                sum = sum + p1.TimePosition / p1.Length
                count = count + 1
            end

            for i, v in ipairs({ t2, (...) }) do
                for k, v2 in pairs(v) do
                    if k ~= "cam" and k ~= "crouch" and k ~= "prone" then
                        if typeof(v2) == "table" then
                            for k2, v3 in pairs(v2) do
                                if k2 ~= "idle" and (k2 ~= "fire" and (k2 ~= "noammo" and (k2 ~= "leaping" and (k2 ~= "landing" and (v3 and (v3.IsPlaying and (v3.Length and v3.Length > 0))))))) then
                                    sum = sum + v3.TimePosition / v3.Length
                                    count = count + 1
                                end
                            end

                            continue
                        end

                        if k ~= "idle" and (k ~= "fire" and (k ~= "noammo" and (k ~= "leaping" and (k ~= "landing" and (v2 and (v2.IsPlaying and (v2.Length and v2.Length > 0))))))) then
                            sum = sum + v2.TimePosition / v2.Length
                            count = count + 1
                        end
                    end
                end
            end

            if count == 0 then
                return 1
            end

            local v2 = sum / count

            if v2 < 0.93 then
                return (v2 / 0.93) ^ 6
            end

            return ((v2 - 0.93) / 0.06999999999999995) ^ 3 * 0.06999999999999995 + 0.93
        end

        return false
    end

    local v25 = nil

    v25 = v6.AncestryChanged:Connect(function(p1, p2) --[[ Line: 1514 | Upvalues: v25 (ref), t2 (copy), v23 (copy) ]]
        if p2 then
            return
        end

        v25:Disconnect()

        for k, v in pairs(t2) do
            if typeof(t2[k]) == "table" then
                for k2, v2 in pairs(t2[k]) do
                    v2:AdjustWeight(0)
                    v2:Stop()
                end

                continue
            end

            v:AdjustWeight(0)
            v:Stop()
        end

        v23:DoCleaning()
    end)
end
