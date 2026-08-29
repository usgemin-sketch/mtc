-- INK HUB CLIENT LOADER (FIXED & ENHANCED)
_G.INK_KEY = _G.INK_KEY or "INK-30D-4C71-D3E4"
_G.INK_SERVER_URL = _G.INK_SERVER_URL or "https://server-ca9b.onrender.com" -- Без слэша на конце!

local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

-- Универсальная функция отправки HTTP-запросов (работает во всех эксплойтах)
local httpRequest = (syn and syn.request) 
    or (http and http.request) 
    or http_request 
    or (fluxus and fluxus.request) 
    or request

local function getHWID()
    local rawHwid = ""
    pcall(function()
        rawHwid = RbxAnalytics:GetClientId()
    end)
    if rawHwid == "" or not rawHwid then
        rawHwid = "FALLBACK_HWID_" .. game:GetService("Players").LocalPlayer.UserId
    end
    return rawHwid
end

_G.INK_HWID = getHWID()

-- Нормализация URL
local cleanUrl = string.gsub(_G.INK_SERVER_URL, "/+$", "")
local authUrl = cleanUrl .. "/verify?key=" .. tostring(_G.INK_KEY) .. "&hwid=" .. tostring(_G.INK_HWID)

print("[INK HUB]: Подключение к серверу " .. cleanUrl .. "...")

local responseBody = nil
local statusCode = 0

if httpRequest then
    -- Безопасный способ через httpRequest (не падаем при 403/404/500)
    local res = httpRequest({
        Url = authUrl,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) InkHubClient/3.0"
        }
    })
    if res then
        responseBody = res.Body
        statusCode = res.StatusCode
    end
else
    -- Резервный способ через game:HttpGet
    local success, res = pcall(function()
        return game:HttpGet(authUrl)
    end)
    if success then
        responseBody = res
        statusCode = 200
    else
        responseBody = res
    end
end

if not responseBody or responseBody == "" then
    warn("[INK HUB ERROR]: Сервер не ответил. Возможно, Render " .. cleanUrl .. " ещё просыпается (подожди 20 сек) или URL указан неверно.")
    return
end

-- Безопасный парсинг JSON
local data = nil
local parseSuccess, parseErr = pcall(function()
    data = HttpService:JSONDecode(responseBody)
end)

if not parseSuccess or type(data) ~= "table" then
    warn("[INK HUB ERROR]: Сервер вернул не JSON. Ответ сервера:")
    print(tostring(responseBody))
    return
end

if data.status == "success" then
    print("[INK HUB]: Успешная авторизация! Срок подписки: " .. tostring(data.expiresIn))
    local mainScript, err = loadstring(data.script)
    if mainScript then
        task.spawn(mainScript)
    else
        warn("[INK HUB ERROR]: Ошибка синтаксиса полученного скрипта: " .. tostring(err))
    end
else
    local errorMsg = data.message or "Неизвестная ошибка сервера"
    warn("[INK HUB AUTH FAILED] Код " .. tostring(statusCode) .. ": " .. tostring(errorMsg))
end
