--[[
    YourHub - UI/Theme.lua
    Color palette & style definitions.
    Semua warna UI diambil dari sini.
    Mobile-optimized: minimal glow/gradient/tween.
]]

local Theme = {}

-- ============================================================
-- ACTIVE THEME
-- ============================================================
Theme.Active = "Dark"

-- ============================================================
-- PALETTES
-- ============================================================
Theme.Palettes = {

    Dark = {
        -- Window
        Background       = Color3.fromRGB(18, 18, 22),
        BackgroundAlt    = Color3.fromRGB(24, 24, 30),

        -- Header / Titlebar
        Header           = Color3.fromRGB(13, 13, 17),
        HeaderText       = Color3.fromRGB(240, 240, 255),

        -- Tabs
        TabBackground    = Color3.fromRGB(22, 22, 28),
        TabActive        = Color3.fromRGB(90, 60, 200),
        TabText          = Color3.fromRGB(160, 160, 180),
        TabTextActive    = Color3.fromRGB(255, 255, 255),

        -- Components
        ComponentBg      = Color3.fromRGB(28, 28, 35),
        ComponentBorder  = Color3.fromRGB(45, 45, 58),
        ComponentHover   = Color3.fromRGB(35, 35, 45),

        -- Toggle
        ToggleOff        = Color3.fromRGB(50, 50, 65),
        ToggleOn         = Color3.fromRGB(90, 60, 200),
        ToggleThumb      = Color3.fromRGB(255, 255, 255),

        -- Slider
        SliderTrack      = Color3.fromRGB(40, 40, 55),
        SliderFill       = Color3.fromRGB(90, 60, 200),
        SliderThumb      = Color3.fromRGB(220, 210, 255),

        -- Text
        TextPrimary      = Color3.fromRGB(230, 230, 245),
        TextSecondary    = Color3.fromRGB(140, 140, 165),
        TextDisabled     = Color3.fromRGB(80, 80, 100),
        TextAccent       = Color3.fromRGB(150, 110, 255),

        -- Accent
        Accent           = Color3.fromRGB(90, 60, 200),
        AccentLight      = Color3.fromRGB(130, 100, 230),

        -- Scrollbar
        ScrollBar        = Color3.fromRGB(50, 50, 70),

        -- Separator
        Separator        = Color3.fromRGB(35, 35, 48),

        -- Notification
        NotifBg          = Color3.fromRGB(22, 22, 30),
        NotifBorder      = Color3.fromRGB(90, 60, 200),
    },

    Purple = {
        Background       = Color3.fromRGB(15, 10, 25),
        BackgroundAlt    = Color3.fromRGB(20, 14, 35),
        Header           = Color3.fromRGB(10, 8, 20),
        HeaderText       = Color3.fromRGB(240, 225, 255),
        TabBackground    = Color3.fromRGB(18, 12, 30),
        TabActive        = Color3.fromRGB(120, 60, 220),
        TabText          = Color3.fromRGB(160, 140, 200),
        TabTextActive    = Color3.fromRGB(255, 240, 255),
        ComponentBg      = Color3.fromRGB(25, 16, 40),
        ComponentBorder  = Color3.fromRGB(60, 40, 90),
        ComponentHover   = Color3.fromRGB(32, 20, 50),
        ToggleOff        = Color3.fromRGB(50, 35, 75),
        ToggleOn         = Color3.fromRGB(120, 60, 220),
        ToggleThumb      = Color3.fromRGB(255, 240, 255),
        SliderTrack      = Color3.fromRGB(40, 28, 65),
        SliderFill       = Color3.fromRGB(120, 60, 220),
        SliderThumb      = Color3.fromRGB(210, 180, 255),
        TextPrimary      = Color3.fromRGB(240, 225, 255),
        TextSecondary    = Color3.fromRGB(160, 135, 210),
        TextDisabled     = Color3.fromRGB(80, 65, 110),
        TextAccent       = Color3.fromRGB(180, 120, 255),
        Accent           = Color3.fromRGB(120, 60, 220),
        AccentLight      = Color3.fromRGB(160, 100, 240),
        ScrollBar        = Color3.fromRGB(55, 38, 85),
        Separator        = Color3.fromRGB(38, 26, 62),
        NotifBg          = Color3.fromRGB(18, 12, 30),
        NotifBorder      = Color3.fromRGB(120, 60, 220),
    },
}

-- ============================================================
-- GET CURRENT PALETTE
-- ============================================================
function Theme.Get()
    return Theme.Palettes[Theme.Active] or Theme.Palettes.Dark
end

function Theme.GetColor(colorName)
    local palette = Theme.Get()
    return palette[colorName] or Color3.fromRGB(255, 255, 255)
end

-- ============================================================
-- SET THEME
-- ============================================================
function Theme.SetTheme(themeName)
    if Theme.Palettes[themeName] then
        Theme.Active = themeName
        return true
    end
    warn("[Theme] Theme tidak ditemukan: " .. tostring(themeName))
    return false
end

-- ============================================================
-- FONT (Roblox built-in, mobile safe)
-- ============================================================
Theme.Fonts = {
    Regular  = Enum.Font.Gotham,
    Bold     = Enum.Font.GothamBold,
    Medium   = Enum.Font.GothamMedium,
    Mono     = Enum.Font.Code,
}

-- ============================================================
-- SIZES
-- ============================================================
Theme.TextSizes = {
    Title     = 15,
    Subtitle  = 13,
    Body      = 12,
    Small     = 11,
}

-- ============================================================
-- CORNER RADIUS
-- ============================================================
Theme.Corner = {
    Window    = UDim.new(0, 10),
    Component = UDim.new(0, 6),
    Button    = UDim.new(0, 6),
    Toggle    = UDim.new(1, 0),  -- fully rounded
}

return Theme
