-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

_G.speed = 300
_G.run = false

local plr = game.Players.LocalPlayer

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,250,0,260)
Frame.Position = UDim2.new(0,20,0,200)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true

-- RGB BORDER
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2

task.spawn(function()
    while task.wait() do
        UIStroke.Color = Color3.fromHSV((tick()%5)/5,1,1)
    end
end)

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "AUTO FARM V4"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- CLOSE
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150,0,0)
Close.TextColor3 = Color3.new(1,1,1)

-- BUTTON FARM
local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,0,0,50)
Button.Position = UDim2.new(0,0,0,30)
Button.Text = "START FARM"

-- SPEED
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1,0,0,40)
SpeedBox.Position = UDim2.new(0,0,0,90)
SpeedBox.Text = "300"

-- TELEPORT DEALER
local TP = Instance.new("TextButton", Frame)
TP.Size = UDim2.new(1,0,0,40)
TP.Position = UDim2.new(0,0,0,140)
TP.Text = "Teleport Dealer"

-- RESET
local Reset = Instance.new("TextButton", Frame)
Reset.Size = UDim2.new(1,0,0,40)
Reset.Position = UDim2.new(0,0,0,190)
Reset.Text = "Reset Character"

-- STATUS
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,0,230)
Status.Text = "Status: OFF"
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)

-- TWEEN
local TweenService = game:GetService("TweenService")

local function tweenTo(car, cf, speed)
    local primary = car.PrimaryPart
    local dist = (primary.Position - cf.Position).Magnitude

    local TweenValue = Instance.new("CFrameValue")
    TweenValue.Value = car:GetPrimaryPartCFrame()

    TweenValue.Changed:Connect(function()
        car:PivotTo(TweenValue.Value)
    end)

    local tween = TweenService:Create(
        TweenValue,
        TweenInfo.new(dist/speed, Enum.EasingStyle.Linear),
        {Value = cf}
    )

    tween:Play()
    tween.Completed:Wait()
end

-- AUTO FARM
local function autofarm()
    while _G.run do
        task.wait()

        pcall(function()
            local chr = plr.Character
            if not chr then return end

            local hrp = chr:FindFirstChild("HumanoidRootPart")
            local hum = chr:FindFirstChild("Humanoid")

            if hum.SeatPart == nil then
                game.ReplicatedStorage.NetworkContainer.RemoteEvents.Job:FireServer("Truck")
                task.wait(0.5)

                hrp.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot

                repeat task.wait()
                    fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                until workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
            end

            local car = workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
            if not car then return end

            if hum.SeatPart == nil then
                car.DriveSeat:Sit(hum)
                task.wait(1)
            end

            if hum.SeatPart ~= nil then
                workspace.Gravity = 0

                local primary = car.PrimaryPart
                local waypoint = workspace.Etc.Waypoint.Waypoint.CFrame

                -- STEP
                local up = primary.CFrame + Vector3.new(0,120,0)
                local mid = waypoint + Vector3.new(0,120,0)
                local slow = waypoint + Vector3.new(0,20,0)
                local down = waypoint

                tweenTo(car, up, _G.speed)
                tweenTo(car, mid, _G.speed)

                -- TURUN PELAN 🔥
                tweenTo(car, slow, 100) -- pelan
                tweenTo(car, down, 50) -- lebih pelan lagi

                task.wait(2)

                workspace.Gravity = 196
            end
        end)
    end
end

-- BUTTONS
Button.MouseButton1Click:Connect(function()
    _G.run = not _G.run
    _G.speed = tonumber(SpeedBox.Text) or 300

    if _G.run then
        Button.Text = "STOP"
        Status.Text = "Status: ON"
        task.spawn(autofarm)
    else
        Button.Text = "START"
        Status.Text = "Status: OFF"
    end
end)

TP.MouseButton1Click:Connect(function()
    plr.Character.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
end)

Reset.MouseButton1Click:Connect(function()
    plr.Character:BreakJoints()
end)

Close.MouseButton1Click:Connect(function()
    _G.run = false
    ScreenGui:Destroy()
end)
