repeat wait() until game:IsLoaded()

local BlacklistedKeys = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.Space,
	Enum.KeyCode.BackSlash,
	Enum.KeyCode.Return,
	Enum.KeyCode.CapsLock,
}

local Numbers = {
	["One"] = 1,
	["Two"] = 2,
	["Three"] = 3,
	["Four"] = 4,
	["Five"] = 5,
	["Six"] = 6,
	["Seven"] = 7,
	["Eight"] = 8,
	["Nine"] = 9,
	["Zero"] = 0,
	["Minus"] = "-",
	["Equals"] = "=",
	["Backquote"] = "`",
	["Comma"] = ",",
	["Slash"] = "/",
	["Semicolon"] = ";",
	["LeftBracket"] = "[",
	["RightBracket"] = "]",
	["Quote"] = "'"

}

local NumberIndex = {}

for i, v in pairs(Numbers) do
	if not table.find(NumberIndex,tostring(i)) then
		table.insert(NumberIndex,i)
	end
end


local taken = false
local ColorPicking = false
local FirstPage = false
local FirstButton = false

----------------
local Client = game.Players.LocalPlayer
local Mouse = Client:GetMouse()

local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Tween = game:GetService("TweenService")
local TI = TweenInfo.new

local Util = {}

function Util:Tween(instance, properties, duration, ...)
	Tween:Create(instance, TI(duration, ...), properties):Play()
end

function Util:ToggleUI(ui)
	ui.Enabled = not ui.Enabled
end

function Util:Wait()
	Run.RenderStepped:Wait()
	return true
end

function Util:Find(table, value)
	for i, v in  pairs(table) do
		if v == value then
			return i
		end
	end
end

function Util:Sort(pattern, values)
	local new = {}
	pattern = pattern:lower()

	if pattern == "" then
		return values
	end

	for i, value in pairs(values) do
		if tostring(value):lower():find(pattern) then
			table.insert(new, value)
		end
	end

	return new
end

local Ripplin
function Util:Ripple(ui)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local mouse = Players.LocalPlayer:GetMouse()

	local button = ui
	local background = button:WaitForChild("Background")

	local active = false
	local hovering = false

	local function CreateCircle()
		local circle = Instance.new("Frame")
		local cornerRadius = Instance.new("UICorner")

		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.BackgroundColor3 = Color3.fromRGB(0,0,0)
		circle.Size = UDim2.new(0, 0, 0, 0)

		cornerRadius.CornerRadius = UDim.new(0.5, 0)
		cornerRadius.Parent = circle

		return circle
	end

	local function CalculateDistance(pointA, pointB)
		return math.sqrt(((pointB.X - pointA.X) ^ 2) + ((pointB.Y - pointA.Y) ^ 2))
	end

	local function OnMouseButton1Down()
		active = true

		local buttonAbsoluteSize = button.AbsoluteSize
		local buttonAbsolutePosition = button.AbsolutePosition

		local mouseAbsolutePosition = Vector2.new(mouse.X, mouse.Y)
		local mouseRelativePosition = (mouseAbsolutePosition - buttonAbsolutePosition)

		local circle = CreateCircle()

		circle.BackgroundTransparency = 0.84
		circle.Position = UDim2.new(0, mouseRelativePosition.X, 0, mouseRelativePosition.Y)
		circle.Parent = background

		local topLeft = CalculateDistance(mouseRelativePosition, Vector2.new(0, 0))
		local topRight = CalculateDistance(mouseRelativePosition, Vector2.new(buttonAbsoluteSize.X, 0))
		local bottomRight = CalculateDistance(mouseRelativePosition, buttonAbsoluteSize)
		local bottomLeft = CalculateDistance(mouseRelativePosition, Vector2.new(0, buttonAbsoluteSize.Y + 2))

		local size = math.max(topLeft-15, topRight-15, bottomRight-15, bottomLeft-15)-- * 2

		local tweenTime = 0.3 -- seconds
		local startedTimestamp
		local completed = false

		local expand = TweenService:Create(
			circle,
			TweenInfo.new(
				tweenTime,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out
			),
			{ Size = UDim2.new(0, size, 0, size) }
		)

		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not active then
				connection:Disconnect()

				local defaultTime = (tweenTime / 3)
				local timeRemaining = tweenTime - (os.time() - startedTimestamp)
				local newTweenTime = not completed and timeRemaining > defaultTime and timeRemaining or defaultTime

				local fadeOut = TweenService:Create(
					circle,
					TweenInfo.new(
						newTweenTime,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.Out
					),
					{ BackgroundTransparency = 1 }
				)

				fadeOut:Play()
				fadeOut.Completed:Wait()

				circle:Destroy()
			end
		end)

		expand:Play()
		startedTimestamp = os.time()
		expand.Completed:Wait()

		completed = true
	end

	local function OnMouseButton1Up()
		active = false
	end


	local function OnMouseLeave()
		hovering = false
		active = false
	end

	button.MouseButton1Down:Connect(OnMouseButton1Down)
	button.MouseButton1Up:Connect(OnMouseButton1Up)


	button.MouseLeave:Connect(OnMouseLeave)

end
----------------

function IsFirstPage(frame,button)
	if FirstPage == true or FirstButton == true then
		return false
	else
		FirstPage, FirstButton = frame, button
		return frame
	end
end

function Draggify(frame)
	local UserInputService = game:GetService("UserInputService")
	local runService = (game:GetService("RunService"));

	local gui = frame

	local dragging
	local dragInput
	local dragStart
	local startPos

	function Lerp(a, b, m)
		return a + (b - a) * m
	end;

	local lastMousePos
	local lastGoalPos
	local DRAG_SPEED = (16); -- // The speed of the UI darg.
	local function Update(dt)
		if not (startPos) then return end;
		if (ColorPicking) then return end;
		if not (dragging) and (lastGoalPos) then
			gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
			return 
		end;

		local delta = (lastMousePos - UserInputService:GetMouseLocation())
		local xGoal = (startPos.X.Offset - delta.X);
		local yGoal = (startPos.Y.Offset - delta.Y);
		lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
		gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
	end;

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			lastMousePos = UserInputService:GetMouseLocation()

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	runService.Heartbeat:Connect(Update)

end


getgenv().Whitelisted = {}
getgenv().Targets = {}

local WindowTable = {} 

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function WindowTable:ToggleUI()
	if game:GetService("CoreGui")[_G.FewofiwegngreRG452].Enabled then
		game:GetService("CoreGui")[_G.FewofiwegngreRG452].Enabled = false
	else
		game:GetService("CoreGui")[_G.FewofiwegngreRG452].Enabled = true
	end
end


function WindowTable:CreateWindow(config)
	function deleteit()
		if game:GetService("CoreGui"):FindFirstChild(tostring(_G.FewofiwegngreRG452)) then
			game:GetService("CoreGui")[tostring(_G.FewofiwegngreRG452)]:Destroy()
		end
	end
	spawn(deleteit)
	wait(0.4)
	_G.FewofiwegngreRG452 = LibName

	local Title = config.Title or config.title or config.text or config.Text or "Made By Drifter!"

	local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui")) --game:GetService("CoreGui")

	local instances = {
		["UICorner_5"] = Instance.new("UICorner"),
		["UICorner_13"] = Instance.new("UICorner"),
		["UICorner_6"] = Instance.new("UICorner"),
		["Frame_13"] = Instance.new("Frame"),
		["Frame_25"] = Instance.new("Frame"),
		["ScrollingFrame_3"] = Instance.new("ScrollingFrame"),
		["ImageLabel_3"] = Instance.new("ImageLabel"),
		["ImageLabel_2"] = Instance.new("ImageLabel"),
		["Frame_6"] = Instance.new("Frame"),
		["UIStroke_3"] = Instance.new("UIStroke"),
		["Frame_19"] = Instance.new("Frame"),
		["Frame_20"] = Instance.new("Frame"),
		["UICorner_14"] = Instance.new("UICorner"),
		["Frame_16"] = Instance.new("Frame"),
		["Frame_3"] = Instance.new("Frame"),
		["TextButton_4"] = Instance.new("TextButton"),
		["Frame_17"] = Instance.new("Frame"),
		["Frame_10"] = Instance.new("Frame"),
		["TextBox_1"] = Instance.new("TextBox"),
		["UICorner_10"] = Instance.new("UICorner"),
		["Frame_23"] = Instance.new("Frame"),
		["Frame_18"] = Instance.new("Frame"),
		["UICorner_15"] = Instance.new("UICorner"),
		["TextLabel_3"] = Instance.new("TextLabel"),
		["UIListLayout_1"] = Instance.new("UIListLayout"),
		["TextButton_2"] = Instance.new("TextButton"),
		["UICorner_11"] = Instance.new("UICorner"),
		["UIStroke_4"] = Instance.new("UIStroke"),
		["Frame_14"] = Instance.new("Frame"),
		["UICorner_17"] = Instance.new("UICorner"),
		["TextButton_1"] = Instance.new("TextButton"),
		["UICorner_16"] = Instance.new("UICorner"),
		["Frame_24"] = Instance.new("Frame"),
		["LocalScript_1"] = Instance.new("LocalScript"),
		["UICorner_8"] = Instance.new("UICorner"),
		["Frame_9"] = Instance.new("Frame"),
		["Frame_21"] = Instance.new("Frame"),
		["UIStroke_2"] = Instance.new("UIStroke"),
		["Frame_8"] = Instance.new("Frame"),
		["ScrollingFrame_2"] = Instance.new("ScrollingFrame"),
		["UICorner_12"] = Instance.new("UICorner"),
		["UICorner_7"] = Instance.new("UICorner"),
		["UICorner_3"] = Instance.new("UICorner"),
		["Frame_7"] = Instance.new("Frame"),
		["UIPadding_1"] = Instance.new("UIPadding"),
		["Frame_22"] = Instance.new("Frame"),
		["ScrollingFrame_1"] = Instance.new("ScrollingFrame"),
		["Frame_11"] = Instance.new("Frame"),
		["ImageLabel_4"] = Instance.new("ImageLabel"),
		["Frame_1"] = Instance.new("Frame"),
		["Frame_12"] = Instance.new("Frame"),
		["TextLabel_2"] = Instance.new("TextLabel"),
		["TextButton_3"] = Instance.new("TextButton"),
		["UICorner_9"] = Instance.new("UICorner"),
		["UIStroke_1"] = Instance.new("UIStroke"),
		["Frame_2"] = Instance.new("Frame"),
		["Frame_15"] = Instance.new("Frame"),
		["Frame_4"] = Instance.new("Frame"),
		["TextLabel_1"] = Instance.new("TextLabel"),
		["UICorner_4"] = Instance.new("UICorner"),
		["Frame_5"] = Instance.new("Frame"),
		["ImageLabel_1"] = Instance.new("ImageLabel"),
		["UICorner_2"] = Instance.new("UICorner"),
		["StringValue_1"] = Instance.new("StringValue"),
		["TextButton_5"] = Instance.new("TextButton"),
		["UICorner_1"] = Instance.new("UICorner"),
		["LocalScript_2"] = Instance.new("LocalScript"),
		["Folder_1"] = Instance.new("Folder"),
	}


	screenGui.Name = _G.FewofiwegngreRG452
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	instances.StringValue_1.Parent = screenGui
	instances.StringValue_1.Name = 'SelectedPlayer'

	instances.Frame_1.Parent = screenGui
	instances.Frame_1.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	instances.Frame_1.Position = UDim2.new(0, 289, 0, 181)
	instances.Frame_1.Size = UDim2.new(0, 543, 0, 344)
	instances.Frame_1.Name = 'MainUI'
	instances.Frame_1.Visible = true
	Draggify(instances.Frame_1)

	instances.UICorner_1.Parent = instances.Frame_1
	instances.UICorner_1.CornerRadius = UDim.new(0, 6)

	instances.Frame_2.Parent = instances.Frame_1
	instances.Frame_2.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	instances.Frame_2.BorderSizePixel = 0
	instances.Frame_2.Size = UDim2.new(0.6077347993850708, 0, 1, 0)
	instances.Frame_2.Name = 'Main'

	instances.Frame_3.Parent = instances.Frame_2
	instances.Frame_3.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.Frame_3.BackgroundTransparency = 1
	instances.Frame_3.BorderSizePixel = 0
	instances.Frame_3.Size = UDim2.new(0, 330, 0, 35)
	instances.Frame_3.Name = 'TopRow'

	instances.TextButton_1.Parent = instances.Frame_3
	instances.TextButton_1.Font = Enum.Font.SourceSans
	instances.TextButton_1.Text = ''
	instances.TextButton_1.TextColor3 = Color3.new(0, 0, 0)
	instances.TextButton_1.TextSize = 14
	instances.TextButton_1.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.TextButton_1.BackgroundTransparency = 1
	instances.TextButton_1.Size = UDim2.new(0, 35, 0, 35)
	instances.TextButton_1.Name = 'ArrowButton'

	instances.ImageLabel_1.Parent = instances.TextButton_1
	instances.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031091000'
	instances.ImageLabel_1.ImageColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	instances.ImageLabel_1.BackgroundTransparency = 1
	instances.ImageLabel_1.BorderSizePixel = 0
	instances.ImageLabel_1.Size = UDim2.new(0, 35, 0, 35)

	instances.LocalScript_1.Parent = instances.TextButton_1

	instances.TextLabel_1.Parent = instances.Frame_3
	instances.TextLabel_1.Font = Enum.Font.SourceSansSemibold
	instances.TextLabel_1.Text = tostring(Title)
	instances.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	instances.TextLabel_1.TextSize = 24
	instances.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
	instances.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.TextLabel_1.BackgroundTransparency = 1
	instances.TextLabel_1.Position = UDim2.new(0.13939394056797028, 0, 0, 0)
	instances.TextLabel_1.Size = UDim2.new(0, 270, 0, 35)

	instances.Frame_4.Parent = instances.Frame_2
	instances.Frame_4.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	instances.Frame_4.BorderSizePixel = 0
	instances.Frame_4.Position = UDim2.new(0, 0, 0.1080000028014183, 0)
	instances.Frame_4.Size = UDim2.new(1, 0, 0.8924418687820435, 0)
	instances.Frame_4.Name = 'Main'

	instances.Frame_5.Parent = instances.Frame_1
	instances.Frame_5.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
	instances.Frame_5.Position = UDim2.new(0, -133, 0, 0)
	instances.Frame_5.Size = UDim2.new(0.23204420506954193, 0, 1, 0)
	instances.Frame_5.ZIndex = 0
	instances.Frame_5.Name = 'PageButtonHolders'

	instances.Folder_1.Parent = instances.Frame_4
	instances.Folder_1.Name = "pageHolder"

	instances.UICorner_2.Parent = instances.Frame_5
	instances.UICorner_2.CornerRadius = UDim.new(0, 6)

	instances.ScrollingFrame_1.Parent = instances.Frame_5
	instances.ScrollingFrame_1.CanvasSize = UDim2.new(0, 0, 0, 0)
	instances.ScrollingFrame_1.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	instances.ScrollingFrame_1.ScrollBarThickness = 0
	instances.ScrollingFrame_1.Active = true
	instances.ScrollingFrame_1.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.ScrollingFrame_1.BackgroundTransparency = 1
	instances.ScrollingFrame_1.Size = UDim2.new(1, 0, 0.8633720874786377, 0)

	instances.UIListLayout_1.Parent = instances.ScrollingFrame_1
	instances.UIListLayout_1.Padding = UDim.new(0, 7)
	instances.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

	instances.UIPadding_1.Parent = instances.ScrollingFrame_1
	instances.UIPadding_1.PaddingLeft = UDim.new(0, 5)
	instances.UIPadding_1.PaddingTop = UDim.new(0, 8)

	instances.TextButton_2.Parent = instances.Frame_5
	instances.TextButton_2.Font = Enum.Font.SourceSansSemibold
	instances.TextButton_2.Text = ''
	instances.TextButton_2.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	instances.TextButton_2.TextSize = 18
	instances.TextButton_2.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	instances.TextButton_2.BorderSizePixel = 0
	instances.TextButton_2.Position = UDim2.new(0.0317460335791111, 0, 0.8865408897399902, 0)
	instances.TextButton_2.Size = UDim2.new(0, 117, 0, 32)
	instances.TextButton_2.AutoButtonColor = false
	instances.TextButton_2.Name = 'Settings'

	instances.UICorner_3.Parent = instances.TextButton_2
	instances.UICorner_3.CornerRadius = UDim.new(0, 4)

	instances.Frame_6.Parent = instances.TextButton_2
	instances.Frame_6.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
	instances.Frame_6.Position = UDim2.new(0, 0, 0.9285714030265808, 0)
	instances.Frame_6.Size = UDim2.new(1, 0, 0.0714285746216774, 0)
	instances.Frame_6.Name = 'buttonShadow'

	instances.UICorner_4.Parent = instances.Frame_6
	instances.UICorner_4.CornerRadius = UDim.new(0, 4)

	instances.Frame_7.Parent = instances.TextButton_2
	instances.Frame_7.BackgroundColor3 = Color3.new(0, 0, 0)
	instances.Frame_7.BackgroundTransparency = 1
	instances.Frame_7.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	instances.Frame_7.BorderSizePixel = 0
	instances.Frame_7.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_7.Name = 'Shadow'

	instances.UICorner_5.Parent = instances.Frame_7
	instances.UICorner_5.CornerRadius = UDim.new(0, 4)

	instances.TextLabel_2.Parent = instances.TextButton_2
	instances.TextLabel_2.Font = Enum.Font.SourceSansSemibold
	instances.TextLabel_2.Text = 'Settings'
	instances.TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
	instances.TextLabel_2.TextSize = 18
	instances.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.TextLabel_2.BackgroundTransparency = 1
	instances.TextLabel_2.Size = UDim2.new(1, 0, 1, 0)
	instances.TextLabel_2.ZIndex = 1

	instances.LocalScript_2.Parent = instances.TextButton_2
	instances.LocalScript_2.Name = 'RippleEffect'

	instances.Frame_8.Parent = instances.TextButton_2
	instances.Frame_8.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Frame_8.BackgroundColor3 = Color3.new(0, 0, 0)
	instances.Frame_8.BackgroundTransparency = 1
	instances.Frame_8.ClipsDescendants = true
	instances.Frame_8.Position = UDim2.new(0.5, 0, 0.5, 0)
	instances.Frame_8.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_8.Name = 'Background'
	Util:Ripple(instances.TextButton_2)

	instances.UICorner_6.Parent = instances.Frame_8
	instances.UICorner_6.CornerRadius = UDim.new(0, 4)
	instances.UICorner_6.Name = 'CornerRadius'

	instances.UIStroke_1.Parent = instances.Frame_8
	instances.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	instances.UIStroke_1.Thickness = 0
	instances.UIStroke_1.Transparency = 0.5
	instances.UIStroke_1.Name = 'Border'

	instances.Frame_9.Parent = instances.Frame_1
	instances.Frame_9.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
	instances.Frame_9.Position = UDim2.new(0.609576404094696, 0, 0, 0)
	instances.Frame_9.Size = UDim2.new(0.3885819613933563, 0, 1, 0)
	instances.Frame_9.Name = 'RightSearchHolder'

	instances.UICorner_7.Parent = instances.Frame_9
	instances.UICorner_7.CornerRadius = UDim.new(0, 6)

	instances.Frame_10.Parent = instances.Frame_9
	instances.Frame_10.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.Frame_10.BorderSizePixel = 0
	instances.Frame_10.Position = UDim2.new(-0.0018987429793924093, 0, 0, 0)
	instances.Frame_10.Size = UDim2.new(0.9952606558799744, 0, 0.10174418240785599, 0)
	instances.Frame_10.Name = 'TopRight'

	instances.Frame_11.Parent = instances.Frame_10
	instances.Frame_11.BackgroundColor3 = Color3.new(0.309804, 0.313726, 0.301961)
	instances.Frame_11.BorderSizePixel = 0
	instances.Frame_11.Position = UDim2.new(0, 0, 0.4444445073604584, 0)
	instances.Frame_11.Size = UDim2.new(1.0047619342803955, 0, 0.5428571701049805, 0)
	instances.Frame_11.Name = 'fixer'

	instances.Frame_12.Parent = instances.Frame_10
	instances.Frame_12.BackgroundColor3 = Color3.new(0.309804, 0.313726, 0.301961)
	instances.Frame_12.BorderSizePixel = 0
	instances.Frame_12.Position = UDim2.new(-1.453218061442385e-07, 0, 0, 0)
	instances.Frame_12.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_12.Name = 'fixer'

	instances.Frame_13.Parent = instances.Frame_10
	instances.Frame_13.BackgroundColor3 = Color3.new(0.309804, 0.313726, 0.301961)
	instances.Frame_13.Size = UDim2.new(1.0047619342803955, 0, 1, 0)

	instances.UICorner_8.Parent = instances.Frame_13
	instances.UICorner_8.CornerRadius = UDim.new(0, 6)

	instances.Frame_14.Parent = instances.Frame_13
	instances.Frame_14.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.Frame_14.BackgroundTransparency = 1
	instances.Frame_14.BorderSizePixel = 0
	instances.Frame_14.Size = UDim2.new(1.0047392845153809, 0, 1.0571428537368774, 0)
	instances.Frame_14.Name = 'ActualTextBar'

	instances.Frame_15.Parent = instances.Frame_14
	instances.Frame_15.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
	instances.Frame_15.BorderSizePixel = 0
	instances.Frame_15.Position = UDim2.new(0.024000000208616257, 0, 0.11100000143051147, 0)
	instances.Frame_15.Size = UDim2.new(0.943396270275116, 0, 0.7567567825317383, 0)

	instances.TextBox_1.Parent = instances.Frame_15
	instances.TextBox_1.ClearTextOnFocus = false
	instances.TextBox_1.Font = Enum.Font.SourceSansItalic
	instances.TextBox_1.PlaceholderColor3 = Color3.new(0.521569, 0.521569, 0.521569)
	instances.TextBox_1.PlaceholderText = 'Search Player...'
	instances.TextBox_1.Text = ''
	instances.TextBox_1.TextColor3 = Color3.new(0.521569, 0.521569, 0.521569)
	instances.TextBox_1.TextSize = 16
	instances.TextBox_1.TextXAlignment = Enum.TextXAlignment.Left
	instances.TextBox_1.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
	instances.TextBox_1.BorderSizePixel = 0
	instances.TextBox_1.Position = UDim2.new(0.028999999165534973, 0, 0, 0)
	instances.TextBox_1.Size = UDim2.new(0.9750000238418579, 0, 1, 0)
	instances.TextBox_1.Name = 'Search'

	instances.Frame_16.Parent = instances.TextBox_1
	instances.Frame_16.BackgroundColor3 = Color3.new(0.0117647, 0.0117647, 0.0117647)
	instances.Frame_16.BorderSizePixel = 0
	instances.Frame_16.Position = UDim2.new(-0.029432404786348343, 0, 0, 0)
	instances.Frame_16.Size = UDim2.new(1.0294324159622192, 0, 0.1071428582072258, 0)

	instances.Frame_17.Parent = instances.Frame_13
	instances.Frame_17.BackgroundColor3 = Color3.new(0.211765, 0.223529, 0.219608)
	instances.Frame_17.BorderSizePixel = 0
	instances.Frame_17.Position = UDim2.new(-0.000014986377209424973, 0, 0.9992063641548157, 0)
	instances.Frame_17.Size = UDim2.new(1, 0, 0.08571428805589676, 0)

	instances.Frame_18.Parent = instances.Frame_9
	instances.Frame_18.Active = true
	instances.Frame_18.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
	instances.Frame_18.BackgroundTransparency = 1
	instances.Frame_18.BorderSizePixel = 0
	instances.Frame_18.Position = UDim2.new(0, 1, 0, 337)
	instances.Frame_18.Size = UDim2.new(0, 211, 0, 0)
	instances.Frame_18.ZIndex = 5
	instances.Frame_18.Name = 'PopUp'

	instances.Frame_19.Parent = instances.Frame_18
	instances.Frame_19.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.Frame_19.BackgroundTransparency = 1
	instances.Frame_19.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	instances.Frame_19.BorderSizePixel = 0
	instances.Frame_19.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_19.Name = 'ForPlayers'

	instances.ScrollingFrame_2.Parent = instances.Frame_19
	instances.ScrollingFrame_2.BottomImage = ''
	instances.ScrollingFrame_2.CanvasSize = UDim2.new(0, 0, 0, 225)
	instances.ScrollingFrame_2.ScrollBarThickness = 4
	instances.ScrollingFrame_2.TopImage = ''
	instances.ScrollingFrame_2.Active = true
	instances.ScrollingFrame_2.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
	instances.ScrollingFrame_2.BorderSizePixel = 0
	instances.ScrollingFrame_2.Size = UDim2.new(1, 0, 1, 0)

	instances.TextButton_3.Parent = instances.ScrollingFrame_2
	instances.TextButton_3.Font = Enum.Font.SourceSansSemibold
	instances.TextButton_3.Text = 'Whitelist'
	instances.TextButton_3.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	instances.TextButton_3.TextSize = 18
	instances.TextButton_3.BackgroundColor3 = Color3.new(0.996078, 0.337255, 0.337255)
	instances.TextButton_3.BorderSizePixel = 0
	instances.TextButton_3.Position = UDim2.new(0, 7, 0, 170)
	instances.TextButton_3.Size = UDim2.new(0, 194, 0, 30)
	instances.TextButton_3.AutoButtonColor = false
	instances.TextButton_3.Name = 'WhitelistBut'

	instances.UICorner_9.Parent = instances.TextButton_3
	instances.UICorner_9.CornerRadius = UDim.new(0, 4)

	instances.Frame_20.Parent = instances.TextButton_3
	instances.Frame_20.BackgroundColor3 = Color3.new(0.631373, 0.231373, 0.235294)
	instances.Frame_20.Position = UDim2.new(0, 0, 0, 28)
	instances.Frame_20.Size = UDim2.new(0, 194, 0, 2)
	instances.Frame_20.Name = 'buttonShadow'

	instances.UICorner_10.Parent = instances.Frame_20
	instances.UICorner_10.CornerRadius = UDim.new(0, 4)

	instances.Frame_21.Parent = instances.TextButton_3
	instances.Frame_21.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Frame_21.BackgroundColor3 = Color3.new(0, 0, 0)
	instances.Frame_21.BackgroundTransparency = 1
	instances.Frame_21.ClipsDescendants = true
	instances.Frame_21.Position = UDim2.new(0.5, 0, 0.5, 0)
	instances.Frame_21.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_21.Name = 'Background'

	instances.UICorner_11.Parent = instances.Frame_21
	instances.UICorner_11.CornerRadius = UDim.new(0, 4)
	instances.UICorner_11.Name = 'CornerRadius'

	instances.UIStroke_2.Parent = instances.Frame_21
	instances.UIStroke_2.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	instances.UIStroke_2.Thickness = 0
	instances.UIStroke_2.Transparency = 0.5
	instances.UIStroke_2.Name = 'Border'

	instances.ImageLabel_2.Parent = instances.ScrollingFrame_2
	instances.ImageLabel_2.Image = 'rbxassetid://3570695787'
	instances.ImageLabel_2.ImageColor3 = Color3.new(0.996078, 0.337255, 0.337255)
	instances.ImageLabel_2.ScaleType = Enum.ScaleType.Slice
	instances.ImageLabel_2.SliceCenter = Rect.new(100, 100, 100, 100)
	instances.ImageLabel_2.SliceScale = 0.029999999329447746
	instances.ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.ImageLabel_2.BackgroundTransparency = 1
	instances.ImageLabel_2.Position = UDim2.new(0, 6, 0, 83)
	instances.ImageLabel_2.Size = UDim2.new(0, 140, 0, 10)
	instances.ImageLabel_2.Name = 'Healthbar'

	instances.ImageLabel_3.Parent = instances.ImageLabel_2
	instances.ImageLabel_3.Image = 'rbxassetid://3570695787'
	instances.ImageLabel_3.ImageColor3 = Color3.new(0, 0.666667, 0.494118)
	instances.ImageLabel_3.ScaleType = Enum.ScaleType.Slice
	instances.ImageLabel_3.SliceCenter = Rect.new(100, 100, 100, 100)
	instances.ImageLabel_3.SliceScale = 0.029999999329447746
	instances.ImageLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.ImageLabel_3.BackgroundTransparency = 1
	instances.ImageLabel_3.Size = UDim2.new(0, 140, 1, 0)
	instances.ImageLabel_3.Name = 'Bar'

	instances.ImageLabel_4.Parent = instances.ScrollingFrame_2
	instances.ImageLabel_4.Image = 'rbxasset://textures/ui/GuiImagePlaceholder.png'
	instances.ImageLabel_4.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
	instances.ImageLabel_4.BackgroundTransparency = 1
	instances.ImageLabel_4.BorderSizePixel = 0
	instances.ImageLabel_4.Position = UDim2.new(0, 6, 0, 6)
	instances.ImageLabel_4.Size = UDim2.new(0, 68, 0, 68)
	instances.ImageLabel_4.Name = 'AvatarImage'

	instances.TextButton_4.Parent = instances.ScrollingFrame_2
	instances.TextButton_4.Font = Enum.Font.SourceSansSemibold
	instances.TextButton_4.Text = 'Target'
	instances.TextButton_4.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	instances.TextButton_4.TextSize = 18
	instances.TextButton_4.BackgroundColor3 = Color3.new(0.996078, 0.337255, 0.337255)
	instances.TextButton_4.BorderSizePixel = 0
	instances.TextButton_4.Position = UDim2.new(0, 7, 0, 133)
	instances.TextButton_4.Size = UDim2.new(0, 194, 0, 30)
	instances.TextButton_4.AutoButtonColor = false
	instances.TextButton_4.Name = 'TargetBut'

	instances.UICorner_12.Parent = instances.TextButton_4
	instances.UICorner_12.CornerRadius = UDim.new(0, 4)

	instances.Frame_22.Parent = instances.TextButton_4
	instances.Frame_22.BackgroundColor3 = Color3.new(0.631373, 0.231373, 0.235294)
	instances.Frame_22.Position = UDim2.new(0, 0, 0.9333333373069763, 0)
	instances.Frame_22.Size = UDim2.new(1, 0, 0.06666667014360428, 0)
	instances.Frame_22.Name = 'buttonShadow'

	instances.UICorner_13.Parent = instances.Frame_22
	instances.UICorner_13.CornerRadius = UDim.new(0, 4)

	instances.Frame_23.Parent = instances.TextButton_4
	instances.Frame_23.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Frame_23.BackgroundColor3 = Color3.new(0, 0, 0)
	instances.Frame_23.BackgroundTransparency = 1
	instances.Frame_23.ClipsDescendants = true
	instances.Frame_23.Position = UDim2.new(0.5, 0, 0.5, 0)
	instances.Frame_23.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_23.Name = 'Background'

	instances.UICorner_14.Parent = instances.Frame_23
	instances.UICorner_14.CornerRadius = UDim.new(0, 4)
	instances.UICorner_14.Name = 'CornerRadius'

	instances.UIStroke_3.Parent = instances.Frame_23
	instances.UIStroke_3.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	instances.UIStroke_3.Thickness = 0
	instances.UIStroke_3.Transparency = 0.5
	instances.UIStroke_3.Name = 'Border'

	instances.TextLabel_3.Parent = instances.ScrollingFrame_2
	instances.TextLabel_3.Font = Enum.Font.SourceSansItalic
	instances.TextLabel_3.RichText = true
	instances.TextLabel_3.Text = 'Name:'
	instances.TextLabel_3.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	instances.TextLabel_3.TextSize = 18
	instances.TextLabel_3.TextWrapped = true
	instances.TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left
	instances.TextLabel_3.TextYAlignment = Enum.TextYAlignment.Top
	instances.TextLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.TextLabel_3.BackgroundTransparency = 1
	instances.TextLabel_3.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	instances.TextLabel_3.BorderSizePixel = 0
	instances.TextLabel_3.Position = UDim2.new(0, 80, 0, 6)
	instances.TextLabel_3.Size = UDim2.new(0, 128, 0, 42)
	instances.TextLabel_3.Name = 'NameLabel'

	instances.TextButton_5.Parent = instances.ScrollingFrame_2
	instances.TextButton_5.Font = Enum.Font.SourceSansSemibold
	instances.TextButton_5.Text = 'Teleport'
	instances.TextButton_5.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	instances.TextButton_5.TextSize = 18
	instances.TextButton_5.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	instances.TextButton_5.BorderSizePixel = 0
	instances.TextButton_5.Position = UDim2.new(0, 6, 0, 100)
	instances.TextButton_5.Size = UDim2.new(0, 194, 0, 25)
	instances.TextButton_5.AutoButtonColor = false
	instances.TextButton_5.Name = 'TeleportBut'

	instances.UICorner_15.Parent = instances.TextButton_5
	instances.UICorner_15.CornerRadius = UDim.new(0, 4)

	instances.Frame_24.Parent = instances.TextButton_5
	instances.Frame_24.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
	instances.Frame_24.Position = UDim2.new(0, 0, 0, 24)
	instances.Frame_24.Size = UDim2.new(0, 194, 0, 2)
	instances.Frame_24.Name = 'buttonShadow'

	instances.UICorner_16.Parent = instances.Frame_24
	instances.UICorner_16.CornerRadius = UDim.new(0, 4)

	instances.Frame_25.Parent = instances.TextButton_5
	instances.Frame_25.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Frame_25.BackgroundColor3 = Color3.new(0, 0, 0)
	instances.Frame_25.BackgroundTransparency = 1
	instances.Frame_25.ClipsDescendants = true
	instances.Frame_25.Position = UDim2.new(0.5, 0, 0.5, 0)
	instances.Frame_25.Size = UDim2.new(1, 0, 1, 0)
	instances.Frame_25.Name = 'Background'

	instances.UICorner_17.Parent = instances.Frame_25
	instances.UICorner_17.CornerRadius = UDim.new(0, 4)
	instances.UICorner_17.Name = 'CornerRadius'

	instances.UIStroke_4.Parent = instances.Frame_25
	instances.UIStroke_4.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	instances.UIStroke_4.Thickness = 0
	instances.UIStroke_4.Transparency = 0.5
	instances.UIStroke_4.Name = 'Border'

	instances.ScrollingFrame_3.Parent = instances.Frame_9
	instances.ScrollingFrame_3.AutomaticCanvasSize = Enum.AutomaticSize.Y
	instances.ScrollingFrame_3.CanvasSize = UDim2.new(0, 0, 0, 100)
	instances.ScrollingFrame_3.ScrollBarThickness = 0
	instances.ScrollingFrame_3.Active = true
	instances.ScrollingFrame_3.BackgroundColor3 = Color3.new(1, 1, 1)
	instances.ScrollingFrame_3.BackgroundTransparency = 1
	instances.ScrollingFrame_3.BorderSizePixel = 0
	instances.ScrollingFrame_3.Position = UDim2.new(0, 0, 0, 44)
	instances.ScrollingFrame_3.Size = UDim2.new(0, 211, 0, 299)
	instances.ScrollingFrame_3.Name = 'ContentSF'

	local function QHCOSQZ_fake_script() -- ContentSF.Main 
		local script = Instance.new('LocalScript', instances.ScrollingFrame_3)

		local PlayerList = script.Parent
		local PlayerPopup = PlayerList.Parent.PopUp
		local Search = PlayerList.Parent.TopRight.Frame.ActualTextBar.Frame.Search
		local Players = game:GetService("Players")
		local SelectedPlayer = PlayerList.Parent.Parent.Parent.SelectedPlayer
		local focused = false
		local opened = false
		local Healthbar = PlayerPopup.ForPlayers.ScrollingFrame.Healthbar.Bar


		local opensize
		local List

		local function UpdateFrame(player)
			if game:GetService("Players"):FindFirstChild(player) then
				local userId = game.Players[player].UserId
				local content, isReady = game:GetService("Players"):GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				PlayerPopup.ForPlayers.ScrollingFrame.CanvasPosition = Vector2.new(0,0)
				PlayerPopup.ForPlayers.ScrollingFrame.AvatarImage.Image = content
				PlayerPopup.ForPlayers.ScrollingFrame.NameLabel.Text = "Name: "..game.Players[player].Name
			end
		end


		local function updatePlayerList(players)
			PlayerList:ClearAllChildren() 
			PlayerList.CanvasSize = UDim2.new(0,0,0,100) 
			local CurrentPlayer = 0 
			for i,v in pairs(players or {}) do 
				CurrentPlayer = CurrentPlayer + 1 

				local TextButton = Instance.new("TextButton")
				local UICorner = Instance.new("UICorner")
				local buttonShadow = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local Background = Instance.new("Frame")
				local CornerRadius = Instance.new("UICorner")

				TextButton.Name = tostring(v)
				TextButton.Parent = PlayerList
				TextButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				TextButton.BorderSizePixel = 0
				TextButton.Size = UDim2.new(0, 197, 0, 33)
				TextButton.Position = UDim2.new( 0, 7, 0, TextButton.Size.Y.Offset * ( CurrentPlayer - 1 ) * 1.15 ) 
				TextButton.Font = Enum.Font.SourceSansSemibold
				TextButton.Text = tostring(v)
				TextButton.TextColor3 = Color3.fromRGB(229, 229, 229)
				TextButton.TextSize = 18.000
				TextButton.AutoButtonColor = false

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = TextButton

				buttonShadow.Name = "buttonShadow"
				buttonShadow.Parent = TextButton
				buttonShadow.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
				buttonShadow.Position = UDim2.new(0, 0, 0, 30)
				buttonShadow.Size = UDim2.new(0, 197, 0, 3)

				UICorner_2.CornerRadius = UDim.new(0, 4)
				UICorner_2.Parent = buttonShadow

				Background.Name = "Background"
				Background.Parent = TextButton
				Background.AnchorPoint = Vector2.new(0.5, 0.5)
				Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Background.BackgroundTransparency = 1.000
				Background.ClipsDescendants = true
				Background.Position = UDim2.new(0.5, 0, 0.5, 0)
				Background.Size = UDim2.new(1, 0, 1, 0)

				CornerRadius.CornerRadius = UDim.new(0, 4)
				CornerRadius.Name = "CornerRadius"
				CornerRadius.Parent = Background
				if SelectedPlayer.Value == TextButton.Name then
					TextButton.BackgroundColor3 = Color3.fromRGB(0,170,126)
					buttonShadow.BackgroundColor3 = Color3.fromRGB(0,113,84)
				end

				TextButton.MouseEnter:Connect(function()
					Util:Tween(Background,{BackgroundTransparency = 0.8},0.2)
				end)


				TextButton.MouseLeave:Connect(function()
					Util:Tween(Background,{BackgroundTransparency = 1},0.2)
				end)

				TextButton.MouseButton1Click:Connect(function()
					if opened and SelectedPlayer.Value == TextButton.Name then
						opened = false
						SelectedPlayer.Value = ""
					else
						opened = false
						opened = true
						SelectedPlayer.Value = TextButton.Name
						UpdateFrame(tostring(SelectedPlayer.Value))
					end
				end)
			end
		end

		local function Handler()
			List = Players:GetPlayers()
			if #Search.Text == 0 or Search.Text == "" then
				updatePlayerList(Players:GetPlayers())
			end
		end

		Players.PlayerAdded:connect(Handler) 
		Players.PlayerRemoving:connect(Handler) 
		Handler()

		Search.Focused:Connect(function()
			focused = true
		end)

		Search.FocusLost:Connect(function()
			focused = false
		end)

		Search:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = Util:Sort(Search.Text, List)
				list = #list ~= 0 and list 
				updatePlayerList(list)
			end
			if Search.Text == "" or #Search.Text == 0 then
				Handler()
			end
		end)



		SelectedPlayer.Changed:Connect(function()
			for i,v in ipairs(PlayerList:GetChildren()) do
				if v.Name == tostring(SelectedPlayer.Value) then
					Util:Tween(v,{BackgroundColor3 = Color3.fromRGB(0,170,126)},0.3)
					Util:Tween(v.buttonShadow,{BackgroundColor3 = Color3.fromRGB(0,113,84)},0.3)
				else
					Util:Tween(v,{BackgroundColor3 = Color3.fromRGB(100,100,100)},0.3)
					Util:Tween(v:WaitForChild("buttonShadow"),{BackgroundColor3 = Color3.fromRGB(71,71,71)},0.3)
				end
			end
			if SelectedPlayer.Value ~= "" then
				PlayerPopup.Visible = true
				wait(0.2)
				PlayerPopup:TweenSizeAndPosition(UDim2.new(0, 211,0, 134),UDim2.new(0, 1,0, 210),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
				PlayerList:TweenSizeAndPosition(UDim2.new(0, 211,0, 166),UDim2.new(0, 0,0, 44),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			else
				PlayerPopup:TweenSizeAndPosition(UDim2.new(0, 211,0, 0),UDim2.new(0, 1,0, 337),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
				wait(0.2)
				PlayerPopup.Visible = false
				PlayerList:TweenSizeAndPosition(UDim2.new(0, 211,0, 299),UDim2.new(0, 0,0, 44),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)

			end
		end)

		for i, v in pairs(PlayerPopup.ForPlayers.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v.MouseEnter:Connect(function()
					Util:Tween(v.Background,{BackgroundTransparency = 0.8},0.2)
				end)	
				v.MouseLeave:Connect(function()
					Util:Tween(v.Background,{BackgroundTransparency = 1},0.2)
				end)	
			end
		end

		PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut.MouseButton1Click:Connect(function()
			if not table.find(getgenv().Whitelisted,tostring(SelectedPlayer.Value)) then
				table.insert(getgenv().Whitelisted,tostring(SelectedPlayer.Value))
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut,{BackgroundColor3 = Color3.fromRGB(0,170,126)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(0,113,84)},0.3)
			else
				for i,v in pairs(getgenv().Whitelisted) do
					if v == tostring(SelectedPlayer.Value) then
						table.remove(getgenv().Whitelisted, i)
					end
				end
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut,{BackgroundColor3 = Color3.fromRGB(254, 86, 86)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(161, 59, 60)},0.3)
			end
		end)

		PlayerPopup.ForPlayers.ScrollingFrame.TargetBut.MouseButton1Click:Connect(function()
			if not table.find(getgenv().Targets,tostring(SelectedPlayer.Value)) then
				table.insert(getgenv().Targets,tostring(SelectedPlayer.Value))
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut,{BackgroundColor3 = Color3.fromRGB(0,170,126)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(0,113,84)},0.3)
			else
				for i,v in pairs(getgenv().Targets) do
					if v == tostring(SelectedPlayer.Value) then
						table.remove(getgenv().Targets, i)
					end
				end
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut,{BackgroundColor3 = Color3.fromRGB(254, 86, 86)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(161, 59, 60)},0.3)
			end
		end)

		PlayerPopup.ForPlayers.ScrollingFrame.TeleportBut.MouseButton1Click:Connect(function()
			Client.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players[tostring(SelectedPlayer.Value)].Character.HumanoidRootPart.Position) * CFrame.new(0,5,0)
		end)

		local Players = game:GetService("Players")


		SelectedPlayer.Changed:Connect(function()
			repeat wait()
				pcall(function()
					Util:Tween(Healthbar.buttonShadow,{Size = UDim2.new(0,(140/100)*Players[SelectedPlayer.Value].Character.Humanoid.Health,1,0)},0.25)
				end)
			until not SelectedPlayer.Value or SelectedPlayer.Value == ""
		end)



		SelectedPlayer.Changed:Connect(function()
			if table.find(getgenv().Whitelisted,tostring(SelectedPlayer.Value)) then
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut,{BackgroundColor3 = Color3.fromRGB(0,170,126)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(0,113,84)},0.3)
			else
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut,{BackgroundColor3 = Color3.fromRGB(254, 86, 86)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.WhitelistBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(161, 59, 60)},0.3)
			end
			if table.find(getgenv().Targets,tostring(SelectedPlayer.Value)) then
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut,{BackgroundColor3 = Color3.fromRGB(0,170,126)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(0,113,84)},0.3)
			else
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut,{BackgroundColor3 = Color3.fromRGB(254, 86, 86)},0.3)
				Util:Tween(PlayerPopup.ForPlayers.ScrollingFrame.TargetBut.buttonShadow,{BackgroundColor3 = Color3.fromRGB(161, 59, 60)},0.3)
			end
		end)
	end
	coroutine.wrap(QHCOSQZ_fake_script)()

	local OptionInstance = {
		["ImageLabel_1"] = Instance.new("ImageLabel"),
		["Frame_3"] = Instance.new("Frame"),
		["UICorner_7"] = Instance.new("UICorner"),
		["TextLabel_2"] = Instance.new("TextLabel"),
		["UICorner_9"] = Instance.new("UICorner"),
		["UICorner_6"] = Instance.new("UICorner"),
		["TextLabel_6"] = Instance.new("TextLabel"),
		["Frame_10"] = Instance.new("Frame"),
		["Frame_2"] = Instance.new("Frame"),
		["UIListLayout_3"] = Instance.new("UIListLayout"),
		["LocalScript_3"] = Instance.new("LocalScript"),
		["Frame_8"] = Instance.new("Frame"),
		["Frame_13"] = Instance.new("Frame"),
		["Frame_1"] = Instance.new("Frame"),
		["TextButton_4"] = Instance.new("TextButton"),
		["TextLabel_4"] = Instance.new("TextLabel"),
		["Frame_11"] = Instance.new("Frame"),
		["UICorner_10"] = Instance.new("UICorner"),
		["UIListLayout_1"] = Instance.new("UIListLayout"),
		["UICorner_5"] = Instance.new("UICorner"),
		["LocalScript_7"] = Instance.new("LocalScript"),
		["UICorner_4"] = Instance.new("UICorner"),
		["TextButton_2"] = Instance.new("TextButton"),
		["UICorner_13"] = Instance.new("UICorner"),
		["Frame_5"] = Instance.new("Frame"),
		["TextLabel_3"] = Instance.new("TextLabel"),
		["UICorner_11"] = Instance.new("UICorner"),
		["TextLabel_1"] = Instance.new("TextLabel"),
		["LocalScript_6"] = Instance.new("LocalScript"),
		["UIPadding_1"] = Instance.new("UIPadding"),
		["LocalScript_4"] = Instance.new("LocalScript"),
		["Frame_9"] = Instance.new("Frame"),
		["UIStroke_3"] = Instance.new("UIStroke"),
		["Frame_12"] = Instance.new("Frame"),
		["UIPadding_2"] = Instance.new("UIPadding"),
		["UICorner_3"] = Instance.new("UICorner"),
		["UICorner_1"] = Instance.new("UICorner"),
		["ImageLabel_2"] = Instance.new("ImageLabel"),
		["UIStroke_2"] = Instance.new("UIStroke"),
		["Frame_7"] = Instance.new("Frame"),
		["UIStroke_1"] = Instance.new("UIStroke"),
		["UICorner_12"] = Instance.new("UICorner"),
		["UICorner_8"] = Instance.new("UICorner"),
		["TextLabel_5"] = Instance.new("TextLabel"),
		["Frame_6"] = Instance.new("Frame"),
		["LocalScript_5"] = Instance.new("LocalScript"),
		["LocalScript_1"] = Instance.new("LocalScript"),
		["Frame_4"] = Instance.new("Frame"),
		["TextButton_3"] = Instance.new("TextButton"),
		["LocalScript_2"] = Instance.new("LocalScript"),
		["UIListLayout_2"] = Instance.new("UIListLayout"),
		["TextButton_1"] = Instance.new("TextButton"),
		["ScrollingFrame_2"] = Instance.new("ScrollingFrame"),
		["UICorner_2"] = Instance.new("UICorner"),
		["Frame_14"] = Instance.new("Frame"),
	}

	OptionInstance.ScrollingFrame_2.Parent = instances.Folder_1
	OptionInstance.ScrollingFrame_2.CanvasSize = UDim2.new(0, 0, 0, 550)
	OptionInstance.ScrollingFrame_2.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	OptionInstance.ScrollingFrame_2.ScrollBarThickness = 0
	OptionInstance.ScrollingFrame_2.Active = true
	OptionInstance.ScrollingFrame_2.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.ScrollingFrame_2.BackgroundTransparency = 1
	OptionInstance.ScrollingFrame_2.BorderSizePixel = 0
	OptionInstance.ScrollingFrame_2.Size = UDim2.new(1, 0, 1, 0)
	OptionInstance.ScrollingFrame_2.Visible = false
	OptionInstance.ScrollingFrame_2.Name = 'Settings'

	OptionInstance.UIPadding_1.Parent = OptionInstance.ScrollingFrame_2
	OptionInstance.UIPadding_1.PaddingLeft = UDim.new(0, 15)
	OptionInstance.UIPadding_1.PaddingTop = UDim.new(0, 15)

	OptionInstance.UIListLayout_1.Parent = OptionInstance.ScrollingFrame_2
	OptionInstance.UIListLayout_1.Padding = UDim.new(0, 15)
	OptionInstance.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

	OptionInstance.Frame_1.Parent = OptionInstance.ScrollingFrame_2
	OptionInstance.Frame_1.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
	OptionInstance.Frame_1.Position = UDim2.new(0, 0, -0.5136986374855042, 0)
	OptionInstance.Frame_1.Size = UDim2.new(0, 301, 0, 202)
	OptionInstance.Frame_1.Name = 'Section'

	OptionInstance.Frame_2.Parent = OptionInstance.Frame_1
	OptionInstance.Frame_2.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
	OptionInstance.Frame_2.LayoutOrder = 2
	OptionInstance.Frame_2.Position = UDim2.new(0, 0, 0, 30)
	OptionInstance.Frame_2.Size = UDim2.new(0, 301, 0, 137)
	OptionInstance.Frame_2.Name = 'Workspace'

	OptionInstance.Frame_3.Parent = OptionInstance.Frame_2
	OptionInstance.Frame_3.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.Frame_3.BackgroundTransparency = 1
	OptionInstance.Frame_3.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	OptionInstance.Frame_3.LayoutOrder = 3
	OptionInstance.Frame_3.Size = UDim2.new(0, 283, 0, 34)
	OptionInstance.Frame_3.Name = 'Button'

	OptionInstance.TextButton_1.Parent = OptionInstance.Frame_3
	OptionInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextButton_1.Text = ''
	OptionInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	OptionInstance.TextButton_1.TextSize = 18
	OptionInstance.TextButton_1.AnchorPoint = Vector2.new(0.5, 0.5)
	OptionInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	OptionInstance.TextButton_1.BorderSizePixel = 0
	OptionInstance.TextButton_1.LayoutOrder = 3
	OptionInstance.TextButton_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	OptionInstance.TextButton_1.Size = UDim2.new(1, 0, 1, 0)
	OptionInstance.TextButton_1.AutoButtonColor = false
	OptionInstance.TextButton_1.Name = 'AntiFallButton'

	OptionInstance.UICorner_1.Parent = OptionInstance.TextButton_1
	OptionInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

	OptionInstance.Frame_4.Parent = OptionInstance.TextButton_1
	OptionInstance.Frame_4.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
	OptionInstance.Frame_4.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
	OptionInstance.Frame_4.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
	OptionInstance.Frame_4.Name = 'buttonShadow'

	OptionInstance.UICorner_2.Parent = OptionInstance.Frame_4
	OptionInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

	OptionInstance.TextLabel_1.Parent = OptionInstance.TextButton_1
	OptionInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextLabel_1.Text = 'Destroy UI'
	OptionInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	OptionInstance.TextLabel_1.TextSize = 18
	OptionInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
	OptionInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextLabel_1.BackgroundTransparency = 1
	OptionInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
	OptionInstance.TextLabel_1.Size = UDim2.new(0.8021202683448792, 0, 1, 0)

	OptionInstance.ImageLabel_1.Parent = OptionInstance.TextButton_1
	OptionInstance.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031229361'
	OptionInstance.ImageLabel_1.BackgroundTransparency = 1
	OptionInstance.ImageLabel_1.BorderSizePixel = 0
	OptionInstance.ImageLabel_1.Position = UDim2.new(0.9151942729949951, 0, 0.20588237047195435, 0)
	OptionInstance.ImageLabel_1.Size = UDim2.new(0, 19, 0, 19)

	OptionInstance.Frame_5.Parent = OptionInstance.TextButton_1
	OptionInstance.Frame_5.AnchorPoint = Vector2.new(0.5, 0.5)
	OptionInstance.Frame_5.BackgroundColor3 = Color3.new(0, 0, 0)
	OptionInstance.Frame_5.BackgroundTransparency = 1
	OptionInstance.Frame_5.ClipsDescendants = true
	OptionInstance.Frame_5.Position = UDim2.new(0.5, 0, 0.5, 0)
	OptionInstance.Frame_5.Size = UDim2.new(1, 0, 1, 0)
	OptionInstance.Frame_5.Name = 'Background'

	OptionInstance.UICorner_3.Parent = OptionInstance.Frame_5
	OptionInstance.UICorner_3.CornerRadius = UDim.new(0, 4)
	OptionInstance.UICorner_3.Name = 'CornerRadius'

	OptionInstance.UIStroke_1.Parent = OptionInstance.Frame_5
	OptionInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	OptionInstance.UIStroke_1.Thickness = 0
	OptionInstance.UIStroke_1.Transparency = 0.5
	OptionInstance.UIStroke_1.Name = 'Border'

	OptionInstance.LocalScript_1.Parent = OptionInstance.TextButton_1
	OptionInstance.LocalScript_1.Name = 'RippleEffect'

	OptionInstance.LocalScript_2.Parent = OptionInstance.TextButton_1
	OptionInstance.LocalScript_2.Disabled = true

	OptionInstance.UIListLayout_2.Parent = OptionInstance.Frame_2
	OptionInstance.UIListLayout_2.Padding = UDim.new(0, 5)
	OptionInstance.UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

	OptionInstance.UICorner_4.Parent = OptionInstance.Frame_2
	OptionInstance.UICorner_4.CornerRadius = UDim.new(0, 4)

	OptionInstance.UIPadding_2.Parent = OptionInstance.Frame_2
	OptionInstance.UIPadding_2.PaddingLeft = UDim.new(0, 9)

	OptionInstance.UICorner_6.Parent = OptionInstance.Frame_7
	OptionInstance.UICorner_6.CornerRadius = UDim.new(0, 4)

	OptionInstance.UICorner_7.Parent = OptionInstance.Frame_8
	OptionInstance.UICorner_7.CornerRadius = UDim.new(0, 4)
	OptionInstance.UICorner_7.Name = 'CornerRadius'

	OptionInstance.UIStroke_2.Parent = OptionInstance.Frame_8
	OptionInstance.UIStroke_2.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	OptionInstance.UIStroke_2.Thickness = 0
	OptionInstance.UIStroke_2.Transparency = 0.5
	OptionInstance.UIStroke_2.Name = 'Border'

	OptionInstance.Frame_9.Parent = OptionInstance.Frame_2
	OptionInstance.Frame_9.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.Frame_9.BackgroundTransparency = 1
	OptionInstance.Frame_9.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	OptionInstance.Frame_9.LayoutOrder = 2
	OptionInstance.Frame_9.Size = UDim2.new(0, 283, 0, 34)
	OptionInstance.Frame_9.Name = 'Keybind'


	OptionInstance.TextButton_3.Parent = OptionInstance.Frame_9
	OptionInstance.TextButton_3.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextButton_3.Text = ''
	OptionInstance.TextButton_3.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
	OptionInstance.TextButton_3.TextSize = 18
	OptionInstance.TextButton_3.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	OptionInstance.TextButton_3.BorderSizePixel = 0
	OptionInstance.TextButton_3.LayoutOrder = 2
	OptionInstance.TextButton_3.Size = UDim2.new(1, 0, 1, 0)
	OptionInstance.TextButton_3.AutoButtonColor = false
	OptionInstance.TextButton_3.Name = 'KeybindButton'


	OptionInstance.UICorner_8.Parent = OptionInstance.TextButton_3
	OptionInstance.UICorner_8.CornerRadius = UDim.new(0, 4)

	OptionInstance.TextLabel_3.Parent = OptionInstance.TextButton_3
	OptionInstance.TextLabel_3.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextLabel_3.Text = 'Toggle UI'
	OptionInstance.TextLabel_3.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	OptionInstance.TextLabel_3.TextSize = 18
	OptionInstance.TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left
	OptionInstance.TextLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextLabel_3.BackgroundTransparency = 1
	OptionInstance.TextLabel_3.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
	OptionInstance.TextLabel_3.Size = UDim2.new(0.5441696047782898, 0, 1, 0)

	OptionInstance.Frame_10.Parent = OptionInstance.TextButton_3
	OptionInstance.Frame_10.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
	OptionInstance.Frame_10.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
	OptionInstance.Frame_10.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
	OptionInstance.Frame_10.Name = 'buttonShadow'

	OptionInstance.UICorner_9.Parent = OptionInstance.Frame_10
	OptionInstance.UICorner_9.CornerRadius = UDim.new(0, 4)

	OptionInstance.LocalScript_5.Parent = OptionInstance.TextButton_3
	OptionInstance.LocalScript_5.Name = 'RippleEffect'

	OptionInstance.Frame_11.Parent = OptionInstance.TextButton_3
	OptionInstance.Frame_11.AnchorPoint = Vector2.new(0.5, 0.5)
	OptionInstance.Frame_11.BackgroundColor3 = Color3.new(0, 0, 0)
	OptionInstance.Frame_11.BackgroundTransparency = 1
	OptionInstance.Frame_11.ClipsDescendants = true
	OptionInstance.Frame_11.Position = UDim2.new(0.5, 0, 0.5, 0)
	OptionInstance.Frame_11.Size = UDim2.new(1, 0, 1, 0)
	OptionInstance.Frame_11.Name = 'Background'

	OptionInstance.UICorner_10.Parent = OptionInstance.Frame_11
	OptionInstance.UICorner_10.CornerRadius = UDim.new(0, 4)
	OptionInstance.UICorner_10.Name = 'CornerRadius'

	OptionInstance.UIStroke_3.Parent = OptionInstance.Frame_11
	OptionInstance.UIStroke_3.Color = Color3.new(0.0980392, 0.462745, 0.823529)
	OptionInstance.UIStroke_3.Thickness = 0
	OptionInstance.UIStroke_3.Transparency = 0.5
	OptionInstance.UIStroke_3.Name = 'Border'

	OptionInstance.TextButton_4.Parent = OptionInstance.TextButton_3
	OptionInstance.TextButton_4.Font = Enum.Font.SourceSans
	OptionInstance.TextButton_4.Text = ''
	OptionInstance.TextButton_4.TextColor3 = Color3.new(0, 0, 0)
	OptionInstance.TextButton_4.TextSize = 14
	OptionInstance.TextButton_4.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextButton_4.BackgroundTransparency = 1
	OptionInstance.TextButton_4.BorderSizePixel = 0
	OptionInstance.TextButton_4.Position = UDim2.new(0.8409894108772278, 0, 0, 0)
	OptionInstance.TextButton_4.Size = UDim2.new(0, 45, 0, 32)

	OptionInstance.TextLabel_4.Parent = OptionInstance.TextButton_4
	OptionInstance.TextLabel_4.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextLabel_4.Text = 'P'
	OptionInstance.TextLabel_4.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	OptionInstance.TextLabel_4.TextScaled = true
	OptionInstance.TextLabel_4.TextSize = 18
	OptionInstance.TextLabel_4.TextWrapped = true
	OptionInstance.TextLabel_4.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextLabel_4.BackgroundTransparency = 1
	OptionInstance.TextLabel_4.Position = UDim2.new(0, 17, 0, 3)
	OptionInstance.TextLabel_4.Size = UDim2.new(0, 26, 0, 26)

	OptionInstance.LocalScript_6.Parent = OptionInstance.TextButton_3
	OptionInstance.LocalScript_6.Disabled = true

	OptionInstance.Frame_12.Parent = OptionInstance.Frame_2
	OptionInstance.Frame_12.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.Frame_12.BackgroundTransparency = 1
	OptionInstance.Frame_12.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	OptionInstance.Frame_12.LayoutOrder = 100
	OptionInstance.Frame_12.Position = UDim2.new(0, 0, 0.5945122241973877, 0)
	OptionInstance.Frame_12.Size = UDim2.new(0, 283, 0, 24)
	OptionInstance.Frame_12.Name = 'Label'

	OptionInstance.Frame_13.Parent = OptionInstance.Frame_12
	OptionInstance.Frame_13.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	OptionInstance.Frame_13.BackgroundTransparency = 1
	OptionInstance.Frame_13.Size = UDim2.new(1, 0, 1, 0)

	OptionInstance.TextLabel_5.Parent = OptionInstance.Frame_13
	OptionInstance.TextLabel_5.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextLabel_5.Text = 'Made by Investor Doge'
	OptionInstance.TextLabel_5.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	OptionInstance.TextLabel_5.TextSize = 18
	OptionInstance.TextLabel_5.TextWrapped = true
	OptionInstance.TextLabel_5.TextXAlignment = Enum.TextXAlignment.Left
	OptionInstance.TextLabel_5.TextYAlignment = Enum.TextYAlignment.Top
	OptionInstance.TextLabel_5.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextLabel_5.BackgroundTransparency = 1
	OptionInstance.TextLabel_5.Size = UDim2.new(1, 0, 1.7083333730697632, 0)

	OptionInstance.UICorner_11.Parent = OptionInstance.Frame_13
	OptionInstance.UICorner_11.CornerRadius = UDim.new(0, 4)

	OptionInstance.LocalScript_7.Parent = OptionInstance.Frame_2

	OptionInstance.UICorner_12.Parent = OptionInstance.Frame_1
	OptionInstance.UICorner_12.CornerRadius = UDim.new(0, 4)

	OptionInstance.UIListLayout_3.Parent = OptionInstance.Frame_1
	OptionInstance.UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

	OptionInstance.Frame_14.Parent = OptionInstance.Frame_1
	OptionInstance.Frame_14.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
	OptionInstance.Frame_14.LayoutOrder = 1
	OptionInstance.Frame_14.Position = UDim2.new(0, 0, 0, 49)
	OptionInstance.Frame_14.Size = UDim2.new(0, 301, 0, 30)
	OptionInstance.Frame_14.Name = 'Top'

	OptionInstance.UICorner_13.Parent = OptionInstance.Frame_14
	OptionInstance.UICorner_13.CornerRadius = UDim.new(0, 4)

	OptionInstance.TextLabel_6.Parent = OptionInstance.Frame_14
	OptionInstance.TextLabel_6.Font = Enum.Font.SourceSansSemibold
	OptionInstance.TextLabel_6.Text = 'Settings'
	OptionInstance.TextLabel_6.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
	OptionInstance.TextLabel_6.TextSize = 18
	OptionInstance.TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left
	OptionInstance.TextLabel_6.BackgroundColor3 = Color3.new(1, 1, 1)
	OptionInstance.TextLabel_6.BackgroundTransparency = 1
	OptionInstance.TextLabel_6.Position = UDim2.new(0.029900332912802696, 0, 0, 0)
	OptionInstance.TextLabel_6.Size = UDim2.new(0.8852940797805786, 0, 1, 0)
	OptionInstance.TextLabel_6.Name = 'Title'

	local Main = OptionInstance.TextButton_3
	local ChangeBind = Main.TextButton
	local Label = ChangeBind.TextLabel


	local Key = Enum.KeyCode.P
	local Listening = false
	game:GetService("UserInputService").InputBegan:Connect(function(Input, IsTyping)
		if IsTyping then return end
		if Input.KeyCode == Key then
			Util:ToggleUI(screenGui)
		end
		if Listening == true then
			if not table.find(BlacklistedKeys,Input.KeyCode) then
				Key = Input.KeyCode
			else
				Key = Enum.KeyCode.P
			end

			Listening = false
			if Key.Name == "LeftControl" then
				Label.Text = "LControl"
			elseif Key.Name == "RightControl" then
				Label.Text = "RControl"
			elseif Key.Name == "LeftShift" then
				Label.Text = "LShift"
			elseif Key.Name == "RightShift" then
				Label.Text = "RShift"
			elseif table.find(NumberIndex,Key.Name) then
				Label.Text = tostring(Numbers[Key.Name])
			else
				Label.Text = Key.Name
			end

		end
	end)

	ChangeBind.MouseButton1Click:Connect(function()
		Listening = true
		Label.Text = ".."
	end)

	OptionInstance.TextButton_1.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	OptionInstance.TextButton_3.MouseEnter:Connect(function()
		Util:Tween(OptionInstance.TextButton_3.Background,{BackgroundTransparency = 0.8},0.2)
	end)
	OptionInstance.TextButton_3.MouseLeave:Connect(function()
		Util:Tween(OptionInstance.TextButton_3.Background,{BackgroundTransparency = 1},0.2)
	end)
	OptionInstance.TextButton_1.MouseEnter:Connect(function()
		Util:Tween(OptionInstance.TextButton_1.Background,{BackgroundTransparency = 0.8},0.2)
	end)
	OptionInstance.TextButton_1.MouseLeave:Connect(function()
		Util:Tween(OptionInstance.TextButton_1.Background,{BackgroundTransparency = 1},0.2)
	end)


	instances.TextButton_2.MouseButton1Click:Connect(function()
		for i,v in next, instances.Folder_1:GetChildren() do
			v.Visible = false
		end 
		OptionInstance.ScrollingFrame_2.Visible = true

		for i,v in pairs(instances.ScrollingFrame_1:GetChildren()) do
			if v:IsA("TextButton") then
				Util:Tween(v, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)},0.2)
				Util:Tween(v.buttonShadow, {BackgroundColor3 = Color3.fromRGB(71, 71, 71)},0.2)
			end
		end
		Util:Tween(instances.TextButton_2, {BackgroundColor3 = Color3.fromRGB(0, 170, 126)},0.2)
		Util:Tween(instances.TextButton_2.buttonShadow, {BackgroundColor3 = Color3.fromRGB(0, 134, 84)},0.2)
	end)

	local Button =  instances.TextButton_1
	local Image = Button.ImageLabel

	local Opened = true

	local PageButtonHolder = Button.Parent.Parent.Parent.PageButtonHolders

	local function Clicked()
		if Opened then
			Opened = false
			Util:Tween(PageButtonHolder,{Position = UDim2.new(0, 10,0, 0)},0.2)
			Util:Tween(Image,{Rotation = 180},0.2)
		else
			Opened = true
			Util:Tween(PageButtonHolder,{Position = UDim2.new(0, -133,0, 0)},0.2)
			Util:Tween(Image,{Rotation = 0},0.2)
		end
	end


	Button.MouseEnter:Connect(function()
		Util:Tween(Image,{ImageColor3 = Color3.fromRGB(160,160,160)},0.2)
	end)


	Button.MouseLeave:Connect(function()
		Util:Tween(Image,{ImageColor3 = Color3.fromRGB(255,255,255)},0.2)
	end)

	Button.MouseButton1Click:Connect(function()
		Clicked()
	end)


	local TabHandler = {}

	function TabHandler:CreateTab(config)
		local tabname = config.Title or "New Tab"
		local ScrollBar = config.ScrollBar or config.scrollbar or config.Scroll or config.scroll or false
		local ButtonImage = config.Image or config.image or "rbxassetid://3926305904"

		local uiPadding = Instance.new("UIPadding")
		local TabInstance = {
			["TextLabel_1"] = Instance.new("TextLabel"),
			["Frame_2"] = Instance.new("Frame"),
			["UIStroke_1"] = Instance.new("UIStroke"),
			["Frame_3"] = Instance.new("Frame"),
			["UIListLayout_1"] = Instance.new("UIListLayout"),
			["TextButton_1"] = Instance.new("TextButton"),
			["UICorner_2"] = Instance.new("UICorner"),
			["UICorner_3"] = Instance.new("UICorner"),
			["UIPadding_1"] = Instance.new("UIPadding"),
			["LocalScript_1"] = Instance.new("LocalScript"),
			["UICorner_4"] = Instance.new("UICorner"),
			["ScrollingFrame_1"] = Instance.new("ScrollingFrame"),
			["Frame_1"] = Instance.new("Frame"),
			["UICorner_1"] = Instance.new("UICorner"),
		}

		TabInstance.TextButton_1.Parent = instances.ScrollingFrame_1
		TabInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
		TabInstance.TextButton_1.Text = ''
		TabInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
		TabInstance.TextButton_1.TextSize = 18
		TabInstance.TextButton_1.BackgroundColor3 = Color3.new(0, 0.666667, 0.494118)
		TabInstance.TextButton_1.BorderSizePixel = 0
		TabInstance.TextButton_1.Position = UDim2.new(0.0714285746216774, 0, -0.002994012087583542, 0)
		TabInstance.TextButton_1.Size = UDim2.new(0, 117, 0, 32)
		TabInstance.TextButton_1.AutoButtonColor = false
		TabInstance.TextButton_1.Name = tostring(tabname)

		TabInstance.UICorner_1.Parent = TabInstance.TextButton_1
		TabInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

		TabInstance.Frame_1.Parent = TabInstance.TextButton_1
		TabInstance.Frame_1.BackgroundColor3 = Color3.new(0, 0.52549, 0.329412)
		TabInstance.Frame_1.Position = UDim2.new(0, 0, 0.9285714030265808, 0)
		TabInstance.Frame_1.Size = UDim2.new(1, 0, 0.0714285746216774, 0)
		TabInstance.Frame_1.Name = 'buttonShadow'

		TabInstance.UICorner_2.Parent = TabInstance.Frame_1
		TabInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

		TabInstance.Frame_2.Parent = TabInstance.TextButton_1
		TabInstance.Frame_2.BackgroundColor3 = Color3.new(0, 0, 0)
		TabInstance.Frame_2.BackgroundTransparency = 1
		TabInstance.Frame_2.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
		TabInstance.Frame_2.BorderSizePixel = 0
		TabInstance.Frame_2.Size = UDim2.new(1, 0, 1, 0)
		TabInstance.Frame_2.Name = 'Shadow'

		TabInstance.UICorner_3.Parent = TabInstance.Frame_2
		TabInstance.UICorner_3.CornerRadius = UDim.new(0, 4)

		TabInstance.TextLabel_1.Parent = TabInstance.TextButton_1
		TabInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
		TabInstance.TextLabel_1.Text = tostring(tabname)
		TabInstance.TextLabel_1.TextColor3 = Color3.new(1, 1, 1)
		TabInstance.TextLabel_1.TextSize = 18
		TabInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
		TabInstance.TextLabel_1.BackgroundTransparency = 1
		TabInstance.TextLabel_1.Size = UDim2.new(1, 0, 1, 0)
		TabInstance.TextLabel_1.ZIndex = 1


		TabInstance.Frame_3.Parent = TabInstance.TextButton_1
		TabInstance.Frame_3.AnchorPoint = Vector2.new(0.5, 0.5)
		TabInstance.Frame_3.BackgroundColor3 = Color3.new(0, 0, 0)
		TabInstance.Frame_3.BackgroundTransparency = 1
		TabInstance.Frame_3.ClipsDescendants = true
		TabInstance.Frame_3.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabInstance.Frame_3.Size = UDim2.new(1, 0, 1, 0)
		TabInstance.Frame_3.Name = 'Background'
		Util:Ripple(TabInstance.TextButton_1)

		TabInstance.UICorner_4.Parent = TabInstance.Frame_3
		TabInstance.UICorner_4.CornerRadius = UDim.new(0, 4)
		TabInstance.UICorner_4.Name = 'CornerRadius'

		TabInstance.UIStroke_1.Parent = TabInstance.Frame_3
		TabInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
		TabInstance.UIStroke_1.Thickness = 0
		TabInstance.UIStroke_1.Transparency = 0.5
		TabInstance.UIStroke_1.Name = 'Border'

		TabInstance.ScrollingFrame_1.Parent = instances.Folder_1
		TabInstance.ScrollingFrame_1.CanvasSize = UDim2.new(0, 0, 0, 550)
		TabInstance.ScrollingFrame_1.ScrollBarImageColor3 = Color3.new(255,255,255)
		TabInstance.ScrollingFrame_1.ScrollBarThickness = 12
		TabInstance.ScrollingFrame_1.Active = true
		TabInstance.ScrollingFrame_1.BackgroundColor3 = Color3.new(1, 1, 1)
		TabInstance.ScrollingFrame_1.BackgroundTransparency = 1
		TabInstance.ScrollingFrame_1.BorderSizePixel = 0
		TabInstance.ScrollingFrame_1.Size = UDim2.new(1, 0, 1, 0)
		TabInstance.ScrollingFrame_1.Name = 'Page'
		TabInstance.ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.Y
		TabInstance.ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		if ScrollBar == false then
			TabInstance.ScrollingFrame_1.ScrollBarThickness = 0
		end

		TabInstance.UIPadding_1.Parent = TabInstance.ScrollingFrame_1
		TabInstance.UIPadding_1.PaddingLeft = UDim.new(0, 15)
		TabInstance.UIPadding_1.PaddingTop = UDim.new(0, 15)

		TabInstance.UIListLayout_1.Parent = TabInstance.ScrollingFrame_1
		TabInstance.UIListLayout_1.Padding = UDim.new(0, 15)
		TabInstance.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder


		local newPage = TabInstance.ScrollingFrame_1
		newPage.Visible = false

		newPage:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local size = newPage:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize
			local padding = newPage:FindFirstChildOfClass("UIListLayout").Parent.UIPadding

			size = size + Vector2.new(0, padding.PaddingBottom.Offset + (padding.PaddingTop.Offset))
			Util:Tween(newPage,{CanvasSize = UDim2.new(1, 0, 0, size.Y + 80)},0.1)

		end)

		if #instances.ScrollingFrame_1:GetChildren() == 3 then
			Util:Tween(TabInstance.TextButton_1, {BackgroundColor3 = Color3.fromRGB(0, 170, 126)},0.2)
			Util:Tween(TabInstance.TextButton_1.buttonShadow, {BackgroundColor3 = Color3.fromRGB(0, 134, 84)},0.2)
			TabInstance.ScrollingFrame_1.Visible = true
		else
			Util:Tween(TabInstance.TextButton_1, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)},0.2)
			Util:Tween(TabInstance.TextButton_1.buttonShadow, {BackgroundColor3 = Color3.fromRGB(71, 71, 71)},0.2)
			TabInstance.ScrollingFrame_1.Visible = false
		end

		TabInstance.TextButton_1.MouseEnter:Connect(function()
			Util:Tween(TabInstance.TextButton_1.Background,{BackgroundTransparency = 0.8},0.2)
		end)
		TabInstance.TextButton_1.MouseLeave:Connect(function()
			Util:Tween(TabInstance.TextButton_1.Background,{BackgroundTransparency = 1},0.2)
		end)

		TabInstance.TextButton_1.MouseButton1Click:Connect(function()
			for i,v in next, instances.Folder_1:GetChildren() do
				v.Visible = false
			end 
			TabInstance.ScrollingFrame_1.Visible = true

			for i,v in pairs(instances.ScrollingFrame_1.Parent:GetDescendants()) do
				if v:IsA("TextButton") then
					Util:Tween(v, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)},0.2)
					Util:Tween(v.buttonShadow, {BackgroundColor3 = Color3.fromRGB(71, 71, 71)},0.2)
				end
			end
			Util:Tween(TabInstance.TextButton_1, {BackgroundColor3 = Color3.fromRGB(0, 170, 126)},0.2)
			Util:Tween(TabInstance.TextButton_1.buttonShadow, {BackgroundColor3 = Color3.fromRGB(0, 134, 84)},0.2)
		end)



		local SectionHandler = {}

		function SectionHandler:CreateSection(config, callback)
			local Title = config.Title or config.title or config.text or config.Text or "Untitled!"
			local OrderNumber = config.Order or config.order or 20

			local SectionInstance = {
				["UICorner_2"] = Instance.new("UICorner"),
				["Frame_3"] = Instance.new("Frame"),
				["Frame_1"] = Instance.new("Frame"),
				["TextLabel_1"] = Instance.new("TextLabel"),
				["LocalScript_1"] = Instance.new("LocalScript"),
				["UICorner_3"] = Instance.new("UICorner"),
				["Frame_2"] = Instance.new("Frame"),
				["UIListLayout_2"] = Instance.new("UIListLayout"),
				["UIPadding_1"] = Instance.new("UIPadding"),
				["UICorner_1"] = Instance.new("UICorner"),
				["UIListLayout_1"] = Instance.new("UIListLayout"),
			}


			SectionInstance.Frame_1.Parent = newPage
			SectionInstance.Frame_1.AutomaticSize = Enum.AutomaticSize.None
			SectionInstance.Frame_1.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
			SectionInstance.Frame_1.Position = UDim2.new(0, 0, -0.5136986374855042, 0)
			SectionInstance.Frame_1.Size = UDim2.new(0, 301, 0, 30)
			SectionInstance.Frame_1.Name = 'Section'
			SectionInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

			SectionInstance.Frame_2.Parent = SectionInstance.Frame_1
			SectionInstance.Frame_2.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
			SectionInstance.Frame_2.LayoutOrder = 2
			SectionInstance.Frame_2.Position = UDim2.new(0, 0, 0, 30)
			SectionInstance.Frame_2.Size = UDim2.new(0, 301, 0, 0)
			SectionInstance.Frame_2.Name = 'Workspace'

			SectionInstance.UIListLayout_1.Parent = SectionInstance.Frame_2
			SectionInstance.UIListLayout_1.Padding = UDim.new(0, 5)
			SectionInstance.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

			SectionInstance.UICorner_1.Parent = SectionInstance.Frame_2
			SectionInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

			SectionInstance.UIPadding_1.Parent = SectionInstance.Frame_2
			SectionInstance.UIPadding_1.PaddingLeft = UDim.new(0, 9)

			SectionInstance.LocalScript_1.Parent = SectionInstance.Frame_2

			SectionInstance.UICorner_2.Parent = SectionInstance.Frame_1
			SectionInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

			SectionInstance.UIListLayout_2.Parent = SectionInstance.Frame_1
			SectionInstance.UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

			SectionInstance.Frame_3.Parent = SectionInstance.Frame_1
			SectionInstance.Frame_3.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
			SectionInstance.Frame_3.LayoutOrder = 1
			SectionInstance.Frame_3.Position = UDim2.new(0, 0, 0, 49)
			SectionInstance.Frame_3.Size = UDim2.new(0, 301, 0, 30)
			SectionInstance.Frame_3.Name = 'Top'

			SectionInstance.UICorner_3.Parent = SectionInstance.Frame_3
			SectionInstance.UICorner_3.CornerRadius = UDim.new(0, 4)

			SectionInstance.TextLabel_1.Parent = SectionInstance.Frame_3
			SectionInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
			SectionInstance.TextLabel_1.Text = tostring(Title)
			SectionInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
			SectionInstance.TextLabel_1.TextSize = 18
			SectionInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
			SectionInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
			SectionInstance.TextLabel_1.BackgroundTransparency = 1
			SectionInstance.TextLabel_1.Position = UDim2.new(0.029900332912802696, 0, 0, 0)
			SectionInstance.TextLabel_1.Size = UDim2.new(0.8852940797805786, 0, 1, 0)
			SectionInstance.TextLabel_1.Name = tostring(Title)

			local FWorkspace = SectionInstance.Frame_2
			local Section = FWorkspace.Parent

			FWorkspace:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if FWorkspace:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y > FWorkspace.Size.Y.Offset then
					if FWorkspace:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y - FWorkspace.Size.Y.Offset < 9 then
						return
					end
				else
					if FWorkspace.Size.Y.Offset - FWorkspace:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y < 9 then
						return
					end
				end
				local size = FWorkspace:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize
				local padding = FWorkspace:FindFirstChildOfClass("UIListLayout").Parent.UIPadding

				size = size + Vector2.new(0, padding.PaddingBottom.Offset + (padding.PaddingTop.Offset))
				Util:Tween(Section,{Size = UDim2.new(0, 301, 0, size.Y + 42)},0.1)
				Util:Tween(FWorkspace,{Size = UDim2.new(0, 301, 0, size.Y + 2)},0.1)

			end)


			local ElementHandler = {}

			function ElementHandler:CreateButton(config)
				local btnText = config.Title or config.title or config.text or config.Text or "Text Button!"
				local callback = config.callback or config.Callback or function() end   

				local OrderNumber = config.Order or config.order or 20

				local ButtonInstance = {
					["LocalScript_2"] = Instance.new("LocalScript"),
					["Frame_3"] = Instance.new("Frame"),
					["ImageLabel_1"] = Instance.new("ImageLabel"),
					["UICorner_1"] = Instance.new("UICorner"),
					["Frame_2"] = Instance.new("Frame"),
					["TextButton_1"] = Instance.new("TextButton"),
					["TextLabel_1"] = Instance.new("TextLabel"),
					["LocalScript_1"] = Instance.new("LocalScript"),
					["UIStroke_1"] = Instance.new("UIStroke"),
					["Frame_1"] = Instance.new("Frame"),
					["UICorner_3"] = Instance.new("UICorner"),
					["UICorner_2"] = Instance.new("UICorner"),
				}

				ButtonInstance.Frame_1.Parent =  SectionInstance.Frame_2
				ButtonInstance.Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
				ButtonInstance.Frame_1.BackgroundTransparency = 1
				ButtonInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				ButtonInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				ButtonInstance.Frame_1.Name = tostring(btnText)
				ButtonInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				ButtonInstance.TextButton_1.Parent = ButtonInstance.Frame_1
				ButtonInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
				ButtonInstance.TextButton_1.Text = ''
				ButtonInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
				ButtonInstance.TextButton_1.TextSize = 18
				ButtonInstance.TextButton_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ButtonInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				ButtonInstance.TextButton_1.BorderSizePixel = 0
				ButtonInstance.TextButton_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				ButtonInstance.TextButton_1.Size = UDim2.new(1, 0, 1, 0)
				ButtonInstance.TextButton_1.AutoButtonColor = false
				ButtonInstance.TextButton_1.Name = 'AntiFallButton'

				ButtonInstance.UICorner_1.Parent = ButtonInstance.TextButton_1
				ButtonInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				ButtonInstance.Frame_2.Parent = ButtonInstance.TextButton_1
				ButtonInstance.Frame_2.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				ButtonInstance.Frame_2.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				ButtonInstance.Frame_2.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				ButtonInstance.Frame_2.Name = 'buttonShadow'

				ButtonInstance.UICorner_2.Parent = ButtonInstance.Frame_2
				ButtonInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

				ButtonInstance.TextLabel_1.Parent = ButtonInstance.TextButton_1
				ButtonInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				ButtonInstance.TextLabel_1.Text = tostring(btnText)
				ButtonInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ButtonInstance.TextLabel_1.TextSize = 18
				ButtonInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				ButtonInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				ButtonInstance.TextLabel_1.BackgroundTransparency = 1
				ButtonInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				ButtonInstance.TextLabel_1.Size = UDim2.new(0.8412331938743591, 0, 1, 0)

				ButtonInstance.ImageLabel_1.Parent = ButtonInstance.TextButton_1
				ButtonInstance.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031229361'
				ButtonInstance.ImageLabel_1.BackgroundTransparency = 1
				ButtonInstance.ImageLabel_1.BorderSizePixel = 0
				ButtonInstance.ImageLabel_1.Position = UDim2.new(0.9151942729949951, 0, 0.20588237047195435, 0)
				ButtonInstance.ImageLabel_1.Size = UDim2.new(0, 19, 0, 19)

				ButtonInstance.Frame_3.Parent = ButtonInstance.TextButton_1
				ButtonInstance.Frame_3.AnchorPoint = Vector2.new(0.5, 0.5)
				ButtonInstance.Frame_3.BackgroundColor3 = Color3.new(0, 0, 0)
				ButtonInstance.Frame_3.BackgroundTransparency = 1
				ButtonInstance.Frame_3.ClipsDescendants = true
				ButtonInstance.Frame_3.Position = UDim2.new(0.5, 0, 0.5, 0)
				ButtonInstance.Frame_3.Size = UDim2.new(1, 0, 1, 0)
				ButtonInstance.Frame_3.Name = 'Background'
				Util:Ripple(ButtonInstance.TextButton_1)

				ButtonInstance.UICorner_3.Parent = ButtonInstance.Frame_3
				ButtonInstance.UICorner_3.CornerRadius = UDim.new(0, 4)
				ButtonInstance.UICorner_3.Name = 'CornerRadius'

				ButtonInstance.UIStroke_1.Parent = ButtonInstance.Frame_3
				ButtonInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				ButtonInstance.UIStroke_1.Thickness = 0
				ButtonInstance.UIStroke_1.Transparency = 0.5
				ButtonInstance.UIStroke_1.Name = 'Border'

				local Button = ButtonInstance.TextButton_1
				local Debounce


				Button.MouseEnter:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 0.8},0.1)
				end)
				Button.MouseLeave:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 1},0.1)
				end)


				local LastClick = tick()
				Button.MouseButton1Click:Connect(function()
					if tick() - LastClick > 0.4 then
						LastClick = tick()
						if callback then
							callback()
						end
					end
				end)
			end
			function ElementHandler:updateButton(button,str)
				str = tostring(str) or "Button"
				button.TextLabel_1.Text = tostring(str)
			end
			function ElementHandler:CreateToggle(config) -- stopped and finished toggle, needs updatetoggle() though
				local btnText = config.Title or config.title or config.text or config.Text or "Toggle"
				local callback = config.callback or config.Callback or function() end   
				local OrderNumber = config.Order or config.order or 20
				local Default = config.Default or config.default or false

				local ToggleInstance = {
					["ImageLabel_1"] = Instance.new("ImageLabel"),
					["UICorner_1"] = Instance.new("UICorner"),
					["UICorner_2"] = Instance.new("UICorner"),
					["UICorner_3"] = Instance.new("UICorner"),
					["Frame_2"] = Instance.new("Frame"),
					["TextLabel_1"] = Instance.new("TextLabel"),
					["Frame_3"] = Instance.new("Frame"),
					["TextButton_1"] = Instance.new("TextButton"),
					["Frame_1"] = Instance.new("Frame"),
					["UIStroke_1"] = Instance.new("UIStroke"),
				}

				ToggleInstance.Frame_1.Parent =  SectionInstance.Frame_2
				ToggleInstance.Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
				ToggleInstance.Frame_1.BackgroundTransparency = 1
				ToggleInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				ToggleInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				ToggleInstance.Frame_1.Name = tostring(btnText)
				ToggleInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				ToggleInstance.TextButton_1.Parent = ToggleInstance.Frame_1
				ToggleInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
				ToggleInstance.TextButton_1.Text = ''
				ToggleInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
				ToggleInstance.TextButton_1.TextSize = 18
				ToggleInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				ToggleInstance.TextButton_1.BorderSizePixel = 0
				ToggleInstance.TextButton_1.Size = UDim2.new(1, 0, 1, 0)
				ToggleInstance.TextButton_1.AutoButtonColor = false
				ToggleInstance.TextButton_1.Name = 'Togglebutton'

				ToggleInstance.UICorner_1.Parent = ToggleInstance.TextButton_1
				ToggleInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				ToggleInstance.Frame_2.Parent = ToggleInstance.TextButton_1
				ToggleInstance.Frame_2.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				ToggleInstance.Frame_2.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				ToggleInstance.Frame_2.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				ToggleInstance.Frame_2.Name = 'buttonShadow'

				ToggleInstance.UICorner_2.Parent = ToggleInstance.Frame_2
				ToggleInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

				ToggleInstance.TextLabel_1.Parent = ToggleInstance.TextButton_1
				ToggleInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				ToggleInstance.TextLabel_1.Text = tostring(btnText)
				ToggleInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ToggleInstance.TextLabel_1.TextSize = 18
				ToggleInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				ToggleInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				ToggleInstance.TextLabel_1.BackgroundTransparency = 1
				ToggleInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				ToggleInstance.TextLabel_1.Size = UDim2.new(0.8021201491355896, 0, 1, 0)

				ToggleInstance.ImageLabel_1.Parent = ToggleInstance.TextButton_1
				ToggleInstance.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031068426'
				ToggleInstance.ImageLabel_1.BackgroundTransparency = 1
				ToggleInstance.ImageLabel_1.BorderSizePixel = 0
				ToggleInstance.ImageLabel_1.Position = UDim2.new(0, 258, 0, 7)
				ToggleInstance.ImageLabel_1.Size = UDim2.new(0, 19, 0, 19)

				ToggleInstance.Frame_3.Parent = ToggleInstance.TextButton_1
				ToggleInstance.Frame_3.AnchorPoint = Vector2.new(0.5, 0.5)
				ToggleInstance.Frame_3.BackgroundColor3 = Color3.new(0, 0, 0)
				ToggleInstance.Frame_3.BackgroundTransparency = 1
				ToggleInstance.Frame_3.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				ToggleInstance.Frame_3.ClipsDescendants = true
				ToggleInstance.Frame_3.Position = UDim2.new(0.5, 0, 0.5, 0)
				ToggleInstance.Frame_3.Size = UDim2.new(1, 0, 1, 0)
				ToggleInstance.Frame_3.Name = 'Background'
				Util:Ripple(ToggleInstance.TextButton_1)

				ToggleInstance.UICorner_3.Parent = ToggleInstance.Frame_3
				ToggleInstance.UICorner_3.CornerRadius = UDim.new(0, 4)
				ToggleInstance.UICorner_3.Name = 'CornerRadius'

				ToggleInstance.UIStroke_1.Parent = ToggleInstance.Frame_3
				ToggleInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				ToggleInstance.UIStroke_1.Thickness = 0
				ToggleInstance.UIStroke_1.Transparency = 0.5
				ToggleInstance.UIStroke_1.Name = 'Border'

				local Toggle = ToggleInstance.TextButton_1


				local active = Default
				self:updateToggle(Toggle, nil, active)

				Toggle.MouseButton1Click:Connect(function()
					active = not active
					self:updateToggle(Toggle, nil, active)

					if callback then
						callback(active, function(...)
							self:updateToggle(Toggle, ...)
						end)
					end
				end)


				local opened = false
				Toggle.MouseEnter:Connect(function()
					Util:Tween(Toggle.Background,{BackgroundTransparency = 0.8},0.2)
				end)
				Toggle.MouseLeave:Connect(function()
					Util:Tween(Toggle.Background,{BackgroundTransparency = 1},0.2)
				end)	
			end
			function ElementHandler:updateToggle(toggle, title, value)
				if title then
					toggle.TextLabel.Text = title
				end

				if value == true then
					toggle.ImageLabel.Image = "http://www.roblox.com/asset/?id=6031068426"
				else
					toggle.ImageLabel.Image = "http://www.roblox.com/asset/?id=6031068433"
				end

			end
			function ElementHandler:CreateLabel(config)
				local Text = config.Title or config.title or config.text or config.Text or "TextLabel"
				local OrderNumber = config.Order or config.order or 20

				local LabelInstance = {
					["UICorner_1"] = Instance.new("UICorner"),
					["Frame_1"] = Instance.new("Frame"),
					["Frame_2"] = Instance.new("Frame"),
					["TextLabel_1"] = Instance.new("TextLabel"),
				}


				LabelInstance.Frame_1.Parent =  SectionInstance.Frame_2
				LabelInstance.Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
				LabelInstance.Frame_1.BackgroundTransparency = 1
				LabelInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				LabelInstance.Frame_1.LayoutOrder = 100
				LabelInstance.Frame_1.Position = UDim2.new(0, 0, 0.5945122241973877, 0)
				LabelInstance.Frame_1.Size = UDim2.new(0, 283, 0, 24)
				LabelInstance.Frame_1.Name = tostring(Text)
				LabelInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)


				LabelInstance.Frame_2.Parent = LabelInstance.Frame_1
				LabelInstance.Frame_2.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				LabelInstance.Frame_2.BackgroundTransparency = 1
				LabelInstance.Frame_2.Size = UDim2.new(1, 0, 1, 0)

				LabelInstance.TextLabel_1.Parent = LabelInstance.Frame_2
				LabelInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				LabelInstance.TextLabel_1.Text = tostring(Text)
				LabelInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				LabelInstance.TextLabel_1.TextSize = 18
				LabelInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				LabelInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				LabelInstance.TextLabel_1.BackgroundTransparency = 1
				LabelInstance.TextLabel_1.Size = UDim2.new(1, 0, 1, 0)

				LabelInstance.UICorner_1.Parent = LabelInstance.Frame_2
				LabelInstance.UICorner_1.CornerRadius = UDim.new(0, 4)
				return LabelInstance.Frame_1
			end
			function ElementHandler:updateLabel(label, title, color)
				if label then
					label.Frame.TextLabel.Text = tostring(title)
				end
				if color then
					label.Frame.TextLabel.TextColor3 = color
				end
			end
			function ElementHandler:CreateSlider(config)
				local btnText = config.Title or config.title or config.text or config.Text or "Slider"
				local callback = config.callback or config.Callback or function() end   
				local Min = config.Min or config.min or 0
				local Max = config.Max or config.max or 100
				local Default = config.Default or config.default or 16
				local OrderNumber = config.Order or config.order or 20

				local SliderInstance = {
					["UICorner_4"] = Instance.new("UICorner"),
					["UICorner_1"] = Instance.new("UICorner"),
					["Frame_4"] = Instance.new("Frame"),
					["Frame_3"] = Instance.new("Frame"),
					["UICorner_3"] = Instance.new("UICorner"),
					["TextLabel_1"] = Instance.new("TextLabel"),
					["Frame_1"] = Instance.new("Frame"),
					["Frame_2"] = Instance.new("Frame"),
					["UICorner_2"] = Instance.new("UICorner"),
					["ScrollingFrame_1"] = Instance.new("ScrollingFrame"),
					["UICorner_6"] = Instance.new("UICorner"),
					["Frame_5"] = Instance.new("Frame"),
					["LocalScript_1"] = Instance.new("LocalScript"),
					["TextLabel_2"] = Instance.new("TextLabel"),
					["UICorner_5"] = Instance.new("UICorner"),
					["ImageLabel_2"] = Instance.new("ImageLabel"),
					["TextButton_1"] = Instance.new("TextButton"),
					["ImageLabel_1"] = Instance.new("ImageLabel"),
				}

				SliderInstance.Frame_1.Parent =  SectionInstance.Frame_2
				SliderInstance.Frame_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				SliderInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				SliderInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				SliderInstance.Frame_1.Name = tostring(btnText)
				SliderInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				SliderInstance.Frame_2.Parent = SliderInstance.Frame_1
				SliderInstance.Frame_2.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				SliderInstance.Frame_2.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				SliderInstance.Frame_2.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				SliderInstance.Frame_2.Name = 'buttonShadow'

				SliderInstance.UICorner_1.Parent = SliderInstance.Frame_2
				SliderInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				SliderInstance.UICorner_2.Parent = SliderInstance.Frame_1
				SliderInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

				SliderInstance.TextLabel_1.Parent = SliderInstance.Frame_1
				SliderInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				SliderInstance.TextLabel_1.Text = tostring(btnText)
				SliderInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				SliderInstance.TextLabel_1.TextSize = 18
				SliderInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				SliderInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				SliderInstance.TextLabel_1.BackgroundTransparency = 1
				SliderInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				SliderInstance.TextLabel_1.Size = UDim2.new(0.2720848023891449, 0, 1, 0)

				SliderInstance.TextButton_1.Parent = SliderInstance.Frame_1
				SliderInstance.TextButton_1.Font = Enum.Font.SourceSans
				SliderInstance.TextButton_1.Text = ''
				SliderInstance.TextButton_1.TextColor3 = Color3.new(0, 0, 0)
				SliderInstance.TextButton_1.TextSize = 14
				SliderInstance.TextButton_1.BackgroundColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				SliderInstance.TextButton_1.Position = UDim2.new(0.34299999475479126, 0, 0.38199999928474426, 0)
				SliderInstance.TextButton_1.Size = UDim2.new(0, 150, 0, 7)
				SliderInstance.TextButton_1.AutoButtonColor = false
				SliderInstance.TextButton_1.Name = 'Main'

				SliderInstance.UICorner_3.Parent = SliderInstance.TextButton_1

				SliderInstance.LocalScript_1.Parent = SliderInstance.TextButton_1
				SliderInstance.LocalScript_1.Disabled = true

				SliderInstance.Frame_3.Parent = SliderInstance.TextButton_1
				SliderInstance.Frame_3.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
				SliderInstance.Frame_3.Size = UDim2.new(0, 150, 0, 7)

				SliderInstance.UICorner_4.Parent = SliderInstance.Frame_3

				SliderInstance.ImageLabel_1.Parent = SliderInstance.Frame_3
				SliderInstance.ImageLabel_1.Image = 'rbxassetid://4608020054'
				SliderInstance.ImageLabel_1.ImageColor3 = Color3.new(0.156863, 0.156863, 0.156863)
				SliderInstance.ImageLabel_1.ImageTransparency = 1
				SliderInstance.ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderInstance.ImageLabel_1.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
				SliderInstance.ImageLabel_1.BackgroundTransparency = 1
				SliderInstance.ImageLabel_1.BorderSizePixel = 0
				SliderInstance.ImageLabel_1.Position = UDim2.new(1, 0, 0.5, 0)
				SliderInstance.ImageLabel_1.Size = UDim2.new(0, 10, 0, 10)

				SliderInstance.ImageLabel_2.Parent = SliderInstance.TextButton_1
				SliderInstance.ImageLabel_2.Image = 'http://www.roblox.com/asset/?id=6031233863'
				SliderInstance.ImageLabel_2.BackgroundTransparency = 1
				SliderInstance.ImageLabel_2.BorderSizePixel = 0
				SliderInstance.ImageLabel_2.Position = UDim2.new(0, 161, 0, -6)
				SliderInstance.ImageLabel_2.Size = UDim2.new(0, 19, 0, 19)
				SliderInstance.ImageLabel_2.ZIndex = 1

				SliderInstance.ScrollingFrame_1.Parent = SliderInstance.Frame_1
				SliderInstance.ScrollingFrame_1.CanvasSize = UDim2.new(0, 0, 0, 0)
				SliderInstance.ScrollingFrame_1.ScrollBarImageColor3 = Color3.new(0, 0, 0)
				SliderInstance.ScrollingFrame_1.Active = true
				SliderInstance.ScrollingFrame_1.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
				SliderInstance.ScrollingFrame_1.BackgroundTransparency = 1
				SliderInstance.ScrollingFrame_1.BorderSizePixel = 0
				SliderInstance.ScrollingFrame_1.Position = UDim2.new(0, 201, 0, -19)
				SliderInstance.ScrollingFrame_1.Size = UDim2.new(0, 46, 0, 29)
				SliderInstance.ScrollingFrame_1.Name = 'TextFrame'
				SliderInstance.ScrollingFrame_1.ZIndex = 5

				SliderInstance.Frame_4.Parent = SliderInstance.ScrollingFrame_1
				SliderInstance.Frame_4.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
				SliderInstance.Frame_4.BackgroundTransparency = 1
				SliderInstance.Frame_4.BorderSizePixel = 0
				SliderInstance.Frame_4.Size = UDim2.new(1, 0, 1, 0)

				SliderInstance.UICorner_5.Parent = SliderInstance.Frame_4
				SliderInstance.UICorner_5.CornerRadius = UDim.new(0, 6)

				SliderInstance.TextLabel_2.Parent = SliderInstance.Frame_4
				SliderInstance.TextLabel_2.Font = Enum.Font.SourceSansSemibold
				SliderInstance.TextLabel_2.Text = '54'
				SliderInstance.TextLabel_2.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				SliderInstance.TextLabel_2.TextScaled = true
				SliderInstance.TextLabel_2.TextSize = 18
				SliderInstance.TextLabel_2.TextTransparency = 1
				SliderInstance.TextLabel_2.TextWrapped = true
				SliderInstance.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
				SliderInstance.TextLabel_2.BackgroundTransparency = 1
				SliderInstance.TextLabel_2.Size = UDim2.new(1, 0, 1, 0)
				SliderInstance.TextLabel_2.ZIndex = 1

				SliderInstance.Frame_5.Parent = SliderInstance.Frame_4
				SliderInstance.Frame_5.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)
				SliderInstance.Frame_5.BackgroundTransparency = 1
				SliderInstance.Frame_5.Position = UDim2.new(0, 0, 0.9369999766349792, 0)
				SliderInstance.Frame_5.Size = UDim2.new(1, 0, 0.06400000303983688, 0)
				SliderInstance.Frame_5.Name = 'buttonShadow'

				SliderInstance.UICorner_6.Parent = SliderInstance.Frame_5
				SliderInstance.UICorner_6.CornerRadius = UDim.new(0, 4)

				local Slider = SliderInstance.TextButton_1

				local TextHover = Slider.Parent.TextFrame
				local Val = TextHover.Frame.TextLabel
				local Fill = Slider.Frame
				local Circle = Fill.ImageLabel

				local value = Default or Min

				self:updateSlider(Slider, nil, Default or Min, Min, Max)


				local held = false
				local Hovering = false

				Slider.MouseButton1Down:Connect(function()
					held = true	
					while held do
						Util:Tween(Circle, {ImageTransparency = 0}, 0.1)
						value = self:updateSlider(Slider, nil, nil, Min, Max, value)
						callback(value)
						wait()
					end
					wait(0.5)
					Util:Tween(Circle, {ImageTransparency = 1}, 0.2)
				end)

				game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if held then
							if not Hovering then
								Util:Tween(TextHover.Frame, {BackgroundTransparency = 1}, 0.1)
								Util:Tween(TextHover.Frame.buttonShadow, {BackgroundTransparency = 1}, 0.1)
								Util:Tween(TextHover:FindFirstChild("TextLabel",true), {TextTransparency = 1}, 0.1)
							end
							held = false
						end
					end
				end)

				Slider.MouseEnter:connect(function()
					Hovering = true
					Util:Tween(TextHover.Frame, {BackgroundTransparency = 0}, 0.1)
					Util:Tween(TextHover.Frame.buttonShadow, {BackgroundTransparency = 0}, 0.1)
					Util:Tween(TextHover:FindFirstChild("TextLabel",true), {TextTransparency = 0}, 0.1)
				end)

				Slider.MouseLeave:connect(function()
					Hovering = false
					if not held then
						Util:Tween(TextHover.Frame, {BackgroundTransparency = 1}, 0.1)
						Util:Tween(TextHover.Frame.buttonShadow, {BackgroundTransparency = 1}, 0.1)
						Util:Tween(TextHover:FindFirstChild("TextLabel",true), {TextTransparency = 1}, 0.1)
					end
				end)
				return SliderInstance.Frame_1
			end

			function ElementHandler:updateSlider(slider, title, value, min, max, lvalue)
				local bar = slider
				local percent = (Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

				if value then
					percent = (value - min) / (max - min)
				end

				percent = math.clamp(percent, 0, 1)
				value = value or math.floor(min + (max - min) * percent)

				slider.Parent.TextFrame.Frame.TextLabel.Text = value
				Util:Tween(slider.Frame, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
				return value
			end

			function ElementHandler:CreateKeybind(config)
				local btnText = config.Title or config.title or config.text or config.Text or "Keybind"
				local callback = config.callback or config.Callback or function() end   
				local DefaultKey = Enum.KeyCode[config.Default] or config.default or Enum.KeyCode.Q
				local OrderNumber = config.Order or config.order or 20


				if not DefaultKey then
					return
				end

				if not table.find(BlacklistedKeys,DefaultKey) then
					DefaultKey = DefaultKey
				else
					DefaultKey = Enum.KeyCode.Q
				end


				local KeybindInstance = {
					["UICorner_3"] = Instance.new("UICorner"),
					["UICorner_1"] = Instance.new("UICorner"),
					["TextButton_1"] = Instance.new("TextButton"),
					["TextLabel_2"] = Instance.new("TextLabel"),
					["LocalScript_1"] = Instance.new("LocalScript"),
					["TextButton_2"] = Instance.new("TextButton"),
					["UICorner_2"] = Instance.new("UICorner"),
					["UIStroke_1"] = Instance.new("UIStroke"),
					["Frame_1"] = Instance.new("Frame"),
					["Frame_3"] = Instance.new("Frame"),
					["TextLabel_1"] = Instance.new("TextLabel"),
					["Frame_2"] = Instance.new("Frame"),
				}

				KeybindInstance.Frame_1.Parent =  SectionInstance.Frame_2
				KeybindInstance.Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
				KeybindInstance.Frame_1.BackgroundTransparency = 1
				KeybindInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				KeybindInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				KeybindInstance.Frame_1.Name = tostring(btnText)
				KeybindInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				KeybindInstance.TextButton_1.Parent = KeybindInstance.Frame_1
				KeybindInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
				KeybindInstance.TextButton_1.Text = ''
				KeybindInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
				KeybindInstance.TextButton_1.TextSize = 18
				KeybindInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				KeybindInstance.TextButton_1.BorderSizePixel = 0
				KeybindInstance.TextButton_1.Size = UDim2.new(1, 0, 1, 0)
				KeybindInstance.TextButton_1.AutoButtonColor = false
				KeybindInstance.TextButton_1.Name = 'KeybindButton'

				KeybindInstance.UICorner_1.Parent = KeybindInstance.TextButton_1
				KeybindInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				KeybindInstance.TextLabel_1.Parent = KeybindInstance.TextButton_1
				KeybindInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				KeybindInstance.TextLabel_1.Text = tostring(btnText)
				KeybindInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				KeybindInstance.TextLabel_1.TextSize = 18
				KeybindInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				KeybindInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				KeybindInstance.TextLabel_1.BackgroundTransparency = 1
				KeybindInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				KeybindInstance.TextLabel_1.Size = UDim2.new(0.5441696047782898, 0, 1, 0)

				KeybindInstance.Frame_2.Parent = KeybindInstance.TextButton_1
				KeybindInstance.Frame_2.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				KeybindInstance.Frame_2.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				KeybindInstance.Frame_2.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				KeybindInstance.Frame_2.Name = 'buttonShadow'

				KeybindInstance.UICorner_2.Parent = KeybindInstance.Frame_2
				KeybindInstance.UICorner_2.CornerRadius = UDim.new(0, 4)

				KeybindInstance.Frame_3.Parent = KeybindInstance.TextButton_1
				KeybindInstance.Frame_3.AnchorPoint = Vector2.new(0.5, 0.5)
				KeybindInstance.Frame_3.BackgroundColor3 = Color3.new(0, 0, 0)
				KeybindInstance.Frame_3.BackgroundTransparency = 1
				KeybindInstance.Frame_3.ClipsDescendants = true
				KeybindInstance.Frame_3.Position = UDim2.new(0.5, 0, 0.5, 0)
				KeybindInstance.Frame_3.Size = UDim2.new(1, 0, 1, 0)
				KeybindInstance.Frame_3.Name = 'Background'
				Util:Ripple(KeybindInstance.TextButton_1)

				KeybindInstance.UICorner_3.Parent = KeybindInstance.Frame_3
				KeybindInstance.UICorner_3.CornerRadius = UDim.new(0, 4)
				KeybindInstance.UICorner_3.Name = 'CornerRadius'

				KeybindInstance.UIStroke_1.Parent = KeybindInstance.Frame_3
				KeybindInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				KeybindInstance.UIStroke_1.Thickness = 0
				KeybindInstance.UIStroke_1.Transparency = 0.5
				KeybindInstance.UIStroke_1.Name = 'Border'

				KeybindInstance.TextButton_2.Parent = KeybindInstance.TextButton_1
				KeybindInstance.TextButton_2.Font = Enum.Font.SourceSans
				KeybindInstance.TextButton_2.Text = ''
				KeybindInstance.TextButton_2.TextColor3 = Color3.new(0, 0, 0)
				KeybindInstance.TextButton_2.TextSize = 14
				KeybindInstance.TextButton_2.BackgroundColor3 = Color3.new(1, 1, 1)
				KeybindInstance.TextButton_2.BackgroundTransparency = 1
				KeybindInstance.TextButton_2.BorderSizePixel = 0
				KeybindInstance.TextButton_2.Position = UDim2.new(0.8409894108772278, 0, 0, 0)
				KeybindInstance.TextButton_2.Size = UDim2.new(0, 45, 0, 32)

				KeybindInstance.TextLabel_2.Parent = KeybindInstance.TextButton_2
				KeybindInstance.TextLabel_2.Font = Enum.Font.SourceSansSemibold
				KeybindInstance.TextLabel_2.Text = tostring(DefaultKey.Name)
				KeybindInstance.TextLabel_2.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				KeybindInstance.TextLabel_2.TextScaled = true
				KeybindInstance.TextLabel_2.TextSize = 18
				KeybindInstance.TextLabel_2.TextWrapped = true
				KeybindInstance.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
				KeybindInstance.TextLabel_2.BackgroundTransparency = 1
				KeybindInstance.TextLabel_2.Position = UDim2.new(0, 17, 0, 3)
				KeybindInstance.TextLabel_2.Size = UDim2.new(0, 26, 0, 26)


				local Button = KeybindInstance.TextButton_1
				
				Button.MouseButton1Click:Connect(function()
					callback()
				end)
				
				local ChangeBind = Button.TextButton
				local Label = ChangeBind.TextLabel

				local opened = false


				Button.MouseEnter:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 0.8},0.2)
				end)
				Button.MouseLeave:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 1},0.2)
				end)

				local Listening = false
				game:GetService("UserInputService").InputBegan:Connect(function(Input, IsTyping)
					if IsTyping then return end
					if Input.KeyCode == DefaultKey then
						callback()
					end
					if Listening == true then
						if not table.find(BlacklistedKeys,Input.KeyCode) then
							DefaultKey = Input.KeyCode
						else
							DefaultKey = Enum.KeyCode.Q
						end

						Listening = false
						if DefaultKey.Name == "LeftControl" then
							Label.Text = "LControl"
						elseif DefaultKey.Name == "RightControl" then
							Label.Text = "RControl"
						elseif DefaultKey.Name == "LeftShift" then
							Label.Text = "LShift"
						elseif DefaultKey.Name == "RightShift" then
							Label.Text = "RShift"
						elseif table.find(NumberIndex,DefaultKey.Name) then
							Label.Text = tostring(Numbers[DefaultKey.Name])
						else
							Label.Text = DefaultKey.Name
						end

					end
				end)

				ChangeBind.MouseButton1Click:Connect(function()
					Listening = true
					Label.Text = ".."
				end)

			end

			function ElementHandler:CreateDropdown(config)
				local btnText = config.Title or config.title or config.text or config.Text or "Dropdown"
				local callback = config.callback or config.Callback or function() end   
				local List
				List = config.array or config.Array or config.Table or config.List or config.list or {}
				if List == "Players" then
					List = game.Players:GetPlayers()
					game.Players.PlayerAdded:Connect(function()
						wait(1)
						List = nil
						wait()
						List = game.Players:GetPlayers()
					end)
					game.Players.PlayerRemoving:Connect(function()
						wait(1)
						List = nil
						wait()
						List = game.Players:GetPlayers()
					end)
				end

				local opened
				local OrderNumber = config.Order or config.order or 20


				local DropInstance = {
					["UICorner_5"] = Instance.new("UICorner"),
					["UICorner_4"] = Instance.new("UICorner"),
					["ImageLabel_1"] = Instance.new("ImageLabel"),
					["UIPadding_2"] = Instance.new("UIPadding"),
					["UIListLayout_2"] = Instance.new("UIListLayout"),
					["Frame_1"] = Instance.new("Frame"),
					["TextButton_1"] = Instance.new("TextButton"),
					["UICorner_3"] = Instance.new("UICorner"),
					["LocalScript_1"] = Instance.new("LocalScript"),
					["UICorner_6"] = Instance.new("UICorner"),
					["Frame_6"] = Instance.new("Frame"),
					["TextLabel_2"] = Instance.new("TextLabel"),
					["UIListLayout_1"] = Instance.new("UIListLayout"),
					["Frame_2"] = Instance.new("Frame"),
					["UIStroke_1"] = Instance.new("UIStroke"),
					["Frame_5"] = Instance.new("Frame"),
					["TextButton_2"] = Instance.new("TextButton"),
					["TextLabel_1"] = Instance.new("TextLabel"),
					["Frame_4"] = Instance.new("Frame"),
					["UIPadding_1"] = Instance.new("UIPadding"),
					["UICorner_2"] = Instance.new("UICorner"),
					["UICorner_1"] = Instance.new("UICorner"),
					["Frame_3"] = Instance.new("Frame"),
				}

				DropInstance.Frame_1.Parent =  SectionInstance.Frame_2
				DropInstance.Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
				DropInstance.Frame_1.BackgroundTransparency = 1
				DropInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				DropInstance.Frame_1.Position = UDim2.new(0, 0, 0.11890243738889694, 0)
				DropInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				DropInstance.Frame_1.Name = tostring(btnText)
				DropInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				DropInstance.UIListLayout_1.Parent = DropInstance.Frame_1
				DropInstance.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				DropInstance.UIPadding_1.Parent = DropInstance.Frame_1

				DropInstance.TextButton_1.Parent = DropInstance.Frame_1
				DropInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
				DropInstance.TextButton_1.Text = ''
				DropInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
				DropInstance.TextButton_1.TextSize = 18
				DropInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				DropInstance.TextButton_1.BorderSizePixel = 0
				DropInstance.TextButton_1.Size = UDim2.new(0, 283, 0, 34)
				DropInstance.TextButton_1.AutoButtonColor = false
				DropInstance.TextButton_1.Name = 'Dropdown'

				DropInstance.UICorner_1.Parent = DropInstance.TextButton_1
				DropInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				DropInstance.ImageLabel_1.Parent = DropInstance.TextButton_1
				DropInstance.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031091004'
				DropInstance.ImageLabel_1.BackgroundTransparency = 1
				DropInstance.ImageLabel_1.BorderSizePixel = 0
				DropInstance.ImageLabel_1.Position = UDim2.new(0.8975265026092529, 0, 0.058823347091674805, 0)
				DropInstance.ImageLabel_1.Rotation = 180
				DropInstance.ImageLabel_1.Size = UDim2.new(0, 29, 0, 29)

				DropInstance.TextLabel_1.Parent = DropInstance.TextButton_1
				DropInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				DropInstance.TextLabel_1.Text = tostring(btnText)
				DropInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				DropInstance.TextLabel_1.TextSize = 18
				DropInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				DropInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				DropInstance.TextLabel_1.BackgroundTransparency = 1
				DropInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				DropInstance.TextLabel_1.Size = UDim2.new(0.869257926940918, 0, 1, 0)

				DropInstance.Frame_2.Parent = DropInstance.TextButton_1
				DropInstance.Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
				DropInstance.Frame_2.BackgroundColor3 = Color3.new(0, 0, 0)
				DropInstance.Frame_2.BackgroundTransparency = 1
				DropInstance.Frame_2.ClipsDescendants = true
				DropInstance.Frame_2.Position = UDim2.new(0.5, 0, 0.5, 0)
				DropInstance.Frame_2.Size = UDim2.new(1, 0, 1, 0)
				DropInstance.Frame_2.Name = 'Background'
				Util:Ripple(DropInstance.TextButton_1)

				DropInstance.UICorner_2.Parent = DropInstance.Frame_2
				DropInstance.UICorner_2.CornerRadius = UDim.new(0, 4)
				DropInstance.UICorner_2.Name = 'CornerRadius'

				DropInstance.UIStroke_1.Parent = DropInstance.Frame_2
				DropInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				DropInstance.UIStroke_1.Thickness = 0
				DropInstance.UIStroke_1.Transparency = 0.5
				DropInstance.UIStroke_1.Name = 'Border'

				DropInstance.Frame_3.Parent = DropInstance.TextButton_1
				DropInstance.Frame_3.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				DropInstance.Frame_3.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				DropInstance.Frame_3.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				DropInstance.Frame_3.Name = 'buttonShadow'

				DropInstance.UICorner_3.Parent = DropInstance.Frame_3
				DropInstance.UICorner_3.CornerRadius = UDim.new(0, 4)

				DropInstance.Frame_4.Parent = DropInstance.TextButton_1
				DropInstance.Frame_4.BackgroundColor3 = Color3.new(1, 1, 1)
				DropInstance.Frame_4.BackgroundTransparency = 1
				DropInstance.Frame_4.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				DropInstance.Frame_4.BorderSizePixel = 0
				DropInstance.Frame_4.Position = UDim2.new(0, 2, 0, 35)
				DropInstance.Frame_4.Size = UDim2.new(0, 278, 0, 0)
				DropInstance.Frame_4.Name = 'HoldingFrame'

				DropInstance.UIPadding_2.Parent = DropInstance.Frame_4

				DropInstance.UICorner_4.Parent = DropInstance.Frame_4
				DropInstance.UICorner_4.CornerRadius = UDim.new(0, 2)

				DropInstance.TextButton_2.Parent = DropInstance.Frame_4
				DropInstance.TextButton_2.Font = Enum.Font.SourceSans
				DropInstance.TextButton_2.Text = ''
				DropInstance.TextButton_2.TextColor3 = Color3.new(0, 0, 0)
				DropInstance.TextButton_2.TextSize = 14
				DropInstance.TextButton_2.BackgroundColor3 = Color3.new(0.996078, 0.337255, 0.337255)
				DropInstance.TextButton_2.BorderSizePixel = 0
				DropInstance.TextButton_2.Size = UDim2.new(1, 0, 0, 0)
				DropInstance.TextButton_2.ZIndex = 2
				DropInstance.TextButton_2.AutoButtonColor = false

				DropInstance.Frame_5.Parent = DropInstance.TextButton_2
				DropInstance.Frame_5.BackgroundColor3 = Color3.new(0, 0, 0)
				DropInstance.Frame_5.BackgroundTransparency = 1
				DropInstance.Frame_5.BorderColor3 = Color3.new(1, 1, 1)
				DropInstance.Frame_5.Size = UDim2.new(1, 0, 1, 0)
				DropInstance.Frame_5.ZIndex = 2
				DropInstance.Frame_5.Name = 'Shadow'

				DropInstance.TextLabel_2.Parent = DropInstance.TextButton_2
				DropInstance.TextLabel_2.Font = Enum.Font.SourceSansSemibold
				DropInstance.TextLabel_2.Text = 'Option 1'
				DropInstance.TextLabel_2.TextColor3 = Color3.new(0.952941, 0.952941, 0.952941)
				DropInstance.TextLabel_2.TextSize = 15
				DropInstance.TextLabel_2.TextTransparency = 1
				DropInstance.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
				DropInstance.TextLabel_2.BackgroundTransparency = 1
				DropInstance.TextLabel_2.BorderSizePixel = 0
				DropInstance.TextLabel_2.Size = UDim2.new(1, 0, 1, 0)

				DropInstance.UICorner_5.Parent = DropInstance.TextButton_2
				DropInstance.UICorner_5.CornerRadius = UDim.new(0, 2)

				DropInstance.Frame_6.Parent = DropInstance.TextButton_2
				DropInstance.Frame_6.BackgroundColor3 = Color3.new(0.631373, 0.231373, 0.235294)
				DropInstance.Frame_6.BorderSizePixel = 0
				DropInstance.Frame_6.Position = UDim2.new(0, 0, 0.9583333134651184, 0)
				DropInstance.Frame_6.Size = UDim2.new(0, 278, 0, 0)
				DropInstance.Frame_6.ZIndex = 2
				DropInstance.Frame_6.Name = 'buttonShadow'

				DropInstance.UICorner_6.Parent = DropInstance.Frame_6
				DropInstance.UICorner_6.CornerRadius = UDim.new(0, 2)

				DropInstance.UIListLayout_2.Parent = DropInstance.Frame_4
				DropInstance.UIListLayout_2.Padding = UDim.new(0, 2)
				DropInstance.UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder


				local Dropdown = DropInstance.TextButton_1
				local HoldingFrame = Dropdown.HoldingFrame
				local Holder = Dropdown.Parent

				HoldingFrame:FindFirstChild("TextButton"):Destroy()

				local Selected = nil


				local opened = false


				HoldingFrame:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					local size = HoldingFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize
					local padding = HoldingFrame:FindFirstChildOfClass("UIListLayout").Parent.UIPadding

					size = size + Vector2.new(0, padding.PaddingBottom.Offset + (padding.PaddingTop.Offset))
					Util:Tween(HoldingFrame,{Size = UDim2.new(0, 278, 0, size.Y + 2)},0.2)
					Util:Tween(Holder,{Size = UDim2.new(0, 283, 0, size.Y +34 )},0.2)
				end)

				Dropdown.MouseEnter:Connect(function()
					Util:Tween(Dropdown.Background,{BackgroundTransparency = 0.8},0.2)
				end)
				Dropdown.MouseLeave:Connect(function()
					Util:Tween(Dropdown.Background,{BackgroundTransparency = 1},0.2)
				end)

				Dropdown.MouseButton1Click:Connect(function()
					if Dropdown.ImageLabel.Rotation == 180 then
						self:updateDropdown(Dropdown, nil, List, callback,Selected,btnText)
					else
						self:updateDropdown(Dropdown, nil, nil, callback,Selected,btnText)
					end
				end)
				return DropInstance.TextButton_1
			end


			function ElementHandler:updateDropdown(dropdown, title, list, callback,selected,text)
				if dropdown.ImageLabel.Rotation == 180 then
					Util:Tween(dropdown.ImageLabel,{Rotation = 0},0.2)
				else
					Util:Tween(dropdown.ImageLabel,{Rotation = 180},0.2)
				end


				for i, button in pairs(dropdown.HoldingFrame:GetChildren()) do
					if button:IsA("TextButton") then
						button:Destroy()
					end
				end

				for i, value in pairs(list or {}) do
					local TextButton = Instance.new("TextButton")
					local Shadow = Instance.new("Frame")
					local TextLabel = Instance.new("TextLabel")
					local UICorner = Instance.new("UICorner")
					local buttonShadow = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local UICorner_3 = Instance.new("UICorner")

					TextButton.Parent = dropdown.HoldingFrame
					TextButton.BackgroundColor3 = Color3.fromRGB(254, 86, 86)
					TextButton.BorderSizePixel = 0
					TextButton.Position = UDim2.new(0, 0, 0, 0)
					TextButton.Size = UDim2.new(1, 0, 0, 24)
					TextButton.ZIndex = 1
					TextButton.AutoButtonColor = false
					TextButton.Font = Enum.Font.SourceSans
					TextButton.Name = tostring(value)
					TextButton.Text = ""
					TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
					TextButton.TextSize = 14.000
					TextButton.Name = tostring(value)

					Shadow.Name = "Shadow"
					Shadow.Parent = TextButton
					Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					Shadow.BackgroundTransparency = 1.000
					Shadow.BorderColor3 = Color3.fromRGB(255, 255, 255)
					Shadow.Size = UDim2.new(1, 0, 1, 0)
					Shadow.ZIndex = 2

					TextLabel.Parent = TextButton
					TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.BackgroundTransparency = 1.000
					TextLabel.BorderSizePixel = 0
					TextLabel.Size = UDim2.new(1, 0, 1, 0)
					TextLabel.Font = Enum.Font.SourceSansSemibold
					TextLabel.Text = tostring(value)
					TextLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
					TextLabel.TextSize = 15.000
					TextLabel.TextTransparency = 0
					TextLabel.ZIndex = 2

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = TextButton

					buttonShadow.Name = "buttonShadow"
					buttonShadow.Parent = TextButton
					buttonShadow.BackgroundColor3 = Color3.fromRGB(161, 59, 60)
					buttonShadow.BackgroundTransparency = 1
					buttonShadow.BorderSizePixel = 0
					buttonShadow.Position = UDim2.new(0, 0,0.958, 0)
					buttonShadow.Size = UDim2.new(0, 278, 0, 2)
					buttonShadow.ZIndex = 2

					if tostring(TextButton.Name) == selected then
						TextButton.BackgroundColor3 = Color3.fromRGB(0, 170, 126)
						buttonShadow.BackgroundColor3 = Color3.fromRGB(0, 134, 84)
					else
						TextButton.BackgroundColor3 = Color3.fromRGB(254, 86, 86)
						buttonShadow.BackgroundColor3 = Color3.fromRGB(161, 59, 60)
					end

					UICorner_2.CornerRadius = UDim.new(0, 4)
					UICorner_2.Parent = buttonShadow

					UICorner_2.CornerRadius = UDim.new(0, 2)
					UICorner_2.Parent = Shadow

					TextButton.MouseEnter:Connect(function()
						Util:Tween(TextButton:FindFirstChild("Shadow"),{BackgroundTransparency = 0.8},0.2)
					end)
					TextButton.MouseLeave:Connect(function()
						Util:Tween(TextButton:FindFirstChild("Shadow"),{BackgroundTransparency = 1},0.2)
					end)

					TextButton.MouseButton1Click:Connect(function()
						if callback then
							callback(value, function(...)
								self:updateDropdown(dropdown, ...)
							end)	
						end
						selected = tostring(TextButton.Name)
						dropdown.TextLabel.Text = tostring(text)
						dropdown.TextLabel.Text = dropdown.TextLabel.Text..": "..selected
						self:updateDropdown(dropdown, value, nil, callback,selected,text)
					end)
				end

			end

			function ElementHandler:CreateColorPicker(config)
				local btnText = config.Title or config.title or config.text or config.Text or "Color Picker"
				local callback = config.callback or config.Callback or function() end   
				local opened
				local OrderNumber = config.Order or config.order or 20
				local Default = config.Default or config.default or Color3.fromRGB(255,0,0)

				local ColorInstance = {
					["TextLabel_1"] = Instance.new("TextLabel"),
					["TextLabel_4"] = Instance.new("TextLabel"),
					["UICorner_6"] = Instance.new("UICorner"),
					["Frame_2"] = Instance.new("Frame"),
					["UICorner_7"] = Instance.new("UICorner"),
					["LocalScript_2"] = Instance.new("LocalScript"),
					["LocalScript_3"] = Instance.new("LocalScript"),
					["TextLabel_5"] = Instance.new("TextLabel"),
					["TextButton_2"] = Instance.new("TextButton"),
					["Frame_10"] = Instance.new("Frame"),
					["UICorner_2"] = Instance.new("UICorner"),
					["TextLabel_2"] = Instance.new("TextLabel"),
					["Frame_11"] = Instance.new("Frame"),
					["UICorner_5"] = Instance.new("UICorner"),
					["UIListLayout_2"] = Instance.new("UIListLayout"),
					["ImageLabel_2"] = Instance.new("ImageLabel"),
					["Frame_7"] = Instance.new("Frame"),
					["UIPadding_1"] = Instance.new("UIPadding"),
					["ImageLabel_3"] = Instance.new("ImageLabel"),
					["UICorner_1"] = Instance.new("UICorner"),
					["UIStroke_2"] = Instance.new("UIStroke"),
					["ImageLabel_1"] = Instance.new("ImageLabel"),
					["Frame_13"] = Instance.new("Frame"),
					["TextButton_1"] = Instance.new("TextButton"),
					["Frame_14"] = Instance.new("Frame"),
					["TextBox_1"] = Instance.new("TextBox"),
					["Frame_4"] = Instance.new("Frame"),
					["Frame_12"] = Instance.new("Frame"),
					["Frame_6"] = Instance.new("Frame"),
					["UIStroke_1"] = Instance.new("UIStroke"),
					["TextLabel_3"] = Instance.new("TextLabel"),
					["Frame_8"] = Instance.new("Frame"),
					["Frame_9"] = Instance.new("Frame"),
					["LocalScript_1"] = Instance.new("LocalScript"),
					["TextBox_2"] = Instance.new("TextBox"),
					["UIListLayout_1"] = Instance.new("UIListLayout"),
					["Frame_3"] = Instance.new("Frame"),
					["UICorner_4"] = Instance.new("UICorner"),
					["TextButton_3"] = Instance.new("TextButton"),
					["TextBox_3"] = Instance.new("TextBox"),
					["Frame_1"] = Instance.new("Frame"),
					["UICorner_3"] = Instance.new("UICorner"),
					["Frame_5"] = Instance.new("Frame"),
				}

				ColorInstance.Frame_1.Parent =  SectionInstance.Frame_2
				ColorInstance.Frame_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				ColorInstance.Frame_1.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				ColorInstance.Frame_1.Position = UDim2.new(0, 0, 0.5945122241973877, 0)
				ColorInstance.Frame_1.Size = UDim2.new(0, 283, 0, 34)
				ColorInstance.Frame_1.Name = tostring(btnText)
				ColorInstance.Frame_1.LayoutOrder = tonumber(OrderNumber)

				ColorInstance.TextButton_1.Parent = ColorInstance.Frame_1
				ColorInstance.TextButton_1.Font = Enum.Font.SourceSansSemibold
				ColorInstance.TextButton_1.Text = ''
				ColorInstance.TextButton_1.TextColor3 = Color3.new(0.898039, 0.898039, 0.898039)
				ColorInstance.TextButton_1.TextSize = 18
				ColorInstance.TextButton_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorInstance.TextButton_1.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				ColorInstance.TextButton_1.BorderSizePixel = 0
				ColorInstance.TextButton_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				ColorInstance.TextButton_1.Size = UDim2.new(0, 283, 0, 34)
				ColorInstance.TextButton_1.AutoButtonColor = false
				ColorInstance.TextButton_1.Name = 'ColorButton'

				ColorInstance.UICorner_1.Parent = ColorInstance.TextButton_1
				ColorInstance.UICorner_1.CornerRadius = UDim.new(0, 4)

				ColorInstance.TextLabel_1.Parent = ColorInstance.TextButton_1
				ColorInstance.TextLabel_1.Font = Enum.Font.SourceSansSemibold
				ColorInstance.TextLabel_1.Text = tostring(btnText)
				ColorInstance.TextLabel_1.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ColorInstance.TextLabel_1.TextSize = 18
				ColorInstance.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
				ColorInstance.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextLabel_1.BackgroundTransparency = 1
				ColorInstance.TextLabel_1.Position = UDim2.new(0.03180212154984474, 0, 0, 0)
				ColorInstance.TextLabel_1.Size = UDim2.new(0.6113074421882629, 0, 1, 0)

				ColorInstance.ImageLabel_1.Parent = ColorInstance.TextButton_1
				ColorInstance.ImageLabel_1.Image = 'http://www.roblox.com/asset/?id=6031625148'
				ColorInstance.ImageLabel_1.BackgroundTransparency = 1
				ColorInstance.ImageLabel_1.BorderSizePixel = 0
				ColorInstance.ImageLabel_1.Position = UDim2.new(0.9151942729949951, 0, 0.20588237047195435, 0)
				ColorInstance.ImageLabel_1.Size = UDim2.new(0, 19, 0, 19)

				ColorInstance.Frame_2.Parent = ColorInstance.TextButton_1
				ColorInstance.Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorInstance.Frame_2.BackgroundColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_2.BackgroundTransparency = 1
				ColorInstance.Frame_2.ClipsDescendants = true
				ColorInstance.Frame_2.Position = UDim2.new(0.5, 0, 0.5, 0)
				ColorInstance.Frame_2.Size = UDim2.new(1, 0, 1, 0)
				ColorInstance.Frame_2.Name = 'Background'
				Util:Ripple(ColorInstance.TextButton_1)

				ColorInstance.UICorner_2.Parent = ColorInstance.Frame_2
				ColorInstance.UICorner_2.CornerRadius = UDim.new(0, 4)
				ColorInstance.UICorner_2.Name = 'CornerRadius'

				ColorInstance.UIStroke_1.Parent = ColorInstance.Frame_2
				ColorInstance.UIStroke_1.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				ColorInstance.UIStroke_1.Thickness = 0
				ColorInstance.UIStroke_1.Transparency = 0.5
				ColorInstance.UIStroke_1.Name = 'Border'

				ColorInstance.LocalScript_1.Parent = ColorInstance.TextButton_1

				ColorInstance.TextButton_2.Parent = ColorInstance.TextButton_1
				ColorInstance.TextButton_2.Font = Enum.Font.SourceSans
				ColorInstance.TextButton_2.Text = ''
				ColorInstance.TextButton_2.TextColor3 = Color3.new(0, 0, 0)
				ColorInstance.TextButton_2.TextSize = 14
				ColorInstance.TextButton_2.BackgroundColor3 = Color3.new(1, 0, 0)
				ColorInstance.TextButton_2.BorderSizePixel = 0
				ColorInstance.TextButton_2.Position = UDim2.new(0, 198, 0, 8)
				ColorInstance.TextButton_2.Size = UDim2.new(0, 54, 0, 18)
				ColorInstance.TextButton_2.AutoButtonColor = false
				ColorInstance.TextButton_2.Name = 'ColorShower'

				ColorInstance.UICorner_3.Parent = ColorInstance.TextButton_2
				ColorInstance.UICorner_3.CornerRadius = UDim.new(0, 4)

				ColorInstance.Frame_3.Parent = ColorInstance.TextButton_2
				ColorInstance.Frame_3.Active = true
				ColorInstance.Frame_3.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
				ColorInstance.Frame_3.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
				ColorInstance.Frame_3.BorderSizePixel = 0
				ColorInstance.Frame_3.Position = UDim2.new(0, -198, 0, 26)
				ColorInstance.Frame_3.Size = UDim2.new(0, 283, 0, 0)
				ColorInstance.Frame_3.Visible = false
				ColorInstance.Frame_3.Name = 'HoldingFrame'

				ColorInstance.UICorner_4.Parent = ColorInstance.Frame_3
				ColorInstance.UICorner_4.CornerRadius = UDim.new(0, 2)

				ColorInstance.LocalScript_2.Parent = ColorInstance.Frame_3
				ColorInstance.LocalScript_2.Name = 'Controller'

				ColorInstance.Frame_4.Parent = ColorInstance.Frame_3
				ColorInstance.Frame_4.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_4.BackgroundTransparency = 1
				ColorInstance.Frame_4.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_4.BorderSizePixel = 0
				ColorInstance.Frame_4.Position = UDim2.new(0.36395758390426636, 0, 0.35227271914482117, 0)
				ColorInstance.Frame_4.Size = UDim2.new(0.6113074421882629, 0, 0.625, 0)
				ColorInstance.Frame_4.Name = 'RGB'

				ColorInstance.Frame_5.Parent = ColorInstance.Frame_4
				ColorInstance.Frame_5.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_5.BackgroundTransparency = 1
				ColorInstance.Frame_5.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_5.BorderSizePixel = 0
				ColorInstance.Frame_5.Position = UDim2.new(0, 0, 0.34545454382896423, 0)
				ColorInstance.Frame_5.Size = UDim2.new(0.2935323417186737, 0, 0.9636363387107849, 0)
				ColorInstance.Frame_5.Name = 'R'
				ColorInstance.Frame_5.LayoutOrder = 1

				ColorInstance.TextBox_1.Parent = ColorInstance.Frame_5
				ColorInstance.TextBox_1.Font = Enum.Font.SourceSans
				ColorInstance.TextBox_1.PlaceholderText = '255'
				ColorInstance.TextBox_1.Text = ''
				ColorInstance.TextBox_1.TextColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextBox_1.TextScaled = true
				ColorInstance.TextBox_1.TextSize = 14
				ColorInstance.TextBox_1.TextWrapped = true
				ColorInstance.TextBox_1.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
				ColorInstance.TextBox_1.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.TextBox_1.BorderSizePixel = 0
				ColorInstance.TextBox_1.Position = UDim2.new(0, 0, 0.5849056839942932, 0)
				ColorInstance.TextBox_1.Size = UDim2.new(1, 0, 0.4150943458080292, 0)
				ColorInstance.TextBox_1.Name = 'Value'

				ColorInstance.TextLabel_2.Parent = ColorInstance.Frame_5
				ColorInstance.TextLabel_2.Font = Enum.Font.SourceSansSemibold
				ColorInstance.TextLabel_2.Text = 'Red'
				ColorInstance.TextLabel_2.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ColorInstance.TextLabel_2.TextSize = 20
				ColorInstance.TextLabel_2.TextWrapped = true
				ColorInstance.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextLabel_2.BackgroundTransparency = 1
				ColorInstance.TextLabel_2.Position = UDim2.new(0, 0, 0.10000000149011612, 0)
				ColorInstance.TextLabel_2.Size = UDim2.new(1, 0, 0.4716981053352356, 0)

				ColorInstance.Frame_6.Parent = ColorInstance.Frame_4
				ColorInstance.Frame_6.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_6.BackgroundTransparency = 1
				ColorInstance.Frame_6.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_6.BorderSizePixel = 0
				ColorInstance.Frame_6.Position = UDim2.new(0.35323384404182434, 0, 0.036363635212183, 0)
				ColorInstance.Frame_6.Size = UDim2.new(0.2935323417186737, 0, 0.9636363387107849, 0)
				ColorInstance.Frame_6.Name = 'B'
				ColorInstance.Frame_6.LayoutOrder = 3

				ColorInstance.TextBox_2.Parent = ColorInstance.Frame_6
				ColorInstance.TextBox_2.Font = Enum.Font.SourceSans
				ColorInstance.TextBox_2.PlaceholderText = '255'
				ColorInstance.TextBox_2.Text = ''
				ColorInstance.TextBox_2.TextColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextBox_2.TextScaled = true
				ColorInstance.TextBox_2.TextSize = 14
				ColorInstance.TextBox_2.TextWrapped = true
				ColorInstance.TextBox_2.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
				ColorInstance.TextBox_2.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.TextBox_2.BorderSizePixel = 0
				ColorInstance.TextBox_2.Position = UDim2.new(0, 0, 0.5849056839942932, 0)
				ColorInstance.TextBox_2.Size = UDim2.new(1, 0, 0.4150943458080292, 0)
				ColorInstance.TextBox_2.Name = 'Value'

				ColorInstance.TextLabel_3.Parent = ColorInstance.Frame_6
				ColorInstance.TextLabel_3.Font = Enum.Font.SourceSansSemibold
				ColorInstance.TextLabel_3.Text = 'Blue'
				ColorInstance.TextLabel_3.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ColorInstance.TextLabel_3.TextSize = 20
				ColorInstance.TextLabel_3.TextWrapped = true
				ColorInstance.TextLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextLabel_3.BackgroundTransparency = 1
				ColorInstance.TextLabel_3.Position = UDim2.new(0, 0, 0.10000000149011612, 0)
				ColorInstance.TextLabel_3.Size = UDim2.new(1, 0, 0.4716981053352356, 0)

				ColorInstance.Frame_7.Parent = ColorInstance.Frame_4
				ColorInstance.Frame_7.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_7.BackgroundTransparency = 1
				ColorInstance.Frame_7.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_7.BorderSizePixel = 0
				ColorInstance.Frame_7.Position = UDim2.new(0.7064676880836487, 0, 0.036363635212183, 0)
				ColorInstance.Frame_7.Size = UDim2.new(0.2935323417186737, 0, 0.9636363387107849, 0)
				ColorInstance.Frame_7.Name = 'G'
				ColorInstance.Frame_7.LayoutOrder = 2


				ColorInstance.TextBox_3.Parent = ColorInstance.Frame_7
				ColorInstance.TextBox_3.Font = Enum.Font.SourceSans
				ColorInstance.TextBox_3.PlaceholderText = '255'
				ColorInstance.TextBox_3.Text = ''
				ColorInstance.TextBox_3.TextColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextBox_3.TextScaled = true
				ColorInstance.TextBox_3.TextSize = 14
				ColorInstance.TextBox_3.TextWrapped = true
				ColorInstance.TextBox_3.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
				ColorInstance.TextBox_3.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.TextBox_3.BorderSizePixel = 0
				ColorInstance.TextBox_3.Position = UDim2.new(0, 0, 0.5849056839942932, 0)
				ColorInstance.TextBox_3.Size = UDim2.new(1, 0, 0.4150943458080292, 0)
				ColorInstance.TextBox_3.Name = 'Value'

				ColorInstance.TextLabel_4.Parent = ColorInstance.Frame_7
				ColorInstance.TextLabel_4.Font = Enum.Font.SourceSansSemibold
				ColorInstance.TextLabel_4.Text = 'Green'
				ColorInstance.TextLabel_4.TextColor3 = Color3.new(0.862745, 0.862745, 0.862745)
				ColorInstance.TextLabel_4.TextSize = 20
				ColorInstance.TextLabel_4.TextWrapped = true
				ColorInstance.TextLabel_4.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextLabel_4.BackgroundTransparency = 1
				ColorInstance.TextLabel_4.Position = UDim2.new(0, 0, 0.10000000149011612, 0)
				ColorInstance.TextLabel_4.Size = UDim2.new(1, 0, 0.4716981053352356, 0)

				ColorInstance.UIListLayout_1.Parent = ColorInstance.Frame_4
				ColorInstance.UIListLayout_1.Padding = UDim.new(0, 12)
				ColorInstance.UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				ColorInstance.UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				ColorInstance.UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Bottom

				ColorInstance.Frame_8.Parent = ColorInstance.Frame_3
				ColorInstance.Frame_8.Active = true
				ColorInstance.Frame_8.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_8.BackgroundTransparency = 1
				ColorInstance.Frame_8.BorderSizePixel = 0
				ColorInstance.Frame_8.Position = UDim2.new(0.03353658691048622, 0, 0.034090910106897354, 0)
				ColorInstance.Frame_8.Size = UDim2.new(0.30792683362960815, 0, 0.9772727489471436, 0)
				ColorInstance.Frame_8.Name = 'Picker'

				ColorInstance.ImageLabel_2.Parent = ColorInstance.Frame_8
				ColorInstance.ImageLabel_2.Image = 'rbxassetid://328298876'
				ColorInstance.ImageLabel_2.Active = true
				ColorInstance.ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.ImageLabel_2.BorderColor3 = Color3.new(0.627451, 0.627451, 0.627451)
				ColorInstance.ImageLabel_2.ClipsDescendants = true
				ColorInstance.ImageLabel_2.Position = UDim2.new(0.04336318373680115, 0, -0.02036517858505249, 0)
				ColorInstance.ImageLabel_2.Size = UDim2.new(1, 0, 1, 0)
				ColorInstance.ImageLabel_2.SizeConstraint = Enum.SizeConstraint.RelativeYY
				ColorInstance.ImageLabel_2.ZIndex = 2
				ColorInstance.ImageLabel_2.Name = 'Gradient'

				ColorInstance.Frame_9.Parent = ColorInstance.ImageLabel_2
				ColorInstance.Frame_9.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.Frame_9.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_9.BorderSizePixel = 0
				ColorInstance.Frame_9.Position = UDim2.new(1, 0, 0, 1)
				ColorInstance.Frame_9.ZIndex = 2
				ColorInstance.Frame_9.Name = 'Cursor'

				ColorInstance.Frame_10.Parent = ColorInstance.Frame_9
				ColorInstance.Frame_10.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorInstance.Frame_10.BackgroundColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_10.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_10.BorderSizePixel = 0
				ColorInstance.Frame_10.Size = UDim2.new(0, 2, 0, 20)
				ColorInstance.Frame_10.ZIndex = 2
				ColorInstance.Frame_10.Name = 'Vertical'

				ColorInstance.Frame_11.Parent = ColorInstance.Frame_9
				ColorInstance.Frame_11.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorInstance.Frame_11.BackgroundColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_11.BorderColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_11.BorderSizePixel = 0
				ColorInstance.Frame_11.Size = UDim2.new(0, 20, 0, 2)
				ColorInstance.Frame_11.ZIndex = 2
				ColorInstance.Frame_11.Name = 'Horizontal'

				ColorInstance.TextButton_3.Parent = ColorInstance.Frame_3
				ColorInstance.TextButton_3.Font = Enum.Font.SourceSans
				ColorInstance.TextButton_3.Text = ''
				ColorInstance.TextButton_3.TextColor3 = Color3.new(0, 0, 0)
				ColorInstance.TextButton_3.TextSize = 14
				ColorInstance.TextButton_3.BackgroundColor3 = Color3.new(0.254902, 0.254902, 0.254902)
				ColorInstance.TextButton_3.Position = UDim2.new(0.38499999046325684, 0, 0.03400000184774399, 0)
				ColorInstance.TextButton_3.Size = UDim2.new(0.35499998927116394, 0, 0.3409999907016754, 0)
				ColorInstance.TextButton_3.AutoButtonColor = false
				ColorInstance.TextButton_3.Name = 'Rainbow'

				ColorInstance.Frame_12.Parent = ColorInstance.TextButton_3
				ColorInstance.Frame_12.BackgroundColor3 = Color3.new(0.215686, 0.215686, 0.215686)
				ColorInstance.Frame_12.BorderSizePixel = 0
				ColorInstance.Frame_12.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				ColorInstance.Frame_12.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				ColorInstance.Frame_12.Name = 'buttonShadow'

				ColorInstance.ImageLabel_3.Parent = ColorInstance.TextButton_3
				ColorInstance.ImageLabel_3.Image = 'http://www.roblox.com/asset/?id=6031068433'
				ColorInstance.ImageLabel_3.BackgroundTransparency = 1
				ColorInstance.ImageLabel_3.BorderSizePixel = 0
				ColorInstance.ImageLabel_3.Position = UDim2.new(0.7656951546669006, 0, 0.1666666716337204, 0)
				ColorInstance.ImageLabel_3.Size = UDim2.new(0.18893775343894958, 0, 0.6333333253860474, 0)

				ColorInstance.TextLabel_5.Parent = ColorInstance.TextButton_3
				ColorInstance.TextLabel_5.Font = Enum.Font.Gotham
				ColorInstance.TextLabel_5.Text = 'Rainbow'
				ColorInstance.TextLabel_5.TextColor3 = Color3.new(0.980392, 0.980392, 0.980392)
				ColorInstance.TextLabel_5.TextSize = 14
				ColorInstance.TextLabel_5.TextXAlignment = Enum.TextXAlignment.Left
				ColorInstance.TextLabel_5.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorInstance.TextLabel_5.BackgroundTransparency = 1
				ColorInstance.TextLabel_5.Position = UDim2.new(0.02700202167034149, 0, 0, 0)
				ColorInstance.TextLabel_5.Size = UDim2.new(0.5053310990333557, 0, 1, 0)

				ColorInstance.UICorner_5.Parent = ColorInstance.TextButton_3
				ColorInstance.UICorner_5.CornerRadius = UDim.new(0, 4)

				ColorInstance.Frame_13.Parent = ColorInstance.TextButton_3
				ColorInstance.Frame_13.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorInstance.Frame_13.BackgroundColor3 = Color3.new(0, 0, 0)
				ColorInstance.Frame_13.BackgroundTransparency = 1
				ColorInstance.Frame_13.ClipsDescendants = true
				ColorInstance.Frame_13.Position = UDim2.new(0.5, 0, 0.5, 0)
				ColorInstance.Frame_13.Size = UDim2.new(1, 0, 1, 0)
				ColorInstance.Frame_13.Name = 'Background'

				ColorInstance.UICorner_6.Parent = ColorInstance.Frame_13
				ColorInstance.UICorner_6.CornerRadius = UDim.new(0, 4)
				ColorInstance.UICorner_6.Name = 'CornerRadius'

				ColorInstance.UIStroke_2.Parent = ColorInstance.Frame_13
				ColorInstance.UIStroke_2.Color = Color3.new(0.0980392, 0.462745, 0.823529)
				ColorInstance.UIStroke_2.Thickness = 0
				ColorInstance.UIStroke_2.Transparency = 0.5
				ColorInstance.UIStroke_2.Name = 'Border'

				ColorInstance.LocalScript_3.Parent = ColorInstance.TextButton_2

				ColorInstance.Frame_14.Parent = ColorInstance.TextButton_1
				ColorInstance.Frame_14.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
				ColorInstance.Frame_14.Position = UDim2.new(0, 0, 0.9411764740943909, 0)
				ColorInstance.Frame_14.Size = UDim2.new(1, 0, 0.05882352963089943, 0)
				ColorInstance.Frame_14.Name = 'buttonShadow'

				ColorInstance.UICorner_7.Parent = ColorInstance.Frame_14
				ColorInstance.UICorner_7.CornerRadius = UDim.new(0, 4)

				ColorInstance.UIListLayout_2.Parent = ColorInstance.Frame_1
				ColorInstance.UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

				ColorInstance.UIPadding_1.Parent = ColorInstance.Frame_1

				local Button = ColorInstance.TextButton_1

				Button.MouseEnter:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 0.8},0.1)
				end)
				Button.MouseLeave:Connect(function()
					Util:Tween(Button.Background,{BackgroundTransparency = 1},0.1)
				end)


				local Shower = ColorInstance.TextButton_2
				local HF = Shower.HoldingFrame
				local opened = false
				local Main = HF.Parent.Parent.Parent

				Shower.Parent.MouseButton1Click:Connect(function()
					if opened then
						Util:Tween(Main,{Size = UDim2.new(0, 283,0, 34)},0.2)
						Util:Tween(HF,{Size = UDim2.new(0, 283,0, 0)},0.2)
						for i, v in pairs(Shower:GetDescendants()) do
							if v:IsA("TextLabel") then
								Util:Tween(v,{TextTransparency = 1},0.2)
							end
						end
						wait(0.2)
						opened = false
						HF.Visible = false
					else
						HF.Visible = true
						Util:Tween(Main,{Size = UDim2.new(0, 283,0, 127)},0.2)
						Util:Tween(HF,{Size = UDim2.new(0, 283,0, 88)},0.2)
						for i, v in pairs(Shower:GetDescendants()) do
							if v:IsA("TextLabel") then
								Util:Tween(v,{TextTransparency = 0},0.2)
							end
						end
						opened = true
					end
				end)

				local Players = game:GetService("Players")
				local TextService = game:GetService("TextService")
				local UserInputService = game:GetService("UserInputService")

				local ColorPicker = ColorInstance.Frame_3
				local Picker = ColorPicker:WaitForChild("Picker")

				local RGB = ColorPicker:WaitForChild("RGB")

				local RainbowB = ColorPicker.Rainbow


				local CurrentDisplay = ColorPicker.Parent

				local Gradient = Picker:WaitForChild("Gradient")
				local Cursor = Gradient:WaitForChild("Cursor")

				local Player = Players.LocalPlayer
				local Mouse = Player:GetMouse()


				local Down = false

				local Abs = math.abs
				local Clamp = math.clamp
				local Floor = math.floor

				local Tonumber = tonumber


				local function UpdateCursorPosition(h, s)
					local gradientSize = Gradient.AbsoluteSize
					local sizeScale = 360 / gradientSize.X
					Cursor.Position = UDim2.new(0, gradientSize.X - (h * 360) / sizeScale, 0, gradientSize.Y - (s * 360) / sizeScale)
				end

				local function InBounds()
					local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
					local gradientPosition = Gradient.AbsolutePosition
					local gradientSize = Gradient.AbsoluteSize

					return (mousePosition.X < (gradientPosition.X + gradientSize.X) and mousePosition.X > gradientPosition.X) and (mousePosition.Y < (gradientPosition.Y + gradientSize.Y) and mousePosition.Y > gradientPosition.Y)
				end

				local function SanitizeNumber(value, rgbValue, isHue)
					if value then
						value = (value ~= value and 0) or (tonumber(value) or 0)

						if isHue then
							return Clamp(value, 0, 360)
						else
							return Clamp(value, 0, (rgbValue and 255 or 1))
						end
					end
				end

				local function UpdateColorWithRGB()
					local color = Color3.fromRGB(Tonumber(RGB.R.Value.Text), Tonumber(RGB.G.Value.Text), Tonumber(RGB.B.Value.Text))
					CurrentDisplay.BackgroundColor3 = color
					callback(color)
					return color
				end

				local function UpdateFillIns(color)
					if color then
						local h, s, v = Color3.toHSV(color)
						local r, g, b = Floor(color.r * 255 + 0.5), Floor(color.g * 255 + 0.5), Floor(color.b * 255 + 0.5)

						RGB.R.Value.Text = r
						RGB.G.Value.Text = g
						RGB.B.Value.Text = b

						UpdateCursorPosition(h, s)
					end
				end
				RGB.R.Value.Text = math.floor(math.clamp(Default.R * 255,0,255), RGB.R.Value.Text)
				RGB.G.Value.Text = math.floor(math.clamp(Default.G * 255,0,255), RGB.G.Value.Text)
				RGB.B.Value.Text = math.floor(math.clamp(Default.B * 255,0,255), RGB.B.Value.Text)
				UpdateColorWithRGB()

				local function GetColor()
					if InBounds() then
						local gradientSize = Gradient.AbsoluteSize
						UserInputService.MouseIconEnabled = false

						local sizeScale = 360 / gradientSize.X
						local offset = Vector2.new(Mouse.X, Mouse.Y) - (Gradient.AbsolutePosition + gradientSize / 2)

						local hue = Abs((offset.X * sizeScale - 180) / 360)
						local saturation = Abs((offset.Y * sizeScale - 180) / 360)
						local color = Color3.fromHSV(hue, saturation, 1)

						CurrentDisplay.BackgroundColor3 = color
						callback(color)
						Cursor.Position = UDim2.new(0, Clamp(offset.X + gradientSize.X / 2, 0, gradientSize.X), 0, Clamp(offset.Y + gradientSize.Y / 2, 0, gradientSize.Y))

						return color
					end

					UserInputService.MouseIconEnabled = true
					return nil
				end

				ColorPicker.Picker.Gradient.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						UpdateFillIns(GetColor())
						Down = true
						ColorPicking = true
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								Down = false
								ColorPicking = false
							end
						end)
					end
				end)

				Mouse.Move:Connect(function()
					if Down then
						UpdateFillIns(GetColor())
					else
						UserInputService.MouseIconEnabled = true
					end
				end)

				Mouse.Button1Up:Connect(function()
					Down = false
				end)

				do
					local R = RGB.R.Value
					local G = RGB.G.Value
					local B = RGB.B.Value


					do
						R:GetPropertyChangedSignal("Text"):Connect(function()
							local text = R.Text

							if #text ~= 0 then
								R.Text = SanitizeNumber(text, true)
								UpdateFillIns(UpdateColorWithRGB())
							end
						end)

						G:GetPropertyChangedSignal("Text"):Connect(function()
							local text = G.Text

							if #text ~= 0 then
								G.Text = SanitizeNumber(text, true)
								UpdateFillIns(UpdateColorWithRGB())
							end
						end)

						B:GetPropertyChangedSignal("Text"):Connect(function()
							local text = B.Text

							if #text ~= 0 then
								B.Text = SanitizeNumber(text, true)
								UpdateFillIns(UpdateColorWithRGB())
							end
						end)
					end
				end

				RainbowB.MouseEnter:Connect(function()
					game.TweenService:Create(RainbowB.Background, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundTransparency = 0.8
					}):Play()
				end)
				RainbowB.MouseLeave:Connect(function()
					game.TweenService:Create(RainbowB.Background, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundTransparency = 1
					}):Play()
				end)

				local Rainbow = false
				RainbowB.MouseButton1Click:Connect(function()
					if Rainbow then 
						Rainbow = false
						RainbowB.ImageLabel.Image = "http://www.roblox.com/asset/?id=6031068433"
					else
						RainbowB.ImageLabel.Image = "http://www.roblox.com/asset/?id=6031068426"
						Rainbow = true
						repeat
							for i = 0,1,0.001*2 do
								if not Rainbow then break end
								UpdateFillIns(Color3.fromHSV(i,1,1))
								wait()
							end
						until not Rainbow		
					end
				end)


			end

			return ElementHandler

		end

		return SectionHandler


	end


	return TabHandler

end

warn("Loaded 1.2".." Wasted 2 hours fixing a bug when it was 1 line.")
return WindowTable


--local Window = WindowTable:CreateWindow({Title = "Ar Du Galen"})
--local tab1 = Window:CreateTab({Title = "Free", ScrollBar = true})
--local tab2 = Window:CreateTab({Title = "Paid", ScrollBar = true})

--local sec = tab1:CreateSection({
--	Title = "Section1"
--})

--local Label = sec:CreateLabel({
--	Title = "[STILL A WORK IN PROGRESS]",
--	Order = 1,
--})
--sec:CreateDropdown({
--	Text = "Dropdown",
--	Array = {"GGGgg","Ttttt","ggggg"},
--	Callback = function(val)
--		print(val)
--	end,
--})

--local OreEspToggle = sec:CreateToggle({
--	Title = "Defaulted Toggle",
--	Order = 1,
--	Default = true,
--	Callback = function(state)
--		print(state)
--	end
--})
--local Label = sec:CreateLabel({
--	Title = "Label",
--	Order = 1,
--})
--sec:CreateSlider({
--	Text = "Slider",
--	Min = 0,
--	Max = 100,
--	Default = 16,
--	Callback = function(val)
--		print(val)
--	end
--})
--sec:CreateSlider({
--	Text = "Slider",
--	Min = 16,
--	Max = 100,
--	Default = 50,
--	Callback = function(val)
--		print(val)
--	end
--})

--sec:CreateColorPicker({Title = "Gay sex", callback = function(returnval)
--	print(returnval)
--end,})
--local OreEspToggle = sec:CreateToggle({
--	Title = "Ore ESP",
--	Order = 1,
--	Callback = function(state)

--	end})

--sec:CreateColorPicker({Text = "Player ESP Color", Order = 4, callback = function(returnval)

--end,})

--local PlrEspToggle = sec:CreateToggle({
--	Title = "Player ESP",
--	Order = 3,
--	Callback = function(state)

--	end})



--Library:CreatePrompt({
--	Message = "Text Here",
--	Prompt = true,
--	Yes = "Yes Button Text",
--	No = "No Button Text",
--	GoAway = false,
--	Duration = 5,
--	Callback = function()

--	end,
--}) 

--Library:ToggleUI()

--Library:CreateWindow({
--	Title = "Title Text Here"
--})

--Window:CreateTab({
--	Title = "Tab Text Here", 
--	Default = true, --only set one to true
--	ScrollBar = true -- shows(doesnt) scrollbar
--})

--Tab:CreateSection({
--	Title = "OwOski"
--})
--Section:CreateButton({
--	Text = "fe",
--	Callback = function()
--		print("hi")
--	end
--})
--Section:CreateToggle({
--	Title = "fe",
--	Callback = function()
--		print("hi")
--	end
--})

--Section:CreateSlider({
--	Text = "Slider Text",
--	Min = 0,
--	Max = 100,
--	Default = 16,
--	Callback = function()
--		print("hi")
--	end
--})
--sec:CreateKeybind({
--	Text = "Keybind Text",
--	Default = "K",
--	Callback = function()
--		print("hi")
--	end
--})
--Section:CreateDropdown({
--	Text = "Dropdown Text",
--	Array = {"Orange","Bananas"},
--	Callback = function()

--	end,
--})

--Dropdown:UpdateDropdown(NewArray)
