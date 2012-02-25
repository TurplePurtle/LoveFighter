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
	g=5000,
	arun=30000,
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

function Fighter:keypressed(key)
	if self.state == "idle" then
		if key == "k" then
			return collider:addToGroup(self.team, HitBox(self.x-(self.leftward and self.xc or -self.xc), self.y, 30, 4, 10))
		elseif key == " " then
			self:jumpStart()
		end
	elseif self.state == "runStart" or self.state == "runSide" then
		if key == "k" then
			return collider:addToGroup(self.team, HitBox(self.x-(self.leftward and self.xc or -self.xc), self.y, 15, 8, 10))
		elseif key == " " then
			self:jumpStart()
		end
	elseif self.state == "air" then
		if key == " " then
			if self.candjump then
				self.state = "jumpStart"
				self.candjump = false
			end
		end
	end
end

function Fighter.update(ent, dt)
	local vxMag = ent.vx > 0 and ent.vx or -ent.vx

	ent.ax = 0
	ent.ay = 0

	if ent.state == "jumpStart" then
		ent.ay = 0
		ent.vy = ent.vjump
		ent.state = "air"
	elseif not ent.grounded then
		ent.ay = ent.g
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
	ent.x = ent.x + ent.vx * dt
	ent.y = ent.y + ent.vy * dt

	ent.collisionShape:moveTo(ent.x, ent.y)
end

function Fighter.draw(ent)
	graphics.setColor(ent.color)
	graphics.rectangle("fill", ent.x - ent.xc, ent.y - ent.yc, ent.w, ent.h)
	if ent.leftward then
		graphics.circle("fill", ent.x-ent.xc, ent.y, 5)
	else
		graphics.circle("fill", ent.x+ent.xc, ent.y, 5)
	end
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
	if inputs["a"] >= 2 then
		if ent.leftward then
			ent:runStart(true)
		else
			ent.leftward = true
		end
	elseif inputs["d"] >= 2 then
		if not ent.leftward then
			ent:runStart(false)
		else
			ent.leftward = false
		end
	end
end

stateCase.runStart = function(ent, inputs)
	if inputs["a"] >= 2 then
		if not ent.leftward then
			ent:runStop()
		end
	elseif inputs["d"] >= 2 then
		if ent.leftward then
			ent:runStop()
		end
	else
		ent:runStop()
	end
end

stateCase.runSide = function(ent, inputs)
	if inputs["a"] >= 2 then
		if not ent.leftward then
			ent:runStop()
		end
	elseif inputs["d"] >= 2 then
		if ent.leftward then
			ent:runStop()
		end
	else
		ent:runStop()
	end
end

stateCase.air = function(ent, inputs)
end

-- Collision Handlers
Fighter.handleCollision = function(ent, shape, mtvX, mtvY)
	if shape.entity.kind == "platform" then
		if not ent.grounded and ent.vy > 0 and mtvY < 0 --[[and mtvY > -shape.entity.h]] then
			ent.grounded = true
			ent.state = "idle"
			ent.candjump = true
			ent.vy = 0
			-- ent.x = ent.x + mtvX
			ent.y = ent.y + mtvY
			ent.collisionShape:move(0,mtvY)
		end
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
end

function Fighter.getHitBoxTable()
	return HitBox
end

Fighter.__index = Fighter

return Fighter