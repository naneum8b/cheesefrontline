local frame = script.Parent:waitForChild("Frame")
local area = frame:WaitForChild("AttackDirectionButtonArea")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents")

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

local function InitializeAttackDirectionButton()
    local template = script.Parent.Templates.Slot
    local attackEvent = remoteEvent:WaitForChild("AttackDirectionEvent")

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
                attackEvent:FireServer(slot.LayoutOrder)
                setAttackDirectionButtonsVisible(false)
            end
        end)
    end
end

local function InitializeUpgradeButton()
    local upgradeEvent = remoteEvent:WaitForChild("UpgradeEvent")

    frame.INGAME_ATTACK_UPGRADE.MouseButton1Click:Connect(function()
        upgradeEvent:FireServer("Attack")
        print("Attack upgrade clicked")
    end)
    
    frame.INGAME_DEFENSE_UPGRADE.MouseButton1Click:Connect(function()
        upgradeEvent:FireServer("Defense")
        print("Defense upgrade clicked")
    end)
end

local function InitializePickingOccupaierButton()
    local pickEvent = remoteEvent:WaitForChild("PickOccupierEvent")

    frame.INGAME_OCCUPATION_UNIT_ICON.MouseButton1Click:Connect(function()
        pickEvent:FireServer()
        print("Pick occupier clicked")
    end)
end

-- Initialization
InitializeAttackDirectionButton()
InitializeUpgradeButton()
InitializePickingOccupaierButton()