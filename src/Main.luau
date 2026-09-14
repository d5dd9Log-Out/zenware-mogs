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

--------------------------------------------------
-- CONFIG ENGINE
--------------------------------------------------

local CONFIG_FOLDER =
    "ZenWare/Lilac"

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
    if type(makefolder) ~= "function"
        or type(isfolder) ~= "function"
    then
        return
    end

    pcall(function()
        if not isfolder(
            "ZenWare"
        ) then
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

        CameraFOV =
            GetCamera()
            and GetCamera().FieldOfView
            or 70,

        SavedAt =
            os.time(),
    }
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

    local humanoid =
        GetHumanoid()

    if humanoid then
        humanoid.WalkSpeed =
            State.WalkSpeed

        humanoid.UseJumpPower =
            true

        humanoid.JumpPower =
            State.JumpPower

        humanoid.HipHeight =
            State.HipHeight
    end

    local camera =
        GetCamera()

    if camera
        and tonumber(
            data.CameraFOV
        )
    then
        camera.FieldOfView =
            tonumber(
                data.CameraFOV
            )
    end

    if data.AutoRebirth == true then
        StartAutoRebirth()
    else
        StopAutoRebirth()
    end

    State.AutoClicker =
        data.AutoClicker == true

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

    State.AutoMog =
        data.AutoMog == true

    State.AutoMogAll =
        data.AutoMogAll == true

    if State.AutoMogAll then
        SafeCall(function()
            AutoMog.StartAll()
        end)
    end

    if data.AntiAFK == true then
        State.AntiAFK = true
    else
        State.AntiAFK = false
    end

    return true
end

local function SaveConfig(name)
    EnsureConfigFolder()

    if type(writefile) ~= "function" then
        return false,
            "writefile unavailable"
    end

    local ok, err =
        pcall(function()
            writefile(
                ConfigPath(name),
                HttpService:JSONEncode(
                    BuildConfigData()
                )
            )
        end)

    return ok, err
end

local function LoadConfig(name)
    if type(readfile) ~= "function"
        or type(isfile) ~= "function"
    then
        return false,
            "readfile/isfile unavailable"
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
    )
end

local function DeleteConfig(name)
    if type(delfile) ~= "function"
        or type(isfile) ~= "function"
    then
        return false,
            "delfile/isfile unavailable"
    end

    local path =
        ConfigPath(name)

    if not isfile(path) then
        return false,
            "Config not found"
    end

    return pcall(function()
        delfile(
            path
        )
    end)
end

local function ListConfigs()
    if type(listfiles) ~= "function" then
        return {}
    end

    EnsureConfigFolder()

    local result = {}

    local ok, entries =
        pcall(function()
            return listfiles(
                CONFIG_FOLDER
            )
        end)

    if not ok
        or type(entries) ~= "table"
    then
        return result
    end

    for _, path in ipairs(entries) do
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

    table.sort(
        result
    )

    return result
end

--------------------------------------------------
-- CONFIG UI
--------------------------------------------------

local ConfigLeft =
    ConfigTab.Tab:AddLeftGroupbox(
        "Configuration",
        "folder"
    )

local ConfigRight =
    ConfigTab.Tab:AddRightGroupbox(
        "Quick Actions",
        "zap"
    )

local configNameInput =
    ConfigLeft:AddInput(
        "ConfigName",
        {
            Text =
                "Config Name",

            Default =
                "default",

            Placeholder =
                "default",
        }
    )

ConfigLeft:AddLabel({
    Text =
        "Local JSON configs\n"
        .. "Save / Load / Delete / List",
    DoesWrap = true,
})

ConfigLeft:AddButton({
    Text = "Save Config",

    Func = function()
        local name =
            tostring(
                configNameInput.Value
                or "default"
            )

        local ok, err =
            SaveConfig(
                name
            )

        Notify(
            "Configs",
            ok
                and (
                    "Saved: "
                    .. SafeConfigName(
                        name
                    )
                )
                or (
                    "Save failed: "
                    .. tostring(err)
                ),
            4
        )
    end,
})

ConfigLeft:AddButton({
    Text = "Load Config",

    Func = function()
        local name =
            tostring(
                configNameInput.Value
                or "default"
            )

        local ok, err =
            LoadConfig(
                name
            )

        Notify(
            "Configs",
            ok
                and (
                    "Loaded: "
                    .. SafeConfigName(
                        name
                    )
                )
                or (
                    "Load failed: "
                    .. tostring(err)
                ),
            4
        )
    end,
})

ConfigLeft:AddButton({
    Text = "Delete Config",

    Func = function()
        local name =
            tostring(
                configNameInput.Value
                or "default"
            )

        local ok, err =
            DeleteConfig(
                name
            )

        Notify(
            "Configs",
            ok
                and (
                    "Deleted: "
                    .. SafeConfigName(
                        name
                    )
                )
                or (
                    "Delete failed: "
                    .. tostring(err)
                ),
            4
        )
    end,
})

ConfigRight:AddButton({
    Text = "List Configs",

    Func = function()
        local list =
            ListConfigs()

        Notify(
            "Configs",
            #list > 0
                and table.concat(
                    list,
                    ", "
                )
                or "No configs found.",
            6
        )
    end,
})

ConfigRight:AddButton({
    Text = "Save Default",

    Func = function()
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

ConfigRight:AddButton({
    Text = "Load Default",

    Func = function()
        local ok, err =
            LoadConfig(
                "default"
            )

        Notify(
            "Configs",
            ok
                and "Default config loaded."
                or (
                    "Load failed: "
                    .. tostring(err)
                ),
            4
        )
    end,
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

local SetDevGravity0
local StartDevCamera
local StopDevCamera
local StartDevFly
local StopDevFly


local UtilityLeft =
    UtilityTab.Tab:AddLeftGroupbox(
        "Session & Character",
        "user"
    )

local UtilityRight =
    UtilityTab.Tab:AddRightGroupbox(
        "Automation",
        "zap"
    )

local UtilityRightDev =
    UtilityTab.Tab:AddRightGroupbox(
        "Dev / Camera",
        "wrench"
    )

--------------------------------------------------
-- LEFT: SESSION
--------------------------------------------------

UtilityLeft:AddLabel({
    Text =
        "🌸 Lilac Utilities\n"
        .. "Session, character and small helpers.",
    DoesWrap = true,
})

UtilityLeft:AddButton({
    Text = "Session Info",

    Func = function()
        local position =
            GetPosition()

        Notify(
            "Session Info",
            "Place: "
                .. tostring(
                    game.PlaceId
                )
                .. "\nPlayers: "
                .. tostring(
                    #Players:GetPlayers()
                )
                .. "\nUptime: "
                .. string.format(
                    "%.0fs",
                    os.clock()
                        - SessionStart
                )
                .. "\nPosition: "
                .. FormatVector3(
                    position
                ),
            6
        )
    end,
})

UtilityLeft:AddButton({
    Text = "Show Place ID",

    Func = function()
        Notify(
            "Place ID",
            tostring(
                game.PlaceId
            ),
            4
        )
    end,
})

UtilityLeft:AddButton({
    Text = "Show Job ID",

    Func = function()
        Notify(
            "Job ID",
            tostring(
                game.JobId
            ),
            4
        )
    end,
})

UtilityLeft:AddButton({
    Text = "Show Player Count",

    Func = function()
        Notify(
            "Server",
            tostring(
                #Players:GetPlayers()
            )
                .. " players online.",
            3
        )
    end,
})

UtilityLeft:AddButton({
    Text = "Refresh Character",

    Func = function()
        SafeCall(function()
            LocalPlayer:LoadCharacter()
        end)
    end,
})

UtilityLeft:AddButton({
    Text = "Character Position",

    Func = function()
        Notify(
            "Position",
            FormatVector3(
                GetPosition()
            ),
            4
        )
    end,
})

UtilityLeft:AddButton({
    Text = "Reset Character Physics",

    Func = function()
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

            humanoid.UseJumpPower =
                true

            humanoid.JumpPower =
                50

            humanoid.HipHeight =
                2
        end

        State.WalkSpeed = 16
        State.JumpPower = 50
        State.HipHeight = 2
    end,
})

UtilityLeft:AddDivider()

UtilityLeft:AddSlider(
    "WalkSpeed",
    {
        Text =
            "Walk Speed",

        Default =
            State.WalkSpeed,

        Min = 1,

        Max = 100,

        Rounding = 0,

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
    }
)

UtilityLeft:AddSlider(
    "JumpPower",
    {
        Text =
            "Jump Power",

        Default =
            State.JumpPower,

        Min = 1,

        Max = 150,

        Rounding = 0,

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
    }
)

UtilityLeft:AddSlider(
    "HipHeight",
    {
        Text =
            "Hip Height",

        Default =
            State.HipHeight,

        Min = 0,

        Max = 10,

        Rounding = 1,

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
    }
)

UtilityLeft:AddSlider(
    "CameraFOV",
    {
        Text =
            "Camera FOV",

        Default = 70,

        Min = 40,

        Max = 120,

        Rounding = 0,

        Callback = function(value)
            local camera =
                GetCamera()

            if camera then
                camera.FieldOfView =
                    value
            end
        end,
    }
)

UtilityLeft:AddToggle(
    "AntiAFK",
    {
        Text =
            "Anti AFK",

        Default =
            State.AntiAFK
            == true,

        Callback = function(enabled)
            State.AntiAFK =
                enabled
        end,
    }
)

UtilityLeft:AddButton({
    Text = "Reset Camera",

    Func = function()
        SafeCall(function()
            StopDevCamera()

            local camera =
                GetCamera()

            local humanoid =
                GetHumanoid()

            camera.CameraType =
                Enum.CameraType.Custom

            if humanoid then
                camera.CameraSubject =
                    humanoid
            end
        end)
    end,
})

--------------------------------------------------
-- RIGHT: AUTOMATION
--------------------------------------------------

UtilityRight:AddLabel({
    Text =
        "Automation controls",
    DoesWrap = true,
})

UtilityRight:AddSlider(
    "RebirthInterval",
    {
        Text =
            "Rebirth Interval",

        Default =
            State.RebirthInterval,

        Min = 0.05,

        Max = 2,

        Rounding = 2,

        Callback = function(value)
            State.RebirthInterval =
                value
        end,
    }
)

UtilityRight:AddToggle(
    "AutoRebirth",
    {
        Text =
            "Auto Rebirth",

        Default =
            State.AutoRebirth
            == true,

        Callback = function(enabled)
            if enabled then
                StartAutoRebirth()
            else
                StopAutoRebirth()
            end
        end,
    }
)

UtilityRight:AddButton({
    Text = "Rebirth Once",

    Func = function()
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

UtilityRight:AddSlider(
    "AutoClickerSpeed",
    {
        Text =
            "Clicks Per Second",

        Default =
            State.AutoClickerSpeed,

        Min = 1,

        Max = 100,

        Rounding = 0,

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
    }
)

UtilityRight:AddToggle(
    "AutoClicker",
    {
        Text =
            "Auto Clicker",

        Default =
            State.AutoClicker
            == true,

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
    }
)

UtilityRight:AddLabel(
    "Clicker hotkey: F"
)

UtilityRight:AddButton({
    Text = "Stop Clicker",

    Func = function()
        State.AutoClicker =
            false

        SafeCall(function()
            AutoClicker.Stop()
        end)
    end,
})

local utilityMogInput =
    UtilityRight:AddInput(
        "UtilityMogTarget",
        {
            Text =
                "Mog Target",

            Placeholder =
                "Player username",
        }
    )

UtilityRight:AddButton({
    Text = "Mog Target",

    Func = function()
        local username =
            tostring(
                utilityMogInput.Value
                or ""
            )

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

        State.AutoMog =
            true

        SafeCall(function()
            AutoMog.Start(
                username
            )
        end)
    end,
})

UtilityRight:AddButton({
    Text = "Mog All",

    Func = function()
        State.AutoMogAll =
            true

        SafeCall(function()
            AutoMog.StartAll()
        end)
    end,
})

UtilityRight:AddButton({
    Text = "Stop Mog",

    Func = function()
        State.AutoMog = false
        State.AutoMogAll = false

        SafeCall(function()
            AutoMog.Stop()
        end)
    end,
})

--------------------------------------------------
-- RIGHT: DEV / CAMERA
--------------------------------------------------

UtilityRightDev:AddToggle(
    "DevGravity0",
    {
        Text =
            "Dev Gravity 0",

        Default = false,

        Callback = function(enabled)
            SetDevGravity0(
                enabled
            )
        end,
    }
)

UtilityRightDev:AddToggle(
    "DevCamera",
    {
        Text =
            "Dev Camera",

        Default = false,

        Callback = function(enabled)
            if enabled then
                StartDevCamera()
            else
                StopDevCamera()
            end
        end,
    }
)

UtilityRightDev:AddButton({
    Text = "Dev Camera Position",

    Func = function()
        StartDevCamera()
    end,
})

UtilityRightDev:AddButton({
    Text = "Reset Dev Camera",

    Func = function()
        StopDevCamera()
    end,
})

UtilityRightDev:AddToggle(
    "DevFly",
    {
        Text =
            "Dev Fly",

        Default = false,

        Callback = function(enabled)
            if enabled then
                StartDevFly()
            else
                StopDevFly()
            end
        end,
    }
)

UtilityRightDev:AddButton({
    Text = "Stop All Dev",

    Func = function()
        StopAllDevTests()
        StopDevFly()
        StopDevCamera()

        devGravity0Enabled =
            false

        if DevGravityOriginal ~= nil then
            Workspace.Gravity =
                DevGravityOriginal

            DevGravityOriginal =
                nil
        end
    end,
})

UtilityRightDev:AddDivider()

UtilityRightDev:AddButton({
    Text = "Start Both Auto Win",

    Func = function()
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
            "Both dev profiles started.",
            3
        )
    end,
})

UtilityRightDev:AddLabel({
    Text =
        "Camera: -73, 62, 4923\n"
        .. "Fly: WalkSpeed • Q/E",
    DoesWrap = true,
})

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

local devGravity0Enabled = false

function SetDevGravity0(enabled)
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

function StopDevCamera()
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

function StartDevCamera()
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

function StopDevFly()
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

function StartDevFly()
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