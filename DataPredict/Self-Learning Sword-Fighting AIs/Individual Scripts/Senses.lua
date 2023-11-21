local InputEvent = game:GetService("ReplicatedStorage").InputEvent

local NPCFolder = game:GetService("Workspace").NPCFolder

local RunService = game:GetService("RunService")

local Character = script.Parent

local IDValue = Character.ID.Value

local Humanoid = Character.Humanoid

local maxHealth = Humanoid.MaxHealth

local previousHealth = Humanoid.MaxHealth

local previouslyTargetedEnemy

local previousEnemyHealth

local previousEnemyDistance

local largeValue = 999999999

local Head = Character.Head

local Connection

local raycastParameters = RaycastParams.new()

raycastParameters.FilterType = Enum.RaycastFilterType.Exclude

raycastParameters.FilterDescendantsInstances = {Character}

local defaultEnvironmentVector =  {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}

local grips = {
	
	normal = CFrame.new(0, 0, -1.70000005, 0, 0, 1, 1, 0, 0, 0, 1, 0),
	
	lunge = CFrame.new(0, 0, -1.70000005, 0, 1, 0, 1, -0, 0, 0, 0, -1)
	
}

local function getClosestEnemy()
	
	local closestEnemy = nil
	
	local closestDistance = largeValue

	for _, obj: Model in NPCFolder:GetChildren() do
		
		if not obj:IsA("Model") then continue end
		
		if obj == Character then continue end
		
		if not obj:FindFirstChildWhichIsA("Humanoid") then continue end
		
		if obj.Humanoid.Health <= 0 then continue end

		local distance = (obj:GetPivot().Position - Character:GetPivot().Position).Magnitude

		if (distance <= closestDistance) then
			
			closestEnemy = obj
			
			closestDistance = distance
			
		end
		
	end

	return closestEnemy, closestDistance
	
end

local function getCurrentView()
	
	local LookVector = Head.CFrame.LookVector * largeValue
	
	local HeadPositionVector = Head.Position
	
	local raycast = workspace:Raycast(HeadPositionVector, LookVector, raycastParameters)
	
	local isEnemy = false
	
	local distance = largeValue
	
	if (raycast) then
		
		local ParentPart = raycast.Instance.Parent
		
		local hasHumanoid = ParentPart:FindFirstChild("Humanoid")
		
		if hasHumanoid then
			
			isEnemy = (Character ~= ParentPart)
			
		end
		
		distance = raycast.Distance
		
	end
	
	return isEnemy, distance
	
end

--// {1, view distance, x, y, z, rx, ry, rz, enemy velocity, enemy lunging, npc lunging} -- the pos, rot and vel ones are relative to npc

local function getEnvironmentVector()
	
	local npcFolder = Character.Parent
	
	local closestEnemy = getClosestEnemy(Character)

	local enemyLunging = 0
	
	local enemyVelocity = Vector3.new(0, 0, 0)
	
	local closestEnemyCF = CFrame.new(Vector3.new(0, 0, 0))
	
	local enemyHealthPercentage = 0
	
	if closestEnemy then
		
		local enemyTool = closestEnemy:FindFirstChildWhichIsA("Tool")
		
		local isEnemyLunging = false
		
		if enemyTool then
			
			isEnemyLunging = (enemyTool.Grip == grips.lunge)
			
		end
		
		enemyLunging = (isEnemyLunging and 1) or 0
		
		enemyVelocity = closestEnemy.PrimaryPart.Velocity
		
		closestEnemyCF = closestEnemy:GetPivot()
		
		enemyHealthPercentage = closestEnemy.Humanoid.Health / maxHealth
		
	end
	
	local npcTool = Character:FindFirstChildWhichIsA("Tool")
	
	local isNPCLunging = (npcTool.Grip == grips.lunge)
	
	local npcLunging = (isNPCLunging and 1) or 0

	local npcVelocity = Character.PrimaryPart.Velocity

	local relativeVelocity = CFrame.new(npcVelocity):ToObjectSpace(CFrame.new(enemyVelocity))
	
	local npcCF = Character:GetPivot()

	local relativeCF = npcCF:ToObjectSpace(closestEnemyCF)
	
	local relativeRot = relativeCF.Rotation
	
	local npcHealthPercentage = Humanoid.Health / maxHealth
	
	local isEnemy, viewingDistance = getCurrentView()
	
	local viewingEnemy = (isEnemy and 1) or 0
	
	local environmentFeatureVector = {
		
		{
			1,
			
			npcHealthPercentage,
			
			viewingDistance, viewingEnemy, enemyHealthPercentage,
	
			relativeCF.X, relativeCF.Y, relativeCF.Z, 
			
			relativeRot.X, relativeRot.Y, relativeRot.Z, 
			
			relativeVelocity.X, relativeVelocity.Y, relativeVelocity.Z, 
			
			enemyLunging, npcLunging,
			
		}
		
	}

	return environmentFeatureVector
	
end

local function getEnemyStatus()
	
	local closestEnemy, distanceToEnemy = getClosestEnemy(Character)
	
	if (closestEnemy == nil) then return nil, 0, 0, 0 end
	
	local damageDealt = 0
	
	local distanceDifference = 0
	
	local currentEnemyHealth = closestEnemy.Humanoid.Health
	
	if (closestEnemy ~= previouslyTargetedEnemy) then 
		
		previouslyTargetedEnemy = closestEnemy
		
	else
		
		damageDealt = (previousEnemyHealth - currentEnemyHealth)
		
		distanceDifference = (previousEnemyDistance - distanceToEnemy)
		
	end
	
	previousEnemyHealth = currentEnemyHealth
	
	previousEnemyDistance = distanceToEnemy
	
	return closestEnemy, damageDealt, distanceDifference, distanceToEnemy
	
end

local function getRewardValue()
	
	local distanceAdjustmentFactor = 0.01
	
	local currentHealth = Humanoid.Health
	
	local healthChange = currentHealth - previousHealth
	
	local closestEnemy, damageDealt, distanceDifference, distanceToEnemy = getEnemyStatus()
	
	local isEnemy, viewingDistance = getCurrentView()
	
	local noEnemy = (closestEnemy == nil)
	
	local idlePunishment = (noEnemy and -0.1) or 0
	
	local isEnemyDead = (previousEnemyHealth == 0)
	
	local enemyDeathReward = (isEnemyDead and 0.3) or 0
	
	local isEnemyReward = (isEnemy and 0.1) or ((viewingDistance <= 5) and -0.3) or 0
	
	local healthChangeRatio = (healthChange / maxHealth)
	
	local damageDealtRatio = (damageDealt / maxHealth)
	
	local healthPercentage = currentHealth / maxHealth
	
	local healReward = (1 - healthPercentage) * distanceToEnemy * distanceAdjustmentFactor
	
	local distanceChangeReward = (distanceDifference * distanceAdjustmentFactor)
	
	local rewardValue = healthChangeRatio + healReward + damageDealtRatio + enemyDeathReward + distanceChangeReward + idlePunishment + isEnemyReward
	
	return rewardValue
	
end

local function senseEnvironment()
	
	local environmentVector = getEnvironmentVector()
	
	local rewardValue = getRewardValue()
	
	InputEvent:Fire(IDValue, environmentVector, rewardValue)
	
	previousHealth = Humanoid.Health
	
end

Humanoid.Died:Connect(function()

	if Connection then Connection:Disconnect() end

	InputEvent:Fire(IDValue, defaultEnvironmentVector, -1)
	
	task.wait()
	
	InputEvent:Fire(IDValue, defaultEnvironmentVector, 0)

	Character:Destroy()

end)

Connection = RunService.Heartbeat:Connect(senseEnvironment)
