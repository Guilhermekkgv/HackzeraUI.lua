local LinuxUI = {}

local localCore = game:GetService("CoreGui")
local localTween = game:GetService("TweenService")
local localUIS = game:GetService("UserInputService")

function createInstance(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props) do
        instance[prop] = value
    end
    return instance
end

local function dragFrame(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    localUIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    localUIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function LinuxUI:CreateHub(name)
    local hub = {}

    local screen = createInstance("ScreenGui", {
        Name = "LinuxUI_" .. name,
        Parent = self.localCore,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local mainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = screen,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 320, 0, 450),
        ZIndex = 10
    })

    local topBar = createInstance("Frame", {
        Name = "TopBar",
        Parent = mainFrame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })

    local title = createInstance("TextLabel", {
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 300, 0, 40),
        Font = Enum.Font.SourceSansBold,
        Text = name or "Linux Hub",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22
    })

    local contentHolder = createInstance("ScrollingFrame", {
        Name = "ContentHolder",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 300, 0, 390),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    })

    local contentLayout = createInstance("UIListLayout", {
        Parent = contentHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    dragFrame(mainFrame)

    function hub:AddSection(sectionName)
        local section = {}

        local sectionFrame = createInstance("Frame", {
            Name = sectionName or "Section",
            Parent = contentHolder,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(0, 280, 0, 0)
        })

        local sectionTitle = createInstance("TextLabel", {
            Name = "SectionTitle",
            Parent = sectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(0, 260, 0, 25),
            Font = Enum.Font.SourceSansSemibold,
            Text = sectionName or "Section",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 20
        })

        local elementsFrame = createInstance("ScrollingFrame", {
            Name = "Elements",
            Parent = sectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(0, 260, 0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
        })

        local elementsLayout = createInstance("UIListLayout", {
            Parent = elementsFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })

        local function updateLayout()
            local elementsHeight = elementsLayout.AbsoluteContentSize.Y + 45
            sectionFrame.Size = UDim2.new(0, 280, 0, elementsHeight)
            contentHolder.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end

        function section:AddButton(text, callback)
            local buttonFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 35)
            })

            local button = createInstance("TextButton", {
                Parent = buttonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSansBold,
                Text = text or "Button",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            button.MouseButton1Click:Connect(function()
                spawn(function()
                    pcall(callback or function() end)
                end)
            end)

            button.MouseButton1Down:Connect(function()
                self.localTween:Create(button, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)

            button.MouseButton1Up:Connect(function()
                self.localTween:Create(button, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            end)

            updateLayout()
        end

        function section:AddToggle(text, default, callback)
            local toggle = {Value = default or false}

            local toggleFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 35)
            })

            local toggleLabel = createInstance("TextLabel", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 180, 0, 35),
                Font = Enum.Font.SourceSansBold,
                Text = text or "Toggle",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            local toggleIndicator = createInstance("Frame", {
                Parent = toggleFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = toggle.Value and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 25, 0, 25)
            })

            local toggleButton = createInstance("TextButton", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function updateToggle()
                self.localTween:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = toggle.Value and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)}):Play()
                spawn(function()
                    pcall(function() callback(toggle.Value) end)
                end)
            end

            toggleButton.MouseButton1Click:Connect(function()
                toggle.Value = not toggle.Value
                updateToggle()
            end)

            updateToggle()
            updateLayout()

            return toggle
        end

        function section:AddSlider(text, min, max, default, callback)
            local slider = {Value = default or min}

            local sliderFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 50)
            })

            local sliderLabel = createInstance("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(0, 180, 0, 20),
                Font = Enum.Font.SourceSansBold,
                Text = text or "Slider",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            local sliderBar = createInstance("Frame", {
                Parent = sliderFrame,
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(0, 220, 0, 10)
            })

            local sliderFill = createInstance("Frame", {
                Parent = sliderBar,
                BackgroundColor3 = Color3.fromRGB(0, 180, 0),
                Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
            })

            local sliderButton = createInstance("TextButton", {
                Parent = sliderBar,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local sliderValue = createInstance("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.SourceSansBold,
                Text = tostring(slider.Value),
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 16
            })

            local dragging
            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)

            localUIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.Touch then
                    local mouseX = input.Position.X - sliderBar.AbsolutePosition.X
                    slider.Value = math.clamp(min + (max - min) * (mouseX / sliderBar.AbsoluteSize.X), min, max)
                    sliderFill.Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
                    sliderValue.Text = tostring(math.floor(slider.Value))
                    spawn(function()
                        pcall(function() callback(slider.Value) end)
                    end)
                end
            end)

            localUIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            updateLayout()
            return slider
        end

        function section:AddKeybind(text, defaultKey, callback)
            local keybind = {Key = defaultKey or Enum.KeyCode.Q}

            local keybindFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 35)
            })

            local keybindLabel = createInstance("TextLabel", {
                Parent = keybindFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 180, 0, 35),
                Font = Enum.Font.SourceSansBold,
                Text = text or "Keybind",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            local keyButton = createInstance("TextButton", {
                Parent = keybindFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.SourceSansBold,
                Text = keybind.Key.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16
            })

            localUIS.InputBegan:Connect(function(input)
                if input.KeyCode == keybind.Key then
                    spawn(function()
                        pcall(function() callback(input.KeyCode) end)
                    end)
                end
            end)

            keyButton.MouseButton1Click:Connect(function()
                keyButton.Text = "..."
                local input = localUIS.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    keybind.Key = input.KeyCode
                    keyButton.Text = keybind.Key.Name
                end
            end)

            updateLayout()
            return keybind
        end

        function section:AddDropdown(text, options, default, callback)
            local dropdown = {Value = default or options[1]}

            local dropdownFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 35)
            })

            local dropdownLabel = createInstance("TextLabel", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 180, 0, 35),
                Font = Enum.Font.SourceSansBold,
                Text = text or "Dropdown",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            local dropdownButton = createInstance("TextButton", {
                Parent = dropdownFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.SourceSansBold,
                Text = dropdown.Value,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16
            })

            local isOpen = false
            local optionsFrame = createInstance("Frame", {
                Parent = dropdownFrame,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(0, 240, 0, 0),
                ZIndex = 20,
                Visible = false
            })

            local optionsLayout = createInstance("UIListLayout", {
                Parent = optionsFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })

            for _, option in pairs(options) do
                local optionButton = createInstance("TextButton", {
                    Parent = optionsFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Size = UDim2.new(0, 230, 0, 25),
                    Font = Enum.Font.SourceSansBold,
                    Text = option,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 16
                })

                optionButton.MouseButton1Click:Connect(function()
                    dropdown.Value = option
                    dropdownButton.Text = option
                    isOpen = false
                    optionsFrame.Visible = false
                    dropdownFrame.Size = UDim2.new(0, 240, 0, 35)
                    spawn(function()
                        pcall(function() callback(dropdown.Value) end)
                    end)
                end)
            end

            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                optionsFrame.Visible = isOpen
                dropdownFrame.Size = isOpen and UDim2.new(0, 240, 0, optionsLayout.AbsoluteContentSize.Y + 45) or UDim2.new(0, 240, 0, 35)
                updateLayout()
            end)

            updateLayout()
            return dropdown
        end

        function section:AddColorPicker(text, defaultColor, callback)
            local colorPicker = {Value = defaultColor or Color3.fromRGB(255, 255, 255)}

            local pickerFrame = createInstance("Frame", {
                Parent = elementsFrame,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 240, 0, 35)
            })

            local pickerLabel = createInstance("TextLabel", {
                Parent = pickerFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 180, 0, 35),
                Font = Enum.Font.SourceSansBold,
                Text = text or "ColorPicker",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 18
            })

            local colorDisplay = createInstance("Frame", {
                Parent = pickerFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = colorPicker.Value,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 25, 0, 25)
            })

            local pickerButton = createInstance("TextButton", {
                Parent = pickerFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local pickerWindow = createInstance("Frame", {
                Parent = screen,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 200, 0, 150),
                ZIndex = 15,
                Visible = false
            })

            local colorWheel = createInstance("ImageButton", {
                Parent = pickerWindow,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(0, 100, 0, 100),
                Image = "rbxassetid://6020299385"
            })

            local wheelPicker = createInstance("Frame", {
                Parent = colorWheel,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 10, 0, 10)
            })

            local brightnessBar = createInstance("Frame", {
                Parent = pickerWindow,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0, 120, 0, 10),
                Size = UDim2.new(0, 20, 0, 100)
            })

            local brightnessGradient = createInstance("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0, colorPicker.Value), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))},
                Parent = brightnessBar
            })

            local brightnessSlider = createInstance("Frame", {
                Parent = brightnessBar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 5)
            })

            local draggingWheel
            local function updateColor(position)
                local center = Vector2.new(colorWheel.AbsolutePosition.X + colorWheel.AbsoluteSize.X / 2, colorWheel.AbsolutePosition.Y + colorWheel.AbsoluteSize.Y / 2)
                local saturation = math.clamp((position - center).Magnitude / (colorWheel.AbsoluteSize.X / 2), 0, 1)
                local hue = math.clamp((math.pi - math.atan2(center.Y - position.Y, center.X - position.X)) / (math.pi * 2), 0, 1)
                draggingWheel = Color3.fromHSV(hue, saturation, 1 - (brightnessSlider.Position.Y.Offset / brightnessBar.AbsoluteSize.Y))
                colorDisplay.BackgroundColor3 = draggingWheel
                colorPicker.Value = draggingWheel
                brightnessGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, draggingWheel), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))}
            end

            pickerButton.MouseButton1Click:Connect(function()
                pickerWindow.Visible = not pickerWindow.Visible
            end)

            colorWheel.MouseButton1Down:Connect(function()
                draggingWheel = true
            end)

            brightnessBar.MouseButton1Down:Connect(function()
                draggingWheel = true
            end)

            localUIS.InputChanged:Connect(function(input)
                if draggingWheel and input.UserInputType == Enum.UserInputType.Touch then
                    local pos = input.Position
                    local wheelPos = colorWheel.AbsolutePosition
                    if draggingWheel == true then
                        if (pos.X > wheelPos.X and pos.X < wheelPos.X + colorWheel.AbsoluteSize.X and pos.Y > wheelPos.Y and pos.Y < wheelPos.Y + colorWheel.AbsoluteSize.Y) then
                            wheelPicker.Position = UDim2.new(0, pos.X - wheelPos.X, 0, pos.Y - wheelPos.Y)
                        else
                            wheelPicker.Position = UDim2.new(0, math.clamp(pos.X - wheelPos.X, 0, colorWheel.AbsoluteSize.X), 0, math.clamp(pos.Y - wheelPos.Y, 0, colorWheel.AbsoluteSize.Y))
                        end
                        updateColor(pos)
                    elseif draggingWheel == true then
                        brightnessSlider.Position = UDim2.new(0, 0, 0, math.clamp(pos.Y - brightnessBar.AbsolutePosition.Y, 0, brightnessBar.AbsoluteSize.Y))
                        updateColor(pos)
                    end
                end
            end)

            localUIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    draggingWheel = false
                    spawn(function()
                        pcall(function() callback(colorPicker.Value) end)
                    end)
                end
            end)

            updateLayout()
            return colorPicker
        end

        updateLayout()
        return section
    end

    hub.MainFrame = mainFrame

    local overlay = createInstance("Frame", {
        Name = "Overlay",
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 5,
        Visible = false
    })

    return hub
end

return LinuxUI
