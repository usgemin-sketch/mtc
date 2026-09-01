-- loader.lua
-- Potassium executor
-- Rayfield UI lib

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local HttpService = game:GetService("HttpService")

local API_URL = "https://server-ca9b.onrender.com"

-- ── UI ────────────────────────────────────────────────────────────
local Window = Rayfield:CreateWindow({
    Name              = "Hub Auth",
    LoadingTitle      = "Hub",
    LoadingSubtitle   = "Авторизация...",
    ConfigurationSaving = { Enabled = false },
    Discord           = { Enabled = false },
    KeySystem         = false
})

local Tab = Window:CreateTab("Вход", 4483362458)

local status = Tab:CreateLabel("Введи логин и пароль")

local UsernameInput = Tab:CreateInput({
    Name        = "Логин",
    PlaceholderText = "твой логин",
    RemoveTextAfterFocusLost = false,
    Callback    = function() end
})

local PasswordInput = Tab:CreateInput({
    Name        = "Пароль",
    PlaceholderText = "твой пароль",
    RemoveTextAfterFocusLost = false,
    Callback    = function() end
})

-- ── Login function ────────────────────────────────────────────────
local function tryLogin()
    local username = UsernameInput.Input.Text
    local password = PasswordInput.Input.Text

    if username == "" or password == "" then
        status:Set("❌ Заполни оба поля")
        return
    end

    status:Set("⏳ Проверяем...")

    local ok, response = pcall(function()
        return HttpService:RequestAsync({
            Url    = API_URL .. "/login",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body   = HttpService:JSONEncode({
                username = username,
                password = password
            })
        })
    end)

    if not ok then
        status:Set("❌ Сервер недоступен. Подожди 30 сек и попробуй снова.")
        return
    end

    local data = HttpService:JSONDecode(response.Body)

    if data.ok then
        status:Set("✅ Успешно! Загружаем хаб...")
        task.wait(1)
        Rayfield:Destroy()

        -- ── Загрузка хаба ─────────────────────────────────────────
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/usgemin-sketch/server/main/games/hub.lua"
        ))()
        -- ─────────────────────────────────────────────────────────
    else
        local errors = {
            not_found      = "❌ Логин не найден.",
            wrong_password = "❌ Неверный пароль."
        }
        status:Set(errors[data.error] or "❌ Ошибка входа.")
    end
end

Tab:CreateButton({
    Name     = "Войти",
    Callback = tryLogin
})
