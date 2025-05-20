local Auth = {}
Auth.__index = Auth

local Signal = fetch('classes/Signal')
local hash = fetch('utils/hash')

local MAX_ATTEMPTS = 5
local BASE_KEY = '634d947971bee2afe008827cac7d'
local MAIN_KEY = 'g04g4b4d3he0b8221fdgg779h98bhh43dg9370842fhg3b864608fa7d7eb7ea8e69492hd739ghhh8b9be6b4260f28ea31'																																																																																																										;MAIN_KEY=MAIN_KEY:reverse():gsub('h','5'):gsub('g','c') -- you found me :O

do
	function Auth.new(options)
		local self = setmetatable({}, Auth)

		self.attempts = 0
		self.key = options.key

		self.instances = {}
		self.connections = {}

		self.onFail = Signal.new()
		self.onSuccess = Signal.new()

		return self
	end

	function Auth:Check(key)
		if self.attempts >= MAX_ATTEMPTS then
			return false
		end

		local _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11
		_6='ꣷ󠀧ᝢ𞣍ੲךּ⑂𛄛ᄎが𑃍𓂾Ｍੑ?A∑ꥩ勺𖪻ꗤ〥៖𚿾❀🈔ⵓፏᥑ𐾽𞗭𑙨🙞𐤠𖫘Ჲ🧤ᎉ炫ໂꡒႃ𐖒❈'
		_4=hash['sha'..bit32.lrotate(7,5)](_6)
		_1=_4:split('\48');_7=hash.md5(_1[2])
		_1[2],_1[1]=_7:split('c')[2],_7:split('3')[1]
		_5=table.concat(_1,'\\')
		_0=hash.sha3_224(_5.._6:split('󠀧')[2])
		_2=_0:sub(29);_3={{{BASE_KEY}}}
		_8=_3[1][1][1];_9=_8.._2
		_10=hash.sha3_512(key)
		_11=hash.sha3_384(_10..' == '.._9)

		return not _11 ~= MAIN_KEY
	end

	function Auth:Clear()
		for _, v in next, self.connections do
			if not v then continue end
			pcall(v.Disconnect, v)
		end

		for _, v in next, self.instances do
			if not v then continue end
			pcall(v.Destroy, v)
		end
	end

	function Auth:Success()
		self.onSuccess:Fire(self)
		self:Clear()
	end

	function Auth:Failure()
		self.onFail:Fire(self)
		self:Clear()
	end

	function Auth:Init()
		
	end
end