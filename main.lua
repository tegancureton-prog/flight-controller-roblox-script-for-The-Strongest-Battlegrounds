-- Works for every executor! (maybe it doesnt i dont know)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Flight Engine State variables
local FlyActive = false
local FlyConnection = nil
local VelocityMover = nil
local GyroMover = nil
local FLY_SPEED = 35 

local MoveStates = {W = false, S = false, A = false, D = false}

-- 1. Core Flight Mechanics Engine Functions
local function StopOmniFly()
    FlyActive = false
    if FlyConnection then FlyConnection:Disconnect() end
    if VelocityMover then VelocityMover:Destroy() end
    if GyroMover then GyroMover:Destroy() end
    
    FlyConnection, VelocityMover, GyroMover = nil, nil, nil
    
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Standing)
        end
    end
end

local function StartOmniFly()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") or not Character:FindFirstChildOfClass("Humanoid") then return end
    local Root = Character.HumanoidRootPart
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    
    FlyActive = true
    
    VelocityMover = Instance.new("BodyVelocity")
    VelocityMover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    VelocityMover.Velocity = Vector3.new(0, 0, 0)
    VelocityMover.Parent = Root

    GyroMover = Instance.new("BodyGyro")
    GyroMover.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    GyroMover.CFrame = Camera.CFrame
    GyroMover.Parent = Root

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyActive or not Root or not Root.Parent or not VelocityMover or not GyroMover then 
            StopOmniFly()
            return 
        end
        
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        local CameraCFrame = Camera.CFrame
        local MoveVector = Vector3.new(0, 0, 0)

        if MoveStates.W then MoveVector = MoveVector + CameraCFrame.LookVector end
        if MoveStates.S then MoveVector = MoveVector - CameraCFrame.LookVector end
        if MoveStates.A then MoveVector = MoveVector - CameraCFrame.RightVector end
        if MoveStates.D then MoveVector = MoveVector + CameraCFrame.RightVector end

        if MoveVector.Magnitude > 0 then
            VelocityMover.Velocity = MoveVector.Unit * FLY_SPEED
        else
            VelocityMover.Velocity = Vector3.new(0, 0, 0)
        end
        
        GyroMover.CFrame = CameraCFrame
    end)
end

-- 2. ScreenGui Framework Construction
local TargetGuiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("RobloxGui") then
        TargetGuiParent = CoreGui
    end
end)

if TargetGuiParent:FindFirstChild("XenoFlightControlHub") then
    TargetGuiParent.XenoFlightControlHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoFlightControlHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetGuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleLabel.Text = "  FLIGHT CONTROLLER v1.0"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 210, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleButton.Text = "Flight Engine: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

local function UpdateButtonVisuals()
    if FlyActive then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        ToggleButton.Text = "Flight Engine: ACTIVE"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        ToggleButton.Text = "Flight Engine: OFF"
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    if FlyActive then StopOmniFly() else StartOmniFly() end
    UpdateButtonVisuals()
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 120, 0, 35)
SpeedLabel.Position = UDim2.new(0, 20, 0, 110)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Configure Speed:"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0, 80, 0, 35)
SpeedInput.Position = UDim2.new(0, 150, 0, 110)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedInput.Text = tostring(FLY_SPEED)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 14
SpeedInput.BorderSizePixel = 0
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

SpeedInput.FocusLost:Connect(function(enterPressed)
    local numericValue = tonumber(SpeedInput.Text)
    if numericValue and numericValue > 0 then
        FLY_SPEED = numericValue
    end
    SpeedInput.Text = tostring(FLY_SPEED)
end)

-- 3. Hardware Keyboard Listener Mappings
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.H then
        if FlyActive then StopOmniFly() else StartOmniFly() end
        UpdateButtonVisuals()
    elseif input.KeyCode == Enum.KeyCode.W then MoveStates.W = true
    elseif input.KeyCode == Enum.KeyCode.S then MoveStates.S = true
    elseif input.KeyCode == Enum.KeyCode.A then MoveStates.A = true
    elseif input.KeyCode == Enum.KeyCode.D then MoveStates.D = true
    end
end)

-- FIXED SECTION: Appended missing closure blocks below
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then MoveStates.W = false
    elseif input.KeyCode == Enum.KeyCode.S then MoveStates.S = false
    elseif input.KeyCode == Enum.KeyCode.A then MoveStates.A = false
    elseif input.KeyCode == Enum.KeyCode.D then MoveStates.D = false
    end
end)
