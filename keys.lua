
-- InkGame_NodeJS_Secure_Loader.lua
-- Стелс-загрузчик с авторизацией под NodeJS бэкенд (Render)
-- Среда выполнения: Potassium API

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local Camera = workspace.CurrentCamera
local request = syn and syn.request or http_request or request

-- Функция дешифрования URL сервера
local function decryptString(data, key)
    local result = {}
    for i = 1, #data do
        local byte = data[i]
        local keyByte = string.byte(key, (i - 1) % #key + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    return table.concat(result)
end

-- Динамический дешифратор базового адреса
-- Сюда мы зашьем финальные байты, когда Render выдаст точную ссылку
local function getServerUrl()
    -- ПОКА ЧТО ИСПОЛЬЗУЕМ ПРЯМУЮ СТРОКУ ДЛЯ ТЕСТА (Замени на свою ссылку с Render):
    local baseTargetUrl = "https://ТВОЙ_АДРЕС_С_://onrender.com"
    return baseTargetUrl
end

local function getClientHWID()
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId() or (gethwid and gethwid()) or "UNKNOWN_HWID_FAIL"
    end)
    return success and result or "UNKNOWN_HWID_FAIL"
end

-- Автоматический ключ для моментального входа без клавиатуры
local AUTH_CONFIG = {
    Width = 420, 
    Height = 240, 
    AutoKey = "INK-TEST-7777" -- Твой тестовый ключ
}

local function getScreenCenter()
    local screenSize = Camera.ViewportSize
    return Vector2.new((screenSize.X / 2) - (AUTH_CONFIG.Width / 2), (screenSize.Y / 2) - (AUTH_CONFIG.Height / 2))
end

local startPos = getScreenCenter()
local MenuBackground = Drawing.new("Square")
local MenuTitle = Drawing.new("Text")
local InputDisplay = Drawing.new("Text")
local StatusText = Drawing.new("Text")

local function initAuthMenu()
    MenuBackground.Size = Vector2.new(AUTH_CONFIG.Width, AUTH_CONFIG.Height)
    MenuBackground.Position = startPos
    MenuBackground.Color = Color3.fromRGB(15, 15, 15)
    MenuBackground.Thickness = 2
    MenuBackground.Filled = true
    MenuBackground.Visible = true

    MenuTitle.Text = "INK GAME: CLOUD LOADER"
    MenuTitle.Size = 18
    MenuTitle.Color = Color3.fromRGB(255, 0, 120)
    MenuTitle.Center = true
    MenuTitle.Outline = true
    MenuTitle.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 20)
    MenuTitle.Visible = true

    InputDisplay.Text = "Connecting via cloud API: " .. AUTH_CONFIG.AutoKey
    InputDisplay.Size = 15
    InputDisplay.Color = Color3.fromRGB(0, 255, 200)
    InputDisplay.Center = true
    InputDisplay.Outline = true
    InputDisplay.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 90)
    InputDisplay.Visible = true

    StatusText.Text = "Connecting to Node.js backend..."
    StatusText.Size = 12
    StatusText.Color = Color3.fromRGB(140, 140, 140)
    StatusText.Center = true
    StatusText.Outline = true
    StatusText.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 160)
    StatusText.Visible = true
end

initAuthMenu()
task.wait(1.5)

local hwid = getClientHWID()
local targetUrl = getServerUrl() .. "?key=" .. AUTH_CONFIG.AutoKey .. "&hwid=" .. hwid

local success, response = pcall(function()
    return request({Url = targetUrl, Method = "GET"})
end)

if success and response.StatusCode == 200 then
    local data = HttpService:JSONDecode(response.Body)
    if data and data.status == "success" then
        StatusText.Color = Color3.fromRGB(50, 255, 50)
        StatusText.Text = "ACCESS GRANTED! Synchronizing with GitHub..."
        task.wait(1)
        MenuBackground:Remove()
        MenuTitle:Remove()
        InputDisplay:Remove()
        StatusText:Remove()
        
        -- Подгрузка твоего файла функционала
        loadstring(game:HttpGet("https://githubusercontent.com"))()
        return
    end
end

StatusText.Color = Color3.fromRGB(255, 50, 50)
StatusText.Text = "CLOUD ERROR! Checking logs or key registration..."
