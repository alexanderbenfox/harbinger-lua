-- physics rewrite
-- Purpose: get collisions for the floor ceiling and walls
-- rewrite of bounds.lua

require 'map1-functions'
require 'itemmap'

physics = {up = false, down = false, right = false, left = false, borderDown = nil, borderUp = nil, borderRight = nil, borderLeft = nil}

vector = {x = 0, y = 0}

collider_points = {topleft = nil, topmiddle = nil, topright = nil, midleft = nil, midright = nil, bottomleft = nil, bottommiddle = nil, bottomright = nil}

function collider_points:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function physics:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function vector:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function vector:create(x1,y1)
	self.x = x1
	self.y = y1
end



function collider_points:create(collider, pos_x, pos_y)
	--points = collider_points:new()
	local points = {topleft = nil, topmiddle = nil, topright = nil, midleft = nil, midright = nil, bottomleft = nil, bottommiddle = nil, bottomright = nil}
	for num, point in ipairs(points) do
		point = vector:new()
	end
	--pos_x = 0
	--pos_y = 0
	yh = pos_y+1
	points.topleft = {x = pos_x, y = pos_y}
	points.topmiddle = {x = pos_x + collider:getWidth()/2, y = pos_y}
	points.topright = {x = pos_x + collider:getWidth(), y = pos_y}
	points.midleft = {x = pos_x, y = (pos_y + collider:getHeight()/2)}
	points.midright = {x = pos_x + collider:getWidth(), y = pos_y + collider:getHeight()/2}
	points.bottomleft = {x = pos_x, y = pos_y + collider:getHeight()}
	points.bottommiddle = {x = pos_x + collider:getWidth()/2 , y = pos_y + collider:getHeight()}
	points.bottomright = {x = pos_x + collider:getWidth(), y = pos_y + collider:getHeight()}
	return points
end


function physics:check_collisions(collisions, movement_x,movement_y, collisionPoints,horizontalAxis,verticalAxis, collider_type)
	collisions = {up = false, down = false, left = false, right = false, borderDown = nil, borderUp = nil, borderRight = false, borderLeft = nil, collided = nil}
	-- here we check for movement
	-- for num, point in ipairs(collisionPoints) do
	-- 	if not collisions.borderRight then
	-- 		collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp = check_movement(movement_x,movement_y)
	-- 	end
	-- 	collisions.down = true
	-- end
	local topr, midr, botr, botrg, botmg,botlg, botl,midl,topl = false, false,false,false,false,false,false,false,false

	if verticalAxis < 0 then
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.bottomright.x-5,collisionPoints.bottomright.y, collider_type)
			botrg = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.bottomleft.x+5,collisionPoints.bottomleft.y, collider_type)
			botlg = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.bottommiddle.x,collisionPoints.bottommiddle.y, collider_type)
			botmg = collisions.borderRight
		end
	end

	if verticalAxis > 0 then

		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.topleft.x+5,collisionPoints.topleft.y+2, collider_type)
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.topmiddle.x,collisionPoints.topmiddle.y+2, collider_type)
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.topright.x-5,collisionPoints.topright.y+2, collider_type)
		end
	end

	if horizontalAxis < 0 then

		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided  = check_movement(collisionPoints.bottomleft.x+1,collisionPoints.bottomleft.y-2, collider_type)
			botl = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.midleft.x+1,collisionPoints.midleft.y-1, collider_type)
			midl = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.topleft.x+1,collisionPoints.topleft.y+3, collider_type)
			topl = collisions.borderRight
		end
	end

	if horizontalAxis > 0 then

		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.topright.x-1,collisionPoints.topright.y+3, collider_type)
			topr = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.midright.x-1,collisionPoints.midright.y-1, collider_type)
			midr = collisions.borderRight
		end
		if not collisions.borderRight then
			collisions.borderRight, collisions.borderLeft, collisions.borderDown, collisions.borderUp, collisions.collided = check_movement(collisionPoints.bottomright.x-1,collisionPoints.bottomright.y-2, collider_type)
			botr = collisions.borderRight
		end
	end

	local dontpush = false

	if (botmg and botrg) or botr then
		dontpush = true
	elseif (botmg and botlg) and botr then
		dontpush = true
	end



	if collisions.borderRight then
		if horizontalAxis > 0 then
			collisions.right = true
		end
		if horizontalAxis < 0 then
			collisions.left = true
		end
		if verticalAxis > 0 then
			collisions.up = true
		end
		if verticalAxis < 0 then
			collisions.down = true
		end
	end
	return collisions,dontpush
end



function check_movement(body_x, body_y, collider_type, movement_indicator)

	if collider_type == "onlyoneway" then
		for num, box in ipairs(onewayBounds) do
			if body_x > box.x1 and body_x < box.x2 then
				if body_y > box.y1 and body_y < box.y2 then
					return box.x1, box.x2, box.y1, box.y2, box
				end
			end
		end
	else
		if collider_type == "player" then
			for num, box in ipairs(onewayBounds) do
				if body_x > box.x1 and body_x < box.x2 then
					if body_y > box.y1 and body_y < box.y2 then
						return box.x1, box.x2, box.y1, box.y2, box
					end
				end
			end
			for num, box in ipairs(movingBounds) do
				if body_x > box.x1 and body_x < box.x2 then
					if body_y > box.y1 and body_y < box.y2 then
						return box.x1, box.x2, box.y1, box.y2, box
					end
				end
			end
		end
		if collider_type == "switch" then
			if body_x >= player.x and body_x<= player.x + player.img:getWidth() then
				if body_y >= player.y and body_y<= player.y + player.img:getHeight() then
					return player.x, player.x + player.img:getWidth(), player.y, player.y + player.img:getHeight(), nil
				end
			end
		end

		if collider_type ~= "door" then
			for num, box in ipairs(switchableDoors) do
				if body_x > box.x1 and body_x < box.x2 then
					if body_y > box.y1 and body_y < box.y2 then
						return box.x1, box.x2, box.y1, box.y2, box
					end
				end
			end
		end

		-- for num, box in ipairs(Bounds) do
		-- 	if body_x > box.x1 and body_x < box.x2 then
		-- 		if body_y > box.y1 and body_y < box.y2 then
		-- 			return box.x1, box.x2, box.y1, box.y2, box
		-- 		end
		-- 	end
		-- end
		for x = -5,5 do
			for y = -5,5 do
				x_ = math.floor(body_x/32+x)
				y_ = math.floor(body_y/32+y)
				if tileLookUp[x_] ~= nil and tileLookUp[x_][y_] ~= nil then
					local box = tileLookUp[x_][y_]
					if body_x > box.x1 and body_x < box.x2 then
						if body_y > box.y1 and body_y < box.y2 then
							return box.x1, box.x2, box.y1, box.y2, box
						end
					end
				end
			end
		end
		if collider_type ~= "pushable" then
			for num, box in ipairs(pushableBounds) do
				if body_x > box.x1 and body_x < box.x2 then
					if body_y > box.y1 and body_y < box.y2 then
						return box.x1, box.x2, box.y1, box.y2, box
					end
				end
			end
		end
		--if collider_type ~= "arrow" then
		for num, box in ipairs(itemBounds) do
			if body_x > box.x1 and body_x < box.x2 then
				if body_y > box.y1 and body_y < box.y2 then
					return box.x1, box.x2, box.y1, box.y2, box
				end
			end
		end
		-- for num,box in ipairs(diagonalBounds) do
		-- 	local col, closest = getCollisionWithPlayer(body_x,body_y,box)
		-- 	if col then
		-- 		return box.x1, box.x2, closest, box.y2, box
		-- 	end
		-- end
		for x = -5,5 do
			for y = -5,5 do
				x_ = math.floor(body_x/32+x)
				y_ = math.floor(body_y/32+y)
				if tileLookUpDiag[x_] ~= nil and tileLookUpDiag[x_][y_] ~= nil then
					local box = tileLookUpDiag[x_][y_]
					local col, closest = getCollisionWithPlayer(body_x,body_y,box)
					if col then
						return box.x1, box.x2, closest, box.y2, box
					end
				end
			end
		end


	--end
		if collider_type == "arrow" then
			for num, enemy in ipairs(rats) do
				if not enemy.dead then
					if body_x > enemy.x and body_x < enemy.x2 then
						if body_y > enemy.y and body_y < enemy.y2 then
							return enemy.x, enemy.x2, enemy.y, enemy.y2, enemy
						end
					end
				end
			end
		end
		return false
	end
end


function physics:get(self, x, y, collider, horizontalAxis, verticalAxis, collider_type)
	thepoints = collider_points:create(collider, x, y)
	return physics:check_collisions(self, x, y, thepoints, horizontalAxis, verticalAxis, collider_type)
end


function loadPixelCollisions(img_path,direction,x,y,ind)
    local collider = {}
    collider.img = love.graphics.newImage(img_path)
    collider.id = img_path
    collider.x1 = 0
    collider.y1 = 0
    collider.x2 = collider.x1 + collider.img:getWidth()
    collider.y2 = collider.y1 + collider.img:getHeight()
    collider.collider = {}
    collider.topspots = {}
    for i = collider.x1,collider.x2-1 do
         collider.collider[i] = {}
         for j = collider.y1, collider.y2 - 1 do
         	if i ~= 32 then
	             local data = collider.img:getData()
	             r,g,b,a = data:getPixel(i,j)
	             if a == 0 then -- if the pixel is transparent then set the matrix indicator to false
	                 collider.collider[i][j] = false
	             else
	             	if collider.collider[i][j-1] ~= nil and collider.collider[i][j-1] == false then
	             		collider.topspots[i] = j
	             	end
	                collider.collider[i][j] = true
	             end
	        else
	        	if ind == "R" then
	        		for x = 0,31 do
	        			collider.collider[i][x] = true
	        		end
	        		collider.topspots[32] = 0
	        	elseif ind == "L" then
	        		for x = 0,31 do
	        			collider.collider[32][x] = false
	        			collider.collider[32][31] = true
	        			collider.topspots[32] = 30
	        		end
	        	end
	        end
        end
    end
    if ind == "I" then
		for x = 0,31 do
			for y = 0,31 do
				collider.collider[x][y] = true
				if x == 0 then
					collider.topspots[y] = -1
				end
			end
		end
	end
    if collider.topspots[31] == nil then
    	collider.topspots[31] = 0
    end
    if collider.topspots[0] == nil then
    	collider.topspots[0] = 0
    end

    --collider.collider = nil
    collider.width = collider.x2-collider.x1
    collider.height = collider.y2 - collider.y1
    collider.collider.x1 = x
    collider.collider.x2 = x + 32
    collider.collider.y1 = y
    collider.collider.y2 = y + 32
    collider.x1 = x
    collider.x2 = x + 32
    collider.y1 = y
    collider.y2 = y + 32

    collider.indicator = "diagonal"
    return collider
end


debugstuff = {}
debugstuff.x = 0
debugstuff.y = 0

function debugstuff:setDebug(x,y)
	self.x = x
	self.y = y
	-- body
end

function drawDebug()
	-- for num,collider in ipairs(diagonalBounds) do
	-- 	for x=collider.x1,collider.x2-1 do
	-- 		for y = collider.y1,collider.y2-1 do
	-- 		    if collider.collider[x-collider.x1][y-collider.y1] then -- if there is a non transparent pixel there then check against the player's collider
	-- 		        love.graphics.setColor(255, 255, 255)
	-- 				love.graphics.rectangle("line", x, y, 1, 1)
	-- 				love.graphics.setColor(255, 0, 255)
	-- 				love.graphics.rectangle("line",x,collider.topspots[x-collider.x1]+collider.y1,1,1)
	-- 	        end
	-- 	    end
	--     end
	--  --    for z = 0,31 do
	-- 	-- 	love.graphics.setColor(255, 0, 255)
	-- 	-- 	love.graphics.rectangle("line", z+collider.x1, collider.topspots[z]+collider.y1, 1, 1)
	-- 	-- end
	-- end
	-- -- love.graphics.setColor(255, 255, 255)
	-- -- love.graphics.setColor(255, 0, 255)
	-- -- love.graphics.rectangle("line", debugstuff.x ,debugstuff.y, 2, 2)
	-- -- love.graphics.setColor(255, 255, 255)

end

function getCollisionWithPlayer(x_,y_,collider) -- where x and y are top left location of colliding sprite and collider is set up like collider's collider
    for x=collider.x1,collider.x2-1 do
        for y = collider.y1,collider.y2-1 do
        	x_ = math.floor(x_)
        	y_ = math.floor(y_)
        	--if ((x-x_)>= 0 and x-x_<32) and ((y-y_)>= 0 and y-y_<32) then
        	if x_ == x and y_+1 == y then
	             if collider.collider[x-collider.x1][y-collider.y1] then -- if there is a non transparent pixel there then check against the player's collider
	                return true, collider.topspots[x-collider.x1]+collider.y1
	                --drawThis(collider.topspots)
	                
	            end
	        end
         end
     end
     return false
end

function getCornerCollision(x_,y_,ind)
	for num,collider in ipairs(diagonalBounds) do
		if containedInWindowCanvas(collider.x1,collider.y1) then
			if ind == 1 then
				for x=collider.x1,collider.x2-1 do
			        for y = collider.y1,collider.y2-1 do
			        	x_ = math.ceil(x_)
			        	y_ = math.ceil(y_)
			        	--if ((x-x_)>= 0 and x-x_<32) and ((y-y_)>= 0 and y-y_<32) then
			        	if x_ == x and y_ == y then
				            if collider.collider[x-collider.x1][y-collider.y1] then -- if there is a non transparent pixel there then check against the player's collider
				                return true, collider.topspots[x-collider.x1]+collider.y1,collider.descendFrom
				                
				            end
				        end
			        end
			    end
			else
				for x=collider.x1,collider.x2-1 do
			        for y = collider.y1,collider.y2-1 do
			        	x_ = math.floor(x_)
			        	y_ = math.ceil(y_)
			        	--if ((x-x_)>= 0 and x-x_<32) and ((y-y_)>= 0 and y-y_<32) then
			        	if x_ == x and y_ == y then
				             if collider.collider[x-collider.x1][y-collider.y1] then -- if there is a non transparent pixel there then check against the player's collider
				             	--print(x-collider.x1)
				                return true, collider.topspots[x-collider.x1]+collider.y1,collider.descendFrom
				                
				            end
				        end
			        end
			    end
			end
		end
	end
	if x_ ~= nil and y_ ~= nil then
		debugstuff:setDebug(x_,y_)
	end
	return false
end

function getWallHang(body_x,body_y)
	for num, box in ipairs(Bounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return true, box.y1
			end
		end
	end
	for num, box in ipairs(pushableBounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return true, box.y1
			end
		end
	end
	--if collider_type ~= "arrow" then
	for num, box in ipairs(itemBounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return true, box.y1
			end
		end
	end
	for num, box in ipairs(movingBounds) do
		if body_x > box.x1 and body_x < box.x2 then
			if body_y > box.y1 and body_y < box.y2 then
				return true, box.y1
			end
		end
	end
	-- for num,box in ipairs(diagonalBounds) do
	-- 	local col, closest = getCollisionWithPlayer(body_x,body_y,box)
	-- 	if col then
	-- 		return true, closest
	-- 	end
	-- end
	return false
end

