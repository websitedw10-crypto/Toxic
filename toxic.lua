--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              T O X I C   H U B   v9.4                   ║
    ║   Pure Client · UI First · Zero Injection Block         ║
    ║   Runtime: Roblox Luau via Delta Executor               ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local CFG = {
    ropeLength     = 20,      
    ropeThickness  = 0.15,
    ropeColor      = BrickColor.new("Really black"),
    guiColor       = Color3.fromRGB(12, 12, 16),
    accentColor    = Color3.fromRGB(220, 40, 60),
    textColor      = Color3.fromRGB(235, 235, 240),
    subTextColor   = Color3.fromRGB(150, 150, 160),
    successColor   = Color3.fromRGB(45, 190, 90),
    dangerColor    = Color3.fromRGB(200, 45, 45),
}

local S = { master = nil, localRope = nil, minimized = false, followConn = nil }

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

-- 🔥 BUILD GUI PERTAMA KALI (SEBELUM APA-APA)
local gui = Instance.new("ScreenGui")
gui.Name = "TOXIC_V94"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local miniBar = Instance.new("Frame")
miniBar.Size = UDim2.new(0, 200, 0, 36)
miniBar.Position = UDim2.new(0.5, -100, 0.5, -18)
miniBar.BackgroundColor3 = CFG.guiColor
miniBar.BorderSizePixel = 0
miniBar.Visible = false
miniBar.ZIndex = 10
miniBar.Parent = gui
corner(miniBar, 8); stroke(miniBar)

local miniName = Instance.new("TextLabel")
miniName.Size = UDim2.new(1, -70, 1, 0)
miniName.Position = UDim2.new(0, 12, 0, 0)
miniName.BackgroundTransparency = 1
miniName.Text = "T O X I C  v9.4"
miniName.TextColor3 = CFG.textColor
miniName.Font = Enum.Font.GothamBlack
miniName.TextSize = 13
miniName.TextXAlignment = Enum.TextXAlignment.Left
miniName.ZIndex = 11
miniName.Parent = miniBar

local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(0, 28, 0, 28)
expandBtn.Position = UDim2.new(1, -64, 0.5, -14)
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
expandBtn.Text = "−"
expandBtn.TextColor3 = CFG.textColor
expandBtn.Font = Enum.Font.GothamBlack
expandBtn.TextSize = 18
expandBtn.BorderSizePixel = 0
expandBtn.ZIndex = 11
expandBtn.Parent = miniBar
corner(expandBtn, 6)

local closeMiniBtn = Instance.new("TextButton")
closeMiniBtn.Size = UDim2.new(0, 28, 0, 28)
closeMiniBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeMiniBtn.BackgroundColor3 = CFG.dangerColor
closeMiniBtn.Text = "✕"
closeMiniBtn.TextColor3 = Color3.new(1, 1, 1)
closeMiniBtn.Font = Enum.Font.GothamBlack
closeMiniBtn.TextSize = 14
closeMiniBtn.BorderSizePixel = 0
closeMiniBtn.ZIndex = 11
closeMiniBtn.Parent = miniBar
corner(closeMiniBtn, 6)

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 340, 0, 420)
win.Position = UDim2.new(0.5, -170, 0.5, -210)
win.BackgroundColor3 = CFG.guiColor
win.BorderSizePixel = 0
win.ZIndex = 10
win.Parent = gui
corner(win, 10); stroke(win)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = CFG.accentColor
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = win
corner(header, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "T O X I C  v9.4"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, -16)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 45)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = 20
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 12
minimizeBtn.Parent = header
corner(minimizeBtn, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 30)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 12
closeBtn.Parent = header
corner(closeBtn, 6)

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Target:IsA("TextButton") or (input.Target.Parent and input.Target.Parent:IsA("TextButton")) then return end
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
makeDraggable(header); makeDraggable(miniBar)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -30, 0, 56)
startBtn.Position = UDim2.new(0, 15, 0, 62)
startBtn.BackgroundColor3 = CFG.successColor
startBtn.Text = "▶ START"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 18
startBtn.BorderSizePixel = 0
startBtn.ZIndex = 12
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
listLabel.ZIndex = 12
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
scroll.ZIndex = 12
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
status.ZIndex = 12
status.Parent = win
corner(status, 6)
local sp = Instance.new("UIPadding")
sp.PaddingLeft = UDim.new(0, 10); sp.PaddingTop = UDim.new(0, 4)
sp.Parent = status

local function setStatus(t, c) status.Text = t; status.TextColor3 = c or CFG.subTextColor end

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, -30, 0, 40)
releaseBtn.Position = UDim2.new(0, 15, 0, 410)
releaseBtn.BackgroundColor3 = CFG.dangerColor
releaseBtn.Text = "✂ RELEASE"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.TextSize = 12
releaseBtn.BorderSizePixel = 0
releaseBtn.ZIndex = 12
releaseBtn.Parent = win
releaseBtn.Visible = false
corner(releaseBtn, 7)

local function minimize() win.Visible = false; miniBar.Visible = true; miniBar.Position = win.Position end
local function expand() miniBar.Visible = false; win.Visible = true; win.Position = miniBar.Position end
minimizeBtn.MouseButton1Click:Connect(minimize)
expandBtn.MouseButton1Click:Connect(expand)

-- ROPE & BOUNDARY PULL (CLIENT-SIDE ONLY)
local function destroyLocalRope()
    if S.localRope then
        if S.localRope.att0 then S.localRope.att0:Destroy() end
        if S.localRope.att1 then S.localRope.att1:Destroy() end
        if S.localRope.rope then S.localRope.rope:Destroy() end
        if S.localRope.holder then S.localRope.holder:Destroy() end
        S.localRope = nil
    end
    if S.followConn then S.followConn:Disconnect(); S.followConn = nil end
end

local function startLocalRope(master)
    destroyLocalRope()
    local myChar = LocalPlayer.Character
    local targetChar = master.Character
    if not myChar or not targetChar then return end
    
    local myHead = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    local targetHand = targetChar:FindFirstChild("RightHand") or targetChar:FindFirstChild("Right Arm") or targetChar:FindFirstChild("HumanoidRootPart")
    if not myHead or not targetHand then return end

    local holder = Instance.new("Part")
    holder.Size = Vector3.new(0.1,0.1,0.1); holder.Transparency = 1; holder.Anchored = true; holder.CanCollide = false; holder.Parent = workspace

    local att0 = Instance.new("Attachment")
    if targetHand.Name == "RightHand" then att0.Position = Vector3.new(0, -0.5, 0)
    elseif targetHand.Name == "Right Arm" then att0.Position = Vector3.new(0, -1, 0)
    else att0.Position = Vector3.new(0, 0, 0) end
    att0.Parent = targetHand

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -1, 0)
    att1.Parent = myHead

    local rope = Instance.new("RopeConstraint")
    rope.Attachment0 = att0; rope.Attachment1 = att1
    rope.Length = CFG.ropeLength; rope.Thickness = CFG.ropeThickness
    rope.Color = CFG.ropeColor; rope.Visible = true; rope.Parent = holder

    S.localRope = { att0 = att0, att1 = att1, rope = rope, holder = holder }

    S.followConn = RunService.Heartbeat:Connect(function()
        local mHRP = master.Character and master.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if mHRP and myHRP and myHum then
            local dist = (myHRP.Position - mHRP.Position).Magnitude
            if dist > CFG.ropeLength then
                myHum:Move((mHRP.Position - myHRP.Position).Unit, false)
            end
        end
    end)
end

local function attachRope(master)
    startLocalRope(master)
end

local function detachRope()
    destroyLocalRope()
end

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
        b.ZIndex = 13
        b.Parent = scroll
        corner(b, 6)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 36, 0, 36)
        avatar.Position = UDim2.new(0, 6, 0.5, -18)
        avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48"
        avatar.ZIndex = 13
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
        nm.ZIndex = 13
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
        uid.ZIndex = 13
        uid.Parent = b

        b.MouseButton1Click:Connect(function() pickMaster(p) end)
        playerBtns[p] = b
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #playerBtns * 52 + 10)
end

function pickMaster(target)
    if S.master then setStatus("already leashed", CFG.dangerColor) return end
    S.master = target
    setStatus("teleporting to " .. target.Name .. "...", CFG.accentColor)

    task.spawn(function()
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetChar = target.Character
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if myHRP and targetHRP then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(5, 0, 0)
            task.wait(0.2)
            
            attachRope(target)
            
            releaseBtn.Visible = true
            listLabel.Visible = false
            scroll.Visible = false
            startBtn.Visible = false
            setStatus("🐕 leashed! walk within 20 studs.", CFG.successColor)
        else
            setStatus("failed teleport", CFG.dangerColor)
            S.master = nil
        end
    end)
end

startBtn.MouseButton1Click:Connect(function()
    if S.master then return end
    listLabel.Visible = true
    scroll.Visible = true
    rebuildList()
    setStatus("pick a master")
end)

releaseBtn.MouseButton1Click:Connect(function()
    detachRope()
    S.master = nil
    releaseBtn.Visible = false
    listLabel.Visible = false
    scroll.Visible = false
    startBtn.Visible = true
    setStatus("released")
end)

local function fullStop()
    detachRope()
    gui:Destroy()
end
closeBtn.MouseButton1Click:Connect(fullStop)
closeMiniBtn.MouseButton1Click:Connect(fullStop)

_G.TOXIC_V94_CLEANUP = fullStop
setStatus("press START")
print("[TOXIC HUB v9.4] loaded")
