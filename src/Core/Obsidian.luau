local Obsidian = {}

local REPO = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local function loadLibrary()
    return loadstring(game:HttpGet(REPO .. "Library.lua"))()
end

function Obsidian.new(title, configFolder)
    local Library = loadLibrary()

    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true

    local Window = Library:CreateWindow({
        Title = title or "ZenWare V3",
        Footer = "ZenWare V3",
        NotifySide = "Right",
        ShowCustomCursor = true,
        AutoShow = true,
        Resizable = true,
        Center = true,
    })

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
                    local label = Group:AddLabel(
                        config.Name or "Keybind"
                    )

                    local keybind = label:AddKeyPicker(
                        config.Flag or config.Name or "Keybind",
                        {
                            Default = config.Default or "RightControl",
                            Mode = "Toggle",
                            Text = config.Name or "Keybind",
                            Callback = config.Callback,
                        }
                    )

                    return keybind
                end

                function self:CreateColorPicker(config)
                    local label = Group:AddLabel(
                        config.Name or "Color"
                    )

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