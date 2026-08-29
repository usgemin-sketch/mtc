-- ====================================================================
--                      INK-SANDIEGO AUTH LOADER                        
-- ====================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- URL твоего хостинга на Render (замени на свою актуальную ссылку)
local BASE_SERVER_URL = "https://onrender.com"

-- Защищенный метод получения HWID игрока
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Имя файла для сохранения ключа на ПК пользователя
local CONFIG_FILE = "InkHub_AuthKey.txt"

-- Загрузка Orion Library (Профессиональная GUI библиотека)
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создание главного окна авторизации
local Window = OrionLib:MakeWindow({
    Name = "InkHub | Система Авторизации", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroEnabled = true,
    IntroText = "Загрузка InkHub..."
})

-- Вкладка авторизации
local AuthTab = Window:MakeTab({
    Name = "Лицензия",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Пытаемся прочитать ранее сохраненный ключ на диске ПК
local SavedKey = ""
if readfile and pcall(function() readfile(CONFIG_FILE) end) then
    SavedKey = readfile(CONFIG_FILE)
end

local EnteredKey = SavedKey

-- Описание для пользователя внутри меню
AuthTab:AddParagraph("Добро пожаловать в InkHub!", "Пожалуйста, введите ваш купленный приватный лицензионный ключ ниже для проверки HWID и активации софта.")

-- Поле ввода ключа
AuthTab:AddTextbox({
    Name = "Лицензионный Ключ",
    Default = SavedKey,
    TextDisappear = false,
    Callback = function(Value)
        EnteredKey = Value
    end
})

-- Главная функция верификации ключа на сервере Render
local function VerifyLicense()
    if EnteredKey == "" or #EnteredKey < 3 then
        OrionLib:MakeNotification({
            Name = "Ошибка ввода",
            Content = "Пожалуйста, сначала введите корректный ключ!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        return
    end

    local ApiUrl = BASE_SERVER_URL .. "/verify?key=" .. EnteredKey .. "&hwid=" .. HWID .. "&username=" .. LocalPlayer.Name

    OrionLib:MakeNotification({
        Name = "Авторизация",
        Content = "Связь с сервером баз данных... Ожидайте.",
        Image = "rbxassetid://4483345998",
        Time = 3
    })

    local response
    local success, err = pcall(function()
        -- Отправляем безопасный GET-запрос через функции чита
        response = request({
            Url = ApiUrl,
            Method = "GET"
        })
    end)

    if success and response and response.Body then
        local data
        local jsonSuccess, jsonErr = pcall(function()
            data = HttpService:JSONDecode(response.Body)
        end)

        if not jsonSuccess then
            OrionLib:MakeNotification({
                Name = "Ошибка Сервера",
                Content = "Сервер вернул некорректный ответ.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            return
        end

        -- Если ключ валидный, привязался или HWID совпал
        if data.status == "success" and data.script then
            OrionLib:MakeNotification({
                Name = "Успех!",
                Content = "Доступ получен! Запуск премиум софта...",
                Image = "rbxassetid://4483345998",
                Time = 4
            })
            
            -- Сохраняем рабочий ключ на ПК, чтобы не вводить повторно
            if writefile then
                pcall(function() writefile(CONFIG_FILE, EnteredKey) end)
            end

            -- Закрываем окно авторизации Orion Lib
            task.wait(1.5)
            OrionLib:Destroy()

            -- Безопасно компилируем и выполняем полученный из облака боевой код
            local func, compileError = loadstring(data.script)
            if func then
                func()
            else
                warn("[InkHub Error]: Ошибка компиляции чита: " .. tostring(compileError))
            end
        else
            -- Обработка ошибок (неверный ключ, миссматч HWID)
            OrionLib:MakeNotification({
                Name = "Доступ Отклонен",
                Content = data.message or "Неверный ключ лицензии!",
                Image = "rbxassetid://4483345998",
                Time = 7
            })
        end
    else
        OrionLib:MakeNotification({
            Name = "Ошибка сети",
            Content = "Не удалось связаться с вашим Node.js сервером.",
            Image = "rbxassetid://4483345998",
            Time = 6
        })
    end
end

-- Кнопка активации
AuthTab:AddButton({
    Name = "Активировать софт",
    Callback = function()
        VerifyLicense()
    end
})

-- Инициализация графической библиотеки
OrionLib:Init()
