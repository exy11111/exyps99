local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local topicId = ReplicatedStorage:WaitForChild("RoundControlFolder"):WaitForChild("TopicControl"):WaitForChild("TopicId")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

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
   CurrentValue = typeSpeed,
   Flag = "TypeSpeed",
   Callback = function(Value)
    typeSpeed = Value
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
        wait(1.25) --must be 1.25 or 1
        simulateTyping(newValue, typeSpeed)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        wait(typeSpeed)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end
end)

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

    
