local Obsidian = {}

local REPO =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local LOGO = 95816097006870

local function loadLibrary()
    local source =
        game:HttpGet(REPO .. "Library.lua")

    return loadstring(source)()
end

function Obsidian.new(title, configFolder)
    local Library = loadLibrary()

    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true
    Library.ShowCustomCursor = true
    Library.GlobalSearch = true

    local ThemeManager
    local SaveManager

    pcall(function()
        ThemeManager = loadstring(
            game:HttpGet(REPO .. "addons/ThemeManager.lua")
        )()
    end)

    pcall(function()
        SaveManager = loadstring(
            game:HttpGet(REPO .. "addons/SaveManager.lua")
        )()
    end)

    --------------------------------------------------
    -- LILAC THEME
    --------------------------------------------------

    local LilacTheme = {
        FontColor = Color3.fromRGB(
            242, 230, 248
        ),

        MainColor = Color3.fromRGB(
            18, 9, 24
        ),

        AccentColor = Color3.fromRGB(
            194, 109, 228
        ),

        BackgroundColor = Color3.fromRGB(
            3, 2, 5
        ),

        OutlineColor = Color3.fromRGB(
            76, 38, 91
        ),

        FontFace = Font.fromEnum(
            Enum.Font.GothamMedium
        ),

        BackgroundImage =
            "rbxthumb://type=Asset&id=137423681201950&w=768&h=768",
    }

    Library.Scheme = LilacTheme

    pcall(function()
        Library:SetFont(
            Enum.Font.GothamMedium
        )
    end)

    --------------------------------------------------
    -- THEME MANAGER
    --------------------------------------------------

    if ThemeManager then
        pcall(function()
            ThemeManager:SetLibrary(
                Library
            )

            ThemeManager:SetFolder(
                configFolder
                    or "ZenWare/Lilac"
            )

            ThemeManager:SetDefaultTheme(
                LilacTheme
            )
        end)
    end

    --------------------------------------------------
    -- SAVE MANAGER
    --------------------------------------------------

    if SaveManager then
        pcall(function()
            SaveManager:SetLibrary(
                Library
            )

            SaveManager:SetFolder(
                configFolder
                    or "ZenWare/Configs"
            )

            SaveManager:SetSubFolder(
                tostring(
                    game.PlaceId
                )
            )

            SaveManager:IgnoreThemeSettings()

            SaveManager:SetIgnoreIndexes({
                "MenuKeybind",
                "UIToggleKey",
            })
        end)
    end

    --------------------------------------------------
    -- WINDOW
    --------------------------------------------------

    local Window = Library:CreateWindow({
        Title =
            title
            or "🌸 Lilac v1488",

        Footer =
            "zenware",

        Icon = LOGO,

        IconSize =
            UDim2.fromOffset(
                18,
                18
            ),

        BackgroundImage =
            "rbxthumb://type=Asset&id=137423681201950&w=768&h=768",

        NotifySide = "Right",

        ShowCustomCursor = true,
        AutoShow = true,
        Resizable = true,
        Center = true,

        Glow = true,
        GlobalSearch = true,

        CornerRadius = 10,

        Animations = {
            ToggleWindow = true,
            TabSwitch = true,
            Groupbox = true,
            Dropdown = true,
            KeyPicker = true,
        },

        TabTransitionTime = 0.20,
        TabSwipeOffset = 24,
        TabSwipeFrom = "bottom",

        TabButtonsStyle = {
            Gap = 5,
            Padding = 9,
            CornerRadius = 7,
            Indicator = true,
            IndicatorWidth = 3,
            IndicatorHeight = 22,
        },

    --------------------------------------------------
    -- FULLSCREEN LILAC IMAGE
    --------------------------------------------------

    pcall(function()
        local ScreenGui =
            Library.ScreenGui

        if not ScreenGui then
            return
        end

        local old =
            ScreenGui:FindFirstChild(
                "LilacFullscreenBackground"
            )

        if old then
            old:Destroy()
        end

        ScreenGui.IgnoreGuiInset =
            true

        local background =
            Instance.new(
                "ImageLabel"
            )

        background.Name =
            "LilacFullscreenBackground"

        background.Position =
            UDim2.fromScale(
                0,
                0
            )

        background.Size =
            UDim2.fromScale(
                1,
                1
            )

        background.BackgroundTransparency =
            1

        background.BorderSizePixel =
            0

        background.Image =
            "rbxthumb://type=Asset&id=99217170570093&w=1920&h=1080"

        background.ImageTransparency =
            0.42

        background.ScaleType =
            Enum.ScaleType.Crop

        background.Active =
            false

        background.Selectable =
            false

        background.ZIndex =
            0

        background.Visible =
            Library.Toggled == true

        background.Parent =
            ScreenGui

        local tint =
            Instance.new(
                "Frame"
            )

        tint.Name =
            "LilacFullscreenTint"

        tint.Position =
            UDim2.fromScale(
                0,
                0
            )

        tint.Size =
            UDim2.fromScale(
                1,
                1
            )

        tint.BackgroundColor3 =
            Color3.fromRGB(
                12,
                3,
                18
            )

        tint.BackgroundTransparency =
            0.70

        tint.BorderSizePixel =
            0

        tint.Active =
            false

        tint.ZIndex =
            1

        tint.Visible =
            background.Visible

        tint.Parent =
            ScreenGui

        task.spawn(function()
            while
                background.Parent
                and not Library.Unloaded
            do
                local visible =
                    Library.Toggled == true

                background.Visible =
                    visible

                tint.Visible =
                    visible

                task.wait(
                    0.05
                )
            end
        end)
    end)

    })

    pcall(function()
        Window:SetBackgroundImage(
            "rbxthumb://type=Asset&id=137423681201950&w=768&h=768"
        )
    end)

    pcall(function()
        Window:SetCornerRadius(
            10
        )
    end)

    pcall(function()
        Window:SetAnimations({
            ToggleWindow = true,
            TabSwitch = true,
            Groupbox = true,
            Dropdown = true,
            KeyPicker = true,
        }, 0.20, 24, "bottom")
    end)

    local ZenWindow = {
        Library = Library,
        Window = Window,
        ThemeManager = ThemeManager,
        SaveManager = SaveManager,
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
            local Tab =
                self.Window.Window:AddTab(
                    tabName,
                    icon
                )

            local ZenTab = {
                Tab = Tab,
                Group = nil,
            }

            --------------------------------------------------
            -- GROUP
            --------------------------------------------------

            function ZenTab:CreateSection(name, icon)
                local Group

                self._ColumnIndex =
                    (self._ColumnIndex or 0)
                    + 1

                local useRight =
                    (
                        self._ColumnIndex % 2
                    ) == 0

                if useRight then
                    local ok, result =
                        pcall(function()
                            if icon then
                                return self.Tab:AddRightGroupbox(
                                    name,
                                    icon
                                )
                            end

                            return self.Tab:AddRightGroupbox(
                                name
                            )
                        end)

                    if ok and result then
                        Group =
                            result
                    end
                end

                if not Group then
                    if icon then
                        Group =
                            self.Tab:AddLeftGroupbox(
                                name,
                                icon
                            )
                    else
                        Group =
                            self.Tab:AddLeftGroupbox(
                                name
                            )
                    end
                end

                self.Group = Group

                --------------------------------------------------
                -- BUTTON
                --------------------------------------------------

                function self:CreateButton(config)
                    config = config or {}

                    return Group:AddButton({
                        Text =
                            config.Name
                            or "Button",

                        Func =
                            config.Callback,
                    })
                end

                --------------------------------------------------
                -- TOGGLE
                --------------------------------------------------

                function self:CreateToggle(config)
                    config = config or {}

                    return Group:AddToggle(
                        config.Flag
                            or config.Name
                            or "Toggle",

                        {
                            Text =
                                config.Name
                                or "Toggle",

                            Default =
                                config.Default == true,

                            Callback =
                                config.Callback,
                        }
                    )
                end

                --------------------------------------------------
                -- SLIDER
                --------------------------------------------------

                function self:CreateSlider(config)
                    config = config or {}

                    return Group:AddSlider(
                        config.Flag
                            or config.Name
                            or "Slider",

                        {
                            Text =
                                config.Name
                                or "Slider",

                            Default =
                                config.Default
                                or 0,

                            Min =
                                config.Min
                                or 0,

                            Max =
                                config.Max
                                or 100,

                            Rounding =
                                config.Rounding
                                or 2,

                            Compact = false,

                            Callback =
                                config.Callback,
                        }
                    )
                end

                --------------------------------------------------
                -- TEXT BOX
                --------------------------------------------------

                function self:CreateTextBox(config)
                    config = config or {}

                    local input =
                        Group:AddInput(
                            config.Flag
                                or config.Name
                                or "Input",

                            {
                                Text =
                                    config.Name
                                    or "Input",

                                Placeholder =
                                    config.Placeholder
                                    or "",

                                Default =
                                    config.Default
                                    or "",

                                Callback =
                                    config.Callback,
                            }
                        )

                    local api = {}

                    function api:GetText()
                        if
                            input
                            and input.Value ~= nil
                        then
                            return tostring(
                                input.Value
                            )
                        end

                        return ""
                    end

                    function api:SetText(value)
                        if
                            input
                            and input.SetValue
                        then
                            input:SetValue(
                                tostring(
                                    value or ""
                                )
                            )
                        end
                    end

                    function api:Focus()
                        if
                            input
                            and input.Input
                        then
                            input.Input:CaptureFocus()
                        end
                    end

                    return api
                end

                --------------------------------------------------
                -- KEYBIND
                --------------------------------------------------

                function self:CreateKeybind(config)
                    config = config or {}

                    local defaultKey =
                        config.Default
                        or "RightControl"

                    if typeof(defaultKey)
                        == "EnumItem"
                    then
                        defaultKey =
                            defaultKey.Name
                    elseif
                        type(defaultKey)
                        ~= "string"
                    then
                        defaultKey =
                            "RightControl"
                    end

                    local label =
                        Group:AddLabel(
                            config.Name
                                or "Keybind"
                        )

                    local keybind =
                        label:AddKeyPicker(
                            config.Flag
                                or config.Name
                                or "Keybind",

                            {
                                Default =
                                    defaultKey,

                                Mode =
                                    "Toggle",

                                Text =
                                    config.Name
                                    or "Keybind",

                                Callback =
                                    config.Callback,
                            }
                        )

                    return keybind
                end

                --------------------------------------------------
                -- COLOR PICKER
                --------------------------------------------------

                function self:CreateColorPicker(config)
                    config = config or {}

                    local label =
                        Group:AddLabel(
                            config.Name
                                or "Color"
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

                function self:CreateParagraph(config)
                    config = config or {}

                    return Group:AddLabel({
                        Text =
                            tostring(
                                config.Title
                                or ""
                            )
                            .. "\n"
                            .. tostring(
                                config.Content
                                or ""
                            ),

                        DoesWrap = true,
                    })
                end

                --------------------------------------------------
                -- IMAGE
                --------------------------------------------------

                function self:CreateImage(config)
                    config = config or {}

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
                                config.Height
                                or 120,

                            Transparency =
                                config.Transparency
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

                function self:CreateConfigSection()
                    local built = false

                    if
                        self.Window.SaveManager
                        and self.Window.SaveManager.BuildConfigSection
                    then
                        built = pcall(function()
                            self.Window.SaveManager:
                                BuildConfigSection(
                                    self.Tab
                                )
                        end)
                    end

                    if not built then
                        Group:AddLabel(
                            "Configuration"
                        )
                    end

                    if
                        self.Window.ThemeManager
                        and self.Window.ThemeManager.ApplyToTab
                    then
                        pcall(function()
                            self.Window.ThemeManager:
                                ApplyToTab(
                                    self.Tab
                                )
                        end)
                    end
                end

                return Group
            end

            return ZenTab
        end

        return Section
    end

    --------------------------------------------------
    -- NOTIFICATION
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
                config.IconColor
                or Color3.fromRGB(
                    194,
                    109,
                    228
                ),
        })
    end

    --------------------------------------------------
    -- TOGGLE KEY
    --------------------------------------------------

    function ZenWindow:SetToggleKey(key)
        if
            self.Library.Options
            and self.Library.Options.MenuKeybind
            and self.Library.Options.MenuKeybind.SetValue
        then
            local keyName

            if typeof(key) == "EnumItem" then
                keyName = key.Name
            elseif type(key) == "string" then
                keyName = key
            else
                keyName = "RightControl"
            end

            self.Library.Options.MenuKeybind:SetValue({
                keyName,
                "Toggle",
            })

            return
        end

        self.ToggleKey = key
    end

    --------------------------------------------------
    -- CONFIG / THEME HELPERS
    --------------------------------------------------

    function ZenWindow:SaveConfig(name)
        if
            not self.SaveManager
            or not self.SaveManager.Save
        then
            return false
        end

        return pcall(function()
            self.SaveManager:Save(
                name or "Default"
            )
        end)
    end

    function ZenWindow:LoadConfig(name)
        if
            not self.SaveManager
            or not self.SaveManager.Load
        then
            return false
        end

        return pcall(function()
            self.SaveManager:Load(
                name or "Default"
            )
        end)
    end

    function ZenWindow:LoadAutoloadConfig()
        if
            not self.SaveManager
            or not self.SaveManager.LoadAutoloadConfig
        then
            return false
        end

        return pcall(function()
            self.SaveManager:
                LoadAutoloadConfig()
        end)
    end

    function ZenWindow:ApplyLilacTheme()
        if
            not self.ThemeManager
            or not self.ThemeManager.SetDefaultTheme
        then
            return false
        end

        local ok = pcall(function()
            self.ThemeManager:
                SetDefaultTheme({
                    FontColor =
                        Color3.fromRGB(
                            242, 230, 248
                        ),

                    MainColor =
                        Color3.fromRGB(
                            18, 9, 24
                        ),

                    AccentColor =
                        Color3.fromRGB(
                            194, 109, 228
                        ),

                    BackgroundColor =
                        Color3.fromRGB(
                            3, 2, 5
                        ),

                    OutlineColor =
                        Color3.fromRGB(
                            76, 38, 91
                        ),

                    FontFace =
                        Font.fromEnum(
                            Enum.Font.GothamMedium
                        ),

                    BackgroundImage =
                        "rbxthumb://type=Asset&id=137423681201950&w=768&h=768",
                })

            self.ThemeManager:
                LoadDefault()
        end)

        return ok
    end

    --------------------------------------------------
    -- AUTOSAVE
    --------------------------------------------------

    function ZenWindow:SetAutoSave(enabled)
        self.AutoSave =
            enabled == true

        if
            self.AutoSave
            and self.SaveManager
            and self.SaveManager.LoadAutoloadConfig
        then
            pcall(function()
                self.SaveManager:
                    LoadAutoloadConfig()
            end)
        end
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