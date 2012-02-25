local Ctrlr = {}
local INPUTS = {}
local KEYS = {n=0}

Ctrlr.inputs = INPUTS
Ctrlr.keys = KEYS

function Ctrlr.update()
	for i=KEYS.n,1,-1 do
		local key = KEYS[i]
		local val = INPUTS[key]
		if val >= 0 then
			INPUTS[key] = val + 1
		end
	end
end

function Ctrlr.keypressed(key)
	if INPUTS[key] then
		INPUTS[key] = 0
	end
end

function Ctrlr.keyreleased(key)
	if INPUTS[key] then
		INPUTS[key] = -1
	end
end

function Ctrlr.setKeys(...)
	for i=1,arg.n do
		local key = arg[i]
		assert(type(key)=="string", "Argument must be a KeyConstant.")
		KEYS[#KEYS+1] = key
		INPUTS[key] = -1
		KEYS.n = KEYS.n+1
	end
end

return Ctrlr