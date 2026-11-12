--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              T O X I C   H U B   v16.0                  ║
    ║   Server-Relay Network · Mutual Script · True Rope      ║
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
    ropeParts = {}, 
    minimized = false, 
    followConn = nil,
    acceptGui = nil,
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

-- ══════════════════════════════════════════════════════
--  🔥 SERVER RELAY SYSTEM (REMOTE EVENTS)
-- ══════════════════════════════════════════════════════
local commName = "TOXIC_NETWORK_V16"
local commFolder = ReplicatedStorage:FindFirstChild(commName)
if not commFolder then
    commFolder = Instance.new("Folder")
    commFolder.Name = commName
    commFolder.Parent = ReplicatedStorage
end

-- Kita bikin RemoteEvent untuk komunikasi antar client via server
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
local updatePos    = getEvent("UpdatePos")

-- ══════════════════════════════════════════════════════
--  🔥 BUILD GUI
-- ══════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TOXIC_V160"
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
miniName.Text = "T O X I C  v16"
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
win.Size = UDim2.new(0, 340, 0, 480)
win.Position = UDim2.new(0.5, -170, 0.5, -240)
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
title.Text = "T O X I C  v16"
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

-- TABS
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 60)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = win

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

local function createTabButton(text, isSelected)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -3, 1, 0)
    btn.BackgroundColor3 = isSelected and CFG.accentColor or Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = CFG.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = tabContainer
    corner(btn, 6)
    return btn
end

local tabMainBtn = createTabButton("MAIN", true)
local tabSelectBtn = createTabButton("SELECT TARGET", false)

-- MAIN PAGE
local pageMain = Instance.new("Frame")
pageMain.Size = UDim2.new(1, -20, 0, 350)
pageMain.Position = UDim2.new(0, 10, 0, 110)
pageMain.BackgroundTransparency = 1
pageMain.Visible = true
pageMain.Parent = win

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 60)
startBtn.Position = UDim2.new(0, 0, 0, 10)
startBtn.BackgroundColor3 = CFG.successColor
startBtn.Text = "▶ START LEASH"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 18
startBtn.BorderSizePixel = 0
startBtn.ZIndex = 12
startBtn.Parent = pageMain
corner(startBtn, 8)

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, 0, 0, 60)
releaseBtn.Position = UDim2.new(0, 0, 0, 80)
releaseBtn.BackgroundColor3 = CFG.dangerColor
releaseBtn.Text = "✂ STOP LEASH"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBlack
releaseBtn.TextSize = 18
releaseBtn.BorderSizePixel = 0
releaseBtn.ZIndex = 12
releaseBtn.Parent = pageMain
releaseBtn.Visible = false
corner(releaseBtn, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 60)
status.Position = UDim2.new(0, 0, 0, 160)
status.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
status.Text = "System: Ready"
status.TextColor3 = CFG.subTextColor
status.Font = Enum.Font.GothamBold
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Center
status.TextWrapped = true
status.ZIndex = 12
status.Parent = pageMain
corner(status, 6)

local function setStatus(t, c) status.Text = t; status.TextColor3 = c or CFG.subTextColor end

-- SELECT PAGE
local pageSelect = Instance.new("Frame")
pageSelect.Size = UDim2.new(1, -20, 0, 350)
pageSelect.Position = UDim2.new(0, 10, 0, 110)
pageSelect.BackgroundTransparency = 1
pageSelect.Visible = false
pageSelect.Parent = win

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 10
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

local playerBtns = {}
local function rebuildList()
    for _, b in pairs(playerBtns) do b:Destroy() end
    playerBtns = {}
    
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 55)
        b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        b.Text = ""
        b.BorderSizePixel = 0
        b.ZIndex = 13
        b.LayoutOrder = count
        b.Parent = scroll
        corner(b, 6)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 40, 0, 40)
        avatar.Position = UDim2.new(0, 8, 0.5, -20)
        avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48"
        avatar.ZIndex = 13
        avatar.Parent = b
        corner(avatar, 20)

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -60, 0, 24)
        nm.Position = UDim2.new(0, 55, 0, 6)
        nm.BackgroundTransparency = 1
        nm.Text = p.DisplayName
        nm.TextColor3 = CFG.textColor
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 14
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.ZIndex = 13
        nm.Parent = b

        local uid = Instance.new("TextLabel")
        uid.Size = UDim2.new(1, -60, 0, 16)
        uid.Position = UDim2.new(0, 55, 0, 30)
        uid.BackgroundTransparency = 1
        uid.Text = "@" .. p.Name
        uid.TextColor3 = CFG.subTextColor
        uid.Font = Enum.Font.Gotham
        uid.TextSize = 11
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

local function switchTab(tab)
    if tab == "main" then
        pageMain.Visible = true
        pageSelect.Visible = false
        tabMainBtn.BackgroundColor3 = CFG.accentColor
        tabSelectBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    else
        pageMain.Visible = false
        pageSelect.Visible = true
        tabMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tabSelectBtn.BackgroundColor3 = CFG.accentColor
        rebuildList()
    end
end

tabMainBtn.MouseButton1Click:Connect(function() switchTab("main") end)
tabSelectBtn.MouseButton1Click:Connect(function() switchTab("select") end)

-- ══════════════════════════════════════════════════════
-- 🔥 NETWORK VISUAL & LOGIC
-- ══════════════════════════════════════════════════════
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

-- دالة لبناء الحبل (بتنفذ على جهاز الشخص اللي بيستلم)
local function createRopeVisual(myChar, masterPlayer)
    destroyRope()
    S.master = masterPlayer
    S.isDog = true

    local head = myChar:FindFirstChild("Head")
    if not head then return end

    -- بناء الحبل (الخط)
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

-- ══════════════════════════════════════════════════════
-- 🔥 NETWORK LISTENERS (ANTI-CHEAT BYPASS IDEA)
-- ══════════════════════════════════════════════════════
-- 1. لو أنا مدير واخترت شخص، ببعتله طلب
function pickMaster(target)
    if S.isDog then setStatus("System: Already Leashed", CFG.dangerColor) return end
    setStatus("Sending request to " .. target.Name .. "...", CFG.accentColor)
    switchTab("main")

    -- نرسل الطلب للسيرفر عشان يوصله للشخص
    sendLeashReq:FireServer(target)
end

-- 2. الاستماع للطلبات (إذا أنا الكلب)
sendLeashReq.OnClientEvent:Connect(function(masterPlayer)
    if S.isDog then return end -- لو أنا مربوط أصلاً

    -- عرض شاشة القبول
    if S.acceptGui then S.acceptGui:Destroy() end

    local ag = Instance.new("ScreenGui")
    ag.Name = "TOXIC_ACCEPT"
    ag.ResetOnSpawn = false
    ag.Parent = game:GetService("CoreGui")
    S.acceptGui = ag

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = CFG.guiColor
    frame.BorderSizePixel = 0
    frame.Parent = ag
    corner(frame, 10)
    stroke(frame, CFG.accentColor, 2)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 50)
    t.Position = UDim2.new(0, 10, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = masterPlayer.Name .. " wants to leash you!"
    t.TextColor3 = CFG.textColor
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextWrapped = true
    t.Parent = frame

    local acc = Instance.new("TextButton")
    acc.Size = UDim2.new(0.4, 0, 0, 40)
    acc.Position = UDim2.new(0.05, 0, 0.7, 0)
    acc.BackgroundColor3 = CFG.successColor
    acc.Text = "ACCEPT"
    acc.TextColor3 = Color3.new(1, 1, 1)
    acc.Font = Enum.Font.GothamBold
    acc.Parent = frame
    corner(acc, 6)

    local rej = Instance.new("TextButton")
    rej.Size = UDim2.new(0.4, 0, 0, 40)
    rej.Position = UDim2.new(0.55, 0, 0.7, 0)
    rej.BackgroundColor3 = CFG.dangerColor
    rej.Text = "REJECT"
    rej.TextColor3 = Color3.new(1, 1, 1)
    rej.Font = Enum.Font.GothamBold
    rej.Parent = frame
    corner(rej, 6)

    acc.MouseButton1Click:Connect(function()
        ag:Destroy()
        setStatus("Accepted! Following " .. masterPlayer.Name, CFG.successColor)
        -- نبلغ السيرفر إني قبلت عشان يبني الحبل عندي وعنده
        acceptLeash:FireServer(masterPlayer, "accept")
        createRopeVisual(LocalPlayer.Character, masterPlayer)
    end)

    rej.MouseButton1Click:Connect(function()
        ag:Destroy()
        acceptLeash:FireServer(masterPlayer, "reject")
        setStatus("Rejected " .. masterPlayer.Name, CFG.dangerColor)
    end)
end)

-- 3. الاستماع للرد (إذا أنا المدير)
acceptLeash.OnClientEvent:Connect(function(dogPlayer, status)
    if status == "accept" then
        setStatus("🐕 " .. dogPlayer.Name .. " accepted!", CFG.successColor)
        -- المدير رح يشوف الحبل يطلع من رقبة الكلب
        -- الكود هنا بيبني الحبل على شاشة المدير (نفس المنطق)
        createRopeVisual(LocalPlayer.Character, dogPlayer) -- مؤقتاً، بيعتمد على الترتيب
    elseif status == "reject" then
        setStatus("❌ " .. dogPlayer.Name .. " rejected.", CFG.dangerColor)
    end
end)

startBtn.MouseButton1Click:Connect(function()
    if S.isDog then 
        setStatus("You are already leashed! Press STOP first.", CFG.dangerColor)
        return 
    end
    switchTab("select")
    setStatus("Select a target to leash", CFG.accentColor)
end)

releaseBtn.MouseButton1Click:Connect(function()
    destroyRope()
    releaseBtn.Visible = false
    startBtn.Visible = true
    setStatus("System: Ready", CFG.subTextColor)
    switchTab("main")
end)

local function minimize() win.Visible = false; miniBar.Visible = true; miniBar.Position = win.Position end
local function expand() miniBar.Visible = false; win.Visible = true; win.Position = miniBar.Position end
minimizeBtn.MouseButton1Click:Connect(minimize)
expandBtn.MouseButton1Click:Connect(expand)

local function fullStop()
    destroyRope()
    if S.acceptGui then S.acceptGui:Destroy() end
    gui:Destroy()
end
closeBtn.MouseButton1Click:Connect(fullStop)
closeMiniBtn.MouseButton1Click:Connect(fullStop)

_G.TOXIC_V160_CLEANUP = fullStop
setStatus("System: Ready")
print("[TOXIC HUB v16] loaded")
