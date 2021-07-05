local Constants = require(script.Parent.Constants)
local Perlin = require(script.Parent.Perlin)
local Block = require(script.Parent.Block)

local Chunk = {}

Chunk.BuildChunk = function(world, ChunksFolder, x, z)
	local function GetNeighborChunk(args)
		local chunk = world.GetBuildedChunk("Chunk "..
			(x + (args.X or 0)).."x"..(z + (args.Z or 0)))
		if chunk and not chunk.IsTotallyLoaded() then
			chunk.Load()
			wait(0.1)
		end
	end
	local chunk = world.GetBuildedChunk("Chunk "..x.."x"..z)
	if not chunk then
		chunk = Chunk.new(world, ChunksFolder, Vector2.new(x, z))
		chunk:Create()
		world.SetBuildedChunk(chunk)
		chunk.Build()
		chunk.Load()
		GetNeighborChunk({X = 1})
		GetNeighborChunk({X = -1})
		GetNeighborChunk({Z = 1})
		GetNeighborChunk({Z = -1})
		wait(0.1)
	end
	return chunk
end

Chunk.new = function(world, ChunksFolder, _position2d)
	local _name = "Chunk ".._position2d.X.."x".._position2d.Y
	local _data = {}
	local _created = false
	local _folder = nil
	local _status = nil
	local _totallyLoaded = false

	local function _TerrainNoise(x, z, cicle, persist)
		local frequency = 1
		local amplitude = 1
		local total = 0
		local maxVal = 0
		for i = 0, cicle - 1 do
			total = total + Perlin:noise(x * frequency, z * frequency) * amplitude
			maxVal = maxVal + amplitude
			amplitude = amplitude * persist
		end
		return total / maxVal
	end
	local function _DirtAndGrassNoise(x, z)
		local maxHeight = Constants.Chunk.Y
		local minHeight = Constants.Chunk.Y / 2
		local smooth = 0.02--0.01
		local cicle = 8--4
		local persist = 1--0.5
		local height = Perlin.lerp(Perlin.inverseLerp(0, 1, 
			_TerrainNoise(x * smooth, z * smooth, cicle, persist)
		), minHeight, maxHeight)
		return height
	end
	local function _StoneNoise(x, z)
		local maxHeight = Constants.Chunk.Y
		local minHeight = Constants.Chunk.Y / 2
		local smooth = 0.02
		local cicle = 8
		local persist = 1
		local height = Perlin.lerp(Perlin.inverseLerp(0, 1, 
			_TerrainNoise(x * smooth * 1.2, z * smooth * 1.2, cicle, persist)
		), minHeight - 3, maxHeight - 3)
		return height
	end
	
	local function _GenerateTree(position)
		local tree = {}
		
		local function Basic(h)
			for y = 1, h + 4 do
				if y < h + 4 then
					tree[position.X.."x"..(position.Y + y).."x"..position.Z] = 
						Block.new(world, "Wood", Vector3.new(
							position.X,
							position.Y + y,
							position.Z
						))
				end
				
				if y == h + 4 then
					tree[(position.X).."x"..(position.Y + y).."x"..(position.Z)] = 
						Block.new(world, "Leaves", Vector3.new(
							position.X,
							position.Y + y,
							position.Z
						))
				end
				
				if y == h + 4 then
					for x = 1, 3 do
						for z = 1, 3 do
							if x == 2 or z == 2 then
								tree[(position.X + x).."x"..
									(position.Y + y).."x"..
									(position.Z + z)] = 
									Block.new(world, "Leaves",
										Vector3.new(
											position.X - 2 + x,
											position.Y + y,
											position.Z - 2 + z
										))
							end
						end
					end
				end
				
				if y == h + 3 then
					for x = 1, 3 do
						for z = 1, 3 do
							if x ~= 2 or z ~= 2 then
								tree[(position.X + x).."x"..
									(position.Y + y).."x"..
									(position.Z + z)] = 
									Block.new(world, "Leaves",
										Vector3.new(
											position.X - 2 + x,
											position.Y + y,
											position.Z - 2 + z
										))
							end
						end
					end
				end
				
				if y == h + 2 or y == h + 1 then
					for x = 1, 5 do
						for z = 1, 5 do
							if x ~= 3 or z ~= 3 then
								tree[(position.X + x).."x"..
									(position.Y + y).."x"..
									(position.Z + z)] = 
									Block.new(world, "Leaves",
										Vector3.new(
											position.X - 3 + x,
											position.Y + y,
											position.Z - 3 + z
										))
							end
						end
					end
				end
			end
		end
		
		if 1 == math.random(1, 50) then
			Basic(math.random(1, 3))
		end
		return tree
	end
	
	------------------------------
	
	local function _SetBlockToData(block)
		_data[(block.GetPosition().X)
			.."x"..block.GetPosition().Y.."x"..
			(block.GetPosition().Z)] = block
	end
	
	local function _Load()
		local function LoadBlocks()
			for _, block in pairs(_data) do
				block.Load()
			end
		end
		LoadBlocks()
		return _folder
	end
	
	local function _Build()
		local function CreateBlocks()
			local function ConvertPosition(x, y, z)
				return Vector3.new(
					x + Constants.Chunk.XZ * _position2d.X,
					y,
					z + Constants.Chunk.XZ * _position2d.Y
				)
			end
			local function GenerateBlocks()
				_totallyLoaded = true
				for x = 0, Constants.Chunk.XZ - 1 do
					for y = 0, Constants.Chunk.Y - 1 do
						for z = 0, Constants.Chunk.XZ - 1 do
							local block = nil
							local position = ConvertPosition(x, y, z)
							local tree = {}

							if y == 0 then
								block = Block.new(world, "Bedrock", position)
							elseif y < _StoneNoise(position.X, position.Z) then
								block = Block.new(world, "Stone", position)
							elseif y < _DirtAndGrassNoise(position.X, position.Z) then
								block = Block.new(world, "Dirt", position)
							elseif y - 1 < _DirtAndGrassNoise(position.X, position.Z) then
								block = Block.new(world, "Grass", position)
								
								if y > Constants.Chunk.Y / 1.6 and
									(x >= 2 and x <= Constants.Chunk.XZ -3) and 
									(z >= 2 and z <= Constants.Chunk.XZ -3) then
									tree = _GenerateTree(position)
								end
							elseif y < Constants.Chunk.Y / 1.7 then
								block = Block.new(world, "Water", position)
							else
								block = Block.new(world, "Air", position)
							end

							for _, block in pairs(tree) do
								if block then
									block.SetParent(_folder)
									_SetBlockToData(block)
								end
							end
                            
							if block then
								if not block.IsTotallyLoaded() then
									_totallyLoaded = false
								end
								block.SetParent(_folder)
								
								_SetBlockToData(block)
							end
						end
					end
				end
			end
			GenerateBlocks()
		end

		if _created then
			CreateBlocks()
		end
	end
	
	local function _Create()
		local function CreateFolder()
			_folder = Instance.new("Folder")
			_folder.Parent = ChunksFolder
			_folder.Name = _name
		end
		CreateFolder()
		_created = true
		return _folder
	end
	
	local function _Destroy(self)
		if _folder then
			_folder:Destroy()
		end
		for _, property in pairs(self) do
			property = nil
		end
	end
	
	return {
		SetBlockToData = _SetBlockToData,
		GetBlockInData = function(position)
			return _data[position.X
				.."x"..position.Y
				.."x"..position.Z]
		end,
		GetName = function()
			return _name
		end,
		GetPosition = function()
			return _position2d
		end,
		GetChunk3d = function()
			return _folder
		end,
		IsTotallyLoaded = function()
			return _totallyLoaded
		end,
		Load = _Load,
		Build = _Build,
		Create = _Create,
		Destroy = _Destroy
	}
end

return Chunk