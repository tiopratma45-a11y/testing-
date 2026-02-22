-- [[ TioHub V BETA]] --
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local pgui = lp:WaitForChild("PlayerGui")
local uis = game:GetService("UserInputService")

-- [ 1. VARS ASLI DARI SCRIPT LU ] --
local autoFish = false
local castDelay = 0.5
local completeDelay = 1
local instantCatch = true
local autoSellTime = false
local autoSellFull = false 
local sellDelay = 60
local maxInv = 50
local autoEquipRod = false
local antiStaff = false

-- [ 2. FUNGSI LOGIKA ASLI DARI SCRIPT LU ] --
local function getNet()
    return RS:WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_net@0.2.0"].net
end

local function sellAll()
   pcall(function() 
      getNet()["RF/SellAllItems"]:InvokeServer()
   end)
end

local function equipRod()
    local char = lp.Character
    if char and not char:FindFirstChildWhichIsA("Tool") then
        pcall(function()
            getNet()["RE/EquipToolFromHotbar"]:FireServer(1) 
        end)
    end
end

-- [ 3. LOOP UTAMA ] --
task.spawn(function()
   while task.wait(0.1) do
      if autoEquipRod then equipRod() end
      if autoFish then
         pcall(function()
            local Net = getNet()
            Net["RF/ChargeFishingRod"]:InvokeServer(1756863567.217075)
            task.wait(castDelay)
            Net["RF/RequestFishingMinigameStarted"]:InvokeServer(-1, 1, 1770772112.401775)
            task.wait(completeDelay)
            if instantCatch then Net["RF/CatchFishCompleted"]:InvokeServer() end
         end)
         task.wait(0.5)
      end
      if autoSellFull then
         local bp = lp:FindFirstChild("Backpack")
         if bp and #bp:GetChildren() >= maxInv then sellAll() end
      end
   end
end)

-- [ 4. GUI CONSTRUCTION DENGAN RESIZE & MINIMIZE ] --
if pgui:FindFirstChild("TioHub_Final") then pgui.TioHub_Final:Destroy() end
local sg = Instance.new("ScreenGui", pgui)
sg.Name = "TioHub_Final"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- VARIABLE UNTUK RESIZE
local isMinimized = false
local originalSize = UDim2.new(0, 500, 0, 380)  -- UKURAN DIPERBESAR biar muat
local minimizedSize = UDim2.new(0, 200, 0, 40)  -- UKURAN MINIMIZE
local isDragging = false
local dragStart = nil
local startPos = nil

-- FLOATING LOGO (TETAP ADA)
local openBtn = Instance.new("ImageButton", sg)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
openBtn.Image = "rbxassetid://90704053210335" 
openBtn.Draggable = true
openBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
openBtn.BackgroundTransparency = 0.2
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0.3, 0)
Instance.new("UIStroke", openBtn).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", openBtn).Thickness = 2

-- MAIN FRAME (BISA DI-RESIZE)
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = originalSize
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)  -- Tengah layar
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Selectable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0.02, 0)

-- TITLE BAR (BUAT DRAG & MINIMIZE)
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0.02, 0)

-- TITLE TEXT
local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.5, 0, 1, 0)
titleText.Position = UDim2.new(0.1, 0, 0, 0)
titleText.Text = "⚡ TioHub V12.0"
titleText.TextColor3 = Color3.fromRGB(255, 100, 100)
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = "Left"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "🗕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.BackgroundTransparency = 0.5
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0.3, 0)

-- CLOSE/BACK BUTTON
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "🗙"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.BackgroundTransparency = 0.3
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0.3, 0)

-- RESIZE HANDLE (BUAT NGATUR UKURAN)
local resizeHandle = Instance.new("Frame", mainFrame)
resizeHandle.Size = UDim2.new(0, 15, 0, 15)
resizeHandle.Position = UDim2.new(1, -15, 1, -15)
resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
resizeHandle.BackgroundTransparency = 0.5
resizeHandle.ZIndex = 10
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0.3, 0)

local resizeIcon = Instance.new("TextLabel", resizeHandle)
resizeIcon.Size = UDim2.new(1, 0, 1, 0)
resizeIcon.Text = "◢"
resizeIcon.TextColor3 = Color3.new(1,1,1)
resizeIcon.BackgroundTransparency = 1
resizeIcon.Font = Enum.Font.Code
resizeIcon.TextSize = 12

-- SIDEBAR
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0.25, 0, 1, -30)  -- Dikurangi tinggi titleBar
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0.02, 0)

local navL = Instance.new("UIListLayout", sidebar)
navL.HorizontalAlignment = "Center"
navL.Padding = UDim.new(0, 5)
navL.VerticalAlignment = Enum.VerticalAlignment.Top

-- CONTAINER
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(0.7, 0, 0.85, -30)
container.Position = UDim2.new(0.27, 0, 0.12, 30)
container.BackgroundTransparency = 1

local pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 5
    p.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
    p.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pages[name] = p
    return p
end

local pgMain = CreatePage("Main")
local pgBack = CreatePage("Backpack")
local pgTele = CreatePage("Teleport")
pgMain.Visible = true

-- FUNGSI DRAG TITLE BAR
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- FUNGSI RESIZE
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Size
    end
end)

resizeHandle.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newWidth = math.max(300, startPos.X.Offset + delta.X)
        local newHeight = math.max(200, startPos.Y.Offset + delta.Y)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

resizeHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- FUNGSI MINIMIZE
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = minimizedSize
        sidebar.Visible = false
        container.Visible = false
        resizeHandle.Visible = false
        minBtn.Text = "🗖"
    else
        mainFrame.Size = originalSize
        sidebar.Visible = true
        container.Visible = true
        resizeHandle.Visible = true
        minBtn.Text = "🗕"
    end
end)

-- CLOSE BUTTON (SEBENERNYA HANYA MINIMIZE KE LOGO)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- OPEN BUTTON (DARI LOGO)
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        mainFrame.Size = originalSize
        isMinimized = false
        minBtn.Text = "🗕"
        sidebar.Visible = true
        container.Visible = true
        resizeHandle.Visible = true
    end
end)

-- UI BUILDER (DIPERBAIKI)
local function AddTab(name)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0.1, 0)
    b.MouseButton1Click:Connect(function()
        for _, pg in pairs(pages) do pg.Visible = false end
        pages[name].Visible = true
        -- Efek hover
        b.BackgroundColor3 = Color3.fromRGB(200,0,0)
        task.wait(0.1)
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    end)
end

local function AddToggle(parent, name, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 45)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    f.BackgroundTransparency = 0.2
    Instance.new("UICorner", f).CornerRadius = UDim.new(0.1, 0)
    
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(0.7, 0, 1, 0)
    tl.Position = UDim2.new(0.05, 0, 0, 0)
    tl.Text = name
    tl.TextColor3 = Color3.new(1,1,1)
    tl.BackgroundTransparency = 1
    tl.TextXAlignment = "Left"
    tl.Font = Enum.Font.Gotham
    tl.TextSize = 14
    tl.TextWrapped = true
    
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.2, 0, 0.7, 0)
    b.Position = UDim2.new(0.75, 0, 0.15, 0)
    b.Text = default and "ON" or "OFF"
    b.BackgroundColor3 = default and Color3.fromRGB(200,0,0) or Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0.2, 0)
    
    local s = default
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = s and "ON" or "OFF"
        b.BackgroundColor3 = s and Color3.fromRGB(200,0,0) or Color3.fromRGB(50,50,50)
        callback(s)
    end)
end

-- [ 5. POPULATE MENU ] --
AddTab("Main")
AddTab("Backpack")
AddTab("Teleport")

-- Tab Main
AddToggle(pgMain, "🐟 Auto Fish", false, function(v) autoFish = v end)
AddToggle(pgMain, "⚡ Instant Catch", true, function(v) instantCatch = v end)
AddToggle(pgMain, "🎣 Auto Equip Rod", false, function(v) autoEquipRod = v end)

-- Tab Backpack
AddToggle(pgBack, "💰 Auto Sell Full", false, function(v) autoSellFull = v end)
local btnSell = Instance.new("TextButton", pgBack)
btnSell.Size = UDim2.new(0.95, 0, 0, 45)
btnSell.Text = "💸 SELL ALL NOW"
btnSell.BackgroundColor3 = Color3.fromRGB(0,100,0)
btnSell.TextColor3 = Color3.new(1,1,1)
btnSell.Font = Enum.Font.GothamBold
btnSell.TextSize = 14
Instance.new("UICorner", btnSell).CornerRadius = UDim.new(0.1, 0)
btnSell.MouseButton1Click:Connect(sellAll)

-- Tab Teleport
local spots = {
    ["🏝️ Pulau Nelayan"] = CFrame.new(95, 9, 2800), 
    ["🌋 Kohana"] = CFrame.new(-641, 16, 611),
    ["🌿 Ancient Jungle"] = CFrame.new(1313.24, 6.62, -157.64),
    ["🏛️ Ancient Ruin"] = CFrame.new(6098.90, -585.92, 4654.14),
    ["🐠 Coral Reefs"] = CFrame.new(-3201.70, 4.62, 2108.83),
    ["🌋 Crater Island"] = CFrame.new(1005.46, 2.58, 5009.35),
    ["🌊 Esoteric Depth"] = CFrame.new(1986.02, 3.84, 1308.56),
    ["🔥 Kohana Volcano"] = CFrame.new(-566.12, 19.00, 152.72),
    ["💧 Lava Basin"] = CFrame.new(937.69, 67.85, -102.17),
    ["🏴‍☠️ Pirate Lake"] = CFrame.new(3408.83, 4.19, 3441.32),
    ["🔮 Secret Temple"] = CFrame.new(1449.44, -22.33, -635.33),
    ["👻 Tempat Ghostfin"] = CFrame.new(-3740.71, -134.22, -1010.29)
}

for n, cf in pairs(spots) do
    local tb = Instance.new("TextButton", pgTele)
    tb.Size = UDim2.new(0.95, 0, 0, 40)
    tb.Text = n
    tb.BackgroundColor3 = Color3.fromRGB(40,40,40)
    tb.TextColor3 = Color3.new(1,1,1)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 12
    tb.TextWrapped = true
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0.1, 0)
    tb.MouseButton1Click:Connect(function() 
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = cf end
    end)
end

-- Atur CanvasSize untuk Teleport
pgTele.CanvasSize = UDim2.new(0, 0, 0, #spots * 45)

print("🔥 TioHub V BETA!")