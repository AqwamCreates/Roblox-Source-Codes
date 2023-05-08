local Character = script.Parent
local Player = game:GetService("Players"):GetPlayerFromCharacter(Character)

local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
	0.1, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

local Events = game:GetService("ReplicatedStorage").Events
local MouseFollowFunctionRemoteEvent = Events:WaitForChild("MouseFollowFunctionRemoteEvent")
local AimRemoteEvent = Events.AimRemoteEvent

local RightUpperArm = Character.RightUpperArm
local RightShoulder = RightUpperArm.RightShoulder

local LeftUpperArm = Character.LeftUpperArm
local LeftShoulder = LeftUpperArm.LeftShoulder

local rightArmAngleWhenNotAimingInRadians = math.rad(-30)
local leftArmAngleWhenNotAimingInRadians = math.rad(60)

local Tool
local PreviousTool
local DefaultToolGripCFrame

local function rotateShoulderC0(Shoulder, angleX)

	local goal = {}

	goal.C0 = CFrame.new(Shoulder.C0.Position) * CFrame.Angles(angleX, 0, 0) 

	local tween = TweenService:Create(Shoulder, tweenInfo, goal)

	tween:Play()

end

local function rotateShoulderC0Coroutine(Shoulder, angleX)

	coroutine.resume(coroutine.create(function()

		rotateShoulderC0(Shoulder, angleX)

	end))

end

local function onMouseFollowEvent(ReceivedPlayer, angleYInRadians)

	if (ReceivedPlayer ~= Player) then return nil end


	if Tool then

		rotateShoulderC0Coroutine(RightShoulder, angleYInRadians)

	elseif (Tool == nil) then

		rotateShoulderC0Coroutine(RightShoulder, 0)

	end

end


local function checkIfToolAddedToCharacter(Child)

	if not (Child:IsA("Tool")) then return nil end

	task.wait(0.01)

	PreviousTool = Tool

	Tool = Child

	DefaultToolGripCFrame = Child.Grip

end

local function checkIfToolRemovedOrChangedFromCharacter(Child)

	if not (Child:IsA("Tool")) then return nil end

	PreviousTool = Tool

	PreviousTool.Grip = DefaultToolGripCFrame

	Tool = nil

end

Character.ChildAdded:Connect(checkIfToolAddedToCharacter)
Character.ChildRemoved:Connect(checkIfToolRemovedOrChangedFromCharacter)

MouseFollowFunctionRemoteEvent.OnServerEvent:Connect(onMouseFollowEvent)
