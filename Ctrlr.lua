--[[

--Call "Ctrlr.setKeys(<keys>)" in love.load
--Call "Ctrlr.update()" in love.update
--Get key state with "Ctrlr.inputs[key]"

Input states:
----------------
0 - not down (previously released)
1 - just released
2 - just pressed
3 - held down

-- Ctrlr.inputs[key] >= 2 and Ctrlr.inputs[key] <= 1 can be used to check
-- if key is currently down or not regardless of when it was pressed.


Example usage:
----------------

-- Set up the keys we want to check.
Ctrlr.setKeys("left", "right", "up")

-- Check keys
-- Player jumps only if key was just pressed
if Ctrlr.inputs["up"] == 2 then
	player:jump()
end

-- Player moves left if "left" key is down at all
if Ctrlr.inputs["left"] >= 2 then
	player:moveLeft()
end
--]]

local Ctrlr = {}
local INPUTS = {}
local KEYS = {n=0}
local isKeyDown = love.keyboard.isDown

Ctrlr.inputs = INPUTS
Ctrlr.keys = KEYS

function Ctrlr.update()
	for i=1,KEYS.n do
		local key = KEYS[i]

		if isKeyDown(key) then
			if INPUTS[key] <= 1 then
				INPUTS[key] = 2
			elseif INPUTS[key] == 2 then
				INPUTS[key] = 3
			end
		else
			if INPUTS[key] >= 2 then
				INPUTS[key] = 1
			elseif INPUTS[key] == 1 then
				INPUTS[key] = 0
			end
		end
	end
end

function Ctrlr.setKeys(...)
	for i=1,arg.n do
		local key = arg[i]
		assert(type(key)=="string", "Argument must be a KeyConstant.")
		KEYS[#KEYS+1] = key
		INPUTS[key] = 0
		KEYS.n = KEYS.n+1
	end
end

return Ctrlr