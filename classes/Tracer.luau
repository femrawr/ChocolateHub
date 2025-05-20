local Tracer = {}
Tracer.__index = Tracer

local Service = fetch('classes/Service')
local tweenService = Service:Get('TweenService')

do
	function Tracer.new(parent)
		local self = setmetatable({}, Tracer)

		self._tracer = cloneref(Instance.new('Part'))
		self._tracer.CanCollide = false
		self._tracer.Anchored = true
		self._tracer.Massless = true
		self._tracer.CanTouch = false
		self._tracer.CanQuery = false
		self._tracer.CastShadow = false
		self._tracer.Size = Vector3.one * 0.2
		self._tracer.CFrame = CFrame.new()
		self._tracer.Material = Enum.Material.SmoothPlastic
		self._tracer.Color = Color3.new(1, 1, 1)
		self._tracer.Parent = parent or workspace.CurrentCamera

		return self
	end

	function Tracer:Update(options)
		local tracer = self._tracer

		tracer.CFrame = CFrame.new((options.from + options.to) / 2, options.to)
		tracer.Size = Vector3.new(options.size or 0.2, options.size or 0.2, (options.from - options.to).Magnitude)

		tracer.Material = options.material or Enum.Material.SmoothPlastic
		tracer.Color = options.color or Color3.new(1, 1, 1)
		tracer.Transparency = options.transparency or 0.3
	end

	function Tracer:Destroy(tween, tweenInfo)
		if not tween then
			self._tracer:Destroy()
			self._tracer = nil
			return
		end

		local tweenObj = tweenService:Create(self._tracer, tweenInfo, {Transparency = 1})
		tweenObj:Play()

		tweenObj.Completed:Connect(function()
			self._tracer:Destroy()
			self._tracer = nil

			tweenObj:Destroy()
			tweenObj = nil
		end)
	end
end

return Tracer