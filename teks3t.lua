--[[
    MAX CHEAT v2.0 | Profesjonalny cheat MM2
    Autor: palofsc
    Funkcje: ESP, Aimbot, AutoCollect, AutoTPEnds, HitboxExpander, AntiFling, AntiVoid, Speed, NoClip
    Poprawki: stabilny AutoCollect, brak TP do ludzi, naprawiony FOV, naprawiony ESP
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
    AutoCollectSpeed = 0.1,
    AutoTPEnds = true,
    AntiFling = true,
    AntiVoid = true,
    SpeedHack = false,
    SpeedValue = 50,
    FullBright = true,
    NoClip = false,
}

-- ===== GUI PARENT =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MaxCheatGUI_v2"
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
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(140, 0, 220)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "MAX CHEAT v2.0 | palofsc"
TitleText.TextColor3 = Color3.fromRGB(200, 120, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -62)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 0, 220)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- ===== FUNKCJE GUI =====
local function createToggle(name, default, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Button.BorderSizePixel = 0
    Button.Text = "  " .. name .. ": " .. (default and "ON" or "OFF")
    Button.TextColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = ScrollFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local state = default
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = "  " .. name .. ": " .. (state and "ON" or "OFF")
        Button.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
        callback(state)
    end)
end

local function createSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScrollFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 8)
    Bar.Position = UDim2.new(0, 10, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(140, 0, 220)
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

-- ===== ESP =====
local ESPObjects = {}

local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.gui and obj.gui.Parent then obj.gui:Destroy() end
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.box and obj.box.Parent then obj.box:Destroy() end
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
    gui.Size = UDim2.new(0, 220, 0, 70)
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

-- ===== HITBOX EXPANDER =====
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

-- ===== AUTO COLLECT / AUTO TP DO MONET =====
local function isCoin(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    return n:find("coin") or n:find("money") or n:find("cash") or n == "coin"
end

local function isGunOrKnife(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    return n:find("gun") or n:find("knife") or n:find("dropped")
end

local function collectAllCoins()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isCoin(obj) then
            obj.CFrame = hrp.CFrame
            count = count + 1
        end
    end
    return count
end

local function collectGunsKnives()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isGunOrKnife(obj) then
            obj.CFrame = hrp.CFrame
        end
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
local lastCollect = 0
local lastHitbox = 0
RunService.RenderStepped:Connect(function(dt)
    updateESP()

    local now = tick()
    if now - lastHitbox > 0.2 then
        updateHitbox()
        lastHitbox = now
    end

    if Config.Aimbot and aimbotActive then
        local target = getClosestPlayer()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Config.AimbotSmooth)
        end
    end

    if now - lastCollect > Config.AutoCollectSpeed then
        lastCollect = now
        if Config.AutoCollect then collectAllCoins() end
        if Config.AutoTPEnds then collectAllCoins() end
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

-- ===== PRZYCISKI GUI =====
createToggle("ESP", Config.ESP, function(v) Config.ESP = v; if not v then clearESP() end end)
createToggle("ESP Rola", Config.ESPRole, function(v) Config.ESPRole = v end)
createToggle("ESP Nazwa", Config.ESPName, function(v) Config.ESPName = v end)
createToggle("ESP Dystans", Config.ESPDistance, function(v) Config.ESPDistance = v end)
createToggle("Aimbot (E)", Config.Aimbot, function(v) Config.Aimbot = v end)
createSlider("Aimbot FOV", 10, 500, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
createSlider("Aimbot Smooth", 1, 100, 25, function(v) Config.AimbotSmooth = v / 100 end)
createToggle("Aimbot Widocznosc", Config.AimbotVisible, function(v) Config.AimbotVisible = v end)
createToggle("Hitbox Expander", Config.HitboxExpander, function(v) Config.HitboxExpander = v end)
createSlider("Hitbox Rozmiar", 3, 50, Config.HitboxSize, function(v) Config.HitboxSize = v end)
createToggle("Auto Zbieranie Monet", Config.AutoCollect, function(v) Config.AutoCollect = v end)
createSlider("Szybkosc Zbierania", 1, 50, 10, function(v) Config.AutoCollectSpeed = v / 100 end)
createToggle("Auto TP do Monet (50)", Config.AutoTPEnds, function(v) Config.AutoTPEnds = v end)
createToggle("AntiFling", Config.AntiFling, function(v) Config.AntiFling = v end)
createToggle("AntiVoid", Config.AntiVoid, function(v) Config.AntiVoid = v end)
createToggle("SpeedHack", Config.SpeedHack, function(v) Config.SpeedHack = v end)
createSlider("Speed Wartosc", 16, 300, Config.SpeedValue, function(v) Config.SpeedValue = v end)
createToggle("NoClip", Config.NoClip, function(v) Config.NoClip = v end)

-- ===== POWIADOMIENIE =====
task.spawn(function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MAX CHEAT v2.0",
            Text = "Zaladowano. AutoCollect aktywny - zbiera monety z calej mapy.",
            Duration = 5,
        })
    end)
end)
