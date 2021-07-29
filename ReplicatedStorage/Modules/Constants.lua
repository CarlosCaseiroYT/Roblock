local Constants = {
	MaxChunkDistanceVisible = 4,
	BlockSizeMultiplier = 3,
	AssetId = {
		GrassTop = "YOUR_ASSET_ID",
		GrassSide = "YOUR_ASSET_ID",
		Dirt = "YOUR_ASSET_ID",
		Stone = "YOUR_ASSET_ID",
		Bedrock = "YOUR_ASSET_ID",
		WoodTopBottom = "YOUR_ASSET_ID",
		WoodSide = "YOUR_ASSET_ID",
		Leaves = "YOUR_ASSET_ID",
		WaterTop = "YOUR_ASSET_ID",
		WaterSideBottom = "YOUR_ASSET_ID"
	},
	Chunk = {
		XZ = 2^3,
		Y = 2^5
	}
}

return Constants
