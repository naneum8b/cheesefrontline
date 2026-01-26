local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider") -- 에셋 로딩 서비스
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local SceneManager = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI들 미리 찾아놓기 (이름이 정확해야 합니다!)
local mainScene = playerGui:WaitForChild("MainScene")
local loadingScene = playerGui:WaitForChild("LoadingScene")
local ingameScene = playerGui:WaitForChild("IngameScene")
local queuePopup = playerGui:WaitForChild("QueuePopup")

-- [핵심] 게임 시작 프로세스 (로딩 포함)
function SceneManager.StartGameProcess()
	print("🚀 게임 시작 프로세스 진입")

	-- 1. 큐 팝업 & 메인 화면 끄기
	queuePopup.Enabled = false
	mainScene.Enabled = false
	
	-- 2. 로딩 화면 켜기
	loadingScene.Enabled = true
	
	-- 로딩 바나 텍스트가 있다면 초기화
	local loadingLabel = loadingScene:FindFirstChild("LoadingScene_ProgressLabel", true) 
	if loadingLabel then loadingLabel.Text = "에셋 로딩 중..." end

	--------------------------------------------------------
	-- 3. 실질적 에셋 로딩 (ContentProvider)
	--------------------------------------------------------
	-- 여기서 게임에 필요한 에셋(이미지, 소리, 메쉬 등)을 미리 읽어옵니다.
	-- 예시: IngameScene 안에 있는 모든 이미지 로드
	
	local assetsToLoad = { ingameScene } -- 로딩할 대상 목록
	
	local startTime = tick()
	
	-- PreloadAsync는 에셋을 다 읽을 때까지 스크립트를 멈춥니다(Yield).
	-- 콜백 함수를 통해 진행률을 표시할 수도 있습니다.
	ContentProvider:PreloadAsync(assetsToLoad, function(contentId, status)
		-- (선택사항) 여기서 로딩 바 게이지를 채울 수 있습니다.
		-- print("로딩 중:", contentId)
	end)
	
	-- 로딩이 너무 빨리 끝나면 어색하니까 최소 2초는 보여주기 (선택사항)
	local elapsedTime = tick() - startTime
	if elapsedTime < 2 then
		task.wait(2 - elapsedTime)
	end
	
	--------------------------------------------------------
	-- 4. 로딩 완료 -> 인게임 진입
	--------------------------------------------------------
	print("✅ 로딩 완료! 인게임으로 진입합니다.")
	if loadingLabel then loadingLabel.Text = "게임 시작!" end
	task.wait(0.5) -- "게임 시작!" 문구 보여줄 시간
	
	loadingScene.Enabled = false -- 로딩 끄기
	ingameScene.Enabled = true   -- 인게임 켜기
end

return SceneManager