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

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "AUTO FARM OP V2"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,0,0,50)
Button.Position = UDim2.new(0,0,0,30)
Button.Text = "START"
Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
Button.TextColor3 = Color3.new(1,1,1)

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1,0,0,40)
SpeedBox.Position = UDim2.new(0,0,0,90)
SpeedBox.Text = "300"
SpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
SpeedBox.TextColor3 = Color3.new(1,1,1)

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,0,140)
Status.Text = "Status: OFF"
Status.TextColor3 = Color3.new(1,1,1)
Status.BackgroundTransparency = 1

-- TELEPORT DEALERSHIP (AUTO)
local function teleportDealer()
    local chr = plr.Character
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
    end
end

-- AUTO MASUK MOBIL
local function getVehicle()
    return workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
end

local function autofarm()
    while _G.run do
        task.wait()

        pcall(function()
            local chr = plr.Character
            if not chr then return end

            local hrp = chr:FindFirstChild("HumanoidRootPart")
            local hum = chr:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            -- Ambil job
            if hum.SeatPart == nil then
                game:GetService("ReplicatedStorage").NetworkContainer.RemoteEvents.Job:FireServer("Truck")
                task.wait(0.5)

                teleportDealer()

                repeat task.wait()
                    fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                until getVehicle()

                task.wait(2)
            end

            -- Masuk mobil otomatis
            if hum.SeatPart == nil and getVehicle() then
                pcall(function()
                    getVehicle().DriveSeat:Sit(hum)
                end)
            end

            -- Jalan ke waypoint
            if hum.SeatPart ~= nil then
                local car = hum.SeatPart.Parent
                local primary = car.PrimaryPart
                if not primary then return end

                workspace.Gravity = 0

                local target = workspace.Etc.Waypoint.Waypoint.CFrame + Vector3.new(0,30,0)
                local dist = (primary.Position - target.Position).Magnitude

                local TweenService = game:GetService("TweenService")
                local TweenValue = Instance.new("CFrameValue")
                TweenValue.Value = car:GetPrimaryPartCFrame()

                TweenValue.Changed:Connect(function()
                    car:PivotTo(TweenValue.Value)
                end)

                local tween = TweenService:Create(
                    TweenValue,
                    TweenInfo.new(dist/_G.speed, Enum.EasingStyle.Linear),
                    {Value = target}
                )

                tween:Play()
                tween.Completed:Wait()

                -- Anti stuck
                local old = primary.Position
                task.wait(2)
                if (primary.Position - old).Magnitude < 5 then
                    car:PivotTo(primary.CFrame + Vector3.new(0,25,0))
                end

                workspace.Gravity = 196
            end
        end)
    end
end

-- BUTTON
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
