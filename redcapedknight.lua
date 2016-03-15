-- red caped knight
enemystate = love.filesystem.load("enemystate.lua")
--require 'enemystate'

redknight = enemystate:rat:new{health = 1, collision = nil, sprite = nil, sprite_name = 'img/NecromancerAnimations/Idle/01.png', sprite_offset = 0, x = 200, y = 650, velocity_x = 0, velocity_y= 0, gravityIterator = 0, animator = nil, folder_name = "RedCapedKnight", direction = 1, enemy = nil, waitTime = 0, waiting = false, hitTimer = 30, bloodTimer = 20, blood = love.graphics.newImage('assets/blood_particle.png'), idle_anim = "Walk", delay = .15, y_offset = -16, attacking = false, hurtBox = hurtBox:new(), left_margin = 3*32, right_margin = 6.5*32, top_margin = 5*32}

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
	self.gotHit, self.hitWorth = self:getHit(self.x,self.y)
	if self.gotHit and self.direction == direction then
		self.direction = self.direction*-1
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
		boxOffset = -32
	end
	if self.attacking then
		self.hurtBox.x1 = self.x + boxOffset
		self.hurtBox.y1 = self.y
		self.hurtBox.x2 = self.hurtBox.x1 + 64
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
		x = x + self.direction * 75 * dt
	elseif self.gotHit then
		x = x + -self.direction * 75 * dt
		y = y - 50 * dt
	end

	if self.gotHit or self.bloodTimer<20 then
		--self.psystem:start()
		self.bloodTimer = self.bloodTimer - 1
		if self.bloodTimer <= 0 then
			--self.psystem:reset()
			--self.psystem:stop()
			self.bloodTimer = 20
		end
	end

	return x, y
end