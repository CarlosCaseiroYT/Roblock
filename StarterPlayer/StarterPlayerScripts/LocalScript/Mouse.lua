local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local camera = workspace.Camera

local rParams = RaycastParams.new()
rParams.IgnoreWater = true

local module = {
	GetMouseTarget = function(list, filterType)
		if filterType then
			rParams.FilterType = filterType
		else
			rParams.FilterType = Enum.RaycastFilterType.Blacklist
		end
		if not list then
			list = {}
		end
		rParams.FilterDescendantsInstances = list
		local maxLenght = 12
		local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
		local unitray = camera:ScreenPointToRay(MousePos.x, MousePos.y)
		local ray = Ray.new(unitray.Origin, unitray.Direction * maxLenght)
		return workspace:Raycast(ray.Origin, ray.Direction, rParams)
	end
}

return module
