-- Anti AFK
warn("Anti afk running")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    warn("Anti afk ran")
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local function dealerships()
    local tables = {"Dealerships"}
    for i,v in pairs(workspace.Etc.Dealership:GetChildren()) do
        if v.ClassName == "Model" then
            table.insert(tables,v.Name)
        end
    end
    return tables
end
getfenv().grav = workspace.Gravity

-- Menggunakan Repository milikmu untuk UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dika-official/autofarm-op/main/main.lua"))()
local example = library:CreateWindow({
    text = "DIKA CDID" -- Nama UI diganti sesuai permintaan
})

-- Bagian Auto Fish [Event] - Dioptimalkan
example:AddToggle("Auto Fish [Event]", function(state)
    _G.test = (state and true or false)
    local plr = game.Players.LocalPlayer
    local chr = plr.Character
    local network = game:GetService("ReplicatedStorage").NetworkContainer
    
    task.spawn(function()
        while _G.test do
            chr:PivotTo(workspace.Event.FishingZone.WorldPivot)
            chr.PrimaryPart.Velocity = Vector3.new(0,0,0)
            task.wait()
        end
    end)
    
    task.wait(0.5)
    while _G.test do
        task.wait()
        if _G.test then
            local timer = tick()    
            network.RemoteEvents.Fishing:FireServer("Start")
            repeat task.wait()
            until tick()-timer > 15 or not _G.test -- Dipercepat
        end
        if _G.test then
            local timer = tick()
            network.RemoteEvents.Fishing:FireServer("Success")
            network.RemoteEvents.Fishing:FireServer("Reset")
            repeat task.wait()
            until tick()-timer > 2 or not _G.test -- Delay dipangkas
        end
    end
end)

-- Bagian Auto Farm [Trucker] - Speed Farm Aktif
example:AddToggle("Auto Farm [Trucker]", function(state)
    getfenv().drive = (state and true or false)
    workspace.Gravity = 196
    if workspace.Map:FindFirstChild("Prop") then
        workspace.Map.Prop:Destroy()
    end
    
    while getfenv().drive do
        task.wait()
        pcall(function()
            if game.Players.LocalPlayer.Character.Humanoid.SeatPart == nil then
                game:GetService("ReplicatedStorage").NetworkContainer.RemoteEvents.Job:FireServer("Truck")
                task.wait(0.1)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                task.wait(1) -- Delay masuk kerja dipercepat
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                
                local prepos = workspace.Etc.Waypoint.Waypoint.Position
                repeat task.wait()
                    fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                until workspace.Etc.Waypoint.Waypoint.Position ~= prepos
                
                task.wait(0.5)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame= workspace.Etc.Job.Truck.Spawner.Part.CFrame
                task.wait(0.8)
                
                local thetruck = nil
                repeat task.wait()
                    if thetruck == nil then
                        repeat task.wait()
                            fireproximityprompt(workspace.Etc.Job.Truck.Spawner.Part.Prompt)
                        until workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name.."sCar")
                        task.wait(1)
                        for i,v in pairs(workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name.."sCar"):GetDescendants()) do
                            if v.Name == "Identifier" and (v.Text == "H 9281 KGK" or v.Text == "BL 7201 EL" or v.Text == "L 9128 TIM") then
                                thetruck = v
                            end
                        end
                    end
                until thetruck ~= nil
                
                repeat task.wait() until workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name.."sCar")
                
                repeat task.wait()
                    pcall(function()
                        if game.Players.LocalPlayer.Character.Humanoid.SeatPart == nil then
                            workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name.."sCar"):FindFirstChild("DriveSeat"):Sit(game.Players.LocalPlayer.Character.Humanoid)
                        end
                    end)
                until game.Players.LocalPlayer.Character.Humanoid.SeatPart ~= nil
                
            elseif game.Players.LocalPlayer.Character.Humanoid.SeatPart ~= nil then
                local plr = game.Players.LocalPlayer
                local chr = plr.Character
                local car = chr.Humanoid.SeatPart.Parent
                local primary = car.PrimaryPart
                workspace.Gravity = 0
                
                local TweenService = game:GetService("TweenService")
                local TweenValue = Instance.new("CFrameValue")
                TweenValue.Value = car:GetPrimaryPartCFrame()
                TweenValue.Changed:Connect(function() car:PivotTo(TweenValue.Value) end)
                
                -- Terbang ke atas (Bypass deteksi tabrakan)
                local UpTween = TweenService:Create(TweenValue, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value=primary.CFrame+Vector3.new(0,1000,0)})
                UpTween:Play()
                UpTween.Completed:Wait()
                
                -- Perjalanan Horizontal Sangat Cepat (Speed Farm)
                local dist = (primary.Position - workspace.Etc.Waypoint.Waypoint.Position + Vector3.new(0,1000,0)).Magnitude
                local fastTime = math.clamp(dist/650, 0.5, 8) -- Ditingkatkan kecepatannya ke 650 unit/detik
                
                TweenValue.Value = car:GetPrimaryPartCFrame()
                local MainTween = TweenService:Create(TweenValue, TweenInfo.new(fastTime, Enum.EasingStyle.Linear), {Value=workspace.Etc.Waypoint.Waypoint.CFrame+Vector3.new(0,1000,0)})
                MainTween:Play()
                MainTween.Completed:Wait()
                
                -- Turun ke Waypoint
                TweenValue.Value = car:GetPrimaryPartCFrame()
                local DownTween = TweenService:Create(TweenValue, TweenInfo.new(1, Enum.EasingStyle.Linear), {Value=workspace.Etc.Waypoint.Waypoint.CFrame+Vector3.new(0,30,0)})
                DownTween:Play()
                DownTween.Completed:Wait()
                
                local prepos = workspace.Etc.Waypoint.Waypoint.Position
                repeat task.wait()
                    if workspace.Etc.Waypoint.Waypoint.Position == prepos then
                        workspace.Gravity = 200
                        for i, v in pairs(car:GetDescendants()) do
                            pcall(function() v.Velocity = Vector3.new(0,0,0) end)
                        end
                        task.wait(0.5)
                    end
                until prepos ~= workspace.Etc.Waypoint.Waypoint.Position
                workspace.Gravity = 196
            end
        end)
    end
end)

-- Tab Teleport
local example2 = library:CreateWindow({
    text = "Teleports"
})

example2:AddDropdown(dealerships(),function(state) 
    if state ~= "Dealerships" then
        for i,v in pairs(workspace.Etc.Dealership:GetChildren()) do
            if v.Name == state then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.WorldPivot + Vector3.new(0,5,0)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                task.wait(0.5)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
end)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,0,0,50)
Button.Position = UDim2.new(0,0,0,30)
Button.Text = "START"

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1,0,0,40)
SpeedBox.Position = UDim2.new(0,0,0,90)
SpeedBox.Text = "230"

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

-- SCAN AREA (DETEK SEMPIT / LUAS)
local function scanArea(pos)
    local ray1 = workspace:Raycast(pos, Vector3.new(5,0,0))
    local ray2 = workspace:Raycast(pos, Vector3.new(-5,0,0))

    if ray1 or ray2 then
        return "sempit"
    else
        return "luas"
    end
end

-- AUTO PARKIR CERDAS
local function smartPark(car, waypoint)
    local primary = car.PrimaryPart
    local look = waypoint.LookVector
    local pos = waypoint.Position

    local area = scanArea(pos)

    local backOffset
    local forwardOffset

    if area == "sempit" then
        backOffset = pos - (look * 10)
        forwardOffset = pos + (look * 2)
    else
        backOffset = pos - (look * 6)
        forwardOffset = pos + (look * 4)
    end

    local top = backOffset + Vector3.new(0,80,0)

    -- NAIK
    tweenTo(car, CFrame.new(top), _G.speed)

    -- ALIGN
    car:PivotTo(CFrame.new(top, top + look))

    -- TURUN PELAN
    tweenTo(car, CFrame.new(backOffset + Vector3.new(0,5,0)), 80)
    tweenTo(car, CFrame.new(backOffset), 50)

    -- MAJU MASUK AREA 🔥
    tweenTo(car, CFrame.new(forwardOffset, forwardOffset + look), 60)

    -- NEMPEL TANAH
    for i = 1,6 do
        task.wait(0.1)
        car:PivotTo(car.PrimaryPart.CFrame - Vector3.new(0,1,0))
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

                smartPark(car, workspace.Etc.Waypoint.Waypoint.CFrame)

                workspace.Gravity = 196
            end
        end)
    end
end

-- BUTTON
Button.MouseButton1Click:Connect(function()
    _G.run = not _G.run
    _G.speed = tonumber(SpeedBox.Text) or 230

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
