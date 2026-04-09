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
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "by Dika Official",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- [[ VARIABLES & FUNCTIONS ]]
local plr = game.Players.LocalPlayer
local network = game:GetService("ReplicatedStorage").NetworkContainer
_G.AutoFish = false
_G.AutoTrucker = false

local function getDealerships()
    local list = {}
    for i, v in pairs(workspace.Etc.Dealership:GetChildren()) do
        if v.ClassName == "Model" then
            table.insert(list, v.Name)
        end
    end
    return list
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
TabFarm:CreateSection("Trucker Job")

TabFarm:CreateToggle({
   Name = "Auto Trucker [Speed Farm]",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoTrucker = Value
      
      if not Value then
          workspace.Gravity = 196
      end
      
      if Value then
          if workspace.Map:FindFirstChild("Prop") then
              workspace.Map.Prop:Destroy()
          end
          
          task.spawn(function()
              while _G.AutoTrucker do
                  pcall(function()
                      local char = plr.Character
                      local hum = char:WaitForChild("Humanoid")
                      
                      -- JIKA BELUM DUDUK DI TRUK
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
                          
                      -- JIKA SUDAH DUDUK DI TRUK
                      elseif hum.SeatPart ~= nil then
                          local car = hum.SeatPart.Parent
                          local primary = car.PrimaryPart
                          local target = workspace.Etc.Waypoint.Waypoint
                          local prepos = target.Position
                          workspace.Gravity = 0
                          
                          local ts = game:GetService("TweenService")
                          local tv = Instance.new("CFrameValue")
                          tv.Value = car:GetPrimaryPartCFrame()
                          tv.Changed:Connect(function() car:PivotTo(tv.Value) end)
                          
                          -- 1. Terbang Ke Atas (Di tempat sekarang)
                          local UpTween = ts:Create(tv, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value = primary.CFrame + Vector3.new(0, 1000, 0)})
                          UpTween:Play()
                          UpTween.Completed:Wait()
                          
                          -- 2. Terbang Mendatar ke Tujuan (Mengikuti arah rotasi Waypoint)
                          local dist = (primary.Position - target.Position).Magnitude
                          local fastTime = math.clamp(dist / 650, 0.5, 8) 
                          
                          tv.Value = car:GetPrimaryPartCFrame()
                          local MainTween = ts:Create(tv, TweenInfo.new(fastTime, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 1000, 0)})
                          MainTween:Play()
                          MainTween.Completed:Wait()
                          
                          -- 3. Turun ke Posisi Waypoint (Jarak aman 15 stud)
                          tv.Value = car:GetPrimaryPartCFrame()
                          local DownTween = ts:Create(tv, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 15, 0)})
                          DownTween:Play()
                          DownTween.Completed:Wait()
                          
                          -- 4. Aktifkan Gravitasi agar nyentuh aspal
                          workspace.Gravity = 196
                          for _, v in pairs(car:GetDescendants()) do
                              if v:IsA("BasePart") then
                                  v.Velocity = Vector3.new(0, -10, 0)
                                  v.RotVelocity = Vector3.new(0, 0, 0)
                              end
                          end
                          
                          -- 5. Menunggu Waypoint Berpindah (Sistem Wiggle/Goyang)
                          local stuckTimer = tick()
                          local wiggleStep = 0
                          
                          repeat task.wait(0.2)
                              -- Failsafe: Jika 2.5 detik belum dapat uang, lakukan pergerakan ke titik trigger
                              if target.Position == prepos and (tick() - stuckTimer) > 2.5 then
                                  workspace.Gravity = 0
                                  tv.Value = car:GetPrimaryPartCFrame()
                                  local nextCFrame
                                  
                                  if wiggleStep == 0 then
                                      -- Geser maju 15 stud
                                      nextCFrame = target.CFrame * CFrame.new(0, 0, 15)
                                      wiggleStep = 1
                                  elseif wiggleStep == 1 then
                                      -- Geser agak turun ke bawah (berjaga-jaga hitbox di bawah tanah)
                                      nextCFrame = target.CFrame - Vector3.new(0, 5, 0)
                                      wiggleStep = 2
                                  else
                                      -- Kembali ke tengah atas
                                      nextCFrame = target.CFrame + Vector3.new(0, 15, 0)
                                      wiggleStep = 0
                                  end
                                  
                                  local AdjustTween = ts:Create(tv, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value = nextCFrame})
                                  AdjustTween:Play()
                                  AdjustTween.Completed:Wait()
                                  
                                  workspace.Gravity = 196
                                  stuckTimer = tick()
                              end
                          until target.Position ~= prepos or not _G.AutoTrucker
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
   Title = "DIKA CDID Siap!",
   Content = "Auto Trucker sudah dilengkapi sistem penyelarasan lokasi.",
   Duration = 5,
   Image = 4483362458,
})
