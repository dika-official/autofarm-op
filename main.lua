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

-- Menggunakan UI Library asli yang berfungsi, JANGAN diganti dengan link repo autofarm kamu
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Marco8642/science/main/ui%20libs2"))()
local example = library:CreateWindow({
    text = "DIKA CDID" -- Nama UI tetap "DIKA CDID"
})

-- Bagian Auto Fish [Event]
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
            until tick()-timer > 15 or not _G.test 
        end
        if _G.test then
            local timer = tick()
            network.RemoteEvents.Fishing:FireServer("Success")
            network.RemoteEvents.Fishing:FireServer("Reset")
            repeat task.wait()
            until tick()-timer > 2 or not _G.test 
        end
    end
end)

-- Bagian Auto Farm [Trucker] - Speed Farm
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
                task.wait(1) 
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
                
                local UpTween = TweenService:Create(TweenValue, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value=primary.CFrame+Vector3.new(0,1000,0)})
                UpTween:Play()
                UpTween.Completed:Wait()
                
                local dist = (primary.Position - workspace.Etc.Waypoint.Waypoint.Position + Vector3.new(0,1000,0)).Magnitude
                local fastTime = math.clamp(dist/650, 0.5, 8) 
                
                TweenValue.Value = car:GetPrimaryPartCFrame()
                local MainTween = TweenService:Create(TweenValue, TweenInfo.new(fastTime, Enum.EasingStyle.Linear), {Value=workspace.Etc.Waypoint.Waypoint.CFrame+Vector3.new(0,1000,0)})
                MainTween:Play()
                MainTween.Completed:Wait()
                
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
