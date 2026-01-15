local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local IngameScene = playerGui:WaitForChild("IngameScene")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackDirectionEvent")

local button = IngameScene.Frame.Button

local function setAttackDirectionButtonsvisible(visible) 
    for _, element in ipairs(button:GetChildren()) do
        if element:IsA("ImageButton") then
            if element:GetAttribute("DirNum") == 5 then
                element.Visible = not visible
            else
                element.Visible = visible
            end
        end
    end
end

for _, element in ipairs(button:GetChildren()) do
    -- 1. 버튼인지 확인 
    if element:IsA("ImageButton") then
        -- 2. 이벤트 연결
        element.MouseButton1Click:Connect(function()
            -- 3. 버튼에 심어둔 속성(Attribute) 가져오기
            local num = element:GetAttribute("DirNum")
            
            if num then
                print("선택된 버튼:", num)
                -- 리모트 이벤트 전송
                if num == 5 then
                    setAttackDirectionButtonsvisible(true)
                else
                    remoteEvent:FireServer(num)
                    setAttackDirectionButtonsvisible(false)
                end
            else
                warn(element.Name .. " 버튼에 DirNum 속성이 없습니다!")
            end
        end)
    end
end
