local started = tick()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Service = fetch('classes/Service')
local httpService, players, scriptContext = Service:Get('HttpService', 'Players', 'ScriptContext')

local games = httpService:JSONDecode(fetch('games', true))
local gameName = games[tostring(game.GameId)]

-- // these games require signal fix
local shitGames = {'sls', 'pe'}
_G.sigFix = table.find(shitGames, getShortName(gameName or 'Universal'))

local library = fetch('ui')

local formatted = formatName(gameName and (gameName:sub(1, 2) == '__' and gameName:sub(3) or gameName) or 'Universal')
local title = gameName and (gameName:len() < 5 and gameName or formatted) or formatted

library.title = library.title .. ' | ' .. title
library.gameName = gameName

if gameName then
	local tab = library:AddTab('Main', 1)
	library.sides = {
		tab:AddColumn(),
		tab:AddColumn()
	}

	if gameName:sub(1, 2) == '__' then
		printf('[main] fetching private script')

		local func, err = loadstring(readfile('ChocolateHub/scripts/' .. gameName:sub(3) .. '.luau'))
		if not func then
			warn('[main] an error occured when loading private script:', err)
			return
		end

		func()
	else
		if isfile('ChocolateHub/scripts/' .. gameName .. '.luau') then
			printf('[main] fetching public script from local file')

			local func, err = loadstring(readfile('ChocolateHub/scripts/' .. gameName .. '.luau'))
			if not func then
				warn('[main] an error occured when loading script:', err)
				return
			end

			func()
		else
			printf('[main] fetching public script from server')
			fetch('games/' .. gameName)
		end
	end
end

library.funcs = {}
fetch('games/core/Visuals')
fetch('games/core/Aiming')
fetch('games/core/Universal')

local executed = false
_G.tpString = [[
	loadstring(game:HttpGet('https://raw.githubusercontent.com/ChocolateDrink/ChocolateHub/refs/heads/main/loader.luau'))()
]]

library.unloadMaid:GiveTask(players.LocalPlayer.OnTeleport:Connect(function(state)
	if executed or state ~= Enum.TeleportState.InProgress then return end
	executed = true

	queue_on_teleport(_G.tpString)
end))

for _, v in next, getconnections(scriptContext.Error) do
	v:Disable()
end

library:Init()

printf('[main] loaded in %.02f seconds', tick() - started)

_G.debug = false