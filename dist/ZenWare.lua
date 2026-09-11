
return (function(oldRequire, ...)
local _vararg = {...}
local _modules = {}

local require = function(path)
	if _modules[path] == nil then
		local fallback
		pcall(function() fallback = oldRequire(path) end)
		if typeof(fallback) ~= "nil" then return fallback end
		error('[bundler] module not found: ' .. path)
	end
	local mod = _modules[path]
	if mod.cached then return mod.value end
	mod.value = mod.load()
	mod.cached = true
	return mod.value
end

_modules["Core/Config.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local Config = {}
			
			Config.Name = "ZenWare"
			
			Config.Defaults = {
			    AutoWin = false,
			
			    TeleportLoop = false,
			    TreadmillLoop = false,
			    TeleportInterval = 0.5,
			
			    AutoClicker = false,
			    AutoClickerSpeed = 10,
			
			    AutoMog = false,
			    AutoMogAll = false,
			
			    AutoLoad = true,
			}
			
			function Config.GetDefaults()
			    local result = {}
			
			    for key, value in pairs(Config.Defaults) do
			        result[key] = value
			    end
			
			    return result
			end
			
			return Config
		end)(unpack(_vararg))
	end,
}

_modules["Core/Obsidian.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			--[[
			    ZenWare V3 - Obsidian Style UI
			    Roblox-native implementation for PlayerGui.
			
			    API compatible with the current ZenWare Main.luau:
			        Window:CreateSection()
			        Section:CreateTab()
			        Tab:CreateSection()
			        Tab:CreateButton()
			        Tab:CreateToggle()
			        Tab:CreateSlider()
			        Tab:CreateDropdown()
			        Tab:CreateTextBox()
			        Tab:CreateKeybind()
			        Tab:CreateColorPicker()
			        Tab:CreateParagraph()
			        Tab:CreateConfigSection()
			        Window:Notify()
			        Window:SetToggleKey()
			        Window:SetAutoSave()
			        Window:Destroy()
			]]
			
			local Players = game:GetService("Players")
			local UserInputService = game:GetService("UserInputService")
			local TweenService = game:GetService("TweenService")
			local RunService = game:GetService("RunService")
			
			local Obsidian = {}
			
			local LocalPlayer = Players.LocalPlayer
			local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
			
			local COLORS = {
			    Background = Color3.fromRGB(14, 14, 18),
			    Sidebar = Color3.fromRGB(18, 18, 23),
			    Surface = Color3.fromRGB(22, 22, 28),
			    Surface2 = Color3.fromRGB(28, 28, 35),
			    Surface3 = Color3.fromRGB(34, 34, 42),
			    Border = Color3.fromRGB(48, 48, 58),
			    Text = Color3.fromRGB(238, 238, 244),
			    Muted = Color3.fromRGB(145, 145, 158),
			    Accent = Color3.fromRGB(125, 92, 255),
			    AccentDark = Color3.fromRGB(92, 65, 205),
			    Success = Color3.fromRGB(80, 205, 125),
			}
			
			local FONT = Enum.Font.Gotham
			local FONT_MEDIUM = Enum.Font.GothamMedium
			local FONT_BOLD = Enum.Font.GothamBold
			
			local function new(className, props, parent)
			    local obj = Instance.new(className)
			    for key, value in pairs(props or {}) do
			        obj[key] = value
			    end
			    obj.Parent = parent
			    return obj
			end
			
			local function addCorner(parent, radius)
			    return new("UICorner", {
			        CornerRadius = UDim.new(0, radius or 6)
			    }, parent)
			end
			
			local function addStroke(parent, color, transparency)
			    return new("UIStroke", {
			        Color = color or COLORS.Border,
			        Thickness = 1,
			        Transparency = transparency or 0.2
			    }, parent)
			end
			
			local function addPadding(parent, left, right, top, bottom)
			    return new("UIPadding", {
			        PaddingLeft = UDim.new(0, left or 0),
			        PaddingRight = UDim.new(0, right or 0),
			        PaddingTop = UDim.new(0, top or 0),
			        PaddingBottom = UDim.new(0, bottom or 0),
			    }, parent)
			end
			
			local function tween(instance, info, props)
			    TweenService:Create(instance, info, props):Play()
			end
			
			local function makeLabel(parent, text, size, color, bold)
			    return new("TextLabel", {
			        BackgroundTransparency = 1,
			        Text = text or "",
			        TextColor3 = color or COLORS.Text,
			        TextSize = size or 13,
			        Font = bold and FONT_BOLD or FONT,
			        TextXAlignment = Enum.TextXAlignment.Left,
			        TextYAlignment = Enum.TextYAlignment.Center,
			    }, parent)
			end
			
			local function trim(value)
			    return tostring(value or ""):match("^%s*(.-)%s*$")
			end
			
			local function getMousePosition()
			    return UserInputService:GetMouseLocation()
			end
			
			function Obsidian.new(title, configFolder)
			    local old = PlayerGui:FindFirstChild("ZenWareV3")
			    if old then
			        old:Destroy()
			    end
			
			    local Window = {
			        Title = title or "ZenWare V3",
			        ConfigFolder = configFolder or "ZenWareConfigs",
			        Tabs = {},
			        CurrentTab = nil,
			        ToggleKey = Enum.KeyCode.RightControl,
			        AutoSave = false,
			        Destroyed = false,
			        Theme = "Dark",
			        Transparency = 0,
			    }
			
			    local Gui = new("ScreenGui", {
			        Name = "ZenWareV3",
			        ResetOnSpawn = false,
			        IgnoreGuiInset = true,
			        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			        DisplayOrder = 100,
			    }, PlayerGui)
			
			    Window.Gui = Gui
			
			    local Main = new("Frame", {
			        Name = "Window",
			        Size = UDim2.fromOffset(820, 540),
			        Position = UDim2.new(0.5, -410, 0.5, -270),
			        BackgroundColor3 = COLORS.Background,
			        BorderSizePixel = 0,
			        ClipsDescendants = true,
			    }, Gui)
			    addCorner(Main, 10)
			    addStroke(Main)
			
			    Window.Root = Main
			
			    local TopBar = new("Frame", {
			        Name = "TopBar",
			        Size = UDim2.new(1, 0, 0, 54),
			        BackgroundColor3 = COLORS.Surface,
			        BorderSizePixel = 0,
			    }, Main)
			    addPadding(TopBar, 18, 12, 0, 0)
			
			    local TitleLabel = makeLabel(TopBar, Window.Title, 15, COLORS.Text, true)
			    TitleLabel.Size = UDim2.new(1, -170, 1, 0)
			
			    local VersionLabel = makeLabel(
			        TopBar,
			        "V3",
			        11,
			        COLORS.Muted,
			        false
			    )
			    VersionLabel.AnchorPoint = Vector2.new(1, 0.5)
			    VersionLabel.Position = UDim2.new(1, -52, 0.5, 0)
			    VersionLabel.Size = UDim2.fromOffset(40, 22)
			    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
			
			    local CloseButton = new("TextButton", {
			        Name = "Close",
			        Size = UDim2.fromOffset(30, 30),
			        Position = UDim2.new(1, -38, 0.5, -15),
			        BackgroundColor3 = COLORS.Surface2,
			        Text = "×",
			        TextColor3 = COLORS.Muted,
			        TextSize = 20,
			        Font = FONT,
			        AutoButtonColor = false,
			    }, TopBar)
			    addCorner(CloseButton, 6)
			
			    CloseButton.MouseEnter:Connect(function()
			        tween(CloseButton, TweenInfo.new(0.12), {
			            BackgroundColor3 = Color3.fromRGB(150, 55, 65),
			            TextColor3 = COLORS.Text
			        })
			    end)
			
			    CloseButton.MouseLeave:Connect(function()
			        tween(CloseButton, TweenInfo.new(0.12), {
			            BackgroundColor3 = COLORS.Surface2,
			            TextColor3 = COLORS.Muted
			        })
			    end)
			
			    local Content = new("Frame", {
			        Name = "Content",
			        Position = UDim2.fromOffset(0, 54),
			        Size = UDim2.new(1, 0, 1, -54),
			        BackgroundTransparency = 1,
			    }, Main)
			
			    local Sidebar = new("ScrollingFrame", {
			        Name = "Sidebar",
			        Size = UDim2.new(0, 190, 1, 0),
			        BackgroundColor3 = COLORS.Sidebar,
			        BorderSizePixel = 0,
			        CanvasSize = UDim2.new(),
			        AutomaticCanvasSize = Enum.AutomaticSize.Y,
			        ScrollBarThickness = 2,
			        ScrollBarImageColor3 = COLORS.Border,
			        ScrollingDirection = Enum.ScrollingDirection.Y,
			    }, Content)
			    addPadding(Sidebar, 10, 10, 12, 12)
			
			    local SideLayout = new("UIListLayout", {
			        Padding = UDim.new(0, 5),
			        SortOrder = Enum.SortOrder.LayoutOrder,
			    }, Sidebar)
			
			    local Pages = new("Frame", {
			        Name = "Pages",
			        Position = UDim2.fromOffset(190, 0),
			        Size = UDim2.new(1, -190, 1, 0),
			        BackgroundTransparency = 1,
			    }, Content)
			
			    local DragHandle = TopBar
			    local dragging = false
			    local dragStart
			    local startPosition
			
			    DragHandle.InputBegan:Connect(function(input)
			        if input.UserInputType == Enum.UserInputType.MouseButton1
			            or input.UserInputType == Enum.UserInputType.Touch then
			            dragging = true
			            dragStart = input.Position
			            startPosition = Main.Position
			        end
			    end)
			
			    DragHandle.InputEnded:Connect(function(input)
			        if input.UserInputType == Enum.UserInputType.MouseButton1
			            or input.UserInputType == Enum.UserInputType.Touch then
			            dragging = false
			        end
			    end)
			
			    UserInputService.InputChanged:Connect(function(input)
			        if not dragging then
			            return
			        end
			
			        if input.UserInputType ~= Enum.UserInputType.MouseMovement
			            and input.UserInputType ~= Enum.UserInputType.Touch then
			            return
			        end
			
			        local delta = input.Position - dragStart
			        Main.Position = UDim2.new(
			            startPosition.X.Scale,
			            startPosition.X.Offset + delta.X,
			            startPosition.Y.Scale,
			            startPosition.Y.Offset + delta.Y
			        )
			    end)
			
			    local resizeHandle = new("TextButton", {
			        Name = "Resize",
			        AnchorPoint = Vector2.new(1, 1),
			        Position = UDim2.new(1, 0, 1, 0),
			        Size = UDim2.fromOffset(18, 18),
			        BackgroundTransparency = 1,
			        Text = "⋰",
			        TextColor3 = COLORS.Muted,
			        TextSize = 16,
			        Font = FONT,
			        AutoButtonColor = false,
			    }, Main)
			
			    local resizing = false
			    local resizeStart
			    local sizeStart
			
			    resizeHandle.InputBegan:Connect(function(input)
			        if input.UserInputType == Enum.UserInputType.MouseButton1
			            or input.UserInputType == Enum.UserInputType.Touch then
			            resizing = true
			            resizeStart = input.Position
			            sizeStart = Main.AbsoluteSize
			        end
			    end)
			
			    resizeHandle.InputEnded:Connect(function(input)
			        if input.UserInputType == Enum.UserInputType.MouseButton1
			            or input.UserInputType == Enum.UserInputType.Touch then
			            resizing = false
			        end
			    end)
			
			    UserInputService.InputChanged:Connect(function(input)
			        if not resizing then
			            return
			        end
			
			        if input.UserInputType ~= Enum.UserInputType.MouseMovement
			            and input.UserInputType ~= Enum.UserInputType.Touch then
			            return
			        end
			
			        local delta = input.Position - resizeStart
			        local width = math.max(620, sizeStart.X + delta.X)
			        local height = math.max(420, sizeStart.Y + delta.Y)
			        Main.Size = UDim2.fromOffset(width, height)
			    end)
			
			    local ToastHolder = new("Frame", {
			        Name = "Notifications",
			        AnchorPoint = Vector2.new(1, 0),
			        Position = UDim2.new(1, -15, 0, 70),
			        Size = UDim2.fromOffset(300, 400),
			        BackgroundTransparency = 1,
			    }, Gui)
			
			    local ToastLayout = new("UIListLayout", {
			        Padding = UDim.new(0, 8),
			        HorizontalAlignment = Enum.HorizontalAlignment.Right,
			        VerticalAlignment = Enum.VerticalAlignment.Top,
			    }, ToastHolder)
			
			    local function notify(data)
			        data = data or {}
			
			        local toast = new("Frame", {
			            Size = UDim2.fromOffset(285, 70),
			            BackgroundColor3 = COLORS.Surface,
			            BorderSizePixel = 0,
			        }, ToastHolder)
			        addCorner(toast, 8)
			        addStroke(toast)
			
			        local bar = new("Frame", {
			            Size = UDim2.fromOffset(3, 70),
			            BackgroundColor3 = COLORS.Accent,
			            BorderSizePixel = 0,
			        }, toast)
			        addCorner(bar, 3)
			
			        local toastTitle = makeLabel(
			            toast,
			            data.Title or "ZenWare",
			            13,
			            COLORS.Text,
			            true
			        )
			        toastTitle.Position = UDim2.fromOffset(14, 7)
			        toastTitle.Size = UDim2.new(1, -24, 0, 22)
			
			        local toastDescription = makeLabel(
			            toast,
			            data.Description or "",
			            11,
			            COLORS.Muted,
			            false
			        )
			        toastDescription.Position = UDim2.fromOffset(14, 30)
			        toastDescription.Size = UDim2.new(1, -24, 0, 32)
			        toastDescription.TextWrapped = true
			
			        toast.Position = UDim2.new(1, 20, 0, 0)
			        tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			            Position = UDim2.new(0, 0, 0, 0)
			        })
			
			        task.delay(tonumber(data.Duration) or 3, function()
			            if not toast.Parent then
			                return
			            end
			
			            tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			                Position = UDim2.new(1, 20, 0, 0),
			                BackgroundTransparency = 1
			            })
			
			            task.wait(0.25)
			            if toast.Parent then
			                toast:Destroy()
			            end
			        end)
			    end
			
			    function Window:Notify(data)
			        notify(data)
			    end
			
			    local function selectTab(tab)
			        for _, other in ipairs(Window.Tabs) do
			            other.Page.Visible = false
			            other.Button.BackgroundTransparency = 1
			            other.Button.TextColor3 = COLORS.Muted
			        end
			
			        tab.Page.Visible = true
			        tab.Button.BackgroundColor3 = COLORS.Accent
			        tab.Button.BackgroundTransparency = 0.15
			        tab.Button.TextColor3 = COLORS.Text
			        Window.CurrentTab = tab
			    end
			
			    local function createElementContainer(parent, height)
			        local holder = new("Frame", {
			            Size = UDim2.new(1, 0, 0, height or 40),
			            BackgroundTransparency = 1,
			        }, parent)
			        return holder
			    end
			
			    function Window:CreateSection(name)
			        local Section = {
			            Name = name or "Section",
			            Tabs = {}
			        }
			
			        function Section:CreateTab(tabName, icon)
			            local Tab = {
			                Name = tabName or "Tab",
			                Section = Section,
			                Elements = {}
			            }
			
			            local tabButton = new("TextButton", {
			                Size = UDim2.new(1, 0, 0, 38),
			                BackgroundColor3 = COLORS.Accent,
			                BackgroundTransparency = 1,
			                Text = (icon and "  " or "") .. (tabName or "Tab"),
			                TextColor3 = COLORS.Muted,
			                TextSize = 12,
			                Font = FONT_MEDIUM,
			                TextXAlignment = Enum.TextXAlignment.Left,
			                AutoButtonColor = false,
			            }, Sidebar)
			            addCorner(tabButton, 6)
			
			            local page = new("ScrollingFrame", {
			                Name = tostring(tabName),
			                Size = UDim2.new(1, 0, 1, 0),
			                BackgroundTransparency = 1,
			                BorderSizePixel = 0,
			                CanvasSize = UDim2.new(),
			                AutomaticCanvasSize = Enum.AutomaticSize.Y,
			                ScrollBarThickness = 3,
			                ScrollBarImageColor3 = COLORS.Border,
			                Visible = false,
			            }, Pages)
			            addPadding(page, 18, 18, 18, 18)
			
			            local pageLayout = new("UIListLayout", {
			                Padding = UDim.new(0, 12),
			                SortOrder = Enum.SortOrder.LayoutOrder,
			            }, page)
			
			            tabButton.MouseEnter:Connect(function()
			                if Window.CurrentTab ~= Tab then
			                    tween(tabButton, TweenInfo.new(0.12), {
			                        BackgroundTransparency = 0.8,
			                        BackgroundColor3 = COLORS.Surface2
			                    })
			                end
			            end)
			
			            tabButton.MouseLeave:Connect(function()
			                if Window.CurrentTab ~= Tab then
			                    tween(tabButton, TweenInfo.new(0.12), {
			                        BackgroundTransparency = 1
			                    })
			                end
			            end)
			
			            tabButton.MouseButton1Click:Connect(function()
			                selectTab(Tab)
			            end)
			
			            Tab.Button = tabButton
			            Tab.Page = page
			
			            function Tab:CreateSection(sectionName)
			                local box = new("Frame", {
			                    Name = sectionName or "Section",
			                    Size = UDim2.new(1, 0, 0, 0),
			                    AutomaticSize = Enum.AutomaticSize.Y,
			                    BackgroundColor3 = COLORS.Surface,
			                    BorderSizePixel = 0,
			                }, page)
			                addCorner(box, 8)
			                addStroke(box)
			
			                addPadding(box, 12, 12, 12, 12)
			
			                local layout = new("UIListLayout", {
			                    Padding = UDim.new(0, 8),
			                    SortOrder = Enum.SortOrder.LayoutOrder,
			                }, box)
			
			                local heading = makeLabel(
			                    box,
			                    sectionName or "Section",
			                    12,
			                    COLORS.Text,
			                    true
			                )
			                heading.Size = UDim2.new(1, 0, 0, 22)
			
			                local Group = {
			                    Root = box,
			                    Layout = layout
			                }
			
			                local function addRow(height)
			                    return createElementContainer(box, height)
			                end
			
			                function Tab:CreateButton(config)
			                    config = config or {}
			
			                    local row = addRow(36)
			                    local button = new("TextButton", {
			                        Size = UDim2.new(1, 0, 1, 0),
			                        BackgroundColor3 = COLORS.Surface2,
			                        Text = config.Name or "Button",
			                        TextColor3 = COLORS.Text,
			                        TextSize = 12,
			                        Font = FONT_MEDIUM,
			                        AutoButtonColor = false,
			                    }, row)
			                    addCorner(button, 6)
			
			                    button.MouseEnter:Connect(function()
			                        tween(button, TweenInfo.new(0.12), {
			                            BackgroundColor3 = COLORS.AccentDark
			                        })
			                    end)
			
			                    button.MouseLeave:Connect(function()
			                        tween(button, TweenInfo.new(0.12), {
			                            BackgroundColor3 = COLORS.Surface2
			                        })
			                    end)
			
			                    button.MouseButton1Click:Connect(function()
			                        if config.Callback then
			                            task.spawn(config.Callback)
			                        end
			                    end)
			
			                    local api = {}
			
			                    function api:SetText(text)
			                        button.Text = tostring(text)
			                    end
			
			                    return api
			                end
			
			                function Tab:CreateToggle(config)
			                    config = config or {}
			
			                    local state = config.Default == true
			                    local row = addRow(42)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Toggle",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Size = UDim2.new(1, -60, 1, 0)
			
			                    local switch = new("TextButton", {
			                        AnchorPoint = Vector2.new(1, 0.5),
			                        Position = UDim2.new(1, 0, 0.5, 0),
			                        Size = UDim2.fromOffset(42, 22),
			                        BackgroundColor3 = state and COLORS.Accent or COLORS.Surface3,
			                        Text = "",
			                        AutoButtonColor = false,
			                    }, row)
			                    addCorner(switch, 11)
			                    addStroke(switch, COLORS.Border, 0.35)
			
			                    local knob = new("Frame", {
			                        AnchorPoint = Vector2.new(0, 0.5),
			                        Position = state
			                            and UDim2.new(1, -20, 0.5, 0)
			                            or UDim2.new(0, 4, 0.5, 0),
			                        Size = UDim2.fromOffset(14, 14),
			                        BackgroundColor3 = COLORS.Text,
			                        BorderSizePixel = 0,
			                    }, switch)
			                    addCorner(knob, 7)
			
			                    local function setValue(value, callCallback)
			                        state = value == true
			
			                        tween(switch, TweenInfo.new(0.15), {
			                            BackgroundColor3 = state
			                                and COLORS.Accent
			                                or COLORS.Surface3
			                        })
			
			                        tween(knob, TweenInfo.new(0.15), {
			                            Position = state
			                                and UDim2.new(1, -18, 0.5, 0)
			                                or UDim2.new(0, 4, 0.5, 0)
			                        })
			
			                        if callCallback and config.Callback then
			                            task.spawn(config.Callback, state)
			                        end
			                    end
			
			                    switch.MouseButton1Click:Connect(function()
			                        setValue(not state, true)
			                    end)
			
			                    local api = {}
			
			                    function api:SetValue(value)
			                        setValue(value, true)
			                    end
			
			                    function api:GetValue()
			                        return state
			                    end
			
			                    return api
			                end
			
			                function Tab:CreateSlider(config)
			                    config = config or {}
			
			                    local min = tonumber(config.Min) or 0
			                    local max = tonumber(config.Max) or 100
			                    local value = math.clamp(
			                        tonumber(config.Default) or min,
			                        min,
			                        max
			                    )
			
			                    local row = addRow(58)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Slider",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Position = UDim2.fromOffset(0, 0)
			                    label.Size = UDim2.new(1, -65, 0, 22)
			
			                    local valueLabel = makeLabel(
			                        row,
			                        tostring(value),
			                        11,
			                        COLORS.Muted,
			                        false
			                    )
			                    valueLabel.AnchorPoint = Vector2.new(1, 0)
			                    valueLabel.Position = UDim2.new(1, 0, 0, 0)
			                    valueLabel.Size = UDim2.fromOffset(60, 22)
			                    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			
			                    local track = new("Frame", {
			                        Position = UDim2.fromOffset(0, 31),
			                        Size = UDim2.new(1, 0, 0, 7),
			                        BackgroundColor3 = COLORS.Surface3,
			                        BorderSizePixel = 0,
			                    }, row)
			                    addCorner(track, 4)
			
			                    local fill = new("Frame", {
			                        Size = UDim2.new((value - min) / math.max(max - min, 0.0001), 0, 1, 0),
			                        BackgroundColor3 = COLORS.Accent,
			                        BorderSizePixel = 0,
			                    }, track)
			                    addCorner(fill, 4)
			
			                    local knob = new("Frame", {
			                        AnchorPoint = Vector2.new(0.5, 0.5),
			                        Position = UDim2.new((value - min) / math.max(max - min, 0.0001), 0, 0.5, 0),
			                        Size = UDim2.fromOffset(13, 13),
			                        BackgroundColor3 = COLORS.Text,
			                        BorderSizePixel = 0,
			                    }, track)
			                    addCorner(knob, 7)
			
			                    local draggingSlider = false
			
			                    local function setValue(newValue, callCallback)
			                        newValue = math.clamp(
			                            tonumber(newValue) or min,
			                            min,
			                            max
			                        )
			
			                        value = newValue
			                        local alpha = (value - min) / math.max(max - min, 0.0001)
			
			                        fill.Size = UDim2.new(alpha, 0, 1, 0)
			                        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
			                        valueLabel.Text = tostring(value)
			
			                        if callCallback and config.Callback then
			                            task.spawn(config.Callback, value)
			                        end
			                    end
			
			                    local function updateFromInput(input)
			                        local x = input.Position.X
			                        local left = track.AbsolutePosition.X
			                        local width = track.AbsoluteSize.X
			                        local alpha = math.clamp((x - left) / math.max(width, 1), 0, 1)
			                        setValue(min + (max - min) * alpha, true)
			                    end
			
			                    track.InputBegan:Connect(function(input)
			                        if input.UserInputType == Enum.UserInputType.MouseButton1
			                            or input.UserInputType == Enum.UserInputType.Touch then
			                            draggingSlider = true
			                            updateFromInput(input)
			                        end
			                    end)
			
			                    UserInputService.InputChanged:Connect(function(input)
			                        if draggingSlider and (
			                            input.UserInputType == Enum.UserInputType.MouseMovement
			                            or input.UserInputType == Enum.UserInputType.Touch
			                        ) then
			                            updateFromInput(input)
			                        end
			                    end)
			
			                    UserInputService.InputEnded:Connect(function(input)
			                        if input.UserInputType == Enum.UserInputType.MouseButton1
			                            or input.UserInputType == Enum.UserInputType.Touch then
			                            draggingSlider = false
			                        end
			                    end)
			
			                    local api = {}
			
			                    function api:SetValue(newValue)
			                        setValue(newValue, true)
			                    end
			
			                    function api:GetValue()
			                        return value
			                    end
			
			                    return api
			                end
			
			                function Tab:CreateDropdown(config)
			                    config = config or {}
			
			                    local options = config.Options or {}
			                    local selected = config.Default
			                    local multi = config.MultiSelect == true
			
			                    if multi then
			                        if typeof(selected) ~= "table" then
			                            selected = {}
			                        else
			                            local copy = {}
			                            for key, val in pairs(selected) do
			                                copy[key] = val
			                            end
			                            selected = copy
			                        end
			                    end
			
			                    local row = addRow(42)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Dropdown",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Size = UDim2.new(0.42, 0, 1, 0)
			
			                    local button = new("TextButton", {
			                        AnchorPoint = Vector2.new(1, 0.5),
			                        Position = UDim2.new(1, 0, 0.5, 0),
			                        Size = UDim2.new(0.54, 0, 0, 32),
			                        BackgroundColor3 = COLORS.Surface2,
			                        TextColor3 = COLORS.Muted,
			                        TextSize = 11,
			                        Font = FONT,
			                        Text = "Select...",
			                        AutoButtonColor = false,
			                    }, row)
			                    addCorner(button, 6)
			                    addStroke(button, COLORS.Border, 0.35)
			
			                    local menu = new("Frame", {
			                        Visible = false,
			                        Position = UDim2.new(0, 0, 1, 4),
			                        Size = UDim2.new(1, 0, 0, math.min(#options * 30 + 8, 180)),
			                        BackgroundColor3 = COLORS.Surface,
			                        BorderSizePixel = 0,
			                        ZIndex = 50,
			                    }, button)
			                    addCorner(menu, 6)
			                    addStroke(menu)
			
			                    local menuScroll = new("ScrollingFrame", {
			                        Size = UDim2.new(1, 0, 1, 0),
			                        BackgroundTransparency = 1,
			                        BorderSizePixel = 0,
			                        CanvasSize = UDim2.new(),
			                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
			                        ScrollBarThickness = 2,
			                        ZIndex = 51,
			                    }, menu)
			                    addPadding(menuScroll, 5, 5, 5, 5)
			
			                    local menuLayout = new("UIListLayout", {
			                        Padding = UDim.new(0, 3)
			                    }, menuScroll)
			
			                    local api = {}
			
			                    local function displayValue()
			                        if multi then
			                            local names = {}
			                            for key, enabled in pairs(selected) do
			                                if enabled then
			                                    table.insert(names, tostring(key))
			                                end
			                            end
			                            table.sort(names)
			                            button.Text = #names > 0
			                                and table.concat(names, ", ")
			                                or "Select..."
			                        else
			                            button.Text = selected ~= nil
			                                and tostring(selected)
			                                or "Select..."
			                        end
			                    end
			
			                    local function callback()
			                        if config.Callback then
			                            task.spawn(config.Callback, selected)
			                        end
			                    end
			
			                    local function rebuild()
			                        for _, child in ipairs(menuScroll:GetChildren()) do
			                            if child:IsA("TextButton") then
			                                child:Destroy()
			                            end
			                        end
			
			                        for _, option in ipairs(options) do
			                            local optionText = tostring(option)
			                            local optionButton = new("TextButton", {
			                                Size = UDim2.new(1, 0, 0, 27),
			                                BackgroundColor3 = COLORS.Surface2,
			                                Text = optionText,
			                                TextColor3 = COLORS.Text,
			                                TextSize = 11,
			                                Font = FONT,
			                                AutoButtonColor = false,
			                                ZIndex = 52,
			                            }, menuScroll)
			                            addCorner(optionButton, 5)
			
			                            optionButton.MouseButton1Click:Connect(function()
			                                if multi then
			                                    selected[option] = not selected[option]
			                                else
			                                    selected = option
			                                    menu.Visible = false
			                                end
			
			                                displayValue()
			                                callback()
			                            end)
			                        end
			                    end
			
			                    button.MouseButton1Click:Connect(function()
			                        menu.Visible = not menu.Visible
			                    end)
			
			                    function api:SetValue(newValue)
			                        selected = newValue
			                        displayValue()
			                        callback()
			                    end
			
			                    function api:GetValue()
			                        return selected
			                    end
			
			                    function api:Refresh(newOptions)
			                        options = newOptions or {}
			                        menu.Size = UDim2.new(
			                            1,
			                            0,
			                            0,
			                            math.min(#options * 30 + 8, 180)
			                        )
			                        rebuild()
			                    end
			
			                    rebuild()
			                    displayValue()
			
			                    return api
			                end
			
			                function Tab:CreateTextBox(config)
			                    config = config or {}
			
			                    local row = addRow(58)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Input",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Position = UDim2.fromOffset(0, 0)
			                    label.Size = UDim2.new(1, 0, 0, 20)
			
			                    local box = new("TextBox", {
			                        Position = UDim2.fromOffset(0, 25),
			                        Size = UDim2.new(1, 0, 0, 30),
			                        BackgroundColor3 = COLORS.Surface2,
			                        TextColor3 = COLORS.Text,
			                        PlaceholderColor3 = COLORS.Muted,
			                        PlaceholderText = config.Placeholder or "",
			                        Text = config.Default or "",
			                        TextSize = 11,
			                        Font = FONT,
			                        ClearTextOnFocus = false,
			                        TextXAlignment = Enum.TextXAlignment.Left,
			                    }, row)
			                    addCorner(box, 6)
			                    addStroke(box, COLORS.Border, 0.35)
			                    addPadding(box, 9, 9, 0, 0)
			
			                    local api = {}
			
			                    function api:GetText()
			                        return box.Text
			                    end
			
			                    function api:SetText(text)
			                        box.Text = tostring(text or "")
			                    end
			
			                    function api:SetPlaceholder(text)
			                        box.PlaceholderText = tostring(text or "")
			                    end
			
			                    function api:Focus()
			                        box:CaptureFocus()
			                    end
			
			                    box.FocusLost:Connect(function(enterPressed)
			                        if config.Callback then
			                            task.spawn(config.Callback, box.Text, enterPressed)
			                        end
			                    end)
			
			                    return api
			                end
			
			                function Tab:CreateKeybind(config)
			                    config = config or {}
			
			                    local key = config.Default or Enum.KeyCode.F
			                    local waiting = false
			                    local row = addRow(42)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Keybind",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Size = UDim2.new(1, -90, 1, 0)
			
			                    local keyButton = new("TextButton", {
			                        AnchorPoint = Vector2.new(1, 0.5),
			                        Position = UDim2.new(1, 0, 0.5, 0),
			                        Size = UDim2.fromOffset(80, 30),
			                        BackgroundColor3 = COLORS.Surface2,
			                        Text = key.Name,
			                        TextColor3 = COLORS.Text,
			                        TextSize = 11,
			                        Font = FONT_MEDIUM,
			                        AutoButtonColor = false,
			                    }, row)
			                    addCorner(keyButton, 6)
			                    addStroke(keyButton, COLORS.Border, 0.35)
			
			                    keyButton.MouseButton1Click:Connect(function()
			                        waiting = true
			                        keyButton.Text = "Press key..."
			                    end)
			
			                    local connection
			                    connection = UserInputService.InputBegan:Connect(function(input, processed)
			                        if Window.Destroyed then
			                            connection:Disconnect()
			                            return
			                        end
			
			                        if waiting then
			                            if input.UserInputType == Enum.UserInputType.Keyboard then
			                                key = input.KeyCode
			                                waiting = false
			                                keyButton.Text = key.Name
			
			                                if config.Callback then
			                                    task.spawn(config.Callback, key)
			                                end
			                            end
			                            return
			                        end
			
			                        if input.UserInputType == Enum.UserInputType.Keyboard
			                            and input.KeyCode == key
			                            and not processed then
			                            if config.Callback then
			                                task.spawn(config.Callback, key)
			                            end
			                        end
			                    end)
			
			                    local api = {}
			
			                    function api:SetKey(newKey)
			                        if typeof(newKey) == "EnumItem" then
			                            key = newKey
			                            keyButton.Text = key.Name
			                        end
			                    end
			
			                    function api:GetKey()
			                        return key
			                    end
			
			                    return api
			                end
			
			                function Tab:CreateColorPicker(config)
			                    config = config or {}
			
			                    local color = config.Default or COLORS.Accent
			                    local row = addRow(42)
			
			                    local label = makeLabel(
			                        row,
			                        config.Name or "Color",
			                        12,
			                        COLORS.Text,
			                        false
			                    )
			                    label.Size = UDim2.new(1, -55, 1, 0)
			
			                    local swatch = new("TextButton", {
			                        AnchorPoint = Vector2.new(1, 0.5),
			                        Position = UDim2.new(1, 0, 0.5, 0),
			                        Size = UDim2.fromOffset(42, 27),
			                        BackgroundColor3 = color,
			                        Text = "",
			                        AutoButtonColor = false,
			                    }, row)
			                    addCorner(swatch, 6)
			                    addStroke(swatch)
			
			                    local api = {}
			
			                    function api:SetColor(newColor)
			                        if typeof(newColor) == "Color3" then
			                            color = newColor
			                            swatch.BackgroundColor3 = color
			
			                            if config.Callback then
			                                task.spawn(config.Callback, color)
			                            end
			                        end
			                    end
			
			                    function api:GetColor()
			                        return color
			                    end
			
			                    -- A compact RGB input popup rather than relying on
			                    -- non-native color-picker APIs.
			                    local popup = new("Frame", {
			                        Visible = false,
			                        AnchorPoint = Vector2.new(1, 0),
			                        Position = UDim2.new(1, 0, 1, 4),
			                        Size = UDim2.fromOffset(230, 145),
			                        BackgroundColor3 = COLORS.Surface,
			                        BorderSizePixel = 0,
			                        ZIndex = 60,
			                    }, swatch)
			                    addCorner(popup, 7)
			                    addStroke(popup)
			
			                    local popupTitle = makeLabel(
			                        popup,
			                        "RGB Color",
			                        11,
			                        COLORS.Text,
			                        true
			                    )
			                    popupTitle.Position = UDim2.fromOffset(10, 7)
			                    popupTitle.Size = UDim2.new(1, -20, 0, 20)
			
			                    local inputs = {}
			                    local channels = {"R", "G", "B"}
			
			                    for i, channel in ipairs(channels) do
			                        local input = new("TextBox", {
			                            Position = UDim2.fromOffset(10 + (i - 1) * 70, 35),
			                            Size = UDim2.fromOffset(60, 28),
			                            BackgroundColor3 = COLORS.Surface2,
			                            TextColor3 = COLORS.Text,
			                            PlaceholderText = channel,
			                            Text = tostring(math.floor(color[channel] * 255 + 0.5)),
			                            TextSize = 11,
			                            Font = FONT,
			                            ClearTextOnFocus = false,
			                            ZIndex = 61,
			                        }, popup)
			                        addCorner(input, 5)
			                        inputs[channel] = input
			                    end
			
			                    local apply = new("TextButton", {
			                        Position = UDim2.fromOffset(10, 75),
			                        Size = UDim2.new(1, -20, 0, 32),
			                        BackgroundColor3 = COLORS.Accent,
			                        Text = "Apply",
			                        TextColor3 = COLORS.Text,
			                        TextSize = 11,
			                        Font = FONT_MEDIUM,
			                        AutoButtonColor = false,
			                        ZIndex = 61,
			                    }, popup)
			                    addCorner(apply, 6)
			
			                    apply.MouseButton1Click:Connect(function()
			                        local r = math.clamp(tonumber(inputs.R.Text) or 255, 0, 255)
			                        local g = math.clamp(tonumber(inputs.G.Text) or 255, 0, 255)
			                        local b = math.clamp(tonumber(inputs.B.Text) or 255, 0, 255)
			
			                        api:SetColor(Color3.fromRGB(r, g, b))
			                        popup.Visible = false
			                    end)
			
			                    swatch.MouseButton1Click:Connect(function()
			                        popup.Visible = not popup.Visible
			                    end)
			
			                    return api
			                end
			
			                function Tab:CreateParagraph(config)
			                    config = config or {}
			
			                    local row = new("Frame", {
			                        AutomaticSize = Enum.AutomaticSize.Y,
			                        Size = UDim2.new(1, 0, 0, 0),
			                        BackgroundColor3 = COLORS.Surface2,
			                        BorderSizePixel = 0,
			                    }, box)
			                    addCorner(row, 6)
			                    addPadding(row, 10, 10, 8, 8)
			
			                    local paragraphTitle = makeLabel(
			                        row,
			                        config.Title or "Information",
			                        12,
			                        COLORS.Text,
			                        true
			                    )
			                    paragraphTitle.Size = UDim2.new(1, 0, 0, 20)
			
			                    local paragraphContent = makeLabel(
			                        row,
			                        config.Content or "",
			                        11,
			                        COLORS.Muted,
			                        false
			                    )
			                    paragraphContent.Position = UDim2.fromOffset(0, 22)
			                    paragraphContent.Size = UDim2.new(1, 0, 0, 0)
			                    paragraphContent.AutomaticSize = Enum.AutomaticSize.Y
			                    paragraphContent.TextWrapped = true
			
			                    local api = {}
			
			                    function api:SetTitle(text)
			                        paragraphTitle.Text = tostring(text or "")
			                    end
			
			                    function api:SetContent(text)
			                        paragraphContent.Text = tostring(text or "")
			                    end
			
			                    return api
			                end
			
			                function Tab:CreateConfigSection()
			                    local row = addRow(42)
			
			                    local label = makeLabel(
			                        row,
			                        "Configs",
			                        12,
			                        COLORS.Text,
			                        true
			                    )
			                    label.Size = UDim2.new(1, -110, 1, 0)
			
			                    local status = makeLabel(
			                        row,
			                        "Ready",
			                        11,
			                        COLORS.Muted,
			                        false
			                    )
			                    status.AnchorPoint = Vector2.new(1, 0.5)
			                    status.Position = UDim2.new(1, 0, 0.5, 0)
			                    status.Size = UDim2.fromOffset(100, 25)
			                    status.TextXAlignment = Enum.TextXAlignment.Right
			
			                    -- Config persistence is intentionally kept as a UI hook.
			                    -- The existing Core/Config module remains the owner of
			                    -- actual persistence.
			                    local api = {}
			
			                    function api:SetStatus(text)
			                        status.Text = tostring(text or "")
			                    end
			
			                    return api
			                end
			
			                return Group
			            end
			
			            table.insert(Window.Tabs, Tab)
			            table.insert(Section.Tabs, Tab)
			
			            if not Window.CurrentTab then
			                selectTab(Tab)
			            end
			
			            return Tab
			        end
			
			        return Section
			    end
			
			    function Window:SetToggleKey(key)
			        if typeof(key) ~= "EnumItem" then
			            return
			        end
			
			        Window.ToggleKey = key
			
			        if Window.ToggleConnection then
			            Window.ToggleConnection:Disconnect()
			        end
			
			        Window.ToggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
			            if processed then
			                return
			            end
			
			            if input.UserInputType == Enum.UserInputType.Keyboard
			                and input.KeyCode == Window.ToggleKey then
			                Main.Visible = not Main.Visible
			            end
			        end)
			    end
			
			    function Window:Toggle()
			        Main.Visible = not Main.Visible
			    end
			
			    function Window:SetAutoSave(enabled)
			        Window.AutoSave = enabled == true
			    end
			
			    function Window:SetTransparency(value)
			        Window.Transparency = math.clamp(tonumber(value) or 0, 0, 1)
			        Main.BackgroundTransparency = Window.Transparency
			    end
			
			    function Window:SetAccent(color)
			        if typeof(color) ~= "Color3" then
			            return
			        end
			
			        COLORS.Accent = color
			        COLORS.AccentDark = color:Lerp(Color3.new(0, 0, 0), 0.25)
			    end
			
			    function Window:Destroy()
			        if Window.Destroyed then
			            return
			        end
			
			        Window.Destroyed = true
			
			        if Window.ToggleConnection then
			            Window.ToggleConnection:Disconnect()
			            Window.ToggleConnection = nil
			        end
			
			        Gui:Destroy()
			    end
			
			    CloseButton.MouseButton1Click:Connect(function()
			        Window:Destroy()
			    end)
			
			    Window:SetToggleKey(Window.ToggleKey)
			
			    return Window
			end
			
			function Obsidian.CreateWindow(config)
			    config = config or {}
			    return Obsidian.new(
			        config.Title or "ZenWare V3",
			        config.ConfigFolder or "ZenWareConfigs"
			    )
			end
			
			return Obsidian

		end)(unpack(_vararg))
	end,
}

_modules["Core/Remotes.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			
			local Remotes = {}
			
			local function getFolder()
			    return ReplicatedStorage:FindFirstChild("ZenWareRemotes")
			end
			
			function Remotes.Get(name)
			    local folder = getFolder()
			
			    if not folder then
			        return nil
			    end
			
			    local remote = folder:FindFirstChild(name)
			
			    if remote and remote:IsA("RemoteEvent") then
			        return remote
			    end
			
			    return nil
			end
			
			function Remotes.Fire(name, ...)
			    local remote = Remotes.Get(name)
			
			    if not remote then
			        return false, "Remote not found: " .. tostring(name)
			    end
			
			    return pcall(function()
			        remote:FireServer(...)
			    end)
			end
			
			return Remotes
		end)(unpack(_vararg))
	end,
}

_modules["Core/State.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local State = {
			    AutoWin = false,
			
			    TeleportLoop = false,
			    TreadmillLoop = false,
			    TeleportInterval = 0.5,
			
			    AutoClicker = false,
			    AutoClickerSpeed = 10,
			
			    AutoMog = false,
			    AutoMogAll = false,
			
			    AutoLoad = true,
			
			    CurrentTarget = nil,
			
			    SavedLocations = {},
			}
			
			return State
		end)(unpack(_vararg))
	end,
}

_modules["Core/Utils.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local Players = game:GetService("Players")
			
			local Utils = {}
			
			function Utils.SafeCall(callback, ...)
			    if typeof(callback) ~= "function" then
			        return false, "Invalid callback"
			    end
			
			    return pcall(callback, ...)
			end
			
			function Utils.GetPlayer()
			    return Players.LocalPlayer
			end
			
			function Utils.GetCharacter()
			    local player = Players.LocalPlayer
			
			    return player and player.Character
			end
			
			function Utils.GetRoot()
			    local character = Utils.GetCharacter()
			
			    if not character then
			        return nil
			    end
			
			    return character:FindFirstChild("HumanoidRootPart")
			end
			
			function Utils.GetPlayers()
			    local result = {}
			
			    for _, player in ipairs(Players:GetPlayers()) do
			        table.insert(result, player.Name)
			    end
			
			    table.sort(result)
			
			    return result
			end
			
			function Utils.ToNumber(value, fallback)
			    local number = tonumber(value)
			
			    if number == nil then
			        return fallback
			    end
			
			    return number
			end
			
			function Utils.Trim(text)
			    return tostring(text):match("^%s*(.-)%s*$")
			end
			
			return Utils
		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoClicker.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local AutoClicker = {}
			
			local running = false
			local runToken = 0
			local clickCallback
			
			function AutoClicker.SetCallback(callback)
			    clickCallback = typeof(callback) == "function"
			        and callback
			        or nil
			end
			
			function AutoClicker.Stop()
			    running = false
			    runToken += 1
			end
			
			function AutoClicker.Start(cps)
			    AutoClicker.Stop()
			
			    running = true
			    runToken += 1
			
			    local token = runToken
			
			    cps = math.clamp(
			        tonumber(cps) or 10,
			        1,
			        100
			    )
			
			    local interval = 1 / cps
			
			    task.spawn(function()
			        while running and token == runToken do
			            if clickCallback then
			                pcall(clickCallback)
			            end
			
			            task.wait(interval)
			        end
			    end)
			end
			
			function AutoClicker.Toggle(cps)
			    if running then
			        AutoClicker.Stop()
			    else
			        AutoClicker.Start(cps)
			    end
			end
			
			function AutoClicker.IsRunning()
			    return running
			end
			
			return AutoClicker
		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoLoad.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local TeleportService = game:GetService("TeleportService")
			
			local AutoLoad = {}
			
			local KEY = "ZenWare_AutoLoad"
			
			function AutoLoad.Set(enabled)
			    pcall(function()
			        TeleportService:SetTeleportSetting(
			            KEY,
			            enabled == true
			        )
			    end)
			end
			
			function AutoLoad.Get(defaultValue)
			    local value
			
			    pcall(function()
			        value = TeleportService:GetTeleportSetting(KEY)
			    end)
			
			    if value == nil then
			        return defaultValue == true
			    end
			
			    return value == true
			end
			
			return AutoLoad
		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoMog.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local Players = game:GetService("Players")
			
			local AutoMog = {}
			
			local running = false
			local runToken = 0
			
			local startCallback
			local stopCallback
			
			function AutoMog.SetCallbacks(startFn, stopFn)
			    startCallback = typeof(startFn) == "function"
			        and startFn
			        or nil
			
			    stopCallback = typeof(stopFn) == "function"
			        and stopFn
			        or nil
			end
			
			function AutoMog.Stop()
			    running = false
			    runToken += 1
			
			    if stopCallback then
			        pcall(stopCallback)
			    end
			end
			
			function AutoMog.Start(username)
			    AutoMog.Stop()
			
			    local target = Players:FindFirstChild(username)
			
			    if not target then
			        return false, "Player not found"
			    end
			
			    running = true
			    runToken += 1
			
			    local token = runToken
			
			    task.spawn(function()
			        if not running or token ~= runToken then
			            return
			        end
			
			        if startCallback then
			            pcall(startCallback, target)
			        end
			    end)
			
			    return true
			end
			
			function AutoMog.StartAll()
			    AutoMog.Stop()
			
			    running = true
			    runToken += 1
			
			    local token = runToken
			
			    task.spawn(function()
			        for _, player in ipairs(Players:GetPlayers()) do
			            if not running or token ~= runToken then
			                break
			            end
			
			            if player ~= Players.LocalPlayer and startCallback then
			                pcall(startCallback, player)
			            end
			
			            task.wait(0.25)
			        end
			
			        if token == runToken then
			            AutoMog.Stop()
			        end
			    end)
			end
			
			function AutoMog.IsRunning()
			    return running
			end
			
			return AutoMog
		end)(unpack(_vararg))
	end,
}

_modules["Features/ServerFinder.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local ServerFinder = {}
			
			local findCallback
			local joinCallback
			
			function ServerFinder.SetCallbacks(findFn, joinFn)
			    findCallback = typeof(findFn) == "function"
			        and findFn
			        or nil
			
			    joinCallback = typeof(joinFn) == "function"
			        and joinFn
			        or nil
			end
			
			function ServerFinder.Find(username)
			    if not findCallback then
			        return nil, "Server Finder backend is not configured"
			    end
			
			    local success, result = pcall(
			        findCallback,
			        username
			    )
			
			    if not success then
			        return nil, result
			    end
			
			    return result
			end
			
			function ServerFinder.Join(serverId)
			    if not joinCallback then
			        return false, "Server join backend is not configured"
			    end
			
			    return pcall(
			        joinCallback,
			        serverId
			    )
			end
			
			return ServerFinder
		end)(unpack(_vararg))
	end,
}

_modules["Features/Teleports.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local Players = game:GetService("Players")
			
			local Teleports = {}
			
			Teleports.Locations = {
			    Win = Vector3.new(-682, 2, -53),
			    Treadmill = Vector3.new(8, 16, -153),
			}
			
			local loopToken = 0
			
			local function getRoot()
			    local player = Players.LocalPlayer
			
			    if not player then
			        return nil
			    end
			
			    local character = player.Character
			
			    if not character then
			        return nil
			    end
			
			    return character:FindFirstChild("HumanoidRootPart")
			end
			
			function Teleports.Teleport(position)
			    if typeof(position) ~= "Vector3" then
			        return false, "Invalid position"
			    end
			
			    local root = getRoot()
			
			    if not root then
			        return false, "HumanoidRootPart not found"
			    end
			
			    root.CFrame = CFrame.new(position)
			
			    return true
			end
			
			function Teleports.Win()
			    return Teleports.Teleport(Teleports.Locations.Win)
			end
			
			function Teleports.Treadmill()
			    return Teleports.Teleport(Teleports.Locations.Treadmill)
			end
			
			function Teleports.StopLoop()
			    loopToken += 1
			end
			
			function Teleports.StartLoop(position, interval)
			    Teleports.StopLoop()
			
			    loopToken += 1
			
			    local token = loopToken
			    local delayTime = math.clamp(
			        tonumber(interval) or 0.5,
			        0.01,
			        5
			    )
			
			    task.spawn(function()
			        while token == loopToken do
			            Teleports.Teleport(position)
			
			            task.wait(delayTime)
			        end
			    end)
			end
			
			function Teleports.SaveLocation(name, position, state)
			    if name == "" then
			        return false
			    end
			
			    if typeof(position) ~= "Vector3" then
			        return false
			    end
			
			    state.SavedLocations[name] = position
			
			    return true
			end
			
			function Teleports.DeleteLocation(name, state)
			    if state.SavedLocations[name] == nil then
			        return false
			    end
			
			    state.SavedLocations[name] = nil
			
			    return true
			end
			
			function Teleports.GetSaved(state)
			    return state.SavedLocations
			end
			
			return Teleports
		end)(unpack(_vararg))
	end,
}

_modules["Main.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local State = require("Core/State")
			local Utils = require("Core/Utils")
			local Remotes = require("Core/Remotes")
			
			local Teleports = require("Features/Teleports")
			local AutoClicker = require("Features/AutoClicker")
			local AutoMog = require("Features/AutoMog")
			local ServerFinder = require("Features/ServerFinder")
			local AutoLoad = require("Features/AutoLoad")
			
			local UI = require("UI/UI")
			
			print("[ZenWare V3] Starting...")
			
			local Window = UI.Create()
			
			--------------------------------------------------
			-- MAIN
			--------------------------------------------------
			
			local MainSection = Window:CreateSection("Main")
			local MainTab = MainSection:CreateTab("Main")
			
			MainTab:CreateSection("Win")
			
			MainTab:CreateToggle({
			    Name = "Auto Win (500m)",
			    Default = false,
			    Flag = "AutoWin",
			
			    Callback = function(enabled)
			        State.AutoWin = enabled
			
			        if enabled then
			            Teleports.Win()
			        end
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Teleport to Win",
			
			    Callback = function()
			        Teleports.Win()
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Teleport to Treadmill",
			
			    Callback = function()
			        Teleports.Treadmill()
			    end,
			})
			
			MainTab:CreateSection("Loops")
			
			MainTab:CreateSlider({
			    Name = "Loop Interval",
			    Min = 0.01,
			    Max = 5,
			    Default = 0.5,
			    Flag = "TeleportInterval",
			
			    Callback = function(value)
			        State.TeleportInterval = value
			
			        if State.TeleportLoop then
			            Teleports.StartLoop(
			                Teleports.Locations.Win,
			                value
			            )
			        end
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "Loop Win Teleport",
			    Default = false,
			    Flag = "TeleportLoop",
			
			    Callback = function(enabled)
			        State.TeleportLoop = enabled
			
			        if enabled then
			            Teleports.StartLoop(
			                Teleports.Locations.Win,
			                State.TeleportInterval
			            )
			        else
			            Teleports.StopLoop()
			        end
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "Loop Treadmill Teleport",
			    Default = false,
			    Flag = "TreadmillLoop",
			
			    Callback = function(enabled)
			        State.TreadmillLoop = enabled
			
			        if enabled then
			            Teleports.StartLoop(
			                Teleports.Locations.Treadmill,
			                State.TeleportInterval
			            )
			        else
			            Teleports.StopLoop()
			        end
			    end,
			})
			
			--------------------------------------------------
			-- TELEPORTS
			--------------------------------------------------
			
			local TeleportSection = Window:CreateSection("Teleports")
			local TeleportTab = TeleportSection:CreateTab("Teleports")
			
			TeleportTab:CreateSection("Custom XYZ")
			
			local xBox = TeleportTab:CreateTextBox({
			    Name = "X",
			    Placeholder = "X coordinate",
			})
			
			local yBox = TeleportTab:CreateTextBox({
			    Name = "Y",
			    Placeholder = "Y coordinate",
			})
			
			local zBox = TeleportTab:CreateTextBox({
			    Name = "Z",
			    Placeholder = "Z coordinate",
			})
			
			TeleportTab:CreateButton({
			    Name = "Teleport",
			
			    Callback = function()
			        local x = tonumber(xBox:GetText())
			        local y = tonumber(yBox:GetText())
			        local z = tonumber(zBox:GetText())
			
			        if x and y and z then
			            Teleports.Teleport(
			                Vector3.new(x, y, z)
			            )
			        end
			    end,
			})
			
			TeleportTab:CreateSection("Saved Locations")
			
			local saveBox = TeleportTab:CreateTextBox({
			    Name = "Location Name",
			    Placeholder = "My Location",
			})
			
			TeleportTab:CreateButton({
			    Name = "Save Current Location",
			
			    Callback = function()
			        local root = Utils.GetRoot()
			        local name = saveBox:GetText()
			
			        if root and name ~= "" then
			            Teleports.SaveLocation(
			                name,
			                root.Position,
			                State
			            )
			        end
			    end,
			})
			
			local deleteBox = TeleportTab:CreateTextBox({
			    Name = "Delete Location",
			    Placeholder = "Location Name",
			})
			
			TeleportTab:CreateButton({
			    Name = "Delete Saved Location",
			
			    Callback = function()
			        Teleports.DeleteLocation(
			            deleteBox:GetText(),
			            State
			        )
			    end,
			})
			
			--------------------------------------------------
			-- AUTO CLICKER
			--------------------------------------------------
			
			local ClickSection = Window:CreateSection("Auto Clicker")
			local ClickTab = ClickSection:CreateTab("Auto Clicker")
			
			ClickTab:CreateSlider({
			    Name = "Clicks Per Second",
			    Min = 1,
			    Max = 100,
			    Default = 10,
			    Flag = "AutoClickerSpeed",
			
			    Callback = function(value)
			        State.AutoClickerSpeed = value
			
			        if State.AutoClicker then
			            AutoClicker.Start(value)
			        end
			    end,
			})
			
			AutoClicker.SetCallback(function()
			    Remotes.Fire("Click")
			end)
			
			ClickTab:CreateToggle({
			    Name = "Enable Auto Clicker",
			    Default = false,
			    Flag = "AutoClicker",
			
			    Callback = function(enabled)
			        State.AutoClicker = enabled
			
			        if enabled then
			            AutoClicker.Start(
			                State.AutoClickerSpeed
			            )
			        else
			            AutoClicker.Stop()
			        end
			    end,
			})
			
			ClickTab:CreateKeybind({
			    Name = "Pause / Resume",
			    Default = Enum.KeyCode.F,
			    Flag = "AutoClickerKey",
			
			    Callback = function()
			        AutoClicker.Toggle(
			            State.AutoClickerSpeed
			        )
			
			        State.AutoClicker =
			            AutoClicker.IsRunning()
			    end,
			})
			
			--------------------------------------------------
			-- AUTO MOG
			--------------------------------------------------
			
			local MogSection = Window:CreateSection("Auto Mog")
			local MogTab = MogSection:CreateTab("Auto Mog")
			
			MogTab:CreateSection("Target")
			
			local targetBox = MogTab:CreateTextBox({
			    Name = "Player",
			    Placeholder = "Player username",
			})
			
			MogTab:CreateButton({
			    Name = "Mog Target",
			
			    Callback = function()
			        local username = targetBox:GetText()
			
			        if username ~= "" then
			            State.CurrentTarget = username
			            State.AutoMog = true
			
			            AutoMog.Start(username)
			        end
			    end,
			})
			
			MogTab:CreateButton({
			    Name = "Auto Mog All",
			
			    Callback = function()
			        State.AutoMogAll = true
			        AutoMog.StartAll()
			    end,
			})
			
			MogTab:CreateButton({
			    Name = "Stop Mog",
			
			    Callback = function()
			        State.AutoMog = false
			        State.AutoMogAll = false
			
			        AutoMog.Stop()
			    end,
			})
			
			AutoMog.SetCallbacks(
			    function(target)
			        Remotes.Fire("Mog", target.UserId)
			    end,
			
			    function()
			        Remotes.Fire("MogStop")
			    end
			)
			
			--------------------------------------------------
			-- SERVER FINDER
			--------------------------------------------------
			
			local ServerSection = Window:CreateSection("Server Finder")
			local ServerTab = ServerSection:CreateTab("Server Finder")
			
			local usernameBox = ServerTab:CreateTextBox({
			    Name = "Username",
			    Placeholder = "Player username",
			})
			
			ServerTab:CreateButton({
			    Name = "Find Player",
			
			    Callback = function()
			        local username = usernameBox:GetText()
			
			        if username == "" then
			            return
			        end
			
			        local result, err =
			            ServerFinder.Find(username)
			
			        Window:Notify({
			            Title = "Server Finder",
			            Description = tostring(
			                result or err
			            ),
			            Duration = 3,
			        })
			    end,
			})
			
			--------------------------------------------------
			-- CONFIGS
			--------------------------------------------------
			
			local ConfigSection = Window:CreateSection("Configs")
			local ConfigTab = ConfigSection:CreateTab("Configs")
			
			ConfigTab:CreateConfigSection()
			
			--------------------------------------------------
			-- SETTINGS
			--------------------------------------------------
			
			local SettingsSection = Window:CreateSection("Settings")
			local SettingsTab = SettingsSection:CreateTab("Settings")
			
			SettingsTab:CreateSection("General")
			
			SettingsTab:CreateKeybind({
			    Name = "UI Toggle Key",
			    Default = Enum.KeyCode.RightControl,
			    Flag = "UIToggleKey",
			
			    Callback = function(key)
			        Window:SetToggleKey(key)
			    end,
			})
			
			SettingsTab:CreateToggle({
			    Name = "Auto Load",
			    Default = AutoLoad.Get(true),
			    Flag = "AutoLoad",
			
			    Callback = function(enabled)
			        State.AutoLoad = enabled
			        AutoLoad.Set(enabled)
			    end,
			})
			
			--------------------------------------------------
			-- CREDITS
			--------------------------------------------------
			
			local CreditsSection = Window:CreateSection("Credits")
			local CreditsTab = CreditsSection:CreateTab("Credits")
			
			CreditsTab:CreateParagraph({
			    Title = "ZenWare V3",
			    Content = "@ZensMod",
			})
			
			--------------------------------------------------
			-- AUTOSAVE
			--------------------------------------------------
			
			Window:SetAutoSave(true)
			
			print("[ZenWare V3] Loaded successfully")
		end)(unpack(_vararg))
	end,
}

_modules["UI/UI.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)
			local Obsidian = require("Core/Obsidian")
			
			local UI = {}
			
			function UI.Create()
			    local Window = Obsidian.new(
			        "ZenWare V3",
			        "ZenWareConfigs"
			    )
			
			    Window:SetToggleKey(Enum.KeyCode.RightControl)
			
			    Window:Notify({
			        Title = "ZenWare V3",
			        Description = "Interface loaded successfully",
			        Duration = 3,
			    })
			
			    return Window
			end
			
			return UI

		end)(unpack(_vararg))
	end,
}

_modules["Core/Config"] = _modules["Core/Config.luau"]
_modules["Core/Obsidian"] = _modules["Core/Obsidian.luau"]
_modules["Core/Remotes"] = _modules["Core/Remotes.luau"]
_modules["Core/State"] = _modules["Core/State.luau"]
_modules["Core/Utils"] = _modules["Core/Utils.luau"]
_modules["Features/AutoClicker"] = _modules["Features/AutoClicker.luau"]
_modules["Features/AutoLoad"] = _modules["Features/AutoLoad.luau"]
_modules["Features/AutoMog"] = _modules["Features/AutoMog.luau"]
_modules["Features/ServerFinder"] = _modules["Features/ServerFinder.luau"]
_modules["Features/Teleports"] = _modules["Features/Teleports.luau"]
_modules["Main"] = _modules["Main.luau"]
_modules["UI/UI"] = _modules["UI/UI.luau"]

return require("Main")
end)(require or function() end, ...)