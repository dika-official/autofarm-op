-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- SETTINGS
_G.speed = 300
_G.run = false

local plr = game.Players.LocalPlayer

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,240,0,200)
Frame.Position = UDim2.new(0,20,0,200)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true

-- RGB BORDER
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2

task.spawn(function()
    while task.wait() do
        local t = tick()
        UIStroke.Color = Color3.fromHSV((t % 5)/5, 1, 1)
    end
end)

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "AUTO FARM RGB"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- CLOSE BUTTON
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150,0,0)
Close.TextColor3 = Color3.new(1,1,1)

Close.MouseEnter:Connect(function()
    Close.BackgroundColor3 = Color3.fromRGB(200,0,0)
end)

Close.MouseLeave:Connect(function()
    Close.BackgroundColor3 = Color3.fromRGB(150,0,0)
end)

-- BUTTON
local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,0,0,50)
Button.Position = UDim2.new(0,0,0,30)
Button.Text = "START"
Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
Button.TextColor3 = Color3.new(1,1,1)

-- SPEED INPUT
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1,0,0,40)
SpeedBox.Position = UDim2.new(0,0,0,90)
SpeedBox.Text = "300"
SpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
SpeedBox.TextColor3 = Color3.new(1,1,1)

-- STATUS
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,0,140)
Status.Text = "Status: OFF"
Status.TextColor3 = Color3.new(1,1,1)
Status.BackgroundTransparency = 1

-- TWEEN FUNCTION
local function tweenTo(car, cf)
    local primary = car.PrimaryPart
    if not primary then return end

    local dist = (primary.Position - cf.Position).Magnitude

    local TweenService = game:GetService("TweenService")
    local TweenValue = Instance.new("CFrameValue")
    TweenValue.Value = car:GetPrimaryPartCFrame()

    TweenValue.Changed:Connect(function()
        car:PivotTo(TweenValue.Value)
    end)

    local tween = TweenService:Create(
        TweenValue,
        TweenInfo.new(dist/_G.speed, Enum.EasingStyle.Linear),
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
            if not hrp or not hum then return end

            -- AMBIL JOB
            if hum.SeatPart == nil then
                game:GetService("ReplicatedStorage").NetworkContainer.RemoteEvents.Job:FireServer("Truck")
                task.wait(0.5)

                hrp.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot

                repeat task.wait()
                    fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                until workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
            end

            local car = workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
            if not car then return end

            -- MASUK MOBIL
            if hum.SeatPart == nil then
                pcall(function()
                    car.DriveSeat:Sit(hum)
                end)
                task.wait(1)
            end

            -- JALAN
            if hum.SeatPart ~= nil then
                workspace.Gravity = 0

                local primary = car.PrimaryPart
                local waypoint = workspace.Etc.Waypoint.Waypoint.CFrame

                local up = primary.CFrame + Vector3.new(0,120,0)
                local mid = waypoint + Vector3.new(0,120,0)
                local down = waypoint + Vector3.new(0,5,0)

                tweenTo(car, up)
                tweenTo(car, mid)
                tweenTo(car, down)

                -- PAKSA TURUN
                for i = 1,5 do
                    task.wait(0.2)
                    car:PivotTo(car.PrimaryPart.CFrame - Vector3.new(0,3,0))
                end

                workspace.Gravity = 196
            end
        end)
    end
end

-- BUTTON CONTROL
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

-- CLOSE FUNCTION
Close.MouseButton1Click:Connect(function()
    _G.run = false
    ScreenGui:Destroy()
end)
