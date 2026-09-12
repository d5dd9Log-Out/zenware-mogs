
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
			            -- CREATE SECTION / GROUPBOX
			            --------------------------------------------------
			
			            function ZenTab:CreateSection(name, icon)
			                local Group
			
			                if icon then
			                    Group = self.Tab:AddLeftGroupbox(
			                        name,
			                        icon
			                    )
			                else
			                    Group = self.Tab:AddLeftGroupbox(
			                        name
			                    )
			                end
			
			                self.Group = Group
			
			                return Group
			            end
			
			            --------------------------------------------------
			            -- GET GROUP
			            --------------------------------------------------
			
			            local function getGroup(self)
			                return self.Group
			            end
			
			            --------------------------------------------------
			            -- BUTTON
			            --------------------------------------------------
			
			            function ZenTab:CreateButton(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                return Group:AddButton({
			                    Text = config.Name or "Button",
			                    Func = config.Callback,
			                })
			            end
			
			            --------------------------------------------------
			            -- TOGGLE
			            --------------------------------------------------
			
			            function ZenTab:CreateToggle(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                return Group:AddToggle(
			                    config.Flag
			                        or config.Name
			                        or "Toggle",
			                    {
			                        Text = config.Name or "Toggle",
			                        Default = config.Default == true,
			                        Callback = config.Callback,
			                    }
			                )
			            end
			
			            --------------------------------------------------
			            -- SLIDER
			            --------------------------------------------------
			
			            function ZenTab:CreateSlider(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                return Group:AddSlider(
			                    config.Flag
			                        or config.Name
			                        or "Slider",
			                    {
			                        Text = config.Name or "Slider",
			
			                        Default =
			                            tonumber(config.Default)
			                            or tonumber(config.Min)
			                            or 0,
			
			                        Min =
			                            tonumber(config.Min)
			                            or 0,
			
			                        Max =
			                            tonumber(config.Max)
			                            or 100,
			
			                        Rounding =
			                            tonumber(config.Rounding)
			                            or 2,
			
			                        Compact = false,
			
			                        Callback = config.Callback,
			                    }
			                )
			            end
			
			            --------------------------------------------------
			            -- TEXT BOX
			            --------------------------------------------------
			
			            function ZenTab:CreateTextBox(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return {
			                        GetText = function()
			                            return ""
			                        end,
			
			                        SetText = function()
			                        end,
			
			                        Focus = function()
			                        end,
			                    }
			                end
			
			                local input = Group:AddInput(
			                    config.Flag
			                        or config.Name
			                        or "Input",
			                    {
			                        Text = config.Name or "Input",
			
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
			                    if input and input.Value ~= nil then
			                        return tostring(input.Value)
			                    end
			
			                    return ""
			                end
			
			                function api:SetText(value)
			                    if input and input.SetValue then
			                        input:SetValue(
			                            tostring(value or "")
			                        )
			                    end
			                end
			
			                function api:Focus()
			                    if input and input.Input then
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
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                local defaultKey =
			                    config.Default
			                    or Enum.KeyCode.F
			
			                if typeof(defaultKey) == "EnumItem" then
			                    defaultKey = defaultKey.Name
			                elseif type(defaultKey) ~= "string" then
			                    defaultKey = "F"
			                end
			
			                local label = Group:AddLabel(
			                    config.Name or "Keybind"
			                )
			
			                local keybind = label:AddKeyPicker(
			                    config.Flag
			                        or config.Name
			                        or "Keybind",
			                    {
			                        Default = defaultKey,
			                        Mode = "Toggle",
			                        Text = config.Name or "Keybind",
			                        Callback = config.Callback,
			                    }
			                )
			
			                return keybind
			            end
			
			            --------------------------------------------------
			            -- COLOR PICKER
			            --------------------------------------------------
			
			            function ZenTab:CreateColorPicker(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                local label = Group:AddLabel(
			                    config.Name or "Color"
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
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
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
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
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
			                            tonumber(config.Height)
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
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
			                Group:AddLabel("Configuration")
			
			                return Group
			            end
			
			            --------------------------------------------------
			            -- DROPDOWN
			            --------------------------------------------------
			
			            function ZenTab:CreateDropdown(config)
			                config = config or {}
			
			                local Group = getGroup(self)
			
			                if not Group then
			                    return nil
			                end
			
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
			-- HELPERS
			--------------------------------------------------
			
			local function AddSlider(tab, config)
			    local ok, result = pcall(function()
			        return tab:CreateSlider(config)
			    end)
			
			    if ok then
			        return result
			    end
			
			    local group = tab:CreateSection(
			        config.Section or config.Name or "Slider"
			    )
			
			    if group and group.AddSlider then
			        return group:AddSlider(
			            config.Flag or config.Name or "Slider",
			            {
			                Text = config.Name or "Slider",
			                Default = config.Default or 0,
			                Min = config.Min or 0,
			                Max = config.Max or 100,
			                Rounding = config.Rounding or 2,
			                Callback = config.Callback,
			            }
			        )
			    end
			
			    return nil
			end
			
			local function AddToggle(tab, config)
			    local ok, result = pcall(function()
			        return tab:CreateToggle(config)
			    end)
			
			    if ok then
			        return result
			    end
			
			    local group = tab:CreateSection(
			        config.Section or "Options"
			    )
			
			    if group and group.AddToggle then
			        return group:AddToggle(
			            config.Flag or config.Name or "Toggle",
			            {
			                Text = config.Name or "Toggle",
			                Default = config.Default == true,
			                Callback = config.Callback,
			            }
			        )
			    end
			
			    return nil
			end
			
			local function AddButton(tab, config)
			    local ok, result = pcall(function()
			        return tab:CreateButton(config)
			    end)
			
			    if ok then
			        return result
			    end
			
			    local group = tab:CreateSection(
			        config.Section or "Actions"
			    )
			
			    if group and group.AddButton then
			        return group:AddButton({
			            Text = config.Name or "Button",
			            Func = config.Callback,
			        })
			    end
			
			    return nil
			end
			
			local function AddTextBox(tab, config)
			    local ok, result = pcall(function()
			        return tab:CreateTextBox(config)
			    end)
			
			    if ok then
			        return result
			    end
			
			    local group = tab:CreateSection(
			        config.Section or "Input"
			    )
			
			    if not group or not group.AddInput then
			        return {
			            GetText = function()
			                return ""
			            end,
			
			            SetText = function()
			            end,
			        }
			    end
			
			    local input = group:AddInput(
			        config.Flag or config.Name or "Input",
			        {
			            Text = config.Name or "Input",
			            Placeholder = config.Placeholder or "",
			            Default = config.Default or "",
			            Callback = config.Callback,
			        }
			    )
			
			    return {
			        GetText = function()
			            if input and input.Value ~= nil then
			                return tostring(input.Value)
			            end
			
			            return ""
			        end,
			
			        SetText = function(value)
			            if input and input.SetValue then
			                input:SetValue(
			                    tostring(value or "")
			                )
			            end
			        end,
			    }
			end
			
			local function AddKeybind(tab, config)
			    local ok, result = pcall(function()
			        return tab:CreateKeybind(config)
			    end)
			
			    if ok then
			        return result
			    end
			
			    local group = tab:CreateSection(
			        config.Section or "Keybinds"
			    )
			
			    if not group or not group.AddLabel then
			        return nil
			    end
			
			    local label = group:AddLabel(
			        config.Name or "Keybind"
			    )
			
			    if label and label.AddKeyPicker then
			        return label:AddKeyPicker(
			            config.Flag or config.Name or "Keybind",
			            {
			                Default =
			                    config.Default
			                    or "RightControl",
			
			                Mode = "Toggle",
			
			                Text =
			                    config.Name
			                    or "Keybind",
			
			                Callback = config.Callback,
			            }
			        )
			    end
			
			    return nil
			end
			
			--------------------------------------------------
			-- MAIN
			--------------------------------------------------
			
			local MainSection =
			    Window:CreateSection("Main")
			
			local MainTab =
			    MainSection:CreateTab(
			        "Main",
			        "home"
			    )
			
			MainTab:CreateSection("Win")
			
			AddToggle(MainTab, {
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
			
			AddButton(MainTab, {
			    Name = "Teleport to Win",
			
			    Callback = function()
			        Teleports.Win()
			    end,
			})
			
			AddButton(MainTab, {
			    Name = "Teleport to Treadmill",
			
			    Callback = function()
			        Teleports.Treadmill()
			    end,
			})
			
			MainTab:CreateSection("Loops")
			
			AddSlider(MainTab, {
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
			
			AddToggle(MainTab, {
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
			
			AddToggle(MainTab, {
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
			-- AUTO REBIRTH
			--------------------------------------------------
			
			local RebirthSection =
			    Window:CreateSection("Auto Rebirth")
			
			local RebirthTab =
			    RebirthSection:CreateTab(
			        "Auto Rebirth",
			        "refresh-cw"
			    )
			
			State.AutoRebirth = false
			State.RebirthInterval = 0.25
			
			local rebirthRunning = false
			
			local function GetRebirthButton()
			    local player =
			        game:GetService("Players").LocalPlayer
			
			    if not player then
			        return nil
			    end
			
			    local playerGui =
			        player:FindFirstChild("PlayerGui")
			
			    if not playerGui then
			        return nil
			    end
			
			    local mainGui =
			        playerGui:FindFirstChild("MainGui")
			
			    if not mainGui then
			        return nil
			    end
			
			    local frames =
			        mainGui:FindFirstChild("Frames")
			
			    if not frames then
			        return nil
			    end
			
			    local rebirthFrame =
			        frames:FindFirstChild("Rebirth")
			
			    if not rebirthFrame then
			        return nil
			    end
			
			    return rebirthFrame:FindFirstChild("Rebirth")
			end
			
			RebirthTab:CreateSection("Rebirth")
			
			AddSlider(RebirthTab, {
			    Name = "Rebirth Interval",
			    Min = 0.05,
			    Max = 2,
			    Default = 0.25,
			    Flag = "RebirthInterval",
			
			    Callback = function(value)
			        State.RebirthInterval = value
			    end,
			})
			
			AddToggle(RebirthTab, {
			    Name = "Auto Rebirth",
			    Default = false,
			    Flag = "AutoRebirth",
			
			    Callback = function(enabled)
			        State.AutoRebirth = enabled
			
			        if not enabled then
			            rebirthRunning = false
			            return
			        end
			
			        if rebirthRunning then
			            return
			        end
			
			        rebirthRunning = true
			
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
			
			            rebirthRunning = false
			        end)
			    end,
			})
			
			--------------------------------------------------
			-- TELEPORTS
			--------------------------------------------------
			
			local TeleportSection =
			    Window:CreateSection("Teleports")
			
			local TeleportTab =
			    TeleportSection:CreateTab(
			        "Teleports",
			        "map-pin"
			    )
			
			TeleportTab:CreateSection("Custom XYZ")
			
			local xBox = AddTextBox(TeleportTab, {
			    Name = "X",
			    Placeholder = "X coordinate",
			})
			
			local yBox = AddTextBox(TeleportTab, {
			    Name = "Y",
			    Placeholder = "Y coordinate",
			})
			
			local zBox = AddTextBox(TeleportTab, {
			    Name = "Z",
			    Placeholder = "Z coordinate",
			})
			
			AddButton(TeleportTab, {
			    Name = "Teleport",
			
			    Callback = function()
			        local x =
			            tonumber(xBox:GetText())
			
			        local y =
			            tonumber(yBox:GetText())
			
			        local z =
			            tonumber(zBox:GetText())
			
			        if x and y and z then
			            Teleports.Teleport(
			                Vector3.new(
			                    x,
			                    y,
			                    z
			                )
			            )
			        end
			    end,
			})
			
			TeleportTab:CreateSection(
			    "Saved Locations"
			)
			
			local saveBox = AddTextBox(TeleportTab, {
			    Name = "Location Name",
			    Placeholder = "My Location",
			})
			
			AddButton(TeleportTab, {
			    Name = "Save Current Location",
			
			    Callback = function()
			        local root =
			            Utils.GetRoot()
			
			        local name =
			            saveBox:GetText()
			
			        if root and name ~= "" then
			            Teleports.SaveLocation(
			                name,
			                root.Position,
			                State
			            )
			        end
			    end,
			})
			
			local deleteBox =
			    AddTextBox(TeleportTab, {
			        Name = "Delete Location",
			        Placeholder = "Location Name",
			    })
			
			AddButton(TeleportTab, {
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
			
			local ClickSection =
			    Window:CreateSection(
			        "Auto Clicker"
			    )
			
			local ClickTab =
			    ClickSection:CreateTab(
			        "Auto Clicker",
			        "mouse-pointer"
			    )
			
			ClickTab:CreateSection("Clicker")
			
			State.AutoClickerSpeed =
			    State.AutoClickerSpeed or 10
			
			AddSlider(ClickTab, {
			    Name = "Clicks Per Second",
			
			    Min = 1,
			    Max = 100,
			
			    Default =
			        State.AutoClickerSpeed,
			
			    Flag = "AutoClickerSpeed",
			
			    Callback = function(value)
			        State.AutoClickerSpeed = value
			
			        if State.AutoClicker then
			            AutoClicker.Start(value)
			        end
			    end,
			})
			
			if AutoClicker
			    and AutoClicker.SetCallback
			then
			    AutoClicker.SetCallback(
			        function()
			            Remotes.Fire("Click")
			        end
			    )
			end
			
			AddToggle(ClickTab, {
			    Name = "Enable Auto Clicker",
			
			    Default = false,
			
			    Flag = "AutoClicker",
			
			    Callback = function(enabled)
			        State.AutoClicker =
			            enabled
			
			        if enabled then
			            AutoClicker.Start(
			                State.AutoClickerSpeed
			                or 10
			            )
			        else
			            AutoClicker.Stop()
			        end
			    end,
			})
			
			AddKeybind(ClickTab, {
			    Name = "Pause / Resume",
			
			    Default = Enum.KeyCode.F,
			
			    Flag = "AutoClickerKey",
			
			    Callback = function()
			        AutoClicker.Toggle(
			            State.AutoClickerSpeed
			            or 10
			        )
			
			        State.AutoClicker =
			            AutoClicker.IsRunning()
			    end,
			})
			
			--------------------------------------------------
			-- AUTO MOG
			--------------------------------------------------
			
			local MogSection =
			    Window:CreateSection("Auto Mog")
			
			local MogTab =
			    MogSection:CreateTab(
			        "Auto Mog",
			        "swords"
			    )
			
			MogTab:CreateSection("Target")
			
			local targetBox =
			    AddTextBox(MogTab, {
			        Name = "Player",
			        Placeholder = "Player username",
			    })
			
			AddButton(MogTab, {
			    Name = "Mog Target",
			
			    Callback = function()
			        local username =
			            targetBox:GetText()
			
			        if username ~= "" then
			            State.CurrentTarget =
			                username
			
			            State.AutoMog = true
			
			            AutoMog.Start(username)
			        end
			    end,
			})
			
			AddButton(MogTab, {
			    Name = "Auto Mog All",
			
			    Callback = function()
			        State.AutoMogAll = true
			
			        AutoMog.StartAll()
			    end,
			})
			
			AddButton(MogTab, {
			    Name = "Stop Mog",
			
			    Callback = function()
			        State.AutoMog = false
			        State.AutoMogAll = false
			
			        AutoMog.Stop()
			    end,
			})
			
			if AutoMog
			    and AutoMog.SetCallbacks
			then
			    AutoMog.SetCallbacks(
			        function(target)
			            if target then
			                Remotes.Fire(
			                    "Mog",
			                    target.UserId
			                )
			            end
			        end,
			
			        function()
			            Remotes.Fire(
			                "MogStop"
			            )
			        end
			    )
			end
			
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
			    "Player Search"
			)
			
			local usernameBox =
			    AddTextBox(ServerTab, {
			        Name = "Username",
			        Placeholder = "Player username",
			    })
			
			AddButton(ServerTab, {
			    Name = "Find Player",
			
			    Callback = function()
			        local username =
			            usernameBox:GetText()
			
			        if username == "" then
			            return
			        end
			
			        local result, err =
			            ServerFinder.Find(
			                username
			            )
			
			        Window:Notify({
			            Title =
			                "Server Finder",
			
			            Description =
			                tostring(
			                    result or err
			                ),
			
			            Duration = 3,
			        })
			    end,
			})
			
			--------------------------------------------------
			-- CONFIGS
			--------------------------------------------------
			
			local ConfigSection =
			    Window:CreateSection("Configs")
			
			local ConfigTab =
			    ConfigSection:CreateTab(
			        "Configs",
			        "folder"
			    )
			
			ConfigTab:CreateSection(
			    "Configuration"
			)
			
			ConfigTab:CreateConfigSection()
			
			--------------------------------------------------
			-- SETTINGS
			--------------------------------------------------
			
			local SettingsSection =
			    Window:CreateSection("Settings")
			
			local SettingsTab =
			    SettingsSection:CreateTab(
			        "Settings",
			        "settings"
			    )
			
			SettingsTab:CreateSection(
			    "General"
			)
			
			AddKeybind(SettingsTab, {
			    Name = "UI Toggle Key",
			
			    Default =
			        Enum.KeyCode.RightControl,
			
			    Flag = "UIToggleKey",
			
			    Callback = function(key)
			        Window:SetToggleKey(key)
			    end,
			})
			
			AddToggle(SettingsTab, {
			    Name = "Auto Load",
			
			    Default =
			        AutoLoad.Get(true),
			
			    Flag = "AutoLoad",
			
			    Callback = function(enabled)
			        State.AutoLoad =
			            enabled
			
			        AutoLoad.Set(
			            enabled
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
			
			CreditsTab:CreateParagraph({
			    Title = "ZenWare V3",
			    Content = "@ZensMod",
			})
			
			--------------------------------------------------
			-- AUTOSAVE
			--------------------------------------------------
			
			Window:SetAutoSave(true)
			
			--------------------------------------------------
			-- FINISHED
			--------------------------------------------------
			
			Window:Notify({
			    Title = "ZenWare V3",
			
			    Description =
			        "All modules loaded successfully.",
			
			    Duration = 4,
			})
			
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