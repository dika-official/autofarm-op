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
      
      if Value then
          task.spawn(function()
              while _G.AutoTrucker do
                  pcall(function()
                      local char = plr.Character
                      local hum = char.Humanoid
                      
                      if hum.SeatPart == nil then
                          -- Ambil Job & Spawn Truk
                          workspace.Gravity = 196
                          network.RemoteEvents.Job:FireServer("Truck")
                          char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
                          task.wait(0.5)
                          fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                          
                          task.wait(1)
                          char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Spawner.Part.CFrame
                          task.wait(0.5)
                          fireproximityprompt(workspace.Etc.Job.Truck.Spawner.Part.Prompt)
                          
                          repeat task.wait(0.5) until workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
                          local car = workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
                          car.DriveSeat:Sit(hum)
                          task.wait(1)
                      else
                          -- Proses Pengiriman (Anti Nyangkut)
                          local car = hum.SeatPart.Parent
                          local target = workspace.Etc.Waypoint.Waypoint
                          local prepos = target.Position
                          
                          workspace.Gravity = 0 -- Matikan gravitasi biar gak jatuh
                          
                          local ts = game:GetService("TweenService")
                          local cframeVal = Instance.new("CFrameValue")
                          cframeVal.Value = car:GetPivot()
                          
                          -- Update posisi mobil dengan aman menggunakan CFrameValue
                          local conn = cframeVal.Changed:Connect(function()
                              car:PivotTo(cframeVal.Value)
                          end)
                          
                          -- 1. Naik ke atas dulu 1000 meter (Hindari gedung)
                          local tweenUp = ts:Create(cframeVal, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Value = car:GetPivot() + Vector3.new(0, 1000, 0)})
                          tweenUp:Play()
                          tweenUp.Completed:Wait()
                          
                          -- 2. Jalan ke waypoint dari atas langit (Speed 3 detik)
                          local tweenMove = ts:Create(cframeVal, TweenInfo.new(3, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 1000, 0)})
                          tweenMove:Play()
                          tweenMove.Completed:Wait()
                          
                          -- 3. Turun pelan ke Waypoint
                          local tweenDown = ts:Create(cframeVal, TweenInfo.new(1, Enum.EasingStyle.Linear), {Value = target.CFrame + Vector3.new(0, 10, 0)})
                          tweenDown:Play()
                          tweenDown.Completed:Wait()
                          
                          conn:Disconnect()
                          cframeVal:Destroy()
                          
                          -- Pas-in ke titik
                          car:PivotTo(target.CFrame)
                          for i, v in pairs(car:GetDescendants()) do
                              if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0) end
                          end
                          task.wait(1.5)
                          
                          -- Tunggu waypoint pindah baru lanjut
                          repeat task.wait(0.1) until target.Position ~= prepos
                      end
                  end)
                  task.wait()
              end
          end)
      else
          workspace.Gravity = 196
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
   Title = "DIKA CDID Berhasil!",
   Content = "Script siap digunakan, truk sudah anti nyangkut.",
   Duration = 5,
   Image = 4483362458,
})
