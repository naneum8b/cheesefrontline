-- SplashScene를 3초 후에 자동으로 닫는 스크립트

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- SplashScene가 복제될 때까지 기다림
local splashScene = playerGui:WaitForChild("SplashScene")
local mainScene = playerGui:WaitForChild("MainScene")

-- 3초 후에 SplashScene를 닫음
task.wait(3)

-- 페이드 아웃 효과 추가
local frame = splashScene:FindFirstChild("Frame")
if frame then
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Frame 페이드 아웃
	local fadeTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})

	-- BG (ImageLabel) 페이드 아웃
	local bg = frame:FindFirstChild("BG")
	if bg then
		local bgTween = TweenService:Create(bg, tweenInfo, {ImageTransparency = 1})

		-- Progress TextLabel도 페이드 아웃
		local progress = bg:FindFirstChild("Progress")
		if progress then
			local progressTween = TweenService:Create(progress, tweenInfo, {TextTransparency = 1})

			-- 모든 트윈을 동시에 재생
			fadeTween:Play()
			bgTween:Play()
			progressTween:Play()

			-- 가장 긴 트윈이 끝날 때까지 기다림
			fadeTween.Completed:Wait()
		else
			-- Progress가 없을 경우 Frame과 BG만 페이드 아웃
			fadeTween:Play()
			bgTween:Play()
			fadeTween.Completed:Wait()
		end
	else
		-- BG가 없을 경우 Frame만 페이드 아웃
		fadeTween:Play()
		fadeTween.Completed:Wait()
	end
end
-- Test
-- MainScene 활성화
local mainScene = playerGui:FindFirstChild("MainScene")
if mainScene then
	mainScene.Enabled = true
end

-- SplashScene 제거
splashScene:Destroy()