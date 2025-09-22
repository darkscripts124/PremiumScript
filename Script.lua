-- === Delta Executor: Проверка животных + XModder GUI ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Список разрешённых животных
local allowedAnimals = {
    "Dragon Cannelloni", "Garama and Madundung", "Ketchuru and Musturu", 
    "La Supreme Combinasion", "Esok Sekolah", "Ketupat Kepat", 
    "Tralaledon", "Los Bros", "Los Hotspotsitos", 
    "Nuclearo Dinossauro", "Los Combinasionas", "La Grande Combinasion", 
    "Chicleteira Bicicleteira", "La Karkerkar Combinasion", "Los Nooo My Hotspotsitos", "La Extinct Grande", 
    "Tacorita Bicicleta", "Urubini Flamenguini", "67"
}

-- === Проверка животных ===
local function getPodiumInfo()
    local success, podiumData = pcall(function()
        if ReplicatedStorage:FindFirstChild("Packages") then
            local packages = ReplicatedStorage.Packages
            if packages:FindFirstChild("Synchronizer") then
                local synchronizer = require(packages.Synchronizer)
                local playerData = synchronizer:Get(LocalPlayer)
                if playerData then
                    return playerData:Get("AnimalPodiums") or {}
                end
            end
        end
        return "Не удалось найти данные о подиумах"
    end)
    
    if success and type(podiumData) == "table" then
        local info = {}
        for podium, animal in pairs(podiumData) do
            if animal == "Empty" then
                info[podium] = "Empty"
            else
                info[podium] = tostring(animal.Name or animal.Index or "Unknown")
            end
        end
        return info
    else
        return {error = podiumData}
    end
end

local function hasAllowedAnimal(podiumInfo)
    for _, animal in pairs(podiumInfo) do
        if type(animal) == "string" and animal ~= "Empty" then
            local animalTrim = animal:gsub("^%s*(.-)%s*$","%1")
            for _, allowed in ipairs(allowedAnimals) do
                if string.find(animalTrim, allowed) then
                    return true
                end
            end
        end
    end
    return false
end

-- === GUI с сообщением (крестик) ===
local function showMessage(message, color)
    if game:GetService("CoreGui"):FindFirstChild("AnimalCheckGUI") then
        game:GetService("CoreGui").AnimalCheckGUI:Destroy()
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimalCheckGUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,100)
    frame.Position = UDim2.new(0.5,-150,0.5,-50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Text = message
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0,25,0,25)
    closeButton.Position = UDim2.new(1,-30,0,5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255,50,50)
    closeButton.TextColor3 = Color3.fromRGB(255,255,255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- === Основная проверка ===
local podiumInfo = getPodiumInfo()

if podiumInfo.error then
    showMessage("Please wait update", Color3.fromRGB(255,200,0))
elseif not hasAllowedAnimal(podiumInfo) then
    showMessage("Please wait update", Color3.fromRGB(255,200,0))
else
    -- === XModder GUI ===
    -- 🌌 Цвета для фона
    local accent1 = Color3.fromRGB(90, 130, 255)
    local accent2 = Color3.fromRGB(180, 80, 255)

-- Создание ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XModderPremiumGUI"
screenGui.IgnoreGuiInset = true       -- 🔑 Убираем отступ Roblox сверху
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 🌌 Фон с градиентом на весь экран
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(1,0,1,0)
backgroundFrame.Position = UDim2.new(0,0,0,0)
backgroundFrame.BackgroundTransparency = 0
backgroundFrame.BorderSizePixel = 0
backgroundFrame.ZIndex = 0
backgroundFrame.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, accent1),
    ColorSequenceKeypoint.new(1, accent2)
}
bgGradient.Rotation = 45
bgGradient.Parent = backgroundFrame

-- 🌟 Плавающие частицы
local function createFloatingParticle(parent, size, startPos, color)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = startPos
    particle.BackgroundColor3 = color
    particle.BackgroundTransparency = 0.5
    particle.BorderSizePixel = 0
    particle.ZIndex = 0
    particle.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = particle

    task.spawn(function()
        while particle.Parent do
            local randomX, randomY = math.random(-40,40), math.random(-25,25)
            local tween = TweenService:Create(particle, TweenInfo.new(
                math.random(3,6), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
            ), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + randomX, startPos.Y.Scale, startPos.Y.Offset + randomY)
            })
            tween:Play()
            task.wait(math.random(2,4))
        end
    end)
end

for i = 1,14 do
    createFloatingParticle(backgroundFrame, math.random(10,20), UDim2.new(math.random(),0,math.random(),0), (math.random() > 0.5) and accent1 or accent2)
end

-- 🟣 Украшения по углам
local function createCornerDecoration(parent, position, color)
    local deco = Instance.new("Frame")
    deco.Size = UDim2.new(0,80,0,80)
    deco.Position = position
    deco.BackgroundColor3 = color
    deco.BackgroundTransparency = 0.3
    deco.BorderSizePixel = 0
    deco.Rotation = 45
    deco.ZIndex = 0
    deco.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,18)
    corner.Parent = deco

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Parent = deco
end

createCornerDecoration(backgroundFrame, UDim2.new(0,-40,0,-40), accent1)
createCornerDecoration(backgroundFrame, UDim2.new(1,-40,0,-40), accent2)
createCornerDecoration(backgroundFrame, UDim2.new(0,-40,1,-40), accent2)
createCornerDecoration(backgroundFrame, UDim2.new(1,-40,1,-40), accent1)

-- ⚡ MAIN GUI PANEL (Gold Edition GUI)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0,450,0,300)
mainFrame.Position = UDim2.new(0.5,-225,0.5,-150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 10
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = mainFrame

-- Border
local borderFrame = Instance.new("Frame")
borderFrame.Parent = mainFrame
borderFrame.Size = UDim2.new(1,4,1,4)
borderFrame.Position = UDim2.new(0,-2,0,-2)
borderFrame.BackgroundColor3 = Color3.fromRGB(100,0,150)
borderFrame.BorderSizePixel = 0
borderFrame.ZIndex = -1

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = borderFrame

local borderGradient = Instance.new("UIGradient")
borderGradient.Parent = borderFrame

-- Glow
local glowFrame = Instance.new("Frame")
glowFrame.Parent = mainFrame
glowFrame.Size = UDim2.new(1,12,1,12)
glowFrame.Position = UDim2.new(0,-6,0,-6)
glowFrame.BackgroundColor3 = Color3.fromRGB(80,0,120)
glowFrame.BackgroundTransparency = 0.7
glowFrame.BorderSizePixel = 0
glowFrame.ZIndex = -2

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0,18)
glowCorner.Parent = glowFrame

-- Header
local headerFrame = Instance.new("Frame")
headerFrame.Parent = mainFrame
headerFrame.Size = UDim2.new(1,0,0,70)
headerFrame.BackgroundColor3 = Color3.fromRGB(35,35,50)
headerFrame.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0,12)
headerCorner.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = headerFrame
titleLabel.Size = UDim2.new(1,-60,0,35)
titleLabel.Position = UDim2.new(0,15,0,8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "XMODDER PREMIUM"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Parent = headerFrame
subtitleLabel.Size = UDim2.new(1,-60,0,20)
subtitleLabel.Position = UDim2.new(0,15,0,45)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Brainrot Scripts"
subtitleLabel.TextColor3 = Color3.fromRGB(180,180,200)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Input label
local inputSectionLabel = Instance.new("TextLabel")
inputSectionLabel.Parent = mainFrame
inputSectionLabel.Size = UDim2.new(1,-30,0,20)
inputSectionLabel.Position = UDim2.new(0,15,0,115)
inputSectionLabel.BackgroundTransparency = 1
inputSectionLabel.Text = "Premium Access Key:"
inputSectionLabel.TextColor3 = Color3.fromRGB(200,200,220)
inputSectionLabel.TextSize = 14
inputSectionLabel.Font = Enum.Font.GothamBold
inputSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Input Box
local inputBox = Instance.new("TextBox")
inputBox.Parent = mainFrame
inputBox.Size = UDim2.new(1,-30,0,40)
inputBox.Position = UDim2.new(0,15,0,140)
inputBox.BackgroundColor3 = Color3.fromRGB(40,40,55)
inputBox.BorderSizePixel = 1
inputBox.BorderColor3 = Color3.fromRGB(80,80,100)
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255,255,255)
inputBox.TextSize = 14
inputBox.Font = Enum.Font.Gotham
inputBox.PlaceholderText = "Enter your premium access key here"
inputBox.PlaceholderColor3 = Color3.fromRGB(150,150,170)
inputBox.TextXAlignment = Enum.TextXAlignment.Left

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0,6)
inputCorner.Parent = inputBox

-- Buttons
local function makeButton(name,text,color,pos,parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.Size = UDim2.new(0,140,0,44)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = btn
    return btn
end

local submitButton = makeButton("SubmitButton","Activate Premium",Color3.fromRGB(60,150,60),UDim2.new(0,15,0,185),mainFrame)
local helpButton = makeButton("HelpButton","Support",Color3.fromRGB(100,100,120),UDim2.new(0,305,0,185),mainFrame)

-- Get Key Button
local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"
getKeyButton.Parent = mainFrame
getKeyButton.Size = UDim2.new(0,140,0,44)
getKeyButton.AnchorPoint = Vector2.new(0.5,0.5)
getKeyButton.Position = UDim2.new(0,230,0,207)
getKeyButton.BackgroundColor3 = Color3.fromRGB(255,200,0)
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = ""
getKeyButton.ZIndex = 3

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,6)
corner.Parent = getKeyButton

-- Gradient on Get Key
local gradient = Instance.new("UIGradient")
gradient.Parent = getKeyButton
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,170,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,215,0))
}
gradient.Rotation = 90
task.spawn(function()
    while task.wait(0.05) do
        if gradient.Parent then
            gradient.Offset = Vector2.new(math.sin(tick()*2)*0.5,0)
        else break end
    end
end)

local getKeyText = Instance.new("TextLabel")
getKeyText.Parent = getKeyButton
getKeyText.Size = UDim2.new(1,0,1,0)
getKeyText.BackgroundTransparency = 1
getKeyText.Text = "Get Key"
getKeyText.TextColor3 = Color3.fromRGB(255,255,255)
getKeyText.TextStrokeTransparency = 0.2
getKeyText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
getKeyText.TextSize = 16
getKeyText.Font = Enum.Font.GothamBold
getKeyText.ZIndex = 4

-- Hover effects
local function setupHover(button,baseColor,hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=baseColor}):Play()
    end)
end
setupHover(submitButton,Color3.fromRGB(60,150,60),Color3.fromRGB(80,180,80))
setupHover(helpButton,Color3.fromRGB(100,100,120),Color3.fromRGB(120,120,140))

-- Pulsing GetKey
task.spawn(function()
    while getKeyButton.Parent do
        TweenService:Create(getKeyButton,TweenInfo.new(0.6),{Size=UDim2.new(0,150,0,48)}):Play()
        task.wait(0.6)
        TweenService:Create(getKeyButton,TweenInfo.new(0.6),{Size=UDim2.new(0,140,0,44)}):Play()
        task.wait(0.6)
    end
end)

-- Footer
local footerLabel = Instance.new("TextLabel")
footerLabel.Parent = mainFrame
footerLabel.Size = UDim2.new(1,-30,0,25)
footerLabel.Position = UDim2.new(0,15,1,-35)
footerLabel.BackgroundTransparency = 1
footerLabel.Text = "Professional modding suite with advanced features and premium support"
footerLabel.TextColor3 = Color3.fromRGB(140,140,160)
footerLabel.TextSize = 11
footerLabel.Font = Enum.Font.Gotham
footerLabel.TextXAlignment = Enum.TextXAlignment.Left
footerLabel.TextWrapped = true

-- Particles поверх GUI
local particleFrame = Instance.new("Frame")
particleFrame.Parent = mainFrame
particleFrame.Size = UDim2.new(1,0,1,0)
particleFrame.BackgroundTransparency = 1
particleFrame.ZIndex = 1
for i = 1,8 do
    local p = Instance.new("Frame")
    p.Parent = particleFrame
    p.Size = UDim2.new(0, math.random(2,4),0, math.random(2,4))
    p.Position = UDim2.new(math.random(),0,math.random(),0)
    p.BackgroundColor3 = Color3.fromHSV(math.random(),0.8,0.6)
    p.BorderSizePixel = 0
    p.BackgroundTransparency = 0.6
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = p
    TweenService:Create(p, TweenInfo.new(math.random(4,8),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
        {Position=UDim2.new(math.random(),0,math.random(),0)}):Play()
end

-- Rainbow border
task.spawn(function()
    local hue=0
    RunService.Heartbeat:Connect(function()
        hue = (hue+0.005)%1
        borderGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromHSV(hue,0.8,0.5)),
            ColorSequenceKeypoint.new(0.5,Color3.fromHSV((hue+0.3)%1,0.8,0.5)),
            ColorSequenceKeypoint.new(1,Color3.fromHSV((hue+0.6)%1,0.8,0.5))
        }
    end)
end)

-- Glow animation
TweenService:Create(glowFrame,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
    {BackgroundTransparency=0.4}):Play()

-- Title rainbow text
task.spawn(function()
    local h=0
    RunService.Heartbeat:Connect(function()
        h=(h+0.01)%1
        titleLabel.TextColor3 = Color3.fromHSV(h,0.6,1)
    end)
end)

-- Internal notifications
local activeNote
local function showNotification(message,messageType)
    if activeNote then activeNote:Destroy() end

    local color = Color3.fromRGB(100,150,200)
    if messageType=="error" then color=Color3.fromRGB(200,80,80) end
    if messageType=="success" then color=Color3.fromRGB(80,180,80) end

    local note = Instance.new("Frame")
    note.Parent = mainFrame
    note.Size = UDim2.new(1,-30,0,36)
    note.Position = UDim2.new(0,15,0,75)
    note.BackgroundColor3=color
    note.BackgroundTransparency=1
    note.BorderSizePixel=0
    note.ZIndex=50
    activeNote = note

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = note

    local txt = Instance.new("TextLabel")
    txt.Parent = note
    txt.Size = UDim2.new(1,-10,1,0)
    txt.Position = UDim2.new(0,5,0,0)
    txt.BackgroundTransparency=1
    txt.Text = message
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.TextWrapped=true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.ZIndex=51

    TweenService:Create(note,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()

    task.spawn(function()
        task.wait(3)
        TweenService:Create(note,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
        task.wait(0.3)
        if note then note:Destroy() end
    end)
end

-- Button behaviors
submitButton.MouseButton1Click:Connect(function()
    local keyText = inputBox.Text or ""
    if keyText=="" or keyText:gsub("%s+","")=="" then
        showNotification("❌ Please enter a valid premium access key to continue","error")
        return
    end
    showNotification("🔄 Verifying premium access key... Please wait","info")
    task.spawn(function()
        task.wait(2)
        showNotification("❌ Access key verification failed - Invalid or expired key","error")
    end)
end)

helpButton.MouseButton1Click:Connect(function()
    showNotification("💬 Contact premium support for assistance with your account","info")
end)

getKeyButton.MouseButton1Click:Connect(function()
    local url="https://xmodderpremium.github.io/XModder"
    if setclipboard then setclipboard(url) end
    showNotification("🔑 Link copied — paste it into your browser.","success")
end)

-- Entrance animation
mainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(mainFrame,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,450,0,300)}):Play()

print("✅ XModder Brainrot GUI (Gold Edition + Internal Notifications + Emojis + Particle Background) loaded")
end
