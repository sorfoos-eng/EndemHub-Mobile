--[[
    Emergency Endem HUB - v12.0 (ALL IN ONE + AGGRESSIVE LOOT)
    Creado para: Delta Mobile
    
    NOVEDADES v12.0:
    - [NUEVO] 🌟 BOTÓN "ALL": Hace Banco -> AFK -> Paquetería -> AFK.
    - [MEJORA] Rango de looteo aumentado a 50 studs (Agarra todo).
    - [MEJORA] Velocidad de interacción más agresiva.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- == LIMPIEZA ==
if CoreGui:FindFirstChild("EndemHubV12") then
    CoreGui.EndemHubV12:Destroy()
end

-- == CONFIGURACIÓN (VARIABLES) ==
local States = {
    ESP = false,
    LowGFX = false,
    Fullbright = false,
    XRay = false,
    NoClip = false,
    AutoFarm = false, 
    Dupe = false,     
    AutoSell = false, 
    Hitbox = false,   
    Spectating = false,
    AutoRoute = false,  -- Solo Paquetería
    AutoBank = false,   -- Solo Banco
    AutoJewelry = false,-- Solo Joyería
    AutoAll = false     -- TODO (Banco + Paq)
}

local SellPosition = nil
local SpectateIndex = 1
local SpectateTarget = nil

-- COORDENADAS RUTA PAQUETERÍA (1-10)
local RouteCoords = {
    Vector3.new(112.4, 73.6, 909.5),   -- 1
    Vector3.new(-967.7, 45.5, 225.5),  -- 2
    Vector3.new(-2081.4, 39.6, 398.7), -- 3
    Vector3.new(-1894.9, 39.3, -623.9),-- 4
    Vector3.new(-1681.1, 39.2, -1272.5),-- 5
    Vector3.new(-1318.0, 39.0, -1111.3),-- 6
    Vector3.new(-242.9, 44.6, -684.7), -- 7
    Vector3.new(495.6, 39.6, -1762.3), -- 8
    Vector3.new(461.8, 39.8, -2216.3), -- 9
    Vector3.new(808.4, 72.3, 248.4)    -- 10
}

-- COORDENADAS BANCO
local BankCoords = {
    Vector3.new(-455, 28, -1402),
    Vector3.new(-438, 28, -1396),
    Vector3.new(-453, 29, -1354),
    Vector3.new(-475, 29, -1363),
    Vector3.new(-401, 44, -1390)
}

-- COORDENADA JOYERÍA
local JewelrySpot = Vector3.new(-492, 25, 350)

local AFKCoord = Vector3.new(-255.0, 186.8, 479.2)

-- == UI PRINCIPAL ==
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndemHubV12"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- 1. BOTÓN "S"
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.9, -50, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "S"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(255, 0, 0)
BtnStroke.Thickness = 2
BtnStroke.Parent = ToggleBtn

-- 2. PANEL PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", MainFrame).Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Header.BackgroundTransparency = 0.9
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Endem Hub | v12.0 ALL IN ONE"
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0.25, 0, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
local SideList = Instance.new("UIListLayout")
SideList.Parent = Sidebar
SideList.Padding = UDim.new(0, 5)

-- CONTENT AREA
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(0.75, -10, 1, -45)
ContentContainer.Position = UDim2.new(0.25, 5, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local TabFrames = {}

-- FUNCIONES UI
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "    " .. icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    page.Parent = ContentContainer
    
    TabFrames[name] = page
    
    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                child.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        for _, p in pairs(TabFrames) do p.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
    return page, btn
end

local function CreateToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0.05, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 13
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(0.85, 0, 0.25, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(50, 255, 50)}):Play()
        else
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        end
        callback(on)
    end)
    local list = parent:FindFirstChildOfClass("UIListLayout")
    if list then list.Padding = UDim.new(0, 8) end
    return btn
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    local list = parent:FindFirstChildOfClass("UIListLayout")
    if list then list.Padding = UDim.new(0, 8) end
    return btn
end

-- == FUNCIONES LOGICAS ==

-- Presionar "1" dos veces para refrescar herramienta
local function PressKeyOne()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    end)
end

-- Función de Looteo agresivo en un punto
local function LootSpot(checkFlagName)
    local silenceTimer = 0        
    local maxTimeInSpot = 30      
    local spotStartTime = tick()
    
    while States[checkFlagName] do
        local foundSomething = false
        if (tick() - spotStartTime) > maxTimeInSpot then break end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, prompt in pairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent then
                    -- RANGO AUMENTADO A 50
                    if (prompt.Parent.Position - myPos).Magnitude < 50 then
                        foundSomething = true
                        fireproximityprompt(prompt)
                        task.wait(0.05) -- SPAM RAPIDO
                    end
                end
            end
        end
        
        if foundSomething then 
            silenceTimer = 0
            task.wait(0.2)
        else 
            silenceTimer = silenceTimer + 0.5
            task.wait(0.5) 
        end
        
        if silenceTimer >= 3 then break end
    end
end

-- RUTA INDIVIDUAL (Banco o Paquetería)
local function RunRoute(routePoints, routeName)
    local activeState = (routeName == "Bank") and "AutoBank" or "AutoRoute"
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Auto " .. routeName, Text="Iniciando...", Duration=3})

    task.spawn(function()
        for i, pos in ipairs(routePoints) do
            if not States[activeState] then break end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
            
            task.wait(1.0)
            PressKeyOne(); task.wait(0.6); PressKeyOne(); task.wait(0.6)
            
            LootSpot(activeState)
            task.wait(0.5)
        end
        
        if States[activeState] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AFKCoord)
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Fin Ruta", Text="TP a AFK.", Duration=5})
            States[activeState] = false
        end
    end)
end

-- === FUNCIÓN "ALL" (BANCO -> AFK -> PAQUETERÍA -> AFK) ===
local function StartAllRoutine()
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="AUTO ALL", Text="1. Iniciando Banco...", Duration=4})
    
    task.spawn(function()
        if not States.AutoAll then return end
        
        -- FASE 1: BANCO
        for i, pos in ipairs(BankCoords) do
            if not States.AutoAll then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
            task.wait(1.0)
            PressKeyOne(); task.wait(0.6); PressKeyOne(); task.wait(0.6)
            LootSpot("AutoAll")
            task.wait(0.5)
        end
        
        -- INTERMEDIO: AFK
        if not States.AutoAll then return end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Descanso", Text="Yendo a AFK antes de Paquetería...", Duration=3})
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AFKCoord)
        end
        task.wait(3) -- Esperar 3 seg en AFK
        
        -- FASE 2: PAQUETERÍA
        if not States.AutoAll then return end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Fase 2", Text="Iniciando Paquetería (1-10)...", Duration=3})
        
        for i, pos in ipairs(RouteCoords) do
            if not States.AutoAll then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
            task.wait(1.0)
            PressKeyOne(); task.wait(0.6); PressKeyOne(); task.wait(0.6)
            LootSpot("AutoAll")
            task.wait(0.5)
        end
        
        -- FINAL: AFK
        if States.AutoAll then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AFKCoord)
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="ALL COMPLETADO", Text="TP a zona AFK final.", Duration=5})
            States.AutoAll = false
        end
    end)
end

-- RUTA JOYERÍA
local function StartJewelry()
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Auto Jewelry", Text="Iniciando...", Duration=3})
    task.spawn(function()
        if not States.AutoJewelry then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(JewelrySpot)
        end
        task.wait(1.0)
        PressKeyOne(); task.wait(0.6); PressKeyOne(); task.wait(0.6)
        
        local silenceTimer = 0
        local maxTime = 120 
        local start = tick()
        
        while States.AutoJewelry do
            if (tick() - start) > maxTime then break end
            local found = false
            if LocalPlayer.Character then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent then
                        -- RANGO 100 PARA JOYERIA
                        if (prompt.Parent.Position - myPos).Magnitude < 100 then
                            found = true
                            fireproximityprompt(prompt)
                            task.wait(0.05)
                        end
                    end
                end
            end
            if found then silenceTimer = 0; task.wait(0.2)
            else silenceTimer = silenceTimer + 1; task.wait(1) end
            
            if silenceTimer >= 4 then break end
        end
        
        if States.AutoJewelry then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AFKCoord)
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Joyería Limpia", Text="TP a AFK.", Duration=5})
            States.AutoJewelry = false
        end
    end)
end

-- Server Hop
local function ServerHop()
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Server Hop", Text="Buscando servidor...", Duration=3})
    local PlaceId = game.PlaceId
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(Servers.data) do
        if s.playing ~= s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer)
            return
        end
    end
end

-- Utils Loops
task.spawn(function()
    while true do
        if States.AutoFarm then -- Loot manual
            pcall(function()
                if LocalPlayer.Character then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            if (prompt.Parent.Position - myPos).Magnitude < 20 then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        end
        if States.Dupe then -- Spam manual
            pcall(function()
                if LocalPlayer.Character then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            if (prompt.Parent.Position - myPos).Magnitude < 20 then
                                task.spawn(function() for i=1, 15 do fireproximityprompt(prompt); task.wait() end end)
                            end
                        end
                    end
                end
            end)
        end
        wait(0.1)
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        if States.AutoSell and SellPosition then
            if LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(SellPosition)
                wait(0.5)
            end
        elseif States.AutoSell and not SellPosition then
            States.AutoSell = false
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Error", Text="¡Marca el Dealer primero!", Duration=3})
        end
        wait(2)
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if States.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- Visuals
local function UpdateXRay()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if States.XRay then
                if part.Transparency < 0.5 then part.LocalTransparencyModifier = 0.6 end
            else
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

task.spawn(function()
    while true do
        wait(1)
        if States.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    if not player.Character.Head:FindFirstChild("EndemESP") then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "EndemESP"; bg.Adornee = player.Character.Head; bg.Size = UDim2.new(0, 100, 0, 50); bg.StudsOffset = Vector3.new(0, 2, 0); bg.AlwaysOnTop = true; bg.Parent = player.Character.Head
                        local txt = Instance.new("TextLabel"); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = player.Name; txt.TextColor3 = Color3.fromRGB(0, 255, 0); txt.Font = Enum.Font.GothamBold; txt.TextSize = 14; txt.Parent = bg
                    end
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do if v.Name == "EndemESP" then v:Destroy() end end
        end
        if States.Fullbright then Lighting.ClockTime = 12; Lighting.Brightness = 2; Lighting.FogEnd = 100000 end
    end
end)


-- == PESTAÑAS ==

-- [A] HOME
local HomePage, HomeBtn = CreateTab("Home", "🏠")
local HomeList = Instance.new("UIListLayout", HomePage); HomeList.Padding = UDim.new(0, 8)
local lbl1 = Instance.new("TextLabel", HomePage); lbl1.Text = "--- UTILIDADES ---"; lbl1.Size = UDim2.new(1,0,0,20); lbl1.BackgroundTransparency=1; lbl1.TextColor3=Color3.fromRGB(255,255,0); lbl1.Font=Enum.Font.GothamBold; lbl1.TextSize=10
CreateToggle(HomePage, "Auto-Loot (Taladro Manual)", function(v) States.AutoFarm = v end)
CreateToggle(HomePage, "Dupe Glitch (Spam)", function(v) States.Dupe = v end)
CreateToggle(HomePage, "NoClip (Paredes)", function(v) States.NoClip = v end)
CreateToggle(HomePage, "X-Ray Visual", function(v) States.XRay = v; UpdateXRay() end)
local lbl2 = Instance.new("TextLabel", HomePage); lbl2.Text = "--- VENTA / SERVER ---"; lbl2.Size = UDim2.new(1,0,0,20); lbl2.BackgroundTransparency=1; lbl2.TextColor3=Color3.fromRGB(0,255,0); lbl2.Font=Enum.Font.GothamBold; lbl2.TextSize=10; lbl2.Parent=HomePage
CreateButton(HomePage, "📍 MARCAR DEALER (Donde estás)", Color3.fromRGB(200, 150, 0), function()
    if LocalPlayer.Character then SellPosition = LocalPlayer.Character.HumanoidRootPart.Position; game:GetService("StarterGui"):SetCore("SendNotification", {Title="Guardado", Text="Dealer OK", Duration=3}) end
end)
CreateToggle(HomePage, "Auto-Sell Loop", function(v) States.AutoSell = v end)
CreateButton(HomePage, "🔀 SERVER HOP (Cambiar Server)", Color3.fromRGB(50, 50, 200), function() ServerHop() end)

-- [B] CHEATS
local CheatPage, CheatBtn = CreateTab("Cheats", "💀")
local CheatList = Instance.new("UIListLayout", CheatPage); CheatList.Padding = UDim.new(0, 8)
local lblCheat = Instance.new("TextLabel", CheatPage); lblCheat.Text = "--- AUTO FARMER ---"; lblCheat.Size = UDim2.new(1,0,0,20); lblCheat.BackgroundTransparency=1; lblCheat.TextColor3=Color3.fromRGB(255,170,0); lblCheat.Font=Enum.Font.GothamBold; lblCheat.TextSize=10

-- BOTON ALL
CreateButton(CheatPage, "🌟 ALL (Banco -> AFK -> Paq -> AFK)", Color3.fromRGB(255, 255, 0), function()
    States.AutoAll = true; States.AutoRoute = false; States.AutoBank = false; States.AutoJewelry = false
    StartAllRoutine()
end)

CreateButton(CheatPage, "🚜 Solo Paquetería (1-10)", Color3.fromRGB(0, 150, 255), function()
    States.AutoRoute = true; States.AutoAll = false; States.AutoBank = false; States.AutoJewelry = false
    RunRoute(RouteCoords, "Paquetería")
end)
CreateButton(CheatPage, "🏦 Solo Banco (Cajas)", Color3.fromRGB(255, 170, 0), function()
    States.AutoBank = true; States.AutoAll = false; States.AutoRoute = false; States.AutoJewelry = false
    RunRoute(BankCoords, "Bank")
end)
CreateButton(CheatPage, "💎 Solo Joyería (Cristal+Reloj)", Color3.fromRGB(170, 0, 255), function()
    States.AutoJewelry = true; States.AutoAll = false; States.AutoRoute = false; States.AutoBank = false
    StartJewelry()
end)

CreateButton(CheatPage, "🛑 DETENER TODO", Color3.fromRGB(200, 50, 50), function()
    States.AutoRoute = false; States.AutoBank = false; States.AutoJewelry = false; States.AutoAll = false
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Stop", Text="Todo detenido.", Duration=2})
end)

local lblCheat2 = Instance.new("TextLabel", CheatPage); lblCheat2.Text = "--- PVP ---"; lblCheat2.Size = UDim2.new(1,0,0,20); lblCheat2.BackgroundTransparency=1; lblCheat2.TextColor3=Color3.fromRGB(255,0,0); lblCheat2.Font=Enum.Font.GothamBold; lblCheat2.TextSize=10; lblCheat2.Parent=CheatPage
CreateToggle(CheatPage, "Hitbox Expander (Big Head)", function(v) States.Hitbox = v end)

-- [C] VISUALS
local VisualPage, VisualBtn = CreateTab("Visuals", "👁️")
local VisualList = Instance.new("UIListLayout", VisualPage); VisualList.Padding = UDim.new(0, 8)
CreateToggle(VisualPage, "ESP Names", function(v) States.ESP = v end)
CreateToggle(VisualPage, "Fullbright", function(v) States.Fullbright = v end)
CreateToggle(VisualPage, "Low Graphics", function(v) States.LowGFX = v; if v then Lighting.GlobalShadows = false end end)

-- [D] TP
local TPPage, TPBtn = CreateTab("TP", "✈️")
local TPGrid = Instance.new("UIGridLayout"); TPGrid.CellSize = UDim2.new(0.48, 0, 0, 35); TPGrid.CellPadding = UDim2.new(0.02, 0, 0.02, 0); TPGrid.Parent = TPPage
local function createTPBtn(text, color, pos)
    local b = Instance.new("TextButton"); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.Parent = TPPage
    Instance.new("UIStroke", b).Color = color; Instance.new("UIStroke", b).Thickness = 1; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function() if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end end)
end
local cPaq = Color3.fromRGB(0, 255, 255)
createTPBtn("Paquetería 1", cPaq, Vector3.new(112.4, 73.6, 909.5))
createTPBtn("Paquetería 2", cPaq, Vector3.new(-967.7, 45.5, 225.5))
createTPBtn("Paquetería 3", cPaq, Vector3.new(-2081.4, 39.6, 398.7))
createTPBtn("Paquetería 4", cPaq, Vector3.new(-1894.9, 39.3, -623.9))
createTPBtn("Paquetería 5", cPaq, Vector3.new(-1681.1, 39.2, -1272.5))
createTPBtn("Paquetería 6", cPaq, Vector3.new(-1318.0, 39.0, -1111.3))
createTPBtn("Paquetería 7", cPaq, Vector3.new(-242.9, 44.6, -684.7))
createTPBtn("Paquetería 8", cPaq, Vector3.new(495.6, 39.6, -1762.3))
createTPBtn("Paquetería 9", cPaq, Vector3.new(461.8, 39.8, -2216.3))
createTPBtn("Paquetería 10", cPaq, Vector3.new(808.4, 72.3, 248.4))
createTPBtn("Banco", Color3.fromRGB(46, 204, 113), Vector3.new(-478.2, 29.9, -1386.5))
createTPBtn("Joyería", Color3.fromRGB(155, 89, 182), Vector3.new(-510.2, 50.2, 322.2))
createTPBtn("AFK Zone", Color3.fromRGB(255, 50, 50), Vector3.new(-255.0, 186.8, 479.2))

-- DRAG & INIT
local dragging, dragInput, dragStart, startPos
local function update(input) local delta = input.Position - dragStart; ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
ToggleBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
HomeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); HomeBtn.TextColor3 = Color3.fromRGB(255,255,255); HomePage.Visible = true

game:GetService("StarterGui"):SetCore("SendNotification", {Title="Endem Hub V12.0"; Text="READY: PRESS ALL"; Duration=5;})
