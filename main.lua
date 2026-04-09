-- [[ ANTI AFK ]]
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    warn("Anti-AFK: Menghindari Kick!")
end)

-- [[ UI LIBRARY: RAYFIELD ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DIKA CDID",
   LoadingTitle = "Memuat Script Ultimate...",
   LoadingSubtitle = "Mode: Terbang & Teleport",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- [[ VARIABLES & FUNCTIONS ]]
local plr = game.Players.LocalPlayer
local network = game:GetService("ReplicatedStorage").NetworkContainer
_G.AutoFish = false
_G.AutoTruckerTween = false
_G.AutoTruckerTele = false

local function getDealerships()
    local list = {}
    for i, v in pairs(workspace.Etc.Dealership:GetChildren()) do
        if v.ClassName == "Model" then
            table.insert(list, v.Name)
        end
    end
    return list
end

-- Function buat ambil job & spawn truk (Dipakai di kedua metode)
local function SetupTruck(hum, char)
    if hum.SeatPart == nil then
        network.RemoteEvents.Job:FireServer("Truck")
        task.wait(0.1)
        char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
        char.HumanoidRootPart.Anchored = true
        task.wait(1)
        char.HumanoidRootPart.Anchored = false
        
        local prepos = workspace.Etc.Waypoint.Waypoint.Position
        repeat task.wait()
            fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
        until workspace.Etc.Waypoint.Waypoint.Position ~= prepos
        
        task.wait(0.5)
        char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Spawner.Part.CFrame
        task.wait(0.8)
        
        local thetruck = nil
        repeat task.wait()
            if thetruck == nil then
                fireproximityprompt(workspace.Etc.Job.Truck.Spawner.Part.Prompt)
                task.wait(1)
                local carsFolder = workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
                if carsFolder then
                    for i,v in pairs(carsFolder:GetDescendants()) do
                        if v.Name == "Identifier" and (v.Text == "H 9281 KGK" or v.Text == "BL 7201 EL" or v.Text == "L 9128 TIM") then
                            thetruck = v
                        end
                    end
                end
            end
        until thetruck ~= nil
        
        repeat task.wait() until workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
        
        repeat task.wait()
            pcall(function()
                local driveSeat = workspace.Vehicles:FindFirstChild(plr.Name.."sCar"):FindFirstChild("DriveSeat")
                if driveSeat and hum.SeatPart == nil then
                    driveSeat:Sit(hum)
                end
            end)
        until hum.SeatPart ~= nil
        return true
    end
    return true
end

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)
local TabTele = Window:CreateTab("Teleports", 4483345998)

-- [[ AUTO FISH SECTION ]]
TabFarm:CreateSection("Fishing Event")
TabFarm:CreateToggle({
   Name = "Auto Fish [Event]",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFish = Value
      if Value then
          task.spawn(function()
              while _G.AutoFish do
                  if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                      plr.Character:PivotTo(workspace.Event.FishingZone.WorldPivot)
                      plr.Character.PrimaryPart.Velocity = Vector3.new(0,0,0)
                  end
                  task.wait(1)
                  network.RemoteEvents.Fishing:FireServer("Start")
                  task.wait(12) 
                  if _G.AutoFish then
                      network.RemoteEvents.Fishing:FireServer("Success")
                      network.RemoteEvents.Fishing:FireServer("Reset")
                  end
                  task.wait(1)
              end
          end)
      end
   end,
})

-- [[ AUTO TRUCKER SECTION ]]
TabFarm:CreateSection("Trucker Job - Pilih Salah Satu!")

-- METODE 1: TERBANG (TWEEN)
TabFarm:CreateToggle({
   Name = "1. Auto Trucker [Mode Terbang / Aman]",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoTruckerTween = Value
      
      if not Value then workspace.Gravity = 196 end
      
      if Value then
          if workspace.Map:FindFirstChild("Prop") then workspace.Map.Prop:Destroy() end
          
          task.spawn(function()
              while _G.AutoTruckerTween do
                  pcall(function()
                      local char = plr.Character
                      local hum = char:WaitForChild("Humanoid")
                      
                      if SetupTruck(hum, char) and hum.SeatPart ~= nil then
                          local car = hum.SeatPart.Parent
                          local primary = car.PrimaryPart
                          local target = workspace.Etc.Waypoint:WaitForChild("Waypoint", 3)
                          if not target then return end
                          
                          local prepos = target.Position
                          workspace.Gravity = 0
                          
                          local ts = game:GetService("TweenService")
                          local tv = Instance.new("CFrameValue")
                          tv.Value = car:GetPrimaryPartCFrame()
                          local pivotConnection = tv.Changed:Connect(function() car:PivotTo(tv.Value) end)
                          
                          -- Terbang
                          local UpTween = ts:Create(tv, TweenInfo.new(1, Enum.EasingStyle.Linear), {Value = primary.CFrame + Vector3.new(0, 300, 0)})
                          UpTween:Play() UpTween.Completed:Wait()
                          
                          -- Mendatar
                          local dist = (primary.Position - target.Position + Vector3.new(0, 300, 0)).Magnitude
                          local safeTime = math.clamp(dist / 250, 2, 15) 
                          local MainTween = ts:Create(tv, TweenInfo.new(safeTime, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 300, 0)})
                          MainTween:Play() MainTween.Completed:Wait()
                          
                          -- Turun & Sweep
                          local DownTween = ts:Create(tv, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 30, 0)})
                          DownTween:Play() DownTween.Completed:Wait()
                          
                          repeat task.wait()
                              if target.Parent and target.Position == prepos then
                                  workspace.Gravity = 0
                                  tv.Value = car:GetPrimaryPartCFrame()
                                  local Sweep1 = ts:Create(tv, TweenInfo.new(1, Enum.EasingStyle.Linear), {Value = target.CFrame * CFrame.new(0, 0, 15)})
                                  Sweep1:Play() Sweep1.Completed:Wait()
                                  
                                  if target.Parent and target.Position == prepos then
                                      tv.Value = car:GetPrimaryPartCFrame()
                                      local Sweep2 = ts:Create(tv, TweenInfo.new(1, Enum.EasingStyle.Linear), {Value = target.CFrame - Vector3.new(0, 15, 0)})
                                      Sweep2:Play() Sweep2.Completed:Wait()
                                  end
                                  
                                  workspace.Gravity = 200
                                  for _, v in pairs(car:GetDescendants()) do
                                      pcall(function() v.Velocity = Vector3.new(0,0,0) end)
                                  end
                                  task.wait(1.5)
                              end
                          until not target.Parent or target.Position ~= prepos or not _G.AutoTruckerTween
                          
                          pivotConnection:Disconnect()
                          tv:Destroy()
                          workspace.Gravity = 196
                          task.wait(1)
                      end
                  end)
                  task.wait()
              end
          end)
      end
   end,
})

-- METODE 2: TELEPORT (INSTAN)
TabFarm:CreateToggle({
   Name = "2. Auto Trucker [Mode Teleport / Brutal]",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoTruckerTele = Value
      
      if not Value then workspace.Gravity = 196 end
      
      if Value then
          if workspace.Map:FindFirstChild("Prop") then workspace.Map.Prop:Destroy() end
          
          task.spawn(function()
              while _G.AutoTruckerTele do
                  pcall(function()
                      local char = plr.Character
                      local hum = char:WaitForChild("Humanoid")
                      
                      if SetupTruck(hum, char) and hum.SeatPart ~= nil then
                          local car = hum.SeatPart.Parent
                          local target = workspace.Etc.Waypoint:WaitForChild("Waypoint", 3)
                          if not target then return end
                          
                          local prepos = target.Position
                          workspace.Gravity = 0
                          
                          -- 1. TELEPORT INSTAN TEPAT DI ATAS TARGET
                          car:PivotTo(target.CFrame + Vector3.new(0, 30, 0))
                          task.wait(0.5) -- Jeda dikit biar map ngerender
                          
                          -- 2. HITBOX SWEEP (CDID tetep butuh trigger benturan)
                          local ts = game:GetService("TweenService")
                          local tv = Instance.new("CFrameValue")
                          tv.Value = car:GetPrimaryPartCFrame()
                          local pivotConnection = tv.Changed:Connect(function() car:PivotTo(tv.Value) end)
                          
                          -- Langsung tembusin ke bawah buat ngambil duitnya
                          local SweepDown = ts:Create(tv, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value = target.CFrame - Vector3.new(0, 15, 0)})
                          SweepDown:Play() SweepDown.Completed:Wait()
                          
                          -- Tunggu rute pindah
                          local stuckTimer = tick()
                          repeat task.wait(0.2)
                              if target.Parent and target.Position == prepos and (tick() - stuckTimer) > 3 then
                                  -- Failsafe goyang kalau belum dapet
                                  tv.Value = car:GetPrimaryPartCFrame()
                                  local Wiggle = ts:Create(tv, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 10, 0)})
                                  Wiggle:Play() Wiggle.Completed:Wait()
                                  car:PivotTo(target.CFrame - Vector3.new(0, 15, 0))
                                  stuckTimer = tick()
                              end
                          until not target.Parent or target.Position ~= prepos or not _G.AutoTruckerTele
                          
                          -- CLEANUP
                          pivotConnection:Disconnect()
                          tv:Destroy()
                          
                          -- Reset velocity biar ga mental
                          for _, v in pairs(car:GetDescendants()) do
                              if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
                          end
                          
                          workspace.Gravity = 196
                          task.wait(0.5)
                      end
                  end)
                  task.wait()
              end
          end)
      end
   end,
})

-- [[ TELEPORT SECTION ]]
TabTele:CreateDropdown({
   Name = "Pilih Dealership",
   Options = getDealerships(),
   CurrentOption = {"Pilih Lokasi"},
   MultipleOptions = false,
   Callback = function(Option)
      local name = Option[1]
      local dealer = workspace.Etc.Dealership:FindFirstChild(name)
      if dealer then
          plr.Character.HumanoidRootPart.CFrame = dealer.WorldPivot + Vector3.new(0, 5, 0)
          Rayfield:Notify({
             Title = "Teleport Berhasil",
             Content = "Kamu telah sampai di " .. name,
             Duration = 3,
             Image = 4483345998,
          })
      end
   end,
})

Rayfield:Notify({
   Title = "Ultimate Script Aktif!",
   Content = "Pilih metodenya kids, Terbang atau Teleport!",
   Duration = 5,
   Image = 4483362458,
})
