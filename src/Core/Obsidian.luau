local Obsidian = {}

local REPO = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local LILAC_BACKGROUND = 83486595661123

local function loadLibrary()
    return loadstring(game:HttpGet(REPO .. "Library.lua"))()
end

function Obsidian.new(title, configFolder)
    local Library = loadLibrary()

    -- LILAC theme
    Library.Scheme = {
        BackgroundColor = Color3.fromRGB(5, 3, 8),
        MainColor = Color3.fromRGB(18, 10, 23),
        AccentColor = Color3.fromRGB(181, 105, 214),
        OutlineColor = Color3.fromRGB(67, 38, 78),
        FontColor = Color3.fromRGB(244, 235, 248),
        Font = Font.fromEnum(Enum.Font.Gotham),

        RedColor = Color3.fromRGB(255, 75, 105),
        DestructiveColor = Color3.fromRGB(220, 55, 80),
        DarkColor = Color3.fromRGB(0, 0, 0),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        BackgroundImageEnabled = true,
        BackgroundImage = "",
        WindowGlow = true,
    }

    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true

    local Window = Library:CreateWindow({
        Title = title or "ZenWare V3",
        Footer = "ZenWare V3",
        Icon = 95816097006870,
        NotifySide = "Right",
        ShowCustomCursor = true,
        AutoShow = true,
        Resizable = true,
        Center = true,
        Glow = true,
    })

    -- Exact uploaded LILAC image
    pcall(function()
        Library:SetBackgroundImage(LILAC_BACKGROUND)
        Library:SetBackgroundImageEnabled(true)
    end)

    pcall(function()
        Window:SetBackgroundImage(LILAC_BACKGROUND)
        Window:SetCornerRadius(10)
        Window:SetAnimations({
            Resize = true,
            Sidebar = true,
            Content = true,
            Elements = true,
        })
    end)

    local ZenWindow = {
        Library = Library,
        Window = Window,
        Sections = {},
    }

    function ZenWindow:CreateSection(sectionName)
        local Section = {
            Name = sectionName,
            Window = self,
        }

        function Section:CreateTab(tabName, icon)
            local Tab = self.Window.Window:AddTab(tabName, icon)

            local ZenTab = {
                Tab = Tab,
                Group = nil,
            }

            function ZenTab:CreateSection(name)
                local Group = self.Tab:AddLeftGroupbox(name)
                self.Group = Group

                function self:CreateButton(config)
                    return Group:AddButton({
                        Text = config.Name or "Button",
                        Func = config.Callback,
                    })
                end

                function self:CreateToggle(config)
                    return Group:AddToggle(
                        config.Flag or config.Name or "Toggle",
                        {
                            Text = config.Name or "Toggle",
                            Default = config.Default == true,
                            Callback = config.Callback,
                        }
                    )
                end

                function self:CreateSlider(config)
                    return Group:AddSlider(
                        config.Flag or config.Name or "Slider",
                        {
                            Text = config.Name or "Slider",
                            Default = config.Default or 0,
                            Min = config.Min or 0,
                            Max = config.Max or 100,
                            Rounding = 2,
                            Callback = config.Callback,
                        }
                    )
                end

                function self:CreateTextBox(config)
                    local input = Group:AddInput(
                        config.Name or "Input",
                        {
                            Text = config.Name or "Input",
                            Placeholder = config.Placeholder or "",
                            Default = "",
                            Callback = config.Callback,
                        }
                    )

                    local api = {}

                    function api:GetText()
                        if input and input.Value ~= nil then
                            return tostring(input.Value)
                        end
                        return ""
                    end

                    function api:SetText(value)
                        if input and input.SetValue then
                            input:SetValue(tostring(value or ""))
                        end
                    end

                    return api
                end

                function self:CreateKeybind(config)
                    local default = config.Default or "RightControl"

                    if typeof(default) == "EnumItem" then
                        default = default.Name
                    end

                    local label = Group:AddLabel(config.Name or "Keybind")

                    return label:AddKeyPicker(
                        config.Flag or config.Name or "Keybind",
                        {
                            Default = default,
                            Mode = "Toggle",
                            Text = config.Name or "Keybind",
                            Callback = config.Callback,
                        }
                    )
                end

                function self:CreateColorPicker(config)
                    local label = Group:AddLabel(config.Name or "Color")

                    return label:AddColorPicker(
                        config.Flag or config.Name or "Color",
                        {
                            Default = config.Default,
                            Title = config.Name or "Color",
                            Callback = config.Callback,
                        }
                    )
                end

                function self:CreateParagraph(config)
                    return Group:AddLabel({
                        Text = (
                            tostring(config.Title or "") ..
                            "\n" ..
                            tostring(config.Content or "")
                        ),
                        DoesWrap = true,
                    })
                end

                function self:CreateConfigSection()
                    Group:AddLabel("Configs")
                end

                return Group
            end

            return ZenTab
        end

        return Section
    end

    function ZenWindow:Notify(config)
        self.Library:Notify({
            Title = config.Title or "ZenWare V3",
            Description = config.Description or "",
            Time = config.Duration or 3,
        })
    end

    function ZenWindow:SetToggleKey(key)
        if self.Library.Options
            and self.Library.Options.MenuKeybind
            and self.Library.Options.MenuKeybind.SetValue then

            self.Library.Options.MenuKeybind:SetValue({
                key.Name,
                "Toggle",
            })

            return
        end

        self.ToggleKey = key
    end

    function ZenWindow:SetAutoSave(enabled)
        self.AutoSave = enabled == true
    end

    function ZenWindow:Destroy()
        if self.Library then
            self.Library:Unload()
        end
    end

    return ZenWindow
end

return Obsidian