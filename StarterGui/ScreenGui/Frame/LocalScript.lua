local UserInputService = game:GetService("UserInputService")

local blocksMenu = script.Parent

local isOpen = false

local customBlockColor3 = Color3.new(0, 0, 0)

UserInputService.InputEnded:Connect(function(inputType, gameProcessedEvent)
	if inputType.UserInputType == Enum.UserInputType.Keyboard then
		if inputType.KeyCode == Enum.KeyCode.E then
			isOpen = not isOpen
			blocksMenu.Visible = isOpen
		end
	end
end)

blocksMenu.Close.MouseButton1Click:Connect(function()
	isOpen = false
	blocksMenu.Visible = false
end)

local function filterString(text)
	local numberText = ""
	local numberCount = 0
	local lastChar = nil
	for char in text:gmatch"." do
		if numberCount < 3 then
			if char == "0"
				or char == "1"
				or char == "2"
				or char == "3"
				or char == "4"
				or char == "5"
				or char == "6"
				or char == "7"
				or char == "8"
				or char == "9" then
				
				numberCount = numberCount + 1
				
				if lastChar == "0" and numberCount == 2 then
					numberCount = 1
					numberText = char
				else
					numberText = numberText..char
				end
				
				lastChar = char
			end
		end
	end
	if numberText == "" then
		return 0
	elseif tonumber(numberText) > 255 then
		numberText = 255
	end
	return numberText
end

blocksMenu.FrameCustom.FrameInput.TextInputR.Changed:Connect(function(propertyName)
	if propertyName == "Text" then
		local inputText = blocksMenu.FrameCustom.FrameInput.TextInputR
		local text = inputText.Text
		
		local numberText = filterString(text)
		
		if numberText then
			inputText.Text = numberText
			local number = tonumber(numberText)
			
			customBlockColor3 = Color3.new(number / 255, customBlockColor3.G, customBlockColor3.B)
			blocksMenu.FrameCustom.ButtonCustom.ImageCustom.BackgroundColor3 = customBlockColor3
		end
	end
end)

blocksMenu.FrameCustom.FrameInput.TextInputG.Changed:Connect(function(propertyName)
	if propertyName == "Text" then
		local inputText = blocksMenu.FrameCustom.FrameInput.TextInputG
		local text = inputText.Text

		local numberText = filterString(text)
		
		if numberText then
			inputText.Text = numberText
			local number = tonumber(numberText)

			customBlockColor3 = Color3.new(customBlockColor3.R, number / 255, customBlockColor3.B)
			blocksMenu.FrameCustom.ButtonCustom.ImageCustom.BackgroundColor3 = customBlockColor3
		end
	end
end)

blocksMenu.FrameCustom.FrameInput.TextInputB.Changed:Connect(function(propertyName)
	if propertyName == "Text" then
		local inputText = blocksMenu.FrameCustom.FrameInput.TextInputB
		local text = inputText.Text

		local numberText = filterString(text)
		
		if numberText then
			inputText.Text = numberText
			local number = tonumber(numberText)

			customBlockColor3 = Color3.new(customBlockColor3.R, customBlockColor3.G, number / 255)
			blocksMenu.FrameCustom.ButtonCustom.ImageCustom.BackgroundColor3 = customBlockColor3
		end
	end
end)

local function selectBlock(blockName)
	return function()
		isOpen = false
		blocksMenu.Visible = false
		script.SelectBlock:Fire(blockName, customBlockColor3)
	end
end

blocksMenu.FrameGrass.ButtonGrass.MouseButton1Click:Connect(selectBlock("Grass"))
blocksMenu.FrameDirt.ButtonDirt.MouseButton1Click:Connect(selectBlock("Dirt"))
blocksMenu.FrameStone.ButtonStone.MouseButton1Click:Connect(selectBlock("Stone"))
blocksMenu.FrameWood.ButtonWood.MouseButton1Click:Connect(selectBlock("Wood"))
blocksMenu.FrameLeaves.ButtonLeaves.MouseButton1Click:Connect(selectBlock("Leaves"))
blocksMenu.FrameWater.ButtonWater.MouseButton1Click:Connect(selectBlock("Water"))
blocksMenu.FrameCustom.ButtonCustom.MouseButton1Click:Connect(selectBlock("Custom"))