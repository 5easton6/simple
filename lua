-- Place this in a LocalScript under StarterPlayerScripts

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Fly Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 100, 0, 50)
flyButton.Position = UDim2.new(0, 10, 0, 10)
flyButton.Text = "Toggle Fly"
flyButton.Parent = screenGui

-- Speed Boost Button
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 100, 0, 50)
speedButton.Position = UDim2.new(0, 10, 0, 70)
speedButton.Text = "Speed Boost"
speedButton.Parent = screenGui

-- Admin Commands Button
local adminButton = Instance.new("TextButton")
adminButton.Size = UDim2.new(0, 100, 0, 50)
adminButton.Position = UDim2.new(0, 10, 0, 130)
adminButton.Text = "Admin Commands"
adminButton.Parent = screenGui

-- Fly Functionality
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 50

local function toggleFly()
	flying = not flying
	if flying then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = rootPart.CFrame
		bodyGyro.Parent = rootPart

		while flying do
			local moveDirection = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDirection = moveDirection + (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDirection = moveDirection - (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDirection = moveDirection - (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDirection = moveDirection + (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveDirection = moveDirection + Vector3.new(0, flySpeed, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveDirection = moveDirection - Vector3.new(0, flySpeed, 0)
			end
			bodyVelocity.Velocity = moveDirection
			bodyGyro.CFrame = workspace.CurrentCamera.CFrame
			task.wait()
		end
	else
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
	end
end

flyButton.MouseButton1Click:Connect(toggleFly)

-- Speed Boost Functionality
local defaultSpeed = 16
local boostedSpeed = 50

local function toggleSpeed()
	if humanoid.WalkSpeed == defaultSpeed then
		humanoid.WalkSpeed = boostedSpeed
		speedButton.Text = "Reset Speed"
	else
		humanoid.WalkSpeed = defaultSpeed
		speedButton.Text = "Speed Boost"
	end
end

speedButton.MouseButton1Click:Connect(toggleSpeed)

-- Admin Commands (Basic Example)
local function openAdminCommands()
	local commands = {
		["kill"] = function(target)
			local targetPlayer = Players:FindFirstChild(target)
			if targetPlayer and targetPlayer.Character then
				targetPlayer.Character:BreakJoints()
			end
		end,
		["heal"] = function(target)
			local targetPlayer = Players:FindFirstChild(target)
			if targetPlayer and targetPlayer.Character then
				targetPlayer.Character.Humanoid.Health = targetPlayer.Character.Humanoid.MaxHealth
			end
		end
	}

	local commandGui = Instance.new("ScreenGui")
	commandGui.Parent = player.PlayerGui
	local commandBox = Instance.new("TextBox")
	commandBox.Size = UDim2.new(0, 200, 0, 50)
	commandBox.Position = UDim2.new(0, 10, 0, 190)
	commandBox.Text = "Enter command (e.g., kill PlayerName)"
	commandBox.Parent = commandGui

	commandBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local input = commandBox.Text:lower()
			local command, target = input:match("(%w+)%s*(%w*)")
			if commands[command] then
				commands[command](target)
			end
			commandGui:Destroy()
		end
	end)
end

adminButton.MouseButton1Click:Connect(openAdminCommands)

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	if flying then
		toggleFly() -- Reset fly state
		toggleFly() -- Re-enable fly
	end
	humanoid.WalkSpeed = defaultSpeed -- Reset speed on respawn
end)