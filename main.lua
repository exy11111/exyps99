--loadstring(game:HttpGet("https://raw.githubusercontent.com/exy11111/exyps99/refs/heads/main/main.lua"))()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--start auto claim chest
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
--end auto claim chest


local Window = Rayfield:CreateWindow({
   Name = "Exy PS99",
   Icon = 0,
   LoadingTitle = "PS99 Simple Script",
   LoadingSubtitle = "by Exy",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"}
   }
})

local Tab = Window:CreateTab("Main")
local AutoSkillEnabled = false
local CoverScreen = false
local AutoSkillTime = 30
local messageToDisplay = ""

local Tab2 = Window:CreateTab("Slime")
local AutoClaimChest = false

local Toggle = Tab:CreateToggle({
   Name = "Auto Skill",
   CurrentValue = AutoSkillEnabled,
   Flag = "AutoSkill", 
   Callback = function(Value)
     AutoSkillEnabled = Value
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Auto Skill Time (Seconds)",
   Range = {10, 60},
   Increment = 10,
   Suffix = "Seconds",
   CurrentValue = AutoSkillTime,
   Flag = "Slider1",
   Callback = function(Value)
    AutoSkillTime = Value
   end,
})

local Input = Tab:CreateInput({
    Name = "Enter Message for Cover Screen",
    CurrentValue = "",
    PlaceholderText = "Enter a message here...",
    RemoveTextAfterFocusLost = false,
    Flag = "InputMessage",
    Callback = function(Text)
        messageToDisplay = Text
    end,
})

local Toggle1 = Tab:CreateToggle({
   Name = "Cover Screen",
   CurrentValue = CoverScreen,
   Flag = "CoverScreen", 
   Callback = function(Value)
        CoverScreen = Value
        if CoverScreen then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BlackScreenGui"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false
            screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

            local blackFrame = Instance.new("Frame")
            blackFrame.Size = UDim2.new(1, 0, 1, 0)
            blackFrame.Position = UDim2.new(0, 0, 0, 0)
            blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
            blackFrame.BorderSizePixel = 0
            blackFrame.Parent = screenGui
            blackFrame.ZIndex = 1

            local messageLabel = Instance.new("TextLabel")
            messageLabel.Size = UDim2.new(1, 0, 1, 0)
            messageLabel.Position = UDim2.new(0, 0, 0, 0)
            messageLabel.BackgroundTransparency = 1
            messageLabel.Text = messageToDisplay
            messageLabel.TextColor3 = Color3.new(1, 1, 1)
            messageLabel.TextSize = 50
            messageLabel.TextWrapped = true
            messageLabel.TextYAlignment = Enum.TextYAlignment.Center
            messageLabel.TextXAlignment = Enum.TextXAlignment.Center
            messageLabel.Parent = blackFrame
            messageLabel.ZIndex = 2


        else
            local existingScreenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BlackScreenGui")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
   end,
})

local AutoClaimStatus = Tab2:CreateLabel("Auto Claim Status: Stopped")

local ToggleAutoClaimChest = Tab2:CreateToggle({
    Name = "Auto Claim Chest",
    CurrentValue = AutoClaimChest,
    Flag = "AutoClaimChest",
    Callback = function(Value)
        AutoClaimChest = Value
        if AutoClaimChest then
            if humanoidRootPart and humanoidRootPart.Parent then
                originalPosition = humanoidRootPart.CFrame
            end

            Rayfield:Notify({
                Title = "PS99 Simple Script",
                Content = "⏳ Starting claiming chests...",
                Duration = 5,
                Image = 4483362458,
            })
            AutoClaimStatus:Set("Auto Claim Status: ⏳ Starting claiming chests...")

            local function pressEKey()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
            local function findNearestObject(objectNamePrefix)
                local closestObj = nil
                local closestDistance = math.huge
                if not humanoidRootPart or not humanoidRootPart.Parent then return nil, math.huge end -- Exit if no character
                local rootPos = humanoidRootPart.Position
                local searchArea = Workspace

                for _, obj in ipairs(searchArea:GetDescendants()) do
                    if obj.Name:lower():match("^"..objectNamePrefix:lower()) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        local partToCheck = nil
                        if obj:IsA("Model") then
                            partToCheck = obj.PrimaryPart or obj:FindFirstChild("Hitbox") or obj:FindFirstChildWhichIsA("BasePart")
                        else
                            partToCheck = obj
                        end

                        if partToCheck and partToCheck:IsA("BasePart") then
                            local distance = (rootPos - partToCheck.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestObj = obj
                            end
                        end
                    end
                end
                return closestObj, closestDistance
            end
            local function teleportToObject(targetObject)
                if not targetObject then return false end
                if not humanoidRootPart or not humanoidRootPart.Parent then return false end -- Exit if no character

                local targetPart = nil
                if targetObject:IsA("Model") then
                    targetPart = targetObject.PrimaryPart or targetObject:FindFirstChild("Hitbox") or targetObject:FindFirstChildWhichIsA("BasePart")
                elseif targetObject:IsA("BasePart") then
                    targetPart = targetObject
                end

                if not targetPart then
                    return false
                end

                local targetCFrame = targetPart.CFrame * CFrame.new(0, 3, -5)
                humanoidRootPart.CFrame = targetCFrame
                task.wait(0.2)
                return true
            end
            local function openNearestChest(chestName)
                local chest, distance = findNearestObject(chestName)
                if not chest then
                    return false
                end
                if teleportToObject(chest) then
                    task.wait(0.1)
                    pressEKey()
                    task.wait(2.5)
                    return true
                else
                    return false
                end
            end
            local COOLDOWN_SECONDS = 120
            local function startCountdown()
                if not AutoClaimChest then return end

                Rayfield:Notify({
                    Title = "PS99 Simple Script",
                    Content = "⏳ Cooldown started...",
                    Duration = 5,
                    Image = 4483362458,
                })

                for i = COOLDOWN_SECONDS, 0, -1 do
                    if not AutoClaimChest then
                        AutoClaimStatus:Set("Auto Claim Status: 🔴 Stopped")
                        return
                    end
                    AutoClaimStatus:Set("Auto Claim Status: ⏳ Cooldown " .. tostring(i).." sec")
                    task.wait(1)
                end

                if AutoClaimChest then
                    AutoClaimStatus:Set("Auto Claim Status: ✅ Ready!")
                    Rayfield:Notify({
                        Title = "PS99 Simple Script",
                        Content = "⏳ Auto claiming chests...",
                        Duration = 5,
                        Image = 4483362458,
                    })
                else
                    AutoClaimStatus:Set("Auto Claim Status: Stopped")
                end
            end
            local function processChestsAndReturn()
                if not AutoClaimChest then return end
                local successTitanic = openNearestChest("TitanicChest")
                if AutoClaimChest then
                    local successHuge = openNearestChest("HugeChest")
                end
                if AutoClaimChest then
                    if humanoidRootPart and humanoidRootPart.Parent then
                        humanoidRootPart.CFrame = originalPosition
                        task.wait(0.3)
                    else
                        AutoClaimChest = false
                        return
                    end
                    startCountdown()
                end
            end
            
            local function mainLoop()
                while AutoClaimChest and task.wait() do
                    processChestsAndReturn()
                end
                if not AutoClaimChest then
                    print("Automatic Chest Opener main loop stopped.")
                end
            end
            mainLoop()
        else
            AutoClaimChest = false
            AutoClaimStatus:Set("Auto Claim Status: 🔴 Stopped")
        end
    end,
})

--Auto Skill
local VirtualInputManager = game:GetService("VirtualInputManager")
local function pressR()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    Rayfield:Notify({
        Title = "PS99 Simple Script",
        Content = "Skill pressed!",
        Duration = 5,
        Image = 4483362458,
    })
end
local running = false
local function updateAutoSkill()
    if AutoSkillEnabled and not running then
        running = true
        while AutoSkillEnabled do
            pressR()
            wait(AutoSkillTime)
        end
        running = false
    elseif not AutoSkillEnabled and running then
        running = false
    end
end
while true do
    updateAutoSkill()
    wait(0.1)
end
--End Auto Skill

--Auto Claim Chest
