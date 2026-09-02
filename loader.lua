-- loader.lua
-- Real Hub | Fling Things and People

local Players = game:GetService("Players")
local plr     = Players.LocalPlayer
local GUI     = gethui()

local SERVER = "https://server-1o6p.onrender.com"
local LOOT   = "https://loot-link.com/s?IB5G1kZ9"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name         = "KeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent       = GUI

local bg = Instance.new("Frame")
bg.Size             = UDim2.new(0,440,0,260)
bg.Position         = UDim2.new(0.5,-220,0.5,-130)
bg.BackgroundColor3 = Color3.fromRGB(10,10,16)
bg.BorderSizePixel  = 0
bg.Parent           = ScreenGui
Instance.new("UICorner",bg).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke",bg)
stroke.Color       = Color3.fromRGB(100,108,255)
stroke.Thickness   = 1.5
stroke.Transparency = 0.4

local topBar = Instance.new("Frame")
topBar.Size             = UDim2.new(1,0,0,4)
topBar.BackgroundColor3 = Color3.fromRGB(100,108,255)
topBar.BorderSizePixel  = 0
topBar.Parent           = bg
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel")
title.Size             = UDim2.new(1,0,0,45)
title.Position         = UDim2.new(0,0,0,10)
title.BackgroundTransparency = 1
title.Text             = "Real Hub"
title.TextColor3       = Color3.fromRGB(255,255,255)
title.Font             = Enum.Font.GothamBold
title.TextSize         = 24
title.Parent           = bg

local sub = Instance.new("TextLabel")
sub.Size             = UDim2.new(1,0,0,18)
sub.Position         = UDim2.new(0,0,0,52)
sub.BackgroundTransparency = 1
sub.Text             = "Fling Things and People"
sub.TextColor3       = Color3.fromRGB(100,108,255)
sub.Font             = Enum.Font.Gotham
sub.TextSize         = 12
sub.Parent           = bg

local div = Instance.new("Frame")
div.Size             = UDim2.new(1,-40,0,1)
div.Position         = UDim2.new(0,20,0,78)
div.BackgroundColor3 = Color3.fromRGB(30,30,45)
div.BorderSizePixel  = 0
div.Parent           = bg

local inputBg = Instance.new("Frame")
inputBg.Size             = UDim2.new(1,-40,0,40)
inputBg.Position         = UDim2.new(0,20,0,92)
inputBg.BackgroundColor3 = Color3.fromRGB(16,16,26)
inputBg.BorderSizePixel  = 0
inputBg.Parent           = bg
Instance.new("UICorner",inputBg).CornerRadius = UDim.new(0,8)

local inputStroke = Instance.new("UIStroke",inputBg)
inputStroke.Color       = Color3.fromRGB(40,40,65)
inputStroke.Thickness   = 1

local input = Instance.new("TextBox")
input.Size             = UDim2.new(1,-20,1,0)
input.Position         = UDim2.new(0,10,0,0)
input.BackgroundTransparency = 1
input.Text             = ""
input.PlaceholderText  = "Paste your key here..."
input.PlaceholderColor3 = Color3.fromRGB(70,70,95)
input.TextColor3       = Color3.fromRGB(220,220,240)
input.Font             = Enum.Font.Gotham
input.TextSize         = 13
input.ClearTextOnFocus = false
input.Parent           = inputBg

local statusL = Instance.new("TextLabel")
statusL.Size             = UDim2.new(1,-40,0,16)
statusL.Position         = UDim2.new(0,20,0,138)
statusL.BackgroundTransparency = 1
statusL.Text             = ""
statusL.TextColor3       = Color3.fromRGB(220,80,80)
statusL.Font             = Enum.Font.Gotham
statusL.TextSize         = 11
statusL.Parent           = bg

local activateBtn = Instance.new("TextButton")
activateBtn.Size             = UDim2.new(0,180,0,40)
activateBtn.Position         = UDim2.new(0,20,0,162)
activateBtn.BackgroundColor3 = Color3.fromRGB(100,108,255)
activateBtn.Text             = "Activate Key"
activateBtn.TextColor3       = Color3.new(1,1,1)
activateBtn.Font             = Enum.Font.GothamBold
activateBtn.TextSize         = 13
activateBtn.BorderSizePixel  = 0
activateBtn.Parent           = bg
Instance.new("UICorner",activateBtn).CornerRadius = UDim.new(0,8)

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size             = UDim2.new(0,180,0,40)
getKeyBtn.Position         = UDim2.new(1,-200,0,162)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(14,14,22)
getKeyBtn.Text             = "Get Key (Free)"
getKeyBtn.TextColor3       = Color3.fromRGB(100,108,255)
getKeyBtn.Font             = Enum.Font.GothamBold
getKeyBtn.TextSize         = 13
getKeyBtn.BorderSizePixel  = 0
getKeyBtn.Parent           = bg
Instance.new("UICorner",getKeyBtn).CornerRadius = UDim.new(0,8)

local getStroke = Instance.new("UIStroke",getKeyBtn)
getStroke.Color       = Color3.fromRGB(100,108,255)
getStroke.Thickness   = 1
getStroke.Transparency = 0.4

local ver = Instance.new("TextLabel")
ver.Size             = UDim2.new(1,0,0,14)
ver.Position         = UDim2.new(0,0,1,-18)
ver.BackgroundTransparency = 1
ver.Text             = "v4.0  |  Key valid 24h  |  Free via lootlabs"
ver.TextColor3       = Color3.fromRGB(50,50,70)
ver.Font             = Enum.Font.Gotham
ver.TextSize         = 10
ver.Parent           = bg

-- Logic
getKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(LOOT) end)
    statusL.Text       = "Link copied! Open browser, complete tasks, copy key"
    statusL.TextColor3 = Color3.fromRGB(100,108,255)
    getKeyBtn.Text     = "Copied!"
    task.wait(2)
    getKeyBtn.Text = "Get Key (Free)"
end)

local function tryActivate()
    local key = input.Text:gsub("%s+","")
    if key == "" then
        statusL.Text       = "Paste your key first"
        statusL.TextColor3 = Color3.fromRGB(220,80,80)
        return
    end

    activateBtn.Text             = "Loading..."
    activateBtn.BackgroundColor3 = Color3.fromRGB(60,65,160)
    statusL.Text                 = ""

    local ok, result = pcall(function()
        return game:HttpGet(SERVER .. "/hub?key=" .. key, true)
    end)

    if ok and result and #result > 50 then
        statusL.Text       = "Loading hub..."
        statusL.TextColor3 = Color3.fromRGB(80,220,120)
        inputStroke.Color  = Color3.fromRGB(80,220,120)
        task.wait(0.8)
        ScreenGui:Destroy()
        loadstring(result)()
    else
        statusL.Text       = "Invalid or expired key"
        statusL.TextColor3 = Color3.fromRGB(220,80,80)
        inputStroke.Color  = Color3.fromRGB(220,80,80)
        activateBtn.Text   = "Activate Key"
        activateBtn.BackgroundColor3 = Color3.fromRGB(100,108,255)
        task.wait(2)
        inputStroke.Color = Color3.fromRGB(40,40,65)
    end
end

activateBtn.MouseButton1Click:Connect(tryActivate)
input.FocusLost:Connect(function(enter)
    if enter then tryActivate() end
end)
