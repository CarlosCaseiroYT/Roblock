local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Constants = require(ReplicatedStorage.Modules.Constants)
local Block = require(ReplicatedStorage.Modules.Block)
local Chunk = require(ReplicatedStorage.Modules.Chunk)
local World = require(ReplicatedStorage.Modules.World)

local Mouse = require(script:WaitForChild("Mouse"))

local LocalPlayer = game:GetService("Players").LocalPlayer

local ChunksFolder = workspace:FindFirstChild("Chunks")
if not ChunksFolder then
	ChunksFolder = Instance.new("Folder", workspace)
	ChunksFolder.Name = "Chunks"
end

local world = nil

local SelectBlock = LocalPlayer
:WaitForChild("PlayerGui")
:WaitForChild("ScreenGui")
:WaitForChild("Frame")
:WaitForChild("LocalScript")
:WaitForChild("SelectBlock")

local blockName = "Grass"
local blockColor3 = Color3.new(0,0,0)

local positionOfChunkWhereHeadIsPlaced = Vector2.new(0, 0)

local lastBlock = nil

RunService.Heartbeat:Connect(function(dt)
	local function GetChunkPosition()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
		local head = Character:WaitForChild("Head")
		local position = head.Position
		local x = math.floor((position.X / (Constants.Chunk.XZ)) / Constants.BlockSizeMultiplier)
		local y = math.floor((position.Z / (Constants.Chunk.XZ)) / Constants.BlockSizeMultiplier)
		return Vector2.new(x, y)
	end

	if positionOfChunkWhereHeadIsPlaced ~= GetChunkPosition() then
		if lastBlock then
			lastBlock.SelectionBox.Visible = false
			lastBlock = nil
		end
		positionOfChunkWhereHeadIsPlaced = GetChunkPosition()

		local chunksInRadius = ReplicatedStorage.LoadChunk:FireServer(
			positionOfChunkWhereHeadIsPlaced.X + 1,
			positionOfChunkWhereHeadIsPlaced.Y + 1
		)
	end
end)

ReplicatedStorage.LoadChunk.OnClientEvent:Connect(function(chunksInRadius)
	for _, chunkInRadius in pairs(chunksInRadius) do
		chunkInRadius.Parent = ChunksFolder
	end
	for _, chunk3d in pairs(ChunksFolder:GetChildren()) do
		local inRadius = false 
		for _, chunkInRadius in pairs(chunksInRadius) do
			if chunkInRadius == chunk3d then
				inRadius = true
			end
		end
		if not inRadius then
			chunk3d.Parent = nil
		end
	end
end)

SelectBlock.Event:Connect(function(_blockName, _color3)
	blockName = _blockName
	blockColor3 = _color3
end)

UserInputService.InputEnded:Connect(
	function(inputType, gameProcessedEvent)
		if gameProcessedEvent then return end
		local result = Mouse.GetMouseTarget(
			ChunksFolder:GetChildren(),
			Enum.RaycastFilterType.Whitelist
		)
		if inputType.UserInputType == Enum.UserInputType.MouseButton1 then
			if result then
				local block = result.Instance

				if block then
					if block.Parent.Parent == ChunksFolder then
						ReplicatedStorage.DestroyBlock:FireServer(block)
						lastBlock = nil
					end
				end
			end
		end
		if inputType.UserInputType == Enum.UserInputType.MouseButton2 then
			if result then
				local block = result.Instance

				if block then
					if block.Parent.Parent == ChunksFolder then
						if result.Position.X + Constants.BlockSizeMultiplier / 2 == block.Position.X then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{X = -1}
							)
						elseif result.Position.X - Constants.BlockSizeMultiplier / 2 == block.Position.X then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{X = 1}
							)
						elseif result.Position.Y + Constants.BlockSizeMultiplier / 2 == block.Position.Y then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{Y = -1}
							)
						elseif result.Position.Y - Constants.BlockSizeMultiplier / 2 == block.Position.Y then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{Y = 1}
							)
						elseif result.Position.Z + Constants.BlockSizeMultiplier / 2 == block.Position.Z then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{Z = -1}
							)
						elseif result.Position.Z - Constants.BlockSizeMultiplier / 2 == block.Position.Z then
							ReplicatedStorage.PutBlock:FireServer(blockName, 
								blockColor3,
								block.Position,
								{Z = 1}
							)
						end
						lastBlock = nil
					end
				end
			end
		end
end)