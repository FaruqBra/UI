--[[
    YourHub - UI/Tabs.lua
    Tab navigation system.
    Build tabs dari gameConfig.UITabs.
    Setiap tab punya scrollable content area.
]]

local TweenService = game:GetService("TweenService")

local Theme        = require(script.Parent.Theme)
local Components   = require(script.Parent.Components)
local Flags        = require(script.Parent.Parent.Config.Flags)
local Settings     = require(script.Parent.Parent.Config.Settings)
local Constants    = require(script.Parent.Parent.Shared.Constants)

local Tabs = {}

-- ============================================================
-- BUILD TABS
-- ============================================================
function Tabs.Build(parent, gameConfig)
    local T       = Theme.Get()
    local tabs    = gameConfig.UITabs or {}
    local tabCount = #tabs

    if tabCount == 0 then
        warn("[Tabs] Tidak ada tab untuk ditampilkan.")
        return
    end

    -- --------------------------------------------------------
    -- TAB BAR
    -- --------------------------------------------------------
    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, Constants.UI.TAB_HEIGHT)
    tabBar.BackgroundColor3 = T.TabBackground
    tabBar.BorderSizePixel  = 0
    tabBar.Parent           = parent

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection  = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder      = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding        = UDim.new(0, 2)
    tabBarLayout.Parent         = tabBar

    Instance.new("UIPadding", tabBar).PaddingLeft  = UDim.new(0, 4)
    Instance.new("UIPadding", tabBar).PaddingRight = UDim.new(0, 4)

    -- --------------------------------------------------------
    -- CONTENT PANELS
    -- --------------------------------------------------------
    local contentArea = Instance.new("Frame")
    contentArea.Name             = "ContentArea"
    contentArea.Size             = UDim2.new(1, 0, 1, -Constants.UI.TAB_HEIGHT)
    contentArea.Position         = UDim2.new(0, 0, 0, Constants.UI.TAB_HEIGHT)
    contentArea.BackgroundColor3 = T.BackgroundAlt
    contentArea.BorderSizePixel  = 0
    contentArea.Parent           = parent

    Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

    -- --------------------------------------------------------
    -- BUILD SETIAP TAB
    -- --------------------------------------------------------
    local tabButtons  = {}
    local tabPanels   = {}
    local activeIndex = 1

    for i, tabInfo in ipairs(tabs) do
        -- Tab Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name             = "Tab_" .. tabInfo.Name
        tabBtn.Size             = UDim2.new(1/tabCount, -4, 0.85, 0)
        tabBtn.BackgroundColor3 = (i == activeIndex) and T.TabActive or T.TabBackground
        tabBtn.BorderSizePixel  = 0
        tabBtn.Text             = tabInfo.Icon .. " " .. tabInfo.Name
        tabBtn.Font             = Theme.Fonts.Medium
        tabBtn.TextSize         = Theme.TextSizes.Small
        tabBtn.TextColor3       = (i == activeIndex) and T.TabTextActive or T.TabText
        tabBtn.LayoutOrder      = i
        tabBtn.Parent           = tabBar
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        table.insert(tabButtons, tabBtn)

        -- Tab Panel (scrollable)
        local panel = Instance.new("ScrollingFrame")
        panel.Name             = "Panel_" .. tabInfo.Name
        panel.Size             = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel  = 0
        panel.ScrollBarThickness = 3
        panel.ScrollBarImageColor3 = T.ScrollBar
        panel.CanvasSize       = UDim2.new(0, 0, 0, 0)
        panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        panel.Visible          = (i == activeIndex)
        panel.Parent           = contentArea

        local panelLayout = Instance.new("UIListLayout")
        panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
        panelLayout.Padding   = UDim.new(0, 4)
        panelLayout.Parent    = panel

        local panelPad = Instance.new("UIPadding")
        panelPad.PaddingLeft   = UDim.new(0, Constants.UI.PADDING)
        panelPad.PaddingRight  = UDim.new(0, Constants.UI.PADDING)
        panelPad.PaddingTop    = UDim.new(0, Constants.UI.PADDING)
        panelPad.PaddingBottom = UDim.new(0, Constants.UI.PADDING)
        panelPad.Parent        = panel

        -- Populate panel dengan feature components
        Tabs.PopulatePanel(panel, tabInfo.Features, gameConfig)

        table.insert(tabPanels, panel)

        -- Tab Switch Logic
        tabBtn.MouseButton1Click:Connect(function()
            -- Update active state
            for j, btn in ipairs(tabButtons) do
                local isActive = (j == i)
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = isActive and T.TabActive or T.TabBackground,
                    TextColor3       = isActive and T.TabTextActive or T.TabText,
                }):Play()
                tabPanels[j].Visible = isActive
            end
            activeIndex = i
        end)
    end

    return tabButtons, tabPanels
end

-- ============================================================
-- POPULATE PANEL
-- Isi setiap tab dengan komponen sesuai feature yang ada
-- ============================================================
function Tabs.PopulatePanel(panel, features, gameConfig)
    local T = Theme.Get()

    for _, featureName in ipairs(features) do
        -- Setiap feature punya layout berbeda di UI
        Tabs.BuildFeatureUI(panel, featureName)
    end
end

-- ============================================================
-- BUILD FEATURE UI
-- Mapping feature name → UI components
-- ============================================================
function Tabs.BuildFeatureUI(panel, featureName)
    -- Import Components
    -- (Sudah di-require di atas)

    if featureName == "AutoFarm" then
        Components.CreateSection(panel, "Auto Farm")
        Components.CreateToggle(panel, "Auto Farm", "AutoFarm")
        Components.CreateToggle(panel, "Teleport ke Mob", "AutoFarm_UseTP")
        Components.CreateSlider(panel, "Farm Range", "AutoFarm_Range", 10, 200, 5)

    elseif featureName == "AutoRoll" then
        Components.CreateSection(panel, "Auto Roll")
        Components.CreateToggle(panel, "Auto Roll", "AutoRoll")
        Components.CreateSlider(panel, "Roll Delay (s)", "AutoRoll_Delay", 0.05, 2.0, 0.05)

    elseif featureName == "AutoPotion" then
        Components.CreateSection(panel, "Auto Potion")
        Components.CreateToggle(panel, "Auto Potion", "AutoPotion")
        Components.CreateSlider(panel, "Min HP %", "AutoPotion_MinHP", 10, 90, 5)

    elseif featureName == "AutoCraft" then
        Components.CreateSection(panel, "Auto Craft")
        Components.CreateToggle(panel, "Auto Craft", "AutoCraft")
        Components.CreateDropdown(panel, "Target Slime", "AutoCraft_Target",
            {"Crafty", "Thorn", "Geode"})

    elseif featureName == "AutoUpgrade" then
        Components.CreateSection(panel, "Auto Upgrade")
        Components.CreateToggle(panel, "Auto Upgrade", "AutoUpgrade")
        Components.CreateDropdown(panel, "Upgrade Target", "AutoUpgrade_Target",
            {"Damage", "Speed", "Luck"})

    elseif featureName == "AutoEquipBestPet" then
        Components.CreateSection(panel, "Pet Manager")
        Components.CreateToggle(panel, "Auto Equip Best Pet", "AutoEquipBestPet")

    elseif featureName == "AutoBuyZone" then
        Components.CreateSection(panel, "Zone Manager")
        Components.CreateToggle(panel, "Auto Buy Zone", "AutoBuyZone")

    elseif featureName == "AutoTeleportZone" then
        Components.CreateToggle(panel, "Auto Teleport Zone", "AutoTeleportZone")
        Components.CreateSlider(panel, "Target Zone", "AutoTeleportZone_Target", 1, 21, 1)

    elseif featureName == "ESP" then
        Components.CreateSection(panel, "ESP Settings")
        Components.CreateToggle(panel, "ESP", "ESP")
        Components.CreateToggle(panel, "Show Mobs", "ESP_ShowMobs")
        Components.CreateToggle(panel, "Show Drops", "ESP_ShowDrops")
        Components.CreateSlider(panel, "Max Distance", "ESP_MaxDistance", 50, 500, 50)

    elseif featureName == "Fly" then
        Components.CreateSection(panel, "Fly Settings")
        Components.CreateToggle(panel, "Fly", "Fly")
        Components.CreateSlider(panel, "Fly Speed", "FlySpeed", 10, 200, 5)

    elseif featureName == "NoClip" then
        Components.CreateSection(panel, "No Clip")
        Components.CreateToggle(panel, "No Clip", "NoClip")

    elseif featureName == "Teleport" then
        Components.CreateSection(panel, "Teleport")
        Components.CreateToggle(panel, "Auto Teleport", "Teleport")

    else
        -- Generic toggle untuk feature yang belum ada layout khusus
        Components.CreateToggle(panel, featureName, featureName)
    end

    Components.CreateSeparator(panel)
end

return Tabs
