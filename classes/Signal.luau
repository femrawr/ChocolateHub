local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)

	self._event = cloneref(Instance.new('BindableEvent'))
	self._argData = nil
	self._argCount = nil

	return self
end

function Signal.isSignal(obj)
	return typeof(obj) == 'table' and getmetatable(obj) == Signal
end

function Signal:Fire(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._event:Fire()

	if not _G.sigFix then
		self._argData = nil
		self._argCount = nil
	end
end

function Signal:Connect(handler)
	if not self._event then
		warn('signal does not exist')
		return
	end

	if typeof(handler) ~= 'function' then
		warn('handler must be a function')
		return
	end

	return self._event.Event:Connect(function()
		handler(unpack(self._argData, 1, self._argCount))
	end)
end

function Signal:Wait()
	self._event.Event:Wait()
	return unpack(self._argData, 1, self._argCount)
end

function Signal:Destroy()
	if self._event then
		self._event:Destroy()
		self._event = nil
	end

	self._argData = nil
	self._argCount = nil
end

return Signal