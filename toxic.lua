-- TOXIC HUB v5 — loadstring version
-- Host this file, then run: loadstring(game:HttpGet("URL"))()
-- File must be plain .lua text (UTF-8, no BOM)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local CFG = {
    channel        = "TOXIC_HUB_V5",
    ropeLength     = 8,
    ropeThickness  = 0.22,
    ropeRestitution= 0.05,
    followDist     = 5,
    dogWalkSpeed   = 14,
    guiColor       = Color3.fromRGB(12, 12, 16),
    accentColor    = Color3.fromRGB(220, 40, 60),
    textColor      = Color3.fromRGB(235, 235, 240),
    subTextColor   = Color3.fromRGB(150, 150, 160),
    successColor   = Color3.fromRGB(45, 190, 90),
    dangerColor    = Color3.fromRGB(200, 45, 45),
}

local bus = ReplicatedStorage:FindFirstChild(CFG.channel)
if not bus then
    bus = Instance.new("Folder")
    bus.Name = CFG.channel
    bus.Parent = ReplicatedStorage
end

local function ensureEvent(name)
    local ev = bus:FindFirstChild(name)
    if not ev then
        ev = Instance.new("RemoteEvent")
        ev.Name = name
        ev.Parent = bus
    end
    return ev
end

local masterEvent = ensureEvent("MasterSync")

local S = {
    master       = nil,
    isDog        = false,
    ropeData     = nil,
    followConn   = nil,
    dogBodyBackup= nil,
    extraParts   = {},
    animTrack    = nil,
}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end
local function stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or CFG.accentColor
    s.Thickness = th or 1
    s.Parent = p
end

local gui = Instance.new("ScreenGui")
gui.Name = "TOXIC_V5"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 360, 0, 480)
win.Position = UDim2.new(0.5, -180, 0.5, -240)
win.BackgroundColor3 = CFG.guiColor
win.BorderSizePixel = 0
win.Parent = gui
corner(win, 10)
stroke(win, CFG.accentColor, 1.5)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = CFG.accentColor
header.BorderSizePixel = 0
header.Parent = win
corner(header, 10)
local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 12)
hFix.Position = UDim2.new(0, 0, 1, -12)
hFix.BackgroundColor3 = CFG.accentColor
hFix.BorderSizePixel = 0
hFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "T O X I C   H U B   v5"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -30, 0, 56)
startBtn.Position = UDim2.new(0, 15, 0, 62)
startBtn.BackgroundColor3 = CFG.successColor
startBtn.Text = "▶ START"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 18
startBtn.BorderSizePixel = 0
startBtn.Parent = win
corner(startBtn, 8)

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -30, 0, 20)
listLabel.Position = UDim2.new(0, 15, 0, 128)
listLabel.BackgroundTransparency = 1
listLabel.Text = "SERVER MEMBERS"
listLabel.TextColor3 = CFG.subTextColor
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 11
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = win
listLabel.Visible = false

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 0, 250)
scroll.Position = UDim2.new(0, 15, 0, 150)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = CFG.accentColor
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = win
scroll.Visible = false
corner(scroll, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 5)
pad.PaddingBottom = UDim.new(0, 5)
pad.PaddingLeft = UDim.new(0, 5)
pad.PaddingRight = UDim.new(0, 5)
pad.Parent = scroll

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 42)
status.Position = UDim2.new(0, 15, 0, 410)
status.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
status.Text = "press START"
status.TextColor3 = CFG.subTextColor
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.Parent = win
corner(status, 6)

local sp = Instance.new("UIPadding")
sp.PaddingLeft = UDim.new(0, 10)
sp.PaddingTop = UDim.new(0, 4)
sp.Parent = status

local function setStatus(t, c)
    status.Text = t
    status.TextColor3 = c or CFG.subTextColor
end

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, -30, 0, 40)
releaseBtn.Position = UDim2.new(0, 15, 0, 410)
releaseBtn.BackgroundColor3 = CFG.dangerColor
releaseBtn.Text = "✂ RELEASE (stop being dog)"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.TextSize = 12
releaseBtn.BorderSizePixel = 0
releaseBtn.Parent = win
releaseBtn.Visible = false
corner(releaseBtn, 7)

local playerBtns = {}

local function rebuildList()
    for _, b in pairs(playerBtns) do b:Destroy() end
    playerBtns = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 48)
        b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        b.Text = ""
        b.BorderSizePixel = 0
        b.Parent = scroll
        corner(b, 6)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 36, 0, 36)
        avatar.Position = UDim2.new(0, 6, 0.5, -18)
        avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48"
        avatar.Parent = b
        corner(avatar, 18)

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -55, 0, 22)
        nm.Position = UDim2.new(0, 48, 0, 4)
        nm.BackgroundTransparency = 1
        nm.Text = p.DisplayName
        nm.TextColor3 = CFG.textColor
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 13
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.Parent = b

        local uid = Instance.new("TextLabel")
        uid.Size = UDim2.new(1, -55, 0, 14)
        uid.Position = UDim2.new(0, 48, 0, 26)
        uid.BackgroundTransparency = 1
        uid.Text = "@" .. p.Name
        uid.TextColor3 = CFG.subTextColor
        uid.Font = Enum.Font.Gotham
        uid.TextSize = 10
        uid.TextXAlignment = Enum.TextXAlignment.Left
        uid.Parent = b

        b.MouseButton1Click:Connect(function()
            pickMaster(p)
        end)

        playerBtns[p] = b
    end

    local count = 0
    for _ in pairs(playerBtns) do count = count + 1 end
    scroll.CanvasSize = UDim2.new(0, 0, 0, count * 52 + 10)
end

local BODY_PARTS = {
    "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm",
    "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg",
    "RightUpperLeg", "RightLowerLeg",
}

local function enterDogBody()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    S.dogBodyBackup = {}

    for _, name in ipairs(BODY_PARTS) do
        local part = char:FindFirstChild(name)
        if part then
            S.dogBodyBackup[name] = part.Size
            part.Size = part.Size * Vector3.new(0.7, 0.65, 0.7)
        end
    end

    local head = char:FindFirstChild("Head")
    if head then
        local snout = Instance.new("Part")
        snout.Name = "TOXIC_SNOUT"
        snout.Size = Vector3.new(0.55, 0.45, 1.1)
        snout.Color = Color3.fromRGB(70, 60, 55)
        snout.Material = Enum.Material.SmoothPlastic
        snout.CanCollide = false
        snout.Massless = true
        snout.Parent = char
        local w = Instance.new("Weld")
        w.Part0 = head; w.Part1 = snout
        w.C0 = CFrame.new(0, -0.2, -0.95)
        w.Parent = snout
        table.insert(S.extraParts, snout)
    end

    local torso = char:FindFirstChild("LowerTorso")
    if torso then
        local tail = Instance.new("Part")
        tail.Name = "TOXIC_TAIL"
        tail.Size = Vector3.new(0.2, 0.2, 1.6)
        tail.Color = Color3.fromRGB(70, 60, 55)
        tail.Material = Enum.Material.SmoothPlastic
        tail.CanCollide = false
        tail.Massless = true
        tail.Parent = char
        local w = Instance.new("Weld")
        w.Part0 = torso; w.Part1 = tail
        w.C0 = CFrame.new(0, 0.4, 0.7) * CFrame.Angles(math.rad(-30), 0, 0)
        w.Parent = tail
        table.insert(S.extraParts, tail)
    end

    if head then
        for _, side in ipairs({ -1, 1 }) do
            local ear = Instance.new("Part")
            ear.Name = "TOXIC_EAR"
            ear.Size = Vector3.new(0.35, 0.45, 0.12)
            ear.Color = Color3.fromRGB(70, 60, 55)
            ear.Material = Enum.Material.SmoothPlastic
            ear.CanCollide = false
            ear.Massless = true
            ear.Parent = char
            local w = Instance.new("Weld")
            w.Part0 = head; w.Part1 = ear
            w.C0 = CFrame.new(side * 0.4, 0.55, 0.1) * CFrame.Angles(0, 0, math.rad(side * 15))
            w.Parent = ear
            table.insert(S.extraParts, ear)
        end
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://282574440"
    local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
    if ok and track then
        track:Play(0.2)
        S.animTrack = track
    end

    hum.WalkSpeed = CFG.dogWalkSpeed
    S.isDog = true
end

local function exitDogBody()
    if not S.isDog then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        if S.dogBodyBackup then
            for name, orig in pairs(S.dogBodyBackup) do
                local part = char:FindFirstChild(name)
                if part then part.Size = orig end
            end
        end
        for _, part in ipairs(S.extraParts) do
            if part then part:Destroy() end
        end
    end
    if S.animTrack then
        pcall(function() S.animTrack:Stop() end)
        S.animTrack = nil
    end
    S.extraParts = {}
    S.dogBodyBackup = nil
    S.isDog = false
end

local function destroyRope()
    if S.ropeData then
        if S.ropeData.att0 then S.ropeData.att0:Destroy() end
        if S.ropeData.att1 then S.ropeData.att1:Destroy() end
        if S.ropeData.rope then S.ropeData.rope:Destroy() end
        if S.ropeData.holder then S.ropeData.holder:Destroy() end
        S.ropeData = nil
    end
    if S.followConn then S.followConn:Disconnect(); S.followConn = nil end
end

local function createRope(masterHRP, myHRP)
    destroyRope()

    local holder = Instance.new("Part")
    holder.Name = "TOXIC_ROPE_HOLDER"
    holder.Size = Vector3.new(0.2, 0.2, 0.2)
    holder.Transparency = 1
    holder.CanCollide = false
    holder.Anchored = true
    holder.Parent = workspace

    local att0 = Instance.new("Attachment")
    att0.Parent = masterHRP

    local att1 = Instance.new("Attachment")
    att1.Parent = myHRP

    local rope = Instance.new("RopeConstraint")
    rope.Attachment0 = att0
    rope.Attachment1 = att1
    rope.Length = CFG.ropeLength
    rope.Thickness = CFG.ropeThickness
    rope.Restitution = CFG.ropeRestitution
    rope.Color = BrickColor.new("Really black")
    rope.Visible = true
    rope.Parent = holder

    S.ropeData = { rope = rope, att0 = att0, att1 = att1, holder = holder }
end

local function startFollow(master)
    local masterHRP = master.Character and master.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not masterHRP or not myHRP then return end

    createRope(masterHRP, myHRP)

    S.followConn = RunService.Heartbeat:Connect(function()
        local mHRP = master.Character and master.Character:FindFirstChild("HumanoidRootPart")
        local myHRP2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if not mHRP or not myHRP2 or not hum then
            destroyRope()
            return
        end

        local dist = (myHRP2.Position - mHRP.Position).Magnitude
        if dist > CFG.followDist then
            local dir = (mHRP.Position - myHRP2.Position).Unit
            hum:Move(dir, false)
        end
    end)
end

function pickMaster(target)
    if S.master then
        setStatus("already leashed to " .. S.master.Name .. " — release first", CFG.dangerColor)
        return
    end

    S.master = target
    setStatus("selected master: " .. target.Name, CFG.accentColor)
    masterEvent:FireServer("pick", target)
    enterDogBody()

    task.spawn(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.CharacterAdded:Wait()
            task.wait(0.5)
        end
        startFollow(target)
        setStatus("🐕 you are now " .. target.Name .. "'s dog", CFG.successColor)
        releaseBtn.Visible = true
        listLabel.Visible = false
        scroll.Visible = false
        startBtn.Visible = true
        startBtn.Text = "✅ LEASHED"
        startBtn.BackgroundColor3 = CFG.accentColor
    end)
end

releaseBtn.MouseButton1Click:Connect(function()
    destroyRope()
    exitDogBody()
    if S.master then
        masterEvent:FireServer("release", S.master)
    end
    S.master = nil
    releaseBtn.Visible = false
    startBtn.Text = "▶ START"
    startBtn.BackgroundColor3 = CFG.successColor
    listLabel.Visible = false
    scroll.Visible = false
    setStatus("released — press START again")
end)

startBtn.MouseButton1Click:Connect(function()
    if S.master then
        setStatus("already leashed to " .. S.master.Name, CFG.dangerColor)
        return
    end
    listLabel.Visible = true
    scroll.Visible = true
    rebuildList()
    setStatus("pick a master from the list")
end)

masterEvent.OnClientEvent:Connect(function(action, fromPlayer)
    if action == "pick" and fromPlayer then
        setStatus("🐕 " .. fromPlayer.Name .. " chose you as master", CFG.accentColor)
    elseif action == "release" and fromPlayer then
        setStatus("released " .. fromPlayer.Name, CFG.subTextColor)
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    destroyRope()
    exitDogBody()
end)

_G.TOXIC_V5_CLEANUP = function()
    destroyRope()
    exitDogBody()
    gui:Destroy()
end

setStatus("press START")
print("[TOXIC HUB v5] loaded")
