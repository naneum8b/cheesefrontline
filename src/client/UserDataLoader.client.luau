-- 스플래시 화면에서 유저 데이터를 로드하는 스크립트
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent 가져오기
local userDataEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UserDataRequest")

-- UI 요소들
local splashScene = playerGui:WaitForChild("SplashScene")
local frame = splashScene:WaitForChild("Frame")
local bg = frame:WaitForChild("BG")
local progressLabel = bg:WaitForChild("Progress")

-- 로딩 상태 관리
local isLoading = true
local userData = nil
local loadingStartTime = tick()

-- 진행률 텍스트 업데이트
local function updateProgress(text)
	if progressLabel then
		progressLabel.Text = text
	end
end

-- 데이터 로드 함수
local function loadUserData()
	updateProgress("서버 연결 중...")
	task.wait(0.5)
	
	updateProgress("유저 데이터 로딩 중...")
	
	-- 서버에 데이터 요청
	userDataEvent:FireServer("LoadData")
	
	-- 응답 대기
	local connection
	connection = userDataEvent.OnClientEvent:Connect(function(responseType, data)
		if responseType == "DataLoaded" then
			userData = data
			updateProgress("데이터 로드 완료!")
			
			-- 로딩 완료 후 잠시 대기
			task.wait(0.5)
			
			isLoading = false
			connection:Disconnect()
		end
	end)
end

-- 스플래시 화면 닫기 함수
local function closeSplashScene()
	-- 최소 3초는 보여주기
	local elapsedTime = tick() - loadingStartTime
	if elapsedTime < 3 then
		task.wait(3 - elapsedTime)
	end
	
	-- 페이드 아웃 효과
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	-- Frame 페이드 아웃
	local fadeTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
	
	-- BG 페이드 아웃
	local bgTween = TweenService:Create(bg, tweenInfo, {ImageTransparency = 1})
	
	-- Progress 페이드 아웃
	local progressTween = TweenService:Create(progressLabel, tweenInfo, {TextTransparency = 1})
	
	-- 모든 트윈 동시 재생
	fadeTween:Play()
	bgTween:Play()
	progressTween:Play()
	
	-- 트윈 완료 대기
	fadeTween.Completed:Wait()
	
	-- MainScene 활성화
	local mainScene = playerGui:FindFirstChild("MainScene")
	if mainScene then
		mainScene.Enabled = true
	end
	
	-- SplashScene 제거
	splashScene:Destroy()
end

-- 메인 로직
local function main()
	updateProgress("게임 초기화 중...")
	task.wait(0.5)
	
	-- 유저 데이터 로드 시작
	loadUserData()
	
	-- 로딩 완료 대기
	while isLoading do
		task.wait(0.1)
	end
	
	-- 데이터 로드 성공 확인
	if userData then
		print("[UserDataLoader] 유저 데이터 로드 성공:")
		print("  코인:", userData.coins)
		print("  레벨:", userData.level)
		print("  경험치:", userData.experience)
		
		-- 여기서 로드된 데이터를 기반으로 UI 업데이트 가능
		-- 예: 메인 화면에 코인 표시, 레벨 표시 등
		
		-- 스플래시 화면 닫기
		closeSplashScene()
	else
		-- 데이터 로드 실패 시
		updateProgress("데이터 로드 실패!")
		task.wait(2)
		closeSplashScene()
	end
end

-- 스크립트 시작
coroutine.wrap(main)()