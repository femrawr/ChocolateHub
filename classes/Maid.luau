local Maid = {}
Maid.__index = Maid

local Signal = fetch('classes/Signal')

function Maid.new()
	local self = setmetatable({
		_tasks = {}
	}, Maid)

	return self
end

function Maid.isMaid(obj)
	return typeof(obj) == 'table' and getmetatable(obj) == Maid
end

function Maid:GiveTask(task)
	local taskId = #self._tasks + 1
	self[taskId] = task

	return taskId
end

function Maid:Clean()
	local tasks = self._tasks

	for i, v in next, tasks do
		if typeof(v) == 'RBXScriptConnection' then
			tasks[i] = nil
			v:Disconnect()
		end
	end

	local index, value = next(tasks)
	while value ~= nil do
		tasks[index] = nil
		if type(value) == 'function' then
			value()
		elseif typeof(value) == 'RBXScriptConnection' then
			value:Disconnect()
		elseif Signal.isSignal(value) then
			value:Destroy()
		elseif typeof(value) == 'table' then
			table.clear(value)
		elseif typeof(value) == 'thread' then
			task.cancel(value)
		elseif value.Destroy then
			value:Destroy()
		end

		index, value = next(tasks)
	end
end

function Maid.__index(self, index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

function Maid:__newindex(index, value)
	if Maid[index] ~= nil then
		warn(string.format('%s is reserved', tostring(index)))
		return
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == value then
		return
	end

	tasks[index] = value

	if oldTask then
		if typeof(oldTask) == 'function' then
			oldTask()
		elseif typeof(oldTask) == 'RBXScriptConnection' then
			oldTask:Disconnect()
		elseif typeof(oldTask) == 'table' then
			table.clear(oldTask)
		elseif Signal.isSignal(oldTask) then
			oldTask:Destroy()
		elseif typeof(oldTask) == 'thread' then
			task.cancel(oldTask)
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

Maid.Destroy = Maid.Clean

return Maid