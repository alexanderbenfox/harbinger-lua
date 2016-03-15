-- make sure to add the camera with bound setting

require 'camera'
require 'charactercontroller'

metroidcamera = {}

--local windowSize = {}
--windowSize.x, windowSize.y = love.window.getHeight(),love.window.getWidth()

--function windowSize:scale(x)
--	windowSize.x = windowSize.x * x
--	windowSize.y = windowSize.y * x
--end

local scrollMultiplier_x = 4 -- has to be atleast 1.1 to work
local scrollMultiplier_y = 2

local movementWindowSize = {} -- this is the window where the character will be kept on screen.
movementWindowSize.x = 0
movementWindowSize.y = 0

local limitMovement = true
local limits = {right = 0, left = 0, top = 0, bottom = 0}

-- stuff that the camera actually uses now

activeTracking = true

local playerPos = {}
playerPos.x = 0
playerPos.y = 0
playerPos.prevX = 0
playerPos.prevY = 0

function playerPos:setPlayerPos(x,y)
	if x then self.x = (x+(player.img:getWidth()/2)) end
	if y then self.y = (y+(player.img:getHeight()/2)) end
end

function playerPos:setPrevPlayerPos(x,y)
	if x then self.prevX = x end
	if y then self.prevY = y end
end

function playerPos:compare()
	if playerPos.x ~= playerPos.prevX then
		return true
	end
	if playerPos.y ~= playerPos.prevY then
		return true
	end
	return false
end

local cameraPos = {}
cameraPos.x = 0
cameraPos.y = 0

function cameraPos:setCameraPos(x,y)
	if x then self.x = x end
	if y then self.y = y end
end

local windowRect = {}
windowRect.x = 0
windowRect.width = 0
windowRect.y = 0
windowRect.height = 0

windowCanvas = {}
windowCanvas.x1 = 0
windowCanvas.x2 = 0
windowCanvas.y1 = 0
windowCanvas.y2 = 0

windowCanvas2 = {}
windowCanvas2.x1 = 0
windowCanvas2.x2 = 0
windowCanvas2.y1 = 0
windowCanvas2.y2 = 0

function windowRect:setVars(x,y,width,height)
	if x then self.x = x end
	if y then self.y = y end
	if width then self.width = width end
	if height then self.height = height end
end

function windowRect:contains(x,y)
	if x >= windowRect.x and x<= windowRect.x+windowRect.width then
		if y >= windowRect.y and y<= windowRect.y+windowRect.height then
			return true
		end
	end
	return false
end

function metroidcamera:load()
	fallingIterator = 0

	-- change this?
	windowSize:scale(.8)
	camera:scale(.8)
	-- windowSize:scale(1)
	-- camera:scale(1)
	camera:setPosition(player.x-windowSize.x/2,player.y-windowSize.y/2)


	cameraPos:setCameraPos(camera._x,camera._y)
	playerPos:setPrevPlayerPos(player.x,player.y)

	-- this is the root x/y coordinates that will be used to create the boundary rectangle.
	--Starts at the top right for this

	--local windowAnchorX = cameraPos.x + movementWindowSize.x/2
	--local windowAnchorY = cameraPos.y + movementWindowSize.y/2
	local windowAnchorX = movementWindowSize.x/2
	local windowAnchorY = movementWindowSize.y/2


	windowRect:setVars(windowAnchorX,windowAnchorY,movementWindowSize.x,movementWindowSize.y)


	


end

function metroidcamera:update(dt)
	-- if player.maxFallSpeed then
	-- 	movementWindowSize.y = 100
	-- else
	-- 	movementWindowSize.y = 0
	-- end


	--update limits first
	-- limits.left = 0 + windowSize.x/2
	-- limits.right = layerInfo.layerWidth - windowSize.x/2
	-- limits.top = 0 + windowSize.y/3
	-- limits.bottom = layerInfo.layerHeight - windowSize.y/2
	limits.left = 0 + windowSize.x/2
	limits.right = layerInfo.layerWidth - windowSize.x/2
	limits.top = 0 + windowSize.y/3
	limits.bottom = layerInfo.layerHeight - windowSize.y/3

	if limits.top >= limits.bottom then
		limits.bottom = limits.top
	end

	if limits.right <= limits.left then
		limits.right = limits.left
	end


	local x = player.x
	local y = player.y

	if button.crouch then
		y = y - (64-50)
	end

	playerPos:setPlayerPos(x,y)

	if activeTracking and playerPos:compare() == true then
		cameraPos:setCameraPos(camera._x,camera._y)

		-- get distance between player and camera
		local playerPositionDifference = {}
		playerPositionDifference.x = playerPos.x - playerPos.prevX
		playerPositionDifference.y = playerPos.y - playerPos.prevY

		-- move camera in this direction but faster than the player moved
		local multipliedDifference = {}
		multipliedDifference.x = scrollMultiplier_x*playerPositionDifference.x
		multipliedDifference.y = scrollMultiplier_y*playerPositionDifference.y

		cameraPos.x = multipliedDifference.x+cameraPos.x
		-- cameraPos.y = multipliedDifference.y+cameraPos.y
		cameraPos.y = multipliedDifference.y - cameraPos.y

		-- update the movement window parameters

		windowRect.x = cameraPos.x - movementWindowSize.x/2
		windowRect.y = cameraPos.y - movementWindowSize.y/2


		-- if you overshoot the boundary, or the player suddenly moves too fast for the multiplier, then this will correct for that case
		-- snaps player to boundary
		if not windowRect:contains(playerPos.x,playerPos.y) then
			local positionDifference = {}
			positionDifference.x = playerPos.x - cameraPos.x
			positionDifference.y = playerPos.y - cameraPos.y

			--snap the boundary to the player
			cameraPos.x = cameraPos.x + DifferenceOutOfBounds(positionDifference.x, movementWindowSize.x)
			cameraPos.y = cameraPos.y + DifferenceOutOfBounds(positionDifference.y,movementWindowSize.y)

		end

		-- clamp movement if limits are active
		if limitMovement then
			camera:setBounds(limits.left,limits.top,limits.right,limits.bottom)
		end

		camera:setX(cameraPos.x)
		camera:setY(cameraPos.y)

	else
		local playerPositionDifference = {}
		playerPositionDifference.x = playerPos.x - playerPos.prevX
		playerPositionDifference.y = playerPos.y - playerPos.prevY
		cameraPos.x = playerPositionDifference.x+cameraPos.x
		cameraPos.y = playerPositionDifference.y+cameraPos.y
		windowRect.x = cameraPos.x - movementWindowSize.x/2
		windowRect.y = cameraPos.y - movementWindowSize.y/2
		if limitMovement then
			camera:setBounds(limits.left,limits.top,limits.right,limits.bottom)
		end
		camera:setX(cameraPos.x)
		camera:setY(cameraPos.y)

	end
	playerPos:setPrevPlayerPos(playerPos.x,playerPos.y)
	windowCanvas.x1 = cameraPos.x -(windowSize.x/2)
	windowCanvas.x2 = cameraPos.x + (windowSize.x/2)
	windowCanvas.y1 = cameraPos.y-(windowSize.y/2)
	windowCanvas.y2 = cameraPos.y + (windowSize.y/2)


	windowCanvas2.x1 = cameraPos.x -(windowSize.x)
	windowCanvas2.x2 = cameraPos.x + (windowSize.x)
	windowCanvas2.y1 = cameraPos.y-(windowSize.y)
	windowCanvas2.y2 = cameraPos.y + (windowSize.y)
end

function DifferenceOutOfBounds(differenceAxis, windowAxis)
	local difference = 0
	local sign = 0
	local absDiffAxis = 0
	if differenceAxis >= 0 then
		absDiffAxis = differenceAxis
		sign = 1
	else
		absDiffAxis = differenceAxis*-1
		sign = -1
	end

	--If the player has overshot the bound on the axis, subtract the boundary from the distance
	--If not,just set the difference to zero because we dont want to needlessly compensate

	if absDiffAxis<=windowAxis/2 then
		difference = 0
	else
		difference = differenceAxis - (windowAxis/2) * sign
	end

	return difference
end


