
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
			    local source = game:HttpGet(REPO .. "Library.lua")
			    return loadstring(source)()
			end
			
			function Obsidian.new(title, configFolder)
			    local Library = loadLibrary()
			
			    Library.ForceCheckbox = false
			    Library.ShowToggleFrameInKeybinds = true
			
			    local Window = Library:CreateWindow({
			        Title = title or "ZenWare V3",
			        Footer = "ZenWare V3",
			        Icon = LOGO,
			
			        NotifySide = "Right",
			
			        ShowCustomCursor = true,
			        AutoShow = true,
			        Resizable = true,
			        Center = true,
			
			        Glow = true,
			        GlobalSearch = true,
			    })
			
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
			            local Tab = self.Window.Window:AddTab(
			                tabName,
			                icon
			            )
			
			            local ZenTab = {
			                Tab = Tab,
			                Group = nil,
			            }
			
			            --------------------------------------------------
			            -- ENSURE GROUP
			            --------------------------------------------------
			
			            function ZenTab:_EnsureGroup(name, icon)
			                if self.Group then
			                    return self.Group
			                end
			
			                local groupName =
			                    name or "General"
			
			                if icon then
			                    self.Group =
			                        self.Tab:AddLeftGroupbox(
			                            groupName,
			                            icon
			                        )
			                else
			                    self.Group =
			                        self.Tab:AddLeftGroupbox(
			                            groupName
			                        )
			                end
			
			                return self.Group
			            end
			
			            --------------------------------------------------
			            -- SECTION
			            --------------------------------------------------
			
			            function ZenTab:CreateSection(name, icon)
			                self.Group = nil
			
			                return self:_EnsureGroup(
			                    name,
			                    icon
			                )
			            end
			
			            --------------------------------------------------
			            -- BUTTON
			            --------------------------------------------------
			
			            function ZenTab:CreateButton(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section or "Actions"
			                    )
			
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
			
			            function ZenTab:CreateToggle(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section or "Options"
			                    )
			
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
			
			            function ZenTab:CreateSlider(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section or "Options"
			                    )
			
			                return Group:AddSlider(
			                    config.Flag
			                        or config.Name
			                        or "Slider",
			
			                    {
			                        Text =
			                            config.Name
			                            or "Slider",
			
			                        Default =
			                            tonumber(
			                                config.Default
			                            )
			                            or 0,
			
			                        Min =
			                            tonumber(
			                                config.Min
			                            )
			                            or 0,
			
			                        Max =
			                            tonumber(
			                                config.Max
			                            )
			                            or 100,
			
			                        Rounding =
			                            tonumber(
			                                config.Rounding
			                            )
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
			
			            function ZenTab:CreateTextBox(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section or "Input"
			                    )
			
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
			                                tostring(
			                                    config.Default
			                                    or ""
			                                ),
			
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
			
			            function ZenTab:CreateKeybind(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section
			                            or "Keybinds"
			                    )
			
			                local defaultKey =
			                    config.Default
			                    or Enum.KeyCode.F
			
			                if typeof(defaultKey)
			                    == "EnumItem"
			                then
			                    defaultKey =
			                        defaultKey.Name
			                elseif
			                    type(defaultKey)
			                    ~= "string"
			                then
			                    defaultKey = "F"
			                end
			
			                local label =
			                    Group:AddLabel(
			                        config.Name
			                            or "Keybind"
			                    )
			
			                return label:AddKeyPicker(
			                    config.Flag
			                        or config.Name
			                        or "Keybind",
			
			                    {
			                        Default =
			                            defaultKey,
			
			                        Mode = "Toggle",
			
			                        Text =
			                            config.Name
			                            or "Keybind",
			
			                        Callback =
			                            config.Callback,
			                    }
			                )
			            end
			
			            --------------------------------------------------
			            -- COLOR PICKER
			            --------------------------------------------------
			
			            function ZenTab:CreateColorPicker(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section
			                            or "Appearance"
			                    )
			
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
			
			            function ZenTab:CreateParagraph(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section
			                            or "Information"
			                    )
			
			                local title =
			                    tostring(
			                        config.Title
			                        or ""
			                    )
			
			                local content =
			                    tostring(
			                        config.Content
			                        or ""
			                    )
			
			                local text = title
			
			                if content ~= "" then
			                    text =
			                        title
			                        .. "\n"
			                        .. content
			                end
			
			                return Group:AddLabel({
			                    Text = text,
			                    DoesWrap = true,
			                })
			            end
			
			            --------------------------------------------------
			            -- IMAGE
			            --------------------------------------------------
			
			            function ZenTab:CreateImage(config)
			                config = config or {}
			
			                if not config.Image then
			                    return nil
			                end
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section
			                            or "Appearance"
			                    )
			
			                return Group:AddImage(
			                    config.Flag
			                        or config.Name
			                        or "Image",
			
			                    {
			                        Image =
			                            config.Image,
			
			                        Height =
			                            tonumber(
			                                config.Height
			                            )
			                            or 120,
			
			                        Transparency =
			                            tonumber(
			                                config.Transparency
			                            )
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
			
			            function ZenTab:CreateConfigSection()
			                local Group =
			                    self:_EnsureGroup(
			                        "Configuration"
			                    )
			
			                Group:AddLabel(
			                    "Configuration"
			                )
			
			                return Group
			            end
			
			            --------------------------------------------------
			            -- DROPDOWN
			            --------------------------------------------------
			
			            function ZenTab:CreateDropdown(config)
			                config = config or {}
			
			                local Group =
			                    self:_EnsureGroup(
			                        config.Section
			                            or "Options"
			                    )
			
			                return Group:AddDropdown(
			                    config.Flag
			                        or config.Name
			                        or "Dropdown",
			
			                    {
			                        Values =
			                            config.Options
			                            or {},
			
			                        Default =
			                            config.Default,
			
			                        Multi =
			                            config.MultiSelect
			                            == true,
			
			                        Text =
			                            config.Name
			                            or "Dropdown",
			
			                        Callback =
			                            config.Callback,
			                    }
			                )
			            end
			
			            return ZenTab
			        end
			
			        return Section
			    end
			
			    --------------------------------------------------
			    -- NOTIFY
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
			        local keyName = "RightControl"
			
			        if typeof(key) == "EnumItem" then
			            keyName = key.Name
			        elseif type(key) == "string" then
			            keyName = key
			        end
			
			        if
			            self.Library.Options
			            and self.Library.Options.MenuKeybind
			            and self.Library.Options.MenuKeybind.SetValue
			        then
			            pcall(function()
			                self.Library.Options.MenuKeybind:SetValue({
			                    keyName,
			                    "Toggle",
			                })
			            end)
			
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
			
			local LocalPlayer = Players.LocalPlayer
			
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
			
			MainTab:CreateToggle({
			    Name = "Auto Win (500m)",
			
			    Default = false,
			
			    Flag = "AutoWin",
			
			    Callback = function(enabled)
			        State.AutoWin = enabled
			
			        if enabled then
			            SafeCall(function()
			                Teleports.Win()
			            end)
			
			            Notify(
			                "Auto Win",
			                "Enabled.",
			                2
			            )
			        else
			            Notify(
			                "Auto Win",
			                "Disabled.",
			                2
			            )
			        end
			    end,
			})
			
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
			-- LOOPS
			--------------------------------------------------
			
			MainTab:CreateSection(
			    "Teleport Loops"
			)
			
			MainTab:CreateSlider({
			    Name = "Loop Interval",
			
			    Min = 0.01,
			    Max = 5,
			
			    Default =
			        State.TeleportInterval,
			
			    Flag = "TeleportInterval",
			
			    Callback = function(value)
			        State.TeleportInterval =
			            value
			
			        if State.TeleportLoop then
			            SafeCall(function()
			                Teleports.StartLoop(
			                    Teleports.Locations.Win,
			                    value
			                )
			            end)
			        end
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "Loop Win Teleport",
			
			    Default = false,
			
			    Flag = "TeleportLoop",
			
			    Callback = function(enabled)
			        State.TeleportLoop =
			            enabled
			
			        if enabled then
			            SafeCall(function()
			                Teleports.StartLoop(
			                    Teleports.Locations.Win,
			                    State.TeleportInterval
			                )
			            end)
			        else
			            SafeCall(function()
			                Teleports.StopLoop()
			            end)
			        end
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "Loop Treadmill Teleport",
			
			    Default = false,
			
			    Flag = "TreadmillLoop",
			
			    Callback = function(enabled)
			        State.TreadmillLoop =
			            enabled
			
			        if enabled then
			            SafeCall(function()
			                Teleports.StartLoop(
			                    Teleports.Locations.Treadmill,
			                    State.TeleportInterval
			                )
			            end)
			        else
			            SafeCall(function()
			                Teleports.StopLoop()
			            end)
			        end
			    end,
			})
			
			--------------------------------------------------
			-- ANTI-CHEAT TESTS
			--------------------------------------------------
			
			local DevTests = {
			    World1AutoWin = false,
			    World2AutoWin = false,
			    World1Speed = false,
			    World2Speed = false,
			    World1Teleport = false,
			    World2Teleport = false,
			    World1Repeated = false,
			    World2Repeated = false,
			}
			
			local function SetDevTest(name, enabled)
			    DevTests[name] = enabled == true
			
			    Notify(
			        "Anti-Cheat Tests",
			        tostring(name)
			            .. (enabled and " enabled." or " disabled."),
			        2
			    )
			end
			
			MainTab:CreateSection(
			    "Anti-Cheat Tests"
			)
			
			MainTab:CreateParagraph({
			    Title = "Client Test Controls",
			
			    Content =
			        "Checkbox-based test controls.\n"
			        .. "No server test object is required.\n"
			        .. "Use these toggles to keep the selected "
			        .. "test profile active while you inspect "
			        .. "your client-side telemetry and logs.",
			})
			
			MainTab:CreateSection(
			    "World 1"
			)
			
			MainTab:CreateToggle({
			    Name = "World 1 Auto Win Test",
			    Default = false,
			    Flag = "World1AutoWinTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World1AutoWin",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 1 Speed Test",
			    Default = false,
			    Flag = "World1SpeedTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World1Speed",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 1 Teleport Test",
			    Default = false,
			    Flag = "World1TeleportTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World1Teleport",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 1 Repeated Test",
			    Default = false,
			    Flag = "World1RepeatedTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World1Repeated",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateSection(
			    "World 2"
			)
			
			MainTab:CreateToggle({
			    Name = "World 2 Auto Win Test",
			    Default = false,
			    Flag = "World2AutoWinTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World2AutoWin",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 2 Speed Test",
			    Default = false,
			    Flag = "World2SpeedTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World2Speed",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 2 Teleport Test",
			    Default = false,
			    Flag = "World2TeleportTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World2Teleport",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateToggle({
			    Name = "World 2 Repeated Test",
			    Default = false,
			    Flag = "World2RepeatedTest",
			
			    Callback = function(enabled)
			        SetDevTest(
			            "World2Repeated",
			            enabled
			        )
			    end,
			})
			
			MainTab:CreateSection(
			    "Test Status"
			)
			
			MainTab:CreateButton({
			    Name = "World 1 Test Status",
			
			    Callback = function()
			        Notify(
			            "World 1 Tests",
			            "Auto Win: "
			                .. tostring(DevTests.World1AutoWin)
			                .. "\nSpeed: "
			                .. tostring(DevTests.World1Speed)
			                .. "\nTeleport: "
			                .. tostring(DevTests.World1Teleport)
			                .. "\nRepeated: "
			                .. tostring(DevTests.World1Repeated),
			            5
			        )
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "World 2 Test Status",
			
			    Callback = function()
			        Notify(
			            "World 2 Tests",
			            "Auto Win: "
			                .. tostring(DevTests.World2AutoWin)
			                .. "\nSpeed: "
			                .. tostring(DevTests.World2Speed)
			                .. "\nTeleport: "
			                .. tostring(DevTests.World2Teleport)
			                .. "\nRepeated: "
			                .. tostring(DevTests.World2Repeated),
			            5
			        )
			    end,
			})
			
			MainTab:CreateButton({
			    Name = "Disable All Tests",
			
			    Callback = function()
			        for name in pairs(DevTests) do
			            DevTests[name] = false
			        end
			
			        Notify(
			            "Anti-Cheat Tests",
			            "All test toggles disabled.",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
			-- AUTO REBIRTH
			--------------------------------------------------
			
			local RebirthSection =
			    Window:CreateSection(
			        "Auto Rebirth"
			    )
			
			local RebirthTab =
			    RebirthSection:CreateTab(
			        "Auto Rebirth",
			        "refresh-cw"
			    )
			
			local rebirthRunning = false
			
			local function GetRebirthButton()
			    local player =
			        Players.LocalPlayer
			
			    if not player then
			        return nil
			    end
			
			    local playerGui =
			        player:FindFirstChild(
			            "PlayerGui"
			        )
			
			    if not playerGui then
			        return nil
			    end
			
			    local mainGui =
			        playerGui:FindFirstChild(
			            "MainGui"
			        )
			
			    if not mainGui then
			        return nil
			    end
			
			    local frames =
			        mainGui:FindFirstChild(
			            "Frames"
			        )
			
			    if not frames then
			        return nil
			    end
			
			    local rebirthFrame =
			        frames:FindFirstChild(
			            "Rebirth"
			        )
			
			    if not rebirthFrame then
			        return nil
			    end
			
			    return rebirthFrame:FindFirstChild(
			        "Rebirth"
			    )
			end
			
			RebirthTab:CreateSection(
			    "Rebirth"
			)
			
			RebirthTab:CreateSlider({
			    Name = "Rebirth Interval",
			
			    Min = 0.05,
			    Max = 2,
			
			    Default = 0.25,
			
			    Flag = "RebirthInterval",
			
			    Callback = function(value)
			        State.RebirthInterval =
			            value
			    end,
			})
			
			RebirthTab:CreateToggle({
			    Name = "Auto Rebirth",
			
			    Default = false,
			
			    Flag = "AutoRebirth",
			
			    Callback = function(enabled)
			        State.AutoRebirth =
			            enabled
			
			        if not enabled then
			            rebirthRunning =
			                false
			
			            return
			        end
			
			        if rebirthRunning then
			            return
			        end
			
			        rebirthRunning =
			            true
			
			        task.spawn(function()
			            while
			                State.AutoRebirth
			                and rebirthRunning
			            do
			                local button =
			                    GetRebirthButton()
			
			                if button then
			                    pcall(function()
			                        firesignal(
			                            button.MouseButton1Click
			                        )
			                    end)
			                end
			
			                task.wait(
			                    State.RebirthInterval
			                    or 0.25
			                )
			            end
			
			            rebirthRunning =
			                false
			        end)
			    end,
			})
			
			RebirthTab:CreateButton({
			    Name = "Test Rebirth Once",
			
			    Callback = function()
			        local button =
			            GetRebirthButton()
			
			        if not button then
			            Notify(
			                "Rebirth",
			                "Button not found.",
			                3
			            )
			
			            return
			        end
			
			        pcall(function()
			            firesignal(
			                button.MouseButton1Click
			            )
			        end)
			    end,
			})
			
			--------------------------------------------------
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
			-- AUTO CLICKER
			--------------------------------------------------
			
			local ClickSection =
			    Window:CreateSection(
			        "Auto Clicker"
			    )
			
			local ClickTab =
			    ClickSection:CreateTab(
			        "Auto Clicker",
			        "mouse-pointer"
			    )
			
			ClickTab:CreateSection(
			    "Clicker"
			)
			
			ClickTab:CreateSlider({
			    Name = "Clicks Per Second",
			
			    Min = 1,
			    Max = 100,
			
			    Default =
			        State.AutoClickerSpeed,
			
			    Flag = "AutoClickerSpeed",
			
			    Callback = function(value)
			        State.AutoClickerSpeed =
			            value
			
			        if State.AutoClicker then
			            SafeCall(function()
			                AutoClicker.Start(
			                    value
			                )
			            end)
			        end
			    end,
			})
			
			SafeCall(function()
			    AutoClicker.SetCallback(
			        function()
			            Remotes.Fire(
			                "Click"
			            )
			        end
			    )
			end)
			
			ClickTab:CreateToggle({
			    Name = "Enable Auto Clicker",
			
			    Default = false,
			
			    Flag = "AutoClicker",
			
			    Callback = function(enabled)
			        State.AutoClicker =
			            enabled
			
			        if enabled then
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
			
			ClickTab:CreateKeybind({
			    Name = "Pause / Resume",
			
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
			
			ClickTab:CreateButton({
			    Name = "Start Clicker",
			
			    Callback = function()
			        State.AutoClicker =
			            true
			
			        SafeCall(function()
			            AutoClicker.Start(
			                State.AutoClickerSpeed
			            )
			        end)
			    end,
			})
			
			ClickTab:CreateButton({
			    Name = "Stop Clicker",
			
			    Callback = function()
			        State.AutoClicker =
			            false
			
			        SafeCall(function()
			            AutoClicker.Stop()
			        end)
			    end,
			})
			
			--------------------------------------------------
			-- AUTO MOG
			--------------------------------------------------
			
			local MogSection =
			    Window:CreateSection(
			        "Auto Mog"
			    )
			
			local MogTab =
			    MogSection:CreateTab(
			        "Auto Mog",
			        "swords"
			    )
			
			MogTab:CreateSection(
			    "Target"
			)
			
			local targetBox =
			    MogTab:CreateTextBox({
			        Name = "Player",
			        Placeholder = "Player username",
			    })
			
			MogTab:CreateButton({
			    Name = "Mog Target",
			
			    Callback = function()
			        local username =
			            targetBox:GetText()
			
			        if username == "" then
			            return
			        end
			
			        State.CurrentTarget =
			            username
			
			        State.AutoMog =
			            true
			
			        SafeCall(function()
			            AutoMog.Start(
			                username
			            )
			        end)
			    end,
			})
			
			MogTab:CreateButton({
			    Name = "Auto Mog All",
			
			    Callback = function()
			        State.AutoMogAll =
			            true
			
			        SafeCall(function()
			            AutoMog.StartAll()
			        end)
			    end,
			})
			
			MogTab:CreateButton({
			    Name = "Stop Mog",
			
			    Callback = function()
			        State.AutoMog =
			            false
			
			        State.AutoMogAll =
			            false
			
			        SafeCall(function()
			            AutoMog.Stop()
			        end)
			    end,
			})
			
			MogTab:CreateButton({
			    Name = "Clear Target",
			
			    Callback = function()
			        targetBox:SetText("")
			        State.CurrentTarget =
			            nil
			    end,
			})
			
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
			
			--------------------------------------------------
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
			
			ConfigTab:CreateSection(
			    "Configuration"
			)
			
			ConfigTab:CreateConfigSection()
			
			ConfigTab:CreateParagraph({
			    Title =
			        "ZenWare Configs",
			
			    Content =
			        "Configuration controls "
			        .. "are provided by the UI core.",
			})
			
			ConfigTab:CreateButton({
			    Name = "Configuration Status",
			
			    Callback = function()
			        Notify(
			            "Configs",
			            "ZenWareConfigs",
			            3
			        )
			    end,
			})
			
			--------------------------------------------------
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
			-- FINALIZE
			--------------------------------------------------
			
			Window:SetAutoSave(
			    true
			)
			
			Notify(
			    "ZenWare V3",
			    "All modules loaded successfully.",
			    4
			)
			
			print(
			    "[ZenWare V3] Loaded successfully"
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