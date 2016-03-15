-- buttonActions
--require 'axe_throw'

button_action = {}

function button_action:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function button_action:load(key, name, animName, bool)
	local s = {button = nil, class = nil, animation = nil, boolean = nil}
	s.button = key
	s.class = name
	s.animation = animName
	s.boolean = bool
	return s
end


axe_throw = {canThrow = true, throwTimerStart = false, upTriggered = false, throwHold = 0, end_timer = 0, endtimertriggered = false, dontPlayAnim = false}

function axe_throw:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

axe = {animator = nil, moving = false}
axeimg = love.graphics.newImage("img/MainCharacterAnimations/AxeThrow/axe.png")
axecollider = love.graphics.newImage("img/MainCharacterAnimations/AxeThrow/axe_collider.png")

function axe:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function axe_throw:keypressdown(key)
	if key == 'k' and self.canThrow and not button.button1.boolean then
		button.button1.boolean = true
		self.canThrow = false
		self.throwTimerStart = true
		self.dontPlayAnim = false
	end
end

function axe_throw:keypressup(key)
	if key == 'k' and not self.canThrow then --and shootTimer >= 30 then
		self.upTriggered = true
	-- elseif key == 'k' and not canShoot then
	-- 	arrowHold = 0
	-- 	timeStart = true
	-- 	canShoot = true
	-- 	shootTimerStart = false
	end
end

function axe_throw:update(dt)
	if self.throwTimerStart then
		self.throwHold = self.throwHold + 1
	else
	 	--shootTimer = 0
	end
	if self.throwHold >= 25 then
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setMode("loop")
	else
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setSpeed(1)
	end


	if not self.canThrow and self.throwHold <= 400 then
		self.throwHold = self.throwHold + 10
	end

	if not self.canThrow and self.throwHold >= 200 and self.upTriggered then
		local xA
		local b = physics:new()
		if direction == 1 then
			xA = player.x + player.img:getWidth()
		else xA = player.x-17 --- arrow.img:getWidth()
		end
		--xA =player.x
		self.canThrow = true
		local r,g,b,alpha = love.graphics.getColor() 
		a = axe:new{x = xA, y = player.y-8, fastShot = false, img = axeimg, velocity_x = 230*direction, velocity_y = -400, d = direction, bounds = b, gravityIterator = 0, destroyTimer = 0, a = alpha, stopped = false}
		a.animator = newCharacter("itemimg","Axe","png",0.1,"AxeSpin")
		table.insert(arrowsOnScreen,a)
		if quiver.arrows == quiver.arrowMax then
			quiver.rechargeTimer = 0
		end
		quiver.arrows = quiver.arrows - 1
		player.ammo = player.ammo - 1
        self:resetAxe()
	end

	if self.endtimertriggered then
		self.end_timer = 1 + self.end_timer
		if self.end_timer > 7 then
			self.end_timer = 0
			self.endtimertriggered = false
			self.dontPlayAnim = true
			MainCharacterAnim:resetAction("AxeThrow")
			button.button1.boolean = false
			MainCharacterAnim:setAction("Idle")
		end
	end

	for num, ar in ipairs(arrowsOnScreen) do
		if ar.animator ~= nil then
			ar.animator:update(dt)
		end
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
			ar.velocity_y = ar.velocity_y + 28 --*.06*ar.gravityIterator
		end
		ar.gravityIterator = ar.gravityIterator + 1
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,1,0)
		local right = ar.bounds.right
		local borderLeft = ar.bounds.borderLeft
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,-1,0)
		local left = ar.bounds.left
		local borderRight = ar.bounds.borderRight
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,0,-1)
		local grounded = ar.bounds.down
		local borderDown = ar.bounds.borderDown
		if (ar.d == 1 and right) or (ar.d == -1 and left)or grounded then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				ar.velocity_x = 10*ar.d
			else ar.velocity_x = 0
			end
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
	end
end

function axe_throw:resetAxe()
	self.throwHold = 0
	--timeStart = true
	self.throwTimerStart = false
	self.upTriggered = false
	self.endtimertriggered = true



end

function axe_throw:draw(dt)
	for num, ar in ipairs(arrowsOnScreen) do
		if ar.animator == nil then
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(r,g,b,ar.a)
			love.graphics.draw(ar.img ,ar.x,ar.y, 0,ar.d,1)
		else 
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(r,g,b,ar.a)
			ar.animator:draw(ar.x,ar.y,0,1,1)
			love.graphics.rectangle("line",ar.x,ar.y,ar.img:getWidth(),ar.img:getHeight())
		end
	end
end










bomb_throw = {canThrow = true, throwTimerStart = false, upTriggered = false, throwHold = 0, end_timer = 0, endtimertriggered = false, dontPlayAnim = false}

function bomb_throw:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

bomb = {animator = nil, moving = false}
bombimg = love.graphics.newImage("itemimg/Bomb/bomb.png")
--axecollider = love.graphics.newImage("img/MainCharacterAnimations/AxeThrow/axe_collider.png")

function bomb:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function bomb_throw:keypressdown(key)
	if key == 'k' and self.canThrow and not button.button1.boolean then
		button.button1.boolean = true
		self.canThrow = false
		self.throwTimerStart = true
		self.dontPlayAnim = false
	end
end

function bomb_throw:keypressup(key)
	if key == 'k' and not self.canThrow then --and shootTimer >= 30 then
		self.upTriggered = true
	-- elseif key == 'k' and not canShoot then
	-- 	arrowHold = 0
	-- 	timeStart = true
	-- 	canShoot = true
	-- 	shootTimerStart = false
	end
end

function bomb_throw:update(dt)
	if self.throwTimerStart then
		self.throwHold = self.throwHold + 1
	else
	 	--shootTimer = 0
	end
	if self.throwHold >= 25 then
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setMode("loop")
	else
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setSpeed(1)
	end


	if not self.canThrow and self.throwHold <= 400 then
		self.throwHold = self.throwHold + 10
	end

	if not self.canThrow and self.throwHold >= 200 and self.upTriggered then
		local xA
		local b = physics:new()
		if direction == 1 then
			xA = player.x + player.img:getWidth()
		else xA = player.x-17 --- arrow.img:getWidth()
		end
		self.canThrow = true
		local r,g,b,alpha = love.graphics.getColor() 
		a = bomb:new{x = xA, y = player.y-8, fastShot = false, img = bombimg, velocity_x = 250*direction, velocity_y = 100, d = direction, bounds = b, gravityIterator = 0, destroyTimer = 0, a = alpha, stopped = false, explosionTable = {}}
		--a.animator = newCharacter("itemimg","Axe","png",0.1,"AxeSpin")
		table.insert(arrowsOnScreen,a)
		if quiver.arrows == quiver.arrowMax then
			quiver.rechargeTimer = 0
		end
		quiver.arrows = quiver.arrows - 1
		player.ammo = player.ammo - 1
        self:resetAxe()
	end

	if self.endtimertriggered then
		self.end_timer = 1 + self.end_timer
		if self.end_timer > 7 then
			self.end_timer = 0
			self.endtimertriggered = false
			self.dontPlayAnim = true
			MainCharacterAnim:resetAction("AxeThrow")
			button.button1.boolean = false
			MainCharacterAnim:setAction("Idle")
		end
	end

	for num, ar in ipairs(arrowsOnScreen) do
		if ar.explosionTable ~= nil then
			for _,exp in ipairs(ar.explosionTable) do
				exp.animator:update(dt)
			end
		end
		if ar.animator ~= nil then
			ar.animator:update(dt)
		end
		if ar.destroyTimer >= 1 then
			ar.destroyTimer = ar.destroyTimer+1
			ar.a = ar.a-5
			--ar.stopped = true
			if (ar.destroyTimer)%4 == 0 then
				local dust_obj = deathBlood:new()
				dust_obj.x = math.random(ar.x,ar.x+ar.img:getWidth())
				dust_obj.y = math.random(ar.y,ar.y+ar.img:getHeight())
				local action = math.random(0,2)
				if action == 1 then
					dust_obj.splatterAction = "Splatter"
				else dust_obj.splatterAction = "Explosion"
				end
				dust_obj.animator = newCharacter("img", "BloodSplatter", "png", .3, dust_obj.splatterAction)
				table.insert(ar.explosionTable,dust_obj)
			end
		end
		if ar.a == 0 then
			table.remove(arrowsOnScreen, num)
		end
		ar.x = ar.x + ar.velocity_x*dt
		ar.y = ar.y + ar.velocity_y*dt
		if ar.destroyTimer == 0 then
			ar.velocity_y = ar.velocity_y + 30 --35*.06*ar.gravityIterator
		end
		ar.gravityIterator = ar.gravityIterator + 1
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,1,0)
		local right = ar.bounds.right
		local borderLeft = ar.bounds.borderLeft
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,-1,0)
		local left = ar.bounds.left
		local borderRight = ar.bounds.borderRight
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,0,-1)
		local grounded = ar.bounds.down
		local borderDown = ar.bounds.borderDown
		if (ar.d == 1 and right) or (ar.d == -1 and left) then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				ar.velocity_x = 10*ar.d
			else ar.velocity_x = 0
			end
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
		if grounded then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				ar.velocity_x = 150*ar.d
			else ar.velocity_x = 0
			end
			ar.y = borderDown - ar.img:getHeight()+1
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
	end
end

function bomb_throw:resetAxe()
	self.throwHold = 0
	--timeStart = true
	self.throwTimerStart = false
	self.upTriggered = false
	self.endtimertriggered = true



end

function bomb_throw:draw(dt)
	for num, ar in ipairs(arrowsOnScreen) do
		if ar.animator == nil then
			local r,g,b,a = love.graphics.getColor()
			local alph = 255
			if ar.destroyTimer>= 1 then
				alph = 0
			end
			love.graphics.setColor(r,g,b,alph)
			local offset = 0
			if ar.d == -1 then
				offset = 16
			end
			love.graphics.draw(ar.img ,ar.x+offset,ar.y, 0,ar.d,1)
			love.graphics.rectangle("line",ar.x,ar.y,ar.img:getWidth(),ar.img:getHeight())
		else 
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(r,g,b,alph)
			ar.animator:draw(ar.x,ar.y,0,1,1)
		end
		if ar.explosionTable ~= nil then
			for _,exp in ipairs(ar.explosionTable) do
				love.graphics.setColor(255,255,255,255)
				exp.animator:setActionSpeed(exp.splatterAction, 4)
				exp.animator:setMode("loop")
				exp.animator:draw(exp.x-16,exp.y-20,0,1,1)
			end
		end
	end
end









dagger_throw = {canThrow = true, throwTimerStart = false, upTriggered = false, throwHold = 0, end_timer = 0, endtimertriggered = false, dontPlayAnim = false}

function dagger_throw:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

dagger = {animator = nil, moving = false}
daggerimg = love.graphics.newImage("itemimg/Dagger/01.png")
--axecollider = love.graphics.newImage("img/MainCharacterAnimations/AxeThrow/axe_collider.png")

function dagger:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function dagger_throw:keypressdown(key)
	if key == 'k' and self.canThrow and not button.button1.boolean then
		button.button1.boolean = true
		self.canThrow = false
		self.throwTimerStart = true
		self.dontPlayAnim = false
	end
end

function dagger_throw:keypressup(key)
	if key == 'k' and not self.canThrow then --and shootTimer >= 30 then
		self.upTriggered = true
	-- elseif key == 'k' and not canShoot then
	-- 	arrowHold = 0
	-- 	timeStart = true
	-- 	canShoot = true
	-- 	shootTimerStart = false
	end
end

function dagger_throw:update(dt)
	if self.throwTimerStart then
		self.throwHold = self.throwHold + 1
	else
	 	--shootTimer = 0
	end
	if self.throwHold >= 25 then
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setMode("loop")
	else
		button.button1.animation = "AxeThrow"
		--MainCharacterAnim:setSpeed(1)
	end


	if not self.canThrow and self.throwHold <= 400 then
		self.throwHold = self.throwHold + 10
	end

	if not self.canThrow and self.throwHold >= 100 and self.upTriggered then
		local xA
		local b = physics:new()
		if direction == 1 then
			xA = player.x + player.img:getWidth()/2
		else xA = player.x --- arrow.img:getWidth()
		end
		self.canThrow = true
		local r,g,b,alpha = love.graphics.getColor() 
		a = dagger:new{x = xA, y = player.y+16, fastShot = false, img = daggerimg, velocity_x = 300*direction, velocity_y = 0, d = direction, bounds = b, gravityIterator = 0, destroyTimer = 0, a = alpha, stopped = false, explosionTable = {}}
		--a.animator = newCharacter("itemimg","Axe","png",0.1,"AxeSpin")
		table.insert(arrowsOnScreen,a)
		if quiver.arrows == quiver.arrowMax then
			quiver.rechargeTimer = 0
		end
		quiver.arrows = quiver.arrows - 1
		player.ammo = player.ammo - 1
        self:resetAxe()
	end

	if self.endtimertriggered then
		self.end_timer = 1 + self.end_timer
		if self.end_timer > 7 then
			self.end_timer = 0
			self.endtimertriggered = false
			self.dontPlayAnim = true
			MainCharacterAnim:resetAction("AxeThrow")
			button.button1.boolean = false
			MainCharacterAnim:setAction("Idle")
		end
	end

	for num, ar in ipairs(arrowsOnScreen) do
		if ar.explosionTable ~= nil then
			for _,exp in ipairs(ar.explosionTable) do
				exp.animator:update(dt)
			end
		end
		if ar.animator ~= nil then
			ar.animator:update(dt)
		end
		if ar.destroyTimer >= 1 then
			ar.destroyTimer = ar.destroyTimer+1
			ar.a = ar.a-5
			--ar.stopped = true
			-- if (ar.destroyTimer)%4 == 0 then
			-- 	local dust_obj = deathBlood:new()
			-- 	dust_obj.x = math.random(ar.x,ar.x+ar.img:getWidth())
			-- 	dust_obj.y = math.random(ar.y,ar.y+ar.img:getHeight())
			-- 	local action = math.random(0,2)
			-- 	if action == 1 then
			-- 		dust_obj.splatterAction = "Splatter"
			-- 	else dust_obj.splatterAction = "Explosion"
			-- 	end
			-- 	dust_obj.animator = newCharacter("img", "BloodSplatter", "png", .3, dust_obj.splatterAction)
			-- 	table.insert(ar.explosionTable,dust_obj)
			-- end
		end
		if ar.a == 0 then
			table.remove(arrowsOnScreen, num)
		end
		ar.x = ar.x + ar.velocity_x*dt
		ar.y = ar.y + ar.velocity_y*dt
		if ar.destroyTimer == 0 then
			--ar.velocity_y = ar.velocity_y + 30 --35*.06*ar.gravityIterator
		end
		ar.gravityIterator = ar.gravityIterator + 1
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,1,0, "arrow")
		local right = ar.bounds.right
		local borderLeft = ar.bounds.borderLeft
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,-1,0, "arrow")
		local left = ar.bounds.left
		local borderRight = ar.bounds.borderRight
		ar.bounds = arrowBounds:get(arrowBounds,ar.x+3,ar.y-3,axecollider,0,-1, "arrow")
		local grounded = ar.bounds.down
		local borderDown = ar.bounds.borderDown
		if (ar.d == 1 and right) or (ar.d == -1 and left) then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				ar.velocity_x = 10*ar.d
			else ar.velocity_x = 0
			end
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
		if grounded then --and ar.bounds.collided.indicator ~= 'D' then
			if ar.destroyTimer <= 1 then
				--ar.velocity_x = 150*ar.d
			else ar.velocity_x = 0
			end
			--ar.y = borderDown - ar.img:getHeight()+1
			ar.velocity_y = 0
			ar.destroyTimer = ar.destroyTimer + 1
		end
	end
end

function dagger_throw:resetAxe()
	self.throwHold = 0
	--timeStart = true
	self.throwTimerStart = false
	self.upTriggered = false
	self.endtimertriggered = true



end

function dagger_throw:draw(dt)
	for num, ar in ipairs(arrowsOnScreen) do
		if ar.animator == nil then
			local r,g,b,a = love.graphics.getColor()
			local alph = 255
			if ar.destroyTimer>= 1 then
				--alph = 0
			end
			love.graphics.setColor(r,g,b,ar.a)
			local offset = 0
			if ar.d == -1 then
				offset = 16
			end
			love.graphics.draw(ar.img ,ar.x+offset,ar.y, 0,ar.d,1)
			love.graphics.rectangle("line",ar.x,ar.y,ar.img:getWidth(),ar.img:getHeight())
		else 
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(r,g,b,ar.a)
			ar.animator:draw(ar.x,ar.y,0,1,1)
		end
		if ar.explosionTable ~= nil then
			for _,exp in ipairs(ar.explosionTable) do
				love.graphics.setColor(255,255,255,255)
				exp.animator:setActionSpeed(exp.splatterAction, 4)
				exp.animator:setMode("loop")
				exp.animator:draw(exp.x-16,exp.y-20,0,1,1)
			end
		end
	end
end

