--[[
    YourHub - UI/Window.lua

    Main window. Clean, modern, mobile-optimized.
    Draggable. Minimal glow/gradient.
    Tabs system terintegrasi.
]]

local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local CoreGui       = game:GetService("CoreGui")

local Theme         = require(script.Parent.Theme)
local Tabs          = require(script.Parent.Tabs)
local Components    = require(script.Parent.Components)
local Notifications = require(script.Parent.Parent.Features.Universal.Notifications)
local Constants     = require(script.Parent.Parent.Shared.Constants)
local Connections   = require(script.Parent.Parent.Core.Connections)

local Window = {}

-- ============================================================
-- INTERNAL
-- ============================================================
local _gui         = nil
local _mainFrame   = nil
local _isOpen      = true

-- ============================================================
-- CREATE
-- ============================================================
function Window.Create(gameConfig)
    local T = Theme.Get()

    -- Cleanup GUI lama jika ada (re-execute safe)
    local oldGui = CoreGui:FindFirstChild("YourHub_GUI")
    if oldGui then oldGui:Destroy() end

    -- --------------------------------------------------------
    -- SCREEN GUI
    -- --------------------------------------------------------
    _gui = Instance.new("ScreenGui")
    _gui.Name             = "YourHub_GUI"
    _gui.ResetOnSpawn     = false
    _gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    _gui.DisplayOrder     = 999
    _gui.Parent           = CoreGui

    -- --------------------------------------------------------
    -- MAIN FRAME
    -- --------------------------------------------------------
    _mainFrame = Instance.new("Frame")
    _mainFrame.Name             = "MainFrame"
    _mainFrame.Size             = UDim2.new(0, Constants.UI.WINDOW_WIDTH, 0, Constants.UI.WINDOW_HEIGHT)
    _mainFrame.Position         = UDim2.new(0.5, -Constants.UI.WINDOW_WIDTH/2, 0.5, -Constants.UI.WINDOW_HEIGHT/2)
    _mainFrame.BackgroundColor3 = T.Background
    _mainFrame.BorderSizePixel  = 0
    _mainFrame.Parent           = _gui

    Instance.new("UICorner", _mainFrame).CornerRadius = Theme.Corner.Window

    -- Subtle drop shadow (sangat ringan untuk mobile)
    local shadow = Instance.new("ImageLabel")
    shadow.Name                = "Shadow"
    shadow.Size                = UDim2.new(1, 20, 1, 20)
    shadow.Position            = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image               = "rbxassetid://6014261993"  -- blur image
    shadow.ImageColor3         = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency   = 0.7
    shadow.ScaleType           = Enum.ScaleType.Slice
    shadow.SliceCenter         = Rect.new(49, 49, 450, 450)
    shadow.ZIndex              = 0
    shadow.Parent              = _mainFrame

    -- --------------------------------------------------------
    -- TITLEBAR
    -- --------------------------------------------------------
    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundColor3 = T.Header
    titleBar.BorderSizePixel  = 0
    titleBar.ZIndex           = 2
    titleBar.Parent           = _mainFrame

    Instance.new("UICorner", titleBar).CornerRadius = Theme.Corner.Window

    -- Fix bottom corners titlebar
    local titleFix = Instance.new("Frame")
    titleFix.Size             = UDim2.new(1, 0, 0, 10)
    titleFix.Position         = UDim2.new(0, 0, 1, -10)
    titleFix.BackgroundColor3 = T.Header
    titleFix.BorderSizePixel  = 0
    titleFix.Parent           = titleBar

    -- Hub Name
    local hubName = Instance.new("TextLabel")
    hubName.Name              = "HubName"
    hubName.Size              = UDim2.new(0.6, 0, 1, 0)
    hubName.Position          = UDim2.new(0, 12, 0, 0)
    hubName.BackgroundTransparency = 1
    hubName.Text              = "✦ YourHub  •  " .. (gameConfig.Name or "Unknown")
    hubName.Font              = Theme.Fonts.Bold
    hubName.TextSize          = Theme.TextSizes.Title
    hubName.TextColor3        = T.HeaderText
    hubName.TextXAlignment    = Enum.TextXAlignment.Left
    hubName.ZIndex            = 3
    hubName.Parent            = titleBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name             = "CloseBtn"
    closeBtn.Size             = UDim2.new(0, 30, 0, 30)
    closeBtn.Position         = UDim2.new(1, -38, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "×"
    closeBtn.Font             = Theme.Fonts.Bold
    closeBtn.TextSize         = 18
    closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    closeBtn.ZIndex           = 4
    closeBtn.Parent           = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name               = "MinBtn"
    minBtn.Size               = UDim2.new(0, 30, 0, 30)
    minBtn.Position           = UDim2.new(1, -74, 0.5, -15)
    minBtn.BackgroundColor3   = Color3.fromRGB(220, 160, 30)
    minBtn.BorderSizePixel    = 0
    minBtn.Text               = "–"
    minBtn.Font               = Theme.Fonts.Bold
    minBtn.TextSize           = 18
    minBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
    minBtn.ZIndex             = 4
    minBtn.Parent             = titleBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    -- --------------------------------------------------------
    -- DRAG SYSTEM (mobile touch friendly)
    -- --------------------------------------------------------
    local dragging     = false
    local dragStartPos = nil
    local frameStartPos = nil

    local dragInput = titleBar

    dragInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging      = true
            dragStartPos  = input.Position
            frameStartPos = _mainFrame.Position
        end
    end)

    dragInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInput.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = input.Position - dragStartPos
            _mainFrame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- --------------------------------------------------------
    -- CLOSE & MINIMIZE ACTIONS
    -- --------------------------------------------------------
    closeBtn.MouseButton1Click:Connect(function()
        Window.Destroy()
    end)

    minBtn.MouseButton1Click:Connect(function()
        Window.Toggle()
    end)

    -- --------------------------------------------------------
    -- CONTENT AREA
    -- --------------------------------------------------------
    local contentFrame = Instance.new("Frame")
    contentFrame.Name             = "Content"
    contentFrame.Size             = UDim2.new(1, 0, 1, -42)
    contentFrame.Position         = UDim2.new(0, 0, 0, 42)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent           = _mainFrame

    -- --------------------------------------------------------
    -- BUILD TABS dari gameConfig.UITabs
    -- --------------------------------------------------------
    Tabs.Build(contentFrame, gameConfig)

    -- --------------------------------------------------------
    -- WATERMARK
    -- --------------------------------------------------------
    local watermark = Instance.new("TextLabel")
    watermark.Name              = "Watermark"
    watermark.Size              = UDim2.new(0, 200, 0, 20)
    watermark.Position          = UDim2.new(0, 5, 1, -25)
    watermark.BackgroundTransparency = 1
    watermark.Text              = "YourHub v1.0 | SlimeRNG"
    watermark.Font              = Theme.Fonts.Regular
    watermark.TextSize          = Theme.TextSizes.Small
    watermark.TextColor3        = T.TextDisabled
    watermark.TextXAlignment    = Enum.TextXAlignment.Left
    watermark.ZIndex            = 2
    watermark.Parent            = _mainFrame

    print("[Window] ✓ UI berhasil dibuat.")
    return _gui
end

-- ============================================================
-- TOGGLE (minimize/restore)
-- ============================================================
function Window.Toggle()
    if not _mainFrame then return end
    _isOpen = not _isOpen
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if _isOpen then
        TweenService:Create(_mainFrame, info, {
            Size = UDim2.new(0, Constants.UI.WINDOW_WIDTH, 0, Constants.UI.WINDOW_HEIGHT)
        }):Play()
    else
        TweenService:Create(_mainFrame, info, {
            Size = UDim2.new(0, Constants.UI.WINDOW_WIDTH, 0, 42)
        }):Play()
    end
end

-- ============================================================
-- DESTROY
-- ============================================================
function Window.Destroy()
    if _gui then
        _gui:Destroy()
        _gui       = nil
        _mainFrame = nil
    end
    print("[Window] UI dihancurkan.")
end

-- ============================================================
-- GET GUI (untuk referensi luar)
-- ============================================================
function Window.GetGui()
    return _gui
end

return Window
