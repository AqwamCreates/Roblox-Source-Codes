local MouseFollowFunctionRemoteEvent = game:GetService("ReplicatedStorage").Events.MouseFollowFunctionRemoteEvent

local armRotationRate = 0.01
local offset = 0.5

local Character = script.Parent

local Player = game.Players:GetPlayerFromCharacter(Character)

local RightUpperArm = Character.RightUpperArm
local RightShoulder = RightUpperArm.RightShoulder

local function rotateShoulder(Shoulder, angle)
	
	local ShoulderC0 = Shoulder.C0
	
	local ShoulderC0Vector = ShoulderC0.Position
	
	Shoulder.C0 = CFrame.new(ShoulderC0Vector) * CFrame.Angles(angle, 0, 0) 
	
end


MouseFollowFunctionRemoteEvent.OnServerEvent:Connect(function(CurrentPlayer, angle)
	
	if (CurrentPlayer ~= Player) then return nil end
	
	local Tool = Character:FindFirstChildWhichIsA("Tool")
	
	if Tool then
		
		rotateShoulder(RightShoulder, angle)
		
	else
		
		rotateShoulder(RightShoulder, 0)
		
	end
	

end)
