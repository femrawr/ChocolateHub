local EntityESP = {}
EntityESP.__index = EntityESP

local entity = fetch('utils/entity')

local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))

local function set(self, p, v) self[p] = v end
local function get(self, p) return self[p] end

local flags = library.flags

local vector3New = Vector3.new
local Vector2New = Vector2.new
local mathFloor = math.floor

local maxEspDistance
local showTeam, useTeamColor, allyColor, enemyColor
local showName, showDistance, showHealth, useFloatHealth
local toggleBoxes, toggleHealthBar, toggleTracers, unlockTracers
local lowHpColor, highHpColor = Color3.new(1, 0, 0), Color3.new(0, 1, 0)

local labelOffset
local boxOffsetTopRight
local boxOffsetBottomLeft
local tracerOffset
local healthBarOffsetTopRight
local healthBarOffsetBottomLeft
local healthBarValueOffsetTopRight
local healthBarValueOffsetBottomLeft

do
	function EntityESP.new(player)
		local self = setmetatable({}, EntityESP)

		self._player = player
		self._playerName = player.Name

		self._label = Drawing.new('Text')
		self._label.Visible = false
		self._label.Center = true
		self._label.Outline = true
		self._label.Text = ''
		self._label.Font = Drawing.Fonts.Plex
		self._label.Size = 17
		self._label.Color = Color3.new(1, 1, 1)

		self._box = Drawing.new('Quad')
		self._box.Visible = false
		self._box.Thickness = 1
		self._box.Filled = false
		self._box.Color = Color3.new(1, 1, 1)

		self._healthBar = Drawing.new('Quad')
		self._healthBar.Visible = false
		self._healthBar.Thickness = 1
		self._healthBar.Filled = false
		self._healthBar.Color = Color3.new(1, 1, 1)

		self._healthBarValue = Drawing.new('Quad')
		self._healthBarValue.Visible = false
		self._healthBarValue.Thickness = 1
		self._healthBarValue.Filled = true
		self._healthBarValue.Color = Color3.new(0, 1, 0)

		self._line = Drawing.new('Line')
		self._line.Visible = false
		self._line.Color = Color3.new(1, 1, 1)

		self._visible = false
		self._labelObject = self._label

		return self
	end

	function EntityESP:Plugin()
		return {}
	end

	function EntityESP:Convert(x, y, z)
		return self._cameraCFrame:VectorToWorldSpace(vector3New(x, y, z))
	end

	function EntityESP:Update()
		local camera = self._camera
		if not camera then return self:Hide() end

		local character, floatHealth, root, health, maxHealth = entity.getData(self._player)
		if not character or not root then return self:Hide() end

		local rootPos = root.Position
		local labelPos, visible = camera:WorldToViewportPoint(rootPos + labelOffset)

		local isTeamMate = entity.isSameTeam(self._player)
		if isTeamMate and not showTeam then return self:Hide() end

		local distance = (rootPos - self._cameraPosition).Magnitude
		if distance > maxEspDistance then return self:Hide() end

		local espColor = useTeamColor and self._player.TeamColor.Color or isTeamMate and allyColor or enemyColor

		if not visible then return self:Hide() end
		self._visible = visible

		local label, box, line, healthBar, healthBarValue = self._label, self._box, self._line, self._healthBar, self._healthBarValue

		local pluginData = self:Plugin()
		local nameText = showName and '['.. (pluginData.playerName or self._playerName).. '] ' or ''
		local distanceText = showDistance and '['.. mathFloor(distance).. ']\n' or ''
		local healthText = showHealth and (useFloatHealth and '['.. mathFloor(floatHealth).. '%]' or '['.. mathFloor(health).. '/'.. mathFloor(maxHealth).. ']') or ''

		local text = nameText.. distanceText.. healthText.. (pluginData.text or '')

		set(label, 'Visible', visible)
		set(label, 'Position', Vector2New(labelPos.X, labelPos.Y - get(self._labelObject, 'TextBounds').Y))
		set(label, 'Text', text)
		set(label, 'Color', espColor)

		if toggleBoxes then
			local boxTopRight = camera:WorldToViewportPoint(rootPos + boxOffsetTopRight)
			local boxBottomLeft = camera:WorldToViewportPoint(rootPos + boxOffsetBottomLeft)

			local topRightX, topRightY = boxTopRight.X, boxTopRight.Y
			local bottomLeftX, bottomLeftY = boxBottomLeft.X, boxBottomLeft.Y

			set(box, 'Visible', visible)

			set(box, 'PointA', Vector2New(topRightX, topRightY))
			set(box, 'PointB', Vector2New(bottomLeftX, topRightY))
			set(box, 'PointC', Vector2New(bottomLeftX, bottomLeftY))
			set(box, 'PointD', Vector2New(topRightX, bottomLeftY))
			set(box, 'Color', espColor)
		else
			set(box, 'Visible', false)
		end

		if toggleTracers then
			local linePosition = camera:WorldToViewportPoint(rootPos + tracerOffset)

			set(line, 'Visible', visible)

			set(line, 'From', unlockTracers and inputService:GetMouseLocation() or self._viewportSize)
			set(line, 'To', Vector2New(linePosition.X, linePosition.Y))
			set(line, 'Color', espColor)
		else
			set(line, 'Visible', false)
		end

		if toggleHealthBar then
			local healthBarValueHealth = (1 - (floatHealth / 100)) * 7.4

			local healthBarTopRight = camera:WorldToViewportPoint(rootPos + healthBarOffsetTopRight)
			local healthBarBottomLeft = camera:WorldToViewportPoint(rootPos + healthBarOffsetBottomLeft)

			local healthBarTopRightX, healthBarTopRightY = healthBarTopRight.X, healthBarTopRight.Y
			local healthBarBottomLeftX, healthBarBottomLeftY = healthBarBottomLeft.X, healthBarBottomLeft.Y

			local healthBarValueTopRight = camera:WorldToViewportPoint(rootPos + healthBarValueOffsetTopRight - self:Convert(0, healthBarValueHealth, 0))
			local healthBarValueBottomLeft = camera:WorldToViewportPoint(rootPos - healthBarValueOffsetBottomLeft)

			local healthBarValueTopRightX, healthBarValueTopRightY = healthBarValueTopRight.X, healthBarValueTopRight.Y
			local healthBarValueBottomLeftX, healthBarValueBottomLeftY = healthBarValueBottomLeft.X, healthBarValueBottomLeft.Y

			set(healthBar, 'Visible', visible)
			set(healthBar, 'Color', espColor)

			set(healthBar, 'PointA', Vector2New(healthBarTopRightX, healthBarTopRightY))
			set(healthBar, 'PointB', Vector2New(healthBarBottomLeftX, healthBarTopRightY))
			set(healthBar, 'PointC', Vector2New(healthBarBottomLeftX, healthBarBottomLeftY))
			set(healthBar, 'PointD', Vector2New(healthBarTopRightX, healthBarBottomLeftY))

			set(healthBarValue, 'Visible', visible)
			set(healthBarValue, 'Color', lowHpColor:Lerp(highHpColor, floatHealth / 100))

			set(healthBarValue, 'PointA', Vector2New(healthBarValueTopRightX, healthBarValueTopRightY))
			set(healthBarValue, 'PointB', Vector2New(healthBarValueBottomLeftX, healthBarValueTopRightY))
			set(healthBarValue, 'PointC', Vector2New(healthBarValueBottomLeftX, healthBarValueBottomLeftY))
			set(healthBarValue, 'PointD', Vector2New(healthBarValueTopRightX, healthBarValueBottomLeftY))
		else
			set(healthBar, 'Visible', false)
			set(healthBarValue, 'Visible', false)
		end
	end

	function EntityESP:Destroy()
		if not self._label then return end

		self._label:Destroy()
		self._label = nil

		self._box:Destroy()
		self._box = nil

		self._line:Destroy()
		self._line = nil

		self._healthBar:Destroy()
		self._healthBar = nil

		self._healthBarValue:Destroy()
		self._healthBarValue = nil
	end

	function EntityESP:Hide()
		if not self._visible then return end
		self._visible = false

		set(self._label, 'Visible', false)
		set(self._box, 'Visible', false)
		set(self._line, 'Visible', false)

		set(self._healthBar, 'Visible', false)
		set(self._healthBarValue, 'Visible', false)
	end
end

do
	local function updateESP()
		local camera = workspace.CurrentCamera
		EntityESP._camera = camera
		if not camera then return end

		EntityESP._cameraCFrame = EntityESP._camera.CFrame
		EntityESP._cameraPosition = EntityESP._cameraCFrame.Position

		local viewportSize = camera.ViewportSize
		EntityESP._viewportSize = Vector2New(viewportSize.X / 2, viewportSize.Y - 10)
		EntityESP._viewportSizeCenter = viewportSize / 2

		maxEspDistance = flags.espMaxDistance
		showTeam = flags.espShowTeam
		useTeamColor = flags.espUseTeamColor
		allyColor = flags.espAllyColor
		enemyColor = flags.espEnemyColor
		showName = flags.espShowName
		showDistance = flags.espShowDistance
		showHealth = flags.espShowHealth
		useFloatHealth = flags.espUseFloatHealth
		toggleBoxes = flags.espRenderBoxes
		toggleHealthBar = flags.espRenderHealthBar
		toggleTracers = flags.espRenderTracers
		unlockTracers = flags.espUnloackTraces
		lowHpColor = flags.espLowHealthColor
		highHpColor = flags.espHighHealthColor

		labelOffset = EntityESP:Convert(0, 3.25, 0)
		boxOffsetTopRight = EntityESP:Convert(2.5, 3, 0)
		boxOffsetBottomLeft = EntityESP:Convert(-2.5, -4.5, 0)
		tracerOffset = EntityESP:Convert(0, -4.5, 0)
		healthBarOffsetTopRight = EntityESP:Convert(-3, 3, 0)
		healthBarOffsetBottomLeft = EntityESP:Convert(-3.5, -4.5, 0)
		healthBarValueOffsetTopRight = EntityESP:Convert(-3.05, 2.95, 0)
		healthBarValueOffsetBottomLeft = EntityESP:Convert(3.45, 4.45, 0)
	end

	updateESP()
	runService:BindToRenderStep('', Enum.RenderPriority.Camera.Value, updateESP)
end

return EntityESP