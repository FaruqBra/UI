--[[
    YourHub - UI/Components.lua

    Reusable UI components.
    Toggle, Slider, Dropdown, Label, Button.
    Mobile optimized — minimal tween, no heavy gradient.

    PENTING: Semua komponen HANYA mengubah Flags.
    Logic dijalankan oleh Features, bukan UI.
]]

local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")

local Theme         = require(script.Parent.Theme)
local Flags         = require(script.Parent.Parent.Config.Flags)
local Constants     = require(script.Parent.Parent.Shared.Constants)

local Components = {}

-- ============================================================
-- HELPER: Quick Tween (ringan)
-- ============================================================
local function quickTween(instance, props, duration)
    duration = duration or Constants.UI.ANIMATION_TIME
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(instance, info, props):Play()
end

-- ============================================================
-- HELPER: Create Instance dengan properties
-- ============================================================
local function create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- ============================================================
-- LABEL
-- ============================================================
function Components.CreateLabel(parent, text, options)
    options = options or {}
    local T = Theme.Get()

    local label = create("TextLabel", {
        Name              = options.Name or "Label",
        Size              = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundColor3  = T.ComponentBg,
        BackgroundTransparency = options.Transparent and 1 or 0,
        BorderSizePixel   = 0,
        Text              = text,
        Font              = Theme.Fonts.Medium,
        TextSize          = Theme.TextSizes.Body,
        TextColor3        = T.TextPrimary,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = parent,
    })

    create("UIPadding", {
        PaddingLeft = UDim.new(0, Constants.UI.PADDING),
    }, {}):Parent = label

    create("UICorner", {
        CornerRadius = Theme.Corner.Component,
    }, {}):Parent = label

    return label
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Components.CreateToggle(parent, text, flagName, callback)
    local T = Theme.Get()
    local currentValue = Flags[flagName] or false

    -- Container
    local container = create("Frame", {
        Name              = "Toggle_" .. flagName,
        Size              = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundColor3  = T.ComponentBg,
        BorderSizePixel   = 0,
        Parent            = parent,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Component }):Parent = container

    -- Label
    create("TextLabel", {
        Size              = UDim2.new(1, -60, 1, 0),
        Position          = UDim2.new(0, Constants.UI.PADDING, 0, 0),
        BackgroundTransparency = 1,
        Text              = text,
        Font              = Theme.Fonts.Regular,
        TextSize          = Theme.TextSizes.Body,
        TextColor3        = T.TextPrimary,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = container,
    })

    -- Toggle Background
    local toggleBg = create("Frame", {
        Name              = "ToggleBg",
        Size              = UDim2.new(0, 40, 0, 20),
        Position          = UDim2.new(1, -Constants.UI.PADDING - 40, 0.5, -10),
        BackgroundColor3  = currentValue and T.ToggleOn or T.ToggleOff,
        BorderSizePixel   = 0,
        Parent            = container,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Toggle }):Parent = toggleBg

    -- Thumb
    local thumb = create("Frame", {
        Name             = "Thumb",
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = currentValue
            and UDim2.new(1, -18, 0.5, -8)
            or  UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = T.ToggleThumb,
        BorderSizePixel  = 0,
        Parent           = toggleBg,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Toggle }):Parent = thumb

    -- --------------------------------------------------------
    -- Toggle Button (invisible overlay untuk click)
    -- --------------------------------------------------------
    local button = create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = container,
    })

    button.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        Flags.Set(flagName, currentValue)

        -- Animate toggle
        quickTween(toggleBg, {
            BackgroundColor3 = currentValue and T.ToggleOn or T.ToggleOff
        })
        quickTween(thumb, {
            Position = currentValue
                and UDim2.new(1, -18, 0.5, -8)
                or  UDim2.new(0, 2, 0.5, -8)
        })

        if callback then
            pcall(callback, currentValue)
        end
    end)

    -- Hover effect (ringan)
    button.MouseEnter:Connect(function()
        quickTween(container, { BackgroundColor3 = T.ComponentHover })
    end)
    button.MouseLeave:Connect(function()
        quickTween(container, { BackgroundColor3 = T.ComponentBg })
    end)

    -- Kembalikan referensi untuk update eksternal
    return {
        Container = container,
        SetValue  = function(val)
            currentValue = val
            Flags.Set(flagName, val)
            quickTween(toggleBg, {
                BackgroundColor3 = val and T.ToggleOn or T.ToggleOff
            })
            quickTween(thumb, {
                Position = val
                    and UDim2.new(1, -18, 0.5, -8)
                    or  UDim2.new(0, 2, 0.5, -8)
            })
        end,
    }
end

-- ============================================================
-- SLIDER
-- ============================================================
function Components.CreateSlider(parent, text, flagName, min, max, step, callback)
    local T = Theme.Get()
    step = step or 1

    local currentValue = Flags[flagName] or min
    currentValue = math.clamp(currentValue, min, max)

    -- Container
    local container = create("Frame", {
        Name              = "Slider_" .. flagName,
        Size              = UDim2.new(1, 0, 0, 50),
        BackgroundColor3  = T.ComponentBg,
        BorderSizePixel   = 0,
        Parent            = parent,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Component }):Parent = container

    -- Label + Value
    local valueText = create("TextLabel", {
        Name             = "LabelValue",
        Size             = UDim2.new(1, -Constants.UI.PADDING * 2, 0, 20),
        Position         = UDim2.new(0, Constants.UI.PADDING, 0, 4),
        BackgroundTransparency = 1,
        Text             = text .. ": " .. tostring(currentValue),
        Font             = Theme.Fonts.Regular,
        TextSize         = Theme.TextSizes.Body,
        TextColor3       = T.TextPrimary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = container,
    })

    -- Track
    local track = create("Frame", {
        Name             = "Track",
        Size             = UDim2.new(1, -Constants.UI.PADDING * 2, 0, 6),
        Position         = UDim2.new(0, Constants.UI.PADDING, 0, 32),
        BackgroundColor3 = T.SliderTrack,
        BorderSizePixel  = 0,
        Parent           = container,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0) }):Parent = track

    -- Fill
    local fillRatio = (currentValue - min) / (max - min)
    local fill = create("Frame", {
        Name             = "Fill",
        Size             = UDim2.new(fillRatio, 0, 1, 0),
        BackgroundColor3 = T.SliderFill,
        BorderSizePixel  = 0,
        Parent           = track,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0) }):Parent = fill

    -- Thumb
    local thumbSize = 14
    local thumb = create("Frame", {
        Name             = "Thumb",
        Size             = UDim2.new(0, thumbSize, 0, thumbSize),
        Position         = UDim2.new(fillRatio, -thumbSize/2, 0.5, -thumbSize/2),
        BackgroundColor3 = T.SliderThumb,
        BorderSizePixel  = 0,
        Parent           = track,
        ZIndex           = 3,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Toggle }):Parent = thumb

    -- --------------------------------------------------------
    -- Drag Logic
    -- --------------------------------------------------------
    local isDragging = false

    local function updateSlider(inputX)
        local trackPos   = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local relX = math.clamp((inputX - trackPos) / trackWidth, 0, 1)

        local rawValue = min + (max - min) * relX
        -- Snap to step
        local snapped = math.floor((rawValue - min) / step + 0.5) * step + min
        snapped = math.clamp(snapped, min, max)

        currentValue = snapped
        Flags.Set(flagName, snapped)
        valueText.Text = text .. ": " .. tostring(snapped)

        local newRatio = (snapped - min) / (max - min)
        fill.Size = UDim2.new(newRatio, 0, 1, 0)
        thumb.Position = UDim2.new(newRatio, -thumbSize/2, 0.5, -thumbSize/2)

        if callback then pcall(callback, snapped) end
    end

    local sliderBtn = create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
        Parent           = track,
    })

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input.Position.X)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging then
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMove then
                updateSlider(input.Position.X)
            end
        end
    end)

    return {
        Container = container,
        SetValue  = function(val)
            currentValue = math.clamp(val, min, max)
            Flags.Set(flagName, currentValue)
            local ratio = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            thumb.Position = UDim2.new(ratio, -thumbSize/2, 0.5, -thumbSize/2)
            valueText.Text = text .. ": " .. tostring(currentValue)
        end,
    }
end

-- ============================================================
-- DROPDOWN
-- ============================================================
function Components.CreateDropdown(parent, text, flagName, options, callback)
    local T = Theme.Get()
    local currentValue = Flags[flagName] or options[1]
    local isOpen = false
    local dropItems = {}

    -- Container
    local container = create("Frame", {
        Name             = "Dropdown_" .. flagName,
        Size             = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundColor3 = T.ComponentBg,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = parent,
        ZIndex           = 5,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Component }):Parent = container

    -- Header button
    local headerBtn = create("TextButton", {
        Size             = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 6,
        Parent           = container,
    })

    -- Label
    create("TextLabel", {
        Size             = UDim2.new(0.5, 0, 1, 0),
        Position         = UDim2.new(0, Constants.UI.PADDING, 0, 0),
        BackgroundTransparency = 1,
        Text             = text,
        Font             = Theme.Fonts.Regular,
        TextSize         = Theme.TextSizes.Body,
        TextColor3       = T.TextPrimary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
        Parent           = container,
    })

    -- Current value text
    local valueLabel = create("TextLabel", {
        Size             = UDim2.new(0.5, -Constants.UI.PADDING * 2, 1, 0),
        Position         = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = tostring(currentValue) .. " ▾",
        Font             = Theme.Fonts.Regular,
        TextSize         = Theme.TextSizes.Body,
        TextColor3       = T.TextAccent,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 7,
        Parent           = container,
    })

    -- Dropdown items
    local itemsFrame = create("Frame", {
        Name             = "Items",
        Size             = UDim2.new(1, 0, 0, #options * 28),
        Position         = UDim2.new(0, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundColor3 = T.BackgroundAlt,
        BorderSizePixel  = 0,
        ZIndex           = 8,
        Parent           = container,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Component }):Parent = itemsFrame
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }):Parent = itemsFrame

    for i, option in ipairs(options) do
        local itemBtn = create("TextButton", {
            Name             = "Option_" .. tostring(option),
            Size             = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = T.ComponentBg,
            BorderSizePixel  = 0,
            Text             = "  " .. tostring(option),
            Font             = Theme.Fonts.Regular,
            TextSize         = Theme.TextSizes.Body,
            TextColor3       = T.TextSecondary,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 9,
            LayoutOrder      = i,
            Parent           = itemsFrame,
        })
        create("UICorner", { CornerRadius = Theme.Corner.Component }):Parent = itemBtn

        itemBtn.MouseButton1Click:Connect(function()
            currentValue = option
            Flags.Set(flagName, option)
            valueLabel.Text = tostring(option) .. " ▾"
            -- Tutup dropdown
            isOpen = false
            quickTween(container, { Size = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT) })
            if callback then pcall(callback, option) end
        end)

        table.insert(dropItems, itemBtn)
    end

    -- Toggle open/close
    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetHeight = isOpen
            and (Constants.UI.COMPONENT_HEIGHT + #options * 28 + 4)
            or   Constants.UI.COMPONENT_HEIGHT
        quickTween(container, { Size = UDim2.new(1, 0, 0, targetHeight) })
        valueLabel.Text = tostring(currentValue) .. (isOpen and " ▴" or " ▾")
    end)

    return {
        Container = container,
        SetValue  = function(val)
            currentValue = val
            Flags.Set(flagName, val)
            valueLabel.Text = tostring(val) .. " ▾"
        end,
    }
end

-- ============================================================
-- BUTTON
-- ============================================================
function Components.CreateButton(parent, text, callback)
    local T = Theme.Get()

    local btn = create("TextButton", {
        Name             = "Button_" .. text,
        Size             = UDim2.new(1, 0, 0, Constants.UI.COMPONENT_HEIGHT),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Text             = text,
        Font             = Theme.Fonts.Bold,
        TextSize         = Theme.TextSizes.Body,
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Parent           = parent,
    })
    create("UICorner", { CornerRadius = Theme.Corner.Button }):Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- Click feedback
        quickTween(btn, { BackgroundColor3 = T.AccentLight }, 0.1)
        task.delay(0.1, function()
            quickTween(btn, { BackgroundColor3 = T.Accent }, 0.1)
        end)
        if callback then pcall(callback) end
    end)

    return btn
end

-- ============================================================
-- SEPARATOR
-- ============================================================
function Components.CreateSeparator(parent)
    local T = Theme.Get()
    return create("Frame", {
        Name             = "Separator",
        Size             = UDim2.new(1, -Constants.UI.PADDING * 2, 0, 1),
        Position         = UDim2.new(0, Constants.UI.PADDING, 0, 0),
        BackgroundColor3 = T.Separator,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
end

-- ============================================================
-- SECTION HEADER
-- ============================================================
function Components.CreateSection(parent, title)
    local T = Theme.Get()
    local frame = create("Frame", {
        Name             = "Section_" .. title,
        Size             = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent           = parent,
    })

    create("TextLabel", {
        Size             = UDim2.new(1, -Constants.UI.PADDING * 2, 1, 0),
        Position         = UDim2.new(0, Constants.UI.PADDING, 0, 0),
        BackgroundTransparency = 1,
        Text             = title:upper(),
        Font             = Theme.Fonts.Bold,
        TextSize         = Theme.TextSizes.Small,
        TextColor3       = T.TextAccent,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = frame,
    })

    return frame
end

return Components
