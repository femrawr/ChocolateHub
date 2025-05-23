local Service = fetch('classes/Service')
local Maid = fetch('classes/Maid')

local players, repoStore, virtualInput, inputService, runService = Service:Get(
	'Players',
	'ReplicatedStorage',
	'VirtualInputManager',
	'UserInputService',
	'RunService'
)

local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local maid = Maid.new()

local funcs = {}
local main = {}

do -- main
	local controllers = localPlayer.PlayerScripts.Client.Controllers
	local knit = require(repoStore.Packages.Knit)

	local animations = repoStore.Assets.Animations

	main = {
		animations = animations,

		leapAction = require(controllers.Action.Leap),

		actionService = knit.GetService('ActionService'),
		matchController = knit.GetController('MatchController'),
		movementController = knit.GetController('MovementController'),
		staminaController = knit.GetController('StaminaController')
	}

	maid.ballAuraPart = cloneref(Instance.new('Part'))
	maid.ballAuraPart.Transparency = 0.75
	maid.ballAuraPart.Anchored = true
	maid.ballAuraPart.CanCollide = false
	maid.ballAuraPart.CanTouch = false
	maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0)
	maid.ballAuraPart.Size = Vector3.one
	maid.ballAuraPart.Shape = Enum.PartType.Ball
	maid.ballAuraPart.CastShadow = false
	maid.ballAuraPart.Material = Enum.Material.ForceField
	maid.ballAuraPart.Color = Color3.fromRGB(255, 0, 0)
	maid.ballAuraPart.Parent = nil

	function funcs.hideBall()
		maid.ballAuraPart.Parent = nil
		maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0)
		maid.ballAuraPart.Size = Vector3.one
	end

	library.unloadMaid:GiveTask(maid.ballAuraPart)
end

do -- hooks
	local oldNamecall
	local function onNamecall(self, ...)
		local method = getnamecallmethod()
		local caller = getcallingscript()

		if method:lower() == 'kick' and tostring(caller):lower() == 'anticheat' and self == localPlayer then
			return
		end

		return oldNamecall(self, ...)
	end

	oldNamecall = hookmetamethod(game, '__namecall', onNamecall)

	local oldConsume
	oldConsume = hookfunction(main.staminaController.Consume, function(...)
		if library.flags.infiniteStamina then
			return true
		end

		return oldConsume(...)
	end)

	library.unloadMaid:GiveTask(main.movementController.SprintChanged:Connect(function(val)
		if val == false and library.flags.keepSprint then
			main.movementController.Sprinting:set(true)

			local hum = localPlayer.Character:FindFirstChildOfClass('Humanoid')
			if hum then hum.WalkSpeed = main.movementController:GetSpeed(true) end
		end
	end))
end

do -- funcs
	function funcs.keepSprint()
		if inputService:GetFocusedTextBox() then return end

		virtualInput:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
		task.wait()
		virtualInput:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
	end

	function funcs.ballAura(t)
		while library.flags.ballAura do
			local root = localPlayer.Character and localPlayer.Character.PrimaryPart
			if not root then
				funcs.hideBall()
				task.wait()
				continue
			end

			local ball = workspace.Junk:FindFirstChild('Football')
			if not ball then
				funcs.hideBall()
				task.wait()
				continue
			end

			if library.flags.ballAuraVisuals then
				maid.ballAuraPart.Parent = camera
				maid.ballAuraPart.CFrame = root.CFrame
				maid.ballAuraPart.Size = Vector3.one * library.flags.ballAuraRange
			else
				funcs.hideBall()
			end

			local mag = (root.CFrame.Position - ball.CFrame.Position).Magnitude
			if mag > library.flags.ballAuraRange then task.wait() continue end

			if ball:GetAttribute('State') ~= 'Released' then task.wait() continue end

			main.actionService.PerformAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'))
			task.wait()
		end

		funcs.hideBall()
	end

	function funcs.antiTackle()
		while library.flags.antiTackle do
			local ball = main.matchController:GetComponent('Football')
			if not ball or not ball:HasFootball() then task.wait() continue end

			main.actionService:PerformActionThenGet('EvadeActivated')
			task.wait()
		end
	end

	function funcs.noDiveDelay(t)
		local func = debug.getupvalue(main.leapAction.BindActionToController, 7)
		debug.setconstant(func, 35, t and 0 or 0.7)
	end

	function funcs.changeTeam()
		if not localPlayer:GetAttribute('TeamPosition') then return end
		localPlayer:SetAttribute('TeamPosition', library.flags.positionChooser)
	end

	function funcs.getBall()
		local ball = workspace.Junk:FindFirstChild('Football')
		if not ball then return end

		main.actionService.PerformAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'))
	end

	function funcs.breakGame()
		funcs.shootBall('break')
	end

	function funcs.shootBall(mode)
		local root = localPlayer.Character and localPlayer.Character.PrimaryPart
		if not root then return end

		local gameBall = main.matchController:GetComponent('Football')
		if not gameBall then return end

		local ownedBall = gameBall:GetPossessedFootball()
		if not ownedBall then return end

		local ball = gameBall:GetFootballComponent(ownedBall)
		if not ball then return end

		local force = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z) * library.flags.shootBallVelocity

		ownedBall:SetAttribute('State', 'Released')
		if mode == 'break' then
			ball:Shoot(Vector3.new(0, -10, 0), Vector3.zero)
		else
			ball:Shoot(root.CFrame.Position, force)
		end
	end
end

do -- modules
	local left, right = unpack(library.sides)
	local ballRelated = right:AddSection('Ball Related')
	local gameplay = left:AddSection('Gameplay')

	do -- gameplay
		gameplay:AddToggle({
			text = 'Ball Aura',
			tip = 'instantly get the ball when its close to you',
			callback = funcs.ballAura
		})

		gameplay:AddSlider({
			text = 'range',
			flag = 'ball aura range',
			min = 10,
			max = 50,
			value = 20
		})

		gameplay:AddToggle({
			text = 'Visualizer',
			flag = 'ball aura visuals',
			state = true
		})

		gameplay:AddDivider()

		gameplay:AddToggle({
			text = 'Anti Tackle',
			tip = 'makes it harder for people to tackle you',
			callback = funcs.antiTackle
		})

		gameplay:AddToggle({
			text = 'No Dive Delay',
			tip = 'removes the goal keeper dive delay',
			callback = funcs.noDiveDelay
		})

		gameplay:AddDivider()

		gameplay:AddList({
			text = 'Position Chooser',
			tip = 'use the keybind to change your team',
			values = { 'GK', 'CF', 'LF', 'RF', 'CM', 'LB', 'RB' }
		}):AddBind({
			flag = 'position chooser bind',
			callback = funcs.changeTeam
		})

		gameplay:AddDivider()

		gameplay:AddToggle({
			text = 'Infinite Stamina'
		})

		gameplay:AddToggle({
			text = 'Keep Sprint',
			callback = funcs.keepSprint
		})
	end

	do -- ball related
		ballRelated:AddBind({
			text = 'Get Ball Bind',
			callback = funcs.getBall
		})

		ballRelated:AddButton({
			text = 'Get Ball',
			tip = 'get the ball from anywhere on the map',
			callback = funcs.getBall
		})

		ballRelated:AddDivider()

		ballRelated:AddBind({
			text = 'Break Game Bind',
			callback = funcs.breakGame
		})

		ballRelated:AddButton({
			text = 'Break Game',
			tip = 'removes the ball from the game',
			callback = funcs.breakGame
		})

		ballRelated:AddDivider()

		ballRelated:AddBind({
			text = 'shoot Ball Bind',
			callback = funcs.shootBall
		})

		ballRelated:AddButton({
			text = 'shoot Ball',
			tip = 'shoots the ball at a higher velocity',
			callback = funcs.shootBall
		})

		ballRelated:AddSlider({
			text = 'Ball Velocity',
			flag = 'shoot ball velocity',
			tip = 'how fast the ball will travel',
			max = 1500,
			min = 100,
			value = 500
		})

		--ballRelated:AddToggle({
		--	text = 'Teleport Ball',
		--	flag = 'shoot ball t p',
		--	tip = 'teleports the ball into the opposing team\'s goal post'
		--})
	end
end