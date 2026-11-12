-- StarterPlayer > StarterPlayerScripts > _hl (LocalScript)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local COLOR = Color3.fromRGB(255, 60, 60)
local OUTLINE = Color3.fromRGB(255, 255, 255)

local tracked = {} -- [character] = highlight

local function clear(char)
    local hl = tracked[char]
    if hl and hl.Parent then hl:Destroy() end
    tracked[char] = nil
end

local function add(char)
    if not char or char == LocalPlayer.Character then return end
    if tracked[char] and tracked[char].Parent then return end

    local hl = Instance.new("Highlight")
    hl.Name = "_" .. tostring(math.random(100000, 999999))
    hl.Adornee = char
    hl.FillColor = COLOR
    hl.OutlineColor = OUTLINE
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    -- Ключевой момент: AlwaysOnTop = видно сквозь стены и на любой дистанции,
    -- пока объект вообще существует в workspace клиента
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    tracked[char] = hl

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function() clear(char) end)
    end
end

-- Подсветить всех, кто уже есть
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character then add(p.Character) end
        p.CharacterAdded:Connect(function(c) task.wait(0.2) add(c) end)
    end
end

-- Новые игроки
Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(c) task.wait(0.2) add(c) end)
    if p.Character then add(p.Character) end
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then clear(p.Character) end
end)

-- Периодическая проверка: если клиент «потерял» персонажа и снова получил — подсветить
task.spawn(function()
    while true do
        task.wait(2)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                add(p.Character)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then add(p.Character) end
    end
end)