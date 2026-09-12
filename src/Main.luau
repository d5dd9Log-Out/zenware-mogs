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