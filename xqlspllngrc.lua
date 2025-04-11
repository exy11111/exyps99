local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local submitAnswerRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SubmitAnswerRemote")
local redeemGroupRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RedeemGroupRemote")

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
   Name = "SPELLING RACE SCRIPT 3.2 by xql",
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

local function submitAnswer(answer)
    submitAnswerRemote:InvokeServer(answer)
end

local function simulateTyping(text, speed)
    for char in text:upper():gmatch(".") do
        local keyCode = Enum.KeyCode[string.upper(char)]
        
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(speed)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            task.wait(speed)
        end
    end
end

local connection

connection = topicId.Changed:Connect(function(newValue)
    Label:Set("Current Word: "..newValue)
    if autoTypeEnabled then
        task.wait(waitTime) --must be 1.25 or 1
        simulateTyping(newValue, typeSpeed)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(typeSpeed)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        submitAnswer(newValue) --in case nasa lobby
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

local function redeemReward()
    redeemGroupRemote:InvokeServer()
end

local function startCountdown()
    timerRunning = true
    while timerRunning do
        task.wait(1)

        if autoClaimEnabled then
            timeLeft -= 1
            timerLabel:Set("Rewards Timer: " .. formatTime(timeLeft))

            if timeLeft <= 0 then
                redeemReward()
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
            redeemReward()
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
       redeemReward()
   end,
})
