local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local UIManager = {}

-- 모듈이 처음 require 될 때 LocalPlayer와 UI를 찾습니다.
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI 요소 경로 (실제 게임 구조에 맞게 확인 필요)
local splashScene = playerGui:WaitForChild("SplashScene")
local frame = splashScene:WaitForChild("Frame")
local bg = frame:WaitForChild("BG")
local progressLabel = bg:WaitForChild("Progress")
local mainScene = playerGui:FindFirstChild("MainScene")

-- 텍스트 업데이트
function UIManager.UpdateText(text)
    print(text)
	if progressLabel then
		progressLabel.Text = text
	end
end

-- 스플래시 화면 닫기 애니메이션
function UIManager.CloseSplash()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local fadeTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
	local bgTween = TweenService:Create(bg, tweenInfo, {ImageTransparency = 1})
	local progressTween = TweenService:Create(progressLabel, tweenInfo, {TextTransparency = 1})
	
	fadeTween:Play()
	bgTween:Play()
	progressTween:Play()
	
	fadeTween.Completed:Wait()
	
	if mainScene then mainScene.Enabled = true end
	
	-- 스플래시 UI 삭제
	if splashScene then splashScene:Destroy() end
end

return UIManager