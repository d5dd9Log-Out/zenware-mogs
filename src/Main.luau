local Players = game:GetService("Players")
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
-- WORLD 2 CLIENT-SIDE AUTO WIN TEST
--------------------------------------------------

local RunService = game:GetService("RunService")

local World2TestRunning = false
local World2NoclipConnection = nil
local World2WinPart = nil

local WORLD2_WIN_POSITION =
    Vector3.new(
        -682,
        40,
        4921
    )

local WORLD2_WIN_SIZE =
    Vector3.new(
        2,
        2,
        2
    )

--------------------------------------------------
-- CREATE WIN PART
--------------------------------------------------

local function CreateWorld2WinPart()
    if
        World2WinPart
        and World2WinPart.Parent
    then
        return World2WinPart
    end

    local old =
        workspace:FindFirstChild(
            "ZenWare_World2_Win"
        )

    if old
        and old:IsA("BasePart")
    then
        World2WinPart = old

        return old
    end

    local part =
        Instance.new("Part")

    part.Name =
        "ZenWare_World2_Win"

    part.Size =
        WORLD2_WIN_SIZE

    part.Position =
        WORLD2_WIN_POSITION

    part.Anchored =
        true

    part.Transparency =
        1

    part.CanCollide =
        false

    part.CanTouch =
        false

    part.CanQuery =
        false

    part.Parent =
        workspace

    World2WinPart =
        part

    return part
end

--------------------------------------------------
-- GET TORSO
--------------------------------------------------

local function GetWorld2Torso()
    local character =
        LocalPlayer.Character

    if not character then
        return nil
    end

    return
        character:FindFirstChild(
            "UpperTorso"
        )
        or character:FindFirstChild(
            "Torso"
        )
end

--------------------------------------------------
-- NOCLIP
--------------------------------------------------

local function StartWorld2Noclip()
    if World2NoclipConnection then
        return
    end

    World2NoclipConnection =
        RunService.Stepped:Connect(
            function()
                if not World2TestRunning then
                    return
                end

                local character =
                    LocalPlayer.Character

                if not character then
                    return
                end

                for _, object in ipairs(
                    character:GetDescendants()
                ) do
                    if object:IsA("BasePart") then
                        object.CanCollide =
                            false
                    end
                end
            end
        )
end

local function StopWorld2Noclip()
    if
        World2NoclipConnection
    then
        World2NoclipConnection:Disconnect()

        World2NoclipConnection =
            nil
    end
end

--------------------------------------------------
-- ONE AUTO WIN CYCLE
--------------------------------------------------

local function RunWorld2AutoWinCycle()
    local torso =
        GetWorld2Torso()

    local winPart =
        CreateWorld2WinPart()

    if not torso then
        return
    end

    if not winPart then
        return
    end

    --------------------------------------------------
    -- SAVE TORSO POSITION ONLY
    --------------------------------------------------

    local oldCFrame =
        torso.CFrame

    --------------------------------------------------
    -- TORso -> WIN PART
    --------------------------------------------------

    torso.CFrame =
        winPart.CFrame

    task.wait(0.5)

    --------------------------------------------------
    -- RETURN TORSO
    --------------------------------------------------

    if torso.Parent then
        torso.CFrame =
            oldCFrame
    end

    --------------------------------------------------
    -- WAIT BEFORE NEXT ATTEMPT
    --------------------------------------------------

    task.wait(1)
end

--------------------------------------------------
-- START
--------------------------------------------------

local function StartWorld2AutoWinTest()
    if World2TestRunning then
        return
    end

    World2TestRunning =
        true

    CreateWorld2WinPart()
    StartWorld2Noclip()

    Notify(
        "World 2 Auto Win",
        "Started.",
        3
    )

    task.spawn(
        function()

            while World2TestRunning do

                local ok, err =
                    pcall(
                        RunWorld2AutoWinCycle
                    )

                if not ok then
                    warn(
                        "[ZenWare World2]",
                        err
                    )

                    task.wait(1)
                end
            end

        end
    )
end

--------------------------------------------------
-- STOP
--------------------------------------------------

local function StopWorld2AutoWinTest()
    World2TestRunning =
        false

    StopWorld2Noclip()

    Notify(
        "World 2 Auto Win",
        "Stopped.",
        3
    )
end

--------------------------------------------------
-- UI
--------------------------------------------------

MainTab:CreateSection(
    "World 2 Anti-Cheat"
)

MainTab:CreateParagraph({
    Title =
        "World 2 Auto Win",

    Content =
        "Noclip + torso movement test.\n"
        .. "Target: -682, 40, 4921\n"
        .. "0.5s at target / 1s delay.",
})

MainTab:CreateToggle({
    Name =
        "World 2 Auto Win Test",

    Default =
        false,

    Flag =
        "World2AutoWinTest",

    Callback =
        function(enabled)

            if enabled then
                StartWorld2AutoWinTest()
            else
                StopWorld2AutoWinTest()
            end

        end,
})

MainTab:CreateButton({
    Name =
        "Run One World 2 Test",

    Callback =
        function()

            task.spawn(
                RunWorld2AutoWinCycle
            )

        end,
})

MainTab:CreateButton({
    Name =
        "Create World 2 Win Part",

    Callback =
        function()

            CreateWorld2WinPart()

            Notify(
                "World 2",
                "Part created at -682, 40, 4921.",
                3
            )

        end,
})

MainTab:CreateButton({
    Name =
        "Remove World 2 Part",

    Callback =
        function()

            World2TestRunning =
                false

            StopWorld2Noclip()

            if World2WinPart then
                World2WinPart:Destroy()

                World2WinPart =
                    nil
            end

            Notify(
                "World 2",
                "Part removed.",
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