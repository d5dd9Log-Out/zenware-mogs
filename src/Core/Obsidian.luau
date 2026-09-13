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

    --------------------------------------------------
    -- LILAC V1488 PALETTE
    --------------------------------------------------

    pcall(function()
        local Scheme = Library.Scheme

        Scheme.FontColor =
            Color3.fromRGB(
                245,
                235,
                250
            )

        Scheme.BackgroundColor =
            Color3.fromRGB(
                8,
                3,
                12
            )

        Scheme.MainColor =
            Color3.fromRGB(
                22,
                8,
                30
            )

        Scheme.AccentColor =
            Color3.fromRGB(
                194,
                91,
                230
            )

        Scheme.OutlineColor =
            Color3.fromRGB(
                92,
                42,
                112
            )

        Scheme.Font =
            Font.fromEnum(
                Enum.Font.Gotham
            )

        Scheme.RedColor =
            Color3.fromRGB(
                255,
                92,
                121
            )

        Scheme.DestructiveColor =
            Color3.fromRGB(
                225,
                63,
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

    local Window = Library:CreateWindow({
        Title =
            title
            or "🌸 Lilac v1488",

        Footer =
            "zenware",

        Icon = LOGO,

        NotifySide = "Right",

        ShowCustomCursor = true,
        AutoShow = true,
        Resizable = true,
        Center = true,

        Glow = true,
        GlobalSearch = true,
    })

    --------------------------------------------------
    -- LILAC IMAGE INSIDE THE MENU ONLY
    --
    -- IMPORTANT:
    -- This is NOT a fullscreen ScreenGui.
    -- It is parented to the Obsidian window itself,
    -- so it disappears automatically when the menu
    -- is hidden.
    --------------------------------------------------

    local MENU_IMAGE =
        "rbxassetid://137423681201950"

    local MenuRoot =
        Window.Window

    -- Use Obsidian's built-in window artwork system.
    pcall(function()
        Window:SetBackgroundImage(MENU_IMAGE)
        local BackgroundImage = MenuRoot:FindFirstChild("BackgroundImage")
        if BackgroundImage and BackgroundImage:IsA("ImageLabel") then
            BackgroundImage.ImageTransparency = 0.68
            BackgroundImage.BackgroundTransparency = 1
        end
    end)

    --------------------------------------------------
    -- FULLSCREEN LILAC BACKGROUND
    --
    -- This is separate from the menu artwork.
    -- It is parented to Obsidian's ScreenGui and follows
    -- the actual window Visible state, so hiding the UI
    -- hides this background too.
    --------------------------------------------------

    local FULLSCREEN_IMAGE =
        "rbxassetid://99217170570093"

    local FullscreenLayer

    pcall(function()
        local ScreenGui =
            Library.ScreenGui

        if ScreenGui then
            local old =
                ScreenGui:FindFirstChild(
                    "LilacFullscreenBackground"
                )

            if old then
                old:Destroy()
            end

            FullscreenLayer =
                Instance.new(
                    "ImageLabel"
                )

            FullscreenLayer.Name =
                "LilacFullscreenBackground"

            FullscreenLayer.BackgroundColor3 =
                Color3.fromRGB(
                    5,
                    2,
                    8
                )

            FullscreenLayer.BackgroundTransparency =
                0.12

            FullscreenLayer.BorderSizePixel =
                0

            FullscreenLayer.Position =
                UDim2.fromScale(
                    0,
                    0
                )

            FullscreenLayer.Size =
                UDim2.fromScale(
                    1,
                    1
                )

            FullscreenLayer.Image =
                FULLSCREEN_IMAGE

            -- Semi-transparent as requested.
            FullscreenLayer.ImageTransparency =
                0.58

            FullscreenLayer.ScaleType =
                Enum.ScaleType.Crop

            FullscreenLayer.Active = false
            FullscreenLayer.Selectable = false
            FullscreenLayer.ZIndex = 0

            FullscreenLayer.Visible =
                Library.Toggled == true

            FullscreenLayer.Parent =
                ScreenGui

            task.spawn(function()
                while FullscreenLayer and FullscreenLayer.Parent and not Library.Unloaded do
                    FullscreenLayer.Visible = Library.Toggled == true
                    task.wait(0.05)
                end
            end)

            local FullscreenGradient =
                Instance.new(
                    "UIGradient"
                )

            FullscreenGradient.Rotation =
                25

            FullscreenGradient.Color =
                ColorSequence.new({
                    ColorSequenceKeypoint.new(
                        0,
                        Color3.fromRGB(
                            5,
                            1,
                            8
                        )
                    ),

                    ColorSequenceKeypoint.new(
                        0.35,
                        Color3.fromRGB(
                            45,
                            10,
                            58
                        )
                    ),

                    ColorSequenceKeypoint.new(
                        0.58,
                        Color3.fromRGB(
                            93,
                            29,
                            112
                        )
                    ),

                    ColorSequenceKeypoint.new(
                        1,
                        Color3.fromRGB(
                            5,
                            1,
                            8
                        )
                    ),
                })

            FullscreenGradient.Transparency =
                NumberSequence.new({
                    NumberSequenceKeypoint.new(
                        0,
                        0.20
                    ),

                    NumberSequenceKeypoint.new(
                        0.50,
                        0.03
                    ),

                    NumberSequenceKeypoint.new(
                        1,
                        0.24
                    ),
                })

            FullscreenGradient.Parent =
                FullscreenLayer

            -- Keep the fullscreen layer synchronized with the real
            -- Obsidian window. RightControl / unload / visibility changes
            -- therefore do not leave a ghost background behind.
            ScreenGui.Destroying:Connect(
                function()
                    FullscreenLayer = nil
                end
            )
        end
    end)

    pcall(function()
        MenuRoot.BackgroundTransparency =
            0.10
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
    -- LILAC THEME HELPER
    --------------------------------------------------

    function ZenWindow:SetLilacBackgroundVisible(visible)
        if FullscreenLayer then
            FullscreenLayer.Visible =
                visible == true
        end
    end

    function ZenWindow:ApplyLilacTheme()
        pcall(function()
            local Scheme =
                self.Library.Scheme

            Scheme.FontColor =
                Color3.fromRGB(
                    245,
                    235,
                    250
                )

            Scheme.BackgroundColor =
                Color3.fromRGB(
                    8,
                    3,
                    12
                )

            Scheme.MainColor =
                Color3.fromRGB(
                    22,
                    8,
                    30
                )

            Scheme.AccentColor =
                Color3.fromRGB(
                    194,
                    91,
                    230
                )

            Scheme.OutlineColor =
                Color3.fromRGB(
                    92,
                    42,
                    112
                )
        end)
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