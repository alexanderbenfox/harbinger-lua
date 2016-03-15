-- Character Physics Controller
require "acca"
position = {}
physics = {}
jumped = false
stopJump = false
direction = 1

characterState = {}
characterState.grounded = false
characterState.shooting = false
characterState.attacking = false
characterState.moving = false


function physics:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function physics:load(arg)

	player = {x = 200, y = 0, speed = 200, img = nil, rigidbody = nil, bools = characterState}
	player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')
	b = blockeddirection:new()


	local windowSize = {x = 0,y=0}
	windowSize.x, windowSize.y = love.window.getHeight(),love.window.getWidth()
	local meterToPixel = 64 --
	love.physics.setMeter(meterToPixel)

	world = love.physics.newWorld(0,(9.81*meterToPixel), true)

	objects = {}

	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, windowSize.x/2, windowSize.y/2)
	objects.ground.shape = love.physics.newRectangleShape(windowSize.x/2,100)
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)

	objects.player = {}
	objects.player.body = love.physics.newBody(world, windowSize.x/2, 0)
	objects.player.shape = love.physics.newRectangleShape(32,64)
	objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape,0)

	position.x, position.y = objects.player.body:getPosition()
	gravityIterator = 0

	MainCharacterAnim = newCharacter("img","MainCharacterAnimations","png",0.1,"Idle")

	attackingTimer = 0
	attackingFinished = 10




end

function physics:update(dt)
	player_move(dt)
	--world:update(dt)
	--objects.player.body:setPosition(player.x,player.y)
	--position.x, position.y = objects.player.body:getPosition()
	MainCharacterAnim:update(dt)
	MainCharacterAnim:setDirection("Forward")
end

function love.keypressed(key)
	if key == 'w' and characterState.grounded and stopJump == false and not cantJump then
		stopJump = true
	end
	if not characterState.attacking then
		shooter:keypressdown(key)
	end
	if key == 'l' and not characterState.shooting and not characterState.attacking then
		characterState.attacking = true
	end
end
function love.keyreleased(key)
	if key == 'w' and stopJump == true then
		stopJump = false
		jumped = false
		cantJumpAgain = false
		cantJump = false
		gravityIterator = 0
	end
	shooter:keypressup(key)
end

function get_collision_up()
	local t1y = b:getboundaries(b,player.x+2,player.y-1,0,1)
	local t2y = b:getboundaries(b,player.x+player.img:getWidth()-2, player.y-1,0,1)
	if t1y.up or t2y.up then
		print("gotceiling")
		stopJump = false
		jumped = false
		cantJumpAgain = false
		cantJump = false
		gravityIterator = 0
		return true
	end
end

function getGrounded(body_x, body_y)
	if b:getboundaries(b,body_x,body_y,0,-1).down then
		jumped = false
		return true
	else return false
	end

end
function getLeft(body_x, body_y)
	if b:getboundaries(b,body_x,body_y+1,-1,0).left or b:getboundaries(b,body_x,body_y-1+player.img:getHeight()/2,-1,0).left or b:getboundaries(b,body_x,body_y-1+player.img:getHeight(),-1,0).left then
		return true
	else return false
	end

end
function getRight(body_x, body_y)
	if b:getboundaries(b,body_x+player.img:getWidth(),body_y+1,1,0).right or b:getboundaries(b,body_x+player.img:getWidth(),body_y-1+player.img:getHeight()/2,1,0).right or b:getboundaries(b,body_x+player.img:getWidth(),body_y-1+player.img:getHeight(),1,0).right then
		return true
	else return false
	end

end

function getFlip()
	if direction == 1 then
		return player.x
	elseif direction == -1 then
		return player.x + player.img:getWidth()
	end
end


function player_move(deltaTime)
	getCeiling = get_collision_up()

	if getGrounded(player.x+2, player.y+player.img:getHeight()+.05) or getGrounded(player.x+player.img:getWidth()-2, player.y+player.img:getHeight()+.05) then
		characterState.grounded = true
	else characterState.grounded = false
	end
	local y = player.y
	local x = player.x
	local groundedThreshhold= nil
	local closestGround= nil
	speed = player.speed
	if not characterState.grounded then
		gravityIterator = gravityIterator + 1
		y = y + 50*.005*gravityIterator
	else gravityIterator = 0
	end



	if ((stopJump and characterState.grounded) or (stopJump and jumped)) and (not cantJumpAgain or not characterState.grounded) and not cantJump and not getCeiling then
		if not characterState.grounded then
			cantJumpAgain = true
		end
		if cantJumpAgain and characterState.grounded then
			cantJump = true
		end
		jumped = true
		y = y - speed*.005*7

	--	player.y = player.y - speed*deltaTime -- move up
	--elseif love.keyboard.isDown('s') and not b:getboundaries().down then
	--	player.y = player.y + speed*deltaTime -- move down
	end


	if characterState.shooting then
		MainCharacterAnim:setAction("Shooting2")
		MainCharacterAnim:play()
		MainCharacterAnim:setMode("once")
	else 
		-- MainCharacterAnim:resettwo()
	end

	if characterState.attacking then
		MainCharacterAnim:setAction("SwordAttack1")
		MainCharacterAnim:setMode("once")
		if attackingTimer <= attackingFinished then
			attackingTimer = attackingTimer + .3
		else
			characterState.attacking = false
			MainCharacterAnim:resetAction("SwordAttack1")
			attackingTimer = 0
		end
	end



	if love.keyboard.isDown('a') and not getLeft(player.x-1,player.y) and not (characterState.shooting and characterState.grounded) and not (characterState.attacking and characterState.grounded) then
		x = player.x - speed*deltaTime -- move up
		characterState.moving = true
		direction = -1
		if not characterState.shooting and not characterState.attacking then
			MainCharacterAnim:setAction("Walk")
			MainCharacterAnim:setMode("loop")
		end
	elseif love.keyboard.isDown('d') and not getRight(player.x+1,player.y) and not (characterState.shooting and characterState.grounded) and not (characterState.attacking and characterState.grounded) then
		x = player.x + speed*deltaTime -- move down
		direction = 1
		characterState.moving = true
		if not characterState.shooting and not characterState.attacking then 
			MainCharacterAnim:setAction("Walk")
			MainCharacterAnim:setMode("loop")
		end
	elseif not characterState.shooting and not characterState.attacking then
		MainCharacterAnim:setAction("Idle")
		MainCharacterAnim:setMode("loop")
		characterState.moving = false
	end

	direction_x = 0
	direction_y = 0
	if player.x > x then-- if you've moved left
		direction_x = -1
	end
	if player.x < x then-- if you've moved right
		direction_x = 1
	end
	if player.y < y then-- if you've moved down
		direction_y = -1
	end
	if player.y > y then-- if you've moved up
		direction_y = 1
	end
	local t1x = b:getboundaries(b,x,player.y+2,direction_x,0)
	local t2x = b:getboundaries(b,x+player.img:getWidth(), player.y+2,direction_x,0)
	local b1x = b:getboundaries(b,x,player.y+player.img:getHeight()-2,direction_x,0)
	local b2x = b:getboundaries(b,x+player.img:getWidth(),player.y+player.img:getHeight()-2,direction_x,0)
	local m1x = b:getboundaries(b,x,player.y+player.img:getHeight()/2,direction_x,0)
	local m2x = b:getboundaries(b,x+player.img:getWidth(),player.y+player.img:getHeight()/2,direction_x,0)
	local t1y = b:getboundaries(b,player.x+2,y,0,direction_y)
	local t2y = b:getboundaries(b,player.x+player.img:getWidth()-2, y,0,direction_y)
	local b1y = b:getboundaries(b,player.x+5,y+player.img:getHeight()+1,0,direction_y)
	local b2y = b:getboundaries(b,player.x+player.img:getWidth()-5,y+player.img:getHeight()+1,0,direction_y)
	if b1y.down or b2y.down then
		local closestGround = nil
		if b1y.down then
			print("b1down")
			closestGround = b1y.borderDown
		else
			print("b2down")
			closestGround = b2y.borderDown
		end
		y = closestGround - player.img:getHeight()
		characterState.grounded = true
	end

	if t1y.up or t2y.up then
		local closestGround = nil
		if t1y.up then
			print("t1up")
			closestGround = t1y.borderUp
		else
			print("t2up")
			closestGround = t2y.borderUp
		end
		--y = closestGround 
	end
	if b2x.right or t2x.right or m2x.right then
		local closestGround = nil
		if b2x.right then
			print("b2right")
			closestGround = b2x.borderRight
		elseif t2x.right then
			print("t2right")
			closestGround = t2x.borderRight
		else
			closestGround = m2x.borderRight

		end
		--x = closestGround - player.img:getWidth()
		x = player.x
	end
		if b1x.left or t1x.left or m1x.left then
		local closestGround = nil
		if b1x.left then
			print("b1left")
			closestGround = b1x.borderLeft
		elseif t1x.left then
			print("t1left")
			closestGround = t1x.borderLeft
		elseif m1x.left then
			print("m2left")
			closestGround = m1x.borderLeft
			print(b1x.borderRight)
		end
		-- x = closestGround
		x = player.x
	end



	player.y = y
	player.x = x
end

function get_collision_down()
	local p = objects.player.shape
	local ray1 = p:rayCast(player.x,player.y,player.x, player.y+10, 1,player.x, player.y, 0)
	return ray1
end

function physics:draw(dt)
	-- love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
	-- love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
	thing = getFlip()
	--love.graphics.draw(player.img,thing,player.y, 0,direction,1,0,0)
	if not characterState.shooting and not characterState.attacking then
		MainCharacterAnim:draw(thing,player.y,0,direction,1)
	elseif not characterState.attacking then
		MainCharacterAnim:draw(thing,player.y-5,0,direction,1)
	elseif characterState.attacking then
		MainCharacterAnim:draw(thing-10*direction,player.y-48,0, direction,1)
	end
end







