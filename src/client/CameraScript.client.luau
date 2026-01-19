-- Workspace prperties에서
-- * streamingEnabled: 체크 해제

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- 시작 위치에 따라 설정값 세팅 필요
-- ================= [설 정] =================
local MOVE_SPEED = 1.0
local ZOOM_SPEED = 3.0
local ROTATE_SPEED = 0.005
local MIN_DIST = 20          -- 줌 최소 거리
local MAX_DIST = 100         -- 줌 최대 거리
local INIT_DIST = 50        -- 초기 줌 거리
local VIEW_ROTATION = -15    -- 초기 회전 각도
local VIEW_ANGLE = -60       -- 카메라 각도
local START_POS = Vector3.new(-45, 0, -60) -- 시작 위치
-- ======================================================================

-- 변수 초기화
local currentDist = INIT_DIST
local currentYaw = VIEW_ROTATION * (math.pi / 180) 
local focusPosition = START_POS
local isRightMouseDown = false 
local hasZoomed = false 

-----------------------------------------------------------------------
-- [1] 캐릭터 처리: 투명하게 만들고 + 땅에 박아버림 (움직임 봉인)
-----------------------------------------------------------------------
local function LockAndHideCharacter(char)
    if not char then return end

    -- 0.5초 대기 (로딩 안전장치)
    task.wait(0.5)

    local rootPart = char:WaitForChild("HumanoidRootPart", 5)
    
    -- 1. 물리적 고정 (Anchored) -> WASD 눌러도 몸이 안 나감
    if rootPart then
        rootPart.Anchored = true 
    end
    
    -- 2. 눈에 안 보이게 투명화
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
            part.CanCollide = false -- 충돌도 없앰
        end
    end
end

-- 캐릭터가 태어날 때마다 실행
if player.Character then LockAndHideCharacter(player.Character) end
player.CharacterAdded:Connect(LockAndHideCharacter)

-- 시작하자마자 카메라 모드 변경
camera.CameraType = Enum.CameraType.Scriptable

-- 입력 감지 (우클릭)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- 입력 감지 (줌 & 회전)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local zoomAmount = input.Position.Z * ZOOM_SPEED
        currentDist = currentDist - zoomAmount
        currentDist = math.clamp(currentDist, MIN_DIST, MAX_DIST)
        hasZoomed = true 
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown then
        local deltaX = input.Delta.X
        currentYaw = currentYaw - (deltaX * ROTATE_SPEED)
    end
end)

-- 카메라 위치 계산 
local function UpdateCamera()
    local camCFrame = camera.CFrame
    local camRight = camCFrame.RightVector
    local camForward = camCFrame.LookVector
    
    camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
    camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

    local finalMove = Vector3.new(0,0,0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then finalMove = finalMove + camForward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then finalMove = finalMove - camForward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then finalMove = finalMove - camRight end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then finalMove = finalMove + camRight end

    if finalMove.Magnitude > 0 then
        local speedMultiplier = currentDist / 50 
        focusPosition = focusPosition + (finalMove.Unit * MOVE_SPEED * speedMultiplier)
    end

    local rotationCFrame = CFrame.Angles(0, currentYaw, 0) 
    local pitchCFrame = CFrame.Angles(math.rad(VIEW_ANGLE), 0, 0)
    local offset = CFrame.new(0, 0, currentDist)
    
    camera.CFrame = CFrame.new(focusPosition) * rotationCFrame * pitchCFrame * offset
end

UpdateCamera() 

-- 매 프레임 반복
RunService.RenderStepped:Connect(function()
    -- if camera.CameraType ~= Enum.CameraType.Scriptable then
    --     camera.CameraType = Enum.CameraType.Scriptable
    -- end

    -- 움직임 체크
    local isMovingKeys = 
        UserInputService:IsKeyDown(Enum.KeyCode.W) or
        UserInputService:IsKeyDown(Enum.KeyCode.S) or
        UserInputService:IsKeyDown(Enum.KeyCode.A) or
        UserInputService:IsKeyDown(Enum.KeyCode.D)

    -- 최적화: 아무것도 안 하면 계산 안 함
    if not isMovingKeys and not isRightMouseDown and not hasZoomed then
        return
    end

    -- 움직임이 있으면 계산 실행
    UpdateCamera()
    
    hasZoomed = false
end)