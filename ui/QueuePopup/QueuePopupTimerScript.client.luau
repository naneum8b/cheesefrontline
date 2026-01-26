local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. 제어할 ScreenGui 찾기
-- (스크립트 위치에 따라 경로를 수정하세요. 예: script.Parent)
local queuePopup = playerGui:WaitForChild("QueuePopup") 

-- (선택사항) 남은 시간을 표시할 텍스트 라벨이 있다면 가져오기
local timerLabel = queuePopup:FindFirstChild("QueuePopup_TimerLabel", true) 

-- 설정값
local TIMEOUT_SECONDS = 20

--------------------------------------------------------------------------------
-- 타이머 로직 함수
--------------------------------------------------------------------------------
local function startTimer()
	local startTime = tick()
	
	-- 2. 팝업이 켜져 있는 동안 계속 반복 (최대 20초)
	while queuePopup.Enabled do
		local elapsed = tick() - startTime
		local remaining = math.ceil(TIMEOUT_SECONDS - elapsed)
		
		-- (선택사항) 화면에 남은 시간 표시
		if timerLabel then
			timerLabel.Text = "매칭 중... (" .. remaining .. "초)"
		end
		
		-- 3. 20초가 지났는지 체크
		if elapsed >= TIMEOUT_SECONDS then
			print("⏰ 타임아웃! 매칭 팝업을 닫습니다.")
			queuePopup.Enabled = false -- 팝업 끄기
			
			-- 여기에 "매칭 실패" 알림을 띄우는 코드를 추가할 수도 있습니다.
			break
		end
		
		task.wait(0.1) -- 0.1초마다 검사
	end
end

--------------------------------------------------------------------------------
-- 이벤트 연결
--------------------------------------------------------------------------------
-- Enabled 속성이 바뀔 때마다 실행됨
queuePopup:GetPropertyChangedSignal("Enabled"):Connect(function()
	if queuePopup.Enabled then
		-- 팝업이 켜지면 타이머 시작 (별도 스레드에서 실행)
		task.spawn(startTimer)
	else
		-- 팝업이 꺼지면?
		-- 위 while 문에서 queuePopup.Enabled를 체크하므로
		-- 자동으로 루프가 종료됩니다. 별도 처리가 필요 없습니다.
		print("팝업이 닫혀서 타이머가 종료됩니다.")
	end
end)