local HitBox = {}
local HBLIST = {}
local collider

local proto = {kind="hitbox"}
function proto.handleCollision()end
function proto.handleCollisionStop()end
function proto.update(hb, dx, dy) -- can use this to make HB follow fighter
	hb:move(dx, dy)
end


function HitBox.new(HB, x, y, span, ftl, damage, fx, fy)
	local hb = collider:addRectangle(x-span/2, y-span/2, span, span)
	hb.entity, hb.damage, hb.ftl, hb.fx, hb.fy = proto, damage, ftl, fx, fy
	HBLIST[#HBLIST+1] = hb
	return hb
end

function HitBox.update()
	for i=#HBLIST,1,-1 do
		local hb = HBLIST[i]
		if hb.ftl > 1 then
			hb.ftl = hb.ftl - 1
		else
			collider:remove(hb)
			table.remove(HBLIST, i)
		end
	end
end

function HitBox.init(_collider)
	collider = _collider
end

HitBox.__index = HitBox
setmetatable(HitBox, {__call=HitBox.new})

return HitBox