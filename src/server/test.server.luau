-- 🔹 서비스
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TriggerZone = workspace:WaitForChild("TriggerZone")

-- 🔹 스폰할 모델
local modelName = "CubeMouse_exp1"
local modelToSpawn = ReplicatedStorage:FindFirstChild(modelName)
if not modelToSpawn then
	warn(modelName .. " 모델을 ReplicatedStorage에서 찾을 수 없습니다!")
	return
end

-- 🔹 모델 크기
local dummy = modelToSpawn:Clone()
dummy.Parent = workspace
local modelSize = dummy:GetExtentsSize()
dummy:Destroy()

local stepX = modelSize.X
local stepZ = modelSize.Z

-- 🔹 플레이어 상태 관리
local activePlayers = {}
local debounce = {}

local zone = workspace.TriggerZone
local spawnY = zone.Position.Y - zone.Size.Y/2
-- 🔹 나선형 좌표 생성기
local function createSpiral(origin)
	local directions = {
		Vector3.new(0, 0, -stepZ),  -- 아래
		Vector3.new(-stepX, 0, 0),  -- 좌
		Vector3.new(0, 0, stepZ),   -- 위
		Vector3.new(stepX, 0, 0)    -- 우
	}
	local dirIndex = 1
	local stepsToTake = 1
	local stepsDone = 0
	local changeStep = 0
	local currentPos = origin

	return function()
		local posToReturn = currentPos
		local dir = directions[dirIndex]

		currentPos += dir
		stepsDone += 1

		if stepsDone >= stepsToTake then
			stepsDone = 0
			dirIndex += 1
			if dirIndex > 4 then dirIndex = 1 end

			changeStep += 1
			if changeStep == 2 then
				stepsToTake += 1
				changeStep = 0
			end
		end

		return posToReturn
	end
end

-- 🔹 충돌 체크
local function isPositionFree(position)
	local parts = workspace:GetPartBoundsInRadius(position, math.max(stepX, stepZ)/2)
	return #parts == 0
end

-- 🔹 시뮬레이션 시작
local function startSimulation(player)
	if activePlayers[player] then return end
	activePlayers[player] = true

	local origin = Vector3.new(TriggerZone.Position.X, -spawnY, TriggerZone.Position.Z)  -- 🔹 기준 위치를 TriggerZone 중심으로
	local nextPos = createSpiral(origin)
	print("Next spawn position:", nextPos())

	task.spawn(function()
    while activePlayers[player] do
        local pos = nil

        -- 비어있는 위치 찾기
        local spiral = createSpiral(TriggerZone.Position)
        for i = 1, 100 do -- 최대 100칸 탐색
            local candidate = spiral()
            if isPositionFree(candidate) then
                pos = candidate
                break
            end
        end

        if pos then
            local newModel = modelToSpawn:Clone()
            local size = newModel:GetExtentsSize()
            local targetPos = Vector3.new(pos.X, pos.Y + size.Y/2, pos.Z)
            newModel:PivotTo(CFrame.new(targetPos))
            newModel.Parent = workspace
        else
            warn("스폰할 빈 공간을 찾지 못했습니다!")
        end

        task.wait(1) -- 1초 대기
    end
end)
end

-- 🔹 시뮬레이션 종료
local function stopSimulation(player)
	activePlayers[player] = nil
end

-- 🔹 TriggerZone 감지
TriggerZone.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not activePlayers[player] and not debounce[player] then
			debounce[player] = true
			print(player.Name .. "가 TriggerZone에 들어옴!")
			startSimulation(player)
			task.delay(0.2, function()
				debounce[player] = false
			end)
		end
	end
end)

TriggerZone.TouchEnded:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			print(player.Name .. "가 TriggerZone에서 나감!")
			stopSimulation(player)
		end
	end
end)

-- 🔹 점프 감지
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.StateChanged:Connect(function(_, newState)
			if newState == Enum.HumanoidStateType.Jumping then
				stopSimulation(player)
				print(player.Name .. "가 점프하여 시뮬레이션 종료")
			end
		end)
	end)
end)
