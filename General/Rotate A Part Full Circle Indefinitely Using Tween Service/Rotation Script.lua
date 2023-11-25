local TweenService = game:GetService("TweenService")

local part = script.Parent

local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local function rotate(currentOrientation)
	
	part.Orientation = currentOrientation
	
	local newOrientation = currentOrientation + Vector3.new(0, 180, 0)
	
	local goal = {
		
		Orientation = newOrientation
		
	}
	
	local tween = TweenService:Create(part, tweenInfo, goal)
	
	tween.Completed:Connect(function()
		
		rotate(newOrientation)
		
	end)
	
	tween:Play()
	
end

rotate(part.Orientation)
