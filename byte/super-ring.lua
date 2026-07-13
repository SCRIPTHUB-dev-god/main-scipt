local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

local radius = 50
local radius2 = 50
local doubleRingEnabled = false
local height = 100
local rotationSpeed = 6
local attractionStrength = 5000
local ringPartsEnabled = false
local flyEnabled = false
local flySpeed = 50
local freecamSpeed = 50
local flyVelocity = nil
local flyGyro = nil
local optimizePerformance = false
local origFogEnd = 100000
local origFogStart = 0
local origAtmospheres = {}
local culledParts = {}

local freecamEnabled = false
local freecamPart = nil
local freecamVelocity = nil
local freecamGyro = nil
local oldMinZoom = 0.5
local oldMaxZoom = 400

local parts = {}
local originalStates = {}

local function addPart(part)
    if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(workspace) then
        if part.Parent == LocalPlayer.Character or part:IsDescendantOf(LocalPlayer.Character) then
            return
        end
        if not table.find(parts, part) then
            table.insert(parts, part)
            originalStates[part] = {
                CanCollide = part.CanCollide,
                CustomPhysicalProperties = part.CustomPhysicalProperties
            }
            if ringPartsEnabled then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                part.CanCollide = false
            end
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
    originalStates[part] = nil
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

local function getTargetPos(currentRadius, pos, tornadoCenter, reverse, heightOffset)
    local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
    local speed = reverse and -rotationSpeed or rotationSpeed
    local newAngle = angle + math.rad(speed)
    local offset = heightOffset or 0
    return Vector3.new(
        tornadoCenter.X + math.cos(newAngle) * currentRadius,
        tornadoCenter.Y + (height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / height)))) + offset,
        tornadoCenter.Z + math.sin(newAngle) * currentRadius
    )
end

RunService.Heartbeat:Connect(function()
    if ringPartsEnabled then
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local tornadoCenter = humanoidRootPart.Position
            if doubleRingEnabled then
                for i, part in pairs(parts) do
                    if part.Parent and not part.Anchored then
                        local targetPos = (i % 2 == 0) and getTargetPos(radius, part.Position, tornadoCenter, false, -5) or getTargetPos(radius2, part.Position, tornadoCenter, true, -25)
                        if targetPos then
                            part.Velocity = (targetPos - part.Position).unit * attractionStrength
                        end
                    end
                end
            else
                for _, part in pairs(parts) do
                    if part.Parent and not part.Anchored then
                        local targetPos = getTargetPos(radius, part.Position, tornadoCenter, false, -5)
                        if targetPos then
                            part.Velocity = (targetPos - part.Position).unit * attractionStrength
                        end
                    end
                end
            end
        end
    end

    if flyEnabled then 
        local character = LocalPlayer.Character 
        local hrp = character and character:FindFirstChild("HumanoidRootPart") 
        local humanoid = character and character:FindFirstChildOfClass("Humanoid") 
        if hrp and humanoid then 
            humanoid.PlatformStand = true 
            if not flyVelocity or flyVelocity.Parent ~= hrp then 
                if flyVelocity then flyVelocity:Destroy() end 
                flyVelocity = Instance.new("BodyVelocity") 
                flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
                flyVelocity.Parent = hrp 
            end 
            if not flyGyro or flyGyro.Parent ~= hrp then 
                if flyGyro then flyGyro:Destroy() end 
                flyGyro = Instance.new("BodyGyro") 
                flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
                flyGyro.Parent = hrp 
            end 
            local camCFrame = workspace.CurrentCamera.CFrame 
            flyGyro.CFrame = camCFrame 
            if humanoid.MoveDirection.Magnitude > 0 then 
                local localMove = camCFrame:VectorToObjectSpace(humanoid.MoveDirection) 
                local flyDir = (camCFrame.LookVector * -localMove.Z) + (camCFrame.RightVector * localMove.X) 
                if flyDir.Magnitude > 0 then flyDir = flyDir.unit end 
                flyVelocity.Velocity = flyDir * flySpeed 
            else 
                flyVelocity.Velocity = Vector3.new(0, 0, 0) 
            end 
        end 
    end 
    
    if freecamEnabled and freecamPart then 
        local character = LocalPlayer.Character 
        local humanoid = character and character:FindFirstChildOfClass("Humanoid") 
        if humanoid and freecamGyro and freecamVelocity then 
            local camCFrame = workspace.CurrentCamera.CFrame 
            freecamGyro.CFrame = camCFrame 
            if humanoid.MoveDirection.Magnitude > 0 then 
                local localMove = camCFrame:VectorToObjectSpace(humanoid.MoveDirection) 
                local flyDir = (camCFrame.LookVector * -localMove.Z) + (camCFrame.RightVector * localMove.X) 
                if flyDir.Magnitude > 0 then flyDir = flyDir.unit end 
                freecamVelocity.Velocity = flyDir * freecamSpeed 
            else 
                freecamVelocity.Velocity = Vector3.new(0, 0, 0) 
            end 
        end 
    end 
end)

RunService.Stepped:Connect(function()
    if flyEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function clearAnimations(character)
    if not character then return end
    local animate = character:FindFirstChild("Animate")
    if animate then animate:Destroy() end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    if optimizePerformance then
        task.wait(0.1)
        clearAnimations(character)
    end
end)

local userId = Players:GetUserIdFromNameAsync("PGK_KINGGM4")
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

StarterGui:SetCore("SendNotification", {
    Title = "Enjoy Super Ring [V1]",
    Text = "Cracked By icarus community",
    Icon = content,
    Duration = 5
})

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()

local window = library:window({
    title = "Super Ring [v1]",
    desc = "by icarus community",
    transparent = 0.15,
    theme = "ocean",
    autoshow = true
})

local ExecutorName = "Unknown"

if identifyexecutor then
    ExecutorName = identifyexecutor()
elseif getexecutorname then
    ExecutorName = getexecutorname()
end

window:AddTag({
    title = ExecutorName,
    icon = "folder",
    color = Color3.fromRGB(45, 125, 255),
    getclick = false,
})

window:AddTag({
    title = "Join Discord",
    icon = "globe",
    color = Color3.fromRGB(45, 125, 255),
    getclick = true,
    callback = function()
        local invite = "https://discord.gg/dbE59H6grJ"

        if setclipboard then
            setclipboard(invite)
        elseif toclipboard then
            toclipboard(invite)
        else
            library:Notification({
                title = "Clipboard",
                desc = "Clipboard is not supported by your executor.",
                duration = 5
            })
            return
        end

        library:Notification({
            title = "Clipboard",
            desc = "Discord invite copied to clipboard!",
            duration = 5
        })
    end
})

local Tab1 = window:AddTab("Main", "home")
local Tab2 = window:AddTab("Settings", "settings")

local Tab = Tab1:AddSection({
    title = "Main Super Ring",
    icon = "settings",
    open = true
})

local SettingsSection = Tab2:AddSection({
    title = "Options",
    icon = "settings",
    open = true
})

local PerformanceSection = Tab2:AddSection({
    title = "others",
    icon = "settings",
    open = false
})

Tab:Addtoggle({
    title = "Super Ring",
    desc = "Click to enable",
    value = false,
    callback = function(state)
        ringPartsEnabled = state
        for _, part in pairs(parts) do
            if part.Parent and not part.Anchored then
                if state then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    part.CanCollide = false
                else
                    part.Velocity = Vector3.new(0, 0, 0)
                    local orig = originalStates[part]
                    if orig then
                        part.CanCollide = orig.CanCollide
                        part.CustomPhysicalProperties = orig.CustomPhysicalProperties
                    else
                        part.CanCollide = true
                        part.CustomPhysicalProperties = nil
                    end
                end
            end
        end
    end
})

Tab:AddSlider({
    Title = "Radius Ring 1",
    Desc = "Radius super ring v1",
    Step = 5,
    Value = {Min = 10, Max = 175, Default = 85},
    Callback = function(value)
        radius = value
    end
})

Tab:AddDivider()

Tab:Addtoggle({
    title = "Double Ring",
    desc = "Enable two rings simultaneously",
    value = false,
    callback = function(state)
        doubleRingEnabled = state
    end
})

Tab:AddSlider({
    Title = "Radius Ring 2",
    Desc = "Radius for the second ring",
    Step = 5,
    Value = {Min = 10, Max = 175, Default = 85},
    Callback = function(value)
        radius2 = value
    end
})

SettingsSection:Addtoggle({
    title = "Fly & Noclip",
    desc = "Click to enable fly and noclip",
    value = false,
    callback = function(state)
        flyEnabled = state
        if not state then
            if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
            if flyGyro then flyGyro:Destroy() flyGyro = nil end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
})

SettingsSection:AddSlider({
    Title = "Speed Fly",
    Desc = "Slide to adjust fly speed",
    Step = 5,
    Value = {Min = 10, Max = 300, Default = 50},
    Callback = function(value)
        flySpeed = value
    end
})

SettingsSection:AddDivider()

SettingsSection:Addtoggle({
    title = "Freecam",
    desc = "Click to enable freecam mode",
    value = false,
    callback = function(state)
        freecamEnabled = state
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if state then 
            if hrp and humanoid then 
                hrp.Anchored = true 
                oldMinZoom = LocalPlayer.CameraMinZoomDistance 
                oldMaxZoom = LocalPlayer.CameraMaxZoomDistance 
                LocalPlayer.CameraMinZoomDistance = 0 
                LocalPlayer.CameraMaxZoomDistance = 0 
                freecamPart = Instance.new("Part") 
                freecamPart.Size = Vector3.new(1, 1, 1) 
                freecamPart.Position = hrp.Position + Vector3.new(0, 5, 0) 
                freecamPart.Transparency = 1 
                freecamPart.CanCollide = false 
                freecamPart.Anchored = false 
                freecamPart.Parent = workspace 
                freecamVelocity = Instance.new("BodyVelocity") 
                freecamVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
                freecamVelocity.Velocity = Vector3.new(0, 0, 0) 
                freecamVelocity.Parent = freecamPart 
                freecamGyro = Instance.new("BodyGyro") 
                freecamGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
                freecamGyro.Parent = freecamPart 
                workspace.CurrentCamera.CameraSubject = freecamPart 
            end 
        else 
            if hrp then hrp.Anchored = false end 
            if freecamPart then freecamPart:Destroy() freecamPart = nil end 
            if freecamVelocity then freecamVelocity:Destroy() freecamVelocity = nil end 
            if freecamGyro then freecamGyro:Destroy() freecamGyro = nil end 
            if humanoid then workspace.CurrentCamera.CameraSubject = humanoid end 
            LocalPlayer.CameraMinZoomDistance = oldMinZoom 
            LocalPlayer.CameraMaxZoomDistance = oldMaxZoom 
        end 
    end 
})

SettingsSection:AddSlider({
    Title = "Speed Freecam",
    Desc = "Slide to adjust freecam speed",
    Step = 5,
    Value = {Min = 10, Max = 300, Default = 50},
    Callback = function(value)
        freecamSpeed = value
    end
})

PerformanceSection:Addtoggle({
    title = "Optimize Performance",
    desc = "Disable shadows, light reflections, textures, and animations to boost FPS",
    value = false,
    callback = function(state)
        optimizePerformance = state
        if state then
            origFogEnd = Lighting.FogEnd
            origFogStart = Lighting.FogStart
            table.clear(origAtmospheres)
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") then
                    origAtmospheres[v] = v.Density
                    v.Density = 0
                end
            end
            Lighting.GlobalShadows = false
            Lighting.EnvironmentSpecularScale = 0
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.FogEnd = 999999
            Lighting.FogStart = 999999
            
            table.clear(culledParts)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") and not v:IsDescendantOf(LocalPlayer.Character) then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    if v.Size.X < 6 and v.Size.Y < 6 and v.Size.Z < 6 then
                        culledParts[v] = {OriginalParent = v.Parent, Position = v.Position, Anchored = v.Anchored}
                    end
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                end
            end
            clearAnimations(LocalPlayer.Character)
            
            task.spawn(function()
                while optimizePerformance do
                    local camera = workspace.CurrentCamera
                    if camera then
                        for part, info in pairs(culledParts) do
                            if not optimizePerformance then break end
                            if part then
                                local partPos = info.Position
                                if not info.Anchored and part.Parent then
                                    partPos = part.Position
                                    info.Position = partPos
                                end
                                local _, onScreen = camera:WorldToViewportPoint(partPos)
                                if onScreen then
                                    if part.Parent ~= info.OriginalParent then
                                        part.Parent = info.OriginalParent
                                    end
                                else
                                    if part.Parent ~= nil then
                                        part.Parent = nil
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            Lighting.GlobalShadows = true
            Lighting.EnvironmentSpecularScale = 1
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.FogEnd = origFogEnd
            Lighting.FogStart = origFogStart
            for v, density in pairs(origAtmospheres) do
                if v.Parent then
                    v.Density = density
                end
            end
            for part, info in pairs(culledParts) do
                if part and info.OriginalParent then
                    part.Parent = info.OriginalParent
                end
            end
            table.clear(culledParts)
        end
    end
})

PerformanceSection:Addbutton({
    title = "touch fling",
    desc = "click for execute",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))()
    end
})
