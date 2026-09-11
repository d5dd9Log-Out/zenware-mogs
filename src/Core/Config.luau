local Config = {}

Config.Name = "ZenWare"

Config.Defaults = {
    AutoWin = false,

    TeleportLoop = false,
    TreadmillLoop = false,
    TeleportInterval = 0.5,

    AutoClicker = false,
    AutoClickerSpeed = 10,

    AutoMog = false,
    AutoMogAll = false,

    AutoLoad = true,
}

function Config.GetDefaults()
    local result = {}

    for key, value in pairs(Config.Defaults) do
        result[key] = value
    end

    return result
end

return Config