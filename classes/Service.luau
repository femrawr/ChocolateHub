local Service = {}

function Service:Get(...)
	local services = {}

	for _, v in next, {...} do
		table.insert(services, self[v])
	end

	return unpack(services)
end

function Service:Hook()
	return nil
end

setmetatable(Service, {
	__index = function(self, index)
		local service = cloneref(game:GetService(index))

		rawset(self, index, service)
		return rawget(self, index)
	end
})

return Service