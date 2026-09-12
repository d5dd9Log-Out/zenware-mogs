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