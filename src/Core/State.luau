local State = {
    AutoWin = false,

    TeleportLoop = false,
    TreadmillLoop = false,
    TeleportInterval = 0.5,

    AutoClicker = false,
    AutoClickerSpeed = 10,

    AutoMog = false,
    AutoMogAll = false,

    AutoLoad = true,

    CurrentTarget = nil,

    SavedLocations = {},
}

return State