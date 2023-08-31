local OutputEvent = game:GetService("ReplicatedStorage").OutputEvent

local Character = script.Parent

local Humanoid = Character.Humanoid

local IDValue = Character.ID.Value

local Tool

local positionVector

local rotationVector

local function getNewPositionVector(x, y, z)
	
	return (Character:GetPivot() * CFrame.new(x, y, z)).Position
	
end

local function getNewRotationVector(x, y, z)

	return Character:GetPivot() * CFrame.Angles(x, y, z)

end

local function A() --// move left -x
	
	positionVector = getNewPositionVector(-Humanoid.WalkSpeed, 0, 0)
	
	Humanoid:MoveTo(positionVector)
	
end

local function D() --// move right x
	
	positionVector = getNewPositionVector(Humanoid.WalkSpeed, 0, 0)

	Humanoid:MoveTo(positionVector)
	
end

local function W() --// move foward -z
	
	positionVector = getNewPositionVector(0, 0, -Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
	
end

local function S() --// move backward z
	
	positionVector = getNewPositionVector(0, 0, Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
	
end

local function AW() --// move left-foward
	
	positionVector = getNewPositionVector(-Humanoid.WalkSpeed, 0, -Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
	
end

local function DW() --// move right-foward
	
	positionVector = getNewPositionVector(Humanoid.WalkSpeed, 0, -Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
	
end

local function AS() --// move left-backward
	
	positionVector = getNewPositionVector(-Humanoid.WalkSpeed, 0, Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
end


local function DS() --// move right-backward
	
	positionVector = getNewPositionVector(Humanoid.WalkSpeed, 0, Humanoid.WalkSpeed)

	Humanoid:MoveTo(positionVector)
	
end

local function rotateLeft() --// rotate left y
	
	rotationVector = getNewRotationVector(0, math.rad(1), 0)
	
	Character:PivotTo(rotationVector)
	
end

local function rotateRight() --// rotate right -y
	
	rotationVector = getNewRotationVector(0, math.rad(-1), 0)

	Character:PivotTo(rotationVector)
	
end

local function jump() --// jump
	
	Humanoid.Jump = true
	
end

local function useWeapon() --// use weapon
	
	Tool = Character:FindFirstChildWhichIsA("Tool")
	
	if not Tool then return end
	
	Tool.Use:Fire()
	
end

local function onOutputReceived(ID, output)
	
	if (ID ~= IDValue) then return nil end
	
	if (output == "A") then A()
		
	elseif (output == "D") then D()
		
	elseif (output == "W") then W()
		
	elseif (output == "S") then S()	
		
	elseif (output == "AW") then AW()
		
	elseif (output == "DW") then DW()
		
	elseif (output == "AS") then AS()
		
	elseif (output == "DS") then DS()
		
	elseif (output == "rotateLeft") then rotateLeft()
		
	elseif (output == "rotateRight") then rotateRight()
		
	elseif (output == "jump") then jump()
		
	elseif (output == "useWeapon") then useWeapon()		
		
	end
	
end

OutputEvent.Event:Connect(onOutputReceived)

