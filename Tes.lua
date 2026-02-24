-- [[ TioHub V12.0 - ORGANIZED WITH GODMODE INTEGRATED ]] --

print("[TioHub] Starting load...")

repeat task.wait() until game:IsLoaded()
print("[TioHub] Game loaded!")

-- [1. SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui", 15)
if not pgui then warn("[TioHub] PlayerGui not found!") return end
local camera = workspace.CurrentCamera

-- [2. GLOBAL STATE]
local isGodmode = false
local ghostClone = nil
local noclipConn = nil
local heartbeatConn = nil

-- [3. CLEANUP FUNCTION]
local function ResetState()
    isGodmode = false

    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end

    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.Landed)
        end

        camera.CameraSubject = hum

        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
                v.AssemblyLinearVelocity = Vector3.zero
            end
        end

        if ghostClone and root then
            root.CFrame = ghostClone:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 2, 0)
        end

        if ghostClone then ghostClone:Destroy(); ghostClone = nil end
    end
end

-- [4. CLEAN OLD GUI]
for _, gui in pairs(pgui:GetChildren()) do
    if gui.Name == "TioHub_Template" then gui:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "TioHub_Template"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 9999  -- Biar pasti di atas semua GUI
sg.Parent = pgui

print("[TioHub] ScreenGui created")

-- [5. FLOATING TOGGLE BUTTON (LOGO)]
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleButton.Image = "rbxassetid://128938769930061"  -- Ganti kalau mau logo lain
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Draggable = true
ToggleButton.Parent = sg
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0.3, 0)
local stroke = Instance.new("UIStroke", ToggleButton)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2

print("[TioHub] ToggleButton ready")

-- [6. MAIN UI FRAME]
local MainUI = Instance.new("Frame")
MainUI.Size = UDim2.new(0, 450, 0, 280)
MainUI.Position = UDim2.new(0.5, 0, 0.5, 0)
MainUI.AnchorPoint = Vector2.new(0.5, 0.5)
MainUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainUI.Visible = false
MainUI.Parent = sg
Instance.new("UICorner", MainUI).CornerRadius = UDim.new(0, 8)

-- [7. NAVIGATION BAR (SIDEBAR)]
local NavigationBar = Instance.new("Frame")
NavigationBar.Size = UDim2.new(0.3, 0, 1, 0)
NavigationBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
NavigationBar.Parent = MainUI
Instance.new("UICorner", NavigationBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0.2, 0)
TitleLabel.Text = "TIOHUB V12"
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = NavigationBar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0.75, 0)
TabContainer.Position = UDim2.new(0, 0, 0.2, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = NavigationBar
local tabLayout = Instance.new("UIListLayout", TabContainer)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Padding = UDim.new(0, 6)

-- [8. CONTENT AREA]
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(0.65, 0, 0.8, 0)
ContentArea.Position = UDim2.new(0.32, 0, 0.15, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainUI

-- [9. PAGES SYSTEM]
local Pages = {}

local function CreatePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8)
    p.Parent = ContentArea
    Pages[name] = p
    return p
end

local function CreateTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85, 0, 0, 35)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", b)
    b.Parent = TabContainer
    b.MouseButton1Click:Connect(function()
        for _, pg in pairs(Pages) do pg.Visible = false end
        Pages[name].Visible = true
    end)
end

-- Buat halaman
local PageMain = CreatePage("Main")
PageMain.Visible = true
CreateTab("Main")

-- [10. FITUR GODMODE (GHOST CLONE + NOCLIP)]
local GodmodeToggle = Instance.new("TextButton")
GodmodeToggle.Size = UDim2.new(0.9, 0, 0, 40)
GodmodeToggle.Text = "Godmode: OFF"
GodmodeToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
GodmodeToggle.TextColor3 = Color3.new(1,1,1)
GodmodeToggle.Font = Enum.Font.GothamBold
GodmodeToggle.Parent = PageMain

GodmodeToggle.MouseButton1Click:Connect(function()
    isGodmode = not isGodmode
    GodmodeToggle.Text = isGodmode and "Godmode: ON" or "Godmode: OFF"
    GodmodeToggle.BackgroundColor3 = isGodmode and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)

    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    if isGodmode then
        char.Archivable = true
        ghostClone = char:Clone()
        ghostClone.Name = "RagilGhost"
        ghostClone.Parent = workspace
        char.Archivable = false

        for _, v in pairs(ghostClone:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.5
                v.CanCollide = true
            end
        end

        hum.PlatformStand = true
        camera.CameraSubject = ghostClone.Humanoid

        noclipConn = RunService.Stepped:Connect(function()
            if isGodmode and char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)

        heartbeatConn = RunService.Heartbeat:Connect(function()
            if ghostClone and char:FindFirstChild("HumanoidRootPart") then
                ghostClone.Humanoid:Move(hum.MoveDirection)
                ghostClone.Humanoid.Jump = hum.Jump
                root.CFrame = ghostClone.HumanoidRootPart.CFrame * CFrame.new(0, -10, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            else
                ResetState()
            end
        end)
    else
        ResetState()
    end
end)

-- [11. TOMBOL BUKA/TUTUP]
ToggleButton.MouseButton1Click:Connect(function()
    MainUI.Visible = not MainUI.Visible
    print("[TioHub] GUI toggled: " .. tostring(MainUI.Visible))
end)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
CloseButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseButton)
CloseButton.Parent = MainUI
CloseButton.MouseButton1Click:Connect(function()
    MainUI.Visible = false
end)

-- Resize bebas dengan drag corner (kanan bawah)
local ResizeCorner = Instance.new("TextButton")
ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
ResizeCorner.Position = UDim2.new(1, -20, 1, -20)
ResizeCorner.BackgroundTransparency = 1
ResizeCorner.Text = ""
ResizeCorner.Parent = MainUI

local resizing = false
local startMousePos, startSize

ResizeCorner.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        startMousePos = input.Position
        startSize = MainUI.Size
    end
end)

ResizeCorner.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startMousePos
        local newWidth = startSize.X.Offset + delta.X
        local newHeight = startSize.Y.Offset + delta.Y
        
        -- Minimal ukuran biar ga hilang
        newWidth = math.max(200, newWidth)
        newHeight = math.max(150, newHeight)
        MainUI.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

warn("TioHub V12 Loaded! 🥵🔥⚡ - Look for floating logo (red stroke) in top-left!")
print("[TioHub] Ready! Tap the logo to open GUI.")