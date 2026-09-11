local TeleportService = game:GetService("TeleportService")

local AutoLoad = {}

local KEY = "ZenWare_AutoLoad"

function AutoLoad.Set(enabled)
    pcall(function()
        TeleportService:SetTeleportSetting(
            KEY,
            enabled == true
        )
    end)
end

function AutoLoad.Get(defaultValue)
    local value

    pcall(function()
        value = TeleportService:GetTeleportSetting(KEY)
    end)

    if value == nil then
        return defaultValue == true
    end

    return value == true
end

return AutoLoad