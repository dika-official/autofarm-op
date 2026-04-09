-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

_G.speed = 250
_G.run = false

local plr = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

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
Title.Text = "AUTO FARM V5"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- CLOSE
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150,0,0)
Close.TextColor3 = Color3.new(1,1,1)

-- BUTTON
local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,0,0,50)
Button.Position = UDim2.new(0,0,0,30)
Button.Text = "START FARM"

-- SPEED
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1,0,0,40)
SpeedBox.Position = UDim2.new(0,0,0,90)
SpeedBox.Text = "250"

-- STATUS
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,0,140)
Status.Text = "Status: OFF"
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)

-- TWEEN
local function tweenTo(car, cf, speed)
    local primary = car.PrimaryPart
    local dist = (primary.Position - cf.Position).Magnitude

    local val = Instance.new("CFrameValue")
    val.Value = car:GetPrimaryPartCFrame()

    val.Changed:Connect(function()
        car:PivotTo(val.Value)
    end)

    local tween = TweenService:Create(val,
        TweenInfo.new(dist/speed, Enum.EasingStyle.Linear),
        {Value = cf}
    )

    tween:Play()
    tween.Completed:Wait()
end

-- RAYCAST TANAH
local function getGround(pos)
    local ray = Ray.new(pos, Vector3.new(0,-500,0))
    local part, hit = workspace:FindPartOnRay(ray)
    return hit or pos
end

-- ALIGN MOBIL
local function alignCar(car, targetCF)
    local primary = car.PrimaryPart
    local look = targetCF.LookVector
    local newCF = CFrame.new(primary.Position, primary.Position + look)
    car:PivotTo(newCF)
end

-- SMART DROP
local function smartDrop(car, waypoint)
    local primary = car.PrimaryPart
    local ground = getGround(waypoint.Position)

    local top = ground + Vector3.new(0,80,0)
    local slow = ground + Vector3.new(0,10,0)
    local final = CFrame.new(ground)

    tweenTo(car, CFrame.new(top), _G.speed)

    alignCar(car, waypoint)

    tweenTo(car, CFrame.new(slow), 80)
    tweenTo(car, final, 40)

    for i = 1,8 do
        task.wait(0.1)
        car:PivotTo(car.PrimaryPart.CFrame - Vector3.new(0,1.5,0))
    end

    task.wait(2)
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

                smartDrop(car, workspace.Etc.Waypoint.Waypoint.CFrame)

                workspace.Gravity = 196
            end
        end)
    end
end

-- BUTTON
Button.MouseButton1Click:Connect(function()
    _G.run = not _G.run
    _G.speed = tonumber(SpeedBox.Text) or 250

    if _G.run then
        Button.Text = "STOP"
        Status.Text = "Status: ON"
        task.spawn(autofarm)
    else
        Button.Text = "START"
        Status.Text = "Status: OFF"
    end
end)

-- CLOSE
Close.MouseButton1Click:Connect(function()
    _G.run = false
    ScreenGui:Destroy()
end)
