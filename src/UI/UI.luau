local Obsidian = require("Core/Obsidian")

local UI = {}

function UI.Create()
    local Window = Obsidian.new(
        "ZenWare V3",
        "ZenWareConfigs"
    )

    Window:SetToggleKey(Enum.KeyCode.RightControl)

    Window:Notify({
        Title = "ZenWare V3",
        Description = "Interface loaded successfully",
        Duration = 3,
    })

    return Window
end

return UI
