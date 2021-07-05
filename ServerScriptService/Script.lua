local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local world = nil

local ChunksFolder = Instance.new("Folder", workspace)
ChunksFolder.Name = "Chunks"

local Constants = require(ReplicatedStorage.Modules.Constants)

local Block = require(ReplicatedStorage.Modules.Block)
local Chunk = require(ReplicatedStorage.Modules.Chunk)
local World = require(ReplicatedStorage.Modules.World)

local isFirstBuildDone = false

------------------
local function GenerateWorld()
	Lighting.FogEnd = (Constants.Chunk.XZ * Constants.BlockSizeMultiplier
		* Constants.MaxChunkDistanceVisible) / 1.5
	Lighting.FogStart = Lighting.FogEnd / 2

	local function CreateSpawnLocation()
		local sl = Instance.new("SpawnLocation", workspace)
		sl.Position = Vector3.new(0,
			Constants.Chunk.Y * Constants.BlockSizeMultiplier + 5, 0)
		sl.Anchored = true
		sl.Transparency = 1
		sl.CanCollide = false
	end

	CreateSpawnLocation()

	world = World.new()

	local chunksInRadius = world:Expand(0, 0, true)

	for _, chunkInRadius in pairs(chunksInRadius) do
		chunkInRadius.GetChunk3d().Parent = ChunksFolder
	end
	
	isFirstBuildDone = true
	
	for _, player in pairs(Players:GetChildren()) do
		player:LoadCharacter()
	end
	
	Players.CharacterAutoLoads = true
end

Players.PlayerAdded:Connect(function(player)
	if isFirstBuildDone then
		player:LoadCharacter()
	end
end)

ReplicatedStorage.LoadChunk.OnServerEvent:Connect(function(player, x, y)
	local chunksInRadius = world:Expand(x, y, false)
	
	local chunks3dInRadius = {}
	
	for _, chunkInRadius in pairs(chunksInRadius) do
		local chunk3d = chunkInRadius.GetChunk3d()
		chunks3dInRadius[chunkInRadius.GetName()] = chunk3d
		chunk3d.Parent = workspace
	end
	
	ReplicatedStorage.LoadChunk:FireClient(player, chunks3dInRadius)
end)

ReplicatedStorage.DestroyBlock.OnServerEvent:Connect(function(player, block3d)
	if block3d then
		local block = Block.GetByPosition(world, Vector3.new(
			(block3d.Position.X / Constants.BlockSizeMultiplier) + 1 + Constants.BlockSizeMultiplier,
			block3d.Position.Y / Constants.BlockSizeMultiplier,
			(block3d.Position.Z / Constants.BlockSizeMultiplier) + 1 + Constants.BlockSizeMultiplier
		))

		if block and block.GetName() ~= "Bedrock" then
			block:SetName("Air")
			block.Load()
			block.ReloadNeighbors()
		end
	end
end)

ReplicatedStorage.PutBlock.OnServerEvent:Connect(
	function(player, name, blockColor3, position, args)
	
	local function GetChunkName(x, y)
		x = math.floor(x / (Constants.Chunk.XZ))
		y = math.floor(y / (Constants.Chunk.XZ))
		return "Chunk "..x.."x"..y
	end
		
	local blockPosition =  Vector3.new(
		(position.X / Constants.BlockSizeMultiplier) + Constants.BlockSizeMultiplier + 1--[[]] + (args.X or 0),
		(position.Y / Constants.BlockSizeMultiplier) + (args.Y or 0),
		(position.Z / Constants.BlockSizeMultiplier) + Constants.BlockSizeMultiplier + 1--[[]] + (args.Z or 0))
	
	local block = Block.GetByPosition(world, blockPosition)
	local lastBlockName = nil
	if block then
		lastBlockName = block.GetName()
		block:SetName(name)
		block.SetColor(blockColor3)
	else
		block = Block.new(world, name, blockPosition, blockColor3)	
	end
	
	if block then
		if not lastBlockName or lastBlockName == "Air" then
			local chunk = world.GetBuildedChunk(
				GetChunkName(block.GetPosition().X, block.GetPosition().Z))	
			local parent = chunk.GetChunk3d()
			block.SetParent(parent)

			chunk.SetBlockToData(block)
			block.Load()
			block.ReloadNeighbors()
		end
	end
end)

print("start")
GenerateWorld()
print("end")