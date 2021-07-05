local Constants = require(script.Parent.Constants)

local Block = {}

Block.GetByPosition = function(world, position)
	local function GetChunkName()
		local x = 0
		local y = 0
		x = math.floor(position.X / (Constants.Chunk.XZ))
		y = math.floor(position.Z / (Constants.Chunk.XZ))
		return "Chunk "..x.."x"..y
	end
	local function FindBlockInChunk(chunkName)
		local chunk = world.GetBuildedChunk(chunkName)
		if chunk then
			local block = chunk.GetBlockInData(position)
			return block
		end
		return nil
	end
	return FindBlockInChunk(GetChunkName())
end

Block.ConvertRawPositionToStudsPosition = function(raw)
	return Vector3.new(
		(raw.X - Constants.Chunk.XZ / 2) * Constants.BlockSizeMultiplier,
		raw.Y * Constants.BlockSizeMultiplier,
		(raw.Z - Constants.Chunk.XZ / 2) * Constants.BlockSizeMultiplier
	)
end

Block.ConvertStudsPositionToRawPosition = function(studs)
	return Vector3.new(
		studs.X / Constants.BlockSizeMultiplier + (Constants.Chunk.XZ / 2),
		studs.Y / Constants.BlockSizeMultiplier,
		studs.Z / Constants.BlockSizeMultiplier + (Constants.Chunk.XZ / 2)
	)
end

Block.new = function(world, _name, _position, _color)
	local _faces = {}
	local _block3d = nil
	local _visible = false
	local _totallyLoaded = false
	
	local _parent = nil

	local function SetAssets()
		if _name == "Grass" then
			_faces.Top = Constants.AssetId.GrassTop
			_faces.Right = Constants.AssetId.GrassSide
			_faces.Left = Constants.AssetId.GrassSide
			_faces.Front = Constants.AssetId.GrassSide
			_faces.Back = Constants.AssetId.GrassSide
			_faces.Bottom = Constants.AssetId.Dirt
		elseif _name == "Dirt" then
			_faces.Top = Constants.AssetId.Dirt
			_faces.Right = Constants.AssetId.Dirt
			_faces.Left = Constants.AssetId.Dirt
			_faces.Front = Constants.AssetId.Dirt
			_faces.Back = Constants.AssetId.Dirt
			_faces.Bottom = Constants.AssetId.Dirt
		elseif _name == "Stone" then
			_faces.Top = Constants.AssetId.Stone
			_faces.Right = Constants.AssetId.Stone
			_faces.Left = Constants.AssetId.Stone
			_faces.Front = Constants.AssetId.Stone
			_faces.Back = Constants.AssetId.Stone
			_faces.Bottom = Constants.AssetId.Stone
		elseif _name == "Bedrock" then
			_faces.Top = Constants.AssetId.Bedrock
			_faces.Right = Constants.AssetId.Bedrock
			_faces.Left = Constants.AssetId.Bedrock
			_faces.Front = Constants.AssetId.Bedrock
			_faces.Back = Constants.AssetId.Bedrock
			_faces.Bottom = Constants.AssetId.Bedrock
		elseif _name == "Wood" then
			_faces.Top = Constants.AssetId.WoodTopBottom
			_faces.Right = Constants.AssetId.WoodSide
			_faces.Left = Constants.AssetId.WoodSide
			_faces.Front = Constants.AssetId.WoodSide
			_faces.Back = Constants.AssetId.WoodSide
			_faces.Bottom = Constants.AssetId.WoodTopBottom
		elseif _name == "Leaves" then
			_faces.Top = Constants.AssetId.Leaves
			_faces.Right = Constants.AssetId.Leaves
			_faces.Left = Constants.AssetId.Leaves
			_faces.Front = Constants.AssetId.Leaves
			_faces.Back = Constants.AssetId.Leaves
			_faces.Bottom = Constants.AssetId.Leaves
		elseif _name == "Water" then
			_faces.Top = Constants.AssetId.WaterTop
			_faces.Right = Constants.AssetId.WaterSideBottom
			_faces.Left = Constants.AssetId.WaterSideBottom
			_faces.Front = Constants.AssetId.WaterSideBottom
			_faces.Back = Constants.AssetId.WaterSideBottom
			_faces.Bottom = Constants.AssetId.WaterSideBottom
		elseif _name == "Custom" then
		else _name = "Air" end
	end
	
	local function _Create(visibleFaces)--Create a Block in Workspace
		local function SetBlock3dAttributes(block3d)
			local function SetBlock3dName()
				block3d.Name = _name.." "
					.._position.X
					.."x".._position.Y
					.."x".._position.Z
			end
			local function SetBlock3dFacesImage()
				local function SetFaceImage(instance, face, imageAsset)
					local function CreateSurfaceGui()
						local surfaceGui = Instance.new("SurfaceGui")
						surfaceGui.Face = face
						surfaceGui.Name = face
						surfaceGui.Enabled = true
						return surfaceGui
					end
					local function CreateImageLabel(surfaceGui)
						local image = Instance.new("ImageLabel")
						image.Image = imageAsset
						image.Parent = surfaceGui
						image.BackgroundTransparency = 1
						image.Size = UDim2.fromScale(1, 1)
						if _name == "Water" then
							image.ImageTransparency = 0.3
						end
						return image
					end

					if visibleFaces[face] then
						local surfaceGui = CreateSurfaceGui()
						CreateImageLabel(surfaceGui)
						surfaceGui.Parent = instance
					end
				end

				if _name ~= "Custom" then
					SetFaceImage(block3d, "Front", _faces.Front)
					SetFaceImage(block3d, "Back", _faces.Back)
					SetFaceImage(block3d, "Right", _faces.Right)
					SetFaceImage(block3d, "Left", _faces.Left)
					SetFaceImage(block3d, "Top", _faces.Top)
					SetFaceImage(block3d, "Bottom", _faces.Bottom)
				end
			end
			local function SetBlock3dSelectionBox()
				local selectionBox = Instance.new("SelectionBox")
				selectionBox.LineThickness = 0.01
				selectionBox.Color3 = Color3.new(0,0,0)
				selectionBox.Transparency = 0.7
				selectionBox.Parent = block3d
				selectionBox.Adornee = block3d
				selectionBox.Visible = false
			end
			local function SetBlock3dSize()
				block3d.Size = Vector3.new(Constants.BlockSizeMultiplier,
					Constants.BlockSizeMultiplier, Constants.BlockSizeMultiplier)
			end
			local function SetBlock3dPosition()
				block3d.Position = Block.ConvertRawPositionToStudsPosition(_position)
			end
			local function SetBlock3dAnchored() block3d.Anchored = true end
			local function SetBlock3dTransparency()
				if _name == "Custom" then
					block3d.Transparency = 0
				else
					block3d.Transparency = 1
				end
			end
			local function SetBlock3dColor()
				if _name == "Custom" then
					block3d.Color = _color
				end
			end
			local function SetBlock3dMaterial()
				block3d.Material = Enum.Material.SmoothPlastic
			end
			local function SetBlock3dParent() block3d.Parent = _parent end
			local function SetBlock3dCanCollide() 
				block3d.CanCollide = _name ~= "Water" and _name ~= "Air"
			end
			
			if _name then SetAssets() end
			SetBlock3dName()
			SetBlock3dFacesImage()
			--SetBlock3dSelectionBox()
			SetBlock3dSize()
			SetBlock3dPosition()
			SetBlock3dAnchored()
			SetBlock3dTransparency()
			SetBlock3dColor()
			SetBlock3dMaterial()
			SetBlock3dParent()
			SetBlock3dCanCollide()
		end
		local function Create3dBlock()
			local block3d = nil
			if _name ~= "Air" then
				block3d = Instance.new("Part")
				SetBlock3dAttributes(block3d)
			end
			return block3d
		end
		_block3d = Create3dBlock()
		return _block3d
	end
	
	local function _Load()
		if _block3d then
			_block3d:Destroy()
			_block3d = nil
		end
		local visibleFaces = {}
		_visible = false
		local function SetBlock3dAllFacesVisibility()
			local function SetFaceVisibility(args, face)
				local function CheckIfFaceCanBeVisible()
					local function GetNeighborChunkName()
						local x = 0
						local y = 0
						x = math.floor((_position.X + (args.X or 0)) / (Constants.Chunk.XZ))
						y = math.floor((_position.Z + (args.Z or 0)) / (Constants.Chunk.XZ))
						return "Chunk "..x.."x"..y
					end
					local neighborChunk = world.GetBuildedChunk(GetNeighborChunkName())
					if neighborChunk then
						local block = Block.GetByPosition(world, Vector3.new(
							_position.X + (args.X or 0),
							_position.Y + (args.Y or 0),
							_position.Z + (args.Z or 0)
						))
						if block then
							if _name == "Grass" and
								face == "Top" and
								block.GetName() ~= "Air" then
								_name = "Dirt"
							end
							return block.GetName() == "Air" or 
								(block.GetName() == "Water" and _name ~= "Water")
						else
							return true
						end
					else
						_totallyLoaded = false
						return false
					end
				end
				local isFaceVisible = CheckIfFaceCanBeVisible()

				if _name ~= "Custom" then
					visibleFaces[face] = isFaceVisible
				end

				if isFaceVisible then
					_visible = true
				end
			end
			
			_totallyLoaded = true
			SetFaceVisibility({X = 1}, "Right")
			SetFaceVisibility({X = -1}, "Left")
			SetFaceVisibility({Y = 1}, "Top")
			SetFaceVisibility({Y = -1}, "Bottom")
			SetFaceVisibility({Z = 1}, "Back")
			SetFaceVisibility({Z = -1}, "Front")
		end

		if _name ~= "Custom" and _name ~= "Air" then
			SetBlock3dAllFacesVisibility()
		end

		if (_visible and _name ~= "Air") or _name == "Custom" then
			_block3d = _Create(visibleFaces)
		end

		return _block3d
	end
	
	local function _ReloadNeighbors()
		local function ReloadBlock(args)
			local block = Block.GetByPosition(world, Vector3.new(
				_position.X + (args.X or 0),
				_position.Y + (args.Y or 0),
				_position.Z + (args.Z or 0)
			))
			if block then
				block.Load()
			end
		end
		ReloadBlock({X = 1})
		ReloadBlock({X = -1})
		ReloadBlock({Y = 1})
		ReloadBlock({Y = -1})
		ReloadBlock({Z = 1})
		ReloadBlock({Z = -1})
	end
	
	local function _Destroy(self)
		if _block3d then
			_block3d:Destroy()
		end
		for _, property in pairs(self) do
			property = nil
		end
	end
	
	if Block.GetByPosition(world, _position) and Block.GetByPosition(world, _position).GetName() ~= "Air" then
		return nil
	end
	
	--Create and Returns the Block Instance
	return {
		SetName = function(self, str)
			local chunk = world.GetBuildedChunk(_parent.Name)
			_name = str
			chunk.SetBlockToData(self)
		end,
		GetName = function()
			return _name
		end,
		GetPosition = function()
			return _position
		end,
		SetColor = function(color3)
			_color = color3
		end,
		GetColor = function()
			return _color
		end,
		SetParent = function(instance)
			_parent = instance
		end,
		GetParent = function()
			return _parent
		end,
		GetBlock3d = function()
			return _block3d
		end,
		GetChunkName = function()
			if _parent then
				return _parent.Name
			end
		end,
		IsTotallyLoaded = function()
			return _totallyLoaded
		end,
		Load = _Load,
		ReloadNeighbors = _ReloadNeighbors,
		Destroy = _Destroy,
	}
end

return Block