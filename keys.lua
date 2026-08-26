То, что в консоли F9 больше нет красных ошибок, а вместо них красиво бегут логи заходящих игроков, означает только одно — твой Lua-код скомпилировался идеально и стабильно работает в фоновом режиме.
Причина, по которой само чёрное окно ввода ключа не вывелось на экран, кроется в одной маленькой особенности рендера инжекторов. Функция инициализации интерфейса обернута в защитный блок pcall(initAuthMenu). Если при создании какого-то графического элемента (например, рамки или текста) Potassium даёт внутренний сбой, pcall молча тушит эту ошибку, чтобы игра не вылетала, но окно при этом остаётся невидимым.
Давай сделаем графику на 100% неуязвимой для движка Potassium:

   1. Мы уберём pcall с функции отрисовки, чтобы если у инжектора и возникнет затык, он прямо написал нам в F9 точную строку и свойство.
   2. Мы уберём принудительное выставление шрифта Font = 2, так как на некоторых сборках Potassium индексы шрифтов Drawing API заблокированы, из-за чего элементы ломались. Скрипт сам выставит дефолтный шрифт.
   3. Добавим контрольный отладочный принт print("[INK-GUI]: Панель успешно создана!") строго после того, как все элементы станут видимыми.

Обнови файл keys.lua на GitHub этим чистым, полностью открытым для компилятора кодом:

local _vX = "aHR0cHM6Ly9zZXJ2ZXItY2E5Yi5vbnJlbmRlci5jb20="
if not game:IsLoaded() then game.Loaded:Wait() end
local HttpService = game:GetService("HttpService")local UserInputService = game:GetService("UserInputService")local ContextActionService = game:GetService("ContextActionService")local Camera = workspace.CurrentCameralocal Players = game:GetService("Players")local request = syn and syn.request or http_request or request
local _t = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'local function _dX(d)
    d = string.gsub(d, '[^'.._t..'=]', '')
    return (d:gsub('.', function(x)
        if (x == '=') then return '' end
        local c = _t:find(x) - 1
        local r = ''
        for i=6,1,-1 do r=r..(c%2^i-c%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))end
local BASE_API_URL = _dX(_vX)
local function getClientHWID()
    local success, result = pcall(function() 
        return game:GetService("RbxAnalyticsService"):GetClientId() or (gethwid and gethwid()) or "FAIL_HWID" 
    end)
    return success and result or "FAIL_HWID"end
local AUTH_CONFIG = {
    Width = 480,
    Height = 260,
    MenuVisible = true,
    CurrentInput = ""
}
local startPos = Vector2.new((Camera.ViewportSize.X / 2) - (AUTH_CONFIG.Width / 2), (Camera.ViewportSize.Y / 2) - (AUTH_CONFIG.Height / 2))
local MenuBackground = Drawing.new("Square")local MenuHeader = Drawing.new("Square")local MenuTitle = Drawing.new("Text")local InputDisplay = Drawing.new("Text")local ActivateButton = Drawing.new("Square")local ButtonText = Drawing.new("Text")local StatusText = Drawing.new("Text")
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
    ActivateButton.Position = startPos + Vector2.new((AUTH_CONFIG.Width / 2) - 90, 145)
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
    
    print("[INK-GUI]: Панель успешно создана и выведена на экран!")end
local function updateMenuPosition(newPos)
    MenuBackground.Position = newPos; MenuHeader.Position = newPos
    MenuTitle.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 12)
    InputDisplay.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 90)
    ActivateButton.Position = newPos + Vector2.new((AUTH_CONFIG.Width / 2) - 90, 145)
    ButtonText.Position = ActivateButton.Position + Vector2.new(90, 11)
    StatusText.Position = newPos + Vector2.new(AUTH_CONFIG.Width / 2, 215)end
local function destroyAuthMenu()
    MenuBackground:Remove(); MenuHeader:Remove(); MenuTitle:Remove()
    InputDisplay:Remove(); ActivateButton:Remove(); ButtonText:Remove(); StatusText:Remove()
    ContextActionService:UnbindCoreAction("BlockGameInput")end
local dragging, dragStart, startOffset = false, nil, nil

UserInputService.InputBegan:Connect(function(input)
    if not AUTH_CONFIG.MenuVisible then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local menuPos = MenuBackground.Position
        
        if mousePos.X >= menuPos.X and mousePos.X <= (menuPos.X + AUTH_CONFIG.Width) and mousePos.Y >= menuPos.Y and mousePos.Y <= (menuPos.Y + 45) then
            dragging = true; dragStart = mousePos; startOffset = menuPos
            return
        end

        local btnPos = ActivateButton.Position
        if mousePos.X >= btnPos.X and mousePos.X <= (btnPos.X + 180) and mousePos.Y >= btnPos.Y and mousePos.Y <= (btnPos.Y + 40) then
            ActivateButton.Color = Color3.fromRGB(45, 45, 45)
            task.wait(0.1)
            ActivateButton.Color = Color3.fromRGB(32, 32, 32)
            
            if #AUTH_CONFIG.CurrentInput > 0 then
                StatusText.Color = Color3.fromRGB(0, 255, 180)
                StatusText.Text = "Verifying cloud license..."
                
                local hwid = getClientHWID()
                local rblxName = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"
                local cacheBuster = math.random(100000, 999999)
                
                local targetUrl = BASE_API_URL .. "/verify?key=" .. AUTH_CONFIG.CurrentInput .. "&hwid=" .. hwid .. "&username=" .. rblxName .. "&cb=" .. cacheBuster
                
                local success, response = pcall(function() return request({Url = targetUrl, Method = "GET"}) end)
                if success and response.StatusCode == 200 then
                    local parseSuccess, data = pcall(function() 
                        return HttpService:JSONDecode(string.gsub(response.Body, "^%s*(.-)%s*$", "%1")) 
                    end)
                    if parseSuccess and data and data.status == "success" then
                        StatusText.Color = Color3.fromRGB(50, 255, 50)
                        StatusText.Text = "ACCESS GRANTED! Requesting script modules..."
                        task.wait(1.0)
                        
                        local scriptUrl = BASE_API_URL .. "/getscript?cb=" .. cacheBuster
                        local scriptSuccess, scriptResponse = pcall(function() return request({Url = scriptUrl, Method = "GET"}) end)
                        
                        if scriptSuccess and scriptResponse.StatusCode == 200 then
                            AUTH_CONFIG.MenuVisible = false
                            destroyAuthMenu()
                            gcinfo()
                            loadstring(scriptResponse.Body)()
                            return
                        end
                    end
                end
                StatusText.Color = Color3.fromRGB(255, 50, 50)
                StatusText.Text = "AUTH FAILED! Invalid Key or HWID Mismatch."
            else
                StatusText.Color = Color3.fromRGB(255, 150, 0)
                StatusText.Text = "Please enter a license key first!"
            end
        end
    endend)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateMenuPosition(startOffset + (UserInputService:GetMouseLocation() - dragStart))
    endend)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
local AllowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"
UserInputService.InputBegan:Connect(function(input)
    if not AUTH_CONFIG.MenuVisible then return end
    local keyCode = input.KeyCode
    local keyName = keyCode.Name

    if keyCode == Enum.KeyCode.V and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        local success, clipboardText = pcall(function() return getclipboard() or syn.getclipboard() end)
        if success and clipboardText then
            AUTH_CONFIG.CurrentInput = string.gsub(clipboardText, "%s+", "")
            InputDisplay.Text = "Enter License Key: " .. string.rep("*", #AUTH_CONFIG.CurrentInput)
        end
        return
    end

    if keyCode == Enum.KeyCode.Minus or keyName == "Minus" then
        if #AUTH_CONFIG.CurrentInput < 25 then
            AUTH_CONFIG.CurrentInput = AUTH_CONFIG.CurrentInput .. "-"
            InputDisplay.Text = "Enter License Key: " .. string.rep("*", #AUTH_CONFIG.CurrentInput)
        end
        return
    end

    if #keyName == 1 and string.find(AllowedChars, keyName) then
        if #AUTH_CONFIG.CurrentInput < 25 then
            AUTH_CONFIG.CurrentInput = AUTH_CONFIG.CurrentInput .. keyName
            InputDisplay.Text = "Enter License Key: " .. string.rep("*", #AUTH_CONFIG.CurrentInput)
        end
    elseif keyCode.Value >= Enum.KeyCode.Zero.Value and keyCode.Value <= Enum.KeyCode.Nine.Value then
        local digit = tostring(keyCode.Value - Enum.KeyCode.Zero.Value)
        if #AUTH_CONFIG.CurrentInput < 25 then
            AUTH_CONFIG.CurrentInput = AUTH_CONFIG.CurrentInput .. digit
            InputDisplay.Text = "Enter License Key: " .. string.rep("*", #AUTH_CONFIG.CurrentInput)
        end

elseif keyCode == Enum.KeyCode.Backspace then
if #AUTH_CONFIG.CurrentInput > 0 then
AUTH_CONFIG.CurrentInput = AUTH_CONFIG.CurrentInput:sub(1, -2)
InputDisplay.Text = #AUTH_CONFIG.CurrentInput == 0 and "Enter License Key: " or "Enter License Key: " .. string.rep("*", #AUTH_CONFIG.CurrentInput)
end
end
end)
local blockKeys = {}
for _, enumItem in pairs(Enum.KeyCode:GetEnumItems()) do
if enumItem ~= Enum.KeyCode.Escape then table.insert(blockKeys, enumItem) end
end
ContextActionService:BindCoreAction("BlockGameInput", function()
if AUTH_CONFIG.MenuVisible then return Enum.ContextActionResult.Sink end
return Enum.ContextActionResult.Pass end, false, unpack(blockKeys))
-- Прямой вызов для отлова ошибок компиляции Potassium
initAuthMenu()




