local queuePopup = script.Parent
local updateSignal = queuePopup:WaitForChild("QueueUpdateSignal") -- 내선 전화기
local stateBG = queuePopup:WaitForChild("QueuePopup_BG"):WaitForChild("QueuePopup_StateBG") -- 경로 확인

-- 2. 사용할 이미지 에셋 ID (여기에 님의 이미지 ID를 넣으세요!)
-- 예시: "rbxassetid://123456789"
-- local IMG_ON = "rbxassetid://000000000"  -- 켜진 상태 (유저 있음)
-- local IMG_OFF = "rbxassetid://111111111" -- 꺼진 상태 (빈 자리)

local COLOR_ON = Color3.fromRGB(0, 255, 0)    -- 🟢 초록색 (활성)
local COLOR_OFF = Color3.fromRGB(75, 75, 75)  -- ⚫ 회색 (비활성)


-- [기능] UI 업데이트 함수
local function updateUI(currentCount, maxCount)
	print("UI 스크립트: 화면을 갱신합니다.")
	-- 1번 슬롯부터 4번 슬롯까지 반복해서 검사
	for i = 1, 4 do
		local userName = "QueuePopup_User" .. i -- "Slot1", "Slot2"... 이름을 만듦
		local userImage = stateBG:FindFirstChild(userName)

		if userImage then
			-- [핵심 로직]
			-- 현재 순번(i)이 접속 인원(currentCount)보다 작거나 같으면 ON
			-- 예: current가 2일 때 -> 1(ON), 2(ON), 3(OFF), 4(OFF)
			if i <= currentCount then
				userImage.ImageColor3 = COLOR_ON
			else
				userImage.ImageColor3 = COLOR_OFF
			end
		end
	end
end

-- [연결] 누가 내선 전화를 걸면(Fire) 이 함수를 실행해라!
updateSignal.Event:Connect(updateUI)
