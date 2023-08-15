local MouseFollowFunctionRemoteEvent = game:GetService("ReplicatedStorage").MouseFollowFunctionRemoteEvent

local Character = script.Parent

local Player = game.Players:GetPlayerFromCharacter(Character)

local RightShoulder = Character.Torso["Right Shoulder"]

local nintyDegreesToRadians = math.rad(90)

local function rotateShoulder(Shoulder, angle)
	
	local ShoulderC0 = Shoulder.C0
	
	local ShoulderC0Vector = ShoulderC0.Position
	
	Shoulder.C0 = CFrame.new(ShoulderC0Vector) * CFrame.Angles(0, nintyDegreesToRadians, angle) 
	
end

MouseFollowFunctionRemoteEvent.OnServerEvent:Connect(function(ReceivedPlayer, angle)
	
	if (ReceivedPlayer ~= Player) then return nil end
	
	local Tool = Character:FindFirstChildWhichIsA("Tool")
	
	if Tool then
		
		rotateShoulder(RightShoulder, angle)
		
	else
		
		rotateShoulder(RightShoulder, 0)
		
	end

end)
