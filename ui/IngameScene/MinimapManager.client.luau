local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local mapFrame = script.Parent.Frame.Minimap.MapFrame
local dotsContainer = mapFrame:WaitForChild("DotsContainer")

local lastUpdate = 0
local UPDATE_INTERVAL = 0.05 -- 0.05초마다 업데이트 (1초에 20번)

-- ==========================================
-- 🗺️ 맵 설정 (144x144, 6x6 타일맵 기준)
-- ==========================================
local MAP_SIZE = Vector2.new(200, 200)
local MAP_CENTER = Vector3.new(6, 2.5, -127)
local TAG_NAME = "MinimapUnit" -- 감지할 태그 이름
-- ==========================================

-- 현재 표시 중인 점들을 관리하는 테이블 (유닛 파트 -> 점 GUI)
local activeBlips = {}

-- 1. 월드 좌표 -> 미니맵 좌표 변환
local function worldToMap(worldPos)
    local currentFrameSize = mapFrame.AbsoluteSize

	local relativePos = worldPos - MAP_CENTER
	local scaleX = relativePos.X / currentFrameSize.X
	local scaleY = relativePos.Z / currentFrameSize.Y 
	return UDim2.new(0.5 + scaleX, 0, 0.5 + scaleY, 0)
end

-- 2. 점(Blip) 생성 함수
local function createBlip(targetPart)
	if activeBlips[targetPart] then 
        return 
    end -- 이미 있으면 패스

	local blip = Instance.new("Frame")
	blip.Name = "UnitDot"
	blip.Size = UDim2.new(0, 4, 0, 4) -- 점 크기 (4픽셀)
	blip.BorderSizePixel = 0
    blip.ZIndex = 10 
	
	-- 색상 결정 로직
	-- 1순위: 파트에 'DotColor'라는 속성(Attribute)이 있으면 그 색 사용
	-- 2순위: 없으면 기본 빨간색
	local colorAttr = targetPart:GetAttribute("DotColor")
	if colorAttr then
		blip.BackgroundColor3 = colorAttr
	else
		blip.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- 기본값: 빨강
	end

	-- 둥글게 만들기
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = blip
	
	blip.AnchorPoint = Vector2.new(0.5, 0.5)
	blip.Parent = dotsContainer
	
	-- 테이블에 등록
	activeBlips[targetPart] = blip
end

-- 3. 점 제거 함수
local function removeBlip(targetPart)
	if activeBlips[targetPart] then
		activeBlips[targetPart]:Destroy()
		activeBlips[targetPart] = nil
	end
end

-- ==========================================
-- 📡 이벤트 연결 (태그 감지 시스템)
-- ==========================================

-- A. 게임 시작 시 이미 있는 태그된 파트들 처리
for _, part in pairs(CollectionService:GetTagged(TAG_NAME)) do
	createBlip(part)
end

-- B. 새롭게 태그된 파트가 들어오면 감지 (스폰 등)
CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(createBlip)

-- C. 태그된 파트가 사라지거나 태그가 빠지면 감지 (사망 등)
CollectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(removeBlip)

-- ==========================================
-- 🔄 매 프레임 위치 업데이트
-- ==========================================
RunService.RenderStepped:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    
    if lastUpdate < UPDATE_INTERVAL then 
        return 
    end 
    
    lastUpdate = 0

    local currentFrameSize = mapFrame.AbsoluteSize

	for part, blip in pairs(activeBlips) do
		if part.Parent then -- 파트가 세상에 존재하면
			blip.Position = worldToMap(part.Position)
		else
			-- 파트가 사라졌는데 이벤트가 늦을 경우를 대비해 여기서도 삭제
			removeBlip(part)
		end
	end
	
	
end)