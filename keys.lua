-- =================================================================
-- INK HUB — Clean Client Loader
-- =================================================================

local SERVER_URL = "https://server-ca9b.onrender.com" 

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetHWID()
    if gethwid then return gethwid() end
    if get_hwid then return get_hwid() end
    if getdeviceid then return getdeviceid() end
    return game:GetService("RbxAnalyticsService"):GetClientId() or "UNKNOWN_HWID"
end

local function HttpRequest(url)
    local reqFn = (http and http.request) or (http_request) or (syn and syn.request) or request
    if reqFn then
        local res = reqFn({ Url = url, Method = "GET" })
        return res.Body
    else
        return game:HttpGet(url)
    end
end

local function GetSafeGuiParent()
    if gethui then return gethui() end
    if get_hidden_gui then return get_hidden_gui() end
    return game:GetService("CoreGui")
end

local function CreateKeyUI()
    local ParentContainer = GetSafeGuiParent()
    if ParentContainer:FindFirstChild("InkKeySystemUI") then
        ParentContainer.InkKeySystemUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "InkKeySystemUI"
    ScreenGui.Parent = ParentContainer

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
    MainFrame.Size = UDim2.new(0, 320, 0, 230)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = MainFrame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(255, 107, 0)
    FrameStroke.Thickness = 1.2
    FrameStroke.Transparency = 0.3
    FrameStroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 12)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "INK HUB — АВТОРИЗАЦИЯ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
    KeyInput.Position = UDim2.new(0.1, 0, 0.22, 0)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Введите лицензионный ключ..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 13

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInput

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Parent = MainFrame
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 107, 0)
    SubmitBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "АКТИВИРОВАТЬ / ВОЙТИ"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 13

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = SubmitBtn

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.05, 0, 0.64, 0)
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Статус: Ожидание ввода..."
    StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    StatusLabel.TextSize = 12

    local ExpireLabel = Instance.new("TextLabel")
    ExpireLabel.Parent = MainFrame
    ExpireLabel.BackgroundTransparency = 1
    ExpireLabel.Position = UDim2.new(0.05, 0, 0.77, 0)
    ExpireLabel.Size = UDim2.new(0.9, 0, 0, 20)
    ExpireLabel.Font = Enum.Font.GothamBold
    ExpireLabel.Text = "Подписка: Не активирована"
    ExpireLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    ExpireLabel.TextSize = 12

    SubmitBtn.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text:gsub("%s+", "")
        if inputKey == "" then
            StatusLabel.Text = "Ошибка: Введите ключ!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            return
        end

        SubmitBtn.Active = false
        StatusLabel.Text = "Проверка ключа..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)

        task.spawn(function()
            local hwid = GetHWID()
            local username = LocalPlayer.Name
            local endpoint = string.format("%s/verify?key=%s&hwid=%s&username=%s",
                SERVER_URL,
                HttpService:UrlEncode(inputKey),
                HttpService:UrlEncode(hwid),
                HttpService:UrlEncode(username)
            )

            local success, rawResponse = pcall(function()
                return HttpRequest(endpoint)
            end)

            if success and rawResponse then
                local decodeSuccess, response = pcall(function()
                    return HttpService:JSONDecode(rawResponse)
                end)

                if decodeSuccess and response then
                    if response.status == "success" and response.script then
                        StatusLabel.Text = "Доступ разрешён!"
                        StatusLabel.TextColor3 = Color3.fromRGB(75, 255, 120)
                        
                        if response.expiresIn then
                            ExpireLabel.Text = "Подписка: осталось " .. tostring(response.expiresIn)
                            ExpireLabel.TextColor3 = Color3.fromRGB(255, 136, 0)
                        end

                        task.wait(1.5)
                        ScreenGui:Destroy()

                        -- Выполнение скрипта главного меню, полученного с сервера
                        local execFunc, err = loadstring(response.script)
                        if execFunc then
                            execFunc()
                        else
                            warn("[INK-LOADER]: Ошибка запуска скрипта с сервера:", err)
                        end
                    else
                        SubmitBtn.Active = true
                        StatusLabel.Text = "Ошибка: " .. (response.message or "Неверный ключ")
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                    end
                else
                    SubmitBtn.Active = true
                    StatusLabel.Text = "Ошибка: Некорректный JSON"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                end
            else
                SubmitBtn.Active = true
                StatusLabel.Text = "Ошибка: Нет связи с сервером"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            end
        end)
    end)
end

CreateKeyUI()
