local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:FindFirstChild("Events")
local MouseFollowFunctionRemoteEvent = Events.MouseFollowFunctionRemoteEvent

local currentCamera = workspace.CurrentCamera

local angle


local function checkMouseLocation()
	
	angle = currentCamera.CFrame.LookVector.Y
	
	MouseFollowFunctionRemoteEvent:FireServer(angle)
	
end

RunService.RenderStepped:Connect(checkMouseLocation)
