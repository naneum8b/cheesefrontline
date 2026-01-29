local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HealthEvent = ReplicatedStorage.RemoteEvents:WaitForChild("HealthChanged") 

local UnitManager = {}

local AllUnitsHealth = {} 
local PendingChanges = {} 

function UnitManager.InitUnit(unitModel, stats)
    AllUnitsHealth[unitModel] = stats.MaxHealth
    PendingChanges[unitModel] = stats.MaxHealth
end

function UnitManager.TakeDamage(unitModel, damageAmount)
    if not AllUnitsHealth[unitModel] then return end
    
    local newHp = AllUnitsHealth[unitModel] - damageAmount
    AllUnitsHealth[unitModel] = newHp
   
    PendingChanges[unitModel] = newHp 
    
    if newHp <= 0 then
        AllUnitsHealth[unitModel] = nil
        PendingChanges[unitModel] = 0
        
        task.delay(0.1, function() unitModel:Destroy() end)
    end
end

local PACKET_RATE = 0.1 
local lastSentTime = 0

RunService.Heartbeat:Connect(function(dt)
    lastSentTime += dt
    if lastSentTime < PACKET_RATE then
        return
    end
    lastSentTime = 0

    if next(PendingChanges) == nil then
        return
    end

    HealthEvent:FireAllClients(PendingChanges)
    
    PendingChanges = {}
end)

return UnitManager