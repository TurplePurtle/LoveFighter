local Map = {}
local collider
local graphics = love.graphics

Map.platforms = {}

Map.Platform = {
color={0x99,0xcc,0x22},
}
Map.Platform.handleCollision=function()end
Map.Platform.handleCollisionStop=Map.Platform.handleCollision

Map.Platform.__index = Map.Platform

function Map.draw()
	local platforms = Map.platforms
	for i=1,#platforms do
		local platform = platforms[i]
		graphics.setColor(platform.color)
		graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
	end
end

function Map.addPlatform(x, y, w, h)
	local platform = {kind="platform",x=x,y=y,w=w,h=h}
	setmetatable(platform, Map.Platform)
	Map.platforms[#Map.platforms+1] = platform

	local collisionShape = collider:addRectangle(x, y, w, h)
	collider:setPassive(collisionShape)
	collider:addToGroup("platforms", collisionShape)
	platform.collisionShape = collisionShape
	collisionShape.entity = platform

	return platform
end

function Map.init(_collider)
	collider = _collider
	return Map
end

return Map