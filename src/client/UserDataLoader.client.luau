local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. 모듈 불러오기 (경로 주의!)
local ClientModules = ReplicatedStorage:WaitForChild("ClientModules")
local DataManager = require(ClientModules:WaitForChild("UserDataManager"))
local UIManager = require(ClientModules:WaitForChild("SplashProgress"))

-- 2. 메인 실행 함수
local function main()
	local startTime = tick()
	
	UIManager.UpdateText("게임 초기화 중...")
	task.wait(0.5)
	
	-- [핵심] DataManager에게 일을 시키면서, 상태가 변하면 UIManager를 부르라고 전달
	local userData = DataManager.LoadUserData(function(msg)
		print(msg)
		UIManager.UpdateText(msg)
	end)
	
	-- 최소 3초 대기 로직 (너무 빨리 로딩돼도 스플래시 유지)
	local elapsedTime = tick() - startTime
	print("3초대기:", userData)
	if elapsedTime < 3 then
		UIManager.UpdateText("리소스 정리 중...")
		task.wait(3 - elapsedTime)
	end
	
	-- 결과 처리
	if userData then
		print("로드 성공:", userData)
		-- userData를 다른 시스템에 넘겨주거나 저장하는 로직 추가 가능
	else
		UIManager.UpdateText("데이터 로드 실패!")
		task.wait(2)
	end
	
	-- 스플래시 종료
	UIManager.CloseSplash()
end

-- 스크립트 시작
main()