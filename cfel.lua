--[[
    AURORA v3.1 | Profesjonalny cheat MM2 (2026)
    Autor: palofsc
    Poprawki: dzialajace zakladki, pelne GUI, optymalizacja, antyspam
]]

-- ===== SERWISY =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ===== KONFIGURACJA =====
local Config = {
    ESP = true,
    ESPRole = true,
    ESPName = true,
    ESPDistance = true,
    ESPBox = false,
    Aimbot = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotFOV = 150,
    AimbotSmooth = 0.25,
    AimbotVisible = true,
    HitboxExpander = false,
    HitboxSize = 12,
    AutoCollect = true,
    AutoCollectSpeed = 0.15,
    AutoTPEnds = true,
    AutoLobby = true,
    AntiFling = true,
    AntiVoid = true,
    AntiSpam = true,
    SpeedHack = false,
    SpeedValue = 50,
    NoClip = false,
    FullBright = true,
    GUIAccent = Color3.fromRGB(160, 80, 255),
    GUIAnimations = true,
}

-- ===== CACHE / ANTYSPAM =====
local Cache = {
    coins = {},
    lastScan = 0,
    scanInterval = 0.4,
    lastCollect = 0,
    lastHitbox = 0,
    lastESP = 0,
    remoteCalls = {},
    maxRemotePerSec = 5,
}

local function canCallRemote(name)
    if not Config.AntiSpam then return true end
    local now = tick()
    Cache.remoteCalls[name] = Cache.remoteCalls[name] or {}
    local calls = Cache.remoteCalls[name]
    local newCalls = {}
    for _, t in ipairs(calls) do
        if now - t < 1 then table.insert(newCalls, t) end
    end
    if #newCalls >= Cache.maxRemotePerSec then return false end
    table.insert(newCalls, now)
    Cache.remoteCalls[name] = newCalls
    return true
end

-- ===== GUI PARENT =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AuroraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local parented = false
if gethui then
    local ok, hui = pcall(gethui)
    if ok and hui then ScreenGui.Parent = hui; parented = true end
end
if not parented and syn and syn.protect_gui then
    local ok = pcall(function() syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui end)
    if ok then parented = true end
end
if not parented then
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if ok then parented = true end
end
if not parented then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ===== GŁÓWNE OKNO =====
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 520, 0, 480)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.GUIAccent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- ===== TITLE BAR =====
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 8, 0, 4)
Logo.BackgroundTransparency = 1
Logo.Text = "A"
Logo.TextColor3 = Config.GUIAccent
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 26
Logo.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -160, 1, 0)
TitleText.Position = UDim2.new(0, 50, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "AURORA  ·  v3.1"
TitleText.TextColor3 = Color3.fromRGB(240, 230, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 17
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -110, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 60, 1, 0)
StatusText.Position = UDim2.new(1, -100, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 120)
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 11
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = TitleBar

task.spawn(function()
    while ScreenGui.Parent do
        if Config.GUIAnimations then
            TweenService:Create(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.8)
            TweenService:Create(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
            task.wait(0.8)
        else
            task.wait(1)
        end
    end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- ===== ZAKŁADKI =====
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 34)
TabBar.Position = UDim2.new(0, 10, 0, 56)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local tabButtons = {}
local tabPages = {}
local activeTab = nil

local function createTab(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 94, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Btn.BorderSizePixel = 0
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 12
    Btn.LayoutOrder = order
    Btn.Parent = TabBar

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -110)
    Page.Position = UDim2.new(0, 10, 0, 100)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 5
    Page.ScrollBarImageColor3 = Config.GUIAccent
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = MainFrame

    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = Page

    tabButtons[name] = Btn
    tabPages[name] = Page

    Btn.MouseButton1Click:Connect(function()
        for n, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
            b.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        for n, p in pairs(tabPages) do p.Visible = false end
        Btn.BackgroundColor3 = Config.GUIAccent
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
        activeTab = name
    end)

    return Page
end

local PageMain = createTab("Główne", 1)
local PageCombat = createTab("Walka", 2)
local PageAuto = createTab("Auto", 3)
local PageProt = createTab("Ochrona", 4)
local PageMove = createTab("Ruch", 5)

-- Aktywuj pierwszą zakładkę
tabButtons["Główne"].BackgroundColor3 = Config.GUIAccent
tabButtons["Główne"].TextColor3 = Color3.fromRGB(255, 255, 255)
PageMain.Visible = true
activeTab = "Główne"

-- ===== FUNKCJE ELEMENTÓW =====
local function createToggle(parent, name, default, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 40, 0, 20)
    Dot.Position = UDim2.new(1, -50, 0.5, -10)
    Dot.BackgroundColor3 = default and Config.GUIAccent or Color3.fromRGB(50, 50, 65)
    Dot.BorderSizePixel = 0
    Dot.Parent = Button

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Dot

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = default
    Button.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Dot, TweenInfo.new(0.2), {BackgroundColor3 = state and Config.GUIAccent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

local function createSlider(parent, name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 54)
    Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 8)
    Bar.Position = UDim2.new(0, 10, 0, 34)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Config.GUIAccent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = Fill

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos)
            Label.Text = name .. ": " .. val
            callback(val)
        end
    end)
end

local function createButton(parent, name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Btn.BorderSizePixel = 0
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(230, 230, 240)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.Parent = parent

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 36)}):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)
end

-- ===== ESP =====
local ESPObjects = {}

local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.gui and obj.gui.Parent then obj.gui:Destroy() end
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
    end
    ESPObjects = {}
end

local function getRole(player)
    if player == LocalPlayer then return "TY" end
    local char = player.Character
    if not char then return "?" end
    local backpack = player:FindFirstChild("Backpack")
    local role = "Niewinny"
    if player:FindFirstChild("IsMurderer") or (backpack and backpack:FindFirstChild("Knife")) then role = "MORDERCA" end
    if player:FindFirstChild("IsSheriff") or (backpack and backpack:FindFirstChild("Gun")) then role = "SZERYF" end
    if player:FindFirstChild("IsHero") then role = "HERO" end
    return role
end

local function getRoleColor(role)
    if role == "MORDERCA" then return Color3.fromRGB(255, 30, 30) end
    if role == "SZERYF" then return Color3.fromRGB(30, 150, 255) end
    if role == "HERO" then return Color3.fromRGB(255, 215, 0) end
    if role == "TY" then return Color3.fromRGB(0, 255, 120) end
    return Color3.fromRGB(200, 200, 200)
end

local function createESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_" .. player.Name
    gui.Size = UDim2.new(0, 220, 0, 72)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = ScreenGui

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 22)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = ""
    roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.TextSize = 15
    roleLabel.TextStrokeTransparency = 0
    roleLabel.Parent = gui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = gui

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 40)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.TextStrokeTransparency = 0
    distLabel.Parent = gui

    local highlight = Instance.new("Highlight")
    highlight.Name = "HL_" .. player.Name
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ScreenGui

    ESPObjects[player] = {
        gui = gui,
        highlight = highlight,
        roleLabel = roleLabel,
        nameLabel = nameLabel,
        distLabel = distLabel,
    }
end

local function updateESP()
    if not Config.ESP then clearESP(); return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] then createESP(player) end
            local obj = ESPObjects[player]
            if not obj then continue end
            local char = player.Character
            local myChar = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    obj.gui.Adornee = char:FindFirstChild("Head") or char.HumanoidRootPart
                    local role = getRole(player)
                    local color = getRoleColor(role)
                    obj.roleLabel.Text = Config.ESPRole and role or ""
                    obj.roleLabel.TextColor3 = color
                    obj.nameLabel.Text = Config.ESPName and player.Name or ""
                    local dist = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                    obj.distLabel.Text = Config.ESPDistance and math.floor(dist) .. " studs" or ""
                    obj.highlight.FillColor = color
                    obj.highlight.OutlineColor = color
                    obj.highlight.Enabled = true
                else
                    obj.gui.Adornee = nil
                    obj.highlight.Enabled = false
                end
            else
                obj.gui.Adornee = nil
                obj.highlight.Enabled = false
            end
        end
    end
end

-- ===== HITBOX =====
local origSizes = {}
local function updateHitbox()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Config.HitboxExpander then
                        if not origSizes[hrp] then origSizes[hrp] = hrp.Size end
                        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                        hrp.Massless = true
                    else
                        if origSizes[hrp] then
                            hrp.Size = origSizes[hrp]
                            origSizes[hrp] = nil
                        end
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end

-- ===== SKAN MAPY =====
local function scanForCoins()
    local coins = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("coin") or n:find("money") or n:find("cash") then
                table.insert(coins, obj)
            end
        end
    end
    Cache.coins = coins
    return coins
end

-- ===== AUTO ZBIERANIE (TP DO MONET) =====
local function autoCollect()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local coins = Cache.coins
    if #coins == 0 then coins = scanForCoins() end
    local collected = 0
    for _, coin in ipairs(coins) do
        if coin and coin.Parent then
            hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))
            collected = collected + 1
            if collected >= 5 then break end
        end
    end
    if collected > 0 and Config.AutoLobby then
        task.wait(0.1)
        hrp.CFrame = CFrame.new(0, 300, 0)
    end
end

-- ===== AIMBOT =====
local function getClosestPlayer()
    local closest = nil
    local shortest = Config.AimbotFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist < shortest then
                            if Config.AimbotVisible then
                                local ray = Ray.new(Camera.CFrame.Position, (char.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 500)
                                local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char})
                                if hit then continue end
                            end
                            shortest = dist
                            closest = char.HumanoidRootPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

local aimbotActive = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.AimbotKey then aimbotActive = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.AimbotKey then aimbotActive = false end
end)

-- ===== ANTIFLING =====
local function antiFling()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.01, 0.01, 0, 0)
                part.Massless = true
            end)
        end
    end
    if hrp.Velocity.Magnitude > 500 then
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- ===== GŁÓWNA PĘTLA =====
RunService.RenderStepped:Connect(function()
    local now = tick()

    if now - Cache.lastESP > 0.05 then
        Cache.lastESP = now
        updateESP()
    end

    if now - Cache.lastHitbox > 0.2 then
        Cache.lastHitbox = now
        updateHitbox()
    end

    if Config.Aimbot and aimbotActive then
        local target = getClosestPlayer()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Config.AimbotSmooth)
        end
    end

    if now - Cache.lastCollect > Config.AutoCollectSpeed then
        Cache.lastCollect = now
        if Config.AutoCollect or Config.AutoTPEnds then autoCollect() end
        if now - Cache.lastScan > Cache.scanInterval then
            Cache.lastScan = now
            scanForCoins()
        end
    end

    if Config.AntiFling then antiFling() end

    if Config.AntiVoid then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart.Position.Y < -50 then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end

    if Config.SpeedHack then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = Config.SpeedValue
        end
    end

    if Config.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ===== FULLBRIGHT =====
if Config.FullBright then
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

-- ===== ZARZĄDZANIE GRACZAMI =====
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if Config.ESP then createESP(p) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        if ESPObjects[p].gui then ESPObjects[p].gui:Destroy() end
        if ESPObjects[p].highlight then ESPObjects[p].highlight:Destroy() end
        ESPObjects[p] = nil
    end
end)

-- ===== ZAWARTOŚĆ ZAKŁADEK =====

-- Główne
createToggle(PageMain, "ESP", Config.ESP, function(v) Config.ESP = v; if not v then clearESP() end end)
createToggle(PageMain, "ESP Rola", Config.ESPRole, function(v) Config.ESPRole = v end)
createToggle(PageMain, "ESP Nazwa", Config.ESPName, function(v) Config.ESPName = v end)
createToggle(PageMain, "ESP Dystans", Config.ESPDistance, function(v) Config.ESPDistance = v end)
createToggle(PageMain, "FullBright", Config.FullBright, function(v) Config.FullBright = v end)

-- Walka
createToggle(PageCombat, "Aimbot (E)", Config.Aimbot, function(v) Config.Aimbot = v end)
createSlider(PageCombat, "Aimbot FOV", 10, 500, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
createSlider(PageCombat, "Aimbot Smooth", 1, 100, 25, function(v) Config.AimbotSmooth = v / 100 end)
createToggle(PageCombat, "Aimbot Widocznosc", Config.AimbotVisible, function(v) Config.AimbotVisible = v end)
createToggle(PageCombat, "Hitbox Expander", Config.HitboxExpander, function(v) Config.HitboxExpander = v end)
createSlider(PageCombat, "Hitbox Rozmiar", 3, 50, Config.HitboxSize, function(v) Config.HitboxSize = v end)

-- Auto
createToggle(PageAuto, "Auto Zbieranie Monet", Config.AutoCollect, function(v) Config.AutoCollect = v end)
createSlider(PageAuto, "Szybkosc Zbierania", 1, 50, 15, function(v) Config.AutoCollectSpeed = v / 100 end)
createToggle(PageAuto, "Auto TP do Monet", Config.AutoTPEnds, function(v) Config.AutoTPEnds = v end)
createToggle(PageAuto, "Auto Lobby (gora mapy)", Config.AutoLobby, function(v) Config.AutoLobby = v end)
createButton(PageAuto, "Skanuj Mape Teraz", function()
    scanForCoins()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "AURORA",
            Text = "Znaleziono " .. #Cache.coins .. " monet.",
            Duration = 3,
        })
    end)
end)

-- Ochrona
createToggle(PageProt, "AntiFling", Config.AntiFling, function(v) Config.AntiFling = v end)
createToggle(PageProt, "AntiVoid", Config.AntiVoid, function(v) Config.AntiVoid = v end)
createToggle(PageProt, "AntiSpam", Config.AntiSpam, function(v) Config.AntiSpam = v end)

-- Ruch
createToggle(PageMove, "SpeedHack", Config.SpeedHack, function(v) Config.SpeedHack = v end)
createSlider(PageMove, "Speed Wartosc", 16, 300, Config.SpeedValue, function(v) Config.SpeedValue = v end)
createToggle(PageMove, "NoClip", Config.NoClip, function(v) Config.NoClip = v end)

-- ===== POWIADOMIENIE =====
task.spawn(function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "AURORA v3.1",
            Text = "Zaladowano. Wszystkie zakladki dzialaja.",
            Duration = 5,
        })
    end)
end)
