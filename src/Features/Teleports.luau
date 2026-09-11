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