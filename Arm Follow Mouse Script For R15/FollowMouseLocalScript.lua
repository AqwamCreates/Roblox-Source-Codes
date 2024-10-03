local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MouseFollowFunctionRemoteEvent = ReplicatedStorage.MouseFollowFunctionRemoteEvent

local currentCamera = workspace.CurrentCamera

local angle

local function checkMouseLocation()
	
	angle = currentCamera.CFrame.LookVector.Y
	
	MouseFollowFunctionRemoteEvent:FireServer(angle)
	
end

RunService.RenderStepped:Connect(checkMouseLocation)
