-- =================================================================
-- Client Key System Loader (Compatible with Potassium & standard APIs)
-- =================================================================

-- Укажи URL твоего Render-сервиса (без завершающего слэша)
local SERVER_URL = "https://your-render-app-name.onrender.com"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция получения уникального HWID в зависимости от среды инжектора
local function GetHWID()
    if gethwid then return gethwid() end
    if get_hwid then return get_hwid() end
    if getdeviceid then return getdeviceid() end
    
    -- Резервный расчет уникального идентификатора клиента
    local clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    return clientId or "UNKNOWN_HWID"
end

-- Функция выполнения HTTP GET запросов (совместимая с большинством эксплойтов)
local function HttpRequest(url)
    local reqFn = (http and http.request) or (http_request) or (syn and syn.request) or request
    if reqFn then
        local res = reqFn({
            Url = url,
            Method = "GET"
        })
        return res.Body
    else
        return game:HttpGet(url)
    end
end

-- Простая графическая форма для ввода ключа (UI)
local function CreateKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitBtn = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")

    local CoreGui = gethui and gethui() or game:GetService("CoreGui")
    if CoreGui:FindFirstChild("InkKeySystemUI") then
        CoreGui.InkKeySystemUI:Destroy()
    end

    ScreenGui.Name = "InkKeySystemUI"
    ScreenGui.Parent = CoreGui

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
    MainFrame.Size = UDim2.new(0, 320, 0, 180)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = MainFrame

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "INK HUB — Авторизация"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18

    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
    KeyInput.Font = Enum.Font.SourceSans
    KeyInput.PlaceholderText = "Введите лицензионный ключ..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = KeyInput

    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Parent = MainFrame
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SubmitBtn.Position = UDim2.new(0.1, 0, 0.58, 0)
    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
    SubmitBtn.Font = Enum.Font.SourceSansBold
    SubmitBtn.Text = "ПРОВЕРИТЬ КЛЮЧ"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 15

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = SubmitBtn

    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
    StatusLabel.Size = UDim2.new(0.8, 0, 0, 25)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 13

    SubmitBtn.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text:gsub("%s+", "")
        if inputKey == "" then
            StatusLabel.Text = "Ошибка: Введите ключ!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            return
        end

        StatusLabel.Text = "Проверка ключа в базе..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

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
                        StatusLabel.Text = "Успешно! Загрузка..."
                        StatusLabel.TextColor3 = Color3.fromRGB(75, 255, 75)
                        task.wait(1)
                        ScreenGui:Destroy()

                        -- Динамическое выполнение подгруженного кода
                        local executable, err = loadstring(response.script)
                        if executable then
                            executable()
                        else
                            warn("[INK-LOADER]: Ошибка компиляции пайлоада: " .. tostring(err))
                        end
                    else
                        StatusLabel.Text = response.message or "Неверный ключ."
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                    end
                else
                    StatusLabel.Text = "Ошибка ответа сервера."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                end
            else
                StatusLabel.Text = "Ошибка подключения к серверу."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            end
        end)
    end)
end

CreateKeyUI()
