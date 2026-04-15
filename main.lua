local player = game.Players.LocalPlayer

-- Цикл для удалённого вызова инструмента
task.spawn(function()
    local remote = game:GetService("ReplicatedStorage").remoteFunctions.toolClick
    while true do
        remote:InvokeServer()
        task.wait(0.2)
    end
end)

-- Функция поддержания скорости
local function setSpeed(character)
    local humanoid = character:WaitForChild("Humanoid")
    while humanoid and humanoid.Parent do
        humanoid.WalkSpeed = 80
        task.wait(0.2)
    end
end

-- Запуск для текущего персонажа
if player.Character then
    setSpeed(player.Character)
end

-- Запуск для новых персонажей (после респавна)
player.CharacterAdded:Connect(setSpeed)
