-- MainScene의 ImageButton들을 누르면 MainScene을 비활성화하는 스크립트
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mainScene = player:WaitForChild("PlayerGui"):WaitForChild("MainScene")
local imageLabel = mainScene.Frame.ImageLabel

-- RemoteEvent 가져오기
local userDataEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UserDataRequest")

-- 유저 데이터 저장 변수
local userData = nil

-- 유저 데이터 가져오기
local function getUserData()
	if not userData then
		userDataEvent:FireServer("GetData")
		
		local connection
		connection = userDataEvent.OnClientEvent:Connect(function(responseType, data)
			if responseType == "CurrentData" then
				userData = data
				connection:Disconnect()
			end
		end)
		
		-- 데이터가 올 때까지 잠시 대기
		local startTime = tick()
		while not userData and (tick() - startTime) < 2 do
			task.wait(0.1)
		end
	end
	
	return userData
end

-- ImageButton들을 찾음
local imageButtons = {
	imageLabel:FindFirstChild("Main_PveButton"),
	imageLabel:FindFirstChild("Main_PvpButton"),
	imageLabel:FindFirstChild("Main_PrevButton")
}

-- 각 버튼의 기능을 정의하는 함수들
local buttonFunctions = {
	-- 첫 번째 버튼 기능
	function()
		print("첫 번째 버튼이 클릭되었습니다.")
		-- 여기에 첫 번째 버튼의 특정 기능을 추가하세요
		-- 예: 특정 씬으로 전환, 아이템 구매, 설정 열기 등
	end,
	
	-- 두 번째 버튼 기능
	function()
		print("두 번째 버튼이 클릭되었습니다.")
		-- 여기에 두 번째 버튼의 특정 기능을 추가하세요
		-- 예: 게임 시작, 캐릭터 선택, 스토리 모드 등
	end,
	
	-- 세 번째 버튼 기능
	function()
		print("세 번째 버튼이 클릭되었습니다.")
		-- 여기에 세 번째 버튼의 특정 기능을 추가하세요
		-- 예: 상점 열기, 친구 목록, 로그아웃 등
	end

}

-- 공통으로 실행될 함수 (모든 버튼 클릭 후 실행)
local function onButtonClicked(buttonIndex)
	-- 해당 버튼의 특정 기능 실행
	if buttonFunctions[buttonIndex] then
		buttonFunctions[buttonIndex]()
	end
	print("onButtonClicked")
	-- MainScene 비활성화 (공통 동작)
	mainScene.Enabled = false
end

-- 각 ImageButton에 클릭 이벤트 연결
for i, imageButton in ipairs(imageButtons) do
	if imageButton and imageButton:IsA("ImageButton") then
		imageButton.MouseButton1Click:Connect(function()
			onButtonClicked(i)
		end)
	end
end