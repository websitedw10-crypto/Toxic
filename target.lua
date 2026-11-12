-- TARGET SCRIPT (Her neck)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ropeLength = 20
local targetTag = "TOXIC_TARGET"
local myRope = nil
local masterPlayer = nil
local conn = nil

-- UI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "TargetUI"
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.1, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.Text = "▶ START (TARGET)"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local stopBtn = Instance.new("TextButton", gui)
stopBtn.Size = UDim2.new(0, 200, 0, 50)
stopBtn.Position = UDim2.new(0.5, -100, 0.1, 60)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopBtn.Text = "✕ STOP"
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 16
stopBtn.Visible = false
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)

local function stopLeash()
    if myRope then myRope:Destroy() end
    if conn then conn:Disconnect() end
    btn.Visible = true
    stopBtn.Visible = false
    masterPlayer = nil
    myRope = nil
    conn = nil
end

btn.MouseButton1Click:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            masterPlayer = p
            break
        end
    end
    
    if not masterPlayer then return end
    
    btn.Visible = false
    stopBtn.Visible = true
    
    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return end
    
    myRope = Instance.new("Part")
    myRope.Name = targetTag
    myRope.Size = Vector3.new(0.15, 0.15, 1)
    myRope.Color = Color3.fromRGB(0, 0, 0)
    myRope.Material = Enum.Material.Neon
    myRope.Anchored = true
    myRope.CanCollide = false
    myRope.Parent = workspace
    
    conn = RunService.RenderStepped:Connect(function()
        local mHRP = masterPlayer.Character and masterPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if not mHRP or not cHRP or not myRope or not hum then return end
        
        local startPos = myHead.Position + Vector3.new(0, -1, 0)
        local endPos = mHRP.Position
        local dist = (startPos - endPos).Magnitude
        
        myRope.Size = Vector3.new(0.15, 0.15, dist)
        myRope.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist/2)
        
        if dist > ropeLength then
            hum:Move((mHRP.Position - cHRP.Position).Unit, false)
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(stopLeash)
