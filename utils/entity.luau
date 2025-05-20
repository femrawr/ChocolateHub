local entity = {}

local players = cloneref(game:GetService('Players'))
local input = cloneref(game:GetService('UserInputService'))

local localPlayer = players.localPlayer

function entity.getList()
	return players:GetPlayers()
end

function entity.getRoot()
	local char = localPlayer.Character
	if not char then
		return nil
	end

	local root = char:FindFirstChild('HumanoidRootPart')
	local hum = char:FindFirstChildOfClass('Humanoid')

	return root, hum
end

function entity.getData(player, tab)
	if typeof(player) == 'string' then
		player = players:FindFirstChild(player)
	elseif typeof(player) == 'Instance' then
		player = players:FindFirstChild(player.Name)
	else
		player = localPlayer
	end

	local character = player.Character
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass('Humanoid')
	if not humanoid then
		return nil
	end

	local root = character:FindFirstChild('HumanoidRootPart')
	if not root then
		return nil
	end

	local health, maxHealth  = humanoid.Health, humanoid.MaxHealth
	local floatHealth = (health / maxHealth) * 100

	if tab then
		return {char = character, float = floatHealth, floored = math.floor(health), max = maxHealth, root = root, pos = root.CFrame.Position}
	else
		return character, floatHealth, root, math.floor(health), maxHealth
	end
end

function entity.isBehindWall(player, part)
	return #workspace.CurrentCamera:GetPartsObscuringTarget({part.CFrame.Position}, player.Character:GetDescendants()) > 0
end

function entity.isSameTeam(player)
	local myTeam, thierTeam = localPlayer.Team, player.Team

	if not myTeam or not thierTeam then
		return
	end

	return myTeam == thierTeam
end

function entity.closestToMouse(options)
	options = options or {}
	local found = nil

	local part = options.part or 'HumanoidRootPart'
	local range = options.range or math.huge

	for _, v in next, entity.getList() do
		if v == localPlayer then continue end

		local otherData = entity.getData(v, true)
		if typeof(otherData) ~= 'table' then continue end
		if not otherData.char or otherData.float <= 0 then continue end

		local targetPart = otherData.char:FindFirstChild(part)
		if not targetPart then continue end

		if options.wallCheck and entity.isBehindWall(v, targetPart) then continue end
		if options.teamCheck and entity.isSameTeam(v) then continue end
		if options.customCheck and options.customCheck() then continue end

		local vector, visible = workspace.CurrentCamera:WorldToViewportPoint(targetPart.CFrame.Position)
		local magnitude = (input:GetMouseLocation() - Vector2.new(vector.X, vector.Y)).Magnitude

		if magnitude > range or not visible then continue end

		found = v
		range = magnitude
	end

	return found
end

function entity.closestToPosition(options)
	options = options or {}
	local found = nil

	local localData = entity.getData(1, true)
	local part = options.part or 'HumanoidRootPart'
	local range = options.range or math.huge

	for _, v in next, entity.getList() do
		if v == localPlayer then continue end

		local otherData = entity.getData(v, true)
		if typeof(otherData) ~= 'table' then continue end
		if not otherData.char or otherData.float <= 0 then continue end

		local targetPart = otherData.char:FindFirstChild(part)
		if not targetPart then continue end

		if options.wallCheck and entity.isBehindWall(v, targetPart) then continue end
		if options.teamCheck and entity.isSameTeam(v) then continue end
		if options.customCheck and options.customCheck() then continue end

		local magnitude = (localData.pos - otherData.pos).Magnitude
		if magnitude > range then continue end

		found = v
		range = magnitude
	end

	return found
end

return entity