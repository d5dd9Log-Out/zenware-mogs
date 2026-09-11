local Players = game:GetService("Players")

local Utils = {}

function Utils.SafeCall(callback, ...)
    if typeof(callback) ~= "function" then
        return false, "Invalid callback"
    end

    return pcall(callback, ...)
end

function Utils.GetPlayer()
    return Players.LocalPlayer
end

function Utils.GetCharacter()
    local player = Players.LocalPlayer

    return player and player.Character
end

function Utils.GetRoot()
    local character = Utils.GetCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

function Utils.GetPlayers()
    local result = {}

    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(result, player.Name)
    end

    table.sort(result)

    return result
end

function Utils.ToNumber(value, fallback)
    local number = tonumber(value)

    if number == nil then
        return fallback
    end

    return number
end

function Utils.Trim(text)
    return tostring(text):match("^%s*(.-)%s*$")
end

return Utils