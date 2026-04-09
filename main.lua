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
   KeySystem = false -- Keyless sesuai permintaan
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
local TabFarm = Window:CreateTab("Auto Farm", 4483362458) -- Icon Farm
local TabTele = Window:CreateTab("Teleports", 4483345998) -- Icon Map

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
                  task.wait(12) -- Kecepatan optimal agar tidak bug
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
      workspace.Gravity = Value and 0 or 196
      
      if Value then
          task.spawn(function()
              while _G.AutoTrucker do
                  pcall(function()
                      local char = plr.Character
                      local hum = char.Humanoid
                      
                      if hum.SeatPart == nil then
                          -- Ambil Job
                          network.RemoteEvents.Job:FireServer("Truck")
                          char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Starter.WorldPivot
                          task.wait(0.5)
                          fireproximityprompt(workspace.Etc.Job.Truck.Starter.Prompt)
                          
                          -- Spawn Truk
                          task.wait(1)
                          char.HumanoidRootPart.CFrame = workspace.Etc.Job.Truck.Spawner.Part.CFrame
                          task.wait(0.5)
                          fireproximityprompt(workspace.Etc.Job.Truck.Spawner.Part.Prompt)
                          
                          -- Tunggu & Duduk
                          repeat task.wait(0.5) until workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
                          local car = workspace.Vehicles:FindFirstChild(plr.Name.."sCar")
                          car.DriveSeat:Sit(hum)
                      else
                          -- Proses Pengiriman (Speed Tween)
                          local car = hum.SeatPart.Parent
                          local target = workspace.Etc.Waypoint.Waypoint
                          local prepos = target.Position
                          
                          -- Tweening Sangat Cepat
                          local ts = game:GetService("TweenService")
                          local ti = TweenInfo.new(3, Enum.EasingStyle.Linear) -- Hanya 3 detik ke tujuan!
                          
                          local tween = ts:Create(car.PrimaryPart, ti, {CFrame = target.CFrame + Vector3.new(0, 50, 0)})
                          tween:Play()
                          tween.Completed:Wait()
                          
                          -- Turun ke bawah untuk selesaikan waypoint
                          car:PivotTo(target.CFrame)
                          task.wait(1)
                          
                          -- Deteksi Waypoint Baru
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
   Content = "Script siap digunakan.",
   Duration = 5,
   Image = 4483362458,
})
