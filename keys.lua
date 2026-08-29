-- INK HUB CLIENT LOADER
_G.INK_KEY = "INK-30D-4C71-D3E4"
_G.INK_SERVER_URL = "https://your-render-app.onrender.com" -- 

local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local function getHWID()
    local rawHwid = ""
    pcall(function()
        rawHwid = RbxAnalytics:GetClientId()
    end)
    if rawHwid == "" then
        rawHwid = "FALLBACK_HWID_" .. game:GetService("Players").LocalPlayer.UserId
    end
    return rawHwid
end

_G.INK_HWID = getHWID()

local authUrl = _G.INK_SERVER_URL .. "/verify?key=" .. tostring(_G.INK_KEY) .. "&hwid=" .. tostring(_G.INK_HWID)

local success, response = pcall(function()
    return game:HttpGet(authUrl)
end)

if not success or not response then
    warn("[INK HUB]: Не удалось связаться с сервером авторизации.")
    return
end

local data
local parseSuccess, parseErr = pcall(function()
    data = HttpService:JSONDecode(response)
end)

if parseSuccess and data and data.status == "success" then
    print("[INK HUB]: Авторизация успешна! Срок действия: " .. tostring(data.expiresIn))
    local mainScript, err = loadstring(data.script)
    if mainScript then
        mainScript()
    else
        warn("[INK HUB]: Ошибка выполнения клиентской оболочки: " .. tostring(err))
    end
else
    local msg = (data and data.message) or "Неизвестная ошибка"
    warn("[INK HUB AUTH FAILED]: " .. tostring(msg))
end
