local frame = script.Parent:waitForChild("Frame")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local area = frame:WaitForChild("AttackDirectionButtonArea")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackDirectionEvent")

local template = script.Parent.Templates.Slot

local function setAttackDirectionButtonsVisible(visible) 
    for _, element in ipairs(area:GetChildren()) do
        if element:IsA("Frame") then 
            if element.LayoutOrder == 5 then
                element.Button.Visible = not visible
            else
                element.Button.Visible = visible
            end
        end
    end
end

for i = 1, 9 do
    local slot = template:Clone()

    slot.LayoutOrder = i
    slot.Parent = area
    if i ~= 5 then
        slot.Button.Visible = false
    end

    slot.Button.MouseButton1Click:Connect(function()
        if slot.LayoutOrder == 5 then
            setAttackDirectionButtonsVisible(true)
        else
            remoteEvent:FireServer(slot.LayoutOrder)
            setAttackDirectionButtonsVisible(false)
        end
    end)
end