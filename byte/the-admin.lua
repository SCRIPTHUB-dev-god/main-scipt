local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")
local musicSound = Instance.new("Sound")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local function getExecutor()
    local name = "Unknown"
    -- executor modern
    if identifyexecutor then
        name = identifyexecutor()
    elseif getexecutorname then
        name = getexecutorname()
    end
    return name
end

local executorName = getExecutor()

local _version = "1.6.66"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

WindUI:AddTheme({Name="My Theme",Accent=Color3.fromHex("#00d4ff"),Background=Color3.fromHex("#0a192f"),Outline=Color3.fromHex("#1e293b"),Text=Color3.fromHex("#f0f9ff"),Placeholder=Color3.fromHex("#94a3b8"),Button=Color3.fromHex("#1d4ed8"),Icon=Color3.fromHex("#38bdf8")})

local Window = WindUI:CreateWindow({Title="Icarus admin | script panel",Icon="snowflake",Author="by.icarus community",Theme="My Theme",Size=UDim2.fromOffset(740,500),Transparent=true,BackgroundImageTransparency=0.73,HideSearchBar=false})
Window:DisableTopbarButtons({"Fullscreen"})
Window:EditOpenButton({Title="Icarus admin",Icon="snowflake",CornerRadius=UDim.new(0,16),StrokeThickness=2.25,Color=ColorSequence.new(Color3.fromHex("#3d87ff"),Color3.fromHex("#91bbff")),Enabled=true})
Window:Tag({Title=executorName,Icon="folder",Color=Color3.fromHex("#ffa200"),})
Window:Tag({Title="key system",Icon="key-round",Color=Color3.fromHex("#e1ff00"),})

local TabSupport=Window:Tab({Title="Support",Icon="info"})
TabSupport:Code({Title="Discord Link",Code=[[https://discord.gg/dbE59H6grJ]]})
Window:Divider()

local Section1=Window:Section({Title="Main Features",Icon="star",Opened=true})
local TabCombat=Section1:Tab({Title="Combat",Icon="sword"})
local TabExploits=Section1:Tab({Title="Exploits",Icon="clipboard"})
local TabPartTP=Section1:Tab({Title="Part TP",Icon="map-pin"})
local TabPlayer=Section1:Tab({Title="Player",Icon="user"})
local ServerTab=Section1:Tab({Title="Server",Icon="server"})
local TabTroll=Section1:Tab({Title="Troll",Icon="zap"})

local flyEnabled=false; local speed=70; local bVelocity,bGyro,shiftLockConn
local noclipEnabled=false; local infJumpEnabled=false; local viewEnabled=false; local selectedTargetName=""
local walkSpeedPower=16; local jumpPower=50; local speedEnabled=false; local jumpEnabled=false
local savedParts={}; local selectedPartName="None"; local tpMode="Teleport"
local loopParts={}; local loopTweenSpeed=1; local loopTweenEnabled=false; local currentLoopIndex=1; local currentTween
local antiVoidEnabled=false; local lastSafeCFrame; local autoVoidOffset=50
local antiKnockbackEnabled=false; local knockbackConn; local antiRagdollEnabled=false; local antiFlingEnabled=false
local tpWallEnabled=false; local tpWallConn
local customGui,followerPart; local targetY=0; local showGuiActive=false; local holdUp,holdDown=false,false; local moveSpeed=25
local maxZoomValue=128; local minZoomValue=0.5; local maxZoomEnabled=false; local minZoomEnabled=false; local infiniteZoomEnabled=false
local flashEnabled=false; local flashSpeed=0.1; local flashDistance=6; local flashDir=1
local spinEnabled=false; local spinSpeedInput=1
local rainbowESPEnabled=false; local rainbowSpeed=1; local espThickness=1.5
local rainbowWorkspaceEnabled=false; local rainbowWorkspaceSpeed=1; local originalPartColors={}
local hellEnabled=false; local hellOriginal={}; local hellFires={}
local fpsBoostEnabled=false
local antiAfkEnabled=false; local lastMoveTime=tick()
local followPartEnabled=false; local followPartModel=nil; local followShape="Tornado"; local followPartCount=48; local followRadius=12; local followAnimTime=0
local tornadoCenter = Vector3.new(0,0,0)
local tornadoTarget = Vector3.new(0,0,0)
local tornadoLastSwitch = 0
local egorEnabled=false
local noAnimationEnabled=false
local freezePlayerEnabled=false
local fakeLagEnabled=false
local airWalkEnabled=false
local airWalkPart=nil

local hitboxEnabled=false
local hitboxType="Head"
local hitboxSize=Vector3.new(1,1,1)
local autoAimEnabled=false
local aimPartType="Head"
local aimSmoothness=1
local noclipCamEnabled=false
local currentAimTarget=nil
local playerAssignedParts={}
_G.notifiedPlayers = {}
local States={Fullbright=false,Tracers=false,Box2D=false,Box3D=false,NameESP=false,DistanceESP=false,HealthNumber=false,LoopTP=false,RainbowESP=false,CharmESP=false,SkeletonESP=false,HealthBar=false}
local defaultLighting={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows,OutdoorAmbient=Lighting.OutdoorAmbient,ExposureCompensation=Lighting.ExposureCompensation}
local lastFullbright=false; local ESP_Objects={}

local customGravityValue = 196.2
local customGravityEnabled = false

local serverInfoEnabled = false
local serverInfoParagraph = nil
local currentFpsValue = 0

local currentMusicId = ""
musicSound.Name = "CustomPlayerMusic"
musicSound.Parent = SoundService
musicSound.Volume = 15
musicSound.Looped = false
musicSound:Stop()

local drawingSupported = false
pcall(function()
    if Drawing and Drawing.new then
        local t = Drawing.new("Line")
        t:Remove()
        drawingSupported = true
    end
end)

local FallbackGui
if not drawingSupported then
    FallbackGui = game:GetService("CoreGui"):FindFirstChild("WindESP_Fallback") or Instance.new("ScreenGui")
    FallbackGui.Name = "WindESP_Fallback"
    FallbackGui.Parent = game:GetService("CoreGui")
end

local function updateCamera()
    if not player.Character then return end
    if infiniteZoomEnabled then player.CameraMaxZoomDistance=999999
    elseif maxZoomEnabled then player.CameraMaxZoomDistance=maxZoomValue
    else player.CameraMaxZoomDistance=128 end
    player.CameraMinZoomDistance=minZoomEnabled and minZoomValue or 0.5
end
player.CharacterAdded:Connect(function() task.wait(1) updateCamera() end)

local function ClearESP(plr)
    if playerAssignedParts[plr] then playerAssignedParts[plr] = nil end
    if ESP_Objects[plr] then
        for _,v in pairs(ESP_Objects[plr]) do
            if typeof(v)=="table" then 
                for _,d in pairs(v) do pcall(function() d:Remove() end) pcall(function() d:Destroy() end) end
            else 
                pcall(function() v:Remove() end) pcall(function() v:Destroy() end) 
            end
        end
        if ESP_Objects[plr].FallbackDrawings then
            for _,v in pairs(ESP_Objects[plr].FallbackDrawings) do
                pcall(function() v:Destroy() end)
            end
        end
        ESP_Objects[plr]=nil
    end
end

local function CreateESP(plr)
    if plr==player or ESP_Objects[plr] then return end
    ESP_Objects[plr]={}
    local bill=Instance.new("BillboardGui"); bill.Name="WindESP"; bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,200,0,50); bill.StudsOffset=Vector3.new(0,3,0); bill.Parent=game:GetService("CoreGui")
    local nameLbl=Instance.new("TextLabel",bill); nameLbl.Size=UDim2.new(1,0,0,20); nameLbl.BackgroundTransparency=1; nameLbl.TextColor3=Color3.new(1,1,1); nameLbl.TextStrokeTransparency=0; nameLbl.Font=Enum.Font.Code; nameLbl.TextSize=14
    local distLbl=Instance.new("TextLabel",bill); distLbl.Position=UDim2.new(0,0,0,20); distLbl.Size=UDim2.new(1,0,0,15); distLbl.BackgroundTransparency=1; distLbl.TextColor3=Color3.new(1,1,1); distLbl.TextStrokeTransparency=0; distLbl.Font=Enum.Font.Code; textSize=13
    ESP_Objects[plr].Billboard=bill; ESP_Objects[plr].NameLbl=nameLbl; ESP_Objects[plr].DistLbl=distLbl
    local box=Instance.new("BoxHandleAdornment"); box.Name="WindBox3D"; box.AlwaysOnTop=true; box.ZIndex=10; box.Size=Vector3.new(4,6,2); box.Color3=Color3.fromRGB(0,255,0); box.Transparency=0.5; box.Parent=game:GetService("CoreGui")
    ESP_Objects[plr].Box3D=box; ESP_Objects[plr].Drawings={}
    ESP_Objects[plr].FallbackDrawings={}
    local hl=Instance.new("Highlight"); hl.Name="SkeletonHighlight"; hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.FillColor=Color3.fromRGB(255,105,180); hl.OutlineColor=Color3.fromRGB(255,20,147); hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=game:GetService("CoreGui"); ESP_Objects[plr].CharmHL=hl
end

local function setShiftLock(state)
    local char=player.Character or player.CharacterAdded:Wait()
    local humanoid=char:WaitForChild("Humanoid"); local root=char:WaitForChild("HumanoidRootPart")
    player.DevEnableMouseLock=state
    if state then
        humanoid.AutoRotate=false; UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter; UserInputService.MouseIconEnabled=false
        if shiftLockConn then shiftLockConn:Disconnect() end
        shiftLockConn=RunService.RenderStepped:Connect(function()
            if not root.Parent then return end
            local look=camera.CFrame.LookVector; local flat=Vector3.new(look.X,0,look.Z).Unit
            root.CFrame=CFrame.new(root.Position,root.Position+flat)
        end)
    else
        humanoid.AutoRotate=true; UserInputService.MouseBehavior=Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled=true
        if shiftLockConn then shiftLockConn:Disconnect() shiftLockConn=nil end
    end
end

local freecamPart,freecamConn,freecamSpeed=nil,nil,2
local moveKeys={W=false,A=false,S=false,D=false}
local function updateFreecamMovement()
    if not freecamPart then return end
    local char=player.Character; local humanoid=char and char:FindFirstChild("Humanoid"); if not humanoid then return end
    local camCF=camera.CFrame; local moveDir=Vector3.zero
    if UserInputService.TouchEnabled then
        local mv=humanoid.MoveDirection
        if mv.Magnitude>0 then
            local camF=camCF.LookVector; local camR=camCF.RightVector
            local fwd=Vector3.new(camF.X,0,camF.Z).Unit; local right=Vector3.new(camR.X,0,camR.Z).Unit
            moveDir=moveDir+camF*mv:Dot(fwd)+camR*mv:Dot(right)
        end
    else
        if moveKeys.W then moveDir=moveDir+camCF.LookVector end
        if moveKeys.S then moveDir=moveDir-camCF.LookVector end
        if moveKeys.D then moveDir=moveDir+camCF.RightVector end
        if moveKeys.A then moveDir=moveDir-camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir=moveDir+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir=moveDir-Vector3.new(0,1,0) end
    end
    if moveDir.Magnitude>0 then moveDir=moveDir.Unit*freecamSpeed end
    freecamPart.CFrame=freecamPart.CFrame+moveDir
end
local function handleFreecamInput(_,st,inp)
    local k=inp.KeyCode.Name
    if moveKeys[k]~=nil then moveKeys[k]=st==Enum.UserInputState.Begin return Enum.ContextActionResult.Sink end
    return Enum.ContextActionResult.Pass
end
local function setFreecam(state)
    local char=player.Character or player.CharacterAdded:Wait()
    local humanoid=char:WaitForChild("Humanoid"); local root=char:WaitForChild("HumanoidRootPart")
    if state then
        humanoid.WalkSpeed=0; humanoid.JumpPower=0; root.Anchored=true
        player.CameraMaxZoomDistance=0; player.CameraMinZoomDistance=0; player.CameraMode=Enum.CameraMode.LockFirstPerson
        UserInputService.MouseIconEnabled=true
        freecamPart=Instance.new("Part"); freecamPart.Size=Vector3.new(1,1,1); freecamPart.Transparency=1; freecamPart.CanCollide=false; freecamPart.Anchored=true; freecamPart.CFrame=camera.CFrame; freecamPart.Parent=workspace
        camera.CameraType=Enum.CameraType.Custom; camera.CameraSubject=freecamPart
        ContextActionService:BindAction("FreecamMove",handleFreecamInput,false,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D)
        if freecamConn then freecamConn:Disconnect() end
        freecamConn=RunService.RenderStepped:Connect(updateFreecamMovement)
    else
        humanoid.WalkSpeed=16; humanoid.JumpPower=50; root.Anchored=false
        player.CameraMode=Enum.CameraMode.Classic; camera.CameraType=Enum.CameraType.Custom; camera.CameraSubject=humanoid
        ContextActionService:UnbindAction("FreecamMove")
        if freecamConn then freecamConn:Disconnect() freecamConn=nil end
        if freecamPart then freecamPart:Destroy() freecamPart=nil end
        for k in pairs(moveKeys) do moveKeys[k]=false end
        task.delay(0.2,updateCamera)
    end
end

local function getPlayerList()
    local t={}
    for _,p in pairs(Players:GetPlayers()) do if p~=player then table.insert(t,p.Name) end end
    return t
end

local function startLoopTween()
    if not loopTweenEnabled or #loopParts==0 then return end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
    if currentLoopIndex>#loopParts then currentLoopIndex=1 end
    local target=loopParts[currentLoopIndex]
    if not target or not target.Parent then table.remove(loopParts,currentLoopIndex) startLoopTween() return end
    if loopTweenSpeed<=0 then root.CFrame=target.CFrame; currentLoopIndex=currentLoopIndex+1; task.wait(0.05); startLoopTween()
    else currentTween=TweenService:Create(root,TweenInfo.new(loopTweenSpeed,Enum.EasingStyle.Linear),{CFrame=target.CFrame}); currentTween.Completed:Connect(function(s) if s==Enum.PlaybackState.Completed and loopTweenEnabled then currentLoopIndex=currentLoopIndex+1 startLoopTween() end end); currentTween:Play() end
end

local function isRagdolled(humanoid)
	return humanoid.PlatformStand or humanoid:GetState() == Enum.HumanoidStateType.Physics
end

task.spawn(function()
    while task.wait(0.5) do
        if States.Fullbright then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128); Lighting.ExposureCompensation=0.5; lastFullbright=true
        elseif lastFullbright then Lighting.Brightness=defaultLighting.Brightness; Lighting.ClockTime=defaultLighting.ClockTime; Lighting.FogEnd=defaultLighting.FogEnd; Lighting.GlobalShadows=defaultLighting.GlobalShadows; Lighting.OutdoorAmbient=defaultLighting.OutdoorAmbient; Lighting.ExposureCompensation=defaultLighting.ExposureCompensation; lastFullbright=false end
    end
end)

local Section1 = TabCombat:Section({
    Title = "aimbot",
    Icon = "target",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section1:Toggle({Title="Enabled aimbot",Callback=function(state) autoAimEnabled=state end})
Section1:Dropdown({Title="Aim player",Values={"Head","Torso","Random"},Default="Head",Callback=function(v) aimPartType=v end})
Section1:Slider({Title="Smoothness",Step=0.01,Value={Min=0.01,Max=1,Default=1},Callback=function(v) aimSmoothness=v end})

local Section2 = TabCombat:Section({
    Title = "esp",
    Icon = "eye",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Toggle({Title="Rainbow ESP",Callback=function(s) States.RainbowESP=s; rainbowESPEnabled=s end})
Section2:Toggle({Title="Tracers",Callback=function(s) States.Tracers=s end})
Section2:Toggle({Title="2D Box",Callback=function(s) States.Box2D=s end})
Section2:Toggle({Title="3D Box",Callback=function(s) States.Box3D=s end})
Section2:Toggle({Title="Name ESP",Callback=function(s) States.NameESP=s end})
Section2:Toggle({Title="Distance ESP",Callback=function(s) States.DistanceESP=s end})
Section2:Toggle({Title="Number Health",Callback=function(s) States.HealthNumber=s end})
Section2:Toggle({Title="Skeleton ESP",Callback=function(s) States.SkeletonESP=s end})
Section2:Slider({Title="Rainbow Speed",Step=0.1,Value={Min=0.1,Max=5,Default=1},Callback=function(v) rainbowSpeed=v end})
Section2:Slider({Title="ESP Thickness",Step=0.1,Value={Min=0.5,Max=5,Default=1.5},Callback=function(v) espThickness=v end})

local Section1 = TabExploits:Section({
    Title = "fly",
    Icon = "user",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

Section1:Toggle({Title="Fly",Callback=function(state)
    flyEnabled=state
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
    if state then
        if hum then hum.PlatformStand=true hum.AutoRotate=false end
        if root then bVelocity=Instance.new("BodyVelocity"); bVelocity.MaxForce=Vector3.new(1e9,1e9,1e9); bVelocity.Velocity=Vector3.zero; bVelocity.P=1250; bVelocity.Parent=root
            bGyro=Instance.new("BodyGyro"); bGyro.MaxTorque=Vector3.new(1e9,1e9,1e9); bGyro.P=3000; bGyro.D=100; bGyro.CFrame=root.CFrame; bGyro.Parent=root end
    else
        if hum then hum.PlatformStand=false hum.AutoRotate=true end
        if bVelocity then bVelocity:Destroy() bVelocity=nil end
        if bGyro then bGyro:Destroy() bGyro=nil end
    end
end})
Section1:Input({Title="Fly Speed",Value="70",Callback=function(v) speed=tonumber(v) or 70 end})
Section1:Divider()
Section1:Toggle({Title="air walk",Callback=function(state)
    showGuiActive=state
    if state then
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        targetY=root and root.Position.Y-3.5 or 50
        if followerPart then followerPart:Destroy() end
        followerPart=Instance.new("Part"); followerPart.Name="FollowerPart"; followerPart.Size=Vector3.new(8,0.8,8); followerPart.Anchored=true; followerPart.CanCollide=true; followerPart.Material=Enum.Material.Neon; followerPart.Color=Color3.fromRGB(0,212,255); followerPart.Transparency=0.25; followerPart.Parent=workspace
        if root then followerPart.CFrame=CFrame.new(root.Position.X,targetY,root.Position.Z) end
        if customGui then customGui:Destroy() end
        customGui=Instance.new("ScreenGui"); customGui.Name="IcarusAirWalk"; customGui.ResetOnSpawn=false; customGui.Parent=playerGui
        local shadow=Instance.new("Frame",customGui); shadow.Size=UDim2.fromOffset(90,100); shadow.Position=UDim2.new(1,-95,0,25); shadow.BackgroundColor3=Color3.new(0,0,0); shadow.BackgroundTransparency=0.5; shadow.BorderSizePixel=0; shadow.ZIndex=0; Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,12)
        local frame=Instance.new("Frame",customGui); frame.Name="Main"; frame.Size=UDim2.fromOffset(90,100); frame.Position=UDim2.new(1,-100,0,20); frame.BackgroundColor3=Color3.fromHex("#0a192f"); frame.BorderSizePixel=0; frame.Active=true; frame.ZIndex=1
        Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
        local stroke=Instance.new("UIStroke",frame); stroke.Color=Color3.fromHex("#38bdf8"); stroke.Thickness=1.2
        local grad=Instance.new("UIGradient",frame); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHex("#0a192f")),ColorSequenceKeypoint.new(1,Color3.fromHex("#1e293b"))}; grad.Rotation=90
        local title=Instance.new("TextLabel",frame); title.Size=UDim2.new(1,-10,0,18); title.Position=UDim2.fromOffset(5,5); title.BackgroundTransparency=1; title.Text="Air Walk"; title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextColor3=Color3.fromHex("#f0f9ff"); title.TextXAlignment=Enum.TextXAlignment.Left
        local yLbl=Instance.new("TextLabel",frame); yLbl.Name="YLabel"; yLbl.Size=UDim2.new(1,-10,0,14); yLbl.Position=UDim2.fromOffset(5,22); yLbl.BackgroundTransparency=1; yLbl.Text="Y: 0.0"; yLbl.Font=Enum.Font.Gotham; yLbl.TextSize=11; yLbl.TextColor3=Color3.fromHex("#94a3b8"); yLbl.TextXAlignment=Enum.TextXAlignment.Left
        local upBtn=Instance.new("TextButton",frame); upBtn.Size=UDim2.fromOffset(36,36); upBtn.Position=UDim2.fromOffset(7,40); upBtn.Text="▲"; upBtn.TextScaled=true; upBtn.Font=Enum.Font.GothamBlack; upBtn.BackgroundColor3=Color3.fromHex("#1d4ed8"); upBtn.TextColor3=Color3.new(1,1,1); Instance.new("UICorner",upBtn).CornerRadius=UDim.new(0,8)
        local downBtn=Instance.new("TextButton",frame); downBtn.Size=UDim2.fromOffset(36,36); downBtn.Position=UDim2.fromOffset(47,40); downBtn.Text="▼"; downBtn.TextScaled=true; downBtn.Font=Enum.Font.GothamBlack; downBtn.BackgroundColor3=Color3.fromHex("#1d4ed8"); downBtn.TextColor3=Color3.new(1,1,1); Instance.new("UICorner",downBtn).CornerRadius=UDim.new(0,8)
        local reset=Instance.new("TextButton",frame); reset.Size=UDim2.new(1,-14,0,20); reset.Position=UDim2.fromOffset(7,78); reset.Text="Reset"; reset.Font=Enum.Font.GothamSemibold; reset.TextSize=12; reset.BackgroundColor3=Color3.fromHex("#0f172a"); reset.TextColor3=Color3.new(1,1,1); Instance.new("UICorner",reset).CornerRadius=UDim.new(0,6)
        local dragging,dragStart,startPos
        frame.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=inp.Position; startPos=frame.Position; inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
        frame.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then local d=inp.Position-dragStart; frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y); shadow.Position=frame.Position+UDim2.fromOffset(5,5) end end)
        upBtn.MouseButton1Down:Connect(function() holdUp=true end); upBtn.MouseButton1Up:Connect(function() holdUp=false end); upBtn.MouseLeave:Connect(function() holdUp=false end)
        downBtn.MouseButton1Down:Connect(function() holdDown=true end); downBtn.MouseButton1Up:Connect(function() holdDown=false end); downBtn.MouseLeave:Connect(function() holdDown=false end)
        reset.MouseButton1Click:Connect(function() local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if r then targetY=r.Position.Y-3.5 end end)
    else holdUp=false; holdDown=false; if customGui then customGui:Destroy() customGui=nil end; if followerPart then followerPart:Destroy() followerPart=nil end end
end})

local Section2 = TabExploits:Section({
    Title = "Player Character",
    Icon = "user",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Toggle({Title="Shift Lock",Callback=setShiftLock})
Section2:Toggle({Title="Noclip",Callback=function(s) noclipEnabled=s end})
Section2:Toggle({Title="Infinite Jump",Callback=function(s) infJumpEnabled=s end})

local Section3 = TabExploits:Section({
    Title = "spectator",
    Icon = "eye",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
local DropdownView=Section3:Dropdown({Title="Select Player to View",Values=getPlayerList(),Callback=function(v) selectedTargetName=v end})
Section3:Button({Title="Refresh Player List",Color=Color3.fromHex("#3d87ff"),Callback=function() DropdownView:Refresh(getPlayerList()) end})
Section3:Toggle({Title="View Player",Callback=function(state)
    viewEnabled=state
    if state then local t=Players:FindFirstChild(selectedTargetName); if t and t.Character and t.Character:FindFirstChild("Humanoid") then camera.CameraSubject=t.Character.Humanoid end
    else camera.CameraSubject=player.Character and player.Character:FindFirstChild("Humanoid") end
end})
local Section4 = TabExploits:Section({
    Title = "tp player",
    Icon = "map-pin",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
local selectedPlayerName,selectedMode="TP"; local loopTask,playerTpTween,loopSpeed=nil,nil,0.2
local DropdownTarget=Section4:Dropdown({Title="Target Player",Values=getPlayerList(),Callback=function(v) selectedPlayerName=v end})
Section4:Button({Title="Refresh Player List",Callback=function() DropdownTarget:Refresh(getPlayerList()) end})
Section4:Dropdown({Title="Mode",Values={"TP","Tween"},Value="TP",Callback=function(v) selectedMode=v end})
Section4:Button({Title="TP / Tween To Player",Callback=function()
    local t=Players:FindFirstChild(selectedPlayerName); local my=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") or not my then return end
    if selectedMode=="TP" then my.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
    else if playerTpTween then playerTpTween:Cancel() end; playerTpTween=TweenService:Create(my,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)}); playerTpTween:Play() end
end})
Section4:Input({Title="Loop Speed",Value="0.2",Callback=function(v) loopSpeed=tonumber(v) or 0.2 end})
Section4:Toggle({Title="Loop TP To Player",Callback=function(state)
    States.LoopTP=state
    if state then loopTask=task.spawn(function() while States.LoopTP do local t=Players:FindFirstChild(selectedPlayerName); local my=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and my then my.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0) end; task.wait(loopSpeed) end end)
    else if loopTask then task.cancel(loopTask) loopTask=nil end end
end})
Section4:Toggle({Title="TP Wall",Callback=function(state)
    tpWallEnabled=state
    local char=player.Character or player.CharacterAdded:Wait()
    local hum=char:WaitForChild("Humanoid"); local root=char:WaitForChild("HumanoidRootPart")
    if state then
        tpWallConn=hum.Touched:Connect(function(hit)
            if not tpWallEnabled then return end
            if hit and hit:IsA("BasePart") and hit.CanCollide then
                local hitTop = hit.Position.Y + hit.Size.Y/2
                if hitTop < root.Position.Y - 2 then return end
                if hit.Size.Y > 6 then
                    local targetY = hitTop + 5
                    root.CFrame = CFrame.new(hit.Position.X, targetY, hit.Position.Z)
                end
            end
        end)
    else if tpWallConn then tpWallConn:Disconnect() tpWallConn=nil end end
end})
local Section5 = TabExploits:Section({
    Title = "cam player",
    Icon = "eye",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section5:Toggle({Title="Freecam",Callback=setFreecam})
Section5:Slider({Title="Freecam Speed",Step=0.5,Value={Min=0.5,Max=10,Default=2},Callback=function(v) freecamSpeed=v end})
Section5:Divider()
Section5:Input({Title="Max Zoom Distance",Value="128",Callback=function(v) maxZoomValue=tonumber(v) or 128; updateCamera() end})
Section5:Input({Title="Min Zoom Distance",Value="0.5",Callback=function(v) minZoomValue=tonumber(v) or 0.5; updateCamera() end})
Section5:Toggle({Title="Toggle Max Zoom",Callback=function(s) maxZoomEnabled=s; updateCamera() end})
Section5:Toggle({Title="Toggle Min Zoom",Callback=function(s) minZoomEnabled=s; updateCamera() end})
Section5:Toggle({Title="Infinite Max Zoom",Callback=function(s) infiniteZoomEnabled=s; updateCamera() end})
Section5:Toggle({Title="Noclip Cam",Callback=function(s) noclipCamEnabled=s; player.DevCameraOcclusionMode=s and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom end})
local Section6 = TabExploits:Section({
    Title = "player movement",
    Icon = "user",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section6:Input({Title="Gravity Value",Value="196.2",Callback=function(v)
    customGravityValue = tonumber(v) or 196.2
    if customGravityEnabled then
        workspace.Gravity = customGravityValue
    end
end})
Section6:Toggle({Title="Toggle Gravity",Callback=function(state)
    customGravityEnabled = state
    if state then
        workspace.Gravity = customGravityValue
    else
        workspace.Gravity = 196.2
    end
end})
Section6:Divider()
Section6:Input({Title="WalkSpeed Power",Value="16",Callback=function(v) walkSpeedPower=tonumber(v) or 16 end})
Section6:Toggle({Title="Speed Enabled",Callback=function(s) speedEnabled=s end})
Section6:Input({Title="JumpPower Power",Value="50",Callback=function(v) jumpPower=tonumber(v) or 50 end})
Section6:Toggle({Title="Jump Enabled",Callback=function(s) jumpEnabled=s end})
Section6:Button({Title="Reset Power Defaults",Color=Color3.fromHex("#ff3030"),Callback=function() walkSpeedPower=16; jumpPower=50; speedEnabled=false; jumpEnabled=false end})

local Section1 = TabPartTP:Section({
    Title = "set tp",
    Icon = "map-pin",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

local DropdownPart=Section1:Dropdown({Title="Select locations",Values={"None"},Callback=function(v) selectedPartName=v end})
Section1:Dropdown({Title="Mode",Values={"Teleport","Tween"},Value="Teleport",Callback=function(v) tpMode=v end})
Section1:Button({Title="teleport location",Color=Color3.fromHex("#00d4ff"),Callback=function()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); local target=workspace:FindFirstChild(selectedPartName)
    if root and target then if tpMode=="Teleport" then root.CFrame=target.CFrame else TweenService:Create(root,TweenInfo.new(1),{CFrame=target.CFrame}):Play() end end
end})
Section1:Button({Title="Create locations",Color=Color3.fromHex("#00d4ff"),Callback=function()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local p=Instance.new("Part"); p.Name="go_location_"..#savedParts+1; p.Transparency=1; p.CanCollide=false; p.Anchored=true; p.Size=Vector3.new(4,1,4)
    if root then p.CFrame=root.CFrame end; p.Parent=workspace; table.insert(savedParts,p.Name); DropdownPart:Refresh(savedParts)
end})
Section1:Button({Title="Delete locations",Color=Color3.fromHex("#ff3030"),Callback=function()
    local t=workspace:FindFirstChild(selectedPartName); if t then t:Destroy() end
    local n={}; for _,nm in ipairs(savedParts) do if nm~=selectedPartName then table.insert(n,nm) end end; savedParts=n; DropdownPart:Refresh(savedParts)
end})
Section1:Divider()
Section1:Input({Title="Tween Speed",Value="1",Callback=function(v) loopTweenSpeed=tonumber(v) or 1 end})
Section1:Toggle({Title="start",Callback=function(state) loopTweenEnabled=state; if state then currentLoopIndex=1; startLoopTween() else if currentTween then currentTween:Cancel() currentTween=nil end end end})
Section1:Button({Title="Set location",Color=Color3.fromHex("#00d4ff"),Callback=function()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local p=Instance.new("Part"); p.Name="Loop_Part_"..#loopParts+1; p.Size=Vector3.new(4,1,4); p.CFrame=root.CFrame; p.Anchored=true; p.CanCollide=false; p.Transparency=0; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(0,212,255); p.Parent=workspace; table.insert(loopParts,p)
end})
Section1:Button({Title="Reset all locations",Color=Color3.fromHex("#ff3030"),Callback=function()
    loopTweenEnabled=false; if currentTween then currentTween:Cancel() currentTween=nil end
    for _,p in ipairs(loopParts) do if p then p:Destroy() end end; loopParts={}; currentLoopIndex=1
end})
local Section2 = TabPartTP:Section({
    Title = "part visual",
    Icon = "boxes",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Dropdown({Title="Follow Shape",Values={"Tornado","Ring","Rain"},Value="Tornado",Callback=function(v) followShape=v end})
Section2:Input({Title="Part Count",Value="48",Callback=function(v) followPartCount=math.clamp(tonumber(v) or 48,1,200) end})
Section2:Input({Title="Ring Radius",Value="12",Callback=function(v) followRadius=tonumber(v) or 12 end})
Section2:Toggle({Title="Follow Part",Callback=function(state)
    followPartEnabled=state
    if state then
        if followPartModel then followPartModel:Destroy() end
        followPartModel=Instance.new("Model"); followPartModel.Name="FollowModel"; followPartModel.Parent=workspace
        tornadoCenter = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        tornadoTarget = tornadoCenter
        if followShape=="Tornado" then
            for i=1,followPartCount do
                local part=Instance.new("Part")
                part.Name="Tornado"..i
                part.Shape=Enum.PartType.Ball
                part.Size=Vector3.new(2,2,2)
                part.Color=Color3.fromRGB(150,150,150)
                part.Material=Enum.Material.Glass
                part.Transparency=0.3
                part.Anchored=true
                part.CanCollide=false
                part.Parent=followPartModel
            end
        elseif followShape=="Ring" then
            for i=1,followPartCount do
                local orb=Instance.new("Part")
                orb.Name="Ring"..i
                orb.Shape=Enum.PartType.Ball
                orb.Size=Vector3.new(1,1,1)
                orb.Color=Color3.fromRGB(0,212,255)
                orb.Material=Enum.Material.Neon
                orb.Anchored=true
                orb.CanCollide=false
                orb.Parent=followPartModel
            end
        else
            for i=1,followPartCount do
                local drop=Instance.new("Part")
                drop.Name="Rain"..i
                drop.Size=Vector3.new(0.35,1,0.35)
                drop.Color=Color3.fromRGB(0,212,255)
                drop.Material=Enum.Material.Neon
                drop.Anchored=true
                drop.CanCollide=false
                drop.Parent=followPartModel
            end
        end
    else
        if followPartModel then followPartModel:Destroy() followPartModel=nil end
    end
end})

local Section1 = ServerTab:Section({
    Title = "grafic",
    Icon = "boxes",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section1:Toggle({Title="Fullbright",Callback=function(s) States.Fullbright=s end})
Section1:Divider()
Section1:Toggle({Title="FPS Boost",Callback=function(state)
    Section1=state
    if state then
        Lighting.GlobalShadows=false; Lighting.FogEnd=100000
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 end
        end
    end
end})
Section1:Divider()
Section1:Toggle({Title="Information Server Toggle",Callback=function(state)
    serverInfoEnabled = state
    if serverInfoParagraph then
        if state then
            local pCount = #Players:GetPlayers()
            pcall(function()
                serverInfoParagraph:SetDesc("player = " .. tostring(pCount) .. "\nfps = " .. tostring(currentFpsValue))
            end)
            pcall(function()
                serverInfoParagraph:Set({
                    Title = "information server",
                    Desc = "player = " .. tostring(pCount) .. "\nfps = " .. tostring(currentFpsValue)
                })
            end)
        else
            pcall(function()
                serverInfoParagraph:SetDesc("Hidden")
            end)
            pcall(function()
                serverInfoParagraph:Set({
                    Title = "information server",
                    Desc = "Hidden"
                })
            end)
        end
    end
end})
serverInfoParagraph = Section1:Paragraph({
    Title = "information server",
    Desc = "Hidden"
})
local Section2 = ServerTab:Section({
    Title = "server",
    Icon = "server",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Button({Title="Rejoin Server",Callback=function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end})
Section2:Button({Title="Server Hop (Small Server)",Callback=function()
    local ok,servers=pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and servers and servers.data then
        for _,s in ipairs(servers.data) do
            if s.playing<s.maxPlayers and s.id~=game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,player)
                break
            end
        end
    end
end})
Section2:Button({Title="Server Hop (Best Ping)",Callback=function()
    local ok,servers=pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and servers and servers.data then
        local bestServer=nil
        local lowestPing=math.huge
        for _,s in ipairs(servers.data) do
            if s.playing<s.maxPlayers and s.id~=game.JobId and s.ping and s.ping<lowestPing then
                lowestPing=s.ping
                bestServer=s
            end
        end
        if bestServer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId,bestServer.id,player)
        end
    end
end})

local Section1 = TabPlayer:Section({
    Title = "anti",
    Icon = "server",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section1:Toggle({Title="Anti Void",Callback=function(s) antiVoidEnabled=s end})
Section1:Toggle({Title="Anti Knockback",Callback=function(state)
    antiKnockbackEnabled=state
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if state then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        if knockbackConn then knockbackConn:Disconnect() end
        knockbackConn=root.ChildAdded:Connect(function(c) if antiKnockbackEnabled and (c:IsA("BodyVelocity") or c:IsA("BodyGyro") or c:IsA("BodyForce") or c:IsA("VectorForce")) then task.defer(function() if c.Parent then c:Destroy() end end) end end)
    else hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true); if knockbackConn then knockbackConn:Disconnect() knockbackConn=nil end end
end})
Section1:Toggle({Title="Anti Ragdoll",Callback=function(s) antiRagdollEnabled=s end})
Section1:Toggle({Title="Anti Fling",Callback=function(s) antiFlingEnabled=s end})
Section1:Toggle({Title="Anti AFK",Callback=function(state)
    antiAfkEnabled=state; lastMoveTime=tick()
    if state then task.spawn(function() while antiAfkEnabled do task.wait(30); if tick()-lastMoveTime>=900 then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()); lastMoveTime=tick() end end end) end
end})

local Section2 = TabPlayer:Section({
    Title = "Animation Player",
    Icon = "user",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Toggle({Title="Egor",Callback=function(state)
    egorEnabled=state
end})
Section2:Toggle({Title="Player No Animation",Callback=function(state)
    noAnimationEnabled=state
end})
Section2:Toggle({Title="Freeze Open",Callback=function(state)
    freezePlayerEnabled=state
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored=state
    end
end})
Section2:Toggle({Title="Fake Lag",Callback=function(state)
    fakeLagEnabled=state
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if state then
            workspace.Gravity = 0
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        else
            workspace.Gravity = 196.2
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end})
Section2:Divider()
Section2:Toggle({Title="Flash",Callback=function(state)
    flashEnabled=state
    if state then task.spawn(function() while flashEnabled do local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame=r.CFrame+r.CFrame.RightVector*flashDistance*flashDir; flashDir=-flashDir end; task.wait(flashSpeed) end end) end
end})
Section2:Input({Title="Flash Speed",Value="0.1",Callback=function(v) flashSpeed=tonumber(v) or 0.1 end})
Section2:Input({Title="Flash Distance",Value="6",Callback=function(v) flashDistance=tonumber(v) or 6 end})
Section2:Divider()
Section2:Toggle({Title="Spin",Callback=function(s) spinEnabled=s end})
Section2:Input({Title="Spin Speed",Value="1",Callback=function(v) spinSpeedInput=tonumber(v) or 1 end})

local Section2 = TabPlayer:Section({
    Title = "music visual",
    Icon = "music-2",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

local Input = Section2:Input({
    Title = "id music",
    Desc = "Enter your id music roblox assets",
    Value = "142376088",
    Callback = function(text)
        local idOnly = string.match(text, "%d+")
        if idOnly then
            currentMusicId = idOnly
        else
            currentMusicId = text
        end
    end
})

Section2:Button({
    Title = "start music id",
    Desc = "single music",
    Icon = "mouse-pointer-click",
    IconAlign = "Right", 
    Callback = function()
        if currentMusicId == "" then
            return
        end
        musicSound:Stop()
        musicSound.SoundId = "rbxassetid://" .. currentMusicId
        musicSound:Play()
    end
})

Section2:Button({
    Title = "stop music",
    Desc = "stop current music",
    Icon = "pause",
    IconAlign = "Right",
    Callback = function()
        musicSound:Stop()
    end
})

local Toggle = Section2:Toggle({
    Title = "loop music",
    Desc = "loop music id",
    Callback = function(state)
        musicSound.Looped = state
    end
})

local Section1 = TabTroll:Section({
    Title = "visual map",
    Icon = "boxes",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section1:Toggle({Title="Rainbow Workspace",Callback=function(state)
    rainbowWorkspaceEnabled=state
    if state then originalPartColors={}; for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name~="FollowerPart" and obj.Name~="FreecamPart" then originalPartColors[obj]=obj.Color end end
    else for p,c in pairs(originalPartColors) do if p and p.Parent then p.Color=c end end; originalPartColors={} end
end})
Section1:Slider({Title="Rainbow Speed",Step=0.1,Value={Min=0.1,Max=5,Default=1},Callback=function(v) rainbowWorkspaceSpeed=v end})
Section1:Divider()
Section1:Toggle({Title="Hell Mode",Callback=function(state)
    hellEnabled=state
    if state then hellOriginal={}; hellFires={}
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name~="FollowerPart" and obj.Name~="FreecamPart" and not obj:IsDescendantOf(player.Character) then
                hellOriginal[obj]={Color=obj.Color,Material=obj.Material}
                if obj.Material==Enum.Material.Wood or obj.Material==Enum.Material.WoodPlanks then obj.Color=Color3.new(0,0,0)
                else obj.Material=Enum.Material.Neon; obj.Color=Color3.fromRGB(255,math.random(0,100),0) end
                local sizeMag=obj.Size.Magnitude; local fireCount=1
                if sizeMag>20 then fireCount=4 elseif sizeMag>12 then fireCount=3 elseif sizeMag>6 then fireCount=2 end
                hellFires[obj]={}
                for i=1,fireCount do local f=Instance.new("Fire"); f.Heat=math.random(8,15); f.Size=math.clamp(sizeMag*0.4,2,20); f.Color=Color3.fromRGB(255,100,0); f.SecondaryColor=Color3.fromRGB(255,200,0); f.Parent=obj; table.insert(hellFires[obj],f) end
            end
        end
    else for p,data in pairs(hellOriginal) do if p and p.Parent then p.Color=data.Color; p.Material=data.Material end end; hellOriginal={}; for _,fires in pairs(hellFires) do for _,f in ipairs(fires) do if f then f:Destroy() end end end; hellFires={} end
end})
local Section2 = TabTroll:Section({
    Title = "troll",
    Icon = "user",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section2:Button({
    Title = "touch fling",
    Desc = "Btw this script by icarus community", -- optional
    Icon = "mouse-pointer-click", -- lucide icon or "rbxassetid://". optional
    IconAlign = "Right", -- "Left" or "Right". optional
    Callback = function()
        WindUI:Notify({Title = "Success execute",Content = "Wait until it has been executed.",Icon = "info",optionalDuration = 2,})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))()
    end
})

local conn

Section2:Toggle({
	Title = "anti kill brick",
	Value = false,
	Callback = function(state)
		if state then
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					pcall(function() v.CanTouch = false end)
				end
			end
			conn = workspace.DescendantAdded:Connect(function(v)
				if v:IsA("BasePart") then
					task.wait()
					pcall(function() v.CanTouch = false end)
				end
			end)
		else
			if conn then conn:Disconnect() conn = nil end
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					pcall(function() v.CanTouch = true end)
				end
			end
		end
	end
})

UserInputService.JumpRequest:Connect(function() if infJumpEnabled then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
UserInputService.InputBegan:Connect(function() lastMoveTime=tick() end)
RunService.Heartbeat:Connect(function() local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum and hum.MoveDirection.Magnitude>0 then lastMoveTime=tick() end end)

Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(function() task.wait(1) CreateESP(plr) end) end)
Players.PlayerRemoving:Connect(ClearESP)
for _,plr in pairs(Players:GetPlayers()) do if plr~=player then CreateESP(plr) end end

task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = os.clock()
        if currentTime - lastTime >= 1 then
            currentFpsValue = frameCount
            frameCount = 0
            lastTime = currentTime
        end
    end)
    while task.wait(1) do
        if serverInfoEnabled and serverInfoParagraph then
            local pCount = #Players:GetPlayers()
            pcall(function()
                serverInfoParagraph:SetDesc("player = " .. tostring(pCount) .. "\nfps = " .. tostring(currentFpsValue))
            end)
            pcall(function()
                serverInfoParagraph:Set({
                    Title = "information server",
                    Desc = "player = " .. tostring(pCount) .. "\nfps = " .. tostring(currentFpsValue)
                })
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local cam=workspace.CurrentCamera; local rainbowCol=Color3.fromHSV((tick()*rainbowSpeed)%1,1,1)
    for plr,obj in pairs(ESP_Objects) do
        local char=plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char:FindFirstChild("Head") then
            local hrp=char.HumanoidRootPart; local hum=char.Humanoid; local head=char.Head
            if obj.Billboard then obj.Billboard.Adornee=hrp; obj.Billboard.Enabled=true; obj.NameLbl.Visible=States.NameESP; obj.NameLbl.Text=plr.Name; obj.NameLbl.TextColor3=rainbowESPEnabled and rainbowCol or Color3.new(1,1,1)
                local dist=player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position-player.Character.HumanoidRootPart.Position).Magnitude or 0
                obj.DistLbl.Visible=States.DistanceESP or States.HealthNumber; local txt=""; if States.DistanceESP then txt=txt..string.format("[%dm] ",math.floor(dist)) end; if States.HealthNumber then txt=txt..string.format("%d HP",math.floor(hum.Health)) end; obj.DistLbl.Text=txt; obj.DistLbl.TextColor3=rainbowESPEnabled and rainbowCol or Color3.new(1,1,1) end
            if obj.Box3D then obj.Box3D.Adornee=hrp; obj.Box3D.Visible=States.Box3D; obj.Box3D.Color3=rainbowESPEnabled and rainbowCol or Color3.fromRGB(0,255,0) end
            local rootPos,vis=cam:WorldToViewportPoint(hrp.Position)
            if vis and (States.Box2D or States.Tracers) then
                local headPos=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0)); local legPos=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
                local height=math.abs(headPos.Y-legPos.Y); local width=height*0.6
                if States.Box2D then 
                    if drawingSupported then
                        if not obj.Drawings.Box then obj.Drawings.Box=Drawing.new("Square") end; obj.Drawings.Box.Visible=true; obj.Drawings.Box.Size=Vector2.new(width,height); obj.Drawings.Box.Position=Vector2.new(rootPos.X-width/2,headPos.Y); obj.Drawings.Box.Color=rainbowESPEnabled and rainbowCol or Color3.new(0,1,0); obj.Drawings.Box.Thickness=espThickness; obj.Drawings.Box.Filled=false 
                    else
                        if not obj.FallbackDrawings.Box then
                            local b = Instance.new("Frame")
                            b.BackgroundTransparency = 1
                            b.BorderSizePixel = 0
                            local stroke = Instance.new("UIStroke")
                            stroke.Parent = b
                            b.Parent = FallbackGui
                            obj.FallbackDrawings.Box = b
                        end
                        local b = obj.FallbackDrawings.Box
                        b.Visible = true
                        b.Size = UDim2.fromOffset(width, height)
                        b.Position = UDim2.fromOffset(rootPos.X - width/2, headPos.Y)
                        b.UIStroke.Color = rainbowESPEnabled and rainbowCol or Color3.new(0,1,0)
                        b.UIStroke.Thickness = espThickness
                    end
                else 
                    if obj.Drawings.Box then obj.Drawings.Box.Visible=false end 
                    if obj.FallbackDrawings.Box then obj.FallbackDrawings.Box.Visible=false end
                end
                if States.Tracers then 
                    if drawingSupported then
                        if not obj.Drawings.Tracer then obj.Drawings.Tracer=Drawing.new("Line") end; obj.Drawings.Tracer.Visible=true; obj.Drawings.Tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y); obj.Drawings.Tracer.To=Vector2.new(rootPos.X,rootPos.Y); obj.Drawings.Tracer.Color=rainbowESPEnabled and rainbowCol or Color3.new(0,1,0); obj.Drawings.Tracer.Thickness=espThickness 
                    else
                        if not obj.FallbackDrawings.Tracer then
                            local t = Instance.new("Frame")
                            t.AnchorPoint = Vector2.new(0.5, 0.5)
                            t.BorderSizePixel = 0
                            t.Parent = FallbackGui
                            obj.FallbackDrawings.Tracer = t
                        end
                        local t = obj.FallbackDrawings.Tracer
                        local from = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        local to = Vector2.new(rootPos.X, rootPos.Y)
                        local m = (to - from)
                        t.Visible = true
                        t.Size = UDim2.fromOffset(espThickness, m.Magnitude)
                        t.Position = UDim2.fromOffset(from.X + m.X/2, from.Y + m.Y/2)
                        t.Rotation = math.deg(math.atan2(m.Y, m.X)) - 90
                        t.BackgroundColor3 = rainbowESPEnabled and rainbowCol or Color3.new(0,1,0)
                    end
                else 
                    if obj.Drawings.Tracer then obj.Drawings.Tracer.Visible=false end 
                    if obj.FallbackDrawings.Tracer then obj.FallbackDrawings.Tracer.Visible=false end
                end
                if States.HealthBar then
                    if drawingSupported then
                        if not obj.Drawings.HealthBar then obj.Drawings.HealthBar = Drawing.new("Square") end
                        obj.Drawings.HealthBar.Visible = true
                        local barHeight = height
                        local barWidth = 4
                        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        obj.Drawings.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPct)
                        obj.Drawings.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 6, headPos.Y + barHeight * (1 - healthPct))
                        obj.Drawings.HealthBar.Color = Color3.fromRGB(255 * (1-healthPct), 255 * healthPct, 0)
                        obj.Drawings.HealthBar.Filled = true
                        obj.Drawings.HealthBar.Thickness = 1
                    else
                        if not obj.FallbackDrawings.HealthBar then
                            local hb = Instance.new("Frame")
                            hb.BorderSizePixel = 0
                            hb.Parent = FallbackGui
                            obj.FallbackDrawings.HealthBar = hb
                        end
                        local hb = obj.FallbackDrawings.HealthBar
                        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        hb.Visible = true
                        hb.Size = UDim2.fromOffset(4, height * healthPct)
                        hb.Position = UDim2.fromOffset(rootPos.X - width/2 - 6, headPos.Y + height * (1 - healthPct))
                        hb.BackgroundColor3 = Color3.fromRGB(255 * (1-healthPct), 255 * healthPct, 0)
                    end
                else
                    if obj.Drawings.HealthBar then obj.Drawings.HealthBar.Visible = false end
                    if obj.FallbackDrawings.HealthBar then obj.FallbackDrawings.HealthBar.Visible = false end
                end
            else 
                if obj.Drawings.Box then obj.Drawings.Box.Visible=false end; if obj.Drawings.Tracer then obj.Drawings.Tracer.Visible=false end 
                if obj.FallbackDrawings.Box then obj.FallbackDrawings.Box.Visible=false end; if obj.FallbackDrawings.Tracer then obj.FallbackDrawings.Tracer.Visible=false end
            end

            if States.SkeletonESP and char then
                if obj.CharmHL then obj.CharmHL.Adornee = char; obj.CharmHL.Enabled = true; obj.CharmHL.FillColor = rainbowESPEnabled and rainbowCol or Color3.fromRGB(255,255,255) end
                local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                local bones = isR15 and {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                } or {
                    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
                    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                }
                for _, b in ipairs(bones) do
                    local p1 = char:FindFirstChild(b[1])
                    local p2 = char:FindFirstChild(b[2])
                    local lName = "Bone_" .. b[1] .. "_" .. b[2]
                    if p1 and p2 then
                        local pos1, v1 = cam:WorldToViewportPoint(p1.Position)
                        local pos2, v2 = cam:WorldToViewportPoint(p2.Position)
                        if v1 and v2 then
                            if drawingSupported then
                                if not obj.Drawings[lName] then obj.Drawings[lName] = Drawing.new("Line") end
                                local l = obj.Drawings[lName]
                                l.Visible = true
                                l.From = Vector2.new(pos1.X, pos1.Y)
                                l.To = Vector2.new(pos2.X, pos2.Y)
                                l.Color = rainbowESPEnabled and rainbowCol or Color3.new(1,1,1)
                                l.Thickness = espThickness
                            else
                                if not obj.FallbackDrawings[lName] then
                                    local f = Instance.new("Frame")
                                    f.AnchorPoint = Vector2.new(0.5, 0.5)
                                    f.BorderSizePixel = 0
                                    f.Parent = FallbackGui
                                    obj.FallbackDrawings[lName] = f
                                end
                                local f = obj.FallbackDrawings[lName]
                                local from = Vector2.new(pos1.X, pos1.Y)
                                local to = Vector2.new(pos2.X, pos2.Y)
                                local m = (to - from)
                                f.Visible = true
                                f.Size = UDim2.fromOffset(espThickness, m.Magnitude)
                                f.Position = UDim2.fromOffset(from.X + m.X/2, from.Y + m.Y/2)
                                f.Rotation = math.deg(math.atan2(m.Y, m.X)) - 90
                                f.BackgroundColor3 = rainbowESPEnabled and rainbowCol or Color3.new(1,1,1)
                            end
                        else
                            if obj.Drawings[lName] then obj.Drawings[lName].Visible = false end
                            if obj.FallbackDrawings[lName] then obj.FallbackDrawings[lName].Visible = false end
                        end
                    else
                        if obj.Drawings[lName] then obj.Drawings[lName].Visible = false end
                        if obj.FallbackDrawings[lName] then obj.FallbackDrawings[lName].Visible = false end
                    end
                end
            else
                if obj.CharmHL then obj.CharmHL.Enabled = false end
                for k, d in pairs(obj.Drawings) do if k:sub(1, 5) == "Bone_" then pcall(function() d.Visible = false end) end end
                if obj.FallbackDrawings then
                    for k, d in pairs(obj.FallbackDrawings) do if k:sub(1, 5) == "Bone_" then d.Visible = false end end
                end
            end
        else 
            if obj.Billboard then obj.Billboard.Enabled=false end; if obj.Box3D then obj.Box3D.Visible=false end 
        end
    end
    if rainbowWorkspaceEnabled then local col=Color3.fromHSV((tick()*rainbowWorkspaceSpeed)%1,1,1); for p,_ in pairs(originalPartColors) do if p and p.Parent then p.Color=col end end end
    if followPartEnabled and followPartModel and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        followAnimTime=followAnimTime+dt
        local root=player.Character.HumanoidRootPart; local basePos=root.Position
        if followShape=="Tornado" then
            if tick() - tornadoLastSwitch > 3 then
                local others={}
                for _,plr in pairs(Players:GetPlayers()) do if plr~=player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then table.insert(others,plr.Character.HumanoidRootPart.Position) end end
                if #others>0 then
                    local targetPos = others[math.random(1,#others)]
                    tornadoTarget = basePos + (targetPos - basePos).Unit * math.random(20,60) + Vector3.new(math.random(-30,30),0,math.random(-30,30))
                else
                    tornadoTarget = basePos + Vector3.new(math.random(-50,50),0,math.random(-50,50))
                end
                tornadoLastSwitch = tick()
            end
            tornadoCenter = tornadoCenter:Lerp(tornadoTarget, dt*0.3)
            local parts=followPartModel:GetChildren()
            for i,part in ipairs(parts) do
                if part:IsA("BasePart") then
                    local t = tick()*4 + i*0.3
                    local height = (i % 30) * 2.5
                    local radius = 5 + height*0.6 + math.sin(t*0.5)*2
                    local angle = t + height*0.2
                    local x = math.cos(angle)*radius
                    local z = math.sin(angle)*radius
                    local y = height - 15 + math.sin(t*0.7)*1.5
                    local windOffset = Vector3.new(math.sin(t*1.3)*2,0,math.cos(t*1.1)*2)
                    part.CFrame = CFrame.new(tornadoCenter + Vector3.new(x,y,z) + windOffset)
                    part.Size = Vector3.new(3,3,3)
                    part.Color = Color3.fromRGB(120,120,120)
                    part.Material = Enum.Material.Glass
                    part.Transparency = 0.4
                end
            end
        elseif followShape=="Ring" then
            local count=#followPartModel:GetChildren()
            for i,part in ipairs(followPartModel:GetChildren()) do
                if part:IsA("BasePart") then
                    local angle = tick()*2 + (i*math.pi*2/count)
                    local pos = basePos + Vector3.new(math.cos(angle)*followRadius, math.sin(tick()*3 + i)*0.5, math.sin(angle)*followRadius)
                    part.CFrame = CFrame.new(pos)
                    part.Color = Color3.fromRGB(0,212,255)
                    part.Material = Enum.Material.Neon
                    part.Transparency = 0
                end
            end
        else
            for i,part in ipairs(followPartModel:GetChildren()) do
                if part:IsA("BasePart") then
                    local radius = 500
                    local angle = (i*137.5)%360
                    local x = math.cos(math.rad(angle))*radius*math.random()
                    local z = math.sin(math.rad(angle))*radius*math.random()
                    local y = 50 - (tick()*20 + i*5)%100
                    part.CFrame = CFrame.new(basePos + Vector3.new(x,y,z))
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function(_,dt)
    local char=player.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid"); if not root or not hum then return end
    if noclipEnabled then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    if not flyEnabled and not freecamPart then
        if speedEnabled then hum.WalkSpeed = walkSpeedPower else hum.WalkSpeed = 16 end
        if hum.WalkSpeed == 16 then hum:SetAttribute('WalkAnimSpeed', 2.5) else hum:SetAttribute('WalkAnimSpeed', 1) end
        if jumpEnabled then hum.JumpPower = jumpPower else hum.JumpPower = 50 end
    end
    if egorEnabled then
        for _,track in pairs(hum:GetPlayingAnimationTracks()) do
            if track.Name:lower():find("walk") or track.Name:lower():find("run") then
                track:AdjustSpeed(10)
            end
        end
    end
    if noAnimationEnabled then
        for _,track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
    if flyEnabled and bVelocity and bGyro then
        hum.PlatformStand=true
        local dir=Vector3.zero
        if hum.MoveDirection.Magnitude>0 then local camCF=camera.CFrame; local rel=camCF:VectorToObjectSpace(hum.MoveDirection); dir=(camCF.LookVector*-rel.Z)+(camCF.RightVector*rel.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        bVelocity.Velocity=dir.Magnitude>0 and dir.Unit*speed or Vector3.zero
        bGyro.CFrame=CFrame.new(root.Position,root.Position+camera.CFrame.LookVector)
    end
    local voidHeight=(workspace.FallenPartsDestroyHeight or -500)+autoVoidOffset
    if root.Position.Y>voidHeight+10 then if hum.FloorMaterial~=Enum.Material.Air then lastSafeCFrame=root.CFrame end end
    if antiVoidEnabled and root.Position.Y<voidHeight then if lastSafeCFrame then root.CFrame=lastSafeCFrame+Vector3.new(0,3,0) else root.CFrame=CFrame.new(root.Position.X,voidHeight+100,root.Position.Z) end; root.AssemblyLinearVelocity=Vector3.zero end
    if antiRagdollEnabled then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false); hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false) end
    if antiFlingEnabled then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        for _,plr in pairs(Players:GetPlayers()) do if plr~=player and plr.Character then for _,p in pairs(plr.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
    end
    if spinEnabled then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(spinSpeedInput*10*dt*60),0) end
    
    if autoAimEnabled then
        local camPos = camera.CFrame.Position
        local function validateTarget(tgt)
            if not tgt or not tgt.Parent or not tgt.Character then return false end
            local tHum = tgt.Character:FindFirstChildOfClass("Humanoid")
            local tHrp = tgt.Character:FindFirstChild("HumanoidRootPart")
            if not tHum or tHum.Health <= 0 or not tHrp then return false end
            return true
        end

        if not validateTarget(currentAimTarget) then
            currentAimTarget = nil
            local closestPlr = nil
            local shortestDist = math.huge
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and validateTarget(plr) then
                    local hrp = plr.Character.HumanoidRootPart
                    local pos, vis = camera:WorldToViewportPoint(hrp.Position)
                    if vis then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestPlr = plr
                        end
                    end
                end
            end
            currentAimTarget = closestPlr
        end

        if currentAimTarget then
            local chosen = aimPartType
            if chosen == "Random" then
                if not playerAssignedParts[currentAimTarget] then
                    local partsList = {"Head", "Torso", "HumanoidRootPart"}
                    playerAssignedParts[currentAimTarget] = partsList[math.random(1, #partsList)]
                end
                chosen = playerAssignedParts[currentAimTarget]
            end
            
            local part = currentAimTarget.Character:FindFirstChild(chosen) or currentAimTarget.Character:FindFirstChild("HumanoidRootPart") or currentAimTarget.Character:FindFirstChild("Head")
            if part then
                local follower = currentAimTarget.Character:FindFirstChild("AimPart") or Instance.new("Part")
                follower.Name = "AimPart"
                follower.Size = Vector3.new(1, 1, 1)
                follower.Transparency = 1
                follower.CanCollide = false
                follower.Anchored = true
                follower.Parent = currentAimTarget.Character
                follower.CFrame = part.CFrame
                
                local dir = (follower.Position - camPos).Unit
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {player.Character}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local hit = workspace:Raycast(camPos, dir * 5000, params)
                if hit and hit.Instance:IsDescendantOf(currentAimTarget.Character) then
                    camera.CFrame = camera.CFrame:Lerp(CFrame.new(camPos, follower.Position), aimSmoothness)
                end
            end
        end
    else
        currentAimTarget = nil
    end

    if showGuiActive and followerPart then
        if holdUp then targetY=targetY+moveSpeed*dt end
        if holdDown then targetY=targetY-moveSpeed*dt end
        local mv=hum.MoveDirection
        followerPart.CFrame=CFrame.new(root.Position.X+mv.X*moveSpeed*dt,targetY,root.Position.Z+mv.Z*moveSpeed*dt)
        if customGui then local lbl=customGui:FindFirstChild("Main",true) and customGui.Main:FindFirstChild("YLabel"); if lbl then lbl.Text=string.format("Y: %.1f",targetY) end end
    end
end)

Window:Divider()
local Tab4=Window:Tab({Title="setting",Icon="settings"})
local Section = Tab4:Section({
    Title = "Settings ui",
    Icon = "settings",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
local Group = Section:Group({})
Group:Button({Title="refresh admin panel",Color=Color3.fromHex("#ff3030"),Justify="Right",Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/king-icarus/refs/heads/script/main/admin.lua",true))(); Window:Destroy() end})
Group:Divider()
Group:Button({Title="Delete ui",Color=Color3.fromHex("#ff3030"),Justify="Right",Callback=function() Window:Destroy() end})
local Section1 = Tab4:Section({
    Title = "update",
    Icon = "clipboard",
    Box = true,
    BoxBorder = true,
    Opened = true,
})
Section1:Paragraph({
    Title = "change logs",
    Desc = "• the mega update\n• new ui\n• add change logs\n• move a element\n• add 3 fueture touchfling,anti kill brick and music"
})
