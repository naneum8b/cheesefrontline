-- MainScene의 ImageButton들을 누르면 MainScene을 비활성화하는 스크립트
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local queuePopup = player:WaitForChild("PlayerGui"):WaitForChild("QueuePopup")
local imageLabel = queuePopup.Frame.ImageLabel

-- ImageButton들을 찾음
local imageButtons = {
	imageLabel:FindFirstChild("QueuePopup_ExitButton"),
}

-- 각 버튼의 기능을 정의하는 함수들
local buttonFunctions = {
	-- 첫 번째 버튼 기능
	function()
		print("첫 번째 버튼이 클릭되었습니다.")
		-- 여기에 첫 번째 버튼의 특정 기능을 추가하세요
		-- 예: 특정 씬으로 전환, 아이템 구매, 설정 열기 등
	end,
}

-- 공통으로 실행될 함수 (모든 버튼 클릭 후 실행)
local function onButtonClicked(buttonIndex)
	-- 해당 버튼의 특정 기능 실행
	if buttonFunctions[buttonIndex] then
		buttonFunctions[buttonIndex]()
	end
	event:FireServer("LeaveQueue")
	queuePopup.Enabled = false
end

-- 각 ImageButton에 클릭 이벤트 연결
for i, imageButton in ipairs(imageButtons) do
	if imageButton and imageButton:IsA("ImageButton") then
		imageButton.MouseButton1Click:Connect(function()
			onButtonClicked(i)
		end)
	end
end