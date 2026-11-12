-- MASTER SCRIPT (You hold the rope)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ropeLength = 20
local myRope = nil
local targetPlayer = nil
local conn = nil

-- UI Setup
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "MasterUI"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.Text = "MASTER MENU"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Tombol START
local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(1, -40, 0, 50)
startBtn.Position = UDim2.new(0, 20, 0, 60)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startBtn.Text = "▶ START LEASH"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 16
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

-- Scroll List (Hidden by default)
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 0, 200)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Visible = false

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)

-- Tombol Stop
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
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = p.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.MouseButton1Click:Connect(function()
                startLeash(p)
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
end

local function stopLeash()
    if myRope then myRope:Destroy() end
    if conn then conn:Disconnect() end
    startBtn.Visible = true
    scroll.Visible = false
    stopBtn.Visible = false
    targetPlayer = nil
    myRope = nil
    conn = nil
end

function startLeash(target)
    if targetPlayer then return end
    targetPlayer = target
    
    startBtn.Visible = false
    scroll.Visible = false
    stopBtn.Visible = true
    
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and tHRP then
        myHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
    end
    
    local rHand = LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm")
    if not rHand then return end
    
    myRope = Instance.new("Part")
    myRope.Name = "MasterRope"
    myRope.Size = Vector3.new(0.15, 0.15, 1)
    myRope.Color = Color3.fromRGB(0, 0, 0)
    myRope.Material = Enum.Material.Neon
    myRope.Anchored = true
    myRope.CanCollide = false
    myRope.Parent = workspace
    
    conn = RunService.RenderStepped:Connect(function()
        local tHRP2 = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if not tHRP2 or not myHRP2 or not myRope or not hum then return end
        
        local startPos = rHand.Position
        local endPos = tHRP2.Position 
        local dist = (startPos - endPos).Magnitude
        
        myRope.Size = Vector3.new(0.15, 0.15, dist)
        myRope.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist/2)
        
        if dist > ropeLength then
            hum:Move((tHRP2.Position - myHRP2.Position).Unit, false)
        end
    end)
end

-- Klik START -> Munculin List
startBtn.MouseButton1Click:Connect(function()
    startBtn.Visible = false
    scroll.Visible = true
    updateList()
end)

stopBtn.MouseButton1Click:Connect(stopLeash)
