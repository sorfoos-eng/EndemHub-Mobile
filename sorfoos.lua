--[[
    Emergency Endem HUB - v8.0 (ALL FIXED)
    Creado para: Delta Mobile
    
    ARREGLOS:
    - SPECTATE: Ahora se pega la cámara al jugador y no se suelta.
    - HITBOX: Cabezas gigantes (Tamaño 15) funcionales para disparar.
    - DUPE: Velocidad de spam mejorada para glitches.
    - RESTO: Todo lo demás (TP, Home, Auto-Sell) sigue funcionando igual.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- == LIMPIEZA ==
if CoreGui:FindFirstChild("EndemHubV8") then
    CoreGui.EndemHubV8:Destroy()
end

-- == CONFIGURACIÓN (VARIABLES) ==
local States = {
    ESP = false,
    LowGFX = false,
    Fullbright = false,
    XRay = false,
    NoClip = false,
    AutoFarm = false, -- Auto-Loot
    Dupe = false,     -- Duplicador
    AutoSell = false, -- Auto Venta
    Hitbox = false,   -- Hitbox
    Spectating = false
}

local SellPosition = nil
local SpectateIndex = 1
local SpectateTarget = nil

-- == UI PRINCIPAL ==
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndemHubV8"
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
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
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
Title.Text = "Emergency Hub X | v8.0 Fixed"
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

-- UI HELPERS (TABS, TOGGLES, BUTTONS)
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "   " .. icon .. "  " .. name
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
    frame.Parent = parent
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

-- == SISTEMAS ARREGLADOS ==

-- 1. HITBOX EXPANDER (FIXED)
-- Usamos Heartbeat para asegurar que la física registre el tamaño nuevo
RunService.Heartbeat:Connect(function()
    if States.Hitbox then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                -- Tamaño aumentado a 15 para asegurar que no falles
                head.Size = Vector3.new(15, 15, 15)
                head.Transparency = 0.7 -- Transparente para ver
                head.CanCollide = false
                head.Color = Color3.fromRGB(255, 0, 0)
                head.Material = Enum.Material.Neon
            end
        end
    end
end)

-- 2. SPECTATE (FIXED)
-- Usamos RenderStepped para forzar la cámara frame por frame
RunService.RenderStepped:Connect(function()
    if States.Spectating and SpectateTarget then
        if SpectateTarget.Character and SpectateTarget.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = SpectateTarget.Character.Humanoid
        else
            -- Si el objetivo muere o desaparece, volver al jugador local
            States.Spectating = false
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

local function SpectateAction(mode)
    local plrs = Players:GetPlayers()
    
    if mode == "Stop" then
        States.Spectating = false
        SpectateTarget = nil
        if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character.Humanoid end
        return
    end
    
    -- Lógica de índice
    if mode == "Next" then SpectateIndex = SpectateIndex + 1 end
    if mode == "Prev" then SpectateIndex = SpectateIndex - 1 end
    
    if SpectateIndex > #plrs then SpectateIndex = 1 end
    if SpectateIndex < 1 then SpectateIndex = #plrs end
    
    local target = plrs[SpectateIndex]
    
    -- Evitar espectearse a uno mismo si es posible
    if target == LocalPlayer then
        SpectateIndex = SpectateIndex + 1
        if SpectateIndex > #plrs then SpectateIndex = 1 end
        target = plrs[SpectateIndex]
    end

    if target then
        SpectateTarget = target
        States.Spectating = true
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Espectando a:", Text=target.Name, Duration=2})
    end
end


-- 3. DUPE & AUTO-LOOT (FIXED)
-- Optimizado para no lagear pero spamear rápido
task.spawn(function()
    while true do
        -- AUTO-LOOT (Normal)
        if States.AutoFarm then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            if (prompt.Parent.Position - myPos).Magnitude < 15 then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        end
        
        -- DUPE (Spam Intenso)
        if States.Dupe then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    -- Buscamos prompts CERCANOS solamente (Optimización)
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent then
                            if (prompt.Parent.Position - myPos).Magnitude < 15 then
                                -- SPAM: Dispara 20 veces rapidísimo
                                task.spawn(function()
                                    for i=1, 20 do 
                                        fireproximityprompt(prompt) 
                                        task.wait() -- Micro espera
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        wait(0.2) -- Ciclo de búsqueda
    end
end)

-- 4. OTROS SISTEMAS (Visuals, NoClip, AutoSell)

-- Auto Sell
task.spawn(function()
    while true do
        if States.AutoSell and SellPosition then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(SellPosition)
                wait(0.5) -- Esperar en el punto de venta
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
        -- ESP
        if States.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    if not player.Character.Head:FindFirstChild("EndemESP") then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "EndemESP"
                        bg.Adornee = player.Character.Head
                        bg.Size = UDim2.new(0, 100, 0, 50)
                        bg.StudsOffset = Vector3.new(0, 2, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = player.Character.Head
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = player.Name
                        txt.TextColor3 = Color3.fromRGB(0, 255, 0)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 14
                        txt.Parent = bg
                    end
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "EndemESP" then v:Destroy() end
            end
        end
        
        -- Fullbright
        if States.Fullbright then
            Lighting.ClockTime = 12
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
        end
    end
end)


-- == CONSTRUCCIÓN DE LAS PESTAÑAS ==

-- [A] HOME TAB
local HomePage, HomeBtn = CreateTab("Home", "🏠")
local HomeList = Instance.new("UIListLayout", HomePage); HomeList.Padding = UDim.new(0, 8)

local lbl1 = Instance.new("TextLabel", HomePage)
lbl1.Text = "--- UTILIDADES ---"
lbl1.Size = UDim2.new(1,0,0,20); lbl1.BackgroundTransparency=1; lbl1.TextColor3=Color3.fromRGB(255,255,0); lbl1.Font=Enum.Font.GothamBold; lbl1.TextSize=10

CreateToggle(HomePage, "Auto-Loot (Taladro)", function(v) States.AutoFarm = v end)
CreateToggle(HomePage, "Dupe Glitch (Spam)", function(v) States.Dupe = v end)
CreateToggle(HomePage, "NoClip (Paredes)", function(v) States.NoClip = v end)
CreateToggle(HomePage, "X-Ray Visual", function(v) States.XRay = v; UpdateXRay() end)

local lbl2 = Instance.new("TextLabel", HomePage)
lbl2.Text = "--- VENTA AUTOMÁTICA ---"
lbl2.Size = UDim2.new(1,0,0,20); lbl2.BackgroundTransparency=1; lbl2.TextColor3=Color3.fromRGB(0,255,0); lbl2.Font=Enum.Font.GothamBold; lbl2.TextSize=10; lbl2.Parent=HomePage

CreateButton(HomePage, "📍 MARCAR DEALER (Donde estás)", Color3.fromRGB(200, 150, 0), function()
    if LocalPlayer.Character then
        SellPosition = LocalPlayer.Character.HumanoidRootPart.Position
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Posición Guardada", Text="Dealer establecido.", Duration=3})
    end
end)
CreateToggle(HomePage, "Auto-Sell Loop", function(v) States.AutoSell = v end)

-- [B] CHEATS TAB (REPARADO)
local CheatPage, CheatBtn = CreateTab("Cheats", "💀")
local CheatList = Instance.new("UIListLayout", CheatPage); CheatList.Padding = UDim.new(0, 8)

CreateToggle(CheatPage, "Hitbox Expander (Big Head)", function(v) States.Hitbox = v end)

-- Panel Spectate
local SpecFrame = Instance.new("Frame", CheatPage)
SpecFrame.Size = UDim2.new(1, 0, 0, 50)
SpecFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 6)

local BtnPrev = CreateButton(SpecFrame, "<", Color3.fromRGB(50,50,50), function() SpectateAction("Prev") end)
BtnPrev.Size = UDim2.new(0, 40, 0, 30); BtnPrev.Position = UDim2.new(0.05, 0, 0.2, 0)

local BtnStop = CreateButton(SpecFrame, "STOP VIEW", Color3.fromRGB(150,50,50), function() SpectateAction("Stop") end)
BtnStop.Size = UDim2.new(0, 100, 0, 30); BtnStop.Position = UDim2.new(0.35, 0, 0.2, 0)

local BtnNext = CreateButton(SpecFrame, ">", Color3.fromRGB(50,50,50), function() SpectateAction("Next") end)
BtnNext.Size = UDim2.new(0, 40, 0, 30); BtnNext.Position = UDim2.new(0.8, 0, 0.2, 0)

-- [C] VISUALS TAB
local VisualPage, VisualBtn = CreateTab("Visuals", "👁️")
local VisualList = Instance.new("UIListLayout", VisualPage); VisualList.Padding = UDim.new(0, 8)

CreateToggle(VisualPage, "ESP Names", function(v) States.ESP = v end)
CreateToggle(VisualPage, "Fullbright", function(v) States.Fullbright = v end)
CreateToggle(VisualPage, "Low Graphics", function(v) 
    States.LowGFX = v
    if v then Lighting.GlobalShadows = false end
end)

-- [D] TP TAB
local TPPage, TPBtn = CreateTab("TP", "✈️")
local TPGrid = Instance.new("UIGridLayout")
TPGrid.CellSize = UDim2.new(0.48, 0, 0, 35)
TPGrid.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
TPGrid.Parent = TPPage

local function createTPBtn(text, color, pos)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = TPPage
    Instance.new("UIStroke", b).Color = color
    Instance.new("UIStroke", b).Thickness = 1
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

-- Lista Completa TPs
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


-- DRAGGING
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Init
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
HomeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); HomeBtn.TextColor3 = Color3.fromRGB(255,255,255); HomePage.Visible = true

game:GetService("StarterGui"):SetCore("SendNotification", {Title="Endem Hub V8"; Text="ALL SYSTEMS FIXED"; Duration=5;})
