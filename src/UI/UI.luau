local Obsidian = require(
    "Core/Obsidian"
)

local UI = {}

function UI.Create()
    local Window =
        Obsidian.new(
            "ZenWare V3",
            "ZenWareConfigs"
        )

    Window:SetToggleKey(
        Enum.KeyCode.RightControl
    )

    return Window
end

return UI