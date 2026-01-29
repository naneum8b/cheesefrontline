local RunService = game:GetService("RunService")
local UnitMover = {}

local movingUnits = {}

RunService.Heartbeat:Connect(function(deltaTime)
    for unit, data in pairs(movingUnits) do
        if not unit.Parent then
            movingUnits[unit] = nil
            continue
        end

        local root = unit.PrimaryPart
        local currentPos = root.Position
        local targetPos = data.Target
        local speed = data.Speed
        
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude
        
        if distance < 0.1 then
            movingUnits[unit] = nil 
            continue
        end
        
        direction = direction.Unit 
        local moveStep = direction * speed * deltaTime
        
        if moveStep.Magnitude > distance then
            moveStep = direction * distance
        end
        
        local newPos = currentPos + moveStep
        root.CFrame = CFrame.lookAt(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
    end
end)

function UnitMover.MoveTo(unit, targetPosition, speed)
    if not unit or not unit.PrimaryPart then return end
    
    movingUnits[unit] = {
        Target = Vector3.new(targetPosition.X, unit.PrimaryPart.Position.Y, targetPosition.Z), 
        Speed = speed
    }
end

function UnitMover.Stop(unit)
    movingUnits[unit] = nil
end

return UnitMover