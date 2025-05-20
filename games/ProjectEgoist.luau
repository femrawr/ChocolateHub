local Service = fetch('classes/Service')
local Maid = fetch('classes/Maid')

local players, repoStore, runService = Service:Get(
	'Players',
	'ReplicatedStorage',
	'RunService'
)

local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local playerGUI = localPlayer.PlayerGui

local world = workspace.World
local remotes = repoStore.Remotes
local modules = repoStore.Modules

local maid = Maid.new()

local funcs = {}
local main = {}

do -- main
	main = {
		guiRemote = playerGUI.MainGUI['Handler (MainGUI)'].RemoteEvent,

		mainModule = require(modules.Generals.MainModule)
	}

	maid.fakeDebugPart = cloneref(Instance.new('Part'))
	maid.fakeDebugPart.Transparency = 1
	maid.fakeDebugPart.Anchored = true
	maid.fakeDebugPart.CanCollide = false
	maid.fakeDebugPart.CanTouch = false
	maid.fakeDebugPart.CFrame = CFrame.new(0, 9e9, 0)
	maid.fakeDebugPart.Size = Vector3.one
	maid.fakeDebugPart.CastShadow = false
	maid.fakeDebugPart.Parent = nil
	maid.fakeDebugPart.Name = 'debug'

	library.unloadMaid:GiveTask(maid.fakeDebugPart)
end

do -- hooks
	local function onCharacterAdded(char)
		local client = char:WaitForChild('CharacterClient', 50)
		if not client then return end

		local clientENV = getsenv(client)

		local oldRequestBall
		oldRequestBall = hookfunction(clientENV.RequestBall, function(...)
			if library.flags.noRequestBallDelay then
				clientENV.SendRemote({
					Function = 'RequestBall'
				})

				remotes.ClientEvent:Fire('GlobalVFX', {
					Function = 'RequestBall',
					Character = char
				})

				return
			end

			return oldRequestBall(...)
		end)

		local oldDribble
		oldDribble = hookfunction(clientENV.Dribble, function(...)
			if library.flags.noDiveDelay then
				local dir = char.Info.HoldingBall.Value
				if dir == 'Front' or dir == 'Back' then
					clientENV.SendRemote({
						Function = 'GKSlide'
					})

					return
				end

				if not main.mainModule.HoldingBall(char) then
					clientENV.SendRemote({
						Function = 'GKDash'
					})

					remotes.ClientEvent:Fire('PlayerClient', {
						Function = 'GkDash',
						Character = char,
						Direction = dir
					})
				end

				clientENV.SendRemote({
					Function = 'Dribble'
				})

				return
			end

			return oldDribble(...)
		end)
	end

	task.spawn(onCharacterAdded, localPlayer.Character)

	library.unloadMaid:GiveTask(localPlayer.CharacterAdded:Connect(onCharacterAdded))
end

do -- funcs
	function funcs.fakeDebug(t)
		maid.fakeDebugPart.Parent = t and workspace or nil
	end

	function funcs.autoDailyReward()
		while library.flags.autoClaimReward do
			for i = 1, 7 do
				main.guiRemote:FireServer({
					Function = 'DailyRewardClaim',
					Day = i
				})
			end

			task.wait(30)
		end
	end
end

do -- ui
	local left = unpack(library.sides)
	local main = left:AddSection('Main')

	do -- main
		main:AddToggle({
			text = 'No Request Ball Delay',
			tip = 'Removes the delay when you request the ball.'
		})

		main:AddToggle({
			text = 'No Dive Delay',
			tip = 'Removes the goal keeper dive delay.'
		})

		main:AddToggle({
			text = 'Ball Trajectory',
			tip = 'Always shows the ball trajectory visualizer.',
			callback = funcs.fakeDebug
		})

		main:AddToggle({
			text = 'Auto Claim Reward',
			tip = 'Automatically claims the daily reward.',
			callback = funcs.autoDailyReward
		})
	end
end