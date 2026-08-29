-- INK HUB CLIENT LOADER (CLEAN SCOPE)
local CONFIG = {
    Key = "INK-30D-4C71-D3E4",
    ServerUrl = "https://server-ca9b.onrender.com" -- Без слэша на конце!
}

local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

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
    if not rawHwid or rawHwid == "" then
        rawHwid = "FALLBACK_HWID_" .. game:GetService("Players").LocalPlayer.UserId
    end
    return rawHwid
end

local hwid = getHWID()
local cleanUrl = string.gsub(CONFIG.ServerUrl, "/+$", "")
local authUrl = cleanUrl .. "/verify?key=" .. tostring(CONFIG.Key) .. "&hwid=" .. tostring(hwid)

print("[INK HUB]: Запрос к серверу авторизации...")

local responseBody = nil
local statusCode = 0

if httpRequest then
    local res = httpRequest({
        Url = authUrl,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "InkHubClient/3.0"
        }
    })
    if res then
        responseBody = res.Body
        statusCode = res.StatusCode
    end
else
    local success, res = pcall(function()
        return game:HttpGet(authUrl)
    end)
    if success then
        responseBody = res
        statusCode = 200
    end
end

if not responseBody or responseBody == "" then
    warn("[INK HUB ERROR]: Сервер не ответил. Проверь статус Render.")
    return
end

local data = nil
local parseSuccess = pcall(function()
    data = HttpService:JSONDecode(responseBody)
end)

if not parseSuccess or type(data) ~= "table" then
    warn("[INK HUB ERROR]: Некорректный ответ сервера: " .. tostring(responseBody))
    return
end

if data.status == "success" then
    print("[INK HUB]: Авторизация успешна! Срок: " .. tostring(data.expiresIn))
    
    -- Исполняем полученный скрипт
    local mainScript, err = loadstring(data.script)
    if mainScript then
        task.spawn(mainScript)
    else
        warn("[INK HUB ERROR]: Ошибка синтаксиса модуля: " .. tostring(err))
    end
else
    warn("[INK HUB AUTH FAILED]: " .. tostring(data.message or "Ошибка доступа"))
end
