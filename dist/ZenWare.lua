
return (function(oldRequire)
local _vararg = {}
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
		return (function()
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
		return (function()
			local Obsidian = {}
			
			local REPO =
			    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
			
			local LOGO = 95816097006870
			
			local function loadLibrary()
			    local source =
			        game:HttpGet(REPO .. "Library.lua")
			
			    return loadstring(source)()
			end
			
			function Obsidian.new(title, configFolder)
			    local Library = loadLibrary()
			
			    Library.ForceCheckbox = false
			    Library.ShowToggleFrameInKeybinds = true
			
			    --------------------------------------------------
			    -- LILAC V1488 COLORS
			    --------------------------------------------------
			
			    pcall(function()
			        local Scheme = Library.Scheme
			
			        Scheme.FontColor =
			            Color3.fromRGB(
			                245,
			                235,
			                250
			            )
			
			        Scheme.BackgroundColor =
			            Color3.fromRGB(
			                7,
			                3,
			                10
			            )
			
			        Scheme.MainColor =
			            Color3.fromRGB(
			                21,
			                8,
			                29
			            )
			
			        Scheme.AccentColor =
			            Color3.fromRGB(
			                194,
			                94,
			                230
			            )
			
			        Scheme.OutlineColor =
			            Color3.fromRGB(
			                88,
			                40,
			                108
			            )
			    end)
			
			    local Window = Library:CreateWindow({
			        Title =
			            title
			            or "🌸 Lilac v1488",
			
			        Footer =
			            "zenware",
			
			        Icon = LOGO,
			
			        NotifySide = "Right",
			
			        ShowCustomCursor = true,
			        AutoShow = true,
			        Resizable = true,
			        Center = true,
			
			        Glow = true,
			        GlobalSearch = true,
			    })
			
			    --------------------------------------------------
			    -- OFFICIAL OBSIDIAN WINDOW BACKGROUND
			    --
			    -- The current Obsidian API accepts either a string
			    -- or number and writes it into Window.BackgroundImage.
			    --------------------------------------------------
			
			    pcall(function()
			        Window:SetBackgroundImage(
			            "rbxassetid://137423681201950"
			        )
			
			        Window:SetBackgroundImageEnabled(
			            true
			        )
			    end)
			
			    pcall(function()
			        Window:SetFooter(
			            "zenware"
			        )
			
			        Window:ChangeTitle(
			            "🌸 Lilac v1488"
			        )
			
			        Window:SetCornerRadius(
			            9
			        )
			    end)
			
			    --------------------------------------------------
			    -- FULLSCREEN BACKGROUND
			    --
			    -- Kept in a SEPARATE low DisplayOrder ScreenGui.
			    -- This means it never sits above / over the menu and
			    -- cannot steal the drag area. It follows Library.Toggled.
			    --------------------------------------------------
			
			    local FullscreenGui
			    local FullscreenImage
			    local FullscreenConnection
			
			    pcall(function()
			        local CoreGui =
			            game:GetService(
			                "CoreGui"
			            )
			
			        local old =
			            CoreGui:FindFirstChild(
			                "LilacV1488Fullscreen"
			            )
			
			        if old then
			            old:Destroy()
			        end
			
			        FullscreenGui =
			            Instance.new(
			                "ScreenGui"
			            )
			
			        FullscreenGui.Name =
			            "LilacV1488Fullscreen"
			
			        FullscreenGui.IgnoreGuiInset =
			            true
			
			        FullscreenGui.ResetOnSpawn =
			            false
			
			        FullscreenGui.DisplayOrder =
			            -1000
			
			        FullscreenGui.ZIndexBehavior =
			            Enum.ZIndexBehavior.Global
			
			        FullscreenGui.Parent =
			            CoreGui
			
			        FullscreenImage =
			            Instance.new(
			                "ImageLabel"
			            )
			
			        FullscreenImage.Name =
			            "Background"
			
			        FullscreenImage.BackgroundTransparency =
			            1
			
			        FullscreenImage.BorderSizePixel =
			            0
			
			        FullscreenImage.Position =
			            UDim2.fromScale(
			                0,
			                0
			            )
			
			        FullscreenImage.Size =
			            UDim2.fromScale(
			                1,
			                1
			            )
			
			        FullscreenImage.Image =
			            "rbxassetid://99217170570093"
			
			        FullscreenImage.ImageTransparency =
			            0.38
			
			        FullscreenImage.ScaleType =
			            Enum.ScaleType.Crop
			
			        -- Critical: never capture mouse input.
			        FullscreenImage.Active =
			            false
			
			        FullscreenImage.Selectable =
			            false
			
			        FullscreenImage.ZIndex =
			            -100
			
			        FullscreenImage.Parent =
			            FullscreenGui
			
			        FullscreenImage.Visible =
			            Library.Toggled == true
			
			        --------------------------------------------------
			        -- Dark lilac glass tint
			        --------------------------------------------------
			
			        local Tint =
			            Instance.new(
			                "Frame"
			            )
			
			        Tint.Name =
			            "LilacTint"
			
			        Tint.BackgroundColor3 =
			            Color3.fromRGB(
			                26,
			                6,
			                36
			            )
			
			        Tint.BackgroundTransparency =
			            0.68
			
			        Tint.BorderSizePixel =
			            0
			
			        Tint.Position =
			            UDim2.fromScale(
			                0,
			                0
			            )
			
			        Tint.Size =
			            UDim2.fromScale(
			                1,
			                1
			            )
			
			        Tint.Active =
			            false
			
			        Tint.ZIndex =
			            -99
			
			        Tint.Parent =
			            FullscreenGui
			
			        --------------------------------------------------
			        -- Follow Obsidian's real toggle state.
			        --------------------------------------------------
			
			        FullscreenConnection =
			            game:GetService(
			                "RunService"
			            ).RenderStepped:Connect(
			                function()
			                    if
			                        not FullscreenImage
			                        or not FullscreenImage.Parent
			                    then
			                        return
			                    end
			
			                    FullscreenImage.Visible =
			                        Library.Toggled == true
			
			                    Tint.Visible =
			                        Library.Toggled == true
			                end
			            )
			    end)
			
			
			    local ZenWindow = {
			        Library = Library,
			        Window = Window,
			        Sections = {},
			    }
			
			    --------------------------------------------------
			    -- SECTION
			    --------------------------------------------------
			
			    function ZenWindow:CreateSection(sectionName)
			        local Section = {
			            Name = sectionName,
			            Window = self,
			        }
			
			        --------------------------------------------------
			        -- TAB
			        --------------------------------------------------
			
			        function Section:CreateTab(tabName, icon)
			            local Tab =
			                self.Window.Window:AddTab(
			                    tabName,
			                    icon
			                )
			
			            local ZenTab = {
			                Tab = Tab,
			                Group = nil,
			            }
			
			            --------------------------------------------------
			            -- GROUP
			            --------------------------------------------------
			
			            function ZenTab:CreateSection(name, icon)
			                local Group
			
			                if icon then
			                    Group =
			                        self.Tab:AddLeftGroupbox(
			                            name,
			                            icon
			                        )
			                else
			                    Group =
			                        self.Tab:AddLeftGroupbox(
			                            name
			                        )
			                end
			
			                self.Group = Group
			
			                --------------------------------------------------
			                -- BUTTON
			                --------------------------------------------------
			
			                function self:CreateButton(config)
			                    config = config or {}
			
			                    return Group:AddButton({
			                        Text =
			                            config.Name
			                            or "Button",
			
			                        Func =
			                            config.Callback,
			                    })
			                end
			
			                --------------------------------------------------
			                -- TOGGLE
			                --------------------------------------------------
			
			                function self:CreateToggle(config)
			                    config = config or {}
			
			                    return Group:AddToggle(
			                        config.Flag
			                            or config.Name
			                            or "Toggle",
			
			                        {
			                            Text =
			                                config.Name
			                                or "Toggle",
			
			                            Default =
			                                config.Default == true,
			
			                            Callback =
			                                config.Callback,
			                        }
			                    )
			                end
			
			                --------------------------------------------------
			                -- SLIDER
			                --------------------------------------------------
			
			                function self:CreateSlider(config)
			                    config = config or {}
			
			                    return Group:AddSlider(
			                        config.Flag
			                            or config.Name
			                            or "Slider",
			
			                        {
			                            Text =
			                                config.Name
			                                or "Slider",
			
			                            Default =
			                                config.Default
			                                or 0,
			
			                            Min =
			                                config.Min
			                                or 0,
			
			                            Max =
			                                config.Max
			                                or 100,
			
			                            Rounding =
			                                config.Rounding
			                                or 2,
			
			                            Compact = false,
			
			                            Callback =
			                                config.Callback,
			                        }
			                    )
			                end
			
			                --------------------------------------------------
			                -- TEXT BOX
			                --------------------------------------------------
			
			                function self:CreateTextBox(config)
			                    config = config or {}
			
			                    local input =
			                        Group:AddInput(
			                            config.Flag
			                                or config.Name
			                                or "Input",
			
			                            {
			                                Text =
			                                    config.Name
			                                    or "Input",
			
			                                Placeholder =
			                                    config.Placeholder
			                                    or "",
			
			                                Default =
			                                    config.Default
			                                    or "",
			
			                                Callback =
			                                    config.Callback,
			                            }
			                        )
			
			                    local api = {}
			
			                    function api:GetText()
			                        if
			                            input
			                            and input.Value ~= nil
			                        then
			                            return tostring(
			                                input.Value
			                            )
			                        end
			
			                        return ""
			                    end
			
			                    function api:SetText(value)
			                        if
			                            input
			                            and input.SetValue
			                        then
			                            input:SetValue(
			                                tostring(
			                                    value or ""
			                                )
			                            )
			                        end
			                    end
			
			                    function api:Focus()
			                        if
			                            input
			                            and input.Input
			                        then
			                            input.Input:CaptureFocus()
			                        end
			                    end
			
			                    return api
			                end
			
			                --------------------------------------------------
			                -- KEYBIND
			                --------------------------------------------------
			
			                function self:CreateKeybind(config)
			                    config = config or {}
			
			                    local defaultKey =
			                        config.Default
			                        or "RightControl"
			
			                    if typeof(defaultKey)
			                        == "EnumItem"
			                    then
			                        defaultKey =
			                            defaultKey.Name
			                    elseif
			                        type(defaultKey)
			                        ~= "string"
			                    then
			                        defaultKey =
			                            "RightControl"
			                    end
			
			                    local label =
			                        Group:AddLabel(
			                            config.Name
			                                or "Keybind"
			                        )
			
			                    local keybind =
			                        label:AddKeyPicker(
			                            config.Flag
			                                or config.Name
			                                or "Keybind",
			
			                            {
			                                Default =
			                                    defaultKey,
			
			                                Mode =
			                                    "Toggle",
			
			                                Text =
			                                    config.Name
			                                    or "Keybind",
			
			                                Callback =
			                                    config.Callback,
			                            }
			                        )
			
			                    return keybind
			                end
			
			                --------------------------------------------------
			                -- COLOR PICKER
			                --------------------------------------------------
			
			                function self:CreateColorPicker(config)
			                    config = config or {}
			
			                    local label =
			                        Group:AddLabel(
			                            config.Name
			                                or "Color"
			                        )
			
			                    return label:AddColorPicker(
			                        config.Flag
			                            or config.Name
			                            or "Color",
			
			                        {
			                            Default =
			                                config.Default,
			
			                            Title =
			                                config.Name
			                                or "Color",
			
			                            Callback =
			                                config.Callback,
			                        }
			                    )
			                end
			
			                --------------------------------------------------
			                -- PARAGRAPH
			                --------------------------------------------------
			
			                function self:CreateParagraph(config)
			                    config = config or {}
			
			                    return Group:AddLabel({
			                        Text =
			                            tostring(
			                                config.Title
			                                or ""
			                            )
			                            .. "\n"
			                            .. tostring(
			                                config.Content
			                                or ""
			                            ),
			
			                        DoesWrap = true,
			                    })
			                end
			
			                --------------------------------------------------
			                -- IMAGE
			                --------------------------------------------------
			
			                function self:CreateImage(config)
			                    config = config or {}
			
			                    if not config.Image then
			                        return nil
			                    end
			
			                    return Group:AddImage(
			                        config.Flag
			                            or config.Name
			                            or "Image",
			
			                        {
			                            Image =
			                                config.Image,
			
			                            Height =
			                                config.Height
			                                or 120,
			
			                            Transparency =
			                                config.Transparency
			                                or 0,
			
			                            Color =
			                                config.Color,
			
			                            ScaleType =
			                                config.ScaleType
			                                or Enum.ScaleType.Fit,
			                        }
			                    )
			                end
			
			                --------------------------------------------------
			                -- CONFIG SECTION
			                --------------------------------------------------
			
			                function self:CreateConfigSection()
			                    Group:AddLabel(
			                        "Configuration"
			                    )
			                end
			
			                return Group
			            end
			
			            return ZenTab
			        end
			
			        return Section
			    end
			
			    --------------------------------------------------
			    -- NOTIFICATION
			    --------------------------------------------------
			
			    function ZenWindow:Notify(config)
			        config = config or {}
			
			        self.Library:Notify({
			            Title =
			                config.Title
			                or "ZenWare V3",
			
			            Description =
			                config.Description
			                or "",
			
			            Time =
			                config.Duration
			                or 3,
			
			            Icon =
			                config.Icon,
			
			            BigIcon =
			                config.BigIcon,
			
			            IconColor =
			                config.IconColor,
			        })
			    end
			
			    --------------------------------------------------
			    -- TOGGLE KEY
			    --------------------------------------------------
			
			    function ZenWindow:SetToggleKey(key)
			        if
			            self.Library.Options
			            and self.Library.Options.MenuKeybind
			            and self.Library.Options.MenuKeybind.SetValue
			        then
			            local keyName
			
			            if typeof(key) == "EnumItem" then
			                keyName = key.Name
			            elseif type(key) == "string" then
			                keyName = key
			            else
			                keyName = "RightControl"
			            end
			
			            self.Library.Options.MenuKeybind:SetValue({
			                keyName,
			                "Toggle",
			            })
			
			            return
			        end
			
			        self.ToggleKey = key
			    end
			
			    --------------------------------------------------
			    -- AUTOSAVE
			    --------------------------------------------------
			
			    function ZenWindow:SetAutoSave(enabled)
			        self.AutoSave =
			            enabled == true
			    end
			
			    --------------------------------------------------
			    -- DESTROY
			    --------------------------------------------------
			
			    function ZenWindow:Destroy()
			        if FullscreenConnection then
			            pcall(function()
			                FullscreenConnection:Disconnect()
			            end)
			
			            FullscreenConnection =
			                nil
			        end
			
			        if FullscreenGui then
			            pcall(function()
			                FullscreenGui:Destroy()
			            end)
			
			            FullscreenGui =
			                nil
			        end
			
			        if self.Library then
			            pcall(function()
			                self.Library:Unload()
			            end)
			        end
			    end
			
			    return ZenWindow
			end
			
			return Obsidian
		end)(unpack(_vararg))
	end,
}

_modules["Core/Remotes.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			
			local Remotes = {}
			
			local function folder()
			    return ReplicatedStorage:FindFirstChild("ZenWareRemotes")
			end
			
			function Remotes.Get(name)
			    local f = folder()
			
			    if not f then
			        return nil
			    end
			
			    local remote = f:FindFirstChild(name)
			
			    if remote and remote:IsA("RemoteEvent") then
			        return remote
			    end
			
			    return nil
			end
			
			function Remotes.Fire(name, arg)
			    local remote = Remotes.Get(name)
			
			    if not remote then
			        return false, "Remote not found: " .. tostring(name)
			    end
			
			    local ok, err = pcall(function()
			        if arg == nil then
			            remote:FireServer()
			        else
			            remote:FireServer(arg)
			        end
			    end)
			
			    return ok, err
			end
			
			return Remotes
		end)(unpack(_vararg))
	end,
}

_modules["Core/State.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function()
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
		return (function()
			local Utils = {}
			
			function Utils.SafeCall(fn, arg)
			    if typeof(fn) ~= "function" then
			        return false, "callback is not a function"
			    end
			
			    if arg == nil then
			        return pcall(fn)
			    end
			
			    return pcall(fn, arg)
			end
			
			function Utils.Number(value, fallback)
			    local n = tonumber(value)
			
			    if n == nil then
			        return fallback
			    end
			
			    return n
			end
			
			function Utils.GetLocalCharacter()
			    local Players = game:GetService("Players")
			    local player = Players.LocalPlayer
			
			    return player and player.Character
			end
			
			function Utils.GetRoot()
			    local character = Utils.GetLocalCharacter()
			
			    return character and character:FindFirstChild("HumanoidRootPart")
			end
			
			function Utils.GetPlayers()
			    local Players = game:GetService("Players")
			    local result = {}
			
			    for _, player in ipairs(Players:GetPlayers()) do
			        table.insert(result, player.Name)
			    end
			
			    table.sort(result)
			
			    return result
			end
			
			return Utils
		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoClicker.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function()
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
		return (function()
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
		return (function()
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
		return (function()
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
		return (function()
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
		return (function()
			local Players = game:GetService("Players")
			local Lighting = game:GetService("Lighting")
			local TeleportService = game:GetService("TeleportService")
			local VirtualUser = game:GetService("VirtualUser")
			local Workspace = game:GetService("Workspace")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local RunService = game:GetService("RunService")
			local UserInputService = game:GetService("UserInputService")
			local HttpService = game:GetService("HttpService")
			
			local LocalPlayer = Players.LocalPlayer
			
			--------------------------------------------------
			-- DEV MODE
			--------------------------------------------------
			-- Keep this enabled only while running your private
			-- development/test build. Set false before production.
			local DEV_TEST_MODE = true
			
			local State = require("Core/State")
			local Utils = require("Core/Utils")
			local Remotes = require("Core/Remotes")
			
			local Teleports = require("Features/Teleports")
			local AutoClicker = require("Features/AutoClicker")
			local AutoMog = require("Features/AutoMog")
			local AutoLoad = require("Features/AutoLoad")
			
			local UI = require("UI/UI")
			
			print("[ZenWare V3] Starting...")
			
			local Window = UI.Create()
			
			--------------------------------------------------
			-- HELPERS
			--------------------------------------------------
			
			local function Notify(title, description, duration)
			    pcall(function()
			        Window:Notify({
			            Title = title or "ZenWare V3",
			            Description = description or "",
			            Duration = duration or 3,
			        })
			    end)
			end
			
			local function SafeCall(callback)
			    if type(callback) ~= "function" then
			        return false, nil
			    end
			
			    local ok, result = pcall(callback)
			
			    if not ok then
			        warn(
			            "[ZenWare V3]",
			            tostring(result)
			        )
			    end
			
			    return ok, result
			end
			
			local function GetCharacter()
			    return LocalPlayer.Character
			end
			
			local function GetHumanoid()
			    local character = GetCharacter()
			
			    if not character then
			        return nil
			    end
			
			    return character:FindFirstChildOfClass(
			        "Humanoid"
			    )
			end
			
			local function GetRoot()
			    return Utils.GetRoot()
			end
			
			local function GetCamera()
			    return Workspace.CurrentCamera
			end
			
			local function GetPosition()
			    local root = GetRoot()
			
			    if not root then
			        return nil
			    end
			
			    return root.Position
			end
			
			local function FormatVector3(position)
			    if not position then
			        return "Unknown"
			    end
			
			    return string.format(
			        "X %.2f | Y %.2f | Z %.2f",
			        position.X,
			        position.Y,
			        position.Z
			    )
			end
			
			local function SetClipboard(value)
			    if type(setclipboard) ~= "function" then
			        return false
			    end
			
			    return pcall(function()
			        setclipboard(
			            tostring(value)
			        )
			    end)
			end
			
			--------------------------------------------------
			-- STATE
			--------------------------------------------------
			
			State.AutoWin =
			    State.AutoWin or false
			
			State.TeleportLoop =
			    State.TeleportLoop or false
			
			State.TreadmillLoop =
			    State.TreadmillLoop or false
			
			State.TeleportInterval =
			    tonumber(
			        State.TeleportInterval
			    )
			    or 0.5
			
			State.AutoRebirth = false
			State.RebirthInterval = 0.25
			
			State.AutoClicker = false
			State.AutoClickerSpeed =
			    tonumber(
			        State.AutoClickerSpeed
			    )
			    or 10
			
			State.AutoMog = false
			State.AutoMogAll = false
			
			State.WalkSpeed =
			    tonumber(
			        State.WalkSpeed
			    )
			    or 16
			
			State.JumpPower =
			    tonumber(
			        State.JumpPower
			    )
			    or 50
			
			State.HipHeight =
			    tonumber(
			        State.HipHeight
			    )
			    or 2
			
			State.AntiAFK = false
			
			--------------------------------------------------
			-- MAIN
			--------------------------------------------------
			
			local MainSection =
			    Window:CreateSection(
			        "Main"
			    )
			
			local MainTab =
			    MainSection:CreateTab(
			        "Main",
			        "home"
			    )
			
			--------------------------------------------------
			-- WIN
			--------------------------------------------------
			
			MainTab:CreateSection(
			    "Win"
			)
			
			MainTab:CreateButton({
			    Name = "Teleport to Win",
			
			    Callback = function()
			        SafeCall(function()
			            Teleports.Win()
			        end)
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Teleport to Treadmill",
			
			    Callback = function()
			        SafeCall(function()
			            Teleports.Treadmill()
			        end)
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Respawn Character",
			
			    Callback = function()
			        SafeCall(function()
			            LocalPlayer:LoadCharacter()
			        end)
			    end,
			})
			
			--------------------------------------------------
			-- AUTO WIN TESTS
			--------------------------------------------------
			
			local TweenService = game:GetService("TweenService")
			
			local DevTests = {
			    World1AutoWin = false,
			    World2AutoWin = false,
			}
			
			local AutoWinState = {
			    World1 = {
			        running = false,
			        part = nil,
			    },
			    World2 = {
			        running = false,
			        part = nil,
			    },
			}
			
			local WorldProfiles = {
			    -- Corrected mapping: the coordinates previously labeled World 2
			    -- belong to World 1, and vice versa.
			    World1 = {
			        start = Vector3.new(-105, 40, -52),
			        finish = Vector3.new(-700, 40, -51),
			        name = "World 1",
			    },
			
			    World2 = {
			        start = Vector3.new(-129, 40, 4944),
			        finish = Vector3.new(-720, 40, 4944),
			        name = "World 2",
			    },
			}
			
			local function GetDevCharacter()
			    return LocalPlayer.Character
			end
			
			local function GetDevRoot()
			    local character = GetDevCharacter()
			
			    if not character then
			        return nil
			    end
			
			    return character:FindFirstChild("HumanoidRootPart")
			end
			
			local function CreateAutoWinPart(worldName)
			    local profile = WorldProfiles[worldName]
			    local state = AutoWinState[worldName]
			
			    if not profile or not state then
			        return nil
			    end
			
			    if state.part and state.part.Parent then
			        return state.part
			    end
			
			    local part = Instance.new("Part")
			    part.Name = "ZenWare_" .. worldName .. "_AutoWin"
			    part.Size = Vector3.new(7, 1, 7)
			    part.CFrame = CFrame.new(profile.start)
			    part.Anchored = true
			    part.CanCollide = true
			    part.CanTouch = false
			    part.CanQuery = false
			    part.Transparency = 0.5
			    part.Parent = workspace
			
			    state.part = part
			
			    return part
			end
			
			local function RemoveAutoWinPart(worldName)
			    local state = AutoWinState[worldName]
			
			    if not state then
			        return
			    end
			
			    if state.part then
			        pcall(function()
			            state.part:Destroy()
			        end)
			    end
			
			    state.part = nil
			end
			
			local function StopAutoWinTest(worldName)
			    local state =
			        AutoWinState[worldName]
			
			    if not state then
			        return
			    end
			
			    state.running =
			        false
			
			    if state.gravityLocked then
			        state.gravityLocked =
			            false
			
			        SetDeveloperGravity(
			            false
			        )
			    end
			end
			
			local function RunVerticalOscillation(character, finishPosition, state)
			    if not character or not character.Parent then
			        return
			    end
			
			    local cycles = 10
			    local totalDuration = 1
			    local halfDuration = totalDuration / (cycles * 2)
			
			    local highY = 40
			    local lowY = -1
			
			    for _ = 1, cycles do
			        if not state.running or not character.Parent then
			            break
			        end
			
			        local currentPivot = character:GetPivot()
			        local highPivot = CFrame.new(
			            finishPosition.X,
			            highY,
			            finishPosition.Z
			        ) * CFrame.fromMatrix(
			            Vector3.zero,
			            currentPivot.XVector,
			            currentPivot.YVector,
			            currentPivot.ZVector
			        )
			
			        local lowPivot = CFrame.new(
			            finishPosition.X,
			            lowY,
			            finishPosition.Z
			        ) * CFrame.fromMatrix(
			            Vector3.zero,
			            currentPivot.XVector,
			            currentPivot.YVector,
			            currentPivot.ZVector
			        )
			
			        local driver = Instance.new("CFrameValue")
			        driver.Value = highPivot
			
			        local connection =
			            driver:GetPropertyChangedSignal("Value"):Connect(function()
			                if character.Parent then
			                    character:PivotTo(driver.Value)
			                end
			            end)
			
			        local downTween = TweenService:Create(
			            driver,
			            TweenInfo.new(
			                halfDuration,
			                Enum.EasingStyle.Linear,
			                Enum.EasingDirection.InOut
			            ),
			            {Value = lowPivot}
			        )
			
			        downTween:Play()
			        downTween.Completed:Wait()
			
			        if not state.running or not character.Parent then
			            connection:Disconnect()
			            driver:Destroy()
			            break
			        end
			
			        local upTween = TweenService:Create(
			            driver,
			            TweenInfo.new(
			                halfDuration,
			                Enum.EasingStyle.Linear,
			                Enum.EasingDirection.InOut
			            ),
			            {Value = highPivot}
			        )
			
			        upTween:Play()
			        upTween.Completed:Wait()
			
			        connection:Disconnect()
			        driver:Destroy()
			    end
			
			    if character.Parent and state.running then
			        character:PivotTo(
			            CFrame.new(finishPosition)
			        )
			    end
			end
			
			local function RunAutoWinCycle(worldName)
			    local profile = WorldProfiles[worldName]
			    local state = AutoWinState[worldName]
			
			    if not profile or not state then
			        return
			    end
			
			    local character = GetDevCharacter()
			
			    if not character then
			        return
			    end
			
			    local part = CreateAutoWinPart(worldName)
			
			    if not part then
			        return
			    end
			
			    character:PivotTo(
			        part.CFrame + Vector3.new(0, 3, 0)
			    )
			
			    task.wait(0.5)
			
			    if not state.running then
			        return
			    end
			
			    local driver = Instance.new("CFrameValue")
			    driver.Value = character:GetPivot()
			
			    local connection =
			        driver:GetPropertyChangedSignal("Value"):Connect(function()
			            if character.Parent then
			                character:PivotTo(driver.Value)
			            end
			        end)
			
			    local tween = TweenService:Create(
			        driver,
			        TweenInfo.new(
			            1,
			            Enum.EasingStyle.Linear,
			            Enum.EasingDirection.InOut
			        ),
			        {
			            Value = CFrame.new(profile.finish),
			        }
			    )
			
			    tween:Play()
			    tween.Completed:Wait()
			
			    connection:Disconnect()
			    driver:Destroy()
			
			    if not state.running or not character.Parent then
			        return
			    end
			
			    character:PivotTo(
			        CFrame.new(profile.finish)
			    )
			
			    -- Replace the old fall with a 1-second, 10-cycle vertical test.
			    RunVerticalOscillation(
			        character,
			        profile.finish,
			        state
			    )
			end
			
			local OriginalGravity = nil
			local GravityLocks = 0
			local GravityEnforcer = nil
			
			local function StartGravityEnforcer()
			    if GravityEnforcer then
			        return
			    end
			
			    GravityEnforcer =
			        RunService.Heartbeat:Connect(
			            function()
			                if GravityLocks > 0
			                    or devGravity0Enabled
			                then
			                    Workspace.Gravity = 0
			                end
			            end
			        )
			end
			
			local function StopGravityEnforcer()
			    if GravityEnforcer
			        and GravityLocks <= 0
			        and not devGravity0Enabled
			    then
			        GravityEnforcer:Disconnect()
			        GravityEnforcer = nil
			    end
			end
			
			local function CaptureGravity()
			    if OriginalGravity == nil then
			        OriginalGravity =
			            Workspace.Gravity
			    end
			end
			
			local function SetDeveloperGravity(enabled)
			    if not DEV_TEST_MODE then
			        return
			    end
			
			    if enabled then
			        GravityLocks += 1
			        CaptureGravity()
			        StartGravityEnforcer()
			        Workspace.Gravity = 0
			        return
			    end
			
			    GravityLocks =
			        math.max(
			            0,
			            GravityLocks - 1
			        )
			
			    if GravityLocks == 0
			        and not devGravity0Enabled
			    then
			        if OriginalGravity ~= nil then
			            Workspace.Gravity =
			                OriginalGravity
			
			            OriginalGravity =
			                nil
			        end
			
			        StopGravityEnforcer()
			    end
			end
			
			local function AnyAutoWinRunning()
			    return
			        (
			            AutoWinState.World1
			            and AutoWinState.World1.running
			        )
			        or
			        (
			            AutoWinState.World2
			            and AutoWinState.World2.running
			        )
			end
			
			local function StartAutoWinTest(worldName)
			    local state = AutoWinState[worldName]
			
			    if not state or state.running then
			        return
			    end
			
			    state.running = true
			
			    if not state.gravityLocked then
			        state.gravityLocked = true
			        SetDeveloperGravity(true)
			    end
			
			    CreateAutoWinPart(worldName)
			
			    Notify(
			        "Anti-Cheat Tests",
			        WorldProfiles[worldName].name .. " Auto Win started.",
			        3
			    )
			
			    task.spawn(function()
			        while state.running do
			            local ok, err = pcall(function()
			                RunAutoWinCycle(worldName)
			            end)
			
			            if not ok then
			                warn("[ZenWare AC TEST]", err)
			                task.wait(1)
			            end
			        end
			    end)
			end
			
			local function StopAllDevTests()
			    for name in pairs(DevTests) do
			        DevTests[name] = false
			    end
			
			    StopAutoWinTest("World1")
			    StopAutoWinTest("World2")
			end
			
			local function SetDevTest(name, enabled)
			    DevTests[name] =
			        enabled == true
			
			    if name == "World1AutoWin" then
			        if enabled then
			            StartAutoWinTest("World1")
			        else
			            StopAutoWinTest("World1")
			        end
			    elseif name == "World2AutoWin" then
			        if enabled then
			            StartAutoWinTest("World2")
			        else
			            StopAutoWinTest("World2")
			        end
			    end
			
			    Notify(
			        "Auto Win Dev",
			        tostring(name)
			            .. (
			                enabled
			                and " enabled."
			                or " disabled."
			            ),
			        2
			    )
			end
			
			MainTab:CreateSection(
			    "Auto Win Dev"
			)
			
			MainTab:CreateParagraph({
			    Title = "🌸 Developer",
			    Content =
			        "World 1 and World 2 movement test profiles."
			})
			
			MainTab:CreateSection(
			    "World 1"
			)
			
			MainTab:CreateToggle({
			    Name = "World 1 Auto Win Dev",
			    Default = false,
			    Flag = "World1AutoWinTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World1AutoWin",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateSection(
			    "World 2"
			)
			
			MainTab:CreateToggle({
			    Name = "World 2 Auto Win Dev",
			    Default = false,
			    Flag = "World2AutoWinTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World2AutoWin",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Disable Auto Win Dev",
			
			    Callback = function()
			        StopAllDevTests()
			
			        Notify(
			            "Auto Win Dev",
			            "Both tests disabled.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			local rebirthRunning = false
			
			local function GetRebirthButton()
			    local player =
			        Players.LocalPlayer
			
			    if not player then
			        return nil
			    end
			
			
			local function RunRebirthOnce()
			    local button =
			        GetRebirthButton()
			
			    if not button then
			        return false
			    end
			
			    local ok =
			        pcall(function()
			            firesignal(
			                button.MouseButton1Click
			            )
			        end)
			
			    return ok
			end
			
			local function StartAutoRebirth()
			    if rebirthRunning then
			        return
			    end
			
			    State.AutoRebirth = true
			    rebirthRunning = true
			
			    task.spawn(function()
			        while
			            State.AutoRebirth
			            and rebirthRunning
			        do
			            RunRebirthOnce()
			
			            task.wait(
			                State.RebirthInterval
			                or 0.25
			            )
			        end
			
			        rebirthRunning = false
			    end)
			end
			
			local function StopAutoRebirth()
			    State.AutoRebirth = false
			    rebirthRunning = false
			end
			
			-- TELEPORTS
			--------------------------------------------------
			
			local TeleportSection =
			    Window:CreateSection(
			        "Teleports"
			    )
			
			local TeleportTab =
			    TeleportSection:CreateTab(
			        "Teleports",
			        "map-pin"
			    )
			
			TeleportTab:CreateSection(
			    "Custom XYZ"
			)
			
			local xBox =
			    TeleportTab:CreateTextBox({
			        Name = "X",
			        Placeholder = "X coordinate",
			    })
			
			local yBox =
			    TeleportTab:CreateTextBox({
			        Name = "Y",
			        Placeholder = "Y coordinate",
			    })
			
			local zBox =
			    TeleportTab:CreateTextBox({
			        Name = "Z",
			        Placeholder = "Z coordinate",
			    })
			
			TeleportTab:CreateButton({
			    Name = "Teleport",
			
			    Callback = function()
			        local x =
			            tonumber(
			                xBox:GetText()
			            )
			
			        local y =
			            tonumber(
			                yBox:GetText()
			            )
			
			        local z =
			            tonumber(
			                zBox:GetText()
			            )
			
			        if not (
			            x
			            and y
			            and z
			        ) then
			            Notify(
			                "Teleport",
			                "Invalid coordinates.",
			                3
			            )
			
			            return
			        end
			
			        SafeCall(function()
			            Teleports.Teleport(
			                Vector3.new(
			                    x,
			                    y,
			                    z
			                )
			            )
			        end)
			    end,
			})
			
			TeleportTab:CreateButton({
			    Name = "Use Current Position",
			
			    Callback = function()
			        local position =
			            GetPosition()
			
			        if not position then
			            return
			        end
			
			        xBox:SetText(
			            tostring(
			                math.floor(
			                    position.X
			                )
			            )
			        )
			
			        yBox:SetText(
			            tostring(
			                math.floor(
			                    position.Y
			                )
			            )
			        )
			
			        zBox:SetText(
			            tostring(
			                math.floor(
			                    position.Z
			                )
			            )
			        )
			    end,
			})
			
			TeleportTab:CreateButton({
			    Name = "Clear Coordinates",
			
			    Callback = function()
			        xBox:SetText("")
			        yBox:SetText("")
			        zBox:SetText("")
			    end,
			})
			
			TeleportTab:CreateSection(
			    "Saved Locations"
			)
			
			local saveBox =
			    TeleportTab:CreateTextBox({
			        Name = "Location Name",
			        Placeholder = "My Location",
			    })
			
			TeleportTab:CreateButton({
			    Name = "Save Current Location",
			
			    Callback = function()
			        local root =
			            GetRoot()
			
			        local name =
			            saveBox:GetText()
			
			        if
			            root
			            and name ~= ""
			        then
			            SafeCall(function()
			                Teleports.SaveLocation(
			                    name,
			                    root.Position,
			                    State
			                )
			            end)
			        end
			    end,
			})
			
			local deleteBox =
			    TeleportTab:CreateTextBox({
			        Name = "Delete Location",
			        Placeholder = "Location Name",
			    })
			
			TeleportTab:CreateButton({
			    Name = "Delete Saved Location",
			
			    Callback = function()
			        local name =
			            deleteBox:GetText()
			
			        if name == "" then
			            return
			        end
			
			        SafeCall(function()
			            Teleports.DeleteLocation(
			                name,
			                State
			            )
			        end)
			    end,
			})
			
			--------------------------------------------------
			--------------------------------------------------
			-- AUTO CLICKER LOGIC
			--------------------------------------------------
			
			SafeCall(function()
			    AutoClicker.SetCallback(
			        function()
			            Remotes.Fire(
			                "Click"
			            )
			        end
			    )
			end)
			
			--------------------------------------------------
			-- AUTO MOG LOGIC
			--------------------------------------------------
			
			SafeCall(function()
			    AutoMog.SetCallbacks(
			        function(target)
			            if not target then
			                return
			            end
			
			            Remotes.Fire(
			                "Mog",
			                target.UserId
			            )
			        end,
			
			        function()
			            Remotes.Fire(
			                "MogStop"
			            )
			        end
			    )
			end)
			
			-- SERVER FINDER
			--------------------------------------------------
			
			local ServerSection =
			    Window:CreateSection(
			        "Server Finder"
			    )
			
			local ServerTab =
			    ServerSection:CreateTab(
			        "Server Finder",
			        "server"
			    )
			
			ServerTab:CreateSection(
			    "Current Server"
			)
			
			local usernameBox =
			    ServerTab:CreateTextBox({
			        Name = "Username",
			        Placeholder = "Player username",
			    })
			
			ServerTab:CreateButton({
			    Name = "Find Player",
			
			    Callback = function()
			        local username =
			            usernameBox:GetText()
			
			        username =
			            tostring(
			                username
			                or ""
			            )
			            :match(
			                "^%s*(.-)%s*$"
			            )
			
			        if username == "" then
			            return
			        end
			
			        local found = nil
			
			        for _, player in ipairs(
			            Players:GetPlayers()
			        ) do
			            if
			                string.lower(
			                    player.Name
			                )
			                ==
			                string.lower(
			                    username
			                )
			            then
			                found = player
			                break
			            end
			        end
			
			        if found then
			            Notify(
			                "Server Finder",
			                "FOUND\n"
			                    .. found.Name
			                    .. "\nUserId: "
			                    .. tostring(
			                        found.UserId
			                    )
			                    .. "\nJobId: "
			                    .. game.JobId,
			                5
			            )
			        else
			            Notify(
			                "Server Finder",
			                "Player is not in this server.",
			                4
			            )
			        end
			    end,
			})
			
			ServerTab:CreateButton({
			    Name = "Server Information",
			
			    Callback = function()
			        Notify(
			            "Current Server",
			            "PlaceId: "
			                .. tostring(
			                    game.PlaceId
			                )
			                .. "\nJobId: "
			                .. tostring(
			                    game.JobId
			                )
			                .. "\nPlayers: "
			                .. tostring(
			                    #Players:GetPlayers()
			                ),
			            5
			        )
			    end,
			})
			
			ServerTab:CreateButton({
			    Name = "Copy Job ID",
			
			    Callback = function()
			        if SetClipboard(
			            game.JobId
			        ) then
			            Notify(
			                "Server Finder",
			                "Job ID copied.",
			                2
			            )
			        end
			    end,
			})
			
			ServerTab:CreateSection(
			    "Join By Job ID"
			)
			
			local jobIdBox =
			    ServerTab:CreateTextBox({
			        Name = "Job ID",
			        Placeholder = "Paste server Job ID",
			    })
			
			ServerTab:CreateButton({
			    Name = "Join Server",
			
			    Callback = function()
			        local jobId =
			            jobIdBox:GetText()
			
			        jobId =
			            tostring(jobId or "")
			            :match("^%s*(.-)%s*$")
			
			        if jobId == "" then
			            Notify(
			                "Server Finder",
			                "Enter a Job ID first.",
			                3
			            )
			            return
			        end
			
			        local TeleportService =
			            game:GetService(
			                "TeleportService"
			            )
			
			        local ok, err =
			            pcall(function()
			                TeleportService:
			                    TeleportToPlaceInstance(
			                        game.PlaceId,
			                        jobId,
			                        Players.LocalPlayer
			                    )
			            end)
			
			        if not ok then
			            Notify(
			                "Server Finder",
			                "Could not join server.\n"
			                    .. tostring(err),
			                5
			            )
			            return
			        end
			
			        Notify(
			            "Server Finder",
			            "Joining Job ID:\n" .. jobId,
			            3
			        )
			    end,
			})
			
			ServerTab:CreateButton({
			    Name = "Use Current Job ID",
			
			    Callback = function()
			        jobIdBox:SetText(
			            tostring(
			                game.JobId
			            )
			        )
			
			        Notify(
			            "Server Finder",
			            "Current Job ID loaded.",
			            2
			        )
			    end,
			})
			
			ServerTab:CreateButton({
			    Name = "Clear Job ID",
			
			    Callback = function()
			        jobIdBox:SetText("")
			
			        Notify(
			            "Server Finder",
			            "Job ID cleared.",
			            2
			        )
			    end,
			})
			
			ServerTab:CreateButton({
			    Name = "List Players",
			
			    Callback = function()
			        local names = {}
			
			        for _, player in ipairs(
			            Players:GetPlayers()
			        ) do
			            table.insert(
			                names,
			                player.Name
			            )
			        end
			
			        table.sort(names)
			
			        Notify(
			            "Players",
			            table.concat(
			                names,
			                ", "
			            ),
			            6
			        )
			    end,
			})
			
			--------------------------------------------------
			-- SETTINGS
			--------------------------------------------------
			
			local SettingsSection =
			    Window:CreateSection(
			        "Settings"
			    )
			
			local SettingsTab =
			    SettingsSection:CreateTab(
			        "Settings",
			        "settings"
			    )
			
			--------------------------------------------------
			-- INTERFACE
			--------------------------------------------------
			
			SettingsTab:CreateSection(
			    "Interface"
			)
			
			SettingsTab:CreateKeybind({
			    Name = "UI Toggle Key",
			
			    Default =
			        Enum.KeyCode.RightControl,
			
			    Flag =
			        "UIToggleKey",
			
			    Callback = function(key)
			        Window:SetToggleKey(
			            key
			        )
			    end,
			})
			
			SettingsTab:CreateToggle({
			    Name = "Auto Load",
			
			    Default =
			        AutoLoad.Get(true),
			
			    Flag =
			        "AutoLoad",
			
			    Callback = function(enabled)
			        State.AutoLoad =
			            enabled
			
			        SafeCall(function()
			            AutoLoad.Set(
			                enabled
			            )
			        end)
			    end,
			})
			
			SettingsTab:CreateToggle({
			    Name = "Auto Save",
			
			    Default = true,
			
			    Flag = "AutoSave",
			
			    Callback = function(enabled)
			        Window:SetAutoSave(
			            enabled
			        )
			    end,
			})
			
			--------------------------------------------------
			-- PLAYER
			--------------------------------------------------
			
			SettingsTab:CreateSection(
			    "Player"
			)
			
			SettingsTab:CreateSlider({
			    Name = "Walk Speed",
			
			    Min = 0,
			    Max = 100,
			
			    Default =
			        State.WalkSpeed,
			
			    Flag =
			        "WalkSpeed",
			
			    Callback = function(value)
			        State.WalkSpeed =
			            value
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.WalkSpeed =
			                value
			        end
			    end,
			})
			
			SettingsTab:CreateSlider({
			    Name = "Jump Power",
			
			    Min = 0,
			    Max = 150,
			
			    Default =
			        State.JumpPower,
			
			    Flag =
			        "JumpPower",
			
			    Callback = function(value)
			        State.JumpPower =
			            value
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.UseJumpPower =
			                true
			
			            humanoid.JumpPower =
			                value
			        end
			    end,
			})
			
			SettingsTab:CreateSlider({
			    Name = "Hip Height",
			
			    Min = 0,
			    Max = 10,
			
			    Default =
			        State.HipHeight,
			
			    Flag =
			        "HipHeight",
			
			    Callback = function(value)
			        State.HipHeight =
			            value
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.HipHeight =
			                value
			        end
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "Apply Player Settings",
			
			    Callback = function()
			        local humanoid =
			            GetHumanoid()
			
			        if not humanoid then
			            return
			        end
			
			        humanoid.WalkSpeed =
			            State.WalkSpeed
			
			        humanoid.UseJumpPower =
			            true
			
			        humanoid.JumpPower =
			            State.JumpPower
			
			        humanoid.HipHeight =
			            State.HipHeight
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "Reset Player Settings",
			
			    Callback = function()
			        local humanoid =
			            GetHumanoid()
			
			        if not humanoid then
			            return
			        end
			
			        humanoid.WalkSpeed =
			            16
			
			        humanoid.UseJumpPower =
			            true
			
			        humanoid.JumpPower =
			            50
			
			        humanoid.HipHeight =
			            2
			
			        State.WalkSpeed =
			            16
			
			        State.JumpPower =
			            50
			
			        State.HipHeight =
			            2
			    end,
			})
			
			--------------------------------------------------
			-- CAMERA
			--------------------------------------------------
			
			SettingsTab:CreateSection(
			    "Camera"
			)
			
			SettingsTab:CreateSlider({
			    Name = "Field Of View",
			
			    Min = 40,
			    Max = 120,
			
			    Default = 70,
			
			    Flag = "CameraFOV",
			
			    Callback = function(value)
			        local camera =
			            GetCamera()
			
			        if camera then
			            camera.FieldOfView =
			                value
			        end
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "Reset FOV",
			
			    Callback = function()
			        local camera =
			            GetCamera()
			
			        if camera then
			            camera.FieldOfView =
			                70
			        end
			    end,
			})
			
			--------------------------------------------------
			-- WORLD
			--------------------------------------------------
			
			SettingsTab:CreateSection(
			    "World"
			)
			
			SettingsTab:CreateToggle({
			    Name = "Full Bright",
			
			    Default = false,
			
			    Flag =
			        "FullBright",
			
			    Callback = function(enabled)
			        if enabled then
			            Lighting.Brightness =
			                2
			
			            Lighting.ClockTime =
			                14
			
			            Lighting.FogEnd =
			                100000
			
			            Lighting.GlobalShadows =
			                false
			        else
			            Lighting.Brightness =
			                1
			
			            Lighting.FogEnd =
			                1000
			
			            Lighting.GlobalShadows =
			                true
			        end
			    end,
			})
			
			SettingsTab:CreateSlider({
			    Name = "Gravity",
			
			    Min = 0,
			    Max = 300,
			
			    Default =
			        Workspace.Gravity,
			
			    Flag =
			        "Gravity",
			
			    Callback = function(value)
			        Workspace.Gravity =
			            value
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "Reset Gravity",
			
			    Callback = function()
			        Workspace.Gravity =
			            196.2
			    end,
			})
			
			--------------------------------------------------
			-- UTILITY
			--------------------------------------------------
			
			SettingsTab:CreateSection(
			    "Utility"
			)
			
			SettingsTab:CreateToggle({
			    Name = "Anti AFK",
			
			    Default = false,
			
			    Flag =
			        "AntiAFK",
			
			    Callback = function(enabled)
			        State.AntiAFK =
			            enabled
			
			        if not enabled then
			            return
			        end
			
			        task.spawn(function()
			            while State.AntiAFK do
			                pcall(function()
			                    VirtualUser:
			                        CaptureController()
			
			                    VirtualUser:
			                        ClickButton2(
			                            Vector2.new()
			                        )
			                end)
			
			                task.wait(
			                    60
			                )
			            end
			        end)
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "Get Player Count",
			
			    Callback = function()
			        Notify(
			            "Players",
			            tostring(
			                #Players:GetPlayers()
			            ),
			            3
			        )
			    end,
			})
			
			SettingsTab:CreateButton({
			    Name = "List Players",
			
			    Callback = function()
			        local names = {}
			
			        for _, player in ipairs(
			            Players:GetPlayers()
			        ) do
			            table.insert(
			                names,
			                player.Name
			            )
			        end
			
			        table.sort(
			            names
			        )
			
			        Notify(
			            "Players",
			            table.concat(
			                names,
			                ", "
			            ),
			            6
			        )
			    end,
			})
			
			--------------------------------------------------
			-- CONFIGS
			--------------------------------------------------
			
			local ConfigSection =
			    Window:CreateSection(
			        "Configs"
			    )
			
			local ConfigTab =
			    ConfigSection:CreateTab(
			        "Configs",
			        "folder"
			    )
			
			local CONFIG_FOLDER =
			    "ZenWare/Lilac"
			
			local ConfigNameBox =
			    ConfigTab:CreateTextBox({
			        Name = "Config Name",
			        Placeholder = "Example: main",
			        Default = "default",
			    })
			
			local function SafeConfigName(name)
			    name =
			        tostring(
			            name
			            or "default"
			        )
			        :gsub(
			            "[^%w_%-%s]",
			            ""
			        )
			        :gsub(
			            "%s+",
			            "_"
			        )
			
			    if name == "" then
			        name = "default"
			    end
			
			    return name
			end
			
			local function ConfigPath(name)
			    return CONFIG_FOLDER
			        .. "/"
			        .. SafeConfigName(name)
			        .. ".json"
			end
			
			local function EnsureConfigFolder()
			    if type(isfolder) == "function"
			        and type(makefolder) == "function"
			    then
			        pcall(function()
			            if not isfolder(CONFIG_FOLDER) then
			                makefolder(
			                    "ZenWare"
			                )
			            end
			
			            if not isfolder(
			                CONFIG_FOLDER
			            ) then
			                makefolder(
			                    CONFIG_FOLDER
			                )
			            end
			        end)
			    end
			end
			
			local function BuildConfigData()
			    return {
			        WalkSpeed =
			            State.WalkSpeed,
			
			        JumpPower =
			            State.JumpPower,
			
			        HipHeight =
			            State.HipHeight,
			
			        RebirthInterval =
			            State.RebirthInterval,
			
			        AutoClickerSpeed =
			            State.AutoClickerSpeed,
			
			        AutoRebirth =
			            State.AutoRebirth == true,
			
			        AutoClicker =
			            State.AutoClicker == true,
			
			        AutoMog =
			            State.AutoMog == true,
			
			        AutoMogAll =
			            State.AutoMogAll == true,
			
			        AntiAFK =
			            State.AntiAFK == true,
			
			        World1AutoWin =
			            DevTests.World1AutoWin == true,
			
			        World2AutoWin =
			            DevTests.World2AutoWin == true,
			
			        SavedAt =
			            os.time(),
			    }
			end
			
			local function ApplyOption(
			    flag,
			    value
			)
			    pcall(function()
			        local library =
			            Window.Library
			
			        local options =
			            library
			            and library.Options
			
			        local option =
			            options
			            and options[flag]
			
			        if option
			            and option.SetValue
			        then
			            option:SetValue(
			                value
			            )
			        end
			    end)
			end
			
			local function ApplyConfigData(data)
			    if type(data) ~= "table" then
			        return false
			    end
			
			    State.WalkSpeed =
			        tonumber(
			            data.WalkSpeed
			        )
			        or State.WalkSpeed
			
			    State.JumpPower =
			        tonumber(
			            data.JumpPower
			        )
			        or State.JumpPower
			
			    State.HipHeight =
			        tonumber(
			            data.HipHeight
			        )
			        or State.HipHeight
			
			    State.RebirthInterval =
			        tonumber(
			            data.RebirthInterval
			        )
			        or State.RebirthInterval
			
			    State.AutoClickerSpeed =
			        tonumber(
			            data.AutoClickerSpeed
			        )
			        or State.AutoClickerSpeed
			
			    ApplyOption(
			        "WalkSpeed",
			        State.WalkSpeed
			    )
			
			    ApplyOption(
			        "JumpPower",
			        State.JumpPower
			    )
			
			    ApplyOption(
			        "HipHeight",
			        State.HipHeight
			    )
			
			    ApplyOption(
			        "RebirthInterval",
			        State.RebirthInterval
			    )
			
			    ApplyOption(
			        "AutoClickerSpeed",
			        State.AutoClickerSpeed
			    )
			
			    ApplyOption(
			        "AutoRebirth",
			        data.AutoRebirth == true
			    )
			
			    ApplyOption(
			        "AutoClicker",
			        data.AutoClicker == true
			    )
			
			    ApplyOption(
			        "AutoMog",
			        data.AutoMog == true
			    )
			
			    ApplyOption(
			        "AutoMogAll",
			        data.AutoMogAll == true
			    )
			
			    ApplyOption(
			        "AntiAFK",
			        data.AntiAFK == true
			    )
			
			    ApplyOption(
			        "World1AutoWinTest",
			        data.World1AutoWin == true
			    )
			
			    ApplyOption(
			        "World2AutoWinTest",
			        data.World2AutoWin == true
			    )
			
			    return true
			end
			
			local function SaveConfig(name)
			    EnsureConfigFolder()
			
			    if type(writefile) ~= "function" then
			        return false,
			            "writefile is unavailable"
			    end
			
			    local encoded =
			        HttpService:JSONEncode(
			            BuildConfigData()
			        )
			
			    local ok, err =
			        pcall(function()
			            writefile(
			                ConfigPath(name),
			                encoded
			            )
			        end)
			
			    return ok, err
			end
			
			local function LoadConfig(name)
			    if type(readfile) ~= "function"
			        or type(isfile) ~= "function"
			    then
			        return false,
			            "readfile/isfile is unavailable"
			    end
			
			    local path =
			        ConfigPath(name)
			
			    if not isfile(path) then
			        return false,
			            "Config not found"
			    end
			
			    local ok, data =
			        pcall(function()
			            return HttpService:JSONDecode(
			                readfile(path)
			            )
			        end)
			
			    if not ok then
			        return false,
			            tostring(data)
			    end
			
			    return ApplyConfigData(
			        data
			    ),
			        nil
			end
			
			local function DeleteConfig(name)
			    if type(delfile) ~= "function"
			        or type(isfile) ~= "function"
			    then
			        return false,
			            "delfile/isfile is unavailable"
			    end
			
			    local path =
			        ConfigPath(name)
			
			    if not isfile(path) then
			        return false,
			            "Config not found"
			    end
			
			    return pcall(function()
			        delfile(path)
			    end)
			end
			
			local function ListConfigs()
			    if type(listfiles) ~= "function" then
			        return {}
			    end
			
			    EnsureConfigFolder()
			
			    local result = {}
			
			    local ok, files =
			        pcall(function()
			            return listfiles(
			                CONFIG_FOLDER
			            )
			        end)
			
			    if not ok or type(files) ~= "table" then
			        return result
			    end
			
			    for _, path in ipairs(files) do
			        local name =
			            tostring(path)
			            :match(
			                "([^/\\]+)%.json$"
			            )
			
			        if name then
			            table.insert(
			                result,
			                name
			            )
			        end
			    end
			
			    table.sort(result)
			
			    return result
			end
			
			ConfigTab:CreateSection(
			    "Configuration"
			)
			
			ConfigTab:CreateButton({
			    Name = "Save Config",
			
			    Callback = function()
			        local name =
			            ConfigNameBox:GetText()
			
			        local ok, err =
			            SaveConfig(name)
			
			        Notify(
			            "Configs",
			            ok
			                and (
			                    "Saved "
			                    .. SafeConfigName(name)
			                    .. "."
			                )
			                or (
			                    "Save failed: "
			                    .. tostring(err)
			                ),
			            4
			        )
			    end,
			})
			
			ConfigTab:CreateButton({
			    Name = "Load Config",
			
			    Callback = function()
			        local name =
			            ConfigNameBox:GetText()
			
			        local ok, err =
			            LoadConfig(name)
			
			        Notify(
			            "Configs",
			            ok
			                and (
			                    "Loaded "
			                    .. SafeConfigName(name)
			                    .. "."
			                )
			                or (
			                    "Load failed: "
			                    .. tostring(err)
			                ),
			            4
			        )
			    end,
			})
			
			ConfigTab:CreateButton({
			    Name = "Delete Config",
			
			    Callback = function()
			        local name =
			            ConfigNameBox:GetText()
			
			        local ok, err =
			            DeleteConfig(name)
			
			        Notify(
			            "Configs",
			            ok
			                and (
			                    "Deleted "
			                    .. SafeConfigName(name)
			                    .. "."
			                )
			                or (
			                    "Delete failed: "
			                    .. tostring(err)
			                ),
			            4
			        )
			    end,
			})
			
			ConfigTab:CreateButton({
			    Name = "List Configs",
			
			    Callback = function()
			        local configs =
			            ListConfigs()
			
			        Notify(
			            "Configs",
			            #configs > 0
			                and table.concat(
			                    configs,
			                    ", "
			                )
			                or "No configs found.",
			            6
			        )
			    end,
			})
			
			ConfigTab:CreateButton({
			    Name = "Save As Default",
			
			    Callback = function()
			        local ok, err =
			            SaveConfig(
			                "default"
			            )
			
			        Notify(
			            "Configs",
			            ok
			                and "Default config saved."
			                or (
			                    "Save failed: "
			                    .. tostring(err)
			                ),
			            4
			        )
			    end,
			})
			
			ConfigTab:CreateParagraph({
			    Title =
			        "Local Configs",
			
			    Content =
			        "Configs are stored locally as JSON. "
			        .. "Save and Load are real file operations.",
			})
			
			-- CREDITS
			--------------------------------------------------
			
			local CreditsSection =
			    Window:CreateSection(
			        "Credits"
			    )
			
			local CreditsTab =
			    CreditsSection:CreateTab(
			        "Credits",
			        "heart"
			    )
			
			CreditsTab:CreateSection(
			    "ZenWare V3"
			)
			
			CreditsTab:CreateParagraph({
			    Title =
			        "ZenWare V3",
			
			    Content =
			        "@ZensMod\n"
			        .. "ZenWare V3",
			})
			
			CreditsTab:CreateButton({
			    Name = "Copy ZenWare Name",
			
			    Callback = function()
			        if SetClipboard(
			            "ZenWare V3"
			        ) then
			            Notify(
			                "Credits",
			                "Copied.",
			                2
			            )
			        end
			    end,
			})
			
			CreditsTab:CreateButton({
			    Name = "Show Version",
			
			    Callback = function()
			        Notify(
			            "ZenWare",
			            "Version V3",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- EXTRA UTILITIES
			--------------------------------------------------
			
			local UtilitySection =
			    Window:CreateSection(
			        "Utilities"
			    )
			
			local UtilityTab =
			    UtilitySection:CreateTab(
			        "Utilities",
			        "sparkles"
			    )
			
			local SessionStart =
			    os.clock()
			
			--------------------------------------------------
			-- AUTOMATION
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Automation"
			)
			
			UtilityTab:CreateSlider({
			    Name = "Rebirth Interval",
			
			    Min = 0.05,
			    Max = 2,
			
			    Default =
			        State.RebirthInterval,
			
			    Flag = "RebirthInterval",
			
			    Callback = function(value)
			        State.RebirthInterval =
			            tonumber(value)
			            or 0.25
			    end,
			})
			
			UtilityTab:CreateToggle({
			    Name = "Auto Rebirth",
			
			    Default =
			        State.AutoRebirth == true,
			
			    Flag = "AutoRebirth",
			
			    Callback = function(enabled)
			        if enabled then
			            StartAutoRebirth()
			        else
			            StopAutoRebirth()
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Rebirth Once",
			
			    Callback = function()
			        local ok =
			            RunRebirthOnce()
			
			        Notify(
			            "Auto Rebirth",
			            ok
			                and "Rebirth requested."
			                or "Rebirth button not found.",
			            3
			        )
			    end,
			})
			
			UtilityTab:CreateSlider({
			    Name = "Clicks Per Second",
			
			    Min = 1,
			    Max = 100,
			
			    Default =
			        State.AutoClickerSpeed,
			
			    Flag = "AutoClickerSpeed",
			
			    Callback = function(value)
			        State.AutoClickerSpeed =
			            tonumber(value)
			            or 10
			
			        if State.AutoClicker then
			            SafeCall(function()
			                AutoClicker.Start(
			                    State.AutoClickerSpeed
			                )
			            end)
			        end
			    end,
			})
			
			UtilityTab:CreateToggle({
			    Name = "Auto Clicker",
			
			    Default =
			        State.AutoClicker == true,
			
			    Flag = "AutoClicker",
			
			    Callback = function(enabled)
			        State.AutoClicker =
			            enabled == true
			
			        if State.AutoClicker then
			            SafeCall(function()
			                AutoClicker.Start(
			                    State.AutoClickerSpeed
			                )
			            end)
			        else
			            SafeCall(function()
			                AutoClicker.Stop()
			            end)
			        end
			    end,
			})
			
			UtilityTab:CreateKeybind({
			    Name = "Clicker Hotkey",
			
			    Default = Enum.KeyCode.F,
			
			    Flag = "AutoClickerKey",
			
			    Callback = function()
			        SafeCall(function()
			            AutoClicker.Toggle(
			                State.AutoClickerSpeed
			            )
			        end)
			
			        SafeCall(function()
			            State.AutoClicker =
			                AutoClicker.IsRunning()
			        end)
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Stop Clicker",
			
			    Callback = function()
			        State.AutoClicker = false
			
			        SafeCall(function()
			            AutoClicker.Stop()
			        end)
			    end,
			})
			
			local utilityTargetBox =
			    UtilityTab:CreateTextBox({
			        Name = "Mog Target",
			        Placeholder = "Player username",
			    })
			
			UtilityTab:CreateButton({
			    Name = "Mog Target",
			
			    Callback = function()
			        local username =
			            utilityTargetBox:GetText()
			
			        if username == "" then
			            Notify(
			                "Auto Mog",
			                "Enter a username first.",
			                3
			            )
			            return
			        end
			
			        State.CurrentTarget =
			            username
			
			        State.AutoMog = true
			
			        SafeCall(function()
			            AutoMog.Start(
			                username
			            )
			        end)
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Mog All",
			
			    Callback = function()
			        State.AutoMogAll = true
			
			        SafeCall(function()
			            AutoMog.StartAll()
			        end)
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Stop Mog",
			
			    Callback = function()
			        State.AutoMog = false
			        State.AutoMogAll = false
			
			        SafeCall(function()
			            AutoMog.Stop()
			        end)
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Clear Mog Target",
			
			    Callback = function()
			        utilityTargetBox:SetText("")
			        State.CurrentTarget = nil
			    end,
			})
			
			--------------------------------------------------
			-- MOVEMENT / CHARACTER
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Movement"
			)
			
			UtilityTab:CreateSlider({
			    Name = "WalkSpeed",
			
			    Min = 1,
			    Max = 100,
			
			    Default =
			        State.WalkSpeed,
			
			    Flag = "WalkSpeed",
			
			    Callback = function(value)
			        State.WalkSpeed =
			            tonumber(value)
			            or 16
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.WalkSpeed =
			                State.WalkSpeed
			        end
			    end,
			})
			
			UtilityTab:CreateSlider({
			    Name = "JumpPower",
			
			    Min = 1,
			    Max = 150,
			
			    Default =
			        State.JumpPower,
			
			    Flag = "JumpPower",
			
			    Callback = function(value)
			        State.JumpPower =
			            tonumber(value)
			            or 50
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.UseJumpPower = true
			            humanoid.JumpPower =
			                State.JumpPower
			        end
			    end,
			})
			
			UtilityTab:CreateSlider({
			    Name = "HipHeight",
			
			    Min = 0,
			    Max = 10,
			
			    Default =
			        State.HipHeight,
			
			    Flag = "HipHeight",
			
			    Callback = function(value)
			        State.HipHeight =
			            tonumber(value)
			            or 2
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            humanoid.HipHeight =
			                State.HipHeight
			        end
			    end,
			})
			
			UtilityTab:CreateToggle({
			    Name = "Anti AFK",
			
			    Default =
			        State.AntiAFK == true,
			
			    Flag = "AntiAFK",
			
			    Callback = function(enabled)
			        State.AntiAFK =
			            enabled == true
			
			        if enabled then
			            SafeCall(function()
			                LocalPlayer.Idled:Connect(
			                    function()
			                        VirtualUser:CaptureController()
			                        VirtualUser:ClickButton2(
			                            Vector2.new()
			                        )
			                    end
			                )
			            end)
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Reset Character Physics",
			
			    Callback = function()
			        local humanoid =
			            GetHumanoid()
			
			        local root =
			            GetRoot()
			
			        if root then
			            root.AssemblyLinearVelocity =
			                Vector3.zero
			
			            root.AssemblyAngularVelocity =
			                Vector3.zero
			        end
			
			        if humanoid then
			            humanoid.WalkSpeed =
			                16
			
			            humanoid.JumpPower =
			                50
			
			            humanoid.HipHeight =
			                2
			        end
			
			        State.WalkSpeed = 16
			        State.JumpPower = 50
			        State.HipHeight = 2
			
			        Notify(
			            "Movement",
			            "Character physics reset.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- CAMERA / VISUAL
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Camera & Visuals"
			)
			
			UtilityTab:CreateSlider({
			    Name = "Camera FOV",
			
			    Min = 40,
			    Max = 120,
			
			    Default = 70,
			
			    Flag = "CameraFOV",
			
			    Callback = function(value)
			        local camera =
			            GetCamera()
			
			        if camera then
			            camera.FieldOfView =
			                tonumber(value)
			                or 70
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "FOV 70",
			
			    Callback = function()
			        local camera =
			            GetCamera()
			
			        if camera then
			            camera.FieldOfView = 70
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "FOV 90",
			
			    Callback = function()
			        local camera =
			            GetCamera()
			
			        if camera then
			            camera.FieldOfView = 90
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Clear Visual Effects",
			
			    Callback = function()
			        for _, object in ipairs(
			            Lighting:GetChildren()
			        ) do
			            if
			                object:IsA("BlurEffect")
			                or object:IsA("ColorCorrectionEffect")
			                or object:IsA("BloomEffect")
			                or object:IsA("SunRaysEffect")
			            then
			                pcall(function()
			                    object.Enabled = false
			                end)
			            end
			        end
			
			        Notify(
			            "Visuals",
			            "Local visual effects disabled.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- SESSION
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Session"
			)
			
			UtilityTab:CreateParagraph({
			    Title = "🌸 Lilac Utilities",
			    Content =
			        "Client information, dev tests and small helpers."
			})
			
			UtilityTab:CreateButton({
			    Name = "Session Info",
			
			    Callback = function()
			        local character =
			            LocalPlayer.Character
			
			        local position =
			            character
			            and character:GetPivot().Position
			
			        Notify(
			            "Session Info",
			            "Place: "
			                .. tostring(game.PlaceId)
			                .. "\nPlayers: "
			                .. tostring(#Players:GetPlayers())
			                .. "\nUptime: "
			                .. string.format(
			                    "%.0fs",
			                    os.clock() - SessionStart
			                )
			                .. "\nPosition: "
			                .. (
			                    position
			                    and string.format(
			                        "%.1f, %.1f, %.1f",
			                        position.X,
			                        position.Y,
			                        position.Z
			                    )
			                    or "Unknown"
			                ),
			            6
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Show Place ID",
			
			    Callback = function()
			        Notify(
			            "Place ID",
			            tostring(game.PlaceId),
			            4
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Show Job ID",
			
			    Callback = function()
			        Notify(
			            "Job ID",
			            tostring(game.JobId),
			            4
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Show Player Count",
			
			    Callback = function()
			        Notify(
			            "Server",
			            tostring(
			                #Players:GetPlayers()
			            ) .. " players online.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- CHARACTER
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Character"
			)
			
			UtilityTab:CreateButton({
			    Name = "Refresh Character",
			
			    Callback = function()
			        SafeCall(function()
			            LocalPlayer:LoadCharacter()
			        end)
			
			        Notify(
			            "Character",
			            "Refresh requested.",
			            3
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Reset Camera",
			
			    Callback = function()
			        SafeCall(function()
			            local character =
			                LocalPlayer.Character
			
			            local humanoid =
			                character
			                and character:FindFirstChildOfClass(
			                    "Humanoid"
			                )
			
			            if humanoid then
			                Workspace.CurrentCamera.CameraSubject =
			                    humanoid
			                Workspace.CurrentCamera.CameraType =
			                    Enum.CameraType.Custom
			            end
			        end)
			
			        Notify(
			            "Camera",
			            "Camera reset.",
			            2
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Character Position",
			
			    Callback = function()
			        local position =
			            GetPosition()
			
			        Notify(
			            "Position",
			            FormatVector3(
			                position
			            ),
			            4
			        )
			    end,
			})
			
			--------------------------------------------------
			-- DEVELOPER PHYSICS TESTS
			--------------------------------------------------
			
			local devFlyEnabled = false
			local devFlyConnection = nil
			local devInputConnection = nil
			local devCameraConnection = nil
			
			local devVerticalInput = 0
			local devFlyHeight = 62
			
			local DEV_CAMERA_POSITION =
			    Vector3.new(
			        -73,
			        62,
			        4923
			    )
			
			local DEV_FLY_SPEED = 32
			
			local function RequireDevMode()
			    if DEV_TEST_MODE then
			        return true
			    end
			
			    Notify(
			        "Developer",
			        "Dev mode is disabled.",
			        4
			    )
			
			    return false
			end
			
			local DevGravityOriginal = nil
			
			local function RestoreGravity()
			    if DevGravityOriginal ~= nil
			        and GravityLocks <= 0
			    then
			        Workspace.Gravity =
			            DevGravityOriginal
			
			        DevGravityOriginal =
			            nil
			    end
			
			    StopGravityEnforcer()
			end
			
			local function SetDevGravity0(enabled)
			    if not RequireDevMode() then
			        return
			    end
			
			    devGravity0Enabled =
			        enabled == true
			
			    if devGravity0Enabled then
			        if DevGravityOriginal == nil then
			            DevGravityOriginal =
			                Workspace.Gravity
			        end
			
			        StartGravityEnforcer()
			        Workspace.Gravity = 0
			    else
			        RestoreGravity()
			    end
			
			    Notify(
			        "Dev Physics",
			        devGravity0Enabled
			            and "Gravity set to 0."
			            or "Gravity restored.",
			        3
			    )
			end
			
			UtilityTab:CreateToggle({
			    Name = "Dev Gravity 0",
			
			    Default = false,
			    Flag = "DevGravity0",
			
			    Callback = function(enabled)
			        SetDevGravity0(
			            enabled
			        )
			    end,
			})
			
			--------------------------------------------------
			-- TEST CAMERA
			--------------------------------------------------
			
			local devCameraEnabled = false
			local devCameraRender = nil
			local devCameraInputBegan = nil
			local devCameraInputEnded = nil
			local devCameraMouse = nil
			local devCameraPosition =
			    Vector3.new(
			        -73,
			        62,
			        4923
			    )
			local devCameraYaw = 0
			local devCameraPitch = math.rad(-5)
			local devCameraKeys = {}
			
			local DEV_CAMERA_SPEED = 28
			local DEV_CAMERA_FAST_SPEED = 65
			local DEV_CAMERA_SENSITIVITY = 0.0025
			
			local function StopDevCamera()
			    devCameraEnabled = false
			
			    if devCameraRender then
			        devCameraRender:Disconnect()
			        devCameraRender = nil
			    end
			
			    if devCameraInputBegan then
			        devCameraInputBegan:Disconnect()
			        devCameraInputBegan = nil
			    end
			
			    if devCameraInputEnded then
			        devCameraInputEnded:Disconnect()
			        devCameraInputEnded = nil
			    end
			
			    if devCameraMouse then
			        devCameraMouse:Disconnect()
			        devCameraMouse = nil
			    end
			
			    table.clear(devCameraKeys)
			
			    UserInputService.MouseBehavior =
			        Enum.MouseBehavior.Default
			    UserInputService.MouseIconEnabled = true
			
			    local camera =
			        Workspace.CurrentCamera
			
			    if camera then
			        camera.CameraType =
			            Enum.CameraType.Custom
			
			        local humanoid =
			            GetHumanoid()
			
			        if humanoid then
			            camera.CameraSubject =
			                humanoid
			        end
			    end
			end
			
			local function StartDevCamera()
			    if not RequireDevMode() then
			        return
			    end
			
			    StopDevCamera()
			
			    local camera =
			        Workspace.CurrentCamera
			
			    if not camera then
			        Notify(
			            "Dev Camera",
			            "CurrentCamera is unavailable.",
			            3
			        )
			        return
			    end
			
			    devCameraEnabled = true
			    devCameraPosition =
			        Vector3.new(
			            -73,
			            62,
			            4923
			        )
			
			    local look =
			        camera.CFrame.LookVector
			
			    devCameraYaw =
			        math.atan2(
			            -look.X,
			            -look.Z
			        )
			
			    devCameraPitch =
			        math.asin(
			            math.clamp(
			                look.Y,
			                -0.98,
			                0.98
			            )
			        )
			
			    camera.CameraType =
			        Enum.CameraType.Scriptable
			
			    camera.CFrame =
			        CFrame.new(
			            devCameraPosition
			        )
			        * CFrame.Angles(
			            devCameraPitch,
			            devCameraYaw,
			            0
			        )
			
			    devCameraInputBegan =
			        UserInputService.InputBegan:Connect(
			            function(input, processed)
			                if processed then
			                    return
			                end
			
			                if input.UserInputType
			                    == Enum.UserInputType.Keyboard
			                then
			                    devCameraKeys[
			                        input.KeyCode
			                    ] = true
			                end
			            end
			        )
			
			    devCameraInputEnded =
			        UserInputService.InputEnded:Connect(
			            function(input)
			                if input.UserInputType
			                    == Enum.UserInputType.Keyboard
			                then
			                    devCameraKeys[
			                        input.KeyCode
			                    ] = nil
			                end
			            end
			        )
			
			    devCameraMouse =
			        UserInputService.InputChanged:Connect(
			            function(input)
			                if not devCameraEnabled then
			                    return
			                end
			
			                if input.UserInputType
			                    == Enum.UserInputType.MouseMovement
			                then
			                    devCameraYaw -=
			                        input.Delta.X
			                        * DEV_CAMERA_SENSITIVITY
			
			                    devCameraPitch -=
			                        input.Delta.Y
			                        * DEV_CAMERA_SENSITIVITY
			
			                    devCameraPitch =
			                        math.clamp(
			                            devCameraPitch,
			                            math.rad(-89),
			                            math.rad(89)
			                        )
			                end
			            end
			        )
			
			    UserInputService.MouseBehavior =
			        Enum.MouseBehavior.LockCurrentPosition
			    UserInputService.MouseIconEnabled = false
			
			    devCameraRender =
			        RunService.RenderStepped:Connect(
			            function(dt)
			                if not devCameraEnabled then
			                    return
			                end
			
			                local cameraNow =
			                    Workspace.CurrentCamera
			
			                if not cameraNow then
			                    return
			                end
			
			                local forward =
			                    Vector3.new(
			                        -math.sin(
			                            devCameraYaw
			                        ),
			                        0,
			                        -math.cos(
			                            devCameraYaw
			                        )
			                    )
			
			                local right =
			                    Vector3.new(
			                        math.cos(
			                            devCameraYaw
			                        ),
			                        0,
			                        -math.sin(
			                            devCameraYaw
			                        )
			                    )
			
			                local move =
			                    Vector3.zero
			
			                if devCameraKeys[
			                    Enum.KeyCode.W
			                ] then
			                    move += forward
			                end
			
			                if devCameraKeys[
			                    Enum.KeyCode.S
			                ] then
			                    move -= forward
			                end
			
			                if devCameraKeys[
			                    Enum.KeyCode.D
			                ] then
			                    move += right
			                end
			
			                if devCameraKeys[
			                    Enum.KeyCode.A
			                ] then
			                    move -= right
			                end
			
			                if devCameraKeys[
			                    Enum.KeyCode.E
			                ] then
			                    move += Vector3.yAxis
			                end
			
			                if devCameraKeys[
			                    Enum.KeyCode.Q
			                ] then
			                    move -= Vector3.yAxis
			                end
			
			                if move.Magnitude > 0 then
			                    local speed =
			                        devCameraKeys[
			                            Enum.KeyCode.LeftShift
			                        ]
			                        and DEV_CAMERA_FAST_SPEED
			                        or DEV_CAMERA_SPEED
			
			                    devCameraPosition +=
			                        move.Unit
			                        * speed
			                        * dt
			                end
			
			                cameraNow.CFrame =
			                    CFrame.new(
			                        devCameraPosition
			                    )
			                    * CFrame.Angles(
			                        devCameraPitch,
			                        devCameraYaw,
			                        0
			                    )
			            end
			        )
			
			    Notify(
			        "Dev Camera",
			        "Enabled at -73, 62, 4923.\n"
			            .. "Mouse = look • WASD = move\n"
			            .. "Q/E = down/up • Shift = fast",
			        5
			    )
			end
			
			UtilityTab:CreateToggle({
			    Name = "Dev Camera",
			    Default = false,
			    Flag = "DevCamera",
			    Callback = function(enabled)
			        if enabled then
			            StartDevCamera()
			        else
			            StopDevCamera()
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Dev Camera Position",
			    Callback = function()
			        StartDevCamera()
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Reset Dev Camera",
			    Callback = function()
			        StopDevCamera()
			    end,
			})
			
			--------------------------------------------------
			-- DEV FLY
			--------------------------------------------------
			
			local function StopDevFly()
			    devFlyEnabled = false
			    devVerticalInput = 0
			
			    if devFlyConnection then
			        devFlyConnection:Disconnect()
			        devFlyConnection = nil
			    end
			
			    if devInputConnection then
			        devInputConnection:Disconnect()
			        devInputConnection = nil
			    end
			
			    local humanoid =
			        GetHumanoid()
			
			    if humanoid then
			        humanoid.AutoRotate = true
			
			        pcall(function()
			            humanoid.PlatformStand = false
			            humanoid:ChangeState(
			                Enum.HumanoidStateType.GettingUp
			            )
			        end)
			    end
			
			    local root =
			        GetRoot()
			
			    if root then
			        root.AssemblyLinearVelocity =
			            Vector3.zero
			
			        root.AssemblyAngularVelocity =
			            Vector3.zero
			    end
			end
			
			local function StartDevFly()
			    if not RequireDevMode() then
			        return
			    end
			
			    StopDevFly()
			
			    local root =
			        GetRoot()
			
			    local humanoid =
			        GetHumanoid()
			
			    if not root or not humanoid then
			        Notify(
			            "Dev Fly",
			            "Character is not ready.",
			            3
			        )
			        return
			    end
			
			    devFlyEnabled = true
			    devFlyHeight =
			        root.Position.Y
			
			    humanoid.AutoRotate = false
			    humanoid.PlatformStand = false
			
			    -- Keep the normal character WalkSpeed.
			    local flySpeed =
			        math.max(
			            1,
			            tonumber(
			                humanoid.WalkSpeed
			            )
			            or 16
			        )
			
			    -- Force the falling animation/state while we hold the
			    -- character at a fixed altitude.
			    pcall(function()
			        humanoid:ChangeState(
			            Enum.HumanoidStateType.Freefall
			        )
			    end)
			
			    devInputConnection =
			        UserInputService.InputBegan:Connect(
			            function(input, processed)
			                if processed or not devFlyEnabled then
			                    return
			                end
			
			                if input.KeyCode ==
			                    Enum.KeyCode.Q
			                then
			                    devVerticalInput = -1
			
			                elseif input.KeyCode ==
			                    Enum.KeyCode.E
			                then
			                    devVerticalInput = 1
			                end
			            end
			        )
			
			    devFlyConnection =
			        RunService.RenderStepped:Connect(
			            function(dt)
			                if not devFlyEnabled then
			                    return
			                end
			
			                local currentRoot =
			                    GetRoot()
			
			                if not currentRoot then
			                    return
			                end
			
			                local currentHumanoid =
			                    GetHumanoid()
			
			                local currentSpeed =
			                    math.max(
			                        1,
			                        tonumber(
			                            currentHumanoid
			                            and currentHumanoid.WalkSpeed
			                        )
			                        or flySpeed
			                    )
			
			                devFlyHeight +=
			                    (
			                        devVerticalInput
			                        * currentSpeed
			                        * dt
			                    )
			
			                local current =
			                    currentRoot.Position
			
			                currentRoot.CFrame =
			                    CFrame.new(
			                        current.X,
			                        devFlyHeight,
			                        current.Z
			                    )
			
			                currentRoot.AssemblyLinearVelocity =
			                    Vector3.zero
			
			                currentRoot.AssemblyAngularVelocity =
			                    Vector3.zero
			
			                pcall(function()
			                    currentHumanoid:ChangeState(
			                        Enum.HumanoidStateType.Freefall
			                    )
			                end)
			            end
			        )
			
			    Notify(
			        "Dev Fly",
			        "Hover enabled.\n"
			            .. "Speed = WalkSpeed\n"
			            .. "Hold E to rise • Q to descend\n"
			            .. "Freefall animation is kept active.",
			        5
			    )
			end
			
			UserInputService.InputEnded:Connect(
			    function(input)
			        if
			            input.KeyCode ==
			                Enum.KeyCode.Q
			            or
			            input.KeyCode ==
			                Enum.KeyCode.E
			        then
			            devVerticalInput = 0
			        end
			    end
			)
			
			--------------------------------------------------
			-- TEST PRESETS
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Quick Tests"
			)
			
			UtilityTab:CreateButton({
			    Name = "Start Both Auto Win",
			
			    Callback = function()
			        if not RequireDevMode() then
			            return
			        end
			
			        StartAutoWinTest(
			            "World1"
			        )
			
			        StartAutoWinTest(
			            "World2"
			        )
			
			        Notify(
			            "Auto Win Dev",
			            "Both dev tests started.",
			            3
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Stop All Developers",
			
			    Callback = function()
			        StopAllDevTests()
			        StopDevFly()
			        StopDevCamera()
			
			        StopTreadmillLock(
			            "World1"
			        )
			
			        StopTreadmillLock(
			            "World2"
			        )
			
			        devGravity0Enabled =
			            false
			
			        RestoreGravity()
			
			        Notify(
			            "Developers",
			            "All dev test systems stopped.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- TREADMILL DEV
			--------------------------------------------------
			
			local TreadmillProfiles = {
			    -- Coordinates supplied by the user:
			    -- World 1 = second screenshot
			    World1 = Vector3.new(
			        -40,
			        13,
			        -163
			    ),
			
			    -- World 2 = first screenshot
			    World2 = Vector3.new(
			        -60,
			        13,
			        4837
			    ),
			}
			
			local treadmillLocks = {
			    World1 = false,
			    World2 = false,
			}
			
			local treadmillConnections = {
			    World1 = nil,
			    World2 = nil,
			}
			
			local treadmillTweening = {
			    World1 = false,
			    World2 = false,
			}
			
			local TREADMILL_TWEEN_TIME =
			    0.35
			
			local TREADMILL_CHECK_INTERVAL =
			    0.15
			
			local function GetRootSafe()
			    local character =
			        LocalPlayer.Character
			
			    if not character then
			        return nil
			    end
			
			    return character:FindFirstChild(
			        "HumanoidRootPart"
			    )
			end
			
			local function TweenCharacterTo(
			    position,
			    worldName,
			    duration
			)
			    if not RequireDevMode() then
			        return false
			    end
			
			    local root =
			        GetRootSafe()
			
			    if not root then
			        return false
			    end
			
			    if treadmillTweening[worldName] then
			        return false
			    end
			
			    treadmillTweening[worldName] =
			        true
			
			    local target =
			        CFrame.new(position)
			
			    local tween =
			        TweenService:Create(
			            root,
			            TweenInfo.new(
			                duration
			                    or TREADMILL_TWEEN_TIME,
			                Enum.EasingStyle.Linear,
			                Enum.EasingDirection.InOut
			            ),
			            {
			                CFrame =
			                    target
			            }
			        )
			
			    tween:Play()
			
			    tween.Completed:Wait()
			
			    treadmillTweening[worldName] =
			        false
			
			    return true
			end
			
			local function StopTreadmillLock(
			    worldName
			)
			    treadmillLocks[worldName] =
			        false
			
			    local thread =
			        treadmillConnections[worldName]
			
			    if thread
			        and task.cancel
			    then
			        pcall(function()
			            task.cancel(
			                thread
			            )
			        end)
			
			        treadmillConnections[worldName] =
			            nil
			    end
			
			    treadmillTweening[worldName] =
			        false
			end
			
			local function StartTreadmillLock(
			    worldName
			)
			    if not RequireDevMode() then
			        return
			    end
			
			    StopTreadmillLock(
			        worldName
			    )
			
			    treadmillLocks[worldName] =
			        true
			
			    local target =
			        TreadmillProfiles[worldName]
			
			    treadmillConnections[worldName] =
			        task.spawn(
			            function()
			                while treadmillLocks[worldName] do
			                    local root =
			                        GetRootSafe()
			
			                    if root then
			                        local distance =
			                            (
			                                root.Position
			                                - target
			                            ).Magnitude
			
			                        if distance >= 1 then
			                            pcall(function()
			                                TweenCharacterTo(
			                                    target,
			                                    worldName,
			                                    TREADMILL_TWEEN_TIME
			                                )
			                            end)
			                        end
			                    end
			
			                    task.wait(
			                        TREADMILL_CHECK_INTERVAL
			                    )
			                end
			            end
			        )
			
			    Notify(
			        "Treadmill Dev",
			        worldName
			            .. " lock enabled.\n"
			            .. "Target: "
			            .. string.format(
			                "%.0f, %.0f, %.0f",
			                target.X,
			                target.Y,
			                target.Z
			            ),
			        3
			    )
			end
			
			UtilityTab:CreateSection(
			    "Treadmill Dev"
			)
			
			UtilityTab:CreateParagraph({
			    Title =
			        "🌸 Treadmill Position Lock",
			
			    Content =
			        "Tweens the character to the configured treadmill "
			        .. "position and returns it whenever it moves 1+ stud away.",
			})
			
			--------------------------------------------------
			-- WORLD 1
			--------------------------------------------------
			
			UtilityTab:CreateButton({
			    Name =
			        "World 1 Tween to Treadmill",
			
			    Callback = function()
			        task.spawn(function()
			            TweenCharacterTo(
			                TreadmillProfiles.World1,
			                "World1",
			                TREADMILL_TWEEN_TIME
			            )
			        end)
			    end,
			})
			
			UtilityTab:CreateToggle({
			    Name =
			        "World 1 Treadmill Lock",
			
			    Default = false,
			
			    Flag =
			        "World1TreadmillLock",
			
			    Callback = function(enabled)
			        if enabled then
			            StartTreadmillLock(
			                "World1"
			            )
			        else
			            StopTreadmillLock(
			                "World1"
			            )
			
			            Notify(
			                "Treadmill Dev",
			                "World 1 lock disabled.",
			                2
			            )
			        end
			    end,
			})
			
			--------------------------------------------------
			-- WORLD 2
			--------------------------------------------------
			
			UtilityTab:CreateButton({
			    Name =
			        "World 2 Tween to Treadmill",
			
			    Callback = function()
			        task.spawn(function()
			            TweenCharacterTo(
			                TreadmillProfiles.World2,
			                "World2",
			                TREADMILL_TWEEN_TIME
			            )
			        end)
			    end,
			})
			
			UtilityTab:CreateToggle({
			    Name =
			        "World 2 Treadmill Lock",
			
			    Default = false,
			
			    Flag =
			        "World2TreadmillLock",
			
			    Callback = function(enabled)
			        if enabled then
			            StartTreadmillLock(
			                "World2"
			            )
			        else
			            StopTreadmillLock(
			                "World2"
			            )
			
			            Notify(
			                "Treadmill Dev",
			                "World 2 lock disabled.",
			                2
			            )
			        end
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name =
			        "Stop Treadmill Locks",
			
			    Callback = function()
			        StopTreadmillLock(
			            "World1"
			        )
			
			        StopTreadmillLock(
			            "World2"
			        )
			
			        Notify(
			            "Treadmill Dev",
			            "All treadmill locks stopped.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- DIAGNOSTICS
			--------------------------------------------------
			
			UtilityTab:CreateSection(
			    "Diagnostics"
			)
			
			UtilityTab:CreateButton({
			    Name = "Check Worlds",
			
			    Callback = function()
			        Notify(
			            "Workspace",
			            "World1: "
			                .. tostring(
			                    Workspace:FindFirstChild(
			                        "World1"
			                    ) ~= nil
			                )
			                .. "\nWorld2: "
			                .. tostring(
			                    Workspace:FindFirstChild(
			                        "World2"
			                    ) ~= nil
			                ),
			            4
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Check Character",
			
			    Callback = function()
			        local character =
			            LocalPlayer.Character
			
			        Notify(
			            "Character Diagnostics",
			            "Character: "
			                .. tostring(
			                    character ~= nil
			                )
			                .. "\nHumanoid: "
			                .. tostring(
			                    character
			                    and character:FindFirstChildOfClass(
			                        "Humanoid"
			                    ) ~= nil
			                )
			                .. "\nRoot: "
			                .. tostring(
			                    character
			                    and character:FindFirstChild(
			                        "HumanoidRootPart"
			                    ) ~= nil
			                ),
			            4
			        )
			    end,
			})
			
			UtilityTab:CreateButton({
			    Name = "Copy Position",
			
			    Callback = function()
			        local position =
			            GetPosition()
			
			        if position then
			            SetClipboard(
			                string.format(
			                    "%.3f, %.3f, %.3f",
			                    position.X,
			                    position.Y,
			                    position.Z
			                )
			            )
			
			            Notify(
			                "Clipboard",
			                "Position copied.",
			                2
			            )
			        end
			    end,
			})
			
			--------------------------------------------------
			-- FINALIZE
			--------------------------------------------------
			
			Window:SetAutoSave(
			    true
			)
			
			Notify(
			    "🌸 Lilac v1488",
			    "All modules loaded successfully.",
			    4
			)
			
			print(
			    "[Lilac v1488] Loaded successfully"
			)
		end)(unpack(_vararg))
	end,
}

_modules["UI/UI.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function()
			local Obsidian = require(
			    "Core/Obsidian"
			)
			
			local UI = {}
			
			function UI.Create()
			    local Window =
			        Obsidian.new(
			            "ZenWare V3",
			            "ZenWareConfigs"
			        )
			
			    Window:SetToggleKey(
			        Enum.KeyCode.RightControl
			    )
			
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
end)(require or function() end)