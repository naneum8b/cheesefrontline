local StarterGui = game:GetService("StarterGui")

local function disableCoreUI()
	-- 최대 10번 정도 시도 (무한 루프 방지)
	for i = 1, 10 do
		local success, err = pcall(function()
			-- 모든 기본 UI(채팅, 플레이어 목록, 감정표현 등) 끄기
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		end)

		if success then
			print("✅ 기본 UI 비활성화 성공!")
			break -- 성공했으면 반복 종료
		else
			-- 실패하면 0.2초 뒤에 다시 시도
			task.wait(0.2)
		end
	end
end

-- 스크립트 실행 즉시 호출
task.spawn(disableCoreUI)