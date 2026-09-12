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
-- CONSTANTS
--------------------------------------------------

local LOGO = "rbxassetid://95816097006870"

--------------------------------------------------
-- MAIN / DASHBOARD
--------------------------------------------------

local MainSection = Window:CreateSection("Main")
local MainTab = MainSection:CreateTab("Main", "home")

MainTab:CreateSection("ZenWare V3", "sparkles")

MainTab:CreateImage({
    Name = "ZenWareLogo",
    Image = LOGO,
    Height = 110,
})

MainTab:CreateParagraph({
    Title = "ZENWARE V3",
    Content =
        "Advanced Roblox utility interface\n"
        .. "Powered by Obsidian\n\n"
        .. "● Status: ONLINE\n"
        .. "● Core: ACTIVE\n"
        .. "● Version: V3",
})

--------------------------------------------------
-- QUICK ACTIONS
--------------------------------------------------

MainTab:CreateSection("Quick Actions", "zap")

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

--------------------------------------------------
-- WIN
--------------------------------------------------

MainTab:CreateSection("Win", "trophy")

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

--------------------------------------------------
-- LOOPS
--------------------------------------------------

MainTab:CreateSection("Teleport Loops", "repeat")

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
    local player = game:GetService("Players").LocalPlayer

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

RebirthTab:CreateSection(
    "Rebirth",
    "refresh-cw"
)

RebirthTab:CreateParagraph({
    Title = "Automatic Rebirth",
    Content =
        "Automatically activates the Rebirth button\n"
        .. "using the selected interval.",
})

RebirthTab:CreateSlider({
    Name = "Rebirth Interval",
    Min = 0.05,
    Max = 2,
    Default = 0.25,
    Flag = "RebirthInterval",

    Callback = function(value)
        State.RebirthInterval = value
    end,
})

RebirthTab:CreateToggle({
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

TeleportTab:CreateSection(
    "Custom XYZ",
    "crosshair"
)

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

--------------------------------------------------
-- SAVED LOCATIONS
--------------------------------------------------

TeleportTab:CreateSection(
    "Saved Locations",
    "bookmark"
)

local saveBox = TeleportTab:CreateTextBox({
    Name = "Location Name",
    Placeholder = "My Location",
})

TeleportTab:CreateButton({
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
    TeleportTab:CreateTextBox({
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

local ClickSection =
    Window:CreateSection("Auto Clicker")

local ClickTab =
    ClickSection:CreateTab(
        "Auto Clicker",
        "mouse-pointer"
    )

ClickTab:CreateSection(
    "Clicker",
    "mouse-pointer"
)

ClickTab:CreateParagraph({
    Title = "Auto Clicker",
    Content =
        "Automatically sends the configured click\n"
        .. "action while enabled.",
})

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

local MogSection =
    Window:CreateSection("Auto Mog")

local MogTab =
    MogSection:CreateTab(
        "Auto Mog",
        "swords"
    )

MogTab:CreateSection(
    "Target",
    "crosshair"
)

MogTab:CreateParagraph({
    Title = "Auto Mog",
    Content =
        "Select a target player and start the Mog\n"
        .. "automation system.",
})

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

        if username ~= "" then
            State.CurrentTarget =
                username

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
        Remotes.Fire(
            "Mog",
            target.UserId
        )
    end,

    function()
        Remotes.Fire("MogStop")
    end
)

--------------------------------------------------
-- SERVER FINDER
--------------------------------------------------

local ServerSection =
    Window:CreateSection("Server Finder")

local ServerTab =
    ServerSection:CreateTab(
        "Server Finder",
        "server"
    )

ServerTab:CreateSection(
    "Player Search",
    "search"
)

ServerTab:CreateParagraph({
    Title = "Server Finder",
    Content =
        "Find the server associated with a Roblox\n"
        .. "username.",
})

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

        if username == "" then
            return
        end

        local result, err =
            ServerFinder.Find(username)

        Window:Notify({
            Title = "Server Finder",
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
    "Configuration",
    "folder"
)

ConfigTab:CreateParagraph({
    Title = "ZenWare Configs",
    Content =
        "Save and load your ZenWare settings.",
})

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
    "General",
    "settings"
)

SettingsTab:CreateParagraph({
    Title = "Interface Settings",
    Content =
        "Configure ZenWare preferences and controls.",
})

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

local CreditsSection =
    Window:CreateSection("Credits")

local CreditsTab =
    CreditsSection:CreateTab(
        "Credits",
        "heart"
    )

CreditsTab:CreateSection(
    "ZenWare V3",
    "heart"
)

CreditsTab:CreateImage({
    Name = "CreditsLogo",
    Image = LOGO,
    Height = 95,
})

CreditsTab:CreateParagraph({
    Title = "ZenWare V3",
    Content =
        "@ZensMod\n\n"
        .. "Powered by Obsidian",
})

--------------------------------------------------
-- AUTOSAVE
--------------------------------------------------

Window:SetAutoSave(true)

--------------------------------------------------
-- READY
--------------------------------------------------

Window:Notify({
    Title = "ZenWare V3",
    Description =
        "Interface loaded successfully",
    Duration = 4,
})

print("[ZenWare V3] Loaded successfully")