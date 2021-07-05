local Constants = require(script.Parent.Constants)
local Chunk = require(script.Parent.Chunk)

local World = {}

World.new = function(ChunksFolder)
	local _buildedChunks = {}
	local _tempChunks = {}
	
	local function _Expand(self, x, z, inside)
		local chunksInRadius = {}
		local function RecursiveRadius(radius)
			radius = radius - 1

			if radius >= 0 then
				for i = 0, radius do
					local x2 = radius - i
					local z2 = 0 + i
					local chunk = Chunk.BuildChunk(self, ChunksFolder, x + x2, z + z2)
					chunksInRadius[chunk.GetName()] = chunk
					x2 = 0 - i
					z2 = radius - i
					chunk = Chunk.BuildChunk(self, ChunksFolder, x + x2, z + z2)
					chunksInRadius[chunk.GetName()] = chunk
					x2 = i - radius
					z2 = 0 - i
					chunk = Chunk.BuildChunk(self, ChunksFolder, x + x2, z + z2)
					chunksInRadius[chunk.GetName()] = chunk
					x2 = 0 + i
					z2 = i - radius
					chunk = Chunk.BuildChunk(self, ChunksFolder, x + x2, z + z2)
					chunksInRadius[chunk.GetName()] = chunk
				end
				RecursiveRadius(radius)
			end
		end
		RecursiveRadius(Constants.MaxChunkDistanceVisible)
		return chunksInRadius
	end

	return {
		GetBuildedChunk = function(chunkName)
			return _buildedChunks[chunkName]
		end,
		SetBuildedChunk = function(chunk)
			_buildedChunks[chunk.GetName()] = chunk
		end,
		Expand = _Expand,
	}
end

return World
