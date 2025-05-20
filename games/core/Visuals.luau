local tab = library:AddTab('Visuals', 500)
local left, right = tab:AddColumn(), tab:AddColumn()

local Service = fetch('classes/Service')
local Maid = fetch('classes/Maid')
local EntityESP = fetch('classes/EntityESP')

local players, runService = Service:Get(
	'Players',
	'RunService'
)

local localPlayer = players.LocalPlayer

local maid = Maid.new()
local entities = {}

local function onPlayerAdded(player)
	if player == localPlayer then return end
	local esp = EntityESP.new(player)

	library.unloadMaid[player] = function()
		table.remove(entities, table.find(entities, esp))
		esp:Destroy()
	end

	table.insert(entities, esp)
end

local function onPlayerRemoving(player)
	library.unloadMaid[player] = nil
end

library.OnLoad:Connect(function()
	players.PlayerAdded:Connect(onPlayerAdded)
	players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, v in next, players:GetPlayers() do
		task.spawn(onPlayerAdded, v)
	end
end)

local function toggleESP(t)
	if not t then
		maid.esp = nil
		for _, v in next, entities do
			v:Hide()
		end

		return
	end

	local lastUpdated = 0

	maid.esp = runService.RenderStepped:Connect(function()
		if tick() - lastUpdated < 0.01 then return end
		lastUpdated = tick()

		for _, v in next, entities do
			v:Update()
		end
	end)
end

do -- ui
	local espSettings = left:AddSection('ESP Settings') do
		espSettings:AddToggle({
			text = 'Enabled',
			flag = 'esp',
			callback = toggleESP
		}):AddBind({
			flag = 'esp bind',
			callback = function()
				library.options.esp:SetState(not library.flags.esp)
			end
		})

		espSettings:AddDivider()

		espSettings:AddSlider({
			text = 'Max Distance',
			flag = 'esp max distance',
			value = 10000,
			min = 50,
			max = 10000,
			callback = function(val)
				if val == 10000 then
					val = math.huge
				end

				library.flags.espMaxDistance = val
			end
		})

		espSettings:AddToggle({
			text = 'Render Boxes',
			flag = 'esp render boxes',
			state = true
		})

		espSettings:AddToggle({
			text = 'Render Health Bar',
			flag = 'esp render health bar'
		})

		espSettings:AddToggle({
			text = 'Render Tracers',
			flag = 'esp render tracers'
		})

		espSettings:AddDivider()

		espSettings:AddToggle({
			text = 'Show Name',
			flag = 'esp show name'
		})

		espSettings:AddToggle({
			text = 'Show Distance',
			flag = 'esp show distance'
		})

		espSettings:AddToggle({
			text = 'Show Health',
			flag = 'esp show health'
		})
	end

	local espCustomization = right:AddSection('ESP Customization') do
		espCustomization:AddColor({
			text = 'Ally Color',
			flag = 'esp ally color',
			color = Color3.new(0, 1, 0)
		})

		espCustomization:AddColor({
			text = 'Enemy Color',
			flag = 'esp enemy color',
			color = Color3.new(1, 0, 0)
		})

		espCustomization:AddToggle({
			text = 'Use Team Color',
			flag = 'esp use team color'
		})

		espCustomization:AddDivider()

		espCustomization:AddColor({
			text = 'Low Health Color',
			flag = 'esp low health color',
			color = Color3.new(1, 0, 0)
		})

		espCustomization:AddColor({
			text = 'High Health Color',
			flag = 'esp high health color',
			color = Color3.new(0, 1, 0)
		})

		espCustomization:AddDivider()

		espCustomization:AddToggle({
			text = 'Use Float Health',
			flag = 'esp use float health'
		})

		espCustomization:AddToggle({
			text = 'Unlock Tracers',
			flag = 'esp unloack traces'
		})

		espCustomization:AddToggle({
			text = 'Show Teammates',
			flag = 'esp show team'
		})
	end
end