local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = {}

-- 리모트 이벤트 위치 (환경에 맞게 경로 수정하세요)
local userDataEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UserDataRequest")

function DataManager.LoadUserData(onStatusUpdate)
	-- 1. 상태 알림 호출
	if onStatusUpdate then onStatusUpdate("서버 연결 중...") end
	task.wait(0.5)
	
	if onStatusUpdate then onStatusUpdate("유저 데이터 로딩 중...") end
	
	-- 2. 서버 요청
	userDataEvent:FireServer("LoadData")
	print("서버 요청")
    
	-- 3. 응답 대기
	local loadedData = nil
	local isFinished = false
	local connection
	
	connection = userDataEvent.OnClientEvent:Connect(function(responseType, data)
		if responseType == "DataLoaded" then
			loadedData = data
			isFinished = true
			if connection then connection:Disconnect() end
		end
        print(responseType)
	end)
	
	-- 데이터가 올 때까지 대기
	while not isFinished do
		task.wait(0.1)
	end
	
	if onStatusUpdate then onStatusUpdate("데이터 로드 완료!") end
	task.wait(0.5)
	
	return loadedData
end

return DataManager