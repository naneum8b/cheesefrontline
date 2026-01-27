local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local event = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QueueJoinEvent")

-- 현재 대기 중인 모든 큐(방)를 저장하는 테이블
-- 구조: { {players={p1, p2}, id="room1"}, {players={p3}, id="room2"} }
local activeQueues = {}

local MAX_PLAYERS = 4

------------------------------------------------------------------
-- [내부 함수] 특정 큐에 있는 모든 사람에게 상태(인원수) 알리기
------------------------------------------------------------------
local function broadcastQueueStatus(queue)
	local currentCount = #queue.players
	
	for _, player in pairs(queue.players) do
		-- 각 클라이언트에게 "QueueUpdate" 신호와 현재 인원/최대 인원을 보냄
		event:FireClient(player, "QueueUpdate", currentCount, MAX_PLAYERS)
	end
	
	print("📢 큐 상태 업데이트: " .. currentCount .. "/" .. MAX_PLAYERS)
	
	-- 만약 4명이 꽉 찼다면?
	if currentCount >= MAX_PLAYERS then
		print("🚀 매칭 성공! 게임 시작 준비...")
		-- 여기에 게임 시작 로직 추가 (SceneManager 호출 신호 보내기 등)
		-- 예: event:FireClient(player, "GameStart")
	end
end

------------------------------------------------------------------
-- [내부 함수] 유저가 이미 다른 큐에 있는지 확인 (중복 참여 방지)
------------------------------------------------------------------
local function removePlayerFromQueues(player)
	for i, queue in pairs(activeQueues) do
		for j, p in pairs(queue.players) do
			if p == player then
				table.remove(queue.players, j)
				broadcastQueueStatus(queue) -- 나갔으니 남은 사람들에게 업데이트
				
				-- 사람이 아무도 없으면 방 삭제
				if #queue.players == 0 then
					table.remove(activeQueues, i)
				end
				return
			end
		end
	end
end

------------------------------------------------------------------
-- [메인] 클라이언트 요청 처리
------------------------------------------------------------------
event.OnServerEvent:Connect(function(player, requestType)
	
	if requestType == "JoinQueue" then
		print(player.Name .. "님의 큐 참가 요청")
		
		-- 1. 혹시 이미 들어가 있으면 기존 큐에서 제거 (안전장치)
		removePlayerFromQueues(player)
		
		-- 2. 빈 자리가 있는 큐 찾기
		local foundQueue = nil
		
		for _, queue in pairs(activeQueues) do
			if #queue.players < MAX_PLAYERS then
				foundQueue = queue
				break
			end
		end
		
		-- 3. 빈 큐가 있으면 넣고, 없으면 새로 생성
		if foundQueue then
			table.insert(foundQueue.players, player)
			broadcastQueueStatus(foundQueue)
		else
			print("빈 큐가 없음. 새로 생성합니다.")
			local newQueue = {
				players = { player },
				id = HttpService:GenerateGUID(false) -- 유니크 ID (필요시 사용)
			}
			table.insert(activeQueues, newQueue)
			broadcastQueueStatus(newQueue)
		end
		
	elseif requestType == "LeaveQueue" then
		-- 취소 버튼 누르면 호출
		removePlayerFromQueues(player)
	end
end)

-- [예외 처리] 유저가 게임을 강제로 종료하면 큐에서 빼줘야 함
Players.PlayerRemoving:Connect(function(player)
	removePlayerFromQueues(player)
end)