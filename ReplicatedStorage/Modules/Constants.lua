local Constants = {
	MaxChunkDistanceVisible = 4,
	BlockSizeMultiplier = 3,
	AssetId = {
		GrassTop = "rbxassetid://6967929613",
		GrassSide = "rbxassetid://6967929535",
		Dirt = "rbxassetid://6967929438",
		Stone = "rbxassetid://6967929130",
		Bedrock = "rbxassetid://6967929042",
		WoodTopBottom = "rbxassetid://6967928951",
		WoodSide = "rbxassetid://6967928867",
		Leaves = "rbxassetid://6967928736",
		WaterTop = "rbxassetid://6967929238",
		WaterSideBottom = "rbxassetid://6967929343"
	},
	Chunk = {
		XZ = 2^3,
		Y = 2^5,
		MaxY = 2^7
	}
}

return Constants
