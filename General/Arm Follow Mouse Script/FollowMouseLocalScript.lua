local RunService = game:GetService("RunService")

local MouseFollowFunctionRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("MouseFollowFunctionRemoteEvent")

local CurrentCamera = workspace.CurrentCamera

local halfPi = math.pi / 2 -- to replace math.rad(90) since math.90 requires it to convert

local function checkMouseLocation()
		
	local angleYInRadians = CurrentCamera.CFrame.LookVector.Y + halfPi -- remove the halfPi if roblox issue is solved
	
	MouseFollowFunctionRemoteEvent:FireServer(angleYInRadians)
	
end

local function run()
	
	RunService.Heartbeat:Connect(checkMouseLocation)
	
end

run()
