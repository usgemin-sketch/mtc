if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE_API_URL = "https://onrender.com"

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local HiddenStorage = gethui and gethui() or game:GetService("CoreGui")

local executor_request = (syn and syn.request) 
    or http_request 
    or (http and http.request) 
    or (fluxus and fluxus.request)

local function getClientHWID()
    local success, result = pcall(function()
        return (gethwid and gethwid())
            or game:GetService("RbxAnalyticsService"):GetClientId()
            or "FAIL_HWID"
    end)
    return success and result or "FAIL_HWID"
end

if HiddenStorage:FindFirstChild("InkKeySystem") then HiddenStorage.InkKeySystem:Destroy() end
if HiddenStorage:FindFirstChild("InkPremiumMenu") then HiddenStorage.InkPremiumMenu:Destroy() end
if HiddenStorage:FindFirstChild("InkVisualsLayer") then HiddenStorage.InkVisualsLayer:Destroy() end

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "InkKeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.Parent = HiddenStorage

local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 360, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -180, 0.4, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 2
KeyStroke.Color = Color3.fromRGB(255, 110, 0)
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 INK CLOUD: LICENSE VERIFICATION"
KeyTitle.TextColor3 = Color3.fromRGB(255, 110, 0)
KeyTitle.TextSize = 14
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.Parent = KeyFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 40)
Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Divider.BorderSizePixel = 0
Divider.Parent = KeyFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -40, 0, 38)
TextBox.Position = UDim2.new(0, 20, 0, 60)
TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextBox.BorderSizePixel = 0
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.PlaceholderText = "Вставь или введи свой ключ лицензии..."
TextBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.SourceSans
TextBox.Parent = KeyFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Thickness = 1
BoxStroke.Color = Color3.fromRGB(55, 55, 55)
BoxStroke.Parent = TextBox

local EnterBtn = Instance.new("TextButton")
EnterBtn.Size = UDim2.new(1, -40, 0, 38)
EnterBtn.Position = UDim2.new(0, 20, 0, 115)
EnterBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
EnterBtn.Text = "АКТИВИРОВАТЬ КЛЮЧ"
EnterBtn.TextColor3 = Color3.fromRGB(255, 110, 0)
EnterBtn.TextSize = 14
EnterBtn.Font = Enum.Font.SourceSansBold
EnterBtn.AutoButtonColor = false
EnterBtn.Parent = KeyFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = EnterBtn

local EnterStroke = Instance.new("UIStroke")
EnterStroke.Thickness = 1
EnterStroke.Color = Color3.fromRGB(255, 110, 0)
EnterStroke.Parent = EnterBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "[ Поддерживается вставка через CTRL+V ]"
StatusLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.Parent = KeyFrame

local function checkLicenseKey()
    local currentInput = TextBox.Text
    
    if #currentInput == 0 then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        StatusLabel.Text = "🚨 ПОЖАЛУЙСТА, СНАЧАЛА ВВЕДИТЕ КЛЮЧ!"
        return
    end

    if not executor_request then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "❌ ОШИБКА: ЭКЗЕКУТОР НЕ ПОДДЕРЖИВАЕТ HTTP ЗАПРОСЫ!"
        return
    end

    StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
    StatusLabel.Text = "⏳ ПОДКЛЮЧЕНИЕ К СЕРВЕРУ... ПРОБУЖДЕНИЕ RENDER (15-40 сек)"
    EnterBtn.Text = "ПОДКЛЮЧЕНИЕ..."
    
    local hwid = getClientHWID()
    local rblxName = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"
    local cacheBuster = math.random(100000, 999999)

    local targetUrl = BASE_API_URL
        .. "/verify?key="
        .. HttpService:UrlEncode(currentInput)
        .. "&hwid="
        .. HttpService:UrlEncode(hwid)
        .. "&username="
        .. HttpService:UrlEncode(rblxName)
        .. "&cb="
        .. cacheBuster

    local success, response = pcall(function()
        return executor_request({
            Url = targetUrl, 
            Method = "GET",
            Timeout = 60
        })
    end)

    if success and response then
        if response.StatusCode == 200 then
            EnterBtn.Text = "ДОСТУП ОДОБРЕН!"
            TweenService:Create(EnterBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 50, 20), TextColor3 = Color3.fromRGB(35, 255, 35)}):Play()
            TweenService:Create(EnterStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 255, 35)}):Play()
            StatusLabel.TextColor3 = Color3.fromRGB(35, 255, 35)
            StatusLabel.Text = "✅ СКАЧИВАНИЕ ПРЕМИУМ-СКРИПТА С СЕРВЕРА..."
            
            task.wait(1.5)
            KeyGui:Destroy()

            local scriptUrl = BASE_API_URL .. "/getscript"
            local loadSuccess, scriptContent = pcall(function()
                if game.HttpGet then
                    return game:HttpGet(scriptUrl)
                else
                    local res = executor_request({Url = scriptUrl, Method = "GET"})
                    return res.Body
                end
            end)

            if loadSuccess and scriptContent then
                local runSuccess, errorMsg = pcall(function()
                    local func = assert(loadstring(scriptContent), "Failed to compile code")
                    func()
                end)
                if not runSuccess then
                    warn("[INK-ERROR]: Ошибка рантайма подгруженного чита: " .. tostring(errorMsg))
                end
            else
                warn("[INK-ERROR]: Не удалось получить код с твоего NodeJS сервера.")
            end
        else
            EnterBtn.Text = "ОШИБКА АВТОРИЗАЦИИ!"
            TweenService:Create(EnterBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 10, 10), TextColor3 = Color3.fromRGB(255, 35, 35)}):Play()
            TweenService:Create(EnterStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 35, 35)}):Play()
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            StatusLabel.Text = "❌ КЛЮЧ НЕ СУЩЕСТВУЕТ ИЛИ HWID НЕ СОВПАДАЕТ! (КОД: " .. tostring(response.StatusCode) .. ")"
            
            task.wait(2)
            EnterBtn.Text = "АКТИВИРОВАТЬ КЛЮЧ"
            TweenService:Create(EnterBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32), TextColor3 = Color3.fromRGB(255, 110, 0)}):Play()
            TweenService:Create(EnterStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 110, 0)}):Play()
        end
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 50)
        StatusLabel.Text = "⚠️ ТАЙМАУТ СЕРВЕРА! RENDER ЕЩЁ СПИТ. ПОПРОБУЙТЕ СНОВА."
        EnterBtn.Text = "АКТИВИРОВАТЬ КЛЮЧ"
    end
end

EnterBtn.MouseButton1Click:Connect(function()
    checkLicenseKey()
end)

print("[INK-LOADER]: Облачный лоадер FULL GETHUI успешно запущен!");
