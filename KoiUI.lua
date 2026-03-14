--[[
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██╗  ██╗ ██████╗ ██╗    ██╗   ██╗██╗                       ║
║   ██║ ██╔╝██╔═══██╗██║    ██║   ██║██║                       ║
║   █████╔╝ ██║   ██║██║    ██║   ██║██║                       ║
║   ██╔═██╗ ██║   ██║██║    ██║   ██║██║                       ║
║   ██║  ██╗╚██████╔╝██║    ╚██████╔╝██║                       ║
║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═════╝ ╚═╝                       ║
║                                                               ║
║   KoiUI vBeta  –  Mobile-First Roblox UI Library             ║
║   Executor & Studio compatible · Touch-optimized             ║
║   Multiple independent windows · Full theming system         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

  MIT-style open license — use freely in any Roblox project.

  QUICK START:
    local KoiUI = require(path.to.KoiUI)
    local gui   = Instance.new("ScreenGui")
    gui.Parent  = game:GetService("Players").LocalPlayer.PlayerGui
    local win   = KoiUI:CreateWindow(gui, { Title = "My UI" })
    win:AddButton({ Text = "Hello!" }):On("onClick", function()
        win:Notify({ Type = "success", Title = "Clicked!" })
    end)

  Full example LocalScript is at the bottom of this file.
]]

-- ─────────────────────────────────────────────────────────────
--  MODULE ROOT
-- ─────────────────────────────────────────────────────────────
local KoiUI          = {}
KoiUI.__index        = KoiUI
KoiUI.Version        = "vBeta"
KoiUI.Windows        = {}       -- all active Window objects
KoiUI._Initialized   = false

-- ─────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local SoundService      = game:GetService("SoundService")
local Debris            = game:GetService("Debris")

local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = workspace.CurrentCamera

-- ─────────────────────────────────────────────────────────────
--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
--  Global configuration — edit these defaults freely.
-- ─────────────────────────────────────────────────────────────
KoiUI.Config = {
    -- ── Theme ─────────────────────────────────────────────────
    Theme          = "Dark",              -- "Dark" | "Light"
    AccentColor    = Color3.fromRGB(99, 102, 241),   -- indigo

    -- ── Animation ─────────────────────────────────────────────
    TweenDuration  = 0.25,
    TweenEasing    = Enum.EasingStyle.Quart,
    TweenDirection = Enum.EasingDirection.Out,

    -- ── Mobile / Input ────────────────────────────────────────
    TouchFeedback   = true,
    SafeAreaTop     = 8,    -- extra top padding (notch safe-area)
    SafeAreaBottom  = 8,

    -- ── Sound ─────────────────────────────────────────────────
    SoundEnabled  = true,
    SoundVolume   = 0.35,
    ClickSoundId  = "rbxassetid://6324790483",
    ToggleSoundId = "rbxassetid://6324790483",
    NotifSoundId  = "rbxassetid://6324790483",

    -- ── Notifications ─────────────────────────────────────────
    NotificationDuration = 4,    -- seconds
    MaxNotifications     = 4,

    -- ── Accessibility ─────────────────────────────────────────
    LargeTextMode    = false,    -- scales all font sizes ×1.3
    HighContrastMode = false,    -- forces pure black/white text

    -- ── Persistent state ──────────────────────────────────────
    PersistentState = false,     -- save slider/toggle values via attributes
}

-- ─────────────────────────────────────────────────────────────
--  THEMES
-- ─────────────────────────────────────────────────────────────
KoiUI.Themes = {
    Dark = {
        Background      = Color3.fromRGB(14, 14, 20),
        Surface         = Color3.fromRGB(22, 22, 32),
        SurfaceVariant  = Color3.fromRGB(30, 30, 44),
        Border          = Color3.fromRGB(52, 52, 72),
        Text            = Color3.fromRGB(238, 238, 255),
        TextSecondary   = Color3.fromRGB(148, 148, 175),
        TextDisabled    = Color3.fromRGB(82, 82, 102),
        Accent          = Color3.fromRGB(99, 102, 241),
        AccentHover     = Color3.fromRGB(118, 120, 255),
        AccentPressed   = Color3.fromRGB(80, 82, 220),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        SwitchOff       = Color3.fromRGB(52, 52, 72),
        SwitchOn        = Color3.fromRGB(99, 102, 241),
        SliderTrack     = Color3.fromRGB(52, 52, 72),
        SliderFill      = Color3.fromRGB(99, 102, 241),
        TitleBar        = Color3.fromRGB(18, 18, 28),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Scrollbar       = Color3.fromRGB(60, 60, 85),
    },
    Light = {
        Background      = Color3.fromRGB(246, 246, 252),
        Surface         = Color3.fromRGB(255, 255, 255),
        SurfaceVariant  = Color3.fromRGB(238, 238, 248),
        Border          = Color3.fromRGB(208, 208, 228),
        Text            = Color3.fromRGB(18, 18, 30),
        TextSecondary   = Color3.fromRGB(88, 88, 110),
        TextDisabled    = Color3.fromRGB(168, 168, 190),
        Accent          = Color3.fromRGB(99, 102, 241),
        AccentHover     = Color3.fromRGB(118, 120, 255),
        AccentPressed   = Color3.fromRGB(80, 82, 220),
        Success         = Color3.fromRGB(16, 185, 129),
        Warning         = Color3.fromRGB(245, 158, 11),
        Error           = Color3.fromRGB(239, 68, 68),
        Info            = Color3.fromRGB(59, 130, 246),
        SwitchOff       = Color3.fromRGB(200, 200, 218),
        SwitchOn        = Color3.fromRGB(99, 102, 241),
        SliderTrack     = Color3.fromRGB(208, 208, 228),
        SliderFill      = Color3.fromRGB(99, 102, 241),
        TitleBar        = Color3.fromRGB(248, 248, 252),
        Shadow          = Color3.fromRGB(80, 80, 120),
        Scrollbar       = Color3.fromRGB(180, 180, 210),
    },
}

-- ─────────────────────────────────────────────────────────────
--  ██╗   ██╗████████╗██╗██╗
--  ██║   ██║╚══██╔══╝██║██║
--  ██║   ██║   ██║   ██║██║
--  ██║   ██║   ██║   ██║██║
--  ╚██████╔╝   ██║   ██║███████╗
--   ╚═════╝    ╚═╝   ╚═╝╚══════╝
--  Internal helpers
-- ─────────────────────────────────────────────────────────────
local Util = {}

-- Returns the current resolved theme table (merged with config overrides)
function Util.Theme()
    local name = KoiUI.Config.Theme
    local base = KoiUI.Themes[name] or KoiUI.Themes.Dark
    local t = {}
    for k, v in pairs(base) do t[k] = v end

    -- Apply config accent overrides
    t.Accent    = KoiUI.Config.AccentColor
    t.SwitchOn  = KoiUI.Config.AccentColor
    t.SliderFill = KoiUI.Config.AccentColor

    -- High-contrast mode
    if KoiUI.Config.HighContrastMode then
        t.Text     = (name == "Dark") and Color3.new(1,1,1) or Color3.new(0,0,0)
        t.Background = (name == "Dark") and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
    return t
end

-- Tween helper
function Util.Tween(inst, props, dur, style, dir)
    dur   = dur   or KoiUI.Config.TweenDuration
    style = style or KoiUI.Config.TweenEasing
    dir   = dir   or KoiUI.Config.TweenDirection
    local tw = TweenService:Create(inst, TweenInfo.new(dur, style, dir), props)
    tw:Play()
    return tw
end

-- Bounce tween (Back easing)
function Util.TweenBounce(inst, props, dur)
    dur = dur or 0.35
    local tw = TweenService:Create(inst,
        TweenInfo.new(dur, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

-- Spring tween (Elastic)
function Util.TweenSpring(inst, props, dur)
    dur = dur or 0.4
    local tw = TweenService:Create(inst,
        TweenInfo.new(dur, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

-- Instance factory
function Util.New(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- UICorner shorthand
function Util.Corner(inst, radius)
    return Util.New("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, inst)
end

-- UIStroke shorthand
function Util.Stroke(inst, color, thick, trans)
    return Util.New("UIStroke", {
        Color                = color or Color3.new(1,1,1),
        Thickness            = thick or 1,
        Transparency         = trans or 0,
        ApplyStrokeMode      = Enum.ApplyStrokeMode.Border,
    }, inst)
end

-- UIPadding shorthand
function Util.Pad(inst, l, r, t, b)
    return Util.New("UIPadding", {
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, inst)
end

-- Screen size
function Util.Screen()
    local vp = Camera.ViewportSize
    return vp.X, vp.Y
end

-- Device detection
function Util.IsMobile()
    return UserInputService.TouchEnabled
end

function Util.IsTablet()
    local w, h = Util.Screen()
    return UserInputService.TouchEnabled and math.min(w, h) >= 600
end

-- Responsive font scale (relative to 1920 wide reference)
function Util.FontSize(size)
    local w = Util.Screen()
    local scale = math.clamp(w / 1920, 0.55, 1.4)
    if KoiUI.Config.LargeTextMode then scale = scale * 1.3 end
    return math.max(9, math.round(size * scale))
end

-- Sound helper
function Util.Sound(id, vol)
    if not KoiUI.Config.SoundEnabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id or KoiUI.Config.ClickSoundId
        s.Volume  = vol or KoiUI.Config.SoundVolume
        s.Parent  = SoundService
        s:Play()
        Debris:AddItem(s, 3)
    end)
end

-- Ripple effect (touch/click visual feedback)
function Util.Ripple(parent, localX, localY, color)
    if not KoiUI.Config.TouchFeedback then return end
    color = color or Color3.new(1, 1, 1)
    local r = Util.New("Frame", {
        Size                 = UDim2.new(0, 0, 0, 0),
        Position             = UDim2.new(0, localX, 0, localY),
        AnchorPoint          = Vector2.new(0.5, 0.5),
        BackgroundColor3     = color,
        BackgroundTransparency = 0.72,
        ZIndex               = parent.ZIndex + 10,
        ClipsDescendants     = false,
    }, parent)
    Util.Corner(r, 999)

    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.8
    local tw = TweenService:Create(r,
        TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1 })
    tw:Play()
    tw.Completed:Connect(function() r:Destroy() end)
end

-- Check if a 2-D screen point is inside a GuiObject
function Util.HitTest(guiObj, x, y)
    local p = guiObj.AbsolutePosition
    local s = guiObj.AbsoluteSize
    return x >= p.X and x <= p.X + s.X and y >= p.Y and y <= p.Y + s.Y
end

-- ─────────────────────────────────────────────────────────────
--  BASE COMPONENT  (all UI widgets inherit from this)
-- ─────────────────────────────────────────────────────────────
local Component = {}
Component.__index = Component

function Component.new(kind)
    return setmetatable({
        _kind        = kind,
        _connections = {},
        _callbacks   = {},
        _destroyed   = false,
        Instance     = nil,    -- set by each component
    }, Component)
end

-- Register an event listener:  component:On("onClick", fn)
function Component:On(event, fn)
    self._callbacks[event] = self._callbacks[event] or {}
    table.insert(self._callbacks[event], fn)
    return self   -- chainable
end

-- Fire all listeners for an event
function Component:Fire(event, ...)
    local cbs = self._callbacks[event]
    if not cbs then return end
    for _, fn in ipairs(cbs) do
        task.spawn(fn, ...)
    end
end

-- Track a RBXScriptConnection for auto-cleanup
function Component:Track(conn)
    table.insert(self._connections, conn)
    return conn
end

-- Destroy component and all tracked connections
function Component:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for _, c in ipairs(self._connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    self._connections = {}
    self._callbacks   = {}
    if self.Instance and self.Instance.Parent then
        self.Instance:Destroy()
    end
end

-- ═════════════════════════════════════════════════════════════
--
--   ██████╗ ██████╗ ███╗   ███╗██████╗  ██████╗ ███╗   ██╗
--  ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██╔═══██╗████╗  ██║
--  ██║     ██║   ██║██╔████╔██║██████╔╝██║   ██║██╔██╗ ██║
--  ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║   ██║██║╚██╗██║
--  ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ╚██████╔╝██║ ╚████║
--   ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝
--   COMPONENTS
--
-- ═════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────
--  SWITCH  (iOS-style toggle)
--
--  options:
--    Label    string  – left-side label
--    Default  bool    – initial value (false)
--    Disabled bool    – greyed-out non-interactable
--    Size     UDim2
--    OnText / OffText string – small status badge text
--
--  events:  onToggle(bool)  onChanged(bool)
-- ─────────────────────────────────────────────────────────────
local Switch = setmetatable({}, { __index = Component })
Switch.__index = Switch

function Switch.new(parent, opts)
    local self = setmetatable(Component.new("Switch"), Switch)
    opts = opts or {}
    local T = Util.Theme()

    self.Value    = opts.Default  or false
    self.Disabled = opts.Disabled or false
    self._label   = opts.Label    or ""

    -- ── Container ──────────────────────────────────────────
    local cont = Util.New("Frame", {
        Size                 = opts.Size or UDim2.new(1, 0, 0, 52),
        BackgroundColor3     = T.Surface,
        BackgroundTransparency = 0,
        ClipsDescendants     = false,
    }, parent)
    Util.Corner(cont, 10)
    Util.Pad(cont, 14, 14, 10, 10)
    self.Instance = cont

    -- ── Label ──────────────────────────────────────────────
    local lbl = Util.New("TextLabel", {
        Size                 = UDim2.new(1, -74, 1, 0),
        BackgroundTransparency = 1,
        Text                 = self._label,
        TextColor3           = T.Text,
        TextSize             = Util.FontSize(14),
        Font                 = Enum.Font.GothamMedium,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextYAlignment       = Enum.TextYAlignment.Center,
        TextTruncate         = Enum.TextTruncate.AtEnd,
        ZIndex               = cont.ZIndex + 1,
    }, cont)
    self._lblInst = lbl

    -- ── Track ──────────────────────────────────────────────
    local TW, TH = 52, 30
    local track = Util.New("Frame", {
        Size             = UDim2.new(0, TW, 0, TH),
        Position         = UDim2.new(1, -TW, 0.5, -TH / 2),
        BackgroundColor3 = self.Value and T.SwitchOn or T.SwitchOff,
        ClipsDescendants = true,
        ZIndex           = cont.ZIndex + 1,
    }, cont)
    Util.Corner(track, 999)
    self._track = track

    -- ── Thumb ──────────────────────────────────────────────
    local TS = TH - 6   -- thumb size
    local thumb = Util.New("Frame", {
        Size             = UDim2.new(0, TS, 0, TS),
        Position         = self.Value
                            and UDim2.new(0, TW - TS - 3, 0.5, -TS / 2)
                            or  UDim2.new(0, 3,            0.5, -TS / 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex           = track.ZIndex + 1,
    }, track)
    Util.Corner(thumb, 999)
    Util.Stroke(thumb, Color3.fromRGB(0,0,0), 1, 0.88)
    self._thumb = thumb
    self._TW, self._TH, self._TS = TW, TH, TS

    -- ── Ripple surface (invisible, full-area hit) ───────────
    local hitArea = Util.New("Frame", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = cont.ZIndex + 2,
    }, cont)
    Util.Corner(hitArea, 10)

    -- ── Input ──────────────────────────────────────────────
    self:Track(hitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch and
           inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if self.Disabled then return end
        local rx = inp.Position.X - cont.AbsolutePosition.X
        local ry = inp.Position.Y - cont.AbsolutePosition.Y
        Util.Ripple(cont, rx, ry, T.Accent)
        self:_animate(not self.Value)
    end))

    return self
end

function Switch:_animate(newVal)
    self.Value = newVal
    local T = Util.Theme()
    local TS = self._TS
    local TW = self._TW

    -- Stretch → slide → shrink  (iOS thumb physics)
    local stretch = TweenService:Create(self._thumb,
        TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, TS + 7, 0, TS) })
    stretch:Play()
    stretch.Completed:Connect(function()
        local targetX = newVal and (TW - TS - 3 - 7) or 3
        Util.Tween(self._thumb, {
            Position = UDim2.new(0, targetX, 0.5, -TS / 2),
            Size     = UDim2.new(0, TS, 0, TS),
        }, 0.18)
    end)
    Util.Tween(self._track, { BackgroundColor3 = newVal and T.SwitchOn or T.SwitchOff }, 0.2)

    Util.Sound(KoiUI.Config.ToggleSoundId)
    self:Fire("onToggle",  newVal)
    self:Fire("onChanged", newVal)

    -- Persistent state
    if KoiUI.Config.PersistentState and self._stateKey then
        pcall(function()
            LocalPlayer:SetAttribute(self._stateKey, newVal)
        end)
    end
end

function Switch:Toggle()
    if not self.Disabled then self:_animate(not self.Value) end
end

function Switch:SetValue(v, silent)
    self.Value = v
    local T = Util.Theme()
    local TS, TW = self._TS, self._TW
    self._thumb.Position = v
        and UDim2.new(0, TW - TS - 3, 0.5, -TS / 2)
        or  UDim2.new(0, 3,           0.5, -TS / 2)
    self._track.BackgroundColor3 = v and T.SwitchOn or T.SwitchOff
    if not silent then
        self:Fire("onToggle",  v)
        self:Fire("onChanged", v)
    end
end

function Switch:SetLabel(text)
    self._label = text
    self._lblInst.Text = text
end

function Switch:SetDisabled(dis)
    self.Disabled = dis
    local T = Util.Theme()
    self._lblInst.TextColor3 = dis and T.TextDisabled or T.Text
    self._track.BackgroundTransparency = dis and 0.55 or 0
    self._thumb.BackgroundTransparency = dis and 0.40 or 0
end

-- ─────────────────────────────────────────────────────────────
--  BUTTON
--
--  options:
--    Text        string
--    Color       Color3  – background (defaults to accent)
--    TextColor   Color3
--    Outlined    bool    – transparent bg with border
--    Disabled    bool
--    Cooldown    number  – seconds before re-clickable
--    HoldTime    number  – seconds to fire onHold (0.5)
--    LongPress   number  – seconds to fire onLongPress (1.5)
--    Size        UDim2
--
--  events:  onClick   onHold   onLongPress
-- ─────────────────────────────────────────────────────────────
local Button = setmetatable({}, { __index = Component })
Button.__index = Button

function Button.new(parent, opts)
    local self = setmetatable(Component.new("Button"), Button)
    opts = opts or {}
    local T = Util.Theme()

    self.Disabled    = opts.Disabled or false
    self._cooldown   = opts.Cooldown  or 0
    self._onCooldown = false
    self._holdTime   = opts.HoldTime  or 0.5
    self._longTime   = opts.LongPress or 1.5
    self._origSize   = opts.Size or UDim2.new(1, 0, 0, 44)

    local bgColor  = opts.Color or T.Accent
    local txtColor = opts.TextColor or Color3.new(1,1,1)

    -- ── Frame ──────────────────────────────────────────────
    local frame = Util.New("Frame", {
        Size             = self._origSize,
        BackgroundColor3 = opts.Outlined and T.Surface or bgColor,
        ClipsDescendants = true,
    }, parent)
    Util.Corner(frame, 10)
    if opts.Outlined then
        Util.Stroke(frame, bgColor, 1.5)
        txtColor = bgColor
    end
    self.Instance = frame

    -- ── Label ──────────────────────────────────────────────
    local lbl = Util.New("TextLabel", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                 = opts.Text or "Button",
        TextColor3           = txtColor,
        TextSize             = Util.FontSize(14),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Center,
        ZIndex               = frame.ZIndex + 1,
    }, frame)
    self._lbl = lbl

    -- ── Cooldown progress bar ─────────────────────────────
    local cdBar = Util.New("Frame", {
        Size             = UDim2.new(0, 0, 0, 3),
        Position         = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.55,
        ZIndex           = frame.ZIndex + 2,
    }, frame)
    self._cdBar = cdBar

    -- ── Input state ────────────────────────────────────────
    local pressedAt  = nil
    local holdFired  = false
    local lpFired    = false
    local heartbeat  = nil

    self:Track(frame.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch and
           inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if self.Disabled or self._onCooldown then return end

        pressedAt = tick()
        holdFired = false
        lpFired   = false

        -- Scale press
        Util.Tween(frame, {
            Size = UDim2.new(
                self._origSize.X.Scale, self._origSize.X.Offset * 0.965,
                self._origSize.Y.Scale, self._origSize.Y.Offset * 0.94)
        }, 0.07)

        -- Ripple
        local rx = inp.Position.X - frame.AbsolutePosition.X
        local ry = inp.Position.Y - frame.AbsolutePosition.Y
        Util.Ripple(frame, rx, ry, Color3.new(1,1,1))

        -- Hold / long-press timer
        heartbeat = RunService.Heartbeat:Connect(function()
            local e = tick() - pressedAt
            if not holdFired and e >= self._holdTime then
                holdFired = true
                self:Fire("onHold")
            end
            if not lpFired and e >= self._longTime then
                lpFired = true
                self:Fire("onLongPress")
                Util.Sound(KoiUI.Config.ClickSoundId)
                if heartbeat then heartbeat:Disconnect() end
            end
        end)
        self:Track(heartbeat)
    end))

    self:Track(frame.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch and
           inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        -- Scale back
        Util.TweenBounce(frame, { Size = self._origSize }, 0.2)
        if heartbeat then heartbeat:Disconnect() end

        if self.Disabled or self._onCooldown then return end
        if not pressedAt then return end

        local elapsed = tick() - pressedAt
        pressedAt = nil

        if elapsed < self._holdTime then
            -- Regular click
            Util.Sound(KoiUI.Config.ClickSoundId)
            self:Fire("onClick")
            if self._cooldown > 0 then self:_startCooldown() end
        end
    end))

    return self
end

function Button:_startCooldown()
    self._onCooldown     = true
    self._lbl.TextTransparency = 0.5
    local elapsed = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        self._cdBar.Size = UDim2.new(math.min(elapsed / self._cooldown, 1), 0, 0, 3)
        if elapsed >= self._cooldown then
            conn:Disconnect()
            self._onCooldown          = false
            self._lbl.TextTransparency = 0
            self._cdBar.Size          = UDim2.new(0, 0, 0, 3)
        end
    end)
    self:Track(conn)
end

function Button:SetText(t)    self._lbl.Text = t end
function Button:SetDisabled(d)
    self.Disabled = d
    local T = Util.Theme()
    Util.Tween(self.Instance, { BackgroundColor3 = d and T.SurfaceVariant or T.Accent })
    self._lbl.TextTransparency = d and 0.55 or 0
end

-- ─────────────────────────────────────────────────────────────
--  SLIDER
--
--  options:
--    Label       string
--    Min/Max     number (0/100)
--    Step        number (1)   – 0 = continuous
--    Default     number
--    ShowValue   bool (true)
--    Size        UDim2
--
--  events:  onValueChanged(number)  onDragStart  onDragEnd
-- ─────────────────────────────────────────────────────────────
local Slider = setmetatable({}, { __index = Component })
Slider.__index = Slider

function Slider.new(parent, opts)
    local self = setmetatable(Component.new("Slider"), Slider)
    opts = opts or {}
    local T = Util.Theme()

    self.Min   = opts.Min     or 0
    self.Max   = opts.Max     or 100
    self.Step  = opts.Step    ~= nil and opts.Step or 1
    self.Value = math.clamp(opts.Default or self.Min, self.Min, self.Max)

    -- ── Container ──────────────────────────────────────────
    local cont = Util.New("Frame", {
        Size             = opts.Size or UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = T.Surface,
        ClipsDescendants = false,
    }, parent)
    Util.Corner(cont, 10)
    Util.Pad(cont, 14, 14, 8, 8)
    self.Instance = cont

    -- ── Header row ─────────────────────────────────────────
    local header = Util.New("Frame", {
        Size                 = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex               = cont.ZIndex + 1,
    }, cont)
    Util.New("TextLabel", {
        Size                 = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                 = opts.Label or "Slider",
        TextColor3           = T.Text,
        TextSize             = Util.FontSize(13),
        Font                 = Enum.Font.GothamMedium,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = cont.ZIndex + 1,
    }, header)

    local valTxt = Util.New("TextLabel", {
        Size                 = UDim2.new(0.3, 0, 1, 0),
        Position             = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text                 = tostring(self.Value),
        TextColor3           = T.Accent,
        TextSize             = Util.FontSize(13),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Right,
        ZIndex               = cont.ZIndex + 1,
    }, header)
    self._valTxt = valTxt

    -- ── Track area ─────────────────────────────────────────
    local trackArea = Util.New("Frame", {
        Size                 = UDim2.new(1, 0, 0, 28),
        Position             = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex               = cont.ZIndex + 1,
    }, cont)

    local TRACK_H = 5
    local track = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, TRACK_H),
        Position         = UDim2.new(0, 0, 0.5, -TRACK_H / 2),
        BackgroundColor3 = T.SliderTrack,
        ZIndex           = cont.ZIndex + 2,
    }, trackArea)
    Util.Corner(track, 999)
    self._track = track

    local fill = Util.New("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.SliderFill,
        ZIndex           = cont.ZIndex + 3,
    }, track)
    Util.Corner(fill, 999)
    self._fill = fill

    -- ── Thumb ──────────────────────────────────────────────
    local THUMB = 22
    local thumb = Util.New("Frame", {
        Size             = UDim2.new(0, THUMB, 0, THUMB),
        Position         = UDim2.new(0, 0, 0.5, -THUMB / 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex           = cont.ZIndex + 4,
    }, track)
    Util.Corner(thumb, 999)
    Util.Stroke(thumb, T.SliderFill, 2.5, 0)
    self._thumb = thumb
    self._THUMB = THUMB

    -- ── Drag logic ─────────────────────────────────────────
    local dragging = false

    local function applyInput(screenX)
        local tPos  = track.AbsolutePosition.X
        local tW    = track.AbsoluteSize.X
        local half  = THUMB / 2
        local relX  = math.clamp(screenX - tPos - half, 0, tW - THUMB)
        local ratio = relX / math.max(1, tW - THUMB)
        local raw   = self.Min + ratio * (self.Max - self.Min)
        local val
        if self.Step > 0 then
            val = math.clamp(math.round(raw / self.Step) * self.Step, self.Min, self.Max)
        else
            val = math.clamp(raw, self.Min, self.Max)
        end
        self:_updateVisual(val)
        self:Fire("onValueChanged", val)
    end

    self:Track(thumb.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Util.Tween(thumb, { Size = UDim2.new(0, THUMB+7, 0, THUMB+7) }, 0.1)
            self:Fire("onDragStart", self.Value)
        end
    end))

    self:Track(track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            applyInput(inp.Position.X)
        end
    end))

    self:Track(UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch or
                         inp.UserInputType == Enum.UserInputType.MouseMovement) then
            applyInput(inp.Position.X)
        end
    end))

    self:Track(UserInputService.InputEnded:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch or
                         inp.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            Util.Tween(thumb, { Size = UDim2.new(0, THUMB, 0, THUMB) }, 0.1)
            self:Fire("onDragEnd", self.Value)
        end
    end))

    -- Initial visual
    -- Defer one frame so AbsoluteSize is valid
    task.defer(function()
        if not self._destroyed then self:_updateVisual(self.Value) end
    end)

    return self
end

function Slider:_updateVisual(val)
    self.Value = val
    local tW   = self._track.AbsoluteSize.X
    local TH   = self._THUMB
    if tW <= 0 then return end
    local ratio = (val - self.Min) / math.max(1, self.Max - self.Min)
    local thumbX = ratio * (tW - TH)
    self._thumb.Position = UDim2.new(0, thumbX, 0.5, -TH / 2)
    self._fill.Size      = UDim2.new(0, thumbX + TH / 2, 1, 0)
    -- Display text
    local disp = (self.Step >= 1 or self.Step == 0)
        and math.round(val)
        or  tonumber(string.format("%.2f", val))
    self._valTxt.Text = tostring(disp)
end

function Slider:SetValue(val, silent)
    val = math.clamp(val, self.Min, self.Max)
    if self.Step > 0 then
        val = math.clamp(math.round(val / self.Step) * self.Step, self.Min, self.Max)
    end
    self:_updateVisual(val)
    if not silent then self:Fire("onValueChanged", val) end
end

-- ─────────────────────────────────────────────────────────────
--  TEXTBOX
--
--  options:
--    Label       string
--    Placeholder string
--    Default     string
--    Mode        "text" | "numeric" | "password"
--    MaxLength   number (100)
--    ClearOnFocus bool
--    Size        UDim2
--
--  events:  onTextChanged(text)  onFocused  onFocusLost(text, enter)
--           onSubmit(text)
-- ─────────────────────────────────────────────────────────────
local TextBox = setmetatable({}, { __index = Component })
TextBox.__index = TextBox

function TextBox.new(parent, opts)
    local self = setmetatable(Component.new("TextBox"), TextBox)
    opts = opts or {}
    local T = Util.Theme()

    self.Mode      = opts.Mode      or "text"
    self.MaxLength = opts.MaxLength or 100

    local hasLabel = opts.Label ~= nil
    local contH    = hasLabel and 68 or 46

    -- ── Container ──────────────────────────────────────────
    local cont = Util.New("Frame", {
        Size             = opts.Size or UDim2.new(1, 0, 0, contH),
        BackgroundColor3 = T.Surface,
        ClipsDescendants = false,
    }, parent)
    Util.Corner(cont, 10)
    Util.Pad(cont, 14, 14, 8, 8)
    self.Instance = cont

    -- ── Optional floating label ────────────────────────────
    if hasLabel then
        Util.New("TextLabel", {
            Size                 = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text                 = opts.Label,
            TextColor3           = T.TextSecondary,
            TextSize             = Util.FontSize(11),
            Font                 = Enum.Font.GothamSemibold,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = cont.ZIndex + 1,
        }, cont)
    end

    -- ── Input frame ────────────────────────────────────────
    local inputH = 34
    local inputFr = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, inputH),
        Position         = UDim2.new(0, 0, 0, hasLabel and 22 or 6),
        BackgroundColor3 = T.SurfaceVariant,
        ZIndex           = cont.ZIndex + 1,
    }, cont)
    Util.Corner(inputFr, 8)
    local border = Util.Stroke(inputFr, T.Border, 1)
    self._border = border

    -- ── Actual TextBox ─────────────────────────────────────
    local tb = Util.New("TextBox", {
        Size                 = UDim2.new(1, -16, 1, 0),
        Position             = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText      = opts.Placeholder or "Type here...",
        PlaceholderColor3    = T.TextDisabled,
        Text                 = opts.Default or "",
        TextColor3           = T.Text,
        TextSize             = Util.FontSize(13),
        Font                 = Enum.Font.Gotham,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ClearTextOnFocus     = opts.ClearOnFocus or false,
        ZIndex               = cont.ZIndex + 2,
    }, inputFr)
    self._tb = tb

    -- Password mode: overlay dots label
    if self.Mode == "password" then
        tb.TextTransparency = 1
        local pwDots = Util.New("TextLabel", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = "",
            TextColor3           = T.Text,
            TextSize             = Util.FontSize(14),
            Font                 = Enum.Font.Gotham,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = cont.ZIndex + 3,
        }, inputFr)
        self:Track(tb:GetPropertyChangedSignal("Text"):Connect(function()
            pwDots.Text = string.rep("●", #tb.Text)
        end))
    end

    -- ── Events ─────────────────────────────────────────────
    self:Track(tb.Focused:Connect(function()
        Util.Tween(border, { Color = T.Accent, Thickness = 2 }, 0.18)
        self:Fire("onFocused")
    end))

    self:Track(tb.FocusLost:Connect(function(enter)
        Util.Tween(border, { Color = T.Border, Thickness = 1 }, 0.18)
        -- Numeric guard
        if self.Mode == "numeric" then
            local n = tonumber(tb.Text)
            tb.Text = n and tostring(n) or (opts.Default and tostring(opts.Default) or "")
        end
        -- Clamp length
        if #tb.Text > self.MaxLength then
            tb.Text = string.sub(tb.Text, 1, self.MaxLength)
        end
        self:Fire("onFocusLost", tb.Text, enter)
        if enter then
            self:Fire("onSubmit", tb.Text)
            Util.Sound(KoiUI.Config.ClickSoundId)
        end
    end))

    self:Track(tb:GetPropertyChangedSignal("Text"):Connect(function()
        self:Fire("onTextChanged", tb.Text)
    end))

    return self
end

function TextBox:GetText()    return self._tb.Text end
function TextBox:SetText(t)   self._tb.Text = tostring(t) end
function TextBox:Clear()      self._tb.Text = "" end
function TextBox:Focus()      self._tb:CaptureFocus() end

-- ─────────────────────────────────────────────────────────────
--  DROPDOWN
--
--  options:
--    Items       table   – list of strings
--    Default     string|table
--    MultiSelect bool (false)
--    Searchable  bool (true)
--    MaxVisible  number (5)  – items shown before scroll
--    Label       string
--    Size        UDim2
--
--  events:  onSelectionChanged(selection)   onOpen   onClose
-- ─────────────────────────────────────────────────────────────
local Dropdown = setmetatable({}, { __index = Component })
Dropdown.__index = Dropdown

function Dropdown.new(parent, opts)
    local self = setmetatable(Component.new("Dropdown"), Dropdown)
    opts = opts or {}
    local T = Util.Theme()

    self.Items       = opts.Items       or {}
    self.Multi       = opts.MultiSelect or false
    self.Searchable  = opts.Searchable  ~= false
    self.MaxVis      = opts.MaxVisible  or 5
    self.IsOpen      = false
    self._ITEM_H     = 40

    -- Selected state
    if self.Multi then
        self.Selected = type(opts.Default) == "table" and opts.Default or {}
    else
        self.Selected = type(opts.Default) == "string" and opts.Default or nil
    end

    -- ── Container ──────────────────────────────────────────
    local cont = Util.New("Frame", {
        Size             = opts.Size or UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.Surface,
        ClipsDescendants = false,
        ZIndex           = 10,
    }, parent)
    Util.Corner(cont, 10)
    self.Instance = cont

    -- Optional label above
    local labelOffset = 0
    if opts.Label then
        labelOffset = 22
        cont.Size = UDim2.new(
            (opts.Size or UDim2.new(1,0,0,44)).X.Scale,
            (opts.Size or UDim2.new(1,0,0,44)).X.Offset,
            0, 44 + labelOffset)
        Util.New("TextLabel", {
            Size                 = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text                 = opts.Label,
            TextColor3           = T.TextSecondary,
            TextSize             = Util.FontSize(11),
            Font                 = Enum.Font.GothamSemibold,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 11,
        }, cont)
    end

    self._baseH    = (opts.Size and opts.Size.Y.Offset or 44)
    self._labelOff = labelOffset

    -- ── Header ─────────────────────────────────────────────
    local header = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        Position         = UDim2.new(0, 0, 0, labelOffset),
        BackgroundColor3 = T.SurfaceVariant,
        ZIndex           = 11,
    }, cont)
    Util.Corner(header, 10)
    Util.Stroke(header, T.Border, 1)
    Util.Pad(header, 14, 14, 0, 0)
    self._header = header

    local selTxt = Util.New("TextLabel", {
        Size                 = UDim2.new(1, -32, 1, 0),
        BackgroundTransparency = 1,
        Text                 = self:_displayText(),
        TextColor3           = self.Selected and T.Text or T.TextDisabled,
        TextSize             = Util.FontSize(13),
        Font                 = Enum.Font.GothamMedium,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextTruncate         = Enum.TextTruncate.AtEnd,
        ZIndex               = 12,
    }, header)
    self._selTxt = selTxt

    local arrow = Util.New("TextLabel", {
        Size                 = UDim2.new(0, 28, 1, 0),
        Position             = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text                 = "▾",
        TextColor3           = T.TextSecondary,
        TextSize             = Util.FontSize(15),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Center,
        ZIndex               = 12,
    }, header)
    self._arrow = arrow

    -- ── List panel ─────────────────────────────────────────
    local listY    = labelOffset + 48
    local list = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 0, listY),
        BackgroundColor3 = T.SurfaceVariant,
        ClipsDescendants = true,
        ZIndex           = 20,
        Visible          = false,
    }, cont)
    Util.Corner(list, 10)
    Util.Stroke(list, T.Border, 1)
    self._list = list

    -- Search box inside list
    local SEARCH_H = self.Searchable and 38 or 0
    if self.Searchable then
        local sFrame = Util.New("Frame", {
            Size             = UDim2.new(1, 0, 0, SEARCH_H),
            BackgroundColor3 = T.Surface,
            ZIndex           = 21,
        }, list)
        Util.Pad(sFrame, 10, 10, 4, 4)
        local sTb = Util.New("TextBox", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            PlaceholderText      = "Search...",
            PlaceholderColor3    = T.TextDisabled,
            Text                 = "",
            TextColor3           = T.Text,
            TextSize             = Util.FontSize(12),
            Font                 = Enum.Font.Gotham,
            ZIndex               = 22,
        }, sFrame)
        self._search = sTb
        self:Track(sTb:GetPropertyChangedSignal("Text"):Connect(function()
            self:_filterItems(sTb.Text)
        end))
    end

    -- Scrollable items area
    local scroll = Util.New("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, -SEARCH_H),
        Position             = UDim2.new(0, 0, 0, SEARCH_H),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.Scrollbar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        ZIndex               = 21,
    }, list)
    Util.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
    self._scroll   = scroll
    self._SEARCH_H = SEARCH_H

    self:_populateItems()

    -- ── Header tap ────────────────────────────────────────
    self:Track(header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.IsOpen then self:Close() else self:Open() end
        end
    end))

    -- Close on outside tap
    self:Track(UserInputService.InputBegan:Connect(function(inp)
        if not self.IsOpen then return end
        if inp.UserInputType ~= Enum.UserInputType.Touch and
           inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        task.defer(function()
            if self._destroyed then return end
            local x, y = inp.Position.X, inp.Position.Y
            if not Util.HitTest(list, x, y) and not Util.HitTest(header, x, y) then
                self:Close()
            end
        end)
    end))

    return self
end

function Dropdown:_displayText()
    if self.Multi then
        if type(self.Selected) == "table" and #self.Selected > 0 then
            return table.concat(self.Selected, ", ")
        end
        return "Select..."
    else
        return self.Selected or "Select..."
    end
end

function Dropdown:_populateItems()
    for _, ch in ipairs(self._scroll:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    local T = Util.Theme()
    local IH = self._ITEM_H

    for i, item in ipairs(self.Items) do
        local isSel = self.Multi
            and (table.find(self.Selected, item) ~= nil)
            or  (self.Selected == item)

        local fr = Util.New("Frame", {
            Size             = UDim2.new(1, 0, 0, IH),
            BackgroundColor3 = isSel and T.Accent or T.SurfaceVariant,
            BackgroundTransparency = isSel and 0.82 or 1,
            LayoutOrder      = i,
            ZIndex           = 22,
        }, self._scroll)
        Util.Pad(fr, 14, 14, 0, 0)

        Util.New("TextLabel", {
            Size                 = UDim2.new(1, -30, 1, 0),
            BackgroundTransparency = 1,
            Text                 = tostring(item),
            TextColor3           = isSel and T.Accent or T.Text,
            TextSize             = Util.FontSize(13),
            Font                 = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 23,
        }, fr)

        Util.New("TextLabel", {
            Size                 = UDim2.new(0, 22, 1, 0),
            Position             = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Text                 = isSel and "✓" or "",
            TextColor3           = T.Accent,
            TextSize             = Util.FontSize(13),
            Font                 = Enum.Font.GothamBold,
            TextXAlignment       = Enum.TextXAlignment.Center,
            ZIndex               = 23,
        }, fr)

        -- Divider
        if i < #self.Items then
            Util.New("Frame", {
                Size             = UDim2.new(1, -28, 0, 1),
                Position         = UDim2.new(0, 14, 1, -1),
                BackgroundColor3 = T.Border,
                BackgroundTransparency = 0.65,
                ZIndex           = 23,
            }, fr)
        end

        self:Track(fr.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or
               inp.UserInputType == Enum.UserInputType.MouseButton1 then
                self:_selectItem(item)
            end
        end))
    end

    self._scroll.CanvasSize = UDim2.new(0, 0, 0, #self.Items * IH)
end

function Dropdown:_filterItems(query)
    query = query:lower()
    for _, ch in ipairs(self._scroll:GetChildren()) do
        if ch:IsA("Frame") then
            local lbl = ch:FindFirstChildWhichIsA("TextLabel")
            if lbl then
                ch.Visible = query == "" or (lbl.Text:lower():find(query, 1, true) ~= nil)
            end
        end
    end
end

function Dropdown:_selectItem(item)
    if self.Multi then
        local idx = table.find(self.Selected, item)
        if idx then table.remove(self.Selected, idx)
        else        table.insert(self.Selected, item) end
    else
        self.Selected = item
        self:Close()
    end
    local T = Util.Theme()
    self._selTxt.Text      = self:_displayText()
    self._selTxt.TextColor3 = (self.Multi and #self.Selected > 0) or
                               (not self.Multi and self.Selected)
                               and T.Text or T.TextDisabled
    self:_populateItems()
    Util.Sound(KoiUI.Config.ClickSoundId)
    self:Fire("onSelectionChanged", self.Selected)
end

function Dropdown:Open()
    self.IsOpen = true
    self._list.Visible = true
    self._list.Size = UDim2.new(1, 0, 0, 0)

    -- Compute target height
    local visible = 0
    for _, ch in ipairs(self._scroll:GetChildren()) do
        if ch:IsA("Frame") and ch.Visible then visible = visible + 1 end
    end
    visible = math.max(1, math.min(visible, self.MaxVis))
    local tH = self._SEARCH_H + visible * self._ITEM_H

    Util.Tween(self._list, { Size = UDim2.new(1, 0, 0, tH) }, 0.22)
    Util.Tween(self._arrow, { Rotation = 180 }, 0.2)
    Util.Tween(self.Instance, {
        Size = UDim2.new(
            self.Instance.Size.X.Scale, self.Instance.Size.X.Offset,
            0, self._baseH + self._labelOff + tH + 8)
    }, 0.22)
    self:Fire("onOpen")
end

function Dropdown:Close()
    self.IsOpen = false
    Util.Tween(self._list, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
    Util.Tween(self._arrow, { Rotation = 0 }, 0.18)
    Util.Tween(self.Instance, {
        Size = UDim2.new(
            self.Instance.Size.X.Scale, self.Instance.Size.X.Offset,
            0, self._baseH + self._labelOff)
    }, 0.18)
    task.delay(0.2, function()
        if not self.IsOpen and not self._destroyed then
            self._list.Visible = false
        end
    end)
    self:Fire("onClose")
end

function Dropdown:GetSelected()   return self.Selected end
function Dropdown:ClearSelection()
    self.Selected = self.Multi and {} or nil
    self._selTxt.Text = self:_displayText()
    self:_populateItems()
end

function Dropdown:SetItems(items)
    self.Items = items
    self:_populateItems()
    if self.IsOpen then self:Close() task.delay(0.25, function() self:Open() end) end
end

-- ─────────────────────────────────────────────────────────────
--  TABS
--
--  options:
--    Tabs    { { Name = "...", Build = function(frame) ... end }, ... }
--    Default string  – initial active tab name
--    Height  number  – pixel height of tabs widget
--    Size    UDim2
--
--  events:  onTabChanged(name)
-- ─────────────────────────────────────────────────────────────
local Tabs = setmetatable({}, { __index = Component })
Tabs.__index = Tabs

function Tabs.new(parent, opts)
    local self = setmetatable(Component.new("Tabs"), Tabs)
    opts = opts or {}
    local T = Util.Theme()

    self._tabDefs   = opts.Tabs or {}
    self._active    = opts.Default or (self._tabDefs[1] and self._tabDefs[1].Name) or ""
    self._frames    = {}   -- name → { Frame, Scroll, Index }
    self._buttons   = {}   -- name → { Frame, Label, Index }
    self._prevActive = nil

    -- ── Container ──────────────────────────────────────────
    local cont = Util.New("Frame", {
        Size                 = opts.Size or UDim2.new(1, 0, 0, opts.Height or 300),
        BackgroundTransparency = 1,
        ClipsDescendants     = false,
    }, parent)
    self.Instance = cont

    -- ── Tab bar ────────────────────────────────────────────
    local BAR_H = 44
    local bar = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, BAR_H),
        BackgroundColor3 = T.Surface,
        ZIndex           = 2,
    }, cont)
    Util.Corner(bar, 10)
    Util.New("UIListLayout", {
        FillDirection        = Enum.FillDirection.Horizontal,
        SortOrder            = Enum.SortOrder.LayoutOrder,
        Padding              = UDim.new(0, 4),
        VerticalAlignment    = Enum.VerticalAlignment.Center,
    }, bar)
    Util.Pad(bar, 4, 4, 4, 4)
    self._bar = bar

    -- Moving indicator pill
    local tabCount = math.max(1, #self._tabDefs)
    local indicator = Util.New("Frame", {
        Size             = UDim2.new(1 / tabCount, -4, 1, 0),
        Position         = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = T.Accent,
        ZIndex           = 3,
    }, bar)
    Util.Corner(indicator, 8)
    self._indicator = indicator

    -- ── Content area ───────────────────────────────────────
    local content = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 1, -(BAR_H + 8)),
        Position         = UDim2.new(0, 0, 0, BAR_H + 8),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 2,
    }, cont)
    self._content = content

    -- Build each tab
    for i, def in ipairs(self._tabDefs) do
        self:_buildButton(def, i)
        self:_buildContent(def, i)
    end

    -- Show default
    if self._active ~= "" then
        self:Switch(self._active, false)
    end

    return self
end

function Tabs:_buildButton(def, idx)
    local T      = Util.Theme()
    local n      = #self._tabDefs
    local isAct  = self._active == def.Name

    local btn = Util.New("Frame", {
        Size                 = UDim2.new(1 / n, 0, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder          = idx,
        ZIndex               = 4,
    }, self._bar)

    local lbl = Util.New("TextLabel", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                 = def.Name,
        TextColor3           = isAct and Color3.new(1,1,1) or T.TextSecondary,
        TextSize             = Util.FontSize(13),
        Font                 = isAct and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        TextXAlignment       = Enum.TextXAlignment.Center,
        ZIndex               = 5,
    }, btn)

    self._buttons[def.Name] = { Frame = btn, Label = lbl, Index = idx }

    self:Track(btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Switch(def.Name, true)
        end
    end))
end

function Tabs:_buildContent(def, idx)
    local frame = Util.New("Frame", {
        Size                 = UDim2.new(1, 0, 1, 0),
        Position             = UDim2.new(idx == 1 and 0 or 1.05, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible              = idx == 1,
        ClipsDescendants     = false,
        ZIndex               = 2,
    }, self._content)

    local scroll = Util.New("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = Util.Theme().Scrollbar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 2,
    }, frame)
    Util.New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 8),
    }, scroll)
    Util.Pad(scroll, 0, 0, 4, 8)

    self._frames[def.Name] = { Frame = frame, Scroll = scroll, Index = idx }

    if def.Build then
        task.defer(function()
            if not self._destroyed then def.Build(scroll) end
        end)
    end
end

function Tabs:Switch(name, animate)
    if not self._frames[name] then return end
    local T      = Util.Theme()
    local n      = #self._tabDefs
    local newIdx = self._frames[name].Index
    local oldIdx = self._frames[self._active] and self._frames[self._active].Index or 0
    self._prevActive = self._active
    self._active     = name

    -- Move indicator
    local ipct = (newIdx - 1) / n
    if animate then
        Util.Tween(self._indicator, {
            Position = UDim2.new(ipct, 4, 0, 0),
            Size     = UDim2.new(1 / n, -4, 1, 0),
        }, 0.2)
    else
        self._indicator.Position = UDim2.new(ipct, 4, 0, 0)
        self._indicator.Size     = UDim2.new(1 / n, -4, 1, 0)
    end

    -- Update buttons
    for tname, bd in pairs(self._buttons) do
        local act = (tname == name)
        Util.Tween(bd.Label, {
            TextColor3 = act and Color3.new(1,1,1) or T.TextSecondary
        }, 0.18)
        bd.Label.Font = act and Enum.Font.GothamBold or Enum.Font.GothamMedium
    end

    -- Slide content
    for tname, fd in pairs(self._frames) do
        local act = (tname == name)
        if act then
            fd.Frame.Visible = true
            if animate then
                local dir = fd.Index >= oldIdx and 1.05 or -1.05
                fd.Frame.Position = UDim2.new(dir, 0, 0, 0)
                Util.Tween(fd.Frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.22)
            else
                fd.Frame.Position = UDim2.new(0, 0, 0, 0)
            end
        else
            if animate then
                local dir = fd.Index < newIdx and -1.05 or 1.05
                Util.Tween(fd.Frame, { Position = UDim2.new(dir, 0, 0, 0) }, 0.22)
                task.delay(0.25, function()
                    if not self._destroyed then fd.Frame.Visible = false end
                end)
            else
                fd.Frame.Visible  = false
                fd.Frame.Position = UDim2.new(1.05, 0, 0, 0)
            end
        end
    end

    Util.Sound(KoiUI.Config.ClickSoundId)
    self:Fire("onTabChanged", name)
end

-- Returns the ScrollingFrame for a named tab (use to add components to it)
function Tabs:GetFrame(name)
    local fd = self._frames[name]
    return fd and fd.Scroll or nil
end

function Tabs:GetActiveTab() return self._active end

-- ─────────────────────────────────────────────────────────────
--  TITLEBAR  (draggable window handle)
--
--  options:
--    Title       string
--    Subtitle    string
--    Minimizable bool (true)
--    Size        UDim2
--    -- internal --
--    _window     Frame  – the parent window frame (for drag)
--    _content    Frame  – the content frame (for minimize)
--
--  events:  onClose   onMinimize(bool)
-- ─────────────────────────────────────────────────────────────
local TitleBar = setmetatable({}, { __index = Component })
TitleBar.__index = TitleBar

function TitleBar.new(parent, opts)
    local self = setmetatable(Component.new("TitleBar"), TitleBar)
    opts = opts or {}
    local T = Util.Theme()

    self._dragging   = false
    self._dragStart  = nil
    self._winStart   = nil
    self._minimized  = false
    self._win        = opts._window  or parent
    self._content    = opts._content

    -- ── Bar ────────────────────────────────────────────────
    local bar = Util.New("Frame", {
        Size             = opts.Size or UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = T.TitleBar,
        ClipsDescendants = true,
        ZIndex           = 6,
    }, parent)
    Util.Corner(bar, 12)
    Util.Pad(bar, 16, 12, 0, 0)
    self.Instance = bar

    -- ── Title ──────────────────────────────────────────────
    local titleLbl = Util.New("TextLabel", {
        Size                 = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Text                 = opts.Title or "KoiUI",
        TextColor3           = T.Text,
        TextSize             = Util.FontSize(15),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = 7,
    }, bar)
    self._titleLbl = titleLbl

    -- Subtitle badge
    if opts.Subtitle then
        local badge = Util.New("Frame", {
            Size             = UDim2.new(0, 52, 0, 18),
            Position         = UDim2.new(0, 0, 0.5, -9),
            AnchorPoint      = Vector2.new(0, 0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 0.8,
            ZIndex           = 7,
        }, bar)
        Util.Corner(badge, 6)
        Util.New("TextLabel", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = opts.Subtitle,
            TextColor3           = T.Accent,
            TextSize             = Util.FontSize(10),
            Font                 = Enum.Font.GothamBold,
            TextXAlignment       = Enum.TextXAlignment.Center,
            ZIndex               = 8,
        }, badge)
        -- Shift title right
        titleLbl.Position = UDim2.new(0, 58, 0, 0)
        titleLbl.Size     = UDim2.new(1, -170, 1, 0)
        badge.Position    = UDim2.new(0, 0, 0.5, -9)
    end

    -- ── Control buttons ────────────────────────────────────
    local btnArea = Util.New("Frame", {
        Size                 = UDim2.new(0, 96, 1, 0),
        Position             = UDim2.new(1, -96, 0, 0),
        BackgroundTransparency = 1,
        ZIndex               = 7,
    }, bar)
    Util.New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 6),
    }, btnArea)

    -- Minimize
    if opts.Minimizable ~= false then
        local minBtn = self:_makeBtn("—", T.TextSecondary, btnArea)
        self:Track(minBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or
               inp.UserInputType == Enum.UserInputType.MouseButton1 then
                self:_toggleMinimize()
            end
        end))
        self._minBtn = minBtn
    end

    -- Close
    local closeBtn = self:_makeBtn("✕", Color3.fromRGB(248, 113, 113), btnArea)
    self:Track(closeBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Util.Sound(KoiUI.Config.ClickSoundId)
            self:Fire("onClose")
        end
    end))

    -- ── Drag ───────────────────────────────────────────────
    local win = self._win

    self:Track(bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging  = true
            self._dragStart = inp.Position
            self._winStart  = win.Position
        end
    end))

    self:Track(UserInputService.InputChanged:Connect(function(inp)
        if not self._dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.Touch and
           inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = inp.Position - self._dragStart
        local sw, sh = Util.Screen()
        local ww = win.AbsoluteSize.X
        win.Position = UDim2.new(0,
            math.clamp(self._winStart.X.Offset + delta.X, 0, sw - ww),
            0,
            math.clamp(self._winStart.Y.Offset + delta.Y,
                KoiUI.Config.SafeAreaTop, sh - 48))
    end))

    self:Track(UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = false
        end
    end))

    return self
end

function TitleBar:_makeBtn(icon, color, parent)
    local btn = Util.New("Frame", {
        Size             = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.82,
        ZIndex           = 8,
    }, parent)
    Util.Corner(btn, 999)
    Util.New("TextLabel", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                 = icon,
        TextColor3           = color,
        TextSize             = Util.FontSize(12),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Center,
        ZIndex               = 9,
    }, btn)

    self:Track(btn.MouseEnter:Connect(function()
        Util.Tween(btn, { BackgroundTransparency = 0.45 }, 0.1)
    end))
    self:Track(btn.MouseLeave:Connect(function()
        Util.Tween(btn, { BackgroundTransparency = 0.82 }, 0.12)
    end))
    return btn
end

function TitleBar:_toggleMinimize()
    self._minimized = not self._minimized
    local c = self._content
    if c then
        if self._minimized then
            self._contentOrigH = c.Size.Y.Offset
            Util.Tween(c, { Size = UDim2.new(c.Size.X.Scale, c.Size.X.Offset, 0, 0) }, 0.25)
        else
            Util.Tween(c, {
                Size = UDim2.new(c.Size.X.Scale, c.Size.X.Offset, 0, self._contentOrigH or 400)
            }, 0.28)
        end
    end
    self:Fire("onMinimize", self._minimized)
end

function TitleBar:SetTitle(t)    self._titleLbl.Text = t end
function TitleBar:IsMinimized()  return self._minimized end

-- ─────────────────────────────────────────────────────────────
--  LABEL / SEPARATOR  (lightweight helpers)
-- ─────────────────────────────────────────────────────────────
local function createLabel(parent, opts)
    opts = opts or {}
    local T = Util.Theme()
    return Util.New("TextLabel", {
        Size                 = opts.Size or UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text                 = opts.Text or "",
        TextColor3           = opts.Color or T.TextSecondary,
        TextSize             = Util.FontSize(opts.TextSize or 12),
        Font                 = opts.Font or Enum.Font.Gotham,
        TextXAlignment       = opts.Align or Enum.TextXAlignment.Left,
        TextWrapped          = opts.Wrap  or false,
        RichText             = opts.Rich  or false,
    }, parent)
end

local function createSeparator(parent, opts)
    opts = opts or {}
    local T = Util.Theme()

    if opts.Label then
        local wrap = Util.New("Frame", {
            Size                 = opts.Size or UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
        }, parent)
        Util.New("Frame", { Size = UDim2.new(0.38, -8, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.Border }, wrap)
        Util.New("Frame", { Size = UDim2.new(0.38, -8, 0, 1),
            Position = UDim2.new(0.62, 8, 0.5, 0),
            BackgroundColor3 = T.Border }, wrap)
        Util.New("TextLabel", {
            Size = UDim2.new(0.24, 0, 1, 0),
            Position = UDim2.new(0.38, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = opts.Label,
            TextColor3 = T.TextSecondary,
            TextSize = Util.FontSize(11),
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, wrap)
        return wrap
    end

    return Util.New("Frame", {
        Size             = opts.Size or UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = opts.Color or T.Border,
        BackgroundTransparency = opts.Transparency or 0,
    }, parent)
end

-- ═════════════════════════════════════════════════════════════
--
--  ███╗   ██╗ ██████╗ ████████╗██╗███████╗
--  ████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝
--  ██╔██╗ ██║██║   ██║   ██║   ██║█████╗
--  ██║╚██╗██║██║   ██║   ██║   ██║██╔══╝
--  ██║ ╚████║╚██████╔╝   ██║   ██║██║
--  ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝
--  NOTIFICATION SYSTEM
--
-- ═════════════════════════════════════════════════════════════
local Notif = {}
Notif._container = nil
Notif._active    = {}

-- Call once per ScreenGui
function Notif.Init(screenGui)
    if Notif._container and Notif._container.Parent == screenGui then return end

    local w, _ = Util.Screen()
    local cW   = math.min(320, w - 24)

    local cont = Util.New("Frame", {
        Size                 = UDim2.new(0, cW, 1, 0),
        Position             = UDim2.new(1, -(cW + 10), 0, 0),
        BackgroundTransparency = 1,
        ZIndex               = 100,
    }, screenGui)
    Util.New("UIListLayout", {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding           = UDim.new(0, 6),
    }, cont)
    Util.Pad(cont, 0, 0, 0, KoiUI.Config.SafeAreaBottom + 10)
    Notif._container = cont
end

--[[
  Notif.Show(opts):
    Type      "info"|"success"|"warning"|"error"|"toast"
    Title     string
    Body      string  (optional)
    Icon      string  (optional override)
    Duration  number  (seconds, default Config.NotificationDuration)
    ActionText  string
    onAction  function
    onDismiss function
]]
function Notif.Show(opts)
    opts = opts or {}
    if not Notif._container or not Notif._container.Parent then return end

    local T = Util.Theme()

    -- Evict oldest if over limit
    if #Notif._active >= KoiUI.Config.MaxNotifications then
        local oldest = Notif._active[1]
        if oldest then oldest:Dismiss() end
    end

    local TYPE_DATA = {
        info    = { color = T.Info,    icon = "ℹ" },
        success = { color = T.Success, icon = "✓" },
        warning = { color = T.Warning, icon = "⚠" },
        error   = { color = T.Error,   icon = "✕" },
        toast   = { color = T.Accent,  icon = "◆" },
    }
    local td       = TYPE_DATA[opts.Type or "info"] or TYPE_DATA.info
    local color    = td.color
    local icon     = opts.Icon or td.icon
    local hasBody  = opts.Body ~= nil
    local hasAct   = opts.ActionText ~= nil
    local notifH   = hasBody and 76 or 58

    -- ── Card ───────────────────────────────────────────────
    local card = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, notifH),
        BackgroundColor3 = T.Surface,
        ClipsDescendants = true,
        ZIndex           = 101,
        LayoutOrder      = tick(),
    }, Notif._container)
    Util.Corner(card, 12)
    Util.Stroke(card, color, 1, 0.72)

    -- Left accent bar
    Util.New("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = color,
        ZIndex           = 102,
    }, card)

    -- Icon
    Util.New("TextLabel", {
        Size                 = UDim2.new(0, 40, 1, 0),
        Position             = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text                 = icon,
        TextColor3           = color,
        TextSize             = Util.FontSize(20),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Center,
        ZIndex               = 102,
    }, card)

    -- Title
    local titleRX = hasAct and -70 or -8
    Util.New("TextLabel", {
        Size                 = UDim2.new(1, titleRX, 0, 22),
        Position             = UDim2.new(0, 52, 0, hasBody and 10 or (notifH/2 - 11)),
        BackgroundTransparency = 1,
        Text                 = opts.Title or "Notification",
        TextColor3           = T.Text,
        TextSize             = Util.FontSize(13),
        Font                 = Enum.Font.GothamBold,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextTruncate         = Enum.TextTruncate.AtEnd,
        ZIndex               = 102,
    }, card)

    -- Body
    if hasBody then
        Util.New("TextLabel", {
            Size                 = UDim2.new(1, -60, 0, 18),
            Position             = UDim2.new(0, 52, 0, 36),
            BackgroundTransparency = 1,
            Text                 = opts.Body,
            TextColor3           = T.TextSecondary,
            TextSize             = Util.FontSize(11),
            Font                 = Enum.Font.Gotham,
            TextXAlignment       = Enum.TextXAlignment.Left,
            TextTruncate         = Enum.TextTruncate.AtEnd,
            ZIndex               = 102,
        }, card)
    end

    -- Action button
    if hasAct then
        local actBadge = Util.New("Frame", {
            Size             = UDim2.new(0, 56, 0, 24),
            Position         = UDim2.new(1, -62, 0.5, -12),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.82,
            ZIndex           = 103,
        }, card)
        Util.Corner(actBadge, 7)
        Util.New("TextLabel", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = opts.ActionText,
            TextColor3           = color,
            TextSize             = Util.FontSize(11),
            Font                 = Enum.Font.GothamBold,
            TextXAlignment       = Enum.TextXAlignment.Center,
            ZIndex               = 104,
        }, actBadge)
        actBadge.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or
               inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if opts.onAction then pcall(opts.onAction) end
            end
        end)
    end

    -- Progress bar
    local prog = Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.3,
        ZIndex           = 103,
    }, card)

    -- ── Notif object ───────────────────────────────────────
    local obj = { Instance = card, _active = true }

    function obj:Dismiss()
        if not self._active then return end
        self._active = false
        Util.Tween(card, {
            Position             = UDim2.new(1.15, 0, card.Position.Y.Scale, card.Position.Y.Offset),
            BackgroundTransparency = 1
        }, 0.25)
        task.delay(0.28, function()
            pcall(function() card:Destroy() end)
            for i, n in ipairs(Notif._active) do
                if n == obj then table.remove(Notif._active, i) break end
            end
        end)
        if opts.onDismiss then pcall(opts.onDismiss) end
    end

    table.insert(Notif._active, obj)

    -- Slide-in
    card.Position = UDim2.new(1.15, 0, card.Position.Y.Scale, card.Position.Y.Offset)
    Util.TweenBounce(card, {
        Position = UDim2.new(0, 0, card.Position.Y.Scale, card.Position.Y.Offset)
    }, 0.32)

    -- Progress tween
    local dur = opts.Duration or KoiUI.Config.NotificationDuration
    TweenService:Create(prog,
        TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 0, 2) }):Play()

    -- Auto-dismiss
    task.delay(dur, function()
        if obj._active then obj:Dismiss() end
    end)

    -- Swipe-right to dismiss
    local sx = nil
    card.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or
           i.UserInputType == Enum.UserInputType.MouseButton1 then
            sx = i.Position.X
        end
    end)
    card.InputEnded:Connect(function(i)
        if sx and (i.UserInputType == Enum.UserInputType.Touch or
                   i.UserInputType == Enum.UserInputType.MouseButton1) then
            if i.Position.X - sx > 55 then obj:Dismiss() end
            sx = nil
        end
    end)

    Util.Sound(KoiUI.Config.NotifSoundId)
    return obj
end

-- ═════════════════════════════════════════════════════════════
--
--  ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗
--  ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║
--  ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║
--  ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║
--  ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝
--   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝
--  WINDOW  – high-level builder
--
-- ═════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

--[[
  KoiUI:CreateWindow(screenGui, opts):
    Title      string
    Subtitle   string
    Width      number (px)
    Height     number (px)
    X / Y      number (px, initial position)
]]
function Window.new(screenGui, opts)
    local self = setmetatable({}, Window)
    opts = opts or {}
    local T = Util.Theme()

    self._components  = {}
    self._visible     = true
    self._screenGui   = screenGui
    self._connections = {}

    Notif.Init(screenGui)

    local sw, sh   = Util.Screen()
    local safe     = KoiUI.Config.SafeAreaTop
    local winW     = opts.Width  or math.min(368, sw - 24)
    local winH     = opts.Height or math.min(530, sh - safe - 24)
    local startX   = opts.X     or math.floor((sw - winW) / 2)
    local startY   = opts.Y     or math.floor(safe + (sh - safe - winH) * 0.22)

    -- ── Window frame ───────────────────────────────────────
    local frame = Util.New("Frame", {
        Size             = UDim2.new(0, winW, 0, winH),
        Position         = UDim2.new(0, startX, 0, startY),
        BackgroundColor3 = T.Background,
        ClipsDescendants = false,
        ZIndex           = 5,
    }, screenGui)
    Util.Corner(frame, 14)

    -- Drop shadow
    Util.New("Frame", {
        Size             = UDim2.new(1, 22, 1, 22),
        Position         = UDim2.new(0, -11, 0, 9),
        BackgroundColor3 = T.Shadow,
        BackgroundTransparency = 0.68,
        ZIndex           = 4,
        Parent           = frame,
    })
    Util.Corner(frame:FindFirstChildWhichIsA("Frame"), 18)

    self._frame  = frame
    self._winW   = winW
    self._winH   = winH

    -- ── Content area ───────────────────────────────────────
    local BAR_H  = 50
    local content = Util.New("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, -BAR_H),
        Position             = UDim2.new(0, 0, 0, BAR_H),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.Scrollbar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 6,
        ClipsDescendants     = true,
    }, frame)
    Util.New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 6),
    }, content)
    Util.Pad(content, 12, 12, 8, 12)
    self._content = content

    -- ── TitleBar ───────────────────────────────────────────
    local tbar = TitleBar.new(frame, {
        Title    = opts.Title    or "KoiUI",
        Subtitle = opts.Subtitle,
        Size     = UDim2.new(1, 0, 0, BAR_H),
        _window  = frame,
        _content = content,
    })
    tbar:On("onClose", function() self:Hide() end)
    self._titleBar = tbar

    -- ── Entrance animation ─────────────────────────────────
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(0, winW * 0.88, 0, winH * 0.88)
    frame.Position = UDim2.new(0,
        startX + winW * 0.06,
        0,
        startY + winH * 0.06)
    Util.TweenBounce(frame, {
        Size                 = UDim2.new(0, winW, 0, winH),
        Position             = UDim2.new(0, startX, 0, startY),
        BackgroundTransparency = 0,
    }, 0.4)

    -- ── Orientation change ─────────────────────────────────
    local oc = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        task.wait(0.12)
        if self._frame and self._frame.Parent then
            local nw, nh = Util.Screen()
            local pos = self._frame.Position
            self._frame.Position = UDim2.new(0,
                math.clamp(pos.X.Offset, 0, nw - self._frame.AbsoluteSize.X),
                0,
                math.clamp(pos.Y.Offset, safe, nh - 50))
        end
    end)
    table.insert(self._connections, oc)

    return self
end

-- ── Component factory methods ──────────────────────────────
function Window:_nextOrder()
    return #self._components + 1
end

function Window:AddButton(opts)
    opts = opts or {}
    opts.Size = opts.Size or UDim2.new(1, 0, 0, 44)
    local b = Button.new(self._content, opts)
    b.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, b)
    return b
end

function Window:AddSwitch(opts)
    opts = opts or {}
    opts.Size = opts.Size or UDim2.new(1, 0, 0, 52)
    local s = Switch.new(self._content, opts)
    s.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, s)
    return s
end

function Window:AddSlider(opts)
    opts = opts or {}
    opts.Size = opts.Size or UDim2.new(1, 0, 0, 64)
    local s = Slider.new(self._content, opts)
    s.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, s)
    return s
end

function Window:AddTextBox(opts)
    opts = opts or {}
    local h = (opts.Label and 68 or 50)
    opts.Size = opts.Size or UDim2.new(1, 0, 0, h)
    local t = TextBox.new(self._content, opts)
    t.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, t)
    return t
end

function Window:AddDropdown(opts)
    opts = opts or {}
    opts.Size = opts.Size or UDim2.new(1, 0, 0, 44)
    local d = Dropdown.new(self._content, opts)
    d.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, d)
    return d
end

function Window:AddTabs(opts)
    opts = opts or {}
    local h = opts.Height or 320
    opts.Size = opts.Size or UDim2.new(1, 0, 0, h)
    local t = Tabs.new(self._content, opts)
    t.Instance.LayoutOrder = self:_nextOrder()
    table.insert(self._components, t)
    return t
end

function Window:AddLabel(opts)
    local lbl = createLabel(self._content, opts)
    lbl.LayoutOrder = self:_nextOrder()
    table.insert(self._components, { Instance = lbl })
    return lbl
end

function Window:AddSeparator(opts)
    local sep = createSeparator(self._content, opts)
    sep.LayoutOrder = self:_nextOrder()
    table.insert(self._components, { Instance = sep })
    return sep
end

-- Notify shorthand bound to this window's screenGui
function Window:Notify(opts)
    Notif.Init(self._screenGui)
    return Notif.Show(opts)
end

-- ── Visibility ─────────────────────────────────────────────
function Window:Show()
    if self._visible then return end
    self._visible = true
    self._frame.Visible = true
    self._frame.BackgroundTransparency = 1
    self._frame.Size = UDim2.new(0, self._winW * 0.9, 0, self._winH * 0.9)
    Util.TweenBounce(self._frame, {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, self._winW, 0, self._winH),
    }, 0.32)
end

function Window:Hide()
    if not self._visible then return end
    self._visible = false
    Util.Tween(self._frame, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, self._winW * 0.9, 0, self._winH * 0.9),
    }, 0.22)
    task.delay(0.24, function()
        if not self._visible and self._frame.Parent then
            self._frame.Visible = false
            self._frame.Size    = UDim2.new(0, self._winW, 0, self._winH)
        end
    end)
end

function Window:Toggle()
    if self._visible then self:Hide() else self:Show() end
end

function Window:SetTitle(t) self._titleBar:SetTitle(t) end

function Window:Destroy()
    for _, c in ipairs(self._connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    for _, comp in ipairs(self._components) do
        if comp.Destroy then comp:Destroy() end
    end
    if self._titleBar then self._titleBar:Destroy() end
    if self._frame    then self._frame:Destroy()    end
end

-- ═════════════════════════════════════════════════════════════
--  KOIUI  PUBLIC API
-- ═════════════════════════════════════════════════════════════

-- Create a new window bound to a ScreenGui
function KoiUI:CreateWindow(screenGui, opts)
    assert(screenGui and screenGui:IsA("ScreenGui"),
        "[KoiUI] CreateWindow requires a ScreenGui as the first argument.")
    local win = Window.new(screenGui, opts)
    table.insert(self.Windows, win)
    return win
end

-- Show a notification without needing a window reference
function KoiUI:Notify(screenGui, opts)
    Notif.Init(screenGui)
    return Notif.Show(opts)
end

-- Toggle visibility of ALL registered windows
function KoiUI:ToggleUI()
    for _, win in ipairs(self.Windows) do win:Toggle() end
end
function KoiUI:ShowAll()
    for _, win in ipairs(self.Windows) do win:Show() end
end
function KoiUI:HideAll()
    for _, win in ipairs(self.Windows) do win:Hide() end
end

-- Change theme at runtime
function KoiUI:SetTheme(name)
    assert(self.Themes[name], "[KoiUI] Unknown theme: " .. tostring(name))
    self.Config.Theme = name
end

function KoiUI:SetAccent(color)
    assert(typeof(color) == "Color3", "[KoiUI] SetAccent expects a Color3.")
    self.Config.AccentColor = color
end

-- Expose component constructors so they can be used outside of Window
KoiUI.Switch   = Switch
KoiUI.Button   = Button
KoiUI.Slider   = Slider
KoiUI.TextBox  = TextBox
KoiUI.Dropdown = Dropdown
KoiUI.Tabs     = Tabs
KoiUI.TitleBar = TitleBar
KoiUI.Notif    = Notif

-- Auto-tune for mobile performance
if UserInputService.TouchEnabled then
    KoiUI.Config.TweenDuration = 0.2
end

-- ═════════════════════════════════════════════════════════════
--[[

╔═══════════════════════════════════════════════════════════════╗
║  EXAMPLE LocalScript                                          ║
║  Drop this in StarterPlayerScripts (or any LocalScript).      ║
╚═══════════════════════════════════════════════════════════════╝

------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")

-- 1. Require the library
local KoiUI = require(ReplicatedStorage:WaitForChild("KoiUI"))

-- 2. Optional: customise before building any UI
KoiUI.Config.Theme       = "Dark"
KoiUI.Config.AccentColor = Color3.fromRGB(139, 92, 246)  -- purple
KoiUI.Config.SoundEnabled = true

-- 3. Create a ScreenGui
local gui         = Instance.new("ScreenGui")
gui.Name          = "KoiUI_Demo"
gui.ResetOnSpawn  = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent        = Players.LocalPlayer:WaitForChild("PlayerGui")

-- 4. Create a window
local window = KoiUI:CreateWindow(gui, {
    Title    = "KoiUI Demo",
    Subtitle = "vBeta",
    Width    = 360,
    Height   = 520,
})

-- 5. Add Tabs (creates a 3-tab layout at 380px height)
local tabs = window:AddTabs({
    Height  = 380,
    Default = "Home",
    Tabs    = {
        { Name = "Home" },
        { Name = "Settings" },
        { Name = "Info" },
    },
})
tabs:On("onTabChanged", function(name)
    print("Active tab:", name)
end)

-- Grab references to each tab's ScrollingFrame
local homeFrame     = tabs:GetFrame("Home")
local settingsFrame = tabs:GetFrame("Settings")
local infoFrame     = tabs:GetFrame("Info")

-- 6. ── HOME TAB ─────────────────────────────────────
-- Button
local btn = KoiUI.Button.new(homeFrame, {
    Text = "Click Me!",
    Size = UDim2.new(1, 0, 0, 44),
})
btn:On("onClick", function()
    window:Notify({
        Type  = "success",
        Title = "Button Clicked!",
        Body  = "Tap feedback is working.",
    })
end)
btn:On("onHold", function()
    print("Held down!")
end)
btn:On("onLongPress", function()
    window:Notify({ Type = "warning", Title = "Long Press!", Body = "You held the button." })
end)

-- Switch
local sw = KoiUI.Switch.new(homeFrame, {
    Label   = "Enable VFX",
    Default = true,
    Size    = UDim2.new(1, 0, 0, 52),
})
sw:On("onToggle", function(val)
    print("VFX toggle:", val)
end)

-- Slider
local vol = KoiUI.Slider.new(homeFrame, {
    Label   = "Volume",
    Min     = 0,
    Max     = 100,
    Step    = 1,
    Default = 60,
    Size    = UDim2.new(1, 0, 0, 64),
})
vol:On("onValueChanged", function(v)
    -- adjust audio etc.
end)

-- Separator
KoiUI.Switch.new(homeFrame, {  -- demonstration: second switch
    Label   = "Show Notifications",
    Default = false,
    Size    = UDim2.new(1, 0, 0, 52),
}):On("onToggle", function(v)
    if v then
        window:Notify({
            Type       = "info",
            Title      = "Notifications ON",
            Body       = "You will receive alerts.",
            ActionText = "OK",
            onAction   = function() print("Acknowledged") end,
        })
    end
end)

-- 7. ── SETTINGS TAB ──────────────────────────────────
local tb = KoiUI.TextBox.new(settingsFrame, {
    Label       = "Display Name",
    Placeholder = "Enter your name...",
    Size        = UDim2.new(1, 0, 0, 68),
})
tb:On("onSubmit", function(text)
    window:Notify({ Type = "success", Title = "Saved!", Body = "Name set to: " .. text })
end)

local dd = KoiUI.Dropdown.new(settingsFrame, {
    Label   = "Quality",
    Items   = { "Low", "Medium", "High", "Ultra" },
    Default = "High",
    Size    = UDim2.new(1, 0, 0, 44),
})
dd:On("onSelectionChanged", function(sel)
    print("Quality:", sel)
end)

local multiDd = KoiUI.Dropdown.new(settingsFrame, {
    Label       = "Enabled Modules",
    Items       = { "HUD", "Minimap", "Chat", "Leaderboard" },
    MultiSelect = true,
    Default     = { "HUD", "Chat" },
    Size        = UDim2.new(1, 0, 0, 44),
})
multiDd:On("onSelectionChanged", function(sel)
    print("Modules:", table.concat(sel, ", "))
end)

-- 8. ── INFO TAB ──────────────────────────────────────
-- (Add labels, version info, etc.)
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, 0, 0, 48)
lbl.BackgroundTransparency = 1
lbl.Text = "KoiUI vBeta\nMobile-first UI Library"
lbl.TextColor3 = Color3.fromRGB(148, 148, 175)
lbl.TextSize = 13
lbl.Font = Enum.Font.Gotham
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextWrapped = true
lbl.Parent = infoFrame

-- 9. Welcome notification
window:Notify({
    Type     = "info",
    Title    = "KoiUI vBeta",
    Body     = "UI loaded successfully!",
    Duration = 5,
})

-- 10. Toggle UI with RightShift (keyboard) or custom button
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        KoiUI:ToggleUI()
    end
end)
------------------------------------------------------------------

]]
-- ═════════════════════════════════════════════════════════════

return KoiUI
