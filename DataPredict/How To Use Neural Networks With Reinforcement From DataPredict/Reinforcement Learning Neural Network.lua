local ServerScriptService = game:GetService("ServerScriptService")

local DataPredict = require(ServerScriptService["DataPredict  - Release Version 1.1"])

local MatrixL =  require(ServerScriptService.MatrixL)

local maxRewardArrayLength = 100

local maxCurrentArrayLength = 100

local isRewardedArray = {}

local currentAccuracyArray = {}

local function buildModel()
	
	local Model = DataPredict.Models.QLearningNeuralNetwork.new()
	
	Model:setModelParametersInitializationMode("RandomNormalNegativeAndPositive")
	
	Model:addLayer(2, true, "tanh")
	
	Model:addLayer(4, false, "ReLU")
	
	Model:setClassesList({1, 2, 3, 4})
	
	Model:setPrintOutput(false)
	
	return Model
	
end

local function checkIfPunishedOrRewarded(environmentFeatureVector, predictedLabel)
	
	local isRewarded = nil
	
	if (environmentFeatureVector[1][2] >= 0) and (environmentFeatureVector[1][3] >= 0) then --  positive + positive = 1
		
		isRewarded = (predictedLabel == 1)

	elseif (environmentFeatureVector[1][2] >= 0) and (environmentFeatureVector[1][3] < 0) then --  positive + negative = 2
		
		isRewarded = (predictedLabel == 2)

	elseif (environmentFeatureVector[1][2] < 0) and (environmentFeatureVector[1][3] >= 0) then --  negative + positive = 3

		isRewarded = (predictedLabel == 3)

	elseif (environmentFeatureVector[1][2] < 0) and (environmentFeatureVector[1][3] < 0) then --  negative + negative = 3

		isRewarded = (predictedLabel == 4)

	end
	
	return isRewarded
	
end

local function generateEnvironmentFeatureVector()
	
	local featureVector1 = MatrixL:createRandomNormalMatrix(1, 3)

	local featureVector2 = MatrixL:createRandomNormalMatrix(1, 3)

	local environmentFeatureVector = MatrixL:subtract(featureVector1, featureVector2)

	environmentFeatureVector[1][1] = 1 -- 1 at first column for bias.
	
	return environmentFeatureVector
	
end

local function calculateCurrentAccuracy(booleanArray)
	
	local numberOfBooleans = #booleanArray
	
	local numberOfTrueBooleans = 0
	
	local currentAccuracy
	
	for i, boolean in ipairs(booleanArray) do
		
		if (boolean == true) then
			
			numberOfTrueBooleans += 1
			
		end
		
	end
	
	currentAccuracy = (numberOfTrueBooleans / numberOfBooleans) * 100
	
	currentAccuracy = math.floor(currentAccuracy)
	
	return currentAccuracy
	
end

local function calculateAverage(array)
	
	local sum = 0
	
	local average
	
	for i, number in ipairs(array) do
		
		sum += number
		
	end

	average = (sum / #array)
	
	return average
	
end

local function getCurrentAverageAccuracy()
	
	local currentAccuracy
	
	local currentAverageAccuracy

	if (#isRewardedArray > maxRewardArrayLength) then

		table.remove(isRewardedArray, 1)

		currentAccuracy = calculateCurrentAccuracy(isRewardedArray)

		table.insert(currentAccuracyArray, currentAccuracy)

	end

	if (#currentAccuracyArray > maxCurrentArrayLength) then

		table.remove(currentAccuracyArray, 1)

		currentAverageAccuracy = calculateAverage(currentAccuracyArray)

	end
	
	return currentAverageAccuracy
	
end

local function startEnvironment(Model)
	
	local reward = 0
	
	local defaultReward = 1

	local defaultPunishment = -0.01
	
	local predictedLabel
	
	local environmentFeatureVector
	
	local isRewarded
	
	local currentAverageAccuracy
	
	while true do

		environmentFeatureVector = generateEnvironmentFeatureVector()

		predictedLabel = Model:reinforce(environmentFeatureVector, reward)
		
		isRewarded = checkIfPunishedOrRewarded(environmentFeatureVector, predictedLabel)
		
		if isRewarded then
			
			reward = defaultReward
			
		else
			
			reward = defaultPunishment
			
		end
		
		table.insert(isRewardedArray, isRewarded)
		
		currentAverageAccuracy = getCurrentAverageAccuracy()
		
		if (currentAverageAccuracy ~= nil) then print(currentAverageAccuracy) end
		
		task.wait(0.01)

	end
	
end

local function run()
	
	local Model = buildModel()
	
	startEnvironment(Model)
	
end

run()