--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              T O X I C   H U B   v16.2                  ║
    ║   Mobile UI · Draggable Header · Min/Max/Close          ║
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
    guiColor       = Color3.fromRGB(12, 12, 16),
    accentColor    = Color3.fromRGB(220, 40, 60),
    textColor      = Color3.fromRGB(235, 235, 240),
    subTextColor   = Color3.fromRGB(150, 150, 160),
    successColor   = Color3.fromRGB(45, 190, 90),
    dangerColor    = Color3.fromRGB(200, 45, 45),
}

local S = { 
    master = nil, 
    isDog = false, 
    minimized = false, 
    followConn = nil,
    targetMaster = nil
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

-- SERVER RELAY
local commName = "TOXIC_NETWORK_V162"
local commFolder = ReplicatedStorage:FindFirstChild(commName)
if not commFolder then
    commFolder = Instance.new("Folder")
    commFolder.Name = commName
    commFolder.Parent = ReplicatedStorage
end
local function getEvent(name)
    local ev = commFolder:FindFirstChild(name)
    if not ev then
        ev = Instance.new("RemoteEvent")
        ev.Name = name
        ev.Parent = commFolder
    end
    return ev
end
local sendLeashReq = getEvent("LeashReq")
local acceptLeash = getEvent("AcceptLeash")

-- ══════════════════════════════════════════════════════
--  🔥 MOBILE UI BUILD
-- ══════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TOXIC_V162"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

-- Mini Bar (buat minimized)
local miniBar = Instance.new("Frame")
miniBar.Size = UDim2.new(0, 180, 0, 36)
miniBar.Position = UDim2.new(0.5, -90, 0.5, -18)
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
miniName.Text = "T O X I C"
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

-- Main Window
local win = Instance.new("Frame")
win.Size = UDim2.new(0, 320, 0, 420) -- تصغير العرض شوي عشان يناسب شاشات الآيفون
win.Position = UDim2.new(0.5, -160, 0.5, -210)
win.BackgroundColor3 = CFG.guiColor
win.BorderSizePixel = 0
win.ZIndex = 10
win.Parent = gui
corner(win, 10); stroke(win)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = CFG.accentColor
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = win
corner(header, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "T O X I C  v16.2"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -75, 0.5, -15)
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
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
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

-- 3 TABS
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 55)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = win

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

local function createTabButton(text, isSelected)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -3, 1, 0)
    btn.BackgroundColor3 = isSelected and CFG.accentColor or Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = CFG.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = tabContainer
    corner(btn, 6)
    return btn
end

local tabMainBtn = createTabButton("MAIN", true)
local tabSelectBtn = createTabButton("TARGETS", false)
local tabReqBtn = createTabButton("REQUESTS", false)

-- MAIN PAGE
local pageMain = Instance.new("Frame")
pageMain.Size = UDim2.new(1, -20, 0, 300)
pageMain.Position = UDim2.new(0, 10, 0, 100)
pageMain.BackgroundTransparency = 1
pageMain.Visible = true
pageMain.Parent = win

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 55)
startBtn.Position = UDim2.new(0, 0, 0, 10)
startBtn.BackgroundColor3 = CFG.successColor
startBtn.Text = "▶ START LEASH"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 17
startBtn.BorderSizePixel = 0
startBtn.ZIndex = 12
startBtn.Parent = pageMain
corner(startBtn, 8)

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, 0, 0, 55)
releaseBtn.Position = UDim2.new(0, 0, 0, 75)
releaseBtn.BackgroundColor3 = CFG.dangerColor
releaseBtn.Text = "✂ STOP LEASH"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBlack
releaseBtn.TextSize = 17
releaseBtn.BorderSizePixel = 0
releaseBtn.ZIndex = 12
releaseBtn.Parent = pageMain
releaseBtn.Visible = false
corner(releaseBtn, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 50)
status.Position = UDim2.new(0, 0, 0, 145)
status.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
status.Text = "System: Ready"
status.TextColor3 = CFG.subTextColor
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Center
status.TextWrapped = true
status.ZIndex = 12
status.Parent = pageMain
corner(status, 6)

local function setStatus(t, c) status.Text = t; status.TextColor3 = c or CFG.subTextColor end

-- SELECT PAGE
local pageSelect = Instance.new("Frame")
pageSelect.Size = UDim2.new(1, -20, 0, 300)
pageSelect.Position = UDim2.new(0, 10, 0, 100)
pageSelect.BackgroundTransparency = 1
pageSelect.Visible = false
pageSelect.Parent = win

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = CFG.accentColor
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true
scroll.ZIndex = 12
scroll.Parent = pageSelect
corner(scroll, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = scroll

-- REQUESTS PAGE
local pageReq = Instance.new("Frame")
pageReq.Size = UDim2.new(1, -20, 0, 300)
pageReq.Position = UDim2.new(0, 10, 0, 100)
pageReq.BackgroundTransparency = 1
pageReq.Visible = false
pageReq.Parent = win

local reqStatus = Instance.new("TextLabel")
reqStatus.Size = UDim2.new(1, 0, 0, 60)
reqStatus.Position = UDim2.new(0, 0, 0, 10)
reqStatus.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
reqStatus.Text = "No pending requests."
reqStatus.TextColor3 = CFG.subTextColor
reqStatus.Font = Enum.Font.Gotham
reqStatus.TextSize = 12
reqStatus.TextXAlignment = Enum.TextXAlignment.Center
reqStatus.ZIndex = 12
reqStatus.Parent = pageReq
corner(reqStatus, 6)

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0.45, 0, 0, 50)
acceptBtn.Position = UDim2.new(0.03, 0, 0, 80)
acceptBtn.BackgroundColor3 = CFG.successColor
acceptBtn.Text = "✅ ACCEPT"
acceptBtn.TextColor3 = Color3.new(1, 1, 1)
acceptBtn.Font = Enum.Font.GothamBlack
acceptBtn.TextSize = 14
acceptBtn.BorderSizePixel = 0
acceptBtn.ZIndex = 12
acceptBtn.Parent = pageReq
acceptBtn.Visible = false
corner(acceptBtn, 8)

local rejectBtn = Instance.new("TextButton")
rejectBtn.Size = UDim2.new(0.45, 0, 0, 50)
rejectBtn.Position = UDim2.new(0.52, 0, 0, 80)
rejectBtn.BackgroundColor3 = CFG.dangerColor
rejectBtn.Text = "❌ REJECT"
rejectBtn.TextColor3 = Color3.new(1, 1, 1)
rejectBtn.Font = Enum.Font.GothamBlack
rejectBtn.TextSize = 14
rejectBtn.BorderSizePixel = 0
rejectBtn.ZIndex = 12
rejectBtn.Parent = pageReq
rejectBtn.Visible = false
corner(rejectBtn, 8)

local function switchTab(tab)
    pageMain.Visible = (tab == "main")
    pageSelect.Visible = (tab == "select")
    pageReq.Visible = (tab == "req")
    
    tabMainBtn.BackgroundColor3 = (tab == "main") and CFG.accentColor or Color3.fromRGB(40, 40, 50)
    tabSelectBtn.BackgroundColor3 = (tab == "select") and CFG.accentColor or Color3.fromRGB(40, 40, 50)
    tabReqBtn.BackgroundColor3 = (tab == "req") and CFG.accentColor or Color3.fromRGB(40, 40, 50)
    
    if tab == "select" then rebuildList() end
end

tabMainBtn.MouseButton1Click:Connect(function() switchTab("main") end)
tabSelectBtn.MouseButton1Click:Connect(function() switchTab("select") end)
tabReqBtn.MouseButton1Click:Connect(function() switchTab("req") end)

-- PLAYER LIST
local playerBtns = {}
local function rebuildList()
    for _, b in pairs(playerBtns) do b:Destroy() end
    playerBtns = {}
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 50)
        b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        b.Text = ""
        b.BorderSizePixel = 0
        b.ZIndex = 13
        b.LayoutOrder = count
        b.Parent = scroll
        corner(b, 6)

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -20, 0, 24)
        nm.Position = UDim2.new(0, 10, 0, 4)
        nm.BackgroundTransparency = 1
        nm.Text = p.DisplayName
        nm.TextColor3 = CFG.textColor
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 13
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.ZIndex = 13
        nm.Parent = b

        local uid = Instance.new("TextLabel")
        uid.Size = UDim2.new(1, -20, 0, 16)
        uid.Position = UDim2.new(0, 10, 0, 26)
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
        count = count + 1
    end
    task.defer(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
end

-- 🔥 NETWORK & ROPE LOGIC
local function destroyRope()
    if S.ropePart then
        S.ropePart:Destroy()
        S.ropePart = nil
    end
    if S.followConn then
        S.followConn:Disconnect()
        S.followConn = nil
    end
    S.master = nil
    S.isDog = false
end

local function createRopeVisual(myChar, masterPlayer)
    destroyRope()
    S.master = masterPlayer
    S.isDog = true

    local head = myChar:FindFirstChild("Head")
    if not head then return end

    local ropePart = Instance.new("Part")
    ropePart.Name = "ToxicNetworkRope"
    ropePart.Size = Vector3.new(0.15, 0.15, 1)
    ropePart.Color = Color3.fromRGB(10, 10, 10)
    ropePart.Material = Enum.Material.Neon
    ropePart.CanCollide = false
    ropePart.Massless = true
    ropePart.Anchored = true
    ropePart.Parent = workspace
    S.ropePart = ropePart

    S.followConn = RunService.RenderStepped:Connect(function()
        local mHRP = masterPlayer.Character and masterPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

        if not mHRP or not cHRP or not myHum or not ropePart then return end

        local startPos = head.Position + Vector3.new(0, -1, 0)
        local endPos = mHRP.Position
        local dist = (startPos - endPos).Magnitude

        ropePart.Size = Vector3.new(0.15, 0.15, dist)
        ropePart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist / 2)

        if dist > CFG.ropeLength then
            local dir = (mHRP.Position - cHRP.Position).Unit
            myHum:Move(dir, false)
        end
    end)
end

function pickMaster(target)
    if S.isDog then setStatus("Already Leashed", CFG.dangerColor) return end
    setStatus("Request sent to " .. target.Name, CFG.accentColor)
    switchTab("main")
    sendLeashReq:FireServer(target)
end

sendLeashReq.OnClientEvent:Connect(function(masterPlayer)
    if S.isDog then return end
    S.targetMaster = masterPlayer
    reqStatus.Text = "🐕 " .. masterPlayer.Name .. " wants to leash you!"
    reqStatus.TextColor3 = CFG.accentColor
    acceptBtn.Visible = true
    rejectBtn.Visible = true
    switchTab("req")
end)

acceptBtn.MouseButton1Click:Connect(function()
    if not S.targetMaster then return end
    acceptBtn.Visible = false
    rejectBtn.Visible = false
    acceptLeash:FireServer(S.targetMaster, "accept")
    reqStatus.Text = "Leashed to " .. S.targetMaster.Name
    reqStatus.TextColor3 = CFG.successColor
    createRopeVisual(LocalPlayer.Character, S.targetMaster)
    startBtn.Visible = false
    releaseBtn.Visible = true
    setStatus("🐕 Leashed!", CFG.successColor)
    switchTab("main")
end)

rejectBtn.MouseButton1Click:Connect(function()
    if not S.targetMaster then return end
    acceptBtn.Visible = false
    rejectBtn.Visible = false
    acceptLeash:FireServer(S.targetMaster, "reject")
    reqStatus.Text = "Rejected."
    reqStatus.TextColor3 = CFG.dangerColor
    S.targetMaster = nil
end)

acceptLeash.OnClientEvent:Connect(function(dogPlayer, status)
    if status == "accept" then
        setStatus("🐕 " .. dogPlayer.Name .. " accepted!", CFG.successColor)
    elseif status == "reject" then
        setStatus("❌ " .. dogPlayer.Name .. " rejected.", CFG.dangerColor)
    end
end)

startBtn.MouseButton1Click:Connect(function()
    if S.isDog then return end
    switchTab("select")
    setStatus("Select a target", CFG.accentColor)
end)

releaseBtn.MouseButton1Click:Connect(function()
    destroyRope()
    releaseBtn.Visible = false
    startBtn.Visible = true
    setStatus("System: Ready", CFG.subTextColor)
    switchTab("main")
end)

-- MIN / MAX / CLOSE BUTTONS
local function minimize() win.Visible = false; miniBar.Visible = true; miniBar.Position = win.Position end
local function expand() miniBar.Visible = false; win.Visible = true; win.Position = miniBar.Position end
minimizeBtn.MouseButton1Click:Connect(minimize)
expandBtn.MouseButton1Click:Connect(expand)

local function fullStop()
    destroyRope()
    gui:Destroy()
end
closeBtn.MouseButton1Click:Connect(fullStop)
closeMiniBtn.MouseButton1Click:Connect(fullStop)

_G.TOXIC_V162_CLEANUP = fullStop
rebuildList()
setStatus("System: Ready")
print("[TOXIC HUB v16.2] loaded")
