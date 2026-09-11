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