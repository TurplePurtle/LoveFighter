local Ctrlr = require "Ctrlr"
local Collider = require("hardoncollider").new(100)
local Map = require("Map").init(Collider)
local Fighter = require("Fighter").init(Collider)
local HitBox = Fighter.getHitBoxTable()
local graphics = love.graphics
local entities = {}
local screenWidth, screenHeight
local paused = false
local player, other

function love.load()
	-- Graphics
	screenWidth, screenHeight = 800, 600
	graphics.setMode(screenWidth, screenHeight)
	graphics.setBackgroundColor(0x87, 0xce, 0xeb)

	-- Ctrlr
	Ctrlr.setKeys("w","a","s","d"," ","j","k")

	-- GameState (->fighter select)

	-- Collider
	Collider:setCallbacks(
		function(dt, shape1, shape2, mtvX, mtvY)
			shape1.entity:handleCollision(shape2, mtvX, mtvY)
			shape2.entity:handleCollision(shape1, -mtvX, -mtvY)
		end,
		function(dt, shape1, shape2)
			shape1.entity:handleCollisionStop(shape2)
			shape2.entity:handleCollisionStop(shape1)
		end
	)

	-- Map
	Map.addPlatform(10, 500, 780, 90)
	Map.addPlatform(160, 256, 160, 16)
	Map.addPlatform(3*160, 256, 160, 16)

	-- Fighter
	player = Fighter({x=160*1.5, y=screenHeight/4, g=1500}):addTo(entities):setTeam("team1")
	other = Fighter({x=160*3.5, y=screenHeight/4, g=1500}):addTo(entities):setTeam("team2")
	--
end

function love.update(dt)
	if paused then return end

	print(player.state)
	-- for k,v in pairs(Collider.groups) do print(k,v) end

	HitBox.update()
	player:processInput(Ctrlr.inputs)

	for i=1,#entities do
		entities[i]:update(dt)
	end

	Collider:update(dt)
	Ctrlr.update()
end

function love.draw()
	graphics.clear()

	Map.draw()

	for i=1,#entities do
		entities[i]:draw()
	end

	-- debugging
	graphics.setColor(0xff,0,0)
	for _,shape in pairs(Collider._active_shapes) do shape:draw("line") end
	for _,shape in pairs(Collider._passive_shapes) do shape:draw("line") end
end

function love.keypressed(key)
	if key == "f4" and love.keyboard.isDown("lalt", "ralt") then
		love.event.push("q")
	elseif key == "escape" then
		paused = not paused
	else
		Ctrlr.keypressed(key)
	end
end

--[[function]] love.keyreleased --[[(key)]] = Ctrlr.keyreleased --[[(key) end]]

-- Custom love.run
function love.run()
	if love.load then love.load(arg) end
	local timer, event, handlers = love.timer, love.event, love.handlers
	local update, draw = love.update, love.draw

	-- Prevent weirdness at startup
	timer.step()
	timer.sleep(1)

	while true do
		timer.step()
		update(timer.getDelta())
		draw()

		-- Process events.
		for e,a,b,c in event.poll() do
			if e == "q" then
				if not love.quit or not love.quit() then
					if love.audio then love.audio.stop() end
					return
				end
			end
			handlers[e](a,b,c)
		end

		timer.sleep(1)
		graphics.present()
	end
end