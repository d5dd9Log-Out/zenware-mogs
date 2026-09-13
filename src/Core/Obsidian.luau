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
    -- LILAC V1488 VISUAL LAYER
    --------------------------------------------------

    local LILAC_IMAGE =
        "rbxassetid://91469127281628"

    local LILAC_PURPLE =
        Color3.fromRGB(
            164,
            76,
            204
        )

    local LILAC_LIGHT =
        Color3.fromRGB(
            222,
            153,
            244
        )

    local LILAC_DARK =
        Color3.fromRGB(
            6,
            2,
            10
        )

    pcall(function()
        local CoreGui =
            game:GetService(
                "CoreGui"
            )

        local old =
            CoreGui:FindFirstChild(
                "LilacV1488Backdrop"
            )

        if old then
            old:Destroy()
        end

        local Backdrop =
            Instance.new(
                "ScreenGui"
            )

        Backdrop.Name =
            "LilacV1488Backdrop"

        Backdrop.IgnoreGuiInset =
            true

        Backdrop.ResetOnSpawn =
            false

        Backdrop.DisplayOrder =
            -1000

        Backdrop.ZIndexBehavior =
            Enum.ZIndexBehavior.Global

        Backdrop.Parent =
            CoreGui

        --------------------------------------------------
        -- IMAGE
        --------------------------------------------------

        local Image =
            Instance.new(
                "ImageLabel"
            )

        Image.Name =
            "LilacArtwork"

        Image.BackgroundTransparency =
            1

        Image.BorderSizePixel =
            0

        Image.Position =
            UDim2.fromScale(
                0,
                0
            )

        Image.Size =
            UDim2.fromScale(
                1,
                1
            )

        Image.Image =
            LILAC_IMAGE

        Image.ImageTransparency =
            0.32

        Image.ScaleType =
            Enum.ScaleType.Crop

        Image.ZIndex =
            1

        Image.Parent =
            Backdrop

        --------------------------------------------------
        -- IMAGE TINT
        --------------------------------------------------

        local ImageGradient =
            Instance.new(
                "UIGradient"
            )

        ImageGradient.Rotation =
            25

        ImageGradient.Color =
            ColorSequence.new({
                ColorSequenceKeypoint.new(
                    0,
                    LILAC_DARK
                ),

                ColorSequenceKeypoint.new(
                    0.30,
                    LILAC_PURPLE
                ),

                ColorSequenceKeypoint.new(
                    0.52,
                    LILAC_LIGHT
                ),

                ColorSequenceKeypoint.new(
                    0.76,
                    LILAC_PURPLE
                ),

                ColorSequenceKeypoint.new(
                    1,
                    LILAC_DARK
                ),
            })

        ImageGradient.Transparency =
            NumberSequence.new({
                NumberSequenceKeypoint.new(
                    0,
                    0.22
                ),

                NumberSequenceKeypoint.new(
                    0.25,
                    0.05
                ),

                NumberSequenceKeypoint.new(
                    0.50,
                    0
                ),

                NumberSequenceKeypoint.new(
                    0.78,
                    0.08
                ),

                NumberSequenceKeypoint.new(
                    1,
                    0.26
                ),
            })

        ImageGradient.Parent =
            Image

        --------------------------------------------------
        -- GLASS / PURPLE OVERLAY
        --------------------------------------------------

        local Overlay =
            Instance.new(
                "Frame"
            )

        Overlay.Name =
            "LilacOverlay"

        Overlay.BackgroundColor3 =
            Color3.fromRGB(
                14,
                5,
                20
            )

        Overlay.BackgroundTransparency =
            0.34

        Overlay.BorderSizePixel =
            0

        Overlay.Size =
            UDim2.fromScale(
                1,
                1
            )

        Overlay.ZIndex =
            2

        Overlay.Parent =
            Backdrop

        local OverlayGradient =
            Instance.new(
                "UIGradient"
            )

        OverlayGradient.Rotation =
            135

        OverlayGradient.Color =
            ColorSequence.new({
                ColorSequenceKeypoint.new(
                    0,
                    Color3.fromRGB(
                        8,
                        2,
                        12
                    )
                ),

                ColorSequenceKeypoint.new(
                    0.38,
                    Color3.fromRGB(
                        63,
                        21,
                        78
                    )
                ),

                ColorSequenceKeypoint.new(
                    0.58,
                    Color3.fromRGB(
                        104,
                        43,
                        126
                    )
                ),

                ColorSequenceKeypoint.new(
                    1,
                    Color3.fromRGB(
                        5,
                        2,
                        9
                    )
                ),
            })

        OverlayGradient.Transparency =
            NumberSequence.new({
                NumberSequenceKeypoint.new(
                    0,
                    0.25
                ),

                NumberSequenceKeypoint.new(
                    0.48,
                    0.02
                ),

                NumberSequenceKeypoint.new(
                    1,
                    0.34
                ),
            })

        OverlayGradient.Parent =
            Overlay

        --------------------------------------------------
        -- SOFT CENTER GLOW
        --------------------------------------------------

        local Glow =
            Instance.new(
                "Frame"
            )

        Glow.Name =
            "CenterGlow"

        Glow.BackgroundColor3 =
            LILAC_PURPLE

        Glow.BackgroundTransparency =
            0.90

        Glow.BorderSizePixel =
            0

        Glow.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        Glow.Position =
            UDim2.fromScale(
                0.5,
                0.5
            )

        Glow.Size =
            UDim2.fromScale(
                0.75,
                0.72
            )

        Glow.ZIndex =
            3

        Glow.Parent =
            Backdrop

        local GlowCorner =
            Instance.new(
                "UICorner"
            )

        GlowCorner.CornerRadius =
            UDim.new(
                0.16,
                0
            )

        GlowCorner.Parent =
            Glow
    end)

    --------------------------------------------------
    -- LILAC WINDOW PALETTE
    --------------------------------------------------

    pcall(function()
        local Scheme =
            Library.Scheme

        Scheme.FontColor =
            Color3.fromRGB(
                244,
                235,
                249
            )

        Scheme.MainColor =
            Color3.fromRGB(
                20,
                9,
                27
            )

        Scheme.AccentColor =
            Color3.fromRGB(
                192,
                94,
                224
            )

        Scheme.BackgroundColor =
            Color3.fromRGB(
                7,
                3,
                10
            )

        Scheme.OutlineColor =
            Color3.fromRGB(
                86,
                41,
                105
            )

        Scheme.RedColor =
            Color3.fromRGB(
                255,
                91,
                121
            )

        Scheme.DestructiveColor =
            Color3.fromRGB(
                225,
                62,
                94
            )

        Scheme.DarkColor =
            Color3.fromRGB(
                2,
                1,
                4
            )

        Scheme.WhiteColor =
            Color3.fromRGB(
                255,
                250,
                255
            )
    end)

    pcall(function()
        Window:SetFooter(
            "zenware"
        )

        Window:ChangeTitle(
            "🌸 Lilac v1488"
        )

        Window:SetCornerRadius(
            9
        )
    end)

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
                    Group:AddLabel(
                        "Configuration"
                    )
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
                config.IconColor,
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