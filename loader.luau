local base = 'https://raw.githubusercontent.com/femrawr/ChocolateHub/refs/heads/main/'
local function fetchScript(url, json)
	local concatenated = base .. url .. (json and '.json' or '.luau')
	local suc, res = pcall(game.HttpGet, game, concatenated)

	if not suc or table.find({'404: Not Found', '400: Invalid Request'}, res) then
		warn(string.format('[fetch] [failed to fetch] %s - %s', url, res))
		return nil
	end

	if json then return res end

	local func, err = loadstring(res, url)
	if not func then
		warn(string.format('[fetch] [syntax error] %s - %s', url, err))
		return nil
	end

	return func()
end

local function formatPrint(text, ...)
	return print(string.format(text, ...))
end

if isfunctionhooked(warn) and _G.oldWarn then
	hookfunction(warn, _G.oldWarn)
end

if isfunctionhooked(print) and _G.oldPrint then
	hookfunction(print, _G.oldPrint)
end

local oldWarn, oldPrint
oldWarn = hookfunction(warn, function(...)
	if not checkcaller() then return oldWarn(...) end
	if not _G.debug then return end
	return oldWarn('[debug]', ...)
end)
oldPrint = hookfunction(print, function(...)
	if not checkcaller() then return oldPrint(...) end
	if not _G.debug then return end
	return oldPrint('[debug]', ...)
end)

getgenv().getShortName = function(str)
	local buffer = ''
	for i = 1, #str do
		local char = str:sub(i, i)
		if char:match('%u') then
			buffer ..= char
		end
	end

	return buffer:lower()
end

getgenv().formatName = function(str)
	local buffer = ''
	for i = 1, #str do
		local char = str:sub(i, i)
		if char:match('%u') and i > 1 then
			buffer ..= ' '
		end

		buffer ..= char
	end

	return buffer
end

getgenv().fetch = fetchScript
getgenv().printf = formatPrint

_G.oldWarn = oldWarn
_G.oldPrint = oldPrint

_G.debug = true

fetchScript('main')
