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
    -- LILAC V1488 COLORS
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
                7,
                3,
                10
            )

        Scheme.MainColor =
            Color3.fromRGB(
                21,
                8,
                29
            )

        Scheme.AccentColor =
            Color3.fromRGB(
                194,
                94,
                230
            )

        Scheme.OutlineColor =
            Color3.fromRGB(
                88,
                40,
                108
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
    -- OFFICIAL OBSIDIAN WINDOW BACKGROUND
    --
    -- The current Obsidian API accepts either a string
    -- or number and writes it into Window.BackgroundImage.
    --------------------------------------------------

    pcall(function()
        Window:SetBackgroundImage(
            "rbxassetid://137423681201950"
        )

        Window:SetBackgroundImageEnabled(
            true
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
    -- FULLSCREEN BACKGROUND
    --
    -- Kept in a SEPARATE low DisplayOrder ScreenGui.
    -- This means it never sits above / over the menu and
    -- cannot steal the drag area. It follows Library.Toggled.
    --------------------------------------------------

    local FullscreenGui
    local FullscreenImage
    local FullscreenConnection

    pcall(function()
        local CoreGui =
            game:GetService(
                "CoreGui"
            )

        local old =
            CoreGui:FindFirstChild(
                "LilacV1488Fullscreen"
            )

        if old then
            old:Destroy()
        end

        FullscreenGui =
            Instance.new(
                "ScreenGui"
            )

        FullscreenGui.Name =
            "LilacV1488Fullscreen"

        FullscreenGui.IgnoreGuiInset =
            true

        FullscreenGui.ResetOnSpawn =
            false

        FullscreenGui.DisplayOrder =
            -1000

        FullscreenGui.ZIndexBehavior =
            Enum.ZIndexBehavior.Global

        FullscreenGui.Parent =
            CoreGui

        FullscreenImage =
            Instance.new(
                "ImageLabel"
            )

        FullscreenImage.Name =
            "Background"

        FullscreenImage.BackgroundTransparency =
            1

        FullscreenImage.BorderSizePixel =
            0

        FullscreenImage.Position =
            UDim2.fromScale(
                0,
                0
            )

        FullscreenImage.Size =
            UDim2.fromScale(
                1,
                1
            )

        FullscreenImage.Image =
            "rbxassetid://99217170570093"

        FullscreenImage.ImageTransparency =
            0.38

        FullscreenImage.ScaleType =
            Enum.ScaleType.Crop

        -- Critical: never capture mouse input.
        FullscreenImage.Active =
            false

        FullscreenImage.Selectable =
            false

        FullscreenImage.ZIndex =
            -100

        FullscreenImage.Parent =
            FullscreenGui

        FullscreenImage.Visible =
            Library.Toggled == true

        --------------------------------------------------
        -- Dark lilac glass tint
        --------------------------------------------------

        local Tint =
            Instance.new(
                "Frame"
            )

        Tint.Name =
            "LilacTint"

        Tint.BackgroundColor3 =
            Color3.fromRGB(
                26,
                6,
                36
            )

        Tint.BackgroundTransparency =
            0.68

        Tint.BorderSizePixel =
            0

        Tint.Position =
            UDim2.fromScale(
                0,
                0
            )

        Tint.Size =
            UDim2.fromScale(
                1,
                1
            )

        Tint.Active =
            false

        Tint.ZIndex =
            -99

        Tint.Parent =
            FullscreenGui

        --------------------------------------------------
        -- Follow Obsidian's real toggle state.
        --------------------------------------------------

        FullscreenConnection =
            game:GetService(
                "RunService"
            ).RenderStepped:Connect(
                function()
                    if
                        not FullscreenImage
                        or not FullscreenImage.Parent
                    then
                        return
                    end

                    FullscreenImage.Visible =
                        Library.Toggled == true

                    Tint.Visible =
                        Library.Toggled == true
                end
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
        if FullscreenConnection then
            pcall(function()
                FullscreenConnection:Disconnect()
            end)

            FullscreenConnection =
                nil
        end

        if FullscreenGui then
            pcall(function()
                FullscreenGui:Destroy()
            end)

            FullscreenGui =
                nil
        end

        if self.Library then
            pcall(function()
                self.Library:Unload()
            end)
        end
    end

    return ZenWindow
end

return Obsidian