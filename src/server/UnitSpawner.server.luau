local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UnitData = require(ReplicatedStorage.Unit.UnitData)

local UnitsFolder = ServerStorage:WaitForChild("Unit")

local Spawner = {}

function Spawner.Spawn(unitName, spawnPos, teamColor)
    -- 1. 데이터 확인
    local stats = UnitData.Stats[unitName]
    if not stats then warn("데이터 없음: " .. unitName) return end

    -- 2. 모델 찾기
    local originalModel = UnitsFolder:FindFirstChild(unitName)
    if not originalModel then warn("모델 없음: " .. unitName) return end

    -- 3. 복제 및 위치 설정
    local newUnit = originalModel:Clone()
    newUnit.Name = unitName -- 이름 확실하게
    newUnit.Parent = game.Workspace
    newUnit:PivotTo(CFrame.new(spawnPos + Vector3.new(0, 2, 0))) -- 땅 위에 살짝 띄워서

    -- 4. [핵심] 스탯 적용 (데이터 -> 실체화)
    local humanoid = newUnit:WaitForChild("Humanoid")
    local rootPart = newUnit:WaitForChild("HumanoidRootPart")
    
    -- A. 휴머노이드 속성 (체력, 속도)
    humanoid.MaxHealth = stats.MaxHealth
    humanoid.Health = stats.MaxHealth
    humanoid.WalkSpeed = stats.WalkSpeed
    
    -- "cheese"나 "Occupier"처럼 움직이면 안 되는 애들은 고정
    if stats.WalkSpeed == 0 then
        rootPart.Anchored = true
    else
        rootPart.Anchored = false
    end

    -- B. 전투 속성 (공격력, 사거리 등) -> Attribute(속성)에 저장
    -- 나중에 공격 스크립트가 이 값을 꺼내 씁니다.
    newUnit:SetAttribute("Damage", stats.Damage)
    newUnit:SetAttribute("Range", stats.Range)
    newUnit:SetAttribute("Armor", stats.Armor)
    newUnit:SetAttribute("AttackSpeed", stats.AttackSpeed)
    newUnit:SetAttribute("ViewRadius", stats.ViewRadius)

    -- 5. 미니맵 & 피아식별용 태그 달기
    CollectionService:AddTag(rootPart, "Unit")
    
    if teamColor == "Red" then
        CollectionService:AddTag(rootPart, "Enemy")
        -- 모델 색깔도 빨갛게 바꿔주면 구분하기 좋음
        for _, v in pairs(newUnit:GetChildren()) do
            if v:IsA("BasePart") then v.Color = Color3.fromRGB(255, 0, 0) end
        end
    elseif teamColor == "Blue" then
        CollectionService:AddTag(rootPart, "Ally")
        for _, v in pairs(newUnit:GetChildren()) do
            if v:IsA("BasePart") then v.Color = Color3.fromRGB(0, 0, 255) end
        end
    end
    
    return newUnit
end

return Spawner