local _vX = "aHR0cHM6Ly9zZXJ2ZXItY2E5Yi5vbnJlbmRlci5jb20="

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local request = syn and syn.request
    or http_request
    or (http and http.request)
    or request

local _t = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function _dX(d)
    d = string.gsub(d, "[^" .. _t .. "=]", "")

    return (d:gsub(".", function(x)
        if x == "=" then
            return ""
        end

        local c = _t:find(x) - 1
        local r = ""

        for i = 6, 1, -1 do
            r = r .. (c % 2 ^ i - c % 2 ^ (i - 1) > 0 and "1" or "0")
        end

        return r
    end):gsub("%d%d%d%d%d%d%d%d", function(x)
        local c = 0

        for i = 1, 8 do
            c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
        end

        return string.char(c)
    end))
end

local BASE_API_URL = _dX(_vX)

local function getClientHWID()
    local success, result = pcall(function()
        return (gethwid and gethwid())
            or game:GetService("RbxAnalyticsService"):GetClientId()
            or "FAIL_HWID"
    end)

    return success and result or "FAIL_HWID"
end

local AUTH_CONFIG = {
    Width = 480,
    Height = 260,
    MenuVisible = true,
    CurrentInput = ""
}

local function getRealMouseLocation()
    local mousePos = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()

    return Vector2.new(mousePos.X, mousePos.Y - inset.Y)
end

local startPos = Vector2.new(
    (Camera.ViewportSize.X / 2) - (AUTH_CONFIG.Width / 2),
    (Camera.ViewportSize.Y / 2) - (AUTH_CONFIG.Height / 2)
)

local MenuBackground = Drawing.new("Square")
local MenuHeader = Drawing.new("Square")
local MenuTitle = Drawing.new("Text")
local InputDisplay = Drawing.new("Text")
local ActivateButton = Drawing.new("Square")
local ButtonText = Drawing.new("Text")
local StatusText = Drawing.new("Text")

local function initAuthMenu()
    MenuBackground.Size = Vector2.new(AUTH_CONFIG.Width, AUTH_CONFIG.Height)
    MenuBackground.Position = startPos
    MenuBackground.Color = Color3.fromRGB(12, 12, 12)
    MenuBackground.Thickness = 2
    MenuBackground.Filled = true

    MenuHeader.Size = Vector2.new(AUTH_CONFIG.Width, 45)
    MenuHeader.Position = startPos
    MenuHeader.Color = Color3.fromRGB(22, 22, 22)
    MenuHeader.Filled = true

    MenuTitle.Text = "INK GAME: PREMIUM CLOUD SOFTWARE"
    MenuTitle.Size = 20
    MenuTitle.Color = Color3.fromRGB(255, 0, 120)
    MenuTitle.Center = true
    MenuTitle.Outline = true
    MenuTitle.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 12)

    InputDisplay.Text = "Enter License Key: "
    InputDisplay.Size = 18
    InputDisplay.Color = Color3.fromRGB(255, 255, 255)
    InputDisplay.Center = true
    InputDisplay.Outline = true
    InputDisplay.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 90)

    ActivateButton.Size = Vector2.new(180, 40)
    ActivateButton.Position = startPos + Vector2.new(
        (AUTH_CONFIG.Width / 2) - 90,
        145
    )
    ActivateButton.Color = Color3.fromRGB(32, 32, 32)
    ActivateButton.Thickness = 1
    ActivateButton.Filled = true

    ButtonText.Text = "ACTIVATE KEY"
    ButtonText.Size = 16
    ButtonText.Color = Color3.fromRGB(0, 255, 180)
    ButtonText.Center = true
    ButtonText.Outline = true
    ButtonText.Position = ActivateButton.Position + Vector2.new(90, 11)

    StatusText.Text = "[ Type license key or press CTRL+V to insert ]"
    StatusText.Size = 13
    StatusText.Color = Color3.fromRGB(110, 110, 110)
    StatusText.Center = true
    StatusText.Outline = true
    StatusText.Position = startPos + Vector2.new(AUTH_CONFIG.Width / 2, 215)

    MenuBackground.Visible = true
    MenuHeader.Visible = true
    MenuTitle.Visible = true
    InputDisplay.Visible = true
    ActivateButton.Visible = true
    ButtonText.Visible = true
    StatusText.Visible = true

    print("[INK-GUI]: Панель успешно создана и выведена на экран!")
end

local function updateMenuPosition(newPos)
    MenuBackground.Position = newPos
    MenuHeader.Position = newPos
    MenuTitle.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 12)
    InputDisplay.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 90)

    ActivateButton.Position = newPos + Vector2.new(
        (AUTH_CONFIG.Width / 2) - 90,
        145
    )

    ButtonText.Position = ActivateButton.Position + Vector2.new(90, 11)
    StatusText.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 215)
end

local function destroyAuthMenu()
    MenuBackground:Remove()
    MenuHeader:Remove()
    MenuTitle:Remove()
    InputDisplay:Remove()
    ActivateButton:Remove()
    ButtonText:Remove()
    StatusText:Remove()

    ContextActionService:UnbindCoreAction("BlockGameInput")
end

local dragging = false
local dragStart = nil
local startOffset = nil

UserInputService.InputBegan:Connect(function(input)
    if not AUTH_CONFIG.MenuVisible then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local mousePos = getRealMouseLocation()
    local menuPos = MenuBackground.Position

    if mousePos.X >= menuPos.X
        and mousePos.X <= menuPos.X + AUTH_CONFIG.Width
        and mousePos.Y >= menuPos.Y
        and mousePos.Y <= menuPos.Y + 45
    then
        dragging = true
        dragStart = mousePos
        startOffset = menuPos
        return
    end

    local btnPos = ActivateButton.Position

    if mousePos.X >= btnPos.X
        and mousePos.X <= btnPos.X + 180
        and mousePos.Y >= btnPos.Y
        and mousePos.Y <= btnPos.Y + 40
    then
        ActivateButton.Color = Color3.fromRGB(45, 45, 45)

        task.wait(0.1)

        ActivateButton.Color = Color3.fromRGB(32, 32, 32)

        if #AUTH_CONFIG.CurrentInput == 0 then
            StatusText.Color = Color3.fromRGB(255, 150, 0)
            StatusText.Text = "Please enter a license key first!"
            return
        end

        if not request then
            StatusText.Color = Color3.fromRGB(255, 50, 50)
            StatusText.Text = "CRITICAL ERROR: Executor does not support HTTP Requests!"
            return
        end

        StatusText.Color = Color3.fromRGB(0, 255, 180)
        StatusText.Text = "Verifying cloud license..."

        local hwid = getClientHWID()
        local rblxName = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"
        local cacheBuster = math.random(100000, 999999)

        local targetUrl =
            BASE_API_URL
            .. "/verify?key="
            .. HttpService:UrlEncode(AUTH_CONFIG.CurrentInput)
            .. "&hwid="
            .. HttpService:UrlEncode(hwid)
            .. "&username="
            .. HttpService:UrlEncode(rblxName)
            .. "&cb="
            .. cacheBuster

        local success, response = pcall(function()
            return request({
                Url = targetUrl,
                Method = "GET"
            })
        end)

        if not success or not response or response.StatusCode ~= 200 then
            StatusText.Color = Color3.fromRGB(255, 50, 50)
            StatusText.Text = "AUTH FAILED! Invalid Key or HWID Mismatch."
            return
        end

        local parseSuccess, data = pcall(function()
            local body = response.Body or ""
            body = body:gsub("^%s*(.-)%s*$", "%1")
            return HttpService:JSONDecode(body)
        end)

        if not parseSuccess or not data or data.status ~= "success" then
            StatusText.Color = Color3.fromRGB(255, 50, 50)
            StatusText.Text = "AUTH FAILED! Invalid Key or HWID Mismatch."
            return
        end

        StatusText.Color = Color3.fromRGB(50, 255, 50)
        StatusText.Text = "ACCESS GRANTED! Requesting script modules..."

        task.wait(1)

        local scriptUrl = BASE_API_URL .. "/getscript?cb=" .. cacheBuster

        local scriptSuccess, scriptResponse = pcall(function()
            return request({
                Url = scriptUrl,
                Method = "GET"
            })
        end)

        if not scriptSuccess
            or not scriptResponse
            or scriptResponse.StatusCode ~= 200
        then
            StatusText.Color = Color3.fromRGB(255, 50, 50)
            StatusText.Text = "ERROR: Failed to download script module."
            return
        end

        AUTH_CONFIG.MenuVisible = false
        destroyAuthMenu()

        local executableCode, compileError = loadstring(scriptResponse.Body)

        if executableCode then
            local runSuccess, runError = pcall(executableCode)

            if not runSuccess then
                warn("[INK-ERROR]: Ошибка выполнения модуля: " .. tostring(runError))
            end
        else
            warn("[INK-ERROR]: Скрипт-модуль поврежден: " .. tostring(compileError))
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if not AUTH_CONFIG.MenuVisible then
        return
    end

    local ctrlDown =
        UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

    if ctrlDown and input.KeyCode == Enum.KeyCode.V then
        local clipboardText

        if getclipboard then
            clipboardText = getclipboard()
        elseif Clipboard and Clipboard.read then
            clipboardText = Clipboard.read()
        end

        if clipboardText then
            local cleanText = tostring(clipboardText):gsub("[\r\n%s]", "")

            AUTH_CONFIG.CurrentInput =
                AUTH_CONFIG.CurrentInput .. cleanText

            InputDisplay.Text =
                "Enter License Key: " .. AUTH_CONFIG.CurrentInput
        end

        return
    end

    if input.KeyCode == Enum.KeyCode.Backspace then
        if #AUTH_CONFIG.CurrentInput > 0 then
            AUTH_CONFIG.CurrentInput =
                string.sub(AUTH_CONFIG.CurrentInput, 1, -2)

            InputDisplay.Text =
                "Enter License Key: " .. AUTH_CONFIG.CurrentInput
        end

        return
    end

    if input.KeyCode == Enum.KeyCode.Space then
        return
    end

    local keyChar = input.KeyCode.Name

    if #keyChar == 1 then
        local isShift =
            UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        if not isShift then
            keyChar = string.lower(keyChar)
        end

        AUTH_CONFIG.CurrentInput =
            AUTH_CONFIG.CurrentInput .. keyChar

        InputDisplay.Text =
            "Enter License Key: " .. AUTH_CONFIG.CurrentInput

    elseif string.sub(keyChar, 1, 6) == "Number"
        and #keyChar == 7
    then
        local num = string.sub(keyChar, 7, 7)

        AUTH_CONFIG.CurrentInput =
            AUTH_CONFIG.CurrentInput .. num

        InputDisplay.Text =
            "Enter License Key: " .. AUTH_CONFIG.CurrentInput
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging
        and input.UserInputType == Enum.UserInputType.MouseMovement
    then
        updateMenuPosition(
            startOffset + (getRealMouseLocation() - dragStart)
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

initAuthMenu()
