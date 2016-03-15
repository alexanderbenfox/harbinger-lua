require 'map1-functions'
require 'itemmap'

blockeddirection = {up = false, down = false, right = false, left = false, borderDown = nil, borderUp = nil, borderRight = nil, borderLeft = nil}

function blockeddirection:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function blockeddirection:player_checkboundaries(b, movement_x,movement_y,d1, d2)
	b = {up = false, down = false, left = false, right = false, borderDown = nil, borderUp = nil, borderRight = nil, borderLeft = nil}
	b.borderRight, b.borderLeft, b.borderDown, b.borderUp = check_movement(movement_x,movement_y)
	if b.borderRight then
		if d1 > 0 then
			b.right = true
		end
		if d1 < 0 then
			b.left = true
		end
		if d2 > 0 then
			b.up = true
		end
		if d2 < 0 then
			b.down = true
		end
	end
	if player.x < 0 then
		b.left = true
	end
	if player.x > (love.graphics.getWidth() - player.img:getWidth()) then
		b.right = true
	end
	if player.y < 0 then
		b.up = true
	end
	if player.y > (love.graphics.getHeight() - player.img:getHeight()) then
		b.down = true
	end
	-- body
	return b
end

function blockeddirection:get_player_boundaries()
	local x1,x2,y1,y2

end


function check_movement(body_x, body_y)
	for num, box in ipairs(Bounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return box.x1, box.x2, box.y1, box.y2
			end
		end
	end
	for num, box in ipairs(itemBounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return box.x1, box.x2, box.y1, box.y2
			end
		end
	end
	return false
end


function blockeddirection:getboundaries(self, x, y,d1,d2)
	return blockeddirection:player_checkboundaries(self, x, y,d1,d2)
end
