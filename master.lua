-- MASTER SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ropeLength = 10 
local myRope = nil
local targetPlayer = nil
local conn = nil

local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "MasterUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MASTER MENU"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0.5, -15)
minBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 20
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 16
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local miniIcon = Instance.new("TextButton", gui)
miniIcon.Size = UDim2.new(0, 50, 0, 50)
miniIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
miniIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
miniIcon.Text = "T"
miniIcon.TextColor3 = Color3.new(1,1,1)
miniIcon.Font = Enum.Font.GothamBlack
miniIcon.TextSize = 24
miniIcon.Visible = false
Instance.new("UICorner", miniIcon).CornerRadius = UDim.new(0, 25)

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Target:IsA("TextButton") then return end
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
makeDraggable(header)
makeDraggable(miniIcon)

local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(1, -40, 0, 50)
startBtn.Position = UDim2.new(0, 20, 0, 60)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startBtn.Text = "▶ START LEASH"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 0, 200)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.Visible = false
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

local stopBtn = Instance.new("TextButton", mainFrame)
stopBtn.Size = UDim2.new(1, -40, 0, 40)
stopBtn.Position = UDim2.new(0, 20, 1, -50)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopBtn.Text = "✕ STOP LEASH"
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Visible = false
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)

local function updateList()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = p.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.MouseButton1Click:Connect(function() startLeash(p) end)
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0, scroll.UIListLayout.AbsoluteContentSize.Y + 10)
end

local function stopLeash()
    if myRope then myRope:Destroy() end
    if conn then conn:Disconnect() end
    startBtn.Visible = true
    scroll.Visible = false
    stopBtn.Visible = false
    targetPlayer = nil; myRope = nil; conn = nil
end

function startLeash(target)
    targetPlayer = target
    startBtn.Visible = false; scroll.Visible = false; stopBtn.Visible = true
    
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0) end
    
    myRope = Instance.new("Part")
    myRope.Size = Vector3.new(0.15, 0.15, 1)
    myRope.Color = Color3.fromRGB(0, 0, 0)
    myRope.Material = Enum.Material.Neon
    myRope.Anchored = true
    myRope.CanCollide = false
    myRope.Parent = workspace
    
    conn = RunService.RenderStepped:Connect(function()
        local rHand = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm"))
        local tHead = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")
        local tHRP2 = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not rHand or not tHead or not myHRP2 or not hum then return end
        
        local startPos = rHand.Position
        local endPos = tHead.Position + Vector3.new(0, -1, 0)
        local dist = (startPos - endPos).Magnitude
        
        myRope.Size = Vector3.new(0.15, 0.15, dist)
        myRope.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist/2)
        if dist > ropeLength then hum:Move((tHRP2.Position - myHRP2.Position).Unit, false) end
    end)
end

minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; miniIcon.Visible = true end)
miniIcon.MouseButton1Click:Connect(function() mainFrame.Visible = true; miniIcon.Visible = false end)
closeBtn.MouseButton1Click:Connect(function() stopLeash(); gui:Destroy() end)

startBtn.MouseButton1Click:Connect(function()
    startBtn.Visible = false; scroll.Visible = true; updateList()
end)
stopBtn.MouseButton1Click:Connect(stopLeash)
