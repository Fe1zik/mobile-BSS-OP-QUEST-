--[[
    BBS OP QUEST GUI (Mobile Optimized)
    Адаптировано для телефонов: увеличенные кнопки, сенсорное управление, плавающая кнопка сворачивания
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
local savedSpeed = 16
local MIN_SPEED = 10
local MAX_SPEED = 250
local isDigActive = false
local digLoop = nil
local isGodModeActive = false
local godLoop = nil
local selectedField = "Sunflower Field"

-- Координаты полей
local fieldPositions = {
    ["Sunflower Field"] = Vector3.new(-212, 86, -225),
    ["Stump Field"] = Vector3.new(-362, 85, -360),
    ["Pepper Field"] = Vector3.new(-60, 85, -500),
    ["Strawberry Field"] = Vector3.new(190, 85, -360),
    ["Rose Field"] = Vector3.new(210, 85, -120)
}

-- ========== ФУНКЦИИ ==========
local function dig()
    game:GetService("ReplicatedStorage").remoteFunctions.toolClick:InvokeServer()
end

local function setGodMode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
    end
end

local function teleportTo(position)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- ========== ЗАГРУЗОЧНЫЙ ЭКРАН ==========
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingGUI"
loadingGui.ResetOnSpawn = false
loadingGui.Parent = playerGui

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingFrame.BackgroundTransparency = 1
loadingFrame.Parent = loadingGui

local loadingCenter = Instance.new("Frame")
loadingCenter.Size = UDim2.new(0, 200, 0, 100)
loadingCenter.Position = UDim2.new(0.5, -100, 0.5, -50)
loadingCenter.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
loadingCenter.BackgroundTransparency = 0.2
loadingCenter.BorderSizePixel = 0
loadingCenter.Parent = loadingFrame

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(0, 12)
loadingCorner.Parent = loadingCenter

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 30)
loadingTitle.Position = UDim2.new(0, 0, 0, 15)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "BBS OP QUEST"
loadingTitle.TextColor3 = Color3.fromRGB(80, 120, 255)
loadingTitle.TextSize = 16
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.Parent = loadingCenter

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0, 20)
loadingText.Position = UDim2.new(0, 0, 0, 50)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Загрузка..."
loadingText.TextColor3 = Color3.fromRGB(150, 150, 150)
loadingText.TextSize = 11
loadingText.Font = Enum.Font.Gotham
loadingText.Parent = loadingCenter

local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0.8, 0, 0, 4)
progressBarBg.Position = UDim2.new(0.1, 0, 0, 80)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = loadingCenter

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(1, 0)
progressBarCorner.Parent = progressBarBg

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBarBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressFill

local function updateProgress(percent, text)
    percent = math.clamp(percent, 0, 1)
    TweenService:Create(progressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    if text then
        loadingText.Text = text
    end
end

updateProgress(0.1, "Инициализация...")
task.wait(0.3)
updateProgress(0.3, "Загрузка GUI...")
task.wait(0.3)
updateProgress(0.5, "Настройка вкладок...")
task.wait(0.3)
updateProgress(0.7, "Подготовка функций...")
task.wait(0.3)
updateProgress(0.8, "Готово!")
task.wait(0.2)

local fadeOut = TweenService:Create(loadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
    {BackgroundTransparency = 1})
fadeOut:Play()
fadeOut.Completed:Connect(function()
    loadingGui:Destroy()
end)

-- ========== GUI СОЗДАНИЕ ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BBSOPQuestGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Плавающая кнопка сворачивания для мобильных устройств
local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(1, -60, 0, 60)
floatingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
floatingButton.Text = "≡"
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.TextSize = 24
floatingButton.Font = Enum.Font.GothamBold
floatingButton.BorderSizePixel = 0
floatingButton.Visible = true
floatingButton.Parent = screenGui

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(1, 0)
floatingCorner.Parent = floatingButton

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 750, 0, 450)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,10)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
topBar.BackgroundTransparency = 0.5
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 100, 1, 0)
titleLabel.Position = UDim2.new(0, 325, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BBS OP QUEST"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 100, 1, 0)
versionLabel.Position = UDim2.new(0, 425, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v1.0.1"
versionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
versionLabel.TextSize = 9
versionLabel.Font = Enum.Font.GothamBold
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Parent = topBar

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, -100, 1, 0)
authorLabel.Position = UDim2.new(0, 10, 0, 5)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "By Fe1zik"
authorLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
authorLabel.TextSize = 8
authorLabel.Font = Enum.Font.GothamBold
authorLabel.TextXAlignment = Enum.TextXAlignment.Left
authorLabel.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -75, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundTransparency = 0.95
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(80, 120, 255)
minimizeButton.TextSize = 24
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = topBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundTransparency = 0.95
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Size = UDim2.new(0, 150, 1, -40)
sideBar.Position = UDim2.new(0, 0, 0, 40)
sideBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sideBar.BackgroundTransparency = 1
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame

local verticalSeparator = Instance.new("Frame")
verticalSeparator.Name = "VerticalSeparator"
verticalSeparator.Size = UDim2.new(0, 5, 1, -10)
verticalSeparator.Position = UDim2.new(0, 165, 0, 40)
verticalSeparator.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
verticalSeparator.BackgroundTransparency = 0.5
verticalSeparator.BorderSizePixel = 0
verticalSeparator.Parent = mainFrame

local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 1, 0)
tabsContainer.Position = UDim2.new(0, 0, 0, 10)
tabsContainer.BackgroundTransparency = 1
tabsContainer.Parent = sideBar

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -170, 1, -60)
contentContainer.Position = UDim2.new(0, 160, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local tabs = {
    {name = "Player", icon = ""},
    {name = "AutoFarm", icon = ""},
    {name = "GodMode", icon = ""},
    {name = "Teleports", icon = ""},
    {name = "Settings", icon = ""}
}

local activeTab = "Player"
local tabButtons = {}

local isMinimized = false
local fullSize = mainFrame.Size
local minimizedSize = UDim2.new(0, 650, 0, 40)

local function animateToCenter(minimize)
    local targetPos
    local targetSize
    
    if minimize then
        targetSize = UDim2.new(0, 0, 0, 0)
        targetPos = UDim2.new(0.5, 0, 0.5, 0)
    else
        targetSize = fullSize
        targetPos = UDim2.new(0.5, -fullSize.X.Offset/2, 0.5, -fullSize.Y.Offset/2)
    end
    
    local sizeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = targetSize})
    local posTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = targetPos})
    
    sizeTween:Play()
    posTween:Play()
    
    sizeTween.Completed:Wait()
    
    if minimize then
        contentContainer.Visible = false
        sideBar.Visible = false
        minimizeButton.Text = "+"
    else
        contentContainer.Visible = true
        sideBar.Visible = true
        minimizeButton.Text = "−"
    end
end

local function setMinimized(minimized)
    if isMinimized == minimized then return end
    isMinimized = minimized
    animateToCenter(minimized)
end

local function setFullHide(hide)
    if hide then
        local hideTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            mainFrame.Visible = false
            floatingButton.Visible = true
        end)
    else
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.Visible = true
        floatingButton.Visible = false
        
        local showTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = fullSize, Position = UDim2.new(0.5, -fullSize.X.Offset/2, 0.5, -fullSize.Y.Offset/2)})
        showTween:Play()
        
        contentContainer.Visible = true
        sideBar.Visible = true
        isMinimized = false
        minimizeButton.Text = "−"
    end
end

local function destroyGUI()
    screenGui:Destroy()
    floatingButton:Destroy()
end

-- Обработчик плавающей кнопки
floatingButton.MouseButton1Click:Connect(function()
    setFullHide(false)
end)

-- Создание вкладок (увеличенные кнопки для мобильных)
local function createTabs()
    local yOffset = 0
    local buttonHeight = 55 -- увеличено для удобного нажатия
    local buttonSpacing = 8
    
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.name .. "Tab"
        tabButton.Size = UDim2.new(1, -20, 0, buttonHeight)
        tabButton.Position = UDim2.new(0, 20, 0, yOffset)
        tabButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        tabButton.BackgroundTransparency = 0.5
        tabButton.Text = tab.icon .. "  " .. tab.name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 16
        tabButton.TextXAlignment = Enum.TextXAlignment.Center
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.BorderSizePixel = 0
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 5, 0, 10)
        indicator.Position = UDim2.new(0, 5, 0.5, -4)
        indicator.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = tabButton
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        local originalX = tabButton.Position.X.Offset
        local currentY = tabButton.Position.Y.Offset
        
        tabButton.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(tabButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Position = UDim2.new(0, originalX + 5, 0, currentY)})
            hoverTween:Play()
        end)
        
        tabButton.MouseLeave:Connect(function()
            local hoverTween = TweenService:Create(tabButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Position = UDim2.new(0, originalX, 0, currentY)})
            hoverTween:Play()
        end)
        
        tabButton.Parent = tabsContainer
        tabButtons[tab.name] = {
            button = tabButton,
            indicator = indicator,
            originalX = originalX,
            yOffset = yOffset
        }
        
        yOffset = yOffset + buttonHeight + buttonSpacing
    end
end

local function animateIndicator(indicator, show)
    local targetTransparency = show and 0 or 1
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if show then
        indicator.Size = UDim2.new(0, 3, 0, 6)
        indicator.BackgroundTransparency = 0.8
        local sizeTween = TweenService:Create(indicator, tweenInfo, {Size = UDim2.new(0, 5, 0, 10)})
        local alphaTween = TweenService:Create(indicator, tweenInfo, {BackgroundTransparency = targetTransparency})
        sizeTween:Play()
        alphaTween:Play()
    else
        local alphaTween = TweenService:Create(indicator, tweenInfo, {BackgroundTransparency = targetTransparency})
        alphaTween:Play()
    end
end

-- Функция для обработки сенсорного ввода на слайдере
local function makeSliderTouchable(sliderBar, sliderHandle, updateCallback)
    local dragging = false
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateCallback()
        end
    end
    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateCallback()
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    sliderBar.InputBegan:Connect(onInputBegan)
    sliderBar.InputChanged:Connect(onInputChanged)
    sliderBar.InputEnded:Connect(onInputEnded)
    sliderHandle.InputBegan:Connect(onInputBegan)
    sliderHandle.InputChanged:Connect(onInputChanged)
    sliderHandle.InputEnded:Connect(onInputEnded)
end

local function switchTab(tabName)
    if activeTab == tabName then return end
    activeTab = tabName
    
    local contentFadeOut = TweenService:Create(contentContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
        {BackgroundTransparency = 1})
    contentFadeOut:Play()
    
    task.wait(0.1)
    
    for name, data in pairs(tabButtons) do
        if name == tabName then
            local bgTween = TweenService:Create(data.button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundColor3 = Color3.fromRGB(50, 70, 120), BackgroundTransparency = 0.3})
            bgTween:Play()
            data.button.TextColor3 = Color3.fromRGB(255, 255, 255)
            animateIndicator(data.indicator, true)
        else
            local bgTween = TweenService:Create(data.button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundColor3 = Color3.fromRGB(15, 15, 15), BackgroundTransparency = 0.5})
            bgTween:Play()
            data.button.TextColor3 = Color3.fromRGB(180, 180, 200)
            animateIndicator(data.indicator, false)
        end
    end
    
    for _, child in ipairs(contentContainer:GetChildren()) do
        child:Destroy()
    end
    
    -- ========== ВКЛАДКА PLAYER ==========
    if tabName == "Player" then
        local playerLabel = Instance.new("TextLabel")
        playerLabel.Size = UDim2.new(1, -20, 0, 25)
        playerLabel.Position = UDim2.new(0, 20, 0, 10)
        playerLabel.BackgroundTransparency = 1
        playerLabel.Text = "" .. player.Name
        playerLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        playerLabel.TextSize = 14
        playerLabel.Font = Enum.Font.GothamMedium
        playerLabel.TextXAlignment = Enum.TextXAlignment.Left
        playerLabel.Parent = contentContainer
        
        local speedBg = Instance.new("Frame")
        speedBg.Size = UDim2.new(1, -370, 0, 80)
        speedBg.Position = UDim2.new(0, 20, 0, 45)
        speedBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        speedBg.BackgroundTransparency = 0.4
        speedBg.BorderSizePixel = 0
        speedBg.Parent = contentContainer
        
        local speedBgCorner = Instance.new("UICorner")
        speedBgCorner.CornerRadius = UDim.new(0, 6)
        speedBgCorner.Parent = speedBg
        
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0, 50, 0, 25)
        speedLabel.Position = UDim2.new(0, 15, 0, 5)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "Speed"
        speedLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        speedLabel.TextSize = 13
        speedLabel.Font = Enum.Font.GothamBold
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.Parent = speedBg
        
        local speedValue = Instance.new("TextLabel")
        speedValue.Size = UDim2.new(0, 40, 0, 25)
        speedValue.Position = UDim2.new(0, 70, 0, 5)
        speedValue.BackgroundTransparency = 1
        speedValue.Text = tostring(savedSpeed)
        speedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedValue.TextSize = 13
        speedValue.Font = Enum.Font.GothamBold
        speedValue.TextXAlignment = Enum.TextXAlignment.Left
        speedValue.Parent = speedBg
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(0, 180, 0, 6)
        sliderBar.Position = UDim2.new(0, 15, 0, 35)
        sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 105)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = speedBg
        
        local sliderBarCorner = Instance.new("UICorner")
        sliderBarCorner.CornerRadius = UDim.new(1, 0)
        sliderBarCorner.Parent = sliderBar
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBar
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(1, 0)
        sliderFillCorner.Parent = sliderFill
        
        local sliderHandle = Instance.new("Frame")
        sliderHandle.Size = UDim2.new(0, 14, 0, 10)
        sliderHandle.Position = UDim2.new(0, 0, 0.5, -5)
        sliderHandle.BackgroundColor3 = Color3.fromRGB(175, 175, 185)
        sliderHandle.BorderSizePixel = 0
        sliderHandle.Parent = sliderBar
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0.5)
        handleCorner.Parent = sliderHandle
        
        local minLabel = Instance.new("TextLabel")
        minLabel.Size = UDim2.new(0, 20, 0, 15)
        minLabel.Position = UDim2.new(0, 15, 0, 48)
        minLabel.BackgroundTransparency = 1
        minLabel.Text = "10"
        minLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
        minLabel.TextSize = 10
        minLabel.Font = Enum.Font.Gotham
        minLabel.TextXAlignment = Enum.TextXAlignment.Left
        minLabel.Parent = speedBg
        
        local maxLabel = Instance.new("TextLabel")
        maxLabel.Size = UDim2.new(0, 25, 0, 15)
        maxLabel.Position = UDim2.new(0, 170, 0, 48)
        maxLabel.BackgroundTransparency = 1
        maxLabel.Text = "250"
        maxLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
        maxLabel.TextSize = 10
        maxLabel.Font = Enum.Font.Gotham
        maxLabel.TextXAlignment = Enum.TextXAlignment.Right
        maxLabel.Parent = speedBg
        
        local currentSpeed = savedSpeed
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        
        local function updatePlayerSpeed(speed)
            savedSpeed = speed
            currentSpeed = speed
            speedValue.Text = tostring(math.floor(speed))
            local percent = (speed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
            local barWidth = sliderBar.AbsoluteSize.X
            local handleWidth = sliderHandle.AbsoluteSize.X
            local newOffset = percent * (barWidth - handleWidth)
            if newOffset >= 0 then
                sliderHandle.Position = UDim2.new(0, newOffset, 0.5, -5)
            end
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            if humanoid then humanoid.WalkSpeed = speed end
        end
        
        -- Восстановление сохранённой скорости
        task.wait(0.05)
        local percent = (savedSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
        local barWidth = sliderBar.AbsoluteSize.X
        local handleWidth = sliderHandle.AbsoluteSize.X
        local newOffset = percent * (barWidth - handleWidth)
        if newOffset >= 0 then
            sliderHandle.Position = UDim2.new(0, newOffset, 0.5, -5)
        end
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        speedValue.Text = tostring(math.floor(savedSpeed))
        if humanoid then humanoid.WalkSpeed = savedSpeed end
        
        local function onCharacterAdded(character)
            humanoid = character:WaitForChild("Humanoid")
            task.wait(0.1)
            humanoid.WalkSpeed = savedSpeed
        end
        
        if player.Character then onCharacterAdded(player.Character) end
        player.CharacterAdded:Connect(onCharacterAdded)
        
        RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.WalkSpeed ~= savedSpeed and humanoid.WalkSpeed > 0 then
                humanoid.WalkSpeed = savedSpeed
            end
        end)
        
        local draggingHandle = false
        local mouse = player:GetMouse()
        
        local function updateSliderFromInput()
            local inputPos = UserInputService:GetMouseLocation()
            local barX = sliderBar.AbsolutePosition.X
            local barWidth = sliderBar.AbsoluteSize.X
            local handleWidth = sliderHandle.AbsoluteSize.X
            local percent = math.clamp((inputPos.X - barX) / (barWidth - handleWidth), 0, 1)
            updatePlayerSpeed(MIN_SPEED + percent * (MAX_SPEED - MIN_SPEED))
        end
        
        sliderHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHandle = true
                updateSliderFromInput()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if draggingHandle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSliderFromInput()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHandle = false
            end
        end)
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateSliderFromInput()
            end
        end)
        
        speedBg.BackgroundTransparency = 0.6
        TweenService:Create(speedBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0.4}):Play()
    
    -- ========== ВКЛАДКА AUTOFARM ==========
    elseif tabName == "AutoFarm" then
        local autoBg = Instance.new("Frame")
        autoBg.Size = UDim2.new(1, -40, 0, 280)
        autoBg.Position = UDim2.new(0, 20, 0, 45)
        autoBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        autoBg.BackgroundTransparency = 0.4
        autoBg.BorderSizePixel = 0
        autoBg.Parent = contentContainer
        
        local autoBgCorner = Instance.new("UICorner")
        autoBgCorner.CornerRadius = UDim.new(0, 6)
        autoBgCorner.Parent = autoBg
        
        -- Auto Dig Toggle
        local digLabel = Instance.new("TextLabel")
        digLabel.Size = UDim2.new(0, 80, 0, 40)
        digLabel.Position = UDim2.new(0, 15, 0, 10)
        digLabel.BackgroundTransparency = 1
        digLabel.Text = "Auto Dig"
        digLabel.TextColor3 = Color3.fromRGB(80, 120, 255)
        digLabel.TextSize = 15
        digLabel.Font = Enum.Font.GothamBold
        digLabel.TextXAlignment = Enum.TextXAlignment.Left
        digLabel.Parent = autoBg
        
        local digToggleBg = Instance.new("Frame")
        digToggleBg.Size = UDim2.new(0, 40, 0, 20)
        digToggleBg.Position = UDim2.new(0, 15, 0, 55)
        digToggleBg.BackgroundColor3 = isDigActive and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(50, 50, 70)
        digToggleBg.BorderSizePixel = 0
        digToggleBg.Parent = autoBg
        
        local digToggleBgCorner = Instance.new("UICorner")
        digToggleBgCorner.CornerRadius = UDim.new(1, 0)
        digToggleBgCorner.Parent = digToggleBg
        
        local digToggleHandle = Instance.new("Frame")
        digToggleHandle.Size = UDim2.new(0, 16, 0, 16)
        digToggleHandle.Position = UDim2.new(0, isDigActive and 22 or 2, 0.5, -8)
        digToggleHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        digToggleHandle.BorderSizePixel = 0
        digToggleHandle.Parent = digToggleBg
        
        local digHandleCorner = Instance.new("UICorner")
        digHandleCorner.CornerRadius = UDim.new(1, 0)
        digHandleCorner.Parent = digToggleHandle
        
        local digStatus = Instance.new("TextLabel")
        digStatus.Size = UDim2.new(0, 50, 0, 40)
        digStatus.Position = UDim2.new(0, 65, 0, 50)
        digStatus.BackgroundTransparency = 1
        digStatus.Text = isDigActive and "ON" or "OFF"
        digStatus.TextColor3 = isDigActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        digStatus.TextSize = 14
        digStatus.Font = Enum.Font.GothamBold
        digStatus.TextXAlignment = Enum.TextXAlignment.Left
        digStatus.Parent = autoBg
        
        local function updateDigUI()
            if isDigActive then
                TweenService:Create(digToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}):Play()
                TweenService:Create(digToggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Position = UDim2.new(0, 22, 0.5, -8)}):Play()
                digStatus.Text = "ON"
                digStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                TweenService:Create(digToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
                TweenService:Create(digToggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                digStatus.Text = "OFF"
                digStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        local function toggleDig()
            isDigActive = not isDigActive
            updateDigUI()
            if isDigActive then
                if digLoop then return end
                digLoop = RunService.Stepped:Connect(function()
                    dig()
                    wait(0.2)
                end)
            else
                if digLoop then
                    digLoop:Disconnect()
                    digLoop = nil
                end
            end
        end
        
        digToggleBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleDig()
            end
        end)
        
        digToggleHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleDig()
            end
        end)
        
        if isDigActive then
            updateDigUI()
            if not digLoop then
                digLoop = RunService.Stepped:Connect(function()
                    dig()
                    wait(0.2)
                end)
            end
        end
        
        -- Dropdown для выбора поля
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(0, 80, 0, 40)
        dropdownLabel.Position = UDim2.new(0, 15, 0, 95)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = "Выбор поля"
        dropdownLabel.TextColor3 = Color3.fromRGB(80, 120, 255)
        dropdownLabel.TextSize = 15
        dropdownLabel.Font = Enum.Font.GothamBold
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = autoBg
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0, 200, 0, 35)
        dropdownButton.Position = UDim2.new(0, 15, 0, 135)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        dropdownButton.Text = selectedField
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.TextSize = 14
        dropdownButton.Font = Enum.Font.GothamMedium
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Parent = autoBg
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 8)
        dropdownCorner.Parent = dropdownButton
        
        local dropdownArrow = Instance.new("TextLabel")
        dropdownArrow.Size = UDim2.new(0, 30, 0, 35)
        dropdownArrow.Position = UDim2.new(1, -35, 0, 0)
        dropdownArrow.BackgroundTransparency = 1
        dropdownArrow.Text = "▼"
        dropdownArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
        dropdownArrow.TextSize = 14
        dropdownArrow.Font = Enum.Font.GothamBold
        dropdownArrow.Parent = dropdownButton
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Name = "DropdownList"
        dropdownList.Size = UDim2.new(0, 200, 0, 0)
        dropdownList.Position = UDim2.new(0, 15, 0, 170)
        dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        dropdownList.BackgroundTransparency = 0.95
        dropdownList.BorderSizePixel = 0
        dropdownList.ClipsDescendants = true
        dropdownList.Visible = false
        dropdownList.Parent = autoBg
        
        local dropdownListCorner = Instance.new("UICorner")
        dropdownListCorner.CornerRadius = UDim.new(0, 8)
        dropdownListCorner.Parent = dropdownList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = dropdownList
        
        local fieldOptions = {"Sunflower Field", "Stump Field", "Pepper Field", "Strawberry Field", "Rose Field"}
        
        for i, field in ipairs(fieldOptions) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 40)
            optionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            optionBtn.Text = field
            optionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionBtn.TextSize = 13
            optionBtn.Font = Enum.Font.GothamMedium
            optionBtn.BorderSizePixel = 0
            optionBtn.Parent = dropdownList
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 6)
            optionCorner.Parent = optionBtn
            
            optionBtn.MouseButton1Click:Connect(function()
                selectedField = field
                dropdownButton.Text = field
                dropdownList.Visible = false
                dropdownArrow.Text = "▼"
            end)
            
            optionBtn.MouseEnter:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            end)
            
            optionBtn.MouseLeave:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end)
        end
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropdownList.Size = UDim2.new(0, 200, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        local isOpen = false
        dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownList.Visible = isOpen
            dropdownArrow.Text = isOpen and "▲" or "▼"
            if isOpen then
                TweenService:Create(dropdownList, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {BackgroundTransparency = 0.1}):Play()
            end
        end)
        
        local teleportBtn = Instance.new("TextButton")
        teleportBtn.Size = UDim2.new(0, 200, 0, 35)
        teleportBtn.Position = UDim2.new(0, 15, 0, 225)
        teleportBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        teleportBtn.Text = "Телепорт на поле"
        teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        teleportBtn.TextSize = 14
        teleportBtn.Font = Enum.Font.GothamMedium
        teleportBtn.BorderSizePixel = 0
        teleportBtn.Parent = autoBg
        
        local teleportCorner = Instance.new("UICorner")
        teleportCorner.CornerRadius = UDim.new(0, 8)
        teleportCorner.Parent = teleportBtn
        
        teleportBtn.MouseButton1Click:Connect(function()
            local pos = fieldPositions[selectedField]
            if pos then
                teleportTo(pos)
            end
        end)
        
        autoBg.BackgroundTransparency = 0.6
        TweenService:Create(autoBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0.4}):Play()

    -- ========== ВКЛАДКА GODMODE ==========
    elseif tabName == "GodMode" then
        local godBg = Instance.new("Frame")
        godBg.Size = UDim2.new(1, -40, 0, 140)
        godBg.Position = UDim2.new(0, 20, 0, 45)
        godBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        godBg.BackgroundTransparency = 0.4
        godBg.BorderSizePixel = 0
        godBg.Parent = contentContainer
        
        local godBgCorner = Instance.new("UICorner")
        godBgCorner.CornerRadius = UDim.new(0, 6)
        godBgCorner.Parent = godBg
        
        local godLabel = Instance.new("TextLabel")
        godLabel.Size = UDim2.new(0, 100, 0, 40)
        godLabel.Position = UDim2.new(0, 15, 0, 15)
        godLabel.BackgroundTransparency = 1
        godLabel.Text = "God Mode"
        godLabel.TextColor3 = Color3.fromRGB(80, 120, 255)
        godLabel.TextSize = 15
        godLabel.Font = Enum.Font.GothamBold
        godLabel.TextXAlignment = Enum.TextXAlignment.Left
        godLabel.Parent = godBg
        
        local godToggleBg = Instance.new("Frame")
        godToggleBg.Size = UDim2.new(0, 40, 0, 20)
        godToggleBg.Position = UDim2.new(0, 15, 0, 65)
        godToggleBg.BackgroundColor3 = isGodModeActive and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(50, 50, 70)
        godToggleBg.BorderSizePixel = 0
        godToggleBg.Parent = godBg
        
        local godToggleBgCorner = Instance.new("UICorner")
        godToggleBgCorner.CornerRadius = UDim.new(1, 0)
        godToggleBgCorner.Parent = godToggleBg
        
        local godToggleHandle = Instance.new("Frame")
        godToggleHandle.Size = UDim2.new(0, 16, 0, 16)
        godToggleHandle.Position = UDim2.new(0, isGodModeActive and 22 or 2, 0.5, -8)
        godToggleHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        godToggleHandle.BorderSizePixel = 0
        godToggleHandle.Parent = godToggleBg
        
        local godHandleCorner = Instance.new("UICorner")
        godHandleCorner.CornerRadius = UDim.new(1, 0)
        godHandleCorner.Parent = godToggleHandle
        
        local godStatus = Instance.new("TextLabel")
        godStatus.Size = UDim2.new(0, 50, 0, 40)
        godStatus.Position = UDim2.new(0, 65, 0, 60)
        godStatus.BackgroundTransparency = 1
        godStatus.Text = isGodModeActive and "ON" or "OFF"
        godStatus.TextColor3 = isGodModeActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        godStatus.TextSize = 14
        godStatus.Font = Enum.Font.GothamBold
        godStatus.TextXAlignment = Enum.TextXAlignment.Left
        godStatus.Parent = godBg
        
        local function updateGodUI()
            if isGodModeActive then
                TweenService:Create(godToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}):Play()
                TweenService:Create(godToggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Position = UDim2.new(0, 22, 0.5, -8)}):Play()
                godStatus.Text = "ON"
                godStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                TweenService:Create(godToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
                TweenService:Create(godToggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                godStatus.Text = "OFF"
                godStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        local function toggleGodMode()
            isGodModeActive = not isGodModeActive
            updateGodUI()
            if isGodModeActive then
                setGodMode()
                if godLoop then return end
                godLoop = RunService.Heartbeat:Connect(function()
                    if isGodModeActive then
                        setGodMode()
                    end
                end)
            else
                if godLoop then
                    godLoop:Disconnect()
                    godLoop = nil
                end
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.MaxHealth = 100
                end
            end
        end
        
        godToggleBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleGodMode()
            end
        end)
        
        godToggleHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleGodMode()
            end
        end)
        
        if isGodModeActive then
            updateGodUI()
            if not godLoop then
                setGodMode()
                godLoop = RunService.Heartbeat:Connect(function()
                    if isGodModeActive then
                        setGodMode()
                    end
                end)
            end
        end
        
        godBg.BackgroundTransparency = 0.6
        TweenService:Create(godBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0.4}):Play()
    
    -- ========== ВКЛАДКА TELEPORTS ==========
    elseif tabName == "Teleports" then
        local teleBg = Instance.new("Frame")
        teleBg.Size = UDim2.new(1, -40, 0, 300)
        teleBg.Position = UDim2.new(0, 20, 0, 45)
        teleBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        teleBg.BackgroundTransparency = 0.4
        teleBg.BorderSizePixel = 0
        teleBg.Parent = contentContainer
        
        local teleBgCorner = Instance.new("UICorner")
        teleBgCorner.CornerRadius = UDim.new(0, 6)
        teleBgCorner.Parent = teleBg
        
        local yOffset = 15
        local teleports = {
            {"Sunflower Field", -212, 86, -225},
            {"Stump Field", -362, 85, -360},
            {"Pepper Field", -60, 85, -500},
            {"Strawberry Field", 190, 85, -360},
            {"Rose Field", 210, 85, -120}
        }
        
        for _, tp in ipairs(teleports) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -30, 0, 45)
            btn.Position = UDim2.new(0, 15, 0, yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.Text = "Телепорт в " .. tp[1]
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.Parent = teleBg
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                teleportTo(Vector3.new(tp[2], tp[3], tp[4]))
            end)
            
            yOffset = yOffset + 55
        end
        
        local hiveBtn = Instance.new("TextButton")
        hiveBtn.Size = UDim2.new(1, -30, 0, 45)
        hiveBtn.Position = UDim2.new(0, 15, 0, yOffset)
        hiveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        hiveBtn.Text = "Телепорт в улей"
        hiveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hiveBtn.TextSize = 14
        hiveBtn.Font = Enum.Font.GothamMedium
        hiveBtn.BorderSizePixel = 0
        hiveBtn.Parent = teleBg
        
        local hiveCorner = Instance.new("UICorner")
        hiveCorner.CornerRadius = UDim.new(0, 8)
        hiveCorner.Parent = hiveBtn
        
        hiveBtn.MouseButton1Click:Connect(function()
            local hive = workspace.HivePlatforms:FindFirstChild("Platform")
            if hive then
                teleportTo(hive.CFrame.Position + Vector3.new(0, 5, 0))
            end
        end)
        
        teleBg.BackgroundTransparency = 0.6
        TweenService:Create(teleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0.4}):Play()
    
    -- ========== ВКЛАДКА SETTINGS ==========
    elseif tabName == "Settings" then
        local settingsBg = Instance.new("Frame")
        settingsBg.Size = UDim2.new(1, -40, 0, 120)
        settingsBg.Position = UDim2.new(0, 20, 0, 45)
        settingsBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        settingsBg.BackgroundTransparency = 0.4
        settingsBg.BorderSizePixel = 0
        settingsBg.Parent = contentContainer
        
        local settingsBgCorner = Instance.new("UICorner")
        settingsBgCorner.CornerRadius = UDim.new(0, 6)
        settingsBgCorner.Parent = settingsBg
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -30, 0, 80)
        infoLabel.Position = UDim2.new(0, 15, 0, 15)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Для сворачивания используйте плавающую кнопку\n\nСделано Fe1zik"
        infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        infoLabel.TextSize = 12
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.Parent = settingsBg
        
        settingsBg.BackgroundTransparency = 0.6
        TweenService:Create(settingsBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0.4}):Play()
    end
    
    task.wait(0.05)
    local contentFadeIn = TweenService:Create(contentContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundTransparency = 1})
    contentFadeIn:Play()
end

-- Убираем клавишу Insert (она не нужна на телефоне)
-- Оставляем только плавающую кнопку

minimizeButton.MouseButton1Click:Connect(function()
    if not mainFrame.Visible then return end
    setMinimized(not isMinimized)
end)

closeButton.MouseButton1Click:Connect(function()
    destroyGUI()
end)

local dragging = false
local dragStart = nil

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset + delta.X,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset + delta.Y
        )
        dragStart = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

createTabs()
for name, data in pairs(tabButtons) do
    data.button.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end
task.wait(0.1)
switchTab("Player")
