local RunService = game:GetService("RunService")

local MouseFollowFunctionRemoteEvent = game:GetService("ReplicatedStorage").MouseFollowFunctionRemoteEvent

local currentCamera = workspace.CurrentCamera

local angle

local function checkMouseLocation()
	
	angle = currentCamera.CFrame.LookVector.Y
	
	MouseFollowFunctionRemoteEvent:FireServer(angle)
	
end

RunService.RenderStepped:Connect(checkMouseLocation)
