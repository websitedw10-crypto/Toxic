--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              T O X I C   H U B   v8                     ║
    ║   Lightweight · Server-Side Rope · Free Move · Dance    ║
    ║   Runtime: Roblox Luau via Delta Executor               ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local CFG = {
    ropeLength     = 10,      -- مسافة الحبل (تقدر تمشي ضمنها)
    ropeThickness  = 0.2,
    ropeColor      = BrickColor.new("Really black"),
    guiColor       = Color3.fromRGB(12, 12, 16),
    accentColor    = Color3.fromRGB(220, 40, 60),
    textColor      = Color3.fromRGB(235, 235, 240),
    subTextColor   = Color3.fromRGB(150, 150, 160),
    successColor   = Color3.fromRGB(45, 190, 90),
    dangerColor    = Color3.fromRGB(200, 45, 45),
}

-- ══════════════════════════════════════════════════════
--  🔥 SERVER-SIDE ROPE INJECTION
-- ══════════════════════════════════════════════════════
local serverScriptCode = [[
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local comm = ReplicatedStorage:FindFirstChild("TOXIC_COMM")
    if not comm then
        comm = Instance.new("Folder")
        comm.Name = "TOXIC_COMM"
        comm.Parent = ReplicatedStorage
    end

    local ropeEvent = comm:FindFirstChild("RopeReq")
    if not ropeEvent then
        ropeEvent = Instance.new("RemoteEvent")
        ropeEvent.Name = "RopeReq"
        ropeEvent.Parent = comm
    end

    local activeRopes = {}

    local function destroyRope(dogId)
        if activeRopes[dogId] then
            local d = activeRopes[dogId]
            if d.att0 then d.att0:Destroy() end
            if d.att1 then d.att1:Destroy() end
            if d.rope then d.rope:Destroy() end
            if d.holder then d.holder:Destroy() end
            activeRopes[dogId] = nil
        end
    end

    ropeEvent.OnServerEvent:Connect(function(player, action, targetPlayer, myPlayer, ropeLen)
        if action == "attach" then
            destroyRope(myPlayer.UserId)
            local myChar = myPlayer.Character
            local targetChar = targetPlayer and targetPlayer.Character
            if not myChar or not targetChar then return end
            
            local myHead = myChar:FindFirstChild("Head")
            local targetHand = targetChar:FindFirstChild("RightHand") or targetChar:FindFirstChild("Right Arm")
            if not myHead or not targetHand then return end

            local holder = Instance.new("Part")
            holder.Name = "GLOBAL_ROPE"
            holder.Size = Vector3.new(0.1, 0.1, 0.1)
            holder.Transparency = 1
            holder.CanCollide = false
            holder.Anchored = true
            holder.Parent = workspace

            local att0 = Instance.new("Attachment")
            att0.Position = (targetHand.Name == "RightHand") and Vector3.new(0, -0.5, 0) or Vector3.new(0, -1, 0)
            att0.Parent = targetHand

            local att1 = Instance.new("Attachment")
            att1.Position = Vector3.new(0, -1, 0)
            att1.Parent = myHead

            local rope = Instance.new("RopeConstraint")
            rope.Attachment0 = att0
            rope.Attachment1 = att1
            rope.Length = ropeLen or 10
            rope.Thickness = 0.2
            rope.Color = BrickColor.new("Really black")
            rope.Visible = true
            rope.Parent = holder

            activeRopes[myPlayer.UserId] = {holder = holder, att0 = att0, att1 = att1, rope = rope}
        elseif action == "detach" then
            destroyRope(myPlayer.UserId)
        end
    end)
]]

-- تنفيذ سكريبت السيرفر (إذا المدخل يدعم Server-Side)
task.spawn(function()
    local ss = game:GetService("ServerScriptService")
    local success = pcall(function()
        local s = Instance.new("Script")
        s.Name = "TOXIC_ROPE_SERVER"
        s.Source = serverScriptCode
        s.Parent = ss
    end)
    if not success then
        -- fallback: client-side rope if no server exec
        warn("[TOXIC] Server injection failed. Rope will be local only.")
    end
end)

-- ══════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════
local commFolder = ReplicatedStorage:FindFirstChild("TOXIC_COMM") or ReplicatedStorage:WaitForChild("TOXIC_COMM", 3)
local ropeReq = commFolder and commFolder:FindFirstChild("RopeReq")

local S = {
    master     = nil,
    localRope  = nil, -- fallback client-side rope
    minimized  = false,
    danceTrack = nil,
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

-- ══════════════════════════════════════════════════════
--  GUI BUILD
-- ══════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TOXIC_V8"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

-- Mini Bar
local miniBar = Instance.new("Frame")
miniBar.Size = UDim2.new(0, 200, 0, 36)
miniBar.Position = UDim2.new(0.5, -100, 0.5, -18)
miniBar.BackgroundColor3 = CFG.guiColor
miniBar.BorderSizePixel = 0
miniBar.Visible = false
miniBar.Parent = gui
corner(miniBar, 8); stroke(miniBar)

local miniName = Instance.new("TextLabel")
miniName.Size = UDim2.new(1, -70, 1, 0)
miniName.Position = UDim2.new(0, 12, 0, 0)
miniName.BackgroundTransparency = 1
miniName.Text = "T O X I C"
miniName.TextColor3 = CFG.textColor
miniName.Font = Enum.Font.GothamBlack
miniName.TextSize = 13
miniName.TextXAlignment = Enum.TextXAlignment.Left
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
closeMiniBtn.Parent = miniBar
corner(closeMiniBtn, 6)

-- Main Window
local win = Instance.new("Frame")
win.Size = UDim2.new(0, 340, 0, 420)
win.Position = UDim2.new(0.5, -170, 0.5, -210)
win.BackgroundColor3 = CFG.guiColor
win.BorderSizePixel = 0
win.Parent = gui
corner(win, 10); stroke(win)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = CFG.accentColor
header.BorderSizePixel = 0
header.Parent = win
corner(header, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "T O X I C  v8"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
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

-- Buttons
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

local danceBtn = Instance.new("TextButton")
danceBtn.Size = UDim2.new(1, -30, 0, 44)
danceBtn.Position = UDim2.new(0, 15, 0, 130)
danceBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
danceBtn.Text = "💃 PLAY DANCE (Floss)"
danceBtn.TextColor3 = Color3.new(1, 1, 1)
danceBtn.Font = Enum.Font.GothamBold
danceBtn.TextSize = 13
danceBtn.BorderSizePixel = 0
danceBtn.Parent = win
danceBtn.Visible = false
corner(danceBtn, 7)

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -30, 0, 20)
listLabel.Position = UDim2.new(0, 15, 0, 185)
listLabel.BackgroundTransparency = 1
listLabel.Text = "SERVER MEMBERS"
listLabel.TextColor3 = CFG.subTextColor
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 11
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = win
listLabel.Visible = false

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 0, 180)
scroll.Position = UDim2.new(0, 15, 0, 210)
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
status.Size = UDim2.new(1, -30, 0, 36)
status.Position = UDim2.new(0, 15, 0, 370)
status.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
status.Text = "press START"
status.TextColor3 = CFG.subTextColor
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = win
corner(status, 6)
local sp = Instance.new("UIPadding")
sp.PaddingLeft = UDim.new(0, 10)
sp.Parent = status

local function setStatus(t, c) status.Text = t; status.TextColor3 = c or CFG.subTextColor end

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, -30, 0, 36)
releaseBtn.Position = UDim2.new(0, 15, 0, 370)
releaseBtn.BackgroundColor3 = CFG.dangerColor
releaseBtn.Text = "✂ RELEASE ROPE"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.TextSize = 12
releaseBtn.BorderSizePixel = 0
releaseBtn.Parent = win
releaseBtn.Visible = false
corner(releaseBtn, 6)

-- Minimize/Expand
local function minimize() win.Visible = false; miniBar.Visible = true; miniBar.Position = win.Position end
local function expand() miniBar.Visible = false; win.Visible = true; win.Position = miniBar.Position end
minimizeBtn.MouseButton1Click:Connect(minimize)
expandBtn.MouseButton1Click:Connect(expand)

-- ══════════════════════════════════════════════════════
--  ROPE LOGIC (Server + Fallback)
-- ══════════════════════════════════════════════════════
local function destroyLocalRope()
    if S.localRope then
        if S.localRope.att0 then S.localRope.att0:Destroy() end
        if S.localRope.att1 then S.localRope.att1:Destroy() end
        if S.localRope.rope then S.localRope.rope:Destroy() end
        if S.localRope.holder then S.localRope.holder:Destroy() end
        S.localRope = nil
    end
end

local function createLocalRope(master, length)
    destroyLocalRope()
    local myChar = LocalPlayer.Character
    local targetChar = master.Character
    if not myChar or not targetChar then return end
    local myHead = myChar:FindFirstChild("Head")
    local targetHand = targetChar:FindFirstChild("RightHand") or targetChar:FindFirstChild("Right Arm")
    if not myHead or not targetHand then return end

    local holder = Instance.new("Part")
    holder.Size = Vector3.new(0.1,0.1,0.1); holder.Transparency = 1; holder.Anchored = true; holder.Parent = workspace

    local att0 = Instance.new("Attachment")
    att0.Position = (targetHand.Name == "RightHand") and Vector3.new(0, -0.5, 0) or Vector3.new(0, -1, 0)
    att0.Parent = targetHand

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -1, 0)
    att1.Parent = myHead

    local rope = Instance.new("RopeConstraint")
    rope.Attachment0 = att0; rope.Attachment1 = att1
    rope.Length = length; rope.Thickness = CFG.ropeThickness
    rope.Color = CFG.ropeColor; rope.Visible = true; rope.Parent = holder

    S.localRope = { att0 = att0, att1 = att1, rope = rope, holder = holder }
end

local function attachRope(master)
    if ropeReq then
        ropeReq:FireServer("attach", master, LocalPlayer, CFG.ropeLength)
    else
        createLocalRope(master, CFG.ropeLength)
    end
end

local function detachRope()
    if ropeReq then
        pcall(function() ropeReq:FireServer("detach", nil, LocalPlayer) end)
    end
    destroyLocalRope()
end

-- ══════════════════════════════════════════════════════
--  DANCE LOGIC (Animation)
-- ══════════════════════════════════════════════════════
local function playDance()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if S.danceTrack then
        pcall(function() S.danceTrack:Stop() end)
        S.danceTrack = nil
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://5918726674" -- Floss (R15)
    local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
    if ok and track then
        track:Play(0.2)
        S.danceTrack = track
        setStatus("💃 Dancing", CFG.successColor)
        track.Stopped:Connect(function() setStatus("Rope active", CFG.accentColor) end)
    else
        setStatus("Dance failed (game blocks anims)", CFG.dangerColor)
    end
end

-- ══════════════════════════════════════════════════════
--  PLAYER LIST
-- ══════════════════════════════════════════════════════
local playerBtns = {}
local function rebuildList()
    for _, b in pairs(playerBtns) do b:Destroy() end
    playerBtns = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        b.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        b.TextColor3 = CFG.textColor
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.Parent = scroll
        corner(b, 5)
        b.MouseButton1Click:Connect(function() pickMaster(p) end)
        playerBtns[p] = b
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #playerBtns * 44 + 10)
end

-- ══════════════════════════════════════════════════════
--  ACTIONS
-- ══════════════════════════════════════════════════════
function pickMaster(target)
    if S.master then setStatus("already leashed", CFG.dangerColor) return end
    S.master = target
    setStatus("leashing to " .. target.Name .. "...", CFG.accentColor)

    attachRope(target)

    releaseBtn.Visible = true
    danceBtn.Visible = true
    listLabel.Visible = false
    scroll.Visible = false
    startBtn.Visible = false
    setStatus("🐕 leashed to " .. target.Name .. " — walk freely in " .. CFG.ropeLength .. " studs", CFG.successColor)
end

startBtn.MouseButton1Click:Connect(function()
    listLabel.Visible = true
    scroll.Visible = true
    rebuildList()
    setStatus("pick a master")
end)

releaseBtn.MouseButton1Click:Connect(function()
    detachRope()
    if S.danceTrack then pcall(function() S.danceTrack:Stop() end) end
    S.master = nil
    S.danceTrack = nil
    releaseBtn.Visible = false
    danceBtn.Visible = false
    listLabel.Visible = false
    scroll.Visible = false
    startBtn.Visible = true
    setStatus("released")
end)

danceBtn.MouseButton1Click:Connect(playDance)

local function fullStop()
    detachRope()
    if S.danceTrack then pcall(function() S.danceTrack:Stop() end) end
    gui:Destroy()
end
closeBtn.MouseButton1Click:Connect(fullStop)
closeMiniBtn.MouseButton1Click:Connect(fullStop)

_G.TOXIC_V8_CLEANUP = fullStop
setStatus("press START")
print("[TOXIC HUB v8] loaded")
