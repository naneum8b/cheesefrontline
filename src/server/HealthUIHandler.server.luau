local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HealthEvent = ReplicatedStorage.RemoteEvents:WaitForChild("HealthChanged")

HealthEvent.OnClientEvent:Connect(function(healthTable)
    for unitModel, newHp in pairs(healthTable) do
        if not unitModel or not unitModel.Parent then continue end
        
        local billboard = unitModel:FindFirstChild("HealthBillboard")
        if billboard then
            local max = billboard:GetAttribute("MaxHP") or 100
            
            if newHp <= 0 then
                billboard.Enabled = false
            else
                local bar = billboard:FindFirstChild("Bar")
                if bar then
                   bar.Size = UDim2.new(newHp / max, 0, 1, 0)
                end
            end
        end
    end
end)