local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local topicId = ReplicatedStorage:WaitForChild("RoundControlFolder"):WaitForChild("TopicControl"):WaitForChild("TopicId")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerGui = player:WaitForChild("PlayerGui")
local gameplay = playerGui:WaitForChild("Gameplay")
local answerInputGui = gameplay:WaitForChild("AnswerInputGui")
local frame = answerInputGui:WaitForChild("Frame")
local frame1 = frame:WaitForChild("Frame")
local answerFrame = frame1:WaitForChild("AnswerFrame")
local centerFrame = answerFrame:WaitForChild("CenterFrame")
local inputFrame = centerFrame:WaitForChild("InputFrame")
local inputFrameBackground = inputFrame:WaitForChild("InputFrameBackground")
local textLabel = inputFrameBackground:WaitForChild("TextLabel")


local Window = Rayfield:CreateWindow({
   Name = "SPELLING RACE SCRIPT",
   Icon = 0,
   LoadingTitle = "SPELLING RACE SCRIPT",
   LoadingSubtitle = "by xql",
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

local Tab = Window:CreateTab("Main Tab")

local autoTypeEnabled = false
local typeSpeed = 0.02
local currentWordValue = ""
local waitTime = 1.75

local Toggle = Tab:CreateToggle({
   Name = "Auto Type",
   CurrentValue = autoTypeEnabled,
   Flag = "AutoType", 
   Callback = function(Value)
     autoTypeEnabled = Value
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Auto Type Speed (sec)",
   Range = {0.01, 0.5},
   Increment = 0.01,
   Suffix = "Seconds",
   CurrentValue = 0.02,
   Flag = "TypeSpeed",
   Callback = function(Value)
    typeSpeed = Value
   end,
})

local Slider1 = Tab:CreateSlider({
   Name = "Waiting time before typing (sec)",
   Range = {1.25, 3},
   Increment = 0.01,
   Suffix = "Seconds",
   CurrentValue = 1.75,
   Flag = "waitTime",
   Callback = function(Value)
    waitTime = Value
   end,
})

local Label = Tab:CreateLabel("Current Word: ")

local function simulateTyping(text, speed)
    for i = 1, #text do
        local char = text:sub(i, i)
        local keyCode = Enum.KeyCode[string.upper(char)]
        
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            wait(speed)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            wait(speed)
        end
    end
end

topicId.Changed:Connect(function(newValue)
    Label:Set("Current Word: "..newValue)
    if autoTypeEnabled then
        wait(waitTime) --must be 1.25 or 1
        simulateTyping(newValue, typeSpeed)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        wait(typeSpeed)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end
end)

Tab:CreateDivider("Your Divider Title")

local autoClaimEnabled = false
local timerDuration = 15 * 60
local timeLeft = timerDuration
local timerRunning = false

local timerLabel = Tab:CreateLabel("Rewards Timer: 15:00")

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

local function teleportToReward()
    local originalPosition = humanoidRootPart.Position
    local targetPart = game.Workspace:FindFirstChild("GroupRewards") and game.Workspace.GroupRewards:FindFirstChild("RewardCircle2")

    if targetPart and targetPart:IsA("BasePart") then
        for i = 1, 10 do
            humanoidRootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
            wait(0.001)
        end
        Rayfield:Notify({Title = "Auto Claim", Content = "Teleported to reward!", Duration = 3})
        humanoidRootPart.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
    else
        Rayfield:Notify({Title = "Auto Claim", Content = "Reward not found!", Duration = 3})
    end
end

local function startCountdown()
    timerRunning = true
    while timerRunning do
        wait(1)

        if autoClaimEnabled then
            timeLeft -= 1
            timerLabel:Set("Rewards Timer: " .. formatTime(timeLeft))

            if timeLeft <= 0 then
                teleportToReward()
                timeLeft = timerDuration
            end
        else
            timeLeft = timerDuration
            timerLabel:Set("Rewards Timer: " .. formatTime(timeLeft))
            timerRunning = false
        end
    end
end

local Toggle2 = Tab:CreateToggle({
    Name = "Auto Claim Rewards",
    CurrentValue = false,
    Flag = "AutoClaim",
    Callback = function(Value)
        autoClaimEnabled = Value

        if Value then
            teleportToReward()
            if not timerRunning then
                task.spawn(startCountdown)
            end
        else
            timeLeft = timerDuration
            timerLabel:Set("Rewards Timer: " .. formatTime(timeLeft))
        end
    end,
})

Tab:CreateButton({
   Name = "Force Claim Now",
   Callback = function()
       teleportToReward()
   end,
})

