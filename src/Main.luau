local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

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

local function Notify(title, description, duration)
    pcall(function()
        Window:Notify({
            Title = title or "ZenWare V3",
            Description = description or "",
            Duration = duration or 3,
        })
    end)
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local character = GetCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
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

local function SafeCall(callback)
    if type(callback) ~= "function" then
        return false
    end

    local ok, err = pcall(callback)

    if not ok then
        warn("[ZenWare V3] " .. tostring(err))
    end

    return ok
end

local function SetClipboard(text)
    if type(setclipboard) == "function" then
        pcall(function()
            setclipboard(tostring(text))
        end)

        return true
    end

    return false
end

--------------------------------------------------
-- PLAYER STATE
--------------------------------------------------

State.AutoWin = State.AutoWin or false
State.TeleportLoop = State.TeleportLoop or false
State.TreadmillLoop = State.TreadmillLoop or false
State.TeleportInterval =
    tonumber(State.TeleportInterval)
    or 0.5

State.AutoRebirth = false
State.RebirthInterval = 0.25

State.AutoClicker = false
State.AutoClickerSpeed = 10

State.AutoMog = false
State.AutoMogAll = false

State.WalkSpeed = 16
State.JumpPower = 50
State.HipHeight = 2

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

--------------------------------------------------
-- WIN
--------------------------------------------------

MainTab:CreateSection("Win")

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
                "Win teleport started.",
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

        Notify(
            "Teleport",
            "Teleported to Win.",
            2
        )
    end,
})

MainTab:CreateButton({
    Name = "Teleport to Treadmill",

    Callback = function()
        SafeCall(function()
            Teleports.Treadmill()
        end)

        Notify(
            "Teleport",
            "Teleported to Treadmill.",
            2
        )
    end,
})

MainTab:CreateButton({
    Name = "Refresh Character",

    Callback = function()
        LocalPlayer:LoadCharacter()

        Notify(
            "Player",
            "Character respawn requested.",
            2
        )
    end,
})

--------------------------------------------------
-- LOOPS
--------------------------------------------------

MainTab:CreateSection("Teleport Loops")

MainTab:CreateSlider({
    Name = "Loop Interval",
    Min = 0.01,
    Max = 5,
    Default = State.TeleportInterval,
    Flag = "TeleportInterval",

    Callback = function(value)
        State.TeleportInterval = value

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
        State.TeleportLoop = enabled

        if enabled then
            SafeCall(function()
                Teleports.StartLoop(
                    Teleports.Locations.Win,
                    State.TeleportInterval
                )
            end)

            Notify(
                "Teleport Loop",
                "Win loop enabled.",
                2
            )
        else
            SafeCall(function()
                Teleports.StopLoop()
            end)

            Notify(
                "Teleport Loop",
                "Win loop stopped.",
                2
            )
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
            SafeCall(function()
                Teleports.StartLoop(
                    Teleports.Locations.Treadmill,
                    State.TeleportInterval
                )
            end)

            Notify(
                "Teleport Loop",
                "Treadmill loop enabled.",
                2
            )
        else
            SafeCall(function()
                Teleports.StopLoop()
            end)

            Notify(
                "Teleport Loop",
                "Treadmill loop stopped.",
                2
            )
        end
    end,
})

--------------------------------------------------
-- PLAYER QUICK INFO
--------------------------------------------------

MainTab:CreateSection(
    "Player Information"
)

MainTab:CreateParagraph({
    Title = "Current Player",

    Content =
        "Username: "
        .. tostring(LocalPlayer.Name)
        .. "\nDisplay: "
        .. tostring(LocalPlayer.DisplayName)
        .. "\nUserId: "
        .. tostring(LocalPlayer.UserId)
        .. "\nJobId: "
        .. tostring(game.JobId),
})

MainTab:CreateButton({
    Name = "Copy Job ID",

    Callback = function()
        if SetClipboard(game.JobId) then
            Notify(
                "Clipboard",
                "Job ID copied.",
                2
            )
        else
            Notify(
                "Clipboard",
                "Clipboard is unavailable.",
                2
            )
        end
    end,
})

MainTab:CreateButton({
    Name = "Copy User ID",

    Callback = function()
        if SetClipboard(LocalPlayer.UserId) then
            Notify(
                "Clipboard",
                "User ID copied.",
                2
            )
        else
            Notify(
                "Clipboard",
                "Clipboard is unavailable.",
                2
            )
        end
    end,
})

--------------------------------------------------
-- POSITION
--------------------------------------------------

MainTab:CreateSection(
    "Position"
)

MainTab:CreateButton({
    Name = "Show Current Position",

    Callback = function()
        local position =
            GetPosition()

        Notify(
            "Current Position",
            FormatVector3(position),
            4
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

RebirthTab:CreateParagraph({
    Title = "Automatic Rebirth",

    Content =
        "Presses the game's Rebirth button "
        .. "at the selected interval.",
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

            Notify(
                "Auto Rebirth",
                "Stopped.",
                2
            )

            return
        end

        if rebirthRunning then
            return
        end

        rebirthRunning = true

        Notify(
            "Auto Rebirth",
            "Started.",
            2
        )

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

RebirthTab:CreateButton({
    Name = "Test Rebirth Once",

    Callback = function()
        local button =
            GetRebirthButton()

        if not button then
            Notify(
                "Rebirth",
                "Rebirth button not found.",
                3
            )

            return
        end

        local ok =
            pcall(function()
                firesignal(
                    button.MouseButton1Click
                )
            end)

        Notify(
            "Rebirth",
            ok
                and "Button activated."
                or "Activation failed.",
            3
        )
    end,
})

RebirthTab:CreateButton({
    Name = "Find Rebirth Button",

    Callback = function()
        local button =
            GetRebirthButton()

        Notify(
            "Rebirth",
            button
                and "Button found."
                or "Button not found.",
            3
        )
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

--------------------------------------------------
-- XYZ
--------------------------------------------------

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
            tonumber(xBox:GetText())

        local y =
            tonumber(yBox:GetText())

        local z =
            tonumber(zBox:GetText())

        if not (x and y and z) then
            Notify(
                "Teleport",
                "Enter valid X, Y and Z values.",
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

        Notify(
            "Teleport",
            "Teleport requested.",
            2
        )
    end,
})

TeleportTab:CreateButton({
    Name = "Use Current Position",

    Callback = function()
        local position =
            GetPosition()

        if not position then
            Notify(
                "Teleport",
                "Character root not found.",
                3
            )

            return
        end

        xBox:SetText(
            string.format(
                "%.2f",
                position.X
            )
        )

        yBox:SetText(
            string.format(
                "%.2f",
                position.Y
            )
        )

        zBox:SetText(
            string.format(
                "%.2f",
                position.Z
            )
        )
    end,
})

--------------------------------------------------
-- OFFSET
--------------------------------------------------

TeleportTab:CreateSection(
    "Position Offset"
)

local offsetBox =
    TeleportTab:CreateTextBox({
        Name = "Offset",
        Placeholder = "10, 0, 0",
    })

TeleportTab:CreateButton({
    Name = "Apply Offset",

    Callback = function()
        local root =
            GetRoot()

        if not root then
            Notify(
                "Teleport",
                "Root part not found.",
                3
            )

            return
        end

        local text =
            offsetBox:GetText()

        local x, y, z =
            text:match(
                "^%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*$"
            )

        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)

        if not (x and y and z) then
            Notify(
                "Teleport",
                "Use format: X, Y, Z",
                3
            )

            return
        end

        SafeCall(function()
            root.CFrame =
                root.CFrame
                + Vector3.new(
                    x,
                    y,
                    z
                )
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "Move +10 X",

    Callback = function()
        local root = GetRoot()

        if root then
            root.CFrame =
                root.CFrame
                + Vector3.new(
                    10,
                    0,
                    0
                )
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Move +10 Y",

    Callback = function()
        local root = GetRoot()

        if root then
            root.CFrame =
                root.CFrame
                + Vector3.new(
                    0,
                    10,
                    0
                )
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Move +10 Z",

    Callback = function()
        local root = GetRoot()

        if root then
            root.CFrame =
                root.CFrame
                + Vector3.new(
                    0,
                    0,
                    10
                )
        end
    end,
})

--------------------------------------------------
-- SAVED LOCATIONS
--------------------------------------------------

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

        if not root then
            Notify(
                "Locations",
                "Root part not found.",
                3
            )

            return
        end

        if name == "" then
            Notify(
                "Locations",
                "Enter a location name.",
                3
            )

            return
        end

        SafeCall(function()
            Teleports.SaveLocation(
                name,
                root.Position,
                State
            )
        end)

        Notify(
            "Locations",
            "Location saved: " .. name,
            3
        )
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

        Notify(
            "Locations",
            "Delete requested.",
            3
        )
    end,
})

TeleportTab:CreateButton({
    Name = "Clear Location Inputs",

    Callback = function()
        saveBox:SetText("")
        deleteBox:SetText("")
        xBox:SetText("")
        yBox:SetText("")
        zBox:SetText("")
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
    Default = 10,
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
            Remotes.Fire("Click")
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
                        or 10
                )
            end)

            Notify(
                "Auto Clicker",
                "Started.",
                2
            )
        else
            SafeCall(function()
                AutoClicker.Stop()
            end)

            Notify(
                "Auto Clicker",
                "Stopped.",
                2
            )
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
                    or 10
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
        State.AutoClicker = true

        SafeCall(function()
            AutoClicker.Start(
                State.AutoClickerSpeed
                    or 10
            )
        end)

        Notify(
            "Auto Clicker",
            "Started manually.",
            2
        )
    end,
})

ClickTab:CreateButton({
    Name = "Stop Clicker",

    Callback = function()
        State.AutoClicker = false

        SafeCall(function()
            AutoClicker.Stop()
        end)

        Notify(
            "Auto Clicker",
            "Stopped manually.",
            2
        )
    end,
})

ClickTab:CreateButton({
    Name = "Check Clicker Status",

    Callback = function()
        local running = false

        SafeCall(function()
            running =
                AutoClicker.IsRunning()
        end)

        Notify(
            "Clicker Status",
            running
                and "RUNNING"
                or "STOPPED",
            3
        )
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
            Notify(
                "Auto Mog",
                "Enter a username.",
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

        Notify(
            "Auto Mog",
            "Target: " .. username,
            3
        )
    end,
})

MogTab:CreateButton({
    Name = "Auto Mog All",

    Callback = function()
        State.AutoMogAll = true

        SafeCall(function()
            AutoMog.StartAll()
        end)

        Notify(
            "Auto Mog",
            "All-target mode started.",
            3
        )
    end,
})

MogTab:CreateButton({
    Name = "Stop Mog",

    Callback = function()
        State.AutoMog = false
        State.AutoMogAll = false

        SafeCall(function()
            AutoMog.Stop()
        end)

        Notify(
            "Auto Mog",
            "Stopped.",
            2
        )
    end,
})

MogTab:CreateButton({
    Name = "Clear Target",

    Callback = function()
        targetBox:SetText("")
        State.CurrentTarget = nil
    end,
})

MogTab:CreateParagraph({
    Title = "Current Target",

    Content = function()
        return tostring(
            State.CurrentTarget
            or "None"
        )
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
    "Player Search"
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

        if username == "" then
            Notify(
                "Server Finder",
                "Enter a username.",
                3
            )

            return
        end

        local result
        local err

        local ok =
            pcall(function()
                result, err =
                    ServerFinder.Find(
                        username
                    )
            end)

        if not ok then
            Notify(
                "Server Finder",
                "Finder failed.",
                3
            )

            return
        end

        Notify(
            "Server Finder",
            tostring(
                result
                or err
                or "No result."
            ),
            5
        )
    end,
})

ServerTab:CreateButton({
    Name = "Show Current Job ID",

    Callback = function()
        Notify(
            "Current Server",
            game.JobId,
            5
        )
    end,
})

ServerTab:CreateButton({
    Name = "Copy Current Job ID",

    Callback = function()
        if SetClipboard(game.JobId) then
            Notify(
                "Server Finder",
                "Job ID copied.",
                2
            )
        else
            Notify(
                "Server Finder",
                "Clipboard unavailable.",
                3
            )
        end
    end,
})

ServerTab:CreateButton({
    Name = "Rejoin Server",

    Callback = function()
        SafeCall(function()
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )
        end)
    end,
})

ServerTab:CreateButton({
    Name = "Reconnect",
    
    Callback = function()
        SafeCall(function()
            TeleportService:Teleport(
                game.PlaceId,
                LocalPlayer
            )
        end)
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
-- UI
--------------------------------------------------

SettingsTab:CreateSection(
    "Interface"
)

SettingsTab:CreateKeybind({
    Name = "UI Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Flag = "UIToggleKey",

    Callback = function(key)
        Window:SetToggleKey(key)

        Notify(
            "Interface",
            "Toggle key changed to "
                .. tostring(key.Name),
            2
        )
    end,
})

SettingsTab:CreateToggle({
    Name = "Auto Load",
    Default = AutoLoad.Get(true),
    Flag = "AutoLoad",

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
    Default = 16,
    Flag = "WalkSpeed",

    Callback = function(value)
        State.WalkSpeed = value

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
    Default = 50,
    Flag = "JumpPower",

    Callback = function(value)
        State.JumpPower = value

        local humanoid =
            GetHumanoid()

        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end,
})

SettingsTab:CreateSlider({
    Name = "Hip Height",
    Min = 0,
    Max = 10,
    Default = 2,
    Flag = "HipHeight",

    Callback = function(value)
        State.HipHeight = value

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
            Notify(
                "Player",
                "Humanoid not found.",
                3
            )

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

        Notify(
            "Player",
            "Settings applied.",
            2
        )
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

        humanoid.WalkSpeed = 16
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 50
        humanoid.HipHeight = 2

        Notify(
            "Player",
            "Default values restored.",
            2
        )
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
            camera.FieldOfView = 70
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Camera Information",

    Callback = function()
        local camera =
            GetCamera()

        if not camera then
            return
        end

        Notify(
            "Camera",
            "FOV: "
                .. tostring(
                    math.floor(
                        camera.FieldOfView
                    )
                )
                .. "\nType: "
                .. tostring(
                    camera.CameraType
                ),
            4
        )
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
    Flag = "FullBright",

    Callback = function(enabled)
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
        end
    end,
})

SettingsTab:CreateSlider({
    Name = "Gravity",
    Min = 0,
    Max = 300,
    Default = Workspace.Gravity,
    Flag = "Gravity",

    Callback = function(value)
        Workspace.Gravity =
            value
    end,
})

SettingsTab:CreateButton({
    Name = "Reset Gravity",

    Callback = function()
        Workspace.Gravity = 196.2

        Notify(
            "World",
            "Gravity reset.",
            2
        )
    end,
})

--------------------------------------------------
-- UTILITY
--------------------------------------------------

SettingsTab:CreateSection(
    "Utility"
)

SettingsTab:CreateButton({
    Name = "Respawn Character",

    Callback = function()
        SafeCall(function()
            LocalPlayer:LoadCharacter()
        end)
    end,
})

SettingsTab:CreateToggle({
    Name = "Anti AFK",
    Default = false,
    Flag = "AntiAFK",

    Callback = function(enabled)
        State.AntiAFK =
            enabled

        if not enabled then
            return
        end

        task.spawn(function()
            while State.AntiAFK do
                pcall(function()
                    VirtualUser:CaptureController()

                    VirtualUser:ClickButton2(
                        Vector2.new()
                    )
                end)

                task.wait(60)
            end
        end)
    end,
})

SettingsTab:CreateButton({
    Name = "Get Player Count",

    Callback = function()
        Notify(
            "Players",
            "Players in server: "
                .. tostring(
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
    Title = "ZenWare Configs",

    Content =
        "Use the built-in configuration "
        .. "system to store UI values and "
        .. "feature preferences.",
})

ConfigTab:CreateButton({
    Name = "Configuration Status",

    Callback = function()
        Notify(
            "Configs",
            "Config folder: ZenWareConfigs",
            3
        )
    end,
})

ConfigTab:CreateButton({
    Name = "Reload Interface",

    Callback = function()
        Notify(
            "Configs",
            "Reload the script to rebuild the interface.",
            4
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

CreditsTab:CreateImage({
    Name = "ZenWareLogo",

    Image =
        "rbxassetid://95816097006870",

    Height = 100,
})

CreditsTab:CreateParagraph({
    Title = "ZenWare V3",

    Content =
        "@ZensMod\n"
        .. "Powered by the ZenWare core\n"
        .. "Interface by Obsidian-style UI",
})

CreditsTab:CreateButton({
    Name = "Copy ZenWare Name",

    Callback = function()
        if SetClipboard("ZenWare V3") then
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
-- FINAL STATUS
--------------------------------------------------

Window:SetAutoSave(true)

Notify(
    "ZenWare V3",
    "All modules loaded successfully.",
    4
)

print(
    "[ZenWare V3] Loaded successfully"
)