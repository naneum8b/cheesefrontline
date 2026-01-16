-- -- 유저 데이터 관리 서버 스크립트
-- local Players = game:GetService("Players")
-- local DataStoreService = game:GetService("DataStoreService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- -- 데이터 저장소 설정
-- local playerDataStore = DataStoreService:GetDataStore("CheeseFrontlineUserData")
-- local userDataEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UserDataRequest")

-- -- 기본 유저 데이터 구조
-- local DEFAULT_PLAYER_DATA = {
-- 	gold_cheese = 0,
-- 	items = {
-- 		item1 = 3,
-- 		item2 = 0,
-- 		item3 = 1,
-- 		item4 = 5,
-- 	},
-- 	level = 1,
-- 	experience = 0,
-- 	wins = 0,
-- 	losses = 0,
-- 	characters = {},
-- 	achievements = {},
-- 	settings = {
-- 		musicVolume = 0.5,
-- 		sfxVolume = 0.5,
-- 		graphicsQuality = "Medium"
-- 	},
-- 	lastLogin = nil,
-- 	playTime = 0
-- }

-- -- 플레이어 데이터 캐시 (메모리에 저장)
-- local playerDataCache = {}

-- -- 데이터 저장소에서 유저 데이터 가져오기
-- local function loadPlayerData(player)
-- 	local success, data = pcall(function()
-- 		return playerDataStore:GetAsync(tostring(player.UserId))
-- 	end)
	
-- 	if success then
-- 		if data then
-- 			-- 기존 데이터가 있으면 로드
-- 			playerDataCache[player.UserId] = data
-- 			print("[UserDataManager] " .. player.Name .. "의 데이터를 로드했습니다.")
-- 			return data
-- 		else
-- 			-- 신규 플레이어면 기본 데이터 생성
-- 			local newData = table.clone(DEFAULT_PLAYER_DATA)
-- 			newData.lastLogin = os.time()
-- 			playerDataCache[player.UserId] = newData
-- 			print("[UserDataManager] " .. player.Name .. "의 새로운 데이터를 생성했습니다.")
-- 			return newData
-- 		end
-- 	else
-- 		warn("[UserDataManager] " .. player.Name .. "의 데이터 로드 실패:", data)
-- 		-- 실패 시 기본 데이터 반환
-- 		local fallbackData = table.clone(DEFAULT_PLAYER_DATA)
-- 		playerDataCache[player.UserId] = fallbackData
-- 		return fallbackData
-- 	end
-- end

-- -- 데이터 저장소에 유저 데이터 저장하기
-- local function savePlayerData(player)
-- 	local data = playerDataCache[player.UserId]
-- 	if not data then
-- 		warn("[UserDataManager] " .. player.Name .. "의 데이터를 찾을 수 없습니다.")
-- 		return false
-- 	end
	
-- 	local success, errorMessage = pcall(function()
-- 		playerDataStore:SetAsync(tostring(player.UserId), data)
-- 	end)
	
-- 	if success then
-- 		print("[UserDataManager] " .. player.Name .. "의 데이터를 저장했습니다.")
-- 		return true
-- 	else
-- 		warn("[UserDataManager] " .. player.Name .. "의 데이터 저장 실패:", errorMessage)
-- 		return false
-- 	end
-- end

-- -- 유저 데이터 업데이트
-- local function updatePlayerData(player, updates)
-- 	local data = playerDataCache[player.UserId]
-- 	if not data then
-- 		warn("[UserDataManager] " .. player.Name .. "의 데이터를 찾을 수 없습니다.")
-- 		return false
-- 	end
	
-- 	-- 데이터 업데이트
-- 	for key, value in pairs(updates) do
-- 		if type(value) == "table" and type(data[key]) == "table" then
-- 			-- 테이블인 경우 병합
-- 			for subKey, subValue in pairs(value) do
-- 				data[key][subKey] = subValue
-- 			end
-- 		else
-- 			data[key] = value
-- 		end
-- 	end
	
-- 	playerDataCache[player.UserId] = data
-- 	return true
-- end

-- -- RemoteEvent 요청 처리
-- userDataEvent.OnServerEvent:Connect(function(player, requestType, ...)
-- 	if requestType == "LoadData" then
-- 		-- 데이터 로드 요청
-- 		local data = loadPlayerData(player)
-- 		userDataEvent:FireClient(player, "DataLoaded", data)
		
-- 	elseif requestType == "UpdateData" then
-- 		-- 데이터 업데이트 요청
-- 		local updates = select(1, ...)
-- 		if updatePlayerData(player, updates) then
-- 			userDataEvent:FireClient(player, "DataUpdated", true)
-- 		else
-- 			userDataEvent:FireClient(player, "DataUpdated", false)
-- 		end
		
-- 	elseif requestType == "GetData" then
-- 		-- 현재 데이터 요청
-- 		local data = playerDataCache[player.UserId]
-- 		if data then
-- 			userDataEvent:FireClient(player, "CurrentData", data)
-- 		else
-- 			userDataEvent:FireClient(player, "CurrentData", nil)
-- 		end
-- 	end
-- end)

-- -- 플레이어 접속 시 데이터 로드
-- Players.PlayerAdded:Connect(function(player)
-- 	loadPlayerData(player)
-- end)

-- -- 플레이어 접속 종료 시 데이터 저장
-- Players.PlayerRemoving:Connect(function(player)
-- 	savePlayerData(player)
-- 	playerDataCache[player.UserId] = nil
-- end)

-- -- 게임 종료 시 모든 플레이어 데이터 저장
-- game:BindToClose(function()
-- 	for _, player in ipairs(Players:GetPlayers()) do
-- 		savePlayerData(player)
-- 	end
-- end)

-- print("[UserDataManager] 유저 데이터 관리자가 시작되었습니다.")