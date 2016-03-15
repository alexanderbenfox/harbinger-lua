-- enemyAI
require 'physics1'
require 'acca'
require 'shooter'
--require 'redcapedknight'
--require 'charactercontroller'

enemyState = {health = nil, collision = nil, sprite = nil, sprite_name = 'nothing', x = 0, y = 0, x2 = 0,y2 = 0, velocity_x = 0, velocity_y= 0, gravityIterator = 0, movement_function = nil, animator = nil, folder_name = nil,direction = 1, enemy = nil, gotHit = false, psystem = nil, hits = 3, hitTimer = 30, dead = false, deathTimer = 70, deathTimerMax = 0, deathAnimComplete = false, alphaFade = 255, deathSpeed = 1, hitWorth = 0, y_offset = 0, color = {r = 255, g= 255, b = 255}, canBeKnockedBack = true, hurtBox = nil, hitValue = 1, bloodSplatter = nil, hitLocation = 0, scale = 1, deathBloodTable = nil}

heartContainers = {}

function enemyState:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end




heartContainer = {timer = 200, gravityIterator = 0, sprite_name = "img/Items/health.png", sprite = nil, x1 = 0, x2 = 0, y1 = 0,y2 = 0} -- money

function heartContainer:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end
ammoPouch = heartContainer:new{sprite_name = "img/Items/ammo.png"} -- ammo
heart1 = heartContainer:new{timer = 200, gravityIterator = 0, sprite_name = "img/Items/heart.png", sprite = nil, x1 = 0, x2 = 0, y1 = 0,y2 = 0} -- health

function heartContainer:update()
	if containedInWindowCanvas(self.x1,self.y1) then
		local collision = physics:get(collision,self.x1,self.y1,self.sprite,0,-1)
		local grounded = collision.down
		local closestDown = collision.borderDown

		if not grounded then
			self.y1 = self.y1 - 1 + .1*self.gravityIterator
			self.y2 = self.y2 - 1 + .1*self.gravityIterator
			self.gravityIterator = self.gravityIterator + 1
		else
			self.gravityIterator = 0
		end
	end
end




deathBlood = {timer = 10, animator = nil, x = 0, y = 0 , splatterAction = nil}

function deathBlood:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function enemyState:load()
end

function enemyState:loadEnemy(args)
	--enemySprite = love.graphics.newImage('assets/PlaceHolder.png')
	self.collision = physics:new()
	self.animator = newCharacter("img",self.folder_name,"png",self.delay,self.idle_anim)
	self.sprite = love.graphics.newImage(self.sprite_name)
	self.bloodSplatter = newCharacter("img", "BloodSplatter", "png", .3, "Splatter")
	if self.hurtBox ~= nil then
		self.hurtBox = hurtBox:new()
	end
	if self.x > player.x then
		self.direction = -1
	else self.direction = 1
	end
	self:load()
	--self.movement_function() = rat:movement_function(0,0,0)
end

function enemyState:DeathSFX()
	if (self.deathTimer)%3 == 0 and self.deathTimer > 50 then
		local dust_obj = deathBlood:new()
		dust_obj.x = math.random(self.x,self.x+self.sprite:getWidth())
		dust_obj.y = math.random(self.y,self.y+self.sprite:getHeight())
		local action = math.random(0,4)
		if action == 1 or action == 3 then
			dust_obj.splatterAction = "Splatter"
		elseif action == 0 or action == 2 then dust_obj.splatterAction = "Splatter2"
		else dust_obj.splatterAction = "Explosion"
		end
		dust_obj.animator = newCharacter("img", "BloodSplatter", "png", .3, dust_obj.splatterAction)
		table.insert(self.deathBloodTable,dust_obj)
	end
	for _,blood in ipairs(self.deathBloodTable) do
		blood.animator:setActionSpeed(blood.splatterAction, 4)
		blood.animator:setMode("loop")
		blood.animator:draw(blood.x-self.sprite:getWidth()/2,blood.y-self.sprite:getHeight()/2,0,1,1)
	end
end

function loadEnemyPositions(currentMap, monsterTileName)
	resetMap()
	local tileString = getMapString(currentMap, monsterTileName,false)
	local enemyTable = {}
	local width = #(tileString:match("[^\n]+"))
	for x = 1, width, 1 do enemyTable[x] = {} end
	local x, y = 1,1
		for row in tileString:gmatch("[^\n]+") do
			x = 1
			for character in row:gmatch(".") do 
				-- if character == 'R' or character == 'B' or character == 'W' or character =='V' or character == 'I' or character == 'z' or character == 'S' or character == 'K' or character == 'E' then
				if character ~= '!' then
					enemyTable[x][y] = character
					x = x+1
				end
			end
			y = y+1
		end
	return enemyTable
end

function insertEnemiesFromMap(positions)
	for columnIndex, column in ipairs(positions) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			--enemyData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH}
			enemyData = {}
			if char == 'R' then -- it's a rat enemy
				enemyData = rat:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'B' then -- bouncing enemy
				enemyData = bouncingmonster:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'M' then -- bouncing enemy
				enemyData = slowwalker:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'W' then -- Walking enemy
				enemyData = walkingmonster:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'J' then -- jumping enemy
				enemyData = jumpingenemy:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'V' then
				enemyData = behelit:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)

			elseif char == 'I' then
				enemyData = necromancer:new()
				enemyData.x = x
				enemyData.y = y
				enemyData.enemy = enemyData

				table.insert(rats,enemyData)
			elseif char == 'S' then
				enemyData = spittingenemy:new()
				enemyData.x = x
				enemyData.y = y
				enemyData.enemy = enemyData
				table.insert(rats,enemyData)
			elseif char == 'C' then
				-- enemyData = spittingenemy:new()
				enemyData = wallclinger:new()
				enemyData.x = x
				enemyData.y = y
				enemyData.enemy = enemyData
				table.insert(rats,enemyData)
			elseif char == 'K' then
				enemyData= redknight:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'O' then
				--enemyData= redknight:new()
				enemyData = swordsman:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'E' then
				--enemyData= redknight:new()
				enemyData = walleye:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'F' then
				--enemyData= redknight:new()
				enemyData = fallingenemy:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			elseif char == 'c' then
				enemyData = chest:new()
				enemyData.enemy = enemyData
				enemyData.x = x
				enemyData.y = y
				table.insert(rats,enemyData)
			end
		end
	end
end

function enemyState:drawEnemy(dt)
	local x = 0
	local y = self.y
	if self.direction == 1 then
		x = self.x
	elseif self.direction == -1 then
		x = self.x+self.sprite:getWidth()
	end
	if self.direction == -1 then
		x = x - self.sprite_offset
	else
		x = x + self.sprite_offset
	end
	local bloodSplatter_y = y

	if self.right_margin ~= nil then
		if self.direction == 1 then
			x = self.x-self.left_margin
		else
			x = self.x+ self.right_margin
		end
		y = self.y - self.top_margin
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("line",self.x,self.y,self.sprite:getWidth(),self.sprite:getHeight())

	end
	local bloodSplatter_x = self.x


	if self.projectile ~= nil then
		-- for _,proj in ipairs(self.projectiles) do
		-- 	love.graphics.draw(proj.sprite,proj.x,proj.y,0,1,1)
		-- end
		love.graphics.draw(self.projectile.sprite,self.projectile.x,self.projectile.y,0,1,1)
	end

	love.graphics.setColor(self.color.r,self.color.g,self.color.b)

	if self.bloodTimer < 30 then
		if self.dead then
			self.bloodTimer = self.bloodTimer - 1
			if self.bloodTimer <= 0 then
				self.bloodTimer = 30
			end
		end
		--love.graphics.setColor(255,0,0,255)
	end
	if self.dead then
		local r,g,b = love.graphics.getColor()
		self.alphaFade = self.alphaFade - 1
		love.graphics.setColor(255,g,b,self.alphaFade)
	end
	if containedInWindowCanvas(x,self.y) then
		self.animator:draw(x,y,0,self.direction*self.scale,1*self.scale)
	end
	love.graphics.setColor(255,255,255)
	if self.bloodTimer < 30 and self.bloodTimer > 15 then
		self.bloodSplatter:setAction("Splatter")
		self.bloodSplatter:setActionSpeed("Splatter", 5)
		self.bloodSplatter:setMode("loop")
		self.bloodSplatter:draw(bloodSplatter_x+(16*-self.direction)+(self.sprite:getWidth()/2),self.hitLocation-22,0,self.direction*1.25,1.25)
	else
		self.bloodSplatter:resetAction("Splatter")
		self.hitLocation = 0
	end
	if self.dead then
		self:DeathSFX()
	end
		

	if self.hurtBox ~= nil then
		love.graphics.rectangle("line",self.hurtBox.x1,self.hurtBox.y1,self.hurtBox.x2 - self.hurtBox.x1,self.hurtBox.y2 - self.hurtBox.y1)
	end
	if self.direction < 0 then
		--self.psystem:setSpeed(direction*250)
		--self.psystem:setLinearAcceleration(0,0,0,100)
	else
		--self.psystem:setSpeed(direction*250)
		--self.psystem:setLinearAcceleration(0,0,0,100)
	end
	if self.bloodTimer < 20 then
		--love.graphics.draw(self.psystem, self.x+16, self.y+16)
	end

end

function enemyState:itemDrop()
	local rand = math.random(0,2)
	if rand == 0 then
		local heart = heartContainer:new()
		heart.x1 = self.x+16
		heart.y1 = self.y
		heart.y2 =self.y + 16
		heart.x2 = self.x+32
		heart.sprite = love.graphics.newImage(heart.sprite_name)
		table.insert(heartContainers,heart)
	end
	rand = math.random(0,3)
	if rand == 0 then
		local heart = ammoPouch:new()
		heart.x1 = self.x+16
		heart.y1 = self.y
		heart.y2 =self.y + 16
		heart.x2 = self.x+32
		heart.sprite = love.graphics.newImage(heart.sprite_name)
		table.insert(heartContainers,heart)
	end

end


rat = enemyState:new{turnaroundTimer = 50, health = 1, collision = nil, sprite = nil, sprite_name = 'img/RatAnimations/rat_collider_sprite.png', sprite_offset = -32, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "RatAnimations", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 20, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Run", delay = .1, hits = 1}

function enemyState:updateEnemy(deltaTime)
	if self.deathTimerMax == 0 then
		self.deathTimerMax = self.deathTimer
	end
	self.x2 = self.x+self.sprite:getWidth()
	self.y2 = self.y+self.sprite:getHeight()
	--self.psystem:update(deltaTime)
	self.animator:update(deltaTime)
	if self.bloodSplatter ~= nil then
		self.bloodSplatter:update(deltaTime)
	else
		self.bloodSplatter = newCharacter("img", "BloodSplatter", "png", .3, "Splatter")
	end

	if self.deathBloodTable ~= nil then
		for _,dust in ipairs(self.deathBloodTable) do
			dust.animator:update(deltaTime)
			dust.timer = dust.timer - 1
			if dust.timer < 0 then
				table.remove(self.deathBloodTable,_)
			end
		end
	else
		self.deathBloodTable = {}
	end


	local x = self.x
	local y = self.y
	if not self.dead and containedInWindowCanvas(x,y) then
		x,y = self.enemy:movement_function(self.x,self.y,deltaTime)
	end

	if (self.dead and self.sprite_name == 'img/BehelitAnimations/Idle/01.png') or (not containedInWindowCanvas(x,y) and self.sprite_name == 'img/BehelitAnimations/Idle/01.png') then
		for _,proj in ipairs(self.projectiles) do
			if not containedInWindowCanvas(proj.x,proj.y) then
				table.remove(self.projectiles,_)
			end
		end
	end

	if self.projectile ~= nil then
		self:moveProjectiles()
	end
	if containedInWindowCanvas(x,y) then

		--check collisions at the end
		self.collision = physics:get(self.collision,x,y,self.sprite,0,-1)
		local grounded = self.collision.down
		local closestDown = self.collision.borderDown
		self.collision = physics:get(self.collision,x,y,self.sprite,0,1)
		local up = self.collision.up
		local closestUp = self.collision.borderDown
		self.collision = physics:get(self.collision,x,y,self.sprite,1,0)
		local rightCollision = self.collision
		local right = self.collision.right
		local closestRight = self.collision.borderRight
		self.collision = physics:get(self.collision,x,y,self.sprite,-1,0)
		local leftCollision = self.collision
		local left = self.collision.left
		local closestLeft = self.collision.borderLeft

		if grounded and self.sprite_name ~= 'img/BouncingEnemy/Idle/01.png'then
			y = self.y
			self.gravityIterator = 0
		end
		local onDiag = false

		local delta_x = 0
		if x > self.x then
			delta_x =1
		else delta_x = -1
		end

		x,y,left,right,onDiag,grounded = self:getOnDiagonal(delta_x,x,y,left,right,onDiag,grounded)


		if not self.dead and not onDiag and (right or left) and self.sprite_name ~= 'img/BouncingEnemy/Idle/01.png' and self.sprite_name ~= 'img/BehelitAnimations/Idle/01.png' then
			x = self.x
			self.direction = self.direction * -1
		end

		if grounded and not onDiag and not (right or left) and not ((closestDown - self.sprite:getHeight()) <= self.y) and self.sprite_name ~= 'img/BouncingEnemy/Idle/01.png' then
			y = closestDown - self.sprite:getHeight()
			self.gravityIterator = 0
		end
	end

	if self.gotHit and self.hitTimer >= 30 then
		self.hits = self.hits - self.hitWorth
		self.hitTimer = self.hitTimer - 1
	end
	if self.hitTimer < 30 then
		self.hitTimer = self.hitTimer - 1
		if self.hitTimer <= 0 then
			self.hitTimer = 30
		end
	end

	-- if grounded then
	-- 	y = self.y
	-- end

	if self.dead then
		if not grounded then
			self.gravityIterator = self.gravityIterator + 1
			y = y + 35*.005*self.gravityIterator
		else 
			self.gravityIterator = 0
		end

		if self.deathTimer == self.deathTimerMax-20 then
			self:itemDrop()
		end

		if grounded and self.deathTimer >= 70 then
			self.animator:setAction("Death")
			self.animator:setMode("once")
			if self.sprite_name ~= 'assets/1.png' then -- if not walking monster
				self.animator:setActionSpeed("Death",.5)
			end
			if self.sprite_name == 'img/BehelitAnimations/Idle/01.png' then
				self.animator:setActionSpeed("Death",1.5)
				for num,proj in ipairs(self.projectiles) do
					table.remove(self.projectiles,num)
				end
			end
			self.deathTimer = self.deathTimer - 1
		elseif grounded then
			self.deathTimer = self.deathTimer - 1
			if self.deathTimer <= 0 then
				self.deathAnimComplete = true

			end
		end
	end

	if self.folder_name == "Chest" then
		y = self.y
	end


	self.x = x
	self.y = y

end

chest = rat:new{sprite_name = "img/Chest/Idle/01.png", folder_name = "Chest", idle_anim = "Idle", bloodTimer = 50, sprite_offset = 0}
function chest:movement_function(Px,Py,dt)
	self.gotHit,self.hitWorth = self:getHit(self.x,self.y)
	return Px,Py
	-- body
end

function chest:DeathSFX()
	if self.deathTimer == 69 then
		local dust_obj = deathBlood:new()
		dust_obj.x = self.x-16
		dust_obj.y = self.y
		dust_obj.timer = 20
		dust_obj.animator = newCharacter("img", "BloodSplatter", "png", .3, "SwordSlash")
		table.insert(self.deathBloodTable,dust_obj)
	end
	for _,blood in ipairs(self.deathBloodTable) do
		blood.animator:setActionSpeed("SwordSlash", 3)
		blood.animator:setMode("once")
		blood.animator:draw(blood.x,blood.y,0,1,1)
	end
end
function chest:itemDrop()

	local heart = heart1:new()
	heart.x1 = self.x+16
	heart.y1 = self.y
	heart.y2 =self.y + 16
	heart.x2 = self.x+32
	heart.sprite = love.graphics.newImage(heart.sprite_name)
	table.insert(heartContainers,heart)
	local heart_ = heart1:new()
	heart_.x1 = self.x+16 + 10
	heart_.y1 = self.y
	heart_.y2 =self.y + 16
	heart_.x2 = self.x+32 + 10
	heart_.sprite = love.graphics.newImage(heart_.sprite_name)
	table.insert(heartContainers,heart_)

end



function rat:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end


function rat:movement_function(Px,Py, dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if not self.gotHit then
		if self.waitTime == 0 then
			if self.waiting then
				self.waitTime = math.random(50,150)
			else
				self.waitTime = math.random(10,40)
			end
			self.waiting = not self.waiting
		end
		self.waitTime = self.waitTime - 1
	end
	if not self.waiting and not self.gotHit then
		self.animator:setAction("Run")
	else
		self.animator:setAction("Idle")
	end
	self.animator:setMode("loop")
	self.animator:play()
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	self.collision = physics:get(self.collision,x,y-2,self.sprite,1,0)
	local rightCollision = self.collision
	local right = self.collision.right
	local closestRight = self.collision.borderRight
	self.collision = physics:get(self.collision,x,y-2,self.sprite,-1,0)
	local leftCollision = self.collision
	local left = self.collision.left
	local closestLeft = self.collision.borderLeft

	-- if left or right then
	-- 	self.direction = self.direction*-1
	-- end
	local falling = self:getFalling(x,y,self.direction)

	if falling and self.turnaroundTimer >= 50 then 
		self.direction = -self.direction 
		--self.turnaroundTimer = 49
	end

	-- if self.turnaroundTimer < 50 then
	-- 	self.turnaroundTimer = self.turnaroundTimer-1
	-- 	if self.turnaroundTimer == 0 then
	-- 		self.turnaroundTimer = 50
	-- 	end
	-- end

	if not self.waiting and not self.gotHit then 
		x = x + self.direction * 110 * dt
	elseif self.gotHit then
		x = x + -self.direction * 100 * dt
		y = y - 50 * dt
	end

	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end

	return x, y
end

function enemyState:getFalling(x,y, direction)
	x = x+direction*32
	y = y+10
	self.collision = physics:get(self.collision,x,y,self.sprite,0,-1)
	local grounded = self.collision.down
	local closestDown = self.collision.borderDown
	-- self.collision = physics:get(self.collision,x,y,self.sprite,0,1)
	-- local up = self.collision.up
	-- local closestUp = self.collision.borderDown
	-- self.collision = physics:get(self.collision,x,y,self.sprite,1,0)
	-- local rightCollision = self.collision
	-- local right = self.collision.right
	-- local closestRight = self.collision.borderRight
	-- self.collision = physics:get(self.collision,x,y,self.sprite,-1,0)
	-- local leftCollision = self.collision
	-- local left = self.collision.left
	-- local closestLeft = self.collision.borderLeft
	return not grounded
end


function enemyState:getHit(x,y)
local gotHit = false
local hitWorth = 0
local hitLocation = 0
for _,box in ipairs(hazardBounds) do
	if x >= box.x1 and x<=box.x2 then
		if (y+self.sprite:getHeight()-30) >= box.y1 and (y+self.sprite:getHeight()-30) <= box.y2 then
			return true, 100
		end
	end
end
	for b_x = blade_collider.x1, blade_collider.x2 do
		for b_y = blade_collider.y1, blade_collider.y2 do
			if b_x >= x and b_x <= x + self.sprite:getWidth() then
				if b_y >= y and b_y <= y + self.sprite:getHeight() then
					gotHit = true
					if characterState.crouchAttack then
						hitWorth = 3
					else
						hitWorth = 3
					end
					hitLocation = b_y
					if self.hitLocation == 0 then
						self.hitLocation = hitLocation
					end
					return gotHit, hitWorth
				end
			end
		end
	end
	hitLocation = 0
	-- for numAr, ar in ipairs(arrowsOnScreen) do
	-- 	if not ar.stopped then
	-- 		if ar.d == 1 then
	-- 				s = 19
	-- 		else
	-- 				s = -19
	-- 		end
	-- 		if ar.x+s >= x and ar.x+s<= x+self.sprite:getWidth() then
	-- 			if ar.y+ar.img:getHeight()/2 >= y and ar.y+ar.img:getHeight()/2 <= y+ self.sprite:getHeight() then
	-- 				gotHit = true
	-- 				hitWorth = 2
	-- 				hitLocation = ar.y
	-- 			end
	-- 		end
	-- 	end
	-- end
	for numAr,ar in ipairs(arrowsOnScreen) do
		if not ar.stopped then
			for x_ = ar.x,ar.x+ar.img:getWidth() do
				if x_ >= x and x_ <= x + self.sprite:getWidth() then
					for y_ = ar.y, ar.y+ar.img:getHeight() do
						if y_ >= y and y_ <= y+self.sprite:getHeight() then
							gotHit = true
							hitWorth = 2
							hitLocation = ar.y
						end
					end
				end
			end
		end
	end
	if self.hitLocation == 0 then
		self.hitLocation = hitLocation
	end
	return gotHit, hitWorth
end

hurtBox = {x1 = 0, x2 = 0, y1 = 0, y2 = 0}

function hurtBox:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

walkingmonster = rat:new{health = 1, collision = nil, sprite = nil, sprite_name = 'assets/1.png', sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "WalkingMonster", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Walk", delay = .15, y_offset = -16, attacking = false, hurtBox = hurtBox:new(), speed = 115, triggered = false}

slowwalker = walkingmonster:new{hits = 6, color = {r = 255, g= 0, b = 255}, speed = 50}


function walkingmonster:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self


	return o

end


function walkingmonster:movement_function(Px,Py, dt)
	if not self.triggered then
		if player.x >= self.x then
			self.direction = 1
		else
			self.direction = -1
		end
		self.triggered = true
	end
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.gotHit and self.direction == direction then
		self.direction = self.direction*-1
	end

	if not self.gotHit then
		if self.waitTime == 0 then
			if self.waiting then
				self.waitTime = math.random(100,200)
			else
				self.waitTime = math.random(40,60)
			end
			self.waiting = not self.waiting
			local i = math.random(0,1)
			if i == 1 then
				self.waiting = false
			end
		end
		self.waitTime = self.waitTime - 1
	end
	if not self.waiting and not self.gotHit then
		self.animator:setAction("Walk")
		self.attacking = false
	elseif self.waiting then
		self.animator:setAction("Attack")
		self.attacking = true
	else
		self.animator:setAction("Idle")
		self.attacking = false
	end


	local boxOffset = 0
	if self.direction == -1 then
		boxOffset = -18
	end
	if self.attacking then
		self.hurtBox.x1 = self.x + boxOffset
		self.hurtBox.y1 = self.y
		self.hurtBox.x2 = self.hurtBox.x1 + 50
		self.hurtBox.y2 = self.hurtBox.y1 + 32
	else
		self.hurtBox.x1 = 0
		self.hurtBox.y1 = 0
		self.hurtBox.x2 = 0
		self.hurtBox.y2 = 0
	end


	self.animator:setMode("loop")
	self.animator:play()
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	self.collision = physics:get(self.collision,x,y-2,self.sprite,1,0)
	local rightCollision = self.collision
	local right = self.collision.right
	local closestRight = self.collision.borderRight
	self.collision = physics:get(self.collision,x,y-2,self.sprite,-1,0)
	local leftCollision = self.collision
	local left = self.collision.left
	local closestLeft = self.collision.borderLeft


	-- if left or right then
	-- 	self.direction = self.direction*-1
	-- end

	if not self.waiting and not self.gotHit then 
		x = x + self.direction * self.speed * dt
	elseif self.gotHit then
		x = x + -self.direction * self.speed * dt
		y = y - 50 * dt
	end

	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end

	return x, y
end

function enemyState:getOnDiagonal(delta_x,x,y,left,right,onDiag,grounded)
	onDiag = false
	local slopeSpot = 0
	local side = nil


	onDiag, slopeSpot, side = getCornerCollision(x+self.sprite:getWidth()-4,y+self.sprite:getHeight(),1)
	local onDiag2, slopeSpot2, side2 = getCornerCollision(x+self.sprite:getWidth()-2,y+self.sprite:getHeight()-2,1)
	--local onDiag3, slopeSpot3 = getRightCornerCollision(x+self.sprite:getWidth()-2,y+self.sprite:getHeight()-2)


	--print(slopeSpot)


	local becameGrounded = false

	if side == "R" or side2 == "R" then
		if onDiag then
			--x = self.x + math.abs(self.x-x)/4
			y = slopeSpot - self.sprite:getHeight()
			print("slope1",slopeSpot)
			grounded = true
			right = false
		end
		if onDiag2 and not onDiag then
			--x = x + math.abs(self.x-x)/4
			y = slopeSpot2 - self.sprite:getHeight()
			grounded = true
			print(slopeSpot2)
			right = false
			onDiag = true
		end
	end

	if delta_x < 0 then
		local onDiag3, slopeSpot3, side3 = getCornerCollision(x+self.sprite:getWidth()-4,y+self.sprite:getHeight()+10,1)
		local onDiag4, slopeSpot4, side3 = getCornerCollision(x+self.sprite:getWidth()-4,y+self.sprite:getHeight()+5,1)
		local onDiag5, slopeSpot5, side3 = getCornerCollision(x+self.sprite:getWidth()-4,y+self.sprite:getHeight()+5,1)

		if side3 == "R" or side4 == "R" or side5 == "R" then
			if onDiag4 and not onDiag then
				--x = x + math.abs(self.x-x)/4
				y = slopeSpot4 - self.sprite:getHeight()
				grounded = true
				--print(slopeSpot3)
				right = false
				onDiag = true
			end
			if onDiag3 and not onDiag then
				--x = x + math.abs(self.x-x)/4
				y = slopeSpot3 - self.sprite:getHeight()
				grounded = true
				--print(slopeSpot4)
				right = false
				onDiag = true
			end
		end
	end

	side = nil
	if not onDiag then
		onDiag, slopeSpot, side = getCornerCollision(x+4,y+self.sprite:getHeight(),-1)
		onDiag2, slopeSpot2, side2 = getCornerCollision(x+2,y+self.sprite:getHeight()-2,-1)
		--local onDiag10, slopeSpot10, side10 = getCornerCollision(x-10,y+self.sprite:getHeight()-5,-1)
	end
	--local onDiag3, slopeSpot3 = getRightCornerCollision(x+self.sprite:getWidth()-2,y+self.sprite:getHeight()-2)

	--print(slopeSpot)
	if side == "L" or side2 == "L" then

		if onDiag then
			--x = self.x + math.abs(self.x-x)/4
			y = slopeSpot - self.sprite:getHeight()
			grounded = true
			left = false
		end
		if onDiag2 and not onDiag then
			--x = x + math.abs(self.x-x)/4
			y = slopeSpot2 - self.sprite:getHeight()
			grounded = true
			print(slopeSpot2)
			left = false
			onDiag = true
		end
	end

	if delta_x > 0 then
		local onDiag3, slopeSpot3, side3 = getCornerCollision(x+4,y+self.sprite:getHeight()+10,-1)
		local onDiag4, slopeSpot4, side4 = getCornerCollision(x+4,y+self.sprite:getHeight()+5,-1)
		local onDiag5, slopeSpot5, side5 = getCornerCollision(x+4,y+self.sprite:getHeight()+5,-1)

		if side3 == "L" or side4 == "L" or side5 == "L" then
			if onDiag4 and not onDiag then
				--x = x + math.abs(self.x-x)/4
				y = slopeSpot4 - self.sprite:getHeight()
				grounded = true
				--print(slopeSpot3)
				left = false
				onDiag = true
			end
			if onDiag3 and not onDiag then
				--x = x + math.abs(self.x-x)/4
				y = slopeSpot3 - self.sprite:getHeight()
				grounded = true
				--print(slopeSpot4)
				left = false
				onDiag = true
			end
		end
	end

	return x,y,left,right,onDiag,grounded
end

bouncingmonster = rat:new{health = 1, collision = nil, sprite = nil, sprite_name = 'img/BouncingEnemy/Idle/01.png', sprite_offset = 0, x = 200, y = 700, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "BouncingEnemy", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .15, direction_x = 1, direction_y = 1}

function bouncingmonster:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function bouncingmonster:movement_function(Px,Py, dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.gotHit and self.direction_x == direction then
		self.direction_x = self.direction_x*-1
	end
	if not self.gotHit then
		if self.waitTime == 0 then
			if self.waiting then
				self.waitTime = math.random(50,150)
			else
				self.waitTime = math.random(40,60)
			end
			self.waiting = not self.waiting
		end
		self.waitTime = self.waitTime - 1
	end
	if not self.waiting and not self.gotHit then
		self.animator:setAction("Moving")
	elseif self.waiting then
		self.animator:setAction("Idle")
	else
		self.animator:setAction("Idle")
	end
	self.animator:setMode("loop")
	self.animator:play()

	self.collision = physics:get(self.collision,x,y-2,self.sprite,1,0)
	local rightCollision = self.collision
	local right = self.collision.right
	local closestRight = self.collision.borderRight
	self.collision = physics:get(self.collision,x,y-2,self.sprite,-1,0)
	local leftCollision = self.collision
	local left = self.collision.left
	local closestLeft = self.collision.borderLeft
	self.collision = physics:get(self.collision,x,y-2,self.sprite,0,1)
	local top = self.collision.up
	local closestTop = self.collision.borderRight
	self.collision = physics:get(self.collision,x,y-2,self.sprite,0,-1)
	local bottom = self.collision.down
	local closestBottom = self.collision.borderLeft


	if left or right then
		self.direction_x = self.direction_x * -1
	end
	if top or bottom then
		self.direction_y = self.direction_y * -1
	end

	if not self.waiting and not self.gotHit then 
		x = x + self.direction_x * 75 * dt
		y = y + self.direction_y * 75 * dt
	elseif self.gotHit then
		--x = x + -self.direction * 75 * dt
		--y = y - 50 * dt
	end

	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end

	return x, y
end

behelit = rat:new{health = 1, collision = nil, sprite = nil, sprite_name = 'img/BehelitAnimations/Idle/01.png', sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "BehelitAnimations", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 100, hits = 10}
function behelit:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.projectiles = {}
	self.projectile = {}
	self.projectile.x = 0
	self.projectile.y = 0
	self.projectile.vx = 0
	self.projectile.vy = 0
	self.projectile.speed = 100
	self.projectile.gravityIterator = 0
	self.projectile.bounds = nil
	self.projectile.destroyTimer = 0
	self.projectile.sprite_name = 'img/BehelitAnimations/behelitproj.png'
	self.projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
	return o
end

projthing = {}

function projthing:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function behelit:movement_function(Px,Py, dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.shootTimer >= 100 then
		--projectile = self.projectile
		local projectile = projthing:new()
		projectile.speed = 100
		projectile.gravityIterator = 0
		projectile.bounds = nil
		projectile.destroyTimer = 0
		projectile.sprite_name = 'img/BehelitAnimations/behelitproj.png'
		projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
		projectile.x = self.x + self.sprite:getWidth()/2
		projectile.y = self.y
		projectile.vx, projectile.vy = getProjectileVelocities(projectile.x, projectile.y,player.x+player.img:getWidth()/2,player.y+player.img:getHeight()/2,dt,projectile.speed)
		--table.insert(self.projectiles,projectile)
		self.projectile = projectile
		self.shootTimer = 0
	end
	self.shootTimer = self.shootTimer + 1
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y

end

function getProjectileVelocities(initial_x,initial_y,target_x, target_y, dt, speed)
	local diff_x = target_x - initial_x
	--local _Vx = diff_x/60
	--local time = 60
	if(math.abs(diff_x) > 256) then
		local d = 1
		if diff_x <= 0 then
			d = -1
		else d = 1
		end
		local _Vx = 5*d
		local time = diff_x/_Vx
		local _Vy = (((-50*.005)*time)/2) + ((target_y-initial_y)/time) 
		return _Vx,_Vy
	else
		local _Vx = diff_x/55
		local time = 55
		local _Vy = (((-50*.005)*time)/2) + ((target_y-initial_y)/time) 
		return _Vx,_Vy
	end
	-- local diff_x = target_x - initial_x
	-- local d = 1
	-- if diff_x <= 0 then
	-- 	d = -1
	-- else d = 1
	-- end
	-- local _Vx = 10*d
	-- local time = diff_x/_Vx
	-- local _Vy = (((-50*.005)*time)/2) + ((target_y-initial_y)/time)
	-- return _Vx,_Vy
end

function behelit:moveProjectiles()
	--for _,proj in ipairs(self.projectiles) do
	local proj = self.projectile
	proj.gravityIterator = proj.gravityIterator + 1
	proj.x = proj.x + proj.vx
	proj.y = proj.y + proj.vy
	proj.vy = proj.vy + 50*.005
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,1,0)
	local right = proj.bounds.right
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,-1,0)
	local left = proj.bounds.left
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,1)
	local up = proj.bounds.up
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,-1)
	local down = proj.bounds.down
	local d = 1
	if proj.vx < 0 then
		d = -1
	end
	if left or right or down or up then --and ar.bounds.collided.indicator ~= 'D' then
		if proj.destroyTimer <= 1 then
			proj.vx = 10*d
		else proj.vx = 0
		end
		proj.vy = 0
		proj.vx = 0
		proj.destroyTimer = proj.destroyTimer + 1
	end
	if proj.destroyTimer > 10 then
		--table.remove(self.projectiles,_)
		self.projectile = nil
	end
	--end
end

function loadEnemies(map_path)
	if rats ~= nil then
		for _,rat in ipairs(rats) do
			table.remove(rats,_)
		end
	end
	rats = {}
	-- rat_ = rat:new()
	-- rat_.enemy = rat_
	-- anotherrat = rat:new()
	-- anotherrat.enemy = anotherrat
	-- anotherrat.x = 300
	-- table.insert(rats,rat_)
	-- table.insert(rats,anotherrat)
	-- 	--monsters = {}
	-- mon1 = walkingmonster:new()
	-- mon1.enemy = mon1
	-- --mon1.y = 750
	-- table.insert(rats,mon1)
	-- mon2 = bouncingmonster:new()
	-- mon2.enemy = mon2
	-- table.insert(rats,mon2)
	
	
	local pos = loadEnemyPositions(map_path,"MonsterTile")
	insertEnemiesFromMap(pos)
	for num, ratt in ipairs(rats) do
		print("RA")
		ratt:loadEnemy()
	end
end

necromancer = rat:new{health = 1, collision = nil, sprite = nil, sprite_name = 'img/NecromancerAnimations/Idle/01.png', sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "NecromancerAnimations", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .25, projectiles = nil, projectile = nil, shootTimer = 100, hits = 10, summonCount = 0}

function necromancer:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function necromancer:movement_function(Px,Py, dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.shootTimer >= 150 then
		self.animator:setAction("Summon")
		if self.shootTimer >= 250 and self.summonCount ~= 3 then
			self.summonCount = self.summonCount + 1
			local skeleton = {}
			skeleton = walkingmonster:new()
			--skeleton.collision = physics:get(skeleton.collision,x,y,skeleton.sprite)
			if player.x > x then
				skeleton.direction = 1
				self.direction = 1
			else
				skeleton.direction = -1
				self.direction=-1
			end
			skeleton.x = x
			skeleton.y = y
			skeleton.enemy = skeleton
			skeleton:loadEnemy()
			table.insert(rats,skeleton)
			self.shootTimer = 0
		end
		if self.shootTimer >= 250 and self.summonCount == 3 then
			self.summonCount = self.summonCount + 1
			local skeleton = {}
			skeleton = walkingmonster:new()
			--skeleton.collision = physics:get(skeleton.collision,x,y,skeleton.sprite)
			if player.x > x then
				skeleton.direction = -1
				self.direction = 1
			else
				skeleton.direction = 1
				self.direction = -1
			end
			skeleton.x = player.x - direction * 96
			skeleton.y = player.y
			skeleton.enemy = skeleton
			skeleton.collision = physics:new()
			skeleton.animator = newCharacter("img",skeleton.folder_name,"png",skeleton.delay,skeleton.idle_anim)
			skeleton.sprite = love.graphics.newImage(skeleton.sprite_name)
			table.insert(rats,skeleton)
			self.shootTimer = 0
			self.summonCount = 0
		end
	else
		self.animator:setAction("Idle")
	end
	self.shootTimer = self.shootTimer + 1
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y

end




spittingenemy = walkingmonster:new{sprite_name = "img/SpittingMonster/Idle/01.png",health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "SpittingMonster", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 70, hits = 9, color = {r = 255,g = 0, b = 100}, notShoot = false, shootLimit = 32*6}
function spittingenemy:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.projectiles = {}
	self.projectile = {}
	self.projectile.x = 0
	self.projectile.y = 0
	self.projectile.vx = 0
	self.projectile.vy = 0
	self.projectile.speed = 100
	self.projectile.gravityIterator = 0
	self.projectile.bounds = nil
	self.projectile.destroyTimer = 0
	self.projectile.sprite_name = 'img/SpittingMonster/spittingmonsterproj.png'
	self.projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
	self.projectile.shootLimit = self.projectile.y
	return o
end

function spittingenemy:movement_function(Px,Py,dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	
	if self.shootTimer <= 100 then
		if self.shootTimer >=40 then
			self.animator:setAction("Attack")
		elseif self.shootTimer >= 30 then
			self.animator:setAction("Attack")
		elseif self.shootTimer>1 then
			self.animator:setAction("Attack")
			--projectile = self.projectile
			local projectile = projthing:new()
			projectile.speed = 100
			projectile.gravityIterator = 0
			projectile.bounds = nil
			projectile.destroyTimer = 0
			projectile.sprite_name = 'img/SpittingMonster/spittingmonsterproj.png'
			projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
			local offset = 1
			if self.direction == 1 then offset = 1 else offset = -1 end
			projectile.x = self.x + self.sprite:getWidth()/2*offset
			projectile.y = self.y - self.sprite:getHeight()/5
			projectile.vx, projectile.vy = 3*self.direction, -2
			projectile.shootLimit = projectile.y+self.sprite:getHeight()-32
			--table.insert(self.projectiles,projectile)
			self.projectile = projectile
		else
			self.shootTimer = math.random(100,200)
			self.animator:resetAction("Attack")
			self.animator:setAction("Idle")
		end
	end
	if player.x >= self.x then
		self.direction = 1
	else self.direction = -1
	end
	self.shootTimer = self.shootTimer - 1
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y
end

function spittingenemy:moveProjectiles()
	--for _,proj in ipairs(self.projectiles) do
	local proj = self.projectile
	--print(table.getn(self.projectiles))
	proj.gravityIterator = proj.gravityIterator + 1
	proj.x = proj.x + proj.vx
	proj.y = proj.y + proj.vy
	--print(proj.vx)
	if proj.vy <= 8 then
		proj.vy = proj.vy + 7*.005*proj.gravityIterator
	end
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,1,0)
	local right = proj.bounds.right
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,-1,0)
	local left = proj.bounds.left
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,1)
	local up = proj.bounds.up
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,-1)
	local down = proj.bounds.down
	local d = 1
	if proj.vx < 0 then
		d = -1
	end
	local reachedLimit = false
	-- if math.abs(self.y - proj.y) > self.shootLimit then
	-- 	reachedLimit = true
	-- end
	if proj.y >= proj.shootLimit then
		reachedLimit = true
	end
	if left or right or down or up or reachedLimit then --and ar.bounds.collided.indicator ~= 'D' then
		if proj.destroyTimer <= 1 then
			proj.vx = 10*d
		else proj.vx = 0
		end
		proj.vy = 0
		proj.vx = 0
		proj.destroyTimer = proj.destroyTimer + 1
	end
	if proj.destroyTimer > 10 then
		--table.remove(self.projectiles,_)
		self.projectile = nil
	end
	--end
end





-- red caped knight
--require 'enemystate'

redknight = rat:new{hits = 20, collision = nil, sprite = nil, sprite_name = 'img/NecromancerAnimations/Idle/01.png', sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "RedCapedKnight", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Walk", delay = .15, y_offset = -16, attacking = false, hurtBox = hurtBox:new(), left_margin = 32, right_margin = 80+12, top_margin = 76, moveTowardsPlayer = false, movetowardsTimer = 0, deathTimer = 250, hurtBoxOut = false, hitValue = 2}

function redknight:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self


	return o

end


function redknight:movement_function(Px,Py, dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py

	local nearPlayer = false
	local nearPlayerValue = math.random(64,96)
	if math.abs((player.x+16) - (self.x+32)) <= nearPlayerValue then
		nearPlayer = true
	end

	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.gotHit and self.direction == direction then
		local a = math.random(0,1)
		if not self.attacking or a == 1 and not self.waiting then
			self.direction = self.direction*-1
		end
	end

	if self.moveTowardsPlayer and not self.attacking and not self.waiting then
		if self.x+32 <= player.x+16 then
			self.direction = 1
		else self.direction = -1
		end
	end
	if self.gotHit and not self.attacking then
		self.animator:resetAction("Attack")
	end
	if not self.gotHit then
		if self.waitTime <= 0 then
			self.animator:resetAction("Attack")
			if self.waiting then
				if self.moveTowardsPlayer then
					self.waitTime = math.random(50,200)
					self.moveTowardsPlayer = false
					if self.x+32 <= player.x+16 and not self.waiting then
						self.direction = -1
						else self.direction = 1
					end
					local i = math.random(0,1)
					if i == 0 then
						self.moveTowardsPlayer = true
						self.waitTime = math.random(100,150)
					end
				else
					self.waitTime = math.random(100,150)
					self.moveTowardsPlayer = true
				end

			elseif nearPlayer then
				self.moveTowardsPlayer = true
				self.attacking = true
				self.waitTime = 170
				if self.moveTowardsPlayer == false then
					local i = math.random(0,1)
					if i == 0 then
						self.attacking = false
						self.waitTime = 0
					end
				end
			end
			self.waiting = not self.waiting

		end
		self.waitTime = self.waitTime - 1
		if not self.attacking and not self.waiting and self.moveTowardsPlayer and nearPlayer then
			self.attacking = true
			self.waiting = true
			self.waitTime = 170
		end


	end
	if not self.waiting and not self.gotHit then
		self.animator:setAction("Walk")
		self.animator:setMode("loop")
		self.attacking = false
		self.attacking = false
	elseif self.waiting then
		self.animator:setAction("Attack")
		self.animator:setMode("once")
		if self.waitTime < 120 and self.waitTime > 45 and not (self.waitTime> 50 and self.waitTime<110) then
			self.attacking = true
			self.hurtBoxOut = true
		else self.attacking = true
			self.hurtBoxOut = false
		end
		if self.waitTime > 150 then
			self.animator:setAction("Idle")
			self.animator:resetAction("Attack")
		end

	else
		self.animator:setAction("Idle")
		self.attacking = false
	end


	local boxOffset = 32
	if self.direction == -1 then
		boxOffset = -80
	end
	if self.hurtBoxOut then
		self.hurtBox.x1 = self.x + boxOffset
		self.hurtBox.y1 = self.y-32
		self.hurtBox.x2 = self.hurtBox.x1 + 96
		self.hurtBox.y2 = self.hurtBox.y1 + 96
	else
		self.hurtBox.x1 = 0
		self.hurtBox.y1 = 0
		self.hurtBox.x2 = 0
		self.hurtBox.y2 = 0
	end


	--self.animator:setMode("loop")
	self.animator:play()
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	self.collision = physics:get(self.collision,x,y-2,self.sprite,1,0)
	local rightCollision = self.collision
	local right = self.collision.right
	local closestRight = self.collision.borderRight
	self.collision = physics:get(self.collision,x,y-2,self.sprite,-1,0)
	local leftCollision = self.collision
	local left = self.collision.left
	local closestLeft = self.collision.borderLeft


	-- if left or right then
	-- 	self.direction = self.direction*-1
	-- end

	if not self.waiting and not self.gotHit and not self.attacking then 
		if self.x+32 <= player.x+16 and self.direction == -1 or (self.direction == 1 and self.x+32 >= player.x+16) then
			x = x + self.direction * 70 * dt
		else x = x+self.direction*90*dt
		end
	elseif self.gotHit and not self.attacking then
		x = x + -self.direction * 75 * dt
		y = y - 50 * dt
	end

	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end

	return x, y
end






wallclinger = walkingmonster:new{health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "WallClinger", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 120, hits = 4, color = {r = 255,g = 255, b = 255}, notShoot = false, shootLimit = 32*6, upperLimit = 0, dontMove = false, moveTimer = 100, moveUp = true}
function wallclinger:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.projectiles = {}
	self.projectile = {}
	self.projectile.x = 0
	self.projectile.y = 0
	self.projectile.vx = 0
	self.projectile.vy = 0
	self.projectile.speed = 100
	self.projectile.gravityIterator = 0
	self.projectile.bounds = nil
	self.projectile.destroyTimer = 0
	self.projectile.sprite_name = 'img/WallClinger/fireball.png'
	self.projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
	return o
end

function NormalizeVector(x1,x2,y1,y2)
	local x = x2 - x1
	local y = y2-y1

	local mag = math.sqrt((x*x) + (y+y))

	local norm_x = x/mag
	local norm_y = y/mag

	return norm_x,norm_y
end


function wallclinger:movement_function(Px,Py,dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	
	if self.shootTimer <= 100 and not self.notShoot and math.abs((self.x+32) - (player.x+32)) > 75 then
		if self.shootTimer >=30 then
			self.animator:setAction("Idle")
			self.dontMove = false
		elseif self.shootTimer >= 10 then
			self.animator:setAction("Idle")
			self.dontMove = false
		elseif self.shootTimer == 9 then
			self.dontMove = true
			self.animator:setAction("Shake")
			--projectile = self.projectile
			local projectile = projthing:new()
			projectile.speed = 100
			projectile.gravityIterator = 0
			projectile.bounds = nil
			projectile.destroyTimer = 0
			projectile.sprite_name = 'img/WallClinger/fireball.png'
			projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
			local offset = 1
			if self.direction == 1 then offset = 1 else offset = 0 end
			projectile.x = self.x + self.sprite:getWidth()*offset
			projectile.y = self.y + self.sprite:getHeight()/4
			local normal_vecX, normal_vecY = NormalizeVector(projectile.x,player.x+player.img:getWidth()/2,projectile.y,player.y+player.img:getHeight()/2)
			local multiplier = 2.5
			-- if normal_vecY < -.7 or normal_vecY > .7 then
			--  	multiplier = 1
			-- end

			projectile.vx, projectile.vy = normal_vecX*multiplier, normal_vecY*multiplier
			--table.insert(self.projectiles,projectile)
			self.projectile = projectile
			self.notShoot = false
			local i = math.random(0,2)
			if i == 3 then
				self.shootTimer = 160
				self.notShoot = true
				self.animator:setAction("Idle")
			end
		else
			self.animator:setAction("Shake")
			if self.shootTimer < 0 then
				self.shootTimer = 100
			end
		end
	end
	if player.x >= self.x then
		self.direction = 1
	else self.direction = -1
	end
	if not self.dontMove then
		self.moveTimer = self.moveTimer - 1
		if self.moveTimer <= 0 then
			self.moveTimer = math.random(50,100)
			self.moveUp = not self.moveUp
		end
		if self.moveUp then
			y = y - .5
		else
			y = y + .5
		end
	end

	self.shootTimer = self.shootTimer - 1
	if self.notShoot and self.shootTimer <= 0 then
		self.notShoot = false
	end
	if self.notShoot then
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y
end

function wallclinger:moveProjectiles()
	--for _,proj in ipairs(self.projectiles) do
	local proj = self.projectile
	--print(table.getn(self.projectiles))
	proj.gravityIterator = proj.gravityIterator + 1
	proj.x = proj.x + proj.vx
	proj.y = proj.y + proj.vy
	--print(proj.vx)
	--proj.vy = proj.vy + 50*.005
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,1,0)
	local right = proj.bounds.right
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,-1,0)
	local left = proj.bounds.left
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,1)
	local up = proj.bounds.up
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,-1)
	local down = proj.bounds.down
	local d = 1
	if proj.vx < 0 then
		d = -1
	end
	local reachedLimit = false
	if math.abs(self.x - proj.x) > self.shootLimit then
		--reachedLimit = true
	end
	if left or right or down or up or reachedLimit then --and ar.bounds.collided.indicator ~= 'D' then
		if proj.destroyTimer <= 1 then
			proj.vx = 10*d
		else proj.vx = 0
		end
		proj.vy = 0
		proj.vx = 0
		proj.destroyTimer = proj.destroyTimer + 1
	end
	if proj.destroyTimer > 10 then
		--table.remove(self.projectiles,_)
		self.projectile = nil
	end
	--end
end




jumpingenemy = walkingmonster:new{sprite_name = 'img/JumpingEnemy/Idle/sprite.png',health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "JumpingEnemy", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 120, hits = 4, color = {r = 255,g = 255, b = 255}, preJump = false, preJumpTimer = 20, landing = false, landingTimer = 10, falling = false, jumping = false, shotProjectile = false, waiting = false, waitTimer = 50, hits = 4, scale = 1.50}



function jumpingenemy:movement_function(Px,Py,dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	local prev_y = y
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local groundLocation = self.collision.borderDown
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	
	if self.waitTimer <= 0 then
		if self.preJumpTimer >= 0 then
			self.animator:setAction("PreJump")
			self.preJumpTimer = self.preJumpTimer - 1
		elseif self.preJumpTimer <= 0 then
			self.jumping = true
		end

		if self.jumping then
			self.animator:setAction("Jump")
			self.animator:setMode("loop")
			y = y - 200*.007*5
			if prev_y <= y then
				self.jumping = false
				self.falling = true
			end
		end

		if self.falling then
			self.animator:setAction("Jump")
			self.animator:setMode("loop")
			if grounded then
				self.jumping = false
				self.falling = false
				self.landing = true
				y = groundLocation-self.sprite:getHeight()
			end
		end

		if self.landing then 
			if groundLocation ~= nil then
				y = groundLocation-self.sprite:getHeight()
			end
			self.animator:setAction("Land")
			self.animator:setMode("loop")
			self.landingTimer = self.landingTimer - 1

			if self.landingTimer <= 0 then
				self.landing = false
				self.waitTimer = 50
				self.preJumpTimer = 20
				self.landingTimer = 10
			end
		end


		if (self.jumping or self.falling) and not grounded then
			x = x+self.direction*90*dt
		end
	else
		self.landing = false
		self.jumping = false
		self.falling = false
		self.waitTimer = self.waitTimer - 1
	end


	if self.waitTimer > 0 then
		if player.x >= self.x then
			self.direction = 1
		else self.direction = -1
		end
	end
	self.shootTimer = self.shootTimer - 1
	if self.notShoot and self.shootTimer <= 0 then
		self.notShoot = false
	end
	if self.notShoot then
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y
end


swordsman = walkingmonster:new{sprite_name = 'img/SwordsMan/sprite.png',health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "SwordsMan", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 120, hits = 4, color = {r = 255,g = 255, b = 255}, attacking = false, playerInRange = false, preAttackTimer = 30, chargeTimer = 10,attackTimer = 100, waitTimer = 25, waiting = false, hits = 9, scale = 1, hurtBoxOut = false, left_margin = 15, right_margin = 39, top_margin = 42, deathTimer = 120}



function swordsman:movement_function(Px,Py,dt)
	self.animator:setActionSpeed("Death", 2)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	local prev_y = y
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local groundLocation = self.collision.borderDown
	local grounded = self.collision.down
	if not grounded then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	else 
		self.gravityIterator = 0
	end
	
	if math.abs(player.x-x) <= 4*32 then
		self.playerInRange = true
	end

	if self.playerInRange then
		if not self.attacking and not self.waiting then
			self.animator:setAction("Charge")
			self.animator:setActionSpeed("Charge", 5)
			self.animator:setMode("loop")
			self.preAttackTimer = self.preAttackTimer - 1
			if self.preAttackTimer <= 0 then
				self.attacking = true
			end
		end

		if self.attacking then
			if self.chargeTimer <= 0 then
				self.animator:setAction("Attack")
				self.animator:setMode("once")
				if self.attackTimer < 75 then
					self.hurtBoxOut = true
				end
				self.attackTimer = self.attackTimer - 1
				if self.attackTimer <= 0 then
					self.attacking = false
					--self.playerInRange = false
					self.hurtBoxOut = false
					self.animator:resetAction("Attack")
					self.waiting = true
				end

			else 
				self.chargeTimer = self.chargeTimer - 1
				x = x+self.direction*300*dt
			end
		end

		if self.waiting then
			self.animator:setAction("Charge")
			self.waitTimer = self.waitTimer - 1
			if self.waitTimer <= 0 then
				self.playerInRange = false
				self.waiting = false
				self.hurtBoxOut = false
				self.attacking = false
				self.waiting = false
				self.chargeTimer = 10
				self.attackTimer = 100
				self.preAttackTimer = 30
				self.waitTimer = 25

			end
		end

	else
		self.hurtBoxOut = false
		self.attacking = false
		self.waiting = false
		self.chargeTimer = 10
		self.attackTimer = 100
		self.preAttackTimer = 30
		self.waitTimer = 25
	end

	local boxOffset = 28
	if self.direction == -1 then
		boxOffset = -40
	end

	if self.hurtBoxOut then
		self.hurtBox.x1 = self.x + boxOffset
		self.hurtBox.y1 = y + 10
		self.hurtBox.x2 = self.hurtBox.x1 + 40
		self.hurtBox.y2 = self.hurtBox.y1 + 10
	else
		self.hurtBox.x1 = 0
		self.hurtBox.y1 = 0
		self.hurtBox.x2 = 0
		self.hurtBox.y2 = 0
	end


	if not self.playerInRange then
		if player.x >= self.x then
			self.direction = 1
		else self.direction = -1
		end
	end
	if not self.playerInRange then
		self.animator:setAction("Walk")
		self.animator:setMode("loop")
		x = x + self.direction*70*dt
	end

	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y
end













walleye = walkingmonster:new{sprite_name = 'img/WallEye/Idle/01.png', health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "WallEye", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, projectiles = nil, projectile = nil, shootTimer = 70, hits = 4, color = {r = 255,g = 255, b = 0}, notShoot = false, shootLimit = 32*6}
function walleye:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.projectiles = {}
	self.projectile = {}
	self.projectile.x = 0
	self.projectile.y = 0
	self.projectile.vx = 0
	self.projectile.vy = 0
	self.projectile.speed = 100
	self.projectile.gravityIterator = 0
	self.projectile.bounds = nil
	self.projectile.destroyTimer = 0
	self.projectile.sprite_name = 'img/WallEye/projectile.png'
	self.projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
	return o
end

function walleye:load()

	self.collision = physics:get(self.collision,self.x+10,self.y,self.sprite,1,0)
	local rightCollision = self.collision
	local right = self.collision.right
	local closestRight = self.collision.borderRight

	if right then
		self.direction = -1
	else
		self.direction = 1
	end
end

function walleye:movement_function(Px,Py,dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	
	if self.shootTimer <= 70 and not self.notShoot then
		if self.shootTimer >=60 then
			self.animator:setAction("Open")
		elseif self.shootTimer >= 40 then
			self.animator:setAction("Attack")
		elseif self.shootTimer >= 10 then
			self.animator:setAction("Attack")
			--projectile = self.projectile
			local projectile = projthing:new()
			projectile.speed = 100
			projectile.gravityIterator = 0
			projectile.bounds = nil
			projectile.destroyTimer = 0
			projectile.sprite_name = 'img/WallEye/projectile.png'
			projectile.sprite = love.graphics.newImage(self.projectile.sprite_name)
			local offset = 1
			if self.direction == 1 then offset = 1 else offset = 0 end
			projectile.x = self.x --+ self.sprite:getWidth()*offset
			projectile.y = self.y + self.sprite:getHeight()/2-5
			projectile.vx, projectile.vy = 7*self.direction, 0
			--table.insert(self.projectiles,projectile)
			self.projectile = projectile
		else
			self.animator:setAction("Close")
			self.shootTimer = 70
			self.notShoot = false
			local i = math.random(0,2)
			if i == 2 then
				self.shootTimer = 100
				self.notShoot = true
				self.animator:setAction("Wait")
			end
		end
	end
	self.shootTimer = self.shootTimer - 1
	if self.notShoot and self.shootTimer <= 0 then
		self.notShoot = false
	end
	if self.notShoot then
	end
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 30
		end
	end
	return x,y
end

function walleye:moveProjectiles()
	--for _,proj in ipairs(self.projectiles) do
	local proj = self.projectile
	--print(table.getn(self.projectiles))
	proj.gravityIterator = proj.gravityIterator + 1
	proj.x = proj.x + proj.vx
	proj.y = proj.y + proj.vy
	--print(proj.vx)
	--proj.vy = proj.vy + 50*.005
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,1,0)
	local right = proj.bounds.right
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,-1,0)
	local left = proj.bounds.left
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,1)
	local up = proj.bounds.up
	proj.bounds = physics:get(proj.bounds,proj.x,proj.y,proj.sprite,0,-1)
	local down = proj.bounds.down
	local d = 1
	if proj.vx < 0 then
		d = -1
	end
	local reachedLimit = false
	if math.abs(self.x - proj.x) > self.shootLimit then
		reachedLimit = true
	end
	if left or right or down or up or reachedLimit then --and ar.bounds.collided.indicator ~= 'D' then
		if proj.destroyTimer <= 1 then
			proj.vx = 10*d
		else proj.vx = 0
		end
		proj.vy = 0
		proj.vx = 0
		proj.destroyTimer = proj.destroyTimer + 1
	end
	if proj.destroyTimer > 10 then
		--table.remove(self.projectiles,_)
		self.projectile = nil
	end
	--end
end










fallingenemy = walkingmonster:new{sprite_name = 'img/FallingEnemy/Idle/01.png', health = 1, collision = nil, sprite = nil, sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "FallingEnemy", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 30, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Idle", delay = .4, triggered = false, falling = false, triggeredTimer = 50, deathTimer = 70}
function fallingenemy:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end


function fallingenemy:movement_function(Px,Py,dt)
	local b_x = 0
	local b_y = 0
	local x = Px
	local y = Py
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	self.collision = physics:get(self.collision,x,y+1,self.sprite,0,-1)
	local grounded = self.collision.down
	if math.abs(player.x-x) < 32 and y < player.y and not self.falling then
		self.animator:setActionSpeed("Shake",6)
		self.animator:setAction("Shake")
		self.triggered = true
	end
	if self.triggered then
		self.triggeredTimer = self.triggeredTimer - 1 
		if self.triggeredTimer <= 0 then
			self.falling = true
			self.animator:setAction("Idle")
		end
	end
	if not grounded and self.falling then
		self.gravityIterator = self.gravityIterator + 1
		y = y + 35*.005*self.gravityIterator
	end
	if self.gotHit or self.bloodTimer<30 then
		--self.psystem:start()
		-- self.bloodTimer = self.bloodTimer - 1
		-- if self.bloodTimer <= 0 then
		-- 	--self.psystem:reset()
		-- 	--self.psystem:stop()
		-- 	self.bloodTimer = 30
		-- end
	end
	return x,y
end
function fallingenemy:DeathSFX()
	if self.deathTimer == 69 then
		local dust_obj = deathBlood:new()
		dust_obj.x = self.x-16
		dust_obj.y = self.y
		dust_obj.timer = 20
		dust_obj.animator = newCharacter("img", "BloodSplatter", "png", .3, "SwordSlash")
		table.insert(self.deathBloodTable,dust_obj)
	end
	for _,blood in ipairs(self.deathBloodTable) do
		blood.animator:setActionSpeed("SwordSlash", 3)
		blood.animator:setMode("once")
		blood.animator:draw(blood.x,blood.y,0,1,1)
	end
end










function containedInWindowCanvas(x,y)
	if x >= windowCanvas.x1 and x <= windowCanvas.x2 then
		if y >= windowCanvas.y1 and y <= windowCanvas.y2 then
			return true
		end
	end
	return false
end

function containedInWindowCanvas2(x,y)
	if x >= windowCanvas2.x1 and x <= windowCanvas2.x2 then
		if y >= windowCanvas2.y1 and y <= windowCanvas2.y2 then
			return true
		end
	end
	return false
end

function updateEnemies(dt)
	for num, ratt in ipairs(rats) do
		ratt:updateEnemy(dt)
		if ratt.hits <= 0 then
			--table.remove(rats,num)
			ratt.dead = true
			if ratt.deathAnimComplete then
				table.remove(rats,num)
			end
		end
	end
	for num,heart in ipairs(heartContainers) do
		heart:update()
	end
end

function drawEnemies(dt)
	for num, ratt in ipairs(rats) do
		ratt:drawEnemy(dt)
	end
	for num, heart in ipairs(heartContainers) do
		love.graphics.draw(heart.sprite,heart.x1,heart.y1,0,1,1)
	end
end


