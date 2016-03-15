-- Shooter Class
require 'charactercontroller'
require 'physics1'
love.filesystem.load("physics1.lua")

shooter = {}
arrow = {x = 0, y = 0, fastShot = false, img = nil, velocity_x = 0, velocity_y = 0, d = 1, bounds = nil}
availableWeapons = {bow = true, axe = true}
arrowsOnScreen = {}
arrowBounds = {}
local arrowHold = 0
local timeStart = false
local shootTimerStart = false
local shootTimer = 0
local timer = 0
local upTriggered = false


function shooter:load(args)
	arrow.img = love.graphics.newImage('assets/arrow.png')
	--local straighArrowImg = love.graphics.newImage('assets/straightarrow.png')
	local straighArrowImg = love.graphics.newImage('assets/arrow.png')
	arrowBounds = physics:new()
end

function arrow:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function shooter:keypressdown(key)
	if key == 'k' and canShoot and not button.button1.boolean then
		button.button1.boolean = true
		canShoot = false
		shootTimerStart = true
	end
end

function shooter:keypressup(key)
	if key == 'k' and not canShoot then --and shootTimer >= 30 then
		upTriggered = true
	-- elseif key == 'k' and not canShoot then
	-- 	arrowHold = 0
	-- 	timeStart = true
	-- 	canShoot = true
	-- 	shootTimerStart = false
	end
end

function shooter:update(dt)
	if shootTimerStart then
		shootTimer = shootTimer + 1
	else
	 	--shootTimer = 0
	end
	if shootTimer >= 25 then
		MainCharacterAnim:setActionSpeed("Shooting",.5)
		MainCharacterAnim:setMode("loop")
		button.button1.animation = "Shooting"
		--MainCharacterAnim:setMode("loop")
	else
		button.button1.animation = "Shooting2"
		--MainCharacterAnim:setSpeed(1)
	end


	if not canShoot and arrowHold <= 600 then
		arrowHold = arrowHold + 18
	end

	if not canShoot and arrowHold >= 250 and upTriggered then
		local xA
		local b = physics:new()
		if direction == 1 then
			xA = player.x + player.img:getWidth()
		else xA = player.x --- arrow.img:getWidth()
		end
		canShoot = true
		local r,g,b,alpha = love.graphics.getColor() 
		a = arrow:new{x = xA, y = player.y+8, fastShot = false, img = arrow.img, velocity_x = 200*direction, velocity_y = 0, d = direction, bounds = b, gravityIterator = 0, destroyTimer = 0, a = alpha, stopped = false}
		a.velocity_x = a.velocity_x + arrowHold*a.d
		if arrowHold > 350 then
			a.img = straighArrowImg
		end
		if isShootingDown then
			a.velocity_y = -math.abs(a.velocity_x)
			a.velocity_x = 0
			a.y = player.y+32
			a.x = player.x + player.img:getWidth()/2
		end
		table.insert(arrowsOnScreen,a)
		if quiver.arrows == quiver.arrowMax then
			quiver.rechargeTimer = 0
		end
		quiver.arrows = quiver.arrows - 1


		if arrowHold>= 590 then
			copy = arrow:new{x = xA, y = player.y+8, fastShot = false, img = arrow.img, velocity_x = 200*direction, velocity_y = 0, d = direction, bounds = b, gravityIterator = 0, destroyTimer = 0, a = alpha, stopped = false}
			copy.velocity_x = copy.velocity_x + arrowHold*copy.d - copy.d*150
			copy.velocity_y = -math.abs(copy.velocity_x/5)
        	table.insert(arrowsOnScreen,copy)
        end
        timeStart = true
        player.ammo = player.ammo - 1
        resetShoot()
	end

	if timeStart then
		timer = 1 + timer
		if timer > 10 then
			MainCharacterAnim:resetAction("Shooting2")
			button.button1.boolean = false
			timer = 0
			timeStart = false
		end
	end

	for num, ar in ipairs(arrowsOnScreen) do
		if ar.destroyTimer >= 1 then
			ar.a = ar.a-5
			ar.stopped = true
		end
		if ar.a == 0 then
			table.remove(arrowsOnScreen, num)
		end
		ar.x = ar.x + ar.velocity_x*dt
		ar.y = ar.y + ar.velocity_y*dt
		if ar.destroyTimer == 0 then
			--ar.velocity_y = ar.velocity_y + 35*.06*ar.gravityIterator
		end
		ar.gravityIterator = ar.gravityIterator + 1
		ar.bounds = arrowBounds:get(arrowBounds,ar.x,ar.y,ar.img,1,0, "arrow")
		local right = ar.bounds.right
		local borderLeft = ar.bounds.borderLeft
		ar.bounds = arrowBounds:get(arrowBounds,ar.x-19,ar.y,ar.img,-1,0, "arrow")
		local left = ar.bounds.left
		local borderRight = ar.bounds.borderRight
		if (ar.d == 1 and right) or (ar.d == -1 and left) then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				ar.velocity_x = 10*ar.d
			else ar.velocity_x = 0
			end
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
	end
end

function resetShoot()
	arrowHold = 0
	--timeStart = true
	shootTimerStart = false
	shootTimer = 0
	upTriggered = false
end

function shooter:draw(dt)
	for num, ar in ipairs(arrowsOnScreen) do
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(r,g,b,ar.a)
		love.graphics.draw(ar.img ,ar.x,ar.y, 0,ar.d,1)
	end
end