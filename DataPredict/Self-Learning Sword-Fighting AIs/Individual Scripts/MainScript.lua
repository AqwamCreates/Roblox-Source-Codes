local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCFolder = game:GetService("Workspace").NPCFolder

local ServerScriptService = game:GetService("ServerScriptService")

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local ModelDataStore = game:GetService("DataStoreService"):GetDataStore("NeuralNetwork")

local AI = game:GetService("ServerStorage").AI

local InputEvent = ReplicatedStorage.InputEvent

local OutputEvent = ReplicatedStorage.OutputEvent

local DataPredict = require(ServerScriptService.DataPredictLibrary)

local ModelArray = {}

local ModelIDArray = {}

-------------------------------------------------------------------------------------------------

local startingID = 1

local finalID = 7

local autoSaveInSeconds = 5 * 60

local timeElapsed = 0

-------------------------------------------------------------------------------------------------

local function buildModel()
	
	local ExperienceReplay = DataPredict.ExperienceReplays.UniformExperienceReplay.new(1, 10)
	
	local Model = DataPredict.Models.DoubleQLearningNeuralNetworkV2.new(nil, nil, nil, 1000, nil, 0.9999999)

	Model:addLayer(15, true, 'Mish')

	Model:addLayer(10, true, 'LeakyReLU')

	Model:addLayer(13, true, 'LeakyReLU')

	Model:addLayer(12, false, 'StableSoftmax')

	Model:setClassesList({'A','D','W','S','AW','DW','AS','DS','rotateLeft','rotateRight','jump','useWeapon'})

	Model:setPrintReinforcementOutput(false)
	
	Model:setExperienceReplay(ExperienceReplay)
	
	return Model
	
end
	
-------------------------------------------------------------------------------------------------

local function loadModel(ID)
	
	local Model = buildModel()
	
	local ModelParameters
	
	local success = false
	
	repeat

		success = pcall(function()

			ModelParameters = ModelDataStore:GetAsync(tostring(ID))

		end)

	until success
	
	if (success) and (ModelParameters ~= nil) then
		
		Model:setModelParameters(ModelParameters)
		
		print("Model Loaded!")
		
	elseif (success) and (ModelParameters == nil) then
		
		print("New Model!")
		
	end
	
	return Model
	
end

local function loadAllModels()
	
	for ID = startingID, finalID, 1 do

		local Model = loadModel(ID)
		
		table.insert(ModelArray, Model)
		
		table.insert(ModelIDArray, ID)

	end
	
end

local function saveModel(ID)
	
	local ModelArrayIndex = table.find(ModelIDArray, ID)
	
	local Model = ModelArray[ModelArrayIndex]
	
	local ModelParameters = Model:getModelParameters()
	
	local success = false
	
	repeat
		
		success = pcall(function()
			
			ModelDataStore:SetAsync(tostring(ID), ModelParameters)
			
		end)
		
	until success
	
	if (success) then print("Model Saved!") end
	
end

local function saveAllModels()
	
	for ID = startingID, finalID, 1 do
		
		saveModel(ID)
		
	end
	
end

local function autoSaveAllModels()
	
	RunService.Heartbeat:Connect(function(deltaTime)
		
		timeElapsed += deltaTime
		
		if (timeElapsed >= autoSaveInSeconds) then
			
			timeElapsed = 0
			
			print("Auto-Saving Models.")
			
			saveAllModels()
			
		end
		
	end)
	
end

local function getRandomPositionVectorFromSpawn()
	
	local maxLength = 46
	
	local maxHalfLength = maxLength / 2
	
	local randomX = Random.new():NextInteger(-maxHalfLength, maxHalfLength)
	
	local randomZ = Random.new():NextInteger(-maxHalfLength, maxHalfLength)
	
	local RandomPositionVector = Vector3.new(randomX, 5, randomZ)
	
	return RandomPositionVector
	
end

local function onInputReceived(ID, environmentVector, rewardValue)
	
	local ModelArrayIndex = table.find(ModelIDArray, ID)
	
	local Model = ModelArray[ModelArrayIndex]

	local output = Model:reinforce(environmentVector, rewardValue)

	OutputEvent:Fire(ID, output)

end

local function giveRandomColourToAI(AI)
	
	local Children = AI:GetChildren()
	
	local randomRedValue = Random.new():NextInteger(0, 255)	
	
	local randomGreenValue = Random.new():NextInteger(0, 255)
	
	local randomBlueValue = Random.new():NextInteger(0, 255)
	
	local RandomColour = Color3.new(randomRedValue, randomGreenValue, randomBlueValue)
	
	for i, Part in ipairs(Children) do
		
		if (Part:IsA("BasePart")) then Part.Color = RandomColour end
		
	end
	
end


local function automaticallyMovePlayerToNPCFolder()
	
	workspace.ChildAdded:Connect(function(Object)
		
		local Player = Players:GetPlayerFromCharacter(Object)
		
		if (Player) then Object.Parent = NPCFolder end
		
	end)
	
end

local function generateAI(ID)
	
	local ClonedAI = AI:Clone()

	giveRandomColourToAI(ClonedAI)

	local RandomPositionVector = getRandomPositionVectorFromSpawn()

	ClonedAI.ID.Value = ID

	ClonedAI.PrimaryPart.Position = RandomPositionVector

	ClonedAI.Parent = NPCFolder

	ClonedAI.Movement.Enabled = true

	ClonedAI.Senses.Enabled = true
	
	ClonedAI.Humanoid.DisplayName = ID
	
end

local function onAIRemoved(AI)
	
	local Player = Players:GetPlayerFromCharacter(AI)
	
	if Player then return nil end
	
	local ID = AI.ID.Value
	
	generateAI(ID)
	
end

local function run()
	
	--automaticallyMovePlayerToNPCFolder()
	
	InputEvent.Event:Connect(onInputReceived)
	
	loadAllModels()
	
	for ID = startingID, finalID, 1 do
		
		generateAI(ID)
		
		task.wait(0.1)
		
	end
	
	NPCFolder.ChildRemoved:Connect(onAIRemoved)
	
	game:BindToClose(saveAllModels)
	
	autoSaveAllModels()
	
end

run()
