local Obsidian = {}

local REPO =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local LOGO = 95816097006870

local function loadLibrary()
    local source = game:HttpGet(REPO .. "Library.lua")
    return loadstring(source)()
end

function Obsidian.new(title, configFolder)
    local Library = loadLibrary()

    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true

    local Window = Library:CreateWindow({
        Title = title or "ZenWare V3",
        Footer = "ZenWare V3",
        Icon = LOGO,

        NotifySide = "Right",

        ShowCustomCursor = true,
        AutoShow = true,
        Resizable = true,
        Center = true,

        Glow = true,
        GlobalSearch = true,
    })

    local ZenWindow = {
        Library = Library,
        Window = Window,
        Sections = {},
    }

    --------------------------------------------------
    -- SECTION
    --------------------------------------------------

    function ZenWindow:CreateSection(sectionName)
        local Section = {
            Name = sectionName,
            Window = self,
        }

        --------------------------------------------------
        -- TAB
        --------------------------------------------------

        function Section:CreateTab(tabName, icon)
            local Tab = self.Window.Window:AddTab(
                tabName,
                icon
            )

            local ZenTab = {
                Tab = Tab,
                Group = nil,
            }

            --------------------------------------------------
            -- CREATE SECTION / GROUPBOX
            --------------------------------------------------

            function ZenTab:CreateSection(name, icon)
                local Group

                if icon then
                    Group = self.Tab:AddLeftGroupbox(
                        name,
                        icon
                    )
                else
                    Group = self.Tab:AddLeftGroupbox(
                        name
                    )
                end

                self.Group = Group

                return Group
            end

            --------------------------------------------------
            -- GET GROUP
            --------------------------------------------------

            local function getGroup(self)
                return self.Group
            end

            --------------------------------------------------
            -- BUTTON
            --------------------------------------------------

            function ZenTab:CreateButton(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                return Group:AddButton({
                    Text = config.Name or "Button",
                    Func = config.Callback,
                })
            end

            --------------------------------------------------
            -- TOGGLE
            --------------------------------------------------

            function ZenTab:CreateToggle(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                return Group:AddToggle(
                    config.Flag
                        or config.Name
                        or "Toggle",
                    {
                        Text = config.Name or "Toggle",
                        Default = config.Default == true,
                        Callback = config.Callback,
                    }
                )
            end

            --------------------------------------------------
            -- SLIDER
            --------------------------------------------------

            function ZenTab:CreateSlider(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                return Group:AddSlider(
                    config.Flag
                        or config.Name
                        or "Slider",
                    {
                        Text = config.Name or "Slider",

                        Default =
                            tonumber(config.Default)
                            or tonumber(config.Min)
                            or 0,

                        Min =
                            tonumber(config.Min)
                            or 0,

                        Max =
                            tonumber(config.Max)
                            or 100,

                        Rounding =
                            tonumber(config.Rounding)
                            or 2,

                        Compact = false,

                        Callback = config.Callback,
                    }
                )
            end

            --------------------------------------------------
            -- TEXT BOX
            --------------------------------------------------

            function ZenTab:CreateTextBox(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return {
                        GetText = function()
                            return ""
                        end,

                        SetText = function()
                        end,

                        Focus = function()
                        end,
                    }
                end

                local input = Group:AddInput(
                    config.Flag
                        or config.Name
                        or "Input",
                    {
                        Text = config.Name or "Input",

                        Placeholder =
                            config.Placeholder
                            or "",

                        Default =
                            tostring(
                                config.Default
                                or ""
                            ),

                        Callback =
                            config.Callback,
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
                        input:SetValue(
                            tostring(value or "")
                        )
                    end
                end

                function api:Focus()
                    if input and input.Input then
                        input.Input:CaptureFocus()
                    end
                end

                return api
            end

            --------------------------------------------------
            -- KEYBIND
            --------------------------------------------------

            function ZenTab:CreateKeybind(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                local defaultKey =
                    config.Default
                    or Enum.KeyCode.F

                if typeof(defaultKey) == "EnumItem" then
                    defaultKey = defaultKey.Name
                elseif type(defaultKey) ~= "string" then
                    defaultKey = "F"
                end

                local label = Group:AddLabel(
                    config.Name or "Keybind"
                )

                local keybind = label:AddKeyPicker(
                    config.Flag
                        or config.Name
                        or "Keybind",
                    {
                        Default = defaultKey,
                        Mode = "Toggle",
                        Text = config.Name or "Keybind",
                        Callback = config.Callback,
                    }
                )

                return keybind
            end

            --------------------------------------------------
            -- COLOR PICKER
            --------------------------------------------------

            function ZenTab:CreateColorPicker(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                local label = Group:AddLabel(
                    config.Name or "Color"
                )

                return label:AddColorPicker(
                    config.Flag
                        or config.Name
                        or "Color",
                    {
                        Default =
                            config.Default,

                        Title =
                            config.Name
                            or "Color",

                        Callback =
                            config.Callback,
                    }
                )
            end

            --------------------------------------------------
            -- PARAGRAPH
            --------------------------------------------------

            function ZenTab:CreateParagraph(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                local title =
                    tostring(
                        config.Title
                        or ""
                    )

                local content =
                    tostring(
                        config.Content
                        or ""
                    )

                local text = title

                if content ~= "" then
                    text =
                        title
                        .. "\n"
                        .. content
                end

                return Group:AddLabel({
                    Text = text,
                    DoesWrap = true,
                })
            end

            --------------------------------------------------
            -- IMAGE
            --------------------------------------------------

            function ZenTab:CreateImage(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                if not config.Image then
                    return nil
                end

                return Group:AddImage(
                    config.Flag
                        or config.Name
                        or "Image",
                    {
                        Image =
                            config.Image,

                        Height =
                            tonumber(config.Height)
                            or 120,

                        Transparency =
                            tonumber(
                                config.Transparency
                            )
                            or 0,

                        Color =
                            config.Color,

                        ScaleType =
                            config.ScaleType
                            or Enum.ScaleType.Fit,
                    }
                )
            end

            --------------------------------------------------
            -- CONFIG SECTION
            --------------------------------------------------

            function ZenTab:CreateConfigSection()
                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                Group:AddLabel("Configuration")

                return Group
            end

            --------------------------------------------------
            -- DROPDOWN
            --------------------------------------------------

            function ZenTab:CreateDropdown(config)
                config = config or {}

                local Group = getGroup(self)

                if not Group then
                    return nil
                end

                return Group:AddDropdown(
                    config.Flag
                        or config.Name
                        or "Dropdown",
                    {
                        Values =
                            config.Options
                            or {},

                        Default =
                            config.Default,

                        Multi =
                            config.MultiSelect
                            == true,

                        Text =
                            config.Name
                            or "Dropdown",

                        Callback =
                            config.Callback,
                    }
                )
            end

            return ZenTab
        end

        return Section
    end

    --------------------------------------------------
    -- NOTIFY
    --------------------------------------------------

    function ZenWindow:Notify(config)
        config = config or {}

        self.Library:Notify({
            Title =
                config.Title
                or "ZenWare V3",

            Description =
                config.Description
                or "",

            Time =
                config.Duration
                or 3,

            Icon =
                config.Icon,

            BigIcon =
                config.BigIcon,

            IconColor =
                config.IconColor,
        })
    end

    --------------------------------------------------
    -- TOGGLE KEY
    --------------------------------------------------

    function ZenWindow:SetToggleKey(key)
        local keyName = "RightControl"

        if typeof(key) == "EnumItem" then
            keyName = key.Name
        elseif type(key) == "string" then
            keyName = key
        end

        if
            self.Library.Options
            and self.Library.Options.MenuKeybind
            and self.Library.Options.MenuKeybind.SetValue
        then
            pcall(function()
                self.Library.Options.MenuKeybind:SetValue({
                    keyName,
                    "Toggle",
                })
            end)

            return
        end

        self.ToggleKey = key
    end

    --------------------------------------------------
    -- AUTOSAVE
    --------------------------------------------------

    function ZenWindow:SetAutoSave(enabled)
        self.AutoSave =
            enabled == true
    end

    --------------------------------------------------
    -- DESTROY
    --------------------------------------------------

    function ZenWindow:Destroy()
        if self.Library then
            pcall(function()
                self.Library:Unload()
            end)
        end
    end

    return ZenWindow
end

return Obsidian