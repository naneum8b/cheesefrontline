local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local event = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QueueJoinEvent")


local queuePopup = playerGui:WaitForChild("QueuePopup")
-- 그 안에 있는 내선 전화기 찾기
local uiSignal = queuePopup:WaitForChild("QueueUpdateSignal") 

------------------------------------------------------------------
-- 3. 서버로부터 상태 업데이트 받기 (핵심!)
------------------------------------------------------------------
event.OnClientEvent:Connect(function(responseType, currentCount, maxCount)
	
	if responseType == "QueueUpdate" then
		print("큐 상태 업데이트 받음:", currentCount, maxCount)
		
		-- [핵심] UI 스크립트에게 신호 쏘기! (함수 호출 대신 Event Fire)
		uiSignal:Fire(currentCount, maxCount)
	end
end)