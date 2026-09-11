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