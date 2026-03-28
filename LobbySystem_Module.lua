-- LobbySystem (ModuleScript)
-- Place this in ServerScriptService as a ModuleScript named "LobbySystem"

local LobbySystem = {}
LobbySystem.__index = LobbySystem

--[[
    Creates a new lobby system.
    
    Parameters:
        joinPart            → Part that players touch to join the lobby
        lobbySpawn          → Part to teleport players to when they join (can be nil)
        teleportDestination → Part to teleport everyone to when lobby is full (can be nil)
        maxPlayers          → Number of players needed to start (default: 5)
]]
function LobbySystem.new(joinPart, lobbySpawn, teleportDestination, maxPlayers)
	local self = setmetatable({}, LobbySystem)
	
	self.joinPart = joinPart
	self.lobbySpawn = lobbySpawn
	self.teleportDestination = teleportDestination
	self.maxPlayers = maxPlayers or 5
	
	self.playersInLobby = {}       -- [Player] = true
	self.connections = {}
	self.guiName = "LobbyExitGui"
	
	self:setupJoinPart()
	self:setupPlayerRemoving()
	
	print("✅ LobbySystem initialized! Max players:", self.maxPlayers)
	return self
end

function LobbySystem:setupJoinPart()
	if not self.joinPart then
		warn("LobbySystem: No joinPart provided!")
		return
	end
	
	local connection = self.joinPart.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end
		
		local player = game.Players:GetPlayerFromCharacter(character)
		if player and not self.playersInLobby[player] then
			self:addPlayerToLobby(player)
		end
	end)
	
	table.insert(self.connections, connection)
end

function LobbySystem:setupPlayerRemoving()
	local connection = game.Players.PlayerRemoving:Connect(function(player)
		if self.playersInLobby[player] then
			self:removePlayerFromLobby(player)
		end
	end)
	table.insert(self.connections, connection)
end

function LobbySystem:addPlayerToLobby(player)
	self.playersInLobby[player] = true
	
	-- Teleport player into the lobby area (if spawn is set)
	if self.lobbySpawn and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = self.lobbySpawn.CFrame + Vector3.new(0, 5, 0) -- spawn slightly above
		end
	end
	
	-- Show the Exit button
	self:showExitGui(player)
	
	print(player.Name .. " joined the lobby! (" .. self:GetPlayerCount() .. "/" .. self.maxPlayers .. ")")
	
	-- Check if we should start
	self:checkIfFull()
end

function LobbySystem:removePlayerFromLobby(player)
	if not self.playersInLobby[player] then return end
	
	self.playersInLobby[player] = nil
	self:hideExitGui(player)
	
	print(player.Name .. " left the lobby! (" .. self:GetPlayerCount() .. "/" .. self.maxPlayers .. ")")
end

function LobbySystem:showExitGui(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Don't create duplicates
	if playerGui:FindFirstChild(self.guiName) then return end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = self.guiName
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Nice-looking frame + button
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 70)
	frame.Position = UDim2.new(1, -280, 0, 20) -- top-right corner
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = frame
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 1, -20)
	button.Position = UDim2.new(0, 10, 0, 10)
	button.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	button.Text = "Exit Lobby"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = frame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button
	
	-- Button functionality
	button.Activated:Connect(function()
		self:removePlayerFromLobby(player)
	end)
end

function LobbySystem:hideExitGui(player)
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		local gui = playerGui:FindFirstChild(self.guiName)
		if gui then
			gui:Destroy()
		end
	end
end

function LobbySystem:checkIfFull()
	local count = self:GetPlayerCount()
	
	if count >= self.maxPlayers then
		print("🎉 Lobby is full! Teleporting all players...")
		self:teleportAllPlayers()
		self:clearLobby()
	end
end

function LobbySystem:teleportAllPlayers()
	if not self.teleportDestination then return end
	
	for player in pairs(self.playersInLobby) do
		if player.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = self.teleportDestination.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
end

function LobbySystem:clearLobby()
	for player in pairs(self.playersInLobby) do
		self:hideExitGui(player)
	end
	self.playersInLobby = {}
end

function LobbySystem:GetPlayerCount()
	local count = 0
	for _ in pairs(self.playersInLobby) do
		count += 1
	end
	return count
end

-- Clean up method (optional)
function LobbySystem:Destroy()
	for _, conn in ipairs(self.connections) do
		conn:Disconnect()
	end
	self:clearLobby()
	print("LobbySystem destroyed.")
end

return LobbySystem
