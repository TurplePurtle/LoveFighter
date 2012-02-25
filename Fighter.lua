-- maybe each fighter must have hitbox list to update

local graphics = love.graphics
local collider
local HitBox = require "HitBox"

local Fighter = {
	kind="fighter",
	x=0,
	y=0,
	vx=0,
	vy=0,
	ax=0,
	ay=0,
	w=64,
	h=64,
	xc=32,
	yc=32,
	m=10,
	damage=0,
	g=5000,
	arun=70000,
	vrun=200,
	vjump=-640,
	grounded=false,
	candjump=true,
	state="idle",
	leftward=true,
	color={0xff, 0xff, 0xff},
}
local stateCase = {} -- process keyboard input with respect to state


function Fighter:processInput(inputs)
	if stateCase[self.state] then stateCase[self.state](self, inputs) end
end

function Fighter.update(ent, dt)
	if ent.y > 600 or ent.y < 0 or ent.x < 0 or ent.x > 800 then
		ent.collisionShape:moveTo(400, 300)
		ent.x, ent.y = 400, 300
		ent.vx, ent.vy = 0, 0
	end

	local vxMag = ent.vx > 0 and ent.vx or -ent.vx

	if ent.state == "jumpStart" then
		ent.ay = 0
		ent.vy = ent.vjump
		ent.state = "air"
	elseif not ent.grounded then
		ent.ay = ent.ay + ent.g
	end

	if ent.state == "runStart" then
		if vxMag < ent.vrun then
			ent.ax = ent.ax + (ent.leftward and -ent.arun or ent.arun) * dt
		else
			ent.state = "runSide"
		end
	elseif ent.state == "runStop" or ent.state == "idle" then
		local fdt = 150 * dt
		if vxMag > fdt*fdt then
			ent.vx = ent.vx * math.sqrt(1 - fdt / math.sqrt(vxMag))
		else
			ent.vx = 0
			ent.state = "idle"
		end
	end

	ent.vx = ent.vx + ent.ax * dt
	ent.vy = ent.vy + ent.ay * dt

	local dispX, dispY = ent.vx * dt, ent.vy * dt

	ent.x = ent.x + dispX
	ent.y = ent.y + dispY
	ent.collisionShape:move(dispX, dispY)

	ent.ax = 0
	ent.ay = 0
end

function Fighter.draw(ent)
	graphics.setColor(ent.color)
	graphics.rectangle("fill", ent.x - ent.xc, ent.y - ent.yc, ent.w, ent.h)
	if ent.leftward then
		graphics.circle("fill", ent.x-ent.xc, ent.y, 5)
	else
		graphics.circle("fill", ent.x+ent.xc, ent.y, 5)
	end
	-- temp print damage
	graphics.setColor(0,0,0)
	graphics.print(ent.damage, ent.x, ent.y)
end

function Fighter.addTo(ent, t)
	t[#t+1] = ent
	return ent
end

function Fighter.setTeam(ent, team)
	ent.team = team
	collider:addToGroup(team, ent.collisionShape)
	return ent
end

function Fighter.hit(ent, relX, relY, span, ftl, damage, fx, fy)
	collider:addToGroup(ent.team, HitBox(ent.x+relX, ent.y+relY, span, ftl, damage, fx, fy))
end

-- Commands
function Fighter:runStart(leftward)
	self.state = "runStart"
	self.leftward = leftward
end

function Fighter:runStop()
	self.state = "runStop"
end

function Fighter:jumpStart()
	self.state = "jumpStart"
	self.grounded = false
end


-- process keybord according to fighter state
stateCase.idle = function(ent, inputs)
	if inputs["k"] == 0 then
		if inputs["w"] >= 0 then
			if inputs["w"] <= 6 then
				return ent:hit(0, -ent.yc, 30, 4, 10, 0, -20000)
			else
				return ent:hit(ent.leftward and -ent.xc or ent.xc, -ent.yc, 30, 4, 10, 0, -10000)
			end
		else
			return ent:hit(ent.leftward and -ent.xc or ent.xc, 0, 30, 4, 10, ent.leftward and -1000 or 1000, 1000)
		end
	end
	if inputs["a"] >= 0 then
		if ent.leftward then
			ent:runStart(true)
		else
			ent.leftward = true
		end
	elseif inputs["d"] >= 0 then
		if not ent.leftward then
			ent:runStart(false)
		else
			ent.leftward = false
		end
	end
	if inputs[" "]  == 0 then
		ent:jumpStart()
	end
end

stateCase.runStart = function(ent, inputs)
	if inputs["k"] == 0 then
		if ent.leftward then
			if inputs["a"] >= 0 and inputs["a"] <= 4 then
				return ent:hit(-ent.xc-24/2, 0, 24, 8, 20, -3000, -2000)
			else
				return ent:hit(-ent.xc, 0, 15, 8, 10, -500, -3000)
			end
		else
			if inputs["d"] >= 0 and inputs["d"] <= 4 then
				return ent:hit(ent.xc+24/2, 0, 24, 8, 20, 3000, -2000)
			else
				return ent:hit(ent.xc, 0, 15, 8, 10, 500, -3000)
			end
		end

	elseif inputs["a"] >= 0 then
		if not ent.leftward then
			ent:runStop()
		end
	elseif inputs["d"] >= 0 then
		if ent.leftward then
			ent:runStop()
		end
	else
		ent:runStop()
	end
	if inputs[" "] == 0 then
		ent:jumpStart()
	end
end

stateCase.runSide = function(ent, inputs)
	if inputs["k"] == 0 then
		return ent:hit(ent.leftward and -ent.xc or ent.xc, 0, 15, 8, 10, 0, 0)
	end
	if inputs["a"] >= 0 then
		if not ent.leftward then
			ent:runStop()
		end
	elseif inputs["d"] >= 0 then
		if ent.leftward then
			ent:runStop()
		end
	else
		ent:runStop()
	end
	if inputs[" "] == 0 then
		ent:jumpStart()
	end
end

stateCase.air = function(ent, inputs)
	if inputs["a"] >= 0 then
		local vx = ent.vx
		if vx > -40 then
			ent.vx = vx - 4
		end
	elseif inputs["d"] >= 0 then
		local vx = ent.vx
		if vx < 40 then
			ent.vx = vx + 4
		end
	end
	if inputs[" "] == 0 then
		if ent.candjump then
			ent.state = "jumpStart"
			ent.candjump = false
		end
	end
end

-- Collision Handlers
Fighter.handleCollision = function(ent, shape, mtvX, mtvY)
	if shape.entity.kind == "platform" then
		ent.x = ent.x + mtvX
		ent.y = ent.y + mtvY
		ent.collisionShape:move(mtvX,mtvY)
		if not ent.grounded and ent.vy > 0 and mtvY < 0 --[[and mtvY > -shape.entity.h]] then
			ent.vy = 0
			ent.grounded = true
			ent.state = "runStop"
			ent.candjump = true
		end
	elseif shape.entity.kind == "hitbox" then
		ent.state = "hit"
		ent.grounded = false
		ent.damage = ent.damage + shape.damage
		ent.ax = ent.ax + shape.fx * (1 + ent.damage/100)
		ent.ay = ent.ay + shape.fy * (1 + ent.damage/100)
		collider:addToGroup(ent.team, shape)
	end
end

Fighter.handleCollisionStop = function(ent, shape)
	if shape.entity.kind == "platform" then
		ent.grounded = false
	end
end


-- Constructor
setmetatable(Fighter, {__call=function(t, opt)
	local o = {}
	setmetatable(o, Fighter)
	if opt then
		for k,v in pairs(opt) do o[k]=v end
	end
	o.collisionShape = collider:addRectangle(o.x-o.xc, o.y-o.yc, o.w, o.h)
	o.collisionShape.entity = o
	return o
end})

function Fighter.init(_collider)
	collider = _collider -- HC collider instance
	HitBox.init(_collider)
	return Fighter
end

function Fighter.getHitBoxTable()
	return HitBox
end

Fighter.__index = Fighter

return Fighter