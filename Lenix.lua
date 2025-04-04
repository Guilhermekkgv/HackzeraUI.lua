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

    -- Checagem inicial pra ver se CoreGui tá acessível
    if not localCore then
        error("CoreGui não encontrado, mano!")
        return nil
    end

    local screen = createInstance("ScreenGui", {
        Name = "LinuxUI_" .. (name or "Default"),
        Parent = localCore,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Confirmação que a ScreenGui foi criada
    if not screen then
        error("ScreenGui não foi criada, parça!")
        return nil
    end

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

    if not mainFrame then
        error("MainFrame não foi criado, cachorro!")
        return nil
    end

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

        updateLayout()
        return section
    end

    hub.MainFrame = mainFrame

    return hub
end

return LinuxUI
