-- ====================================================================
--                  INK-SANDIEGO PREMIUM SECURE LOADER                  
-- ====================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ СЕРВЕРА
local BASE_SERVER_URL = "https://onrender.com"
local CONFIG_FILE = "InkHub_SecureKey.txt"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- СВЕРХЗАЩИЩЕННОЕ СКРЫТОЕ ХРАНИЛИЩЕ ДЛЯ ОБХОДА АНТИЧИТОВ
local SecureParent = nil
if gethui then
    SecureParent = gethui() -- Полностью изолированная папка, невидимая для детектов игры
elseif cloneref then
    SecureParent = cloneref(game:GetService("CoreGui"))
else
    SecureParent = game:GetService("CoreGui")
end

-- Загрузка топовой безопасной библиотеки Linoria Lib
local Repository = "https://githubusercontent.com"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()

-- Создание главного защищенного окна
local Window = Library:CreateWindow({
    Title = "InkHub | Premium Gate v2.4",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Привязка скрытия GUI на кнопку (Хайд меню)
Library:SetWatermark("InkHub Private | " .. LocalPlayer.Name)
Library.Keybind = Enum.KeyCode.LeftControl -- По нажатию на Левый Ctrl меню полностью исчезает/появляется

-- Вкладка авторизации
local Tabs = {
    Auth = Window:AddTab("Авторизация")
}

local LeftGroupBox = Tabs.Auth:AddLeftGroupbox("Лицензионный Ключ")

-- Чтение сохраненного ключа
local SavedKey = ""
if readfile and pcall(function() readfile(CONFIG_FILE) end) then
    SavedKey = readfile(CONFIG_FILE)
end

-- Поле ввода
local EnteredKey = SavedKey
LeftGroupBox:AddInput("KeyInput", {
    Default = SavedKey,
    Numeric = false,
    Finished = true,
    Text = "Введите ваш приватный ключ:",
    Tooltip = "Ключ привязывается к вашему HWID при первом входе",
    Placeholder = "INK-XXXX-XXXX",
    Callback = function(Value)
        EnteredKey = Value
    end
})

-- Функция проверки лицензии
local function RequestServerAuth()
    if EnteredKey == "" or #EnteredKey < 4 then
        Library:Notify("Ошибка: Поле ввода пусто или ключ слишком короткий!", 4)
        return
    end

    Library:Notify("Проверка лицензии... Ожидайте ответа бэкенда.", 3)

    local ApiUrl = BASE_SERVER_URL .. "/verify?key=" .. EnteredKey .. "&hwid=" .. HWID .. "&username=" .. LocalPlayer.Name
    local response
    
    local success, err = pcall(function()
        response = request({
            Url = ApiUrl,
            Method = "GET"
        })
    end)

    if success and response and response.Body then
        local data
        pcall(function() data = HttpService:JSONDecode(response.Body) end)

        if data and data.status == "success" and data.script then
            Library:Notify("Доступ разрешен! Активация софта...", 3)
            
            -- Сохраняем ключ
            if writefile then
                pcall(function() writefile(CONFIG_FILE, EnteredKey) end)
            end

            task.wait(1)
            Library:Unload() -- Полностью и чисто удаляем GUI авторизации из памяти

            -- Компиляция и запуск твоего приватного кода из Node.js
            local func, compileError = loadstring(data.script)
            if func then
                func()
            else
                warn("[InkHub Error]: Критическая ошибка компиляции основного скрипта: " .. tostring(compileError))
            end
        else
            Library:Notify("Доступ отклонен: " .. (data and data.message or "Неверный ключ!"), 5)
        end
    else
        Library:Notify("Ошибка подключения к Render серверу. Проверьте хостинг!", 5)
    end
end

-- Кнопка активации
LeftGroupBox:AddButton({
    Text = "Проверить и запустить",
    Func = RequestServerAuth,
    DoubleClick = false
})

-- Текст-инструкция для покупателя
LeftGroupBox:AddLabel("Нажмите [LeftControl] чтобы полностью скрыть/показать это меню.")

-- Принудительно пушим наш интерфейс в скрытый gethui контейнер
if Window.Holder and SecureParent then
    Window.Holder.Parent = SecureParent
end

Library:Notify("InkHub Security Module запущен успешно!", 3)
