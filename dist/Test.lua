
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

_modules["Core/AcrylicUI.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Core/Config.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Core/Remotes.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

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

		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoClicker.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoLoad.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Features/AutoMog.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Features/ServerFinder.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

		end)(unpack(_vararg))
	end,
}

_modules["Features/Teleports.luau"] = {
	cached = false,
	value = nil,
	load = function()
		return (function(...)

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

		end)(unpack(_vararg))
	end,
}

_modules["Core/AcrylicUI"] = _modules["Core/AcrylicUI.luau"]
_modules["Core/Config"] = _modules["Core/Config.luau"]
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