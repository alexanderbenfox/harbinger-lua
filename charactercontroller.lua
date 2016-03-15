--rewrite of physics.lua
--player character controller!

require "acca"
require "physics1"
require "buttonaction"
require "GhostingContainer"
position = {}
--physics = {}
jumped = false
stopJump = false
direction = 1

character_controller = {}

--grounded = false

buttonState = {left = false, right = false, jump = false, crouch = false, button1 = nil, button2 = nil}

windowSize = {x = 0,y=0, scale = 1}
windowSize.x, windowSize.y = love.window.getHeight(),love.window.getWidth()

blade_collider = {sprite = nil, x1 = 0, x2= 0, y1 = 0, y2 = 0}




vendorMenu = {}
vendorMenu.interacting = false
vendorMenu.animator = nil
vendorMenu.position = 0
vendorMenu.images = {}
vendorMenu.portrait = nil

coinDropper = {}
coinThing = {x = 0,y = 0,animator = nil,timer = 30}
function coinThing:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function updateCoinDropper(dt)
	for _,coin in ipairs(coinDropper) do
		coin.animator:update(dt)
		coin.timer = coin.timer - 1
		if coin.timer <= 0 then
			table.remove(coinDropper,_)
		end
	end
end
function drawCoinDropper()
	for _,coin in ipairs(coinDropper) do
		coin.animator:draw(coin.x,coin.y,0,1,1)
	end
end


quiver = {}
quiver.arrowMax = 2
quiver.arrows = 2
quiver.arrowQuiver = {}
quiver.fullRecharge = 60
quiver.arrowIcon = nil
quiver.rechargeMax = 80
quiver.rechargeTimer = 80


debugTools = {}
debugTools.deathCounter = 0
debugTools.timer = 0
debugTools.startTimer = 0



-- ditheringString = "// Ordered dithering aka Bayer matrix dithering

-- uniform sampler2D bgl_RenderedTexture;
-- float Scale = 1.0;

-- float find_closest(int x, int y, float c0)
-- {

-- int dither[8][8] = {
-- { 0, 32, 8, 40, 2, 34, 10, 42}, /* 8x8 Bayer ordered dithering */
-- {48, 16, 56, 24, 50, 18, 58, 26}, /* pattern. Each input pixel */
-- {12, 44, 4, 36, 14, 46, 6, 38}, /* is scaled to the 0..63 range */
-- {60, 28, 52, 20, 62, 30, 54, 22}, /* before looking in this table */
-- { 3, 35, 11, 43, 1, 33, 9, 41}, /* to determine the action. */
-- {51, 19, 59, 27, 49, 17, 57, 25},
-- {15, 47, 7, 39, 13, 45, 5, 37},
-- {63, 31, 55, 23, 61, 29, 53, 21} }; 

-- float limit = 0.0;
-- if(x < 8)
-- {
-- limit = (dither[x][y]+1)/64.0;
-- }


-- if(c0 < limit)
-- return 0.0;
-- return 1.0;
-- }

-- void main(void)
-- {
-- vec4 lum = vec4(0.299, 0.587, 0.114, 0);
-- float grayscale = dot(texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy), lum);
-- vec3 rgb = texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy).rgb;

-- vec2 xy = gl_FragCoord.xy * Scale;
-- int x = int(mod(xy.x, 8));
-- int y = int(mod(xy.y, 8));

-- vec3 finalRGB;
-- finalRGB.r = find_closest(x, y, rgb.r);
-- finalRGB.g = find_closest(x, y, rgb.g);
-- finalRGB.b = find_closest(x, y, rgb.b);

-- float final = find_closest(x, y, grayscale);
-- gl_FragColor = vec4(finalRGB, 1.0);
-- }
-- "







dashTrailTable = {}
dust = {timer = 10, animator = nil, x = 0, y = 0 }
function windowSize:scale(x)
  windowSize.x = windowSize.x * x
  windowSize.y = windowSize.y * x
  windowSize.scale = x
end

local prev_x = 0
local prev_y = 0

function character_controller:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end


function character_controller:load(arg, loadPlayer)
	--vendorMenu.animator = newCharacter()
	vendorMenu.images[0] = love.graphics.newImage("img/Menus/VendorMenu/02.png") 
	vendorMenu.images[1] = love.graphics.newImage("img/Menus/VendorMenu/03.png") 
	vendorMenu.images[2] = love.graphics.newImage("img/Menus/VendorMenu/04.png") 
	vendorMenu.portrait = love.graphics.newImage("assets/doommask.png")

	shader = love.graphics.newShader[[
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
vec4 pixel = Texel(texture,texture_coords);
//vec4 red = (1.0,0.0,0.0,1.0);
pixel.r = 1.0;
pixel.g = 0;
pixel.b = 0;
pixel.a = 0.5*pixel.a;
  return pixel;
}]]

-- 	shader = love.graphics.newShader[[// Ordered dithering aka Bayer matrix dithering

-- uniform sampler2D bgl_RenderedTexture;
-- float Scale = 1.0;

-- float find_closest(int x, int y, float c0)
-- {

-- int dither[8][8] = {
-- { 0, 32, 8, 40, 2, 34, 10, 42}, /* 8x8 Bayer ordered dithering */
-- {48, 16, 56, 24, 50, 18, 58, 26}, /* pattern. Each input pixel */
-- {12, 44, 4, 36, 14, 46, 6, 38}, /* is scaled to the 0..63 range */
-- {60, 28, 52, 20, 62, 30, 54, 22}, /* before looking in this table */
-- { 3, 35, 11, 43, 1, 33, 9, 41}, /* to determine the action. */
-- {51, 19, 59, 27, 49, 17, 57, 25},
-- {15, 47, 7, 39, 13, 45, 5, 37},
-- {63, 31, 55, 23, 61, 29, 53, 21} }; 

-- float limit = 0.0;
-- if(x < 8)
-- {
-- limit = (dither[x][y]+1)/64.0;
-- }


-- if(c0 < limit)
-- return 0.0;
-- return 1.0;
-- }

-- void main(void)
-- {
-- vec4 lum = vec4(0.299, 0.587, 0.114, 0);
-- float grayscale = dot(texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy), lum);
-- vec3 rgb = texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy).rgb;

-- vec2 xy = gl_FragCoord.xy * Scale;
-- int x = int(mod(xy.x, 8));
-- int y = int(mod(xy.y, 8));

-- vec3 finalRGB;
-- finalRGB.r = find_closest(x, y, rgb.r);
-- finalRGB.g = find_closest(x, y, rgb.g);
-- finalRGB.b = find_closest(x, y, rgb.b);

-- float final = find_closest(x, y, grayscale);
-- gl_FragColor = vec4(finalRGB, 1.0);
-- }
-- ]]
	quiver.arrowIcon = love.graphics.newImage('assets/arrowicon.png')
	quiver.axeIcon = love.graphics.newImage("img/MainCharacterAnimations/AxeThrow/axe.png")
	quiver.bombIcon = love.graphics.newImage("itemimg/Bomb/bomb.png")
	quiver.Icon = quiver.axeIcon


	for x = 1,quiver.arrowMax do
		local arrowItem = {}
		arrowItem.usable = true
		table.insert(quiver.arrowQuiver,arrowItem)
	end



	grounded = false

	if loadPlayer then
		player = {x = 160, y = 110, render_x = 0, render_y = 0, speed = 0, maxSpeed = 120, accelerationFactor = 60, img = nil, rigidbody = nil, state = nil, health = 10, healthMax = 10, hurt = false, hurtTimer = 50, normalAttacking = false, secondSlashTimer = 20, secondSlashing = false, attackSpeed = -1.6, attackAnimSpeed = 1.3, rolling = false, rollTimer = 30, pressingRight = false, pressingLeft = false, pressTimer = 20, getupTimer = 25, getupGroundTriggered = false, bufferAttack =false, bufferedKey = nil, canCharge = true, isChargingAttack = false, chargeMultiplier = 0, charging = false, chargeStrike = false, chargeFillValue = 0, chargeFillMax = 0, chargeFill = nil, offGroundDodge = false, maxFallSpeed = false, coins = 0, nearVendor = false, ammo = 10, ammoMax = 10, dead = false, respawnTimer = 100, respawnPoint = {x = 0,y = 0}, respawnPointTriggered = false, currentSpawnPoint = nil, respawnRoom = nil, nearFire = false}
	end

	player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')
	blade_collider.sprite = love.graphics.newImage('img/MainCharacterAnimations/sword_collider.png')
	mainCharPortrait = love.graphics.newImage('img/MainCharacterAnimations/maincharportrait.png')
	collisions = physics:new()
	button = buttonState:new()
	button.button1 = button_action:new()
	button.button1 = button_action:load("k",dagger_throw,"AxeThrow",shooting)


	local meterToPixel = 64 --

	gravityIterator = 0

	MainCharacterAnim = newCharacter("img","MainCharacterAnimations","png",0.1,"Idle")


	playerGhostContainer = GhostingContainer:new()
	playerGhostContainer:init(3,.1,MainCharacterAnim,.1,player) -- trail length, spawn rate(lower = faster), animator, effect duration, reference

	attackingTimer = 0
	attackingFinished = 7

	characterState = {buttons = button, collision = collisions, attacking = false, crouchAttack = false, jumping = false, moving = false, hasRing = true, canCrouchAttackWhileMoving = true, wallHanging = false, initiatedPullUp = false, pullUp_y = 0, savedLedgePoint = 0, falling = false, cantKnockBack = false, onOneWayPlatform = false, crouchedThiseFrame = false}
	player.state = characterState

	ledgePoint = 0


	keyIndicator = newCharacter("img","KeyIndicators","png",0.1,"L")

end

function dust:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function getDoorPosition()
	for _, door in ipairs(doorPositions) do
		if door.x >= player.x and door.x <= player.x+player.img:getWidth() then
			--if (door.y >= player.y and door.y <= player.y + player.img:getHeight()) or  then
			if player.y+32 >= (door.y-door.height) and player.y+32 <= (door.y) then
				return true, door
			end
		end
	end
	return false
end

function character_controller:update(dt)
	player_move(dt)
	--world:update(dt)
	--objects.player.body:setPosition(player.x,player.y)
	--position.x, position.y = objects.player.body:getPosition()
	MainCharacterAnim:update(dt)
	MainCharacterAnim:setDirection("Forward")
end

function buttonState:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end


function love.keypressed(key)
	-- if characterState.hasRing then
	-- 	ring.obtained = false
	-- end
	if ingame then
		KeyPress(key)
	else
		KeyPressGameStart(key)
	end

end

function KeyPress(key)
	characterState.collision = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1)
	grounded = characterState.collision.down
	local onewayCheck = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1, "player")
	if onewayCheck.down then
		grounded = true
	end
	if key == 'w' and grounded or characterState.onOneWayPlatform then
		stopJump = true
	end

	onewayCheck = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1, "onlyoneway")

	if onewayCheck.down and key=='j' and button.crouch then
		player.y = player.y + 5
	end


	-- if canPlunge and key == 'l' and not characterState.attacking then
	-- 	plunging = true
	-- 	canPlunge = false
	-- end
	if not characterState.crouchedThiseFrame and not player.rolling and player.getupTimer == 25 and not player.charging and not player.isChargingAttack and not characterState.wallHanging and not characterState.initiatedPullUp then
		if not characterState.attacking and not player.hurt and quiver.arrows > 0 and not button.crouch and player.ammo > 0 then
			button.button1.class:keypressdown(key)
		end
		if not player.nearVendor and not player.nearFire then
			if key == 'l' and not button.button1.boolean and not characterState.attacking and not button.crouch and (not player.hurt or characterState.cantKnockBack) and not plunging and not canPlunge and not characterState.canCrouchAttackWhileMoving then
				characterState.attacking = true
			elseif key =='l' and not button.button1.boolean and not characterState.isAttacking and not characterState.crouchAttack and (button.crouch or characterState.canCrouchAttackWhileMoving) and (not player.hurt or characterState.cantKnockBack) and not plunging and not canPlunge then
				characterState.crouchAttack = true
			end
		end

		if key == 'j' and grounded and not characterState.attacking and not button.crouch then
			player.rolling = true
			player.pressingRight = false
			player.pressingLeft = false
			player.pressTimer = 20
		end
	end
	if characterState.wallHanging and key == 'w' then
		characterState.collision = physics:get(characterState.collision,player.x+(4*direction),ledgePoint - player.img:getHeight(),player.img,direction,0)
		local right = characterState.collision.right
		local left = characterState.collision.left
		if not right or not left then
			characterState.initiatedPullUp = true
			characterState.pullUp_y = (ledgePoint - player.img:getHeight())+(player.img:getHeight()/3)
			characterState.savedLedgePoint = ledgePoint
		end
	end

	-- if (key == 'd' and player.pressingRight) or (key == 'a' and player.pressingLeft) then
	-- 	player.rolling = true
	-- 	print("YOOYO")
	-- 	player.pressingRight = false
	-- 	player.pressingLeft = false
	-- 	player.pressTimer = 20
	-- end



	-- if key == 's' and not button.button1.boolean and not characterState.attacking then
	-- 	player.img = love.graphics.newImage('img/MainCharacterAnimations/Crouch/01.png')
	-- 	player.y = player.y + (64-36)
	-- 	button.crouch = true
	-- end

	if player.nearVendor and not vendorMenu.interacting then
		if key == 'l' then
			vendorMenu.interacting = true
		end
	end

	if vendorMenu.interacting then
		if key == 'a' and vendorMenu.position>0 then
			vendorMenu.position = vendorMenu.position - 1
		end
		if key == 'd' and vendorMenu.position<2 then
			vendorMenu.position = vendorMenu.position + 1
		end
		if vendorMenu.position == 2 and key == 'l' then
			vendorMenu.interacting = false
			vendorMenu.position = 0
		end
	end

	if player.nearFire and key == 'l' then
		player.respawnPoint.x = player.x
		player.respawnPoint.y = player.y
		player.respawnPointTriggered = true
		player.currentSpawnPoint.on = true
		player.respawnRoom = player.currentSpawnPoint.room
		tableSave("/Users/alex/Documents/Game/gamesaves/gamesave1.lua")
	end

end
function love.keyreleased(key)
	if ingame then
		KeyRelease(key)
	else
	end
end

function KeyRelease(key)
	if key == 'w' and stopJump == true then
		stopJump = false
		jumped = false
		cantJumpAgain = false
		cantJump = false
		gravityIterator = 0
	end
	if (not player.hurt or characterState.cantKnockBack) then
		button.button1.class:keypressup(key)
	end
	if key == 's' then
		plunging = false
		canPlunge = false
	end

	if key == 'l' and player.isChargingAttack then
		player.charging = true
		player.isChargingAttack = false
		player.canCharge = true
	end

	if key == 'k' and button.crouch then
		for k in pairs(arrowsOnScreen) do
			arrowsOnScreen[k] = nil
		end
		if button.button1.class == bomb_throw then
			button.button1 = button_action:load("k",axe_throw,"AxeThrow",shooting)
			quiver.Icon = quiver.axeIcon
		else 
			-- button.button1 = button_action:load("k",shooter,"Shooting2",shooting)
			-- quiver.Icon = quiver.arrowIcon
			button.button1 = button_action:load("k",bomb_throw,"AxeThrow",shooting)
			quiver.Icon = quiver.bombIcon
		end
	end


	-- if key == 'd' and not player.pressingRight then
	-- 	player.pressingRight = true
	-- end
	-- if key == 'a' and not player.pressingLeft then
	-- 	player.pressingLeft = true
	-- end
	-- if key == 's' then
	-- 	button.crouch = false
	-- 	player.y = player.y - (64-36)
	-- 	player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')
	-- end
end


function getFlip()
	if direction == 1 then
		return player.x
	elseif direction == -1 then
		return player.x + player.img:getWidth()
	end
end

function resetAttackStuff()
	player.canCharge = true
	player.isChargingAttack = false
	player.charging = false
	player.chargeStrike = false
	player.chargeMultiplier = 0
	characterState.attacking = false
	player.chargeStrike = false
	attackingTimer = 0
	player.canCharge = true
	player.chargeMultiplier = 0
	player.normalAttacking = false
end

function checkForWallHang(x,y)
	local checkTop, checkBottom = false,false
	local blockTop1,blockTop2 = 0,0

	checkTop, blockTop1 = getWallHang(x,y+1)
	checkBottom, blockTop2 = getWallHang(x,y+9)

	checkFeet = getWallHang(x-direction*16, y+player.img:getHeight()+16)

	if not checkTop and checkBottom and not checkFeet then
		return true, blockTop2
	else
		return false
	end
end


function player_move(deltaTime)
	--print(deltaTime)

	if getNearVendor() then
		player.nearVendor = true
	else player.nearVendor = false
	end

	if getNearFire() then
		player.nearFire = true
	else player.nearFire = false
	end

	keyIndicator:update(deltaTime)
	keyIndicator:setMode("bounce")



	local healValue = 0
	local ttype = nil
	local gotCoin,healLocation_x,healLocation_y,ttype  = getCoinItem()
	--(player.health < player.healthMax)
	if ttype ~= nil then
		if gotCoin and ttype == "coin" then
			--player.health = player. health + 1
			player.coins = player.coins + 1
			local coin = coinThing:new()
			coin.x = healLocation_x-32
			coin.y = healLocation_y-32
			coin.animator = newCharacter("img","Items","png",0.1,"CoinDrop")
			table.insert(coinDropper,coin)
		elseif gotCoin and ttype == "ammo" then
			if player.ammo < player.ammoMax then
				player.ammo = player.ammo + 1
			end
			local coin = coinThing:new()
			coin.x = healLocation_x-32
			coin.y = healLocation_y-32
			coin.animator = newCharacter("img","Items","png",0.1,"CoinDrop")
			table.insert(coinDropper,coin)

		else 
			player.health = player. health + 3
			if player.health >= player.healthMax then
				player.health = player.healthMax
			end
			local coin = coinThing:new()
			coin.x = healLocation_x-32
			coin.y = healLocation_y-32
			coin.animator = newCharacter("img","Items","png",0.1,"CoinDrop")
			table.insert(coinDropper,coin)
		end
	end
	updateCoinDropper(deltaTime)



	local wallHangingLastFrame = characterState.wallHanging
	local wall_x,offset_wall = 1,3
	if direction == -1 then
		wall_x,offset_wall = 0,-3
	end
	characterState.wallHanging, ledgePoint = checkForWallHang(player.x+(player.img:getWidth()*wall_x)+offset_wall, player.y)
	if not (characterState.wallHanging and fallingLastFrame) or button.crouch or characterState.attacking then characterState.wallHanging = false end

	if wallHangingLastFrame and not characterState.wallHanging then
		MainCharacterAnim:resetAction("OnLedge")
	end



	debugTools.timer = love.timer.getTime() - debugTools.startTimer

	playerGhostContainer:update()
	if player.bufferAttack and player.getupTimer == 25 then
		KeyPress(player.bufferedKey)
		if not love.keyboard.isDown(player.bufferedKey) then
			KeyRelease(player.bufferedKey)
		end
		player.bufferAttack = false
	end

	--print(player.pressTimer)
	if player.pressingRight or player.pressingLeft then
		player.pressTimer = player.pressTimer - 1
	end

	if player.pressTimer <= 0 then
		player.pressingLeft = false
		player.pressingRight = false
		player.pressTimer = 20
	end

	if player.hurt or player.rolling or characterState.wallHanging or characterState.initiatedPullUp then
		activeTracking = false
	else
		activeTracking = true
	end
	--characterState.jumping = jumped

	characterState.canCrouchAttackWhileMoving = (love.keyboard.isDown('s') and (love.keyboard.isDown('a') or love.keyboard.isDown('d')))
	-- if characterState.canCrouchAttackWhileMoving and not crouchAtthen
	-- 	button.crouch = false
	-- end
	characterState.collision = physics:get(characterState.collision,player.x,player.y,player.img,0,1)
	up = characterState.collision.up
	characterState.collision = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1, "player")
	local C = characterState.collision.down
	if love.keyboard.isDown('s') and not characterState.jumping and not button.button1.boolean and (not characterState.moving or characterState.crouchAttack) and not characterState.attacking and (not player.hurt or characterState.cantKnockBack) then
		MainCharacterAnim:setAction("Crouch")
		MainCharacterAnim:setMode("loop")
		if not button.crouch then 
			player.y = player.y + (64-36)
			resetAttackStuff()
			characterState.crouchedThiseFrame = true
		else
			characterState.crouchedThiseFrame = false
		end
		button.crouch = true
		player.img = love.graphics.newImage('img/MainCharacterAnimations/Crouch/01.png')
	elseif not (characterState.crouchAttack or player.hurt) and not up then
		if button.crouch and C then
			player.y = player.y - (64-36)
			resetAttackStuff()
		end
		button.crouch = false
		player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')
	end


	local y = player.y
	local x = player.x

	local speed = player.speed

	local prev_grav = gravityIterator


	characterState.collision = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1)
	local onewayCheck = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1, "player")

	if characterState.wallHanging then
		gravityIterator = 0
		grounded = true
	end

	if not grounded then
		gravityIterator = gravityIterator + 1
		if 35*.009*gravityIterator <= 8 then
			y = y + 35*.008*gravityIterator
			player.maxFallSpeed = false
		else
			player.maxFallSpeed = true 
			y = y + 8 
		end
	else 
		maxFallSpeed = false
		--MainCharacterAnim:resetAction("Plunge")
		--plunging = false
		if not stopJump then
			gravityIterator = 0
		end
	end

	if characterState.collision.down or onewayCheck.down then
		characterState.jumping = false
	elseif not onDiagonalSlope then
		onewayCheck = false
		characterState.jumping = true
	end



	--characterState.collision = physics:get(characterState.collision,x,y+1,player.img,0,-1)
	--grounded = characterState.collision.down




	if stopJump then
		jumped = true
		--y = y - speed*.005*4.75
		y = y - 200*.0065*5
	end

		



	player.secondSlashTimer = player.secondSlashTimer - 1

	-- local jumpTime1 = MainCharacterAnim:getFrameAction("SwordAttack1")
	-- local standTime1 = MainCharacterAnim:getFrameAction("SwordAttack1Jump")
	-- local jumpTime2 = MainCharacterAnim:getFrameAction("SwordAttack2")
	-- local standTime2 = MainCharacterAnim:getFrameAction("SwordAttack2Jump")
	-- local jumpTime1timer = MainCharacterAnim:getTimerAction("SwordAttack1")
	-- local standTime1timer = MainCharacterAnim:getTimerAction("SwordAttack1Jump")
	-- local jumpTime2timer = MainCharacterAnim:getTimerAction("SwordAttack2")
	-- local standTime2timer = MainCharacterAnim:getTimerAction("SwordAttack2Jump")

	-- local frame1 = 0
	-- local frame2 = 0
	-- local timer1 = 0
	-- local timer2 = 0

	-- if jumpTime1timer >= standTime1timer then
	-- 	timer1 = jumpTime1timer
	-- else
	-- 	timer1 = standTime1timer
	-- end


	-- if jumpTime2timer >= standTime2timer then
	-- 	timer2 = jumpTime2timer
	-- else
	-- 	timer2 = standTime2timer
	-- end

	-- if jumpTime1 >= standTime1 then
	-- 	frame1 = jumpTime1
	-- else
	-- 	frame1 = standTime1
	-- end


	-- if jumpTime2 >= standTime2 then
	-- 	frame2 = jumpTime2
	-- else
	-- 	frame2 = standTime2
	-- end

	-- print(timer1)
	-- print(timer2)


	-- MainCharacterAnim:seekAction("SwordAttack1", frame1)
	-- MainCharacterAnim:seekAction("SwordAttack1Jump", frame1)
	-- MainCharacterAnim:seekAction("SwordAttack2", frame2)
	-- MainCharacterAnim:seekAction("SwordAttack2Jump", frame2)

	-- MainCharacterAnim:timerAction("SwordAttack1", timer1)
	-- MainCharacterAnim:timerAction("SwordAttack1Jump", timer1)
	-- MainCharacterAnim:timerAction("SwordAttack2", timer2)
	-- MainCharacterAnim:timerAction("SwordAttack2Jump", timer2)

	if characterState.attacking and not button.crouch and (not player.hurt or characterState.cantKnockBack) then --and (not love.keyboard.isDown('s') or player.normalAttacking) then
		if player.secondSlashTimer < 0 and not player.secondSlashing and not player.chargeStrike then
			if not characterState.jumping then
				MainCharacterAnim:setActionSpeed("SwordAttack1",player.attackAnimSpeed)
				MainCharacterAnim:setAction("SwordAttack1")
				MainCharacterAnim:updateAction("SwordAttack1Jump", deltaTime)
			else
				MainCharacterAnim:setActionSpeed("SwordAttack1Jump",player.attackAnimSpeed)
				MainCharacterAnim:setAction("SwordAttack1Jump")
				MainCharacterAnim:updateAction("SwordAttack1", deltaTime)
			end

			MainCharacterAnim:setMode("once")
			attackingFinished = 8 - player.attackSpeed
		elseif not player.chargeStrike then
			if not characterState.jumping then
				MainCharacterAnim:setActionSpeed("SwordAttack2",player.attackAnimSpeed)
				MainCharacterAnim:setAction("SwordAttack2")
				MainCharacterAnim:updateAction("SwordAttack2Jump", deltaTime)
			else
				MainCharacterAnim:setActionSpeed("SwordAttack2Jump",player.attackAnimSpeed)
				MainCharacterAnim:setAction("SwordAttack2Jump")
				MainCharacterAnim:updateAction("SwordAttack2", deltaTime)
			end
			MainCharacterAnim:setMode("once")
			player.secondSlashing = true
			attackingFinished = 8 - player.attackSpeed
		else
			MainCharacterAnim:setActionSpeed("SwordChargeStrike",player.attackAnimSpeed)
			MainCharacterAnim:setAction("SwordChargeStrike")
			MainCharacterAnim:setMode("once")
			attackingFinished = 12
		end

		player.normalAttacking = true

		if love.keyboard.isDown('l') and player.canCharge and not player.chargeStrike then
			if attackingTimer >= 4 then
				--player.isChargingAttack = true
			end
			--MainCharacterAnim:setAction("SwordCharge")
		else
			player.canCharge = false
		end

		if attackingTimer >= 3 and attackingTimer <= 6 then
			local first = 0
			local second = 56
			if player.secondSlashing then
				first = 10
				second = 66
			end
			if player.chargeStrike then
				second = 74
				first = 16
			end
			if direction == 1 then
				blade_collider.x1 = player.x + 16
				blade_collider.x2 = blade_collider.x1 + second
			else 
				blade_collider.x1 = player.x-second+16
				blade_collider.x2 = player.x+16
			end
			blade_collider.y1 = player.y+4
			blade_collider.y2  = blade_collider.y1 + 32 - 16
			if player.chargeStrike then
				blade_collider.y1 = player.y - 16
				blade_collider.y2 = blade_collider.y1 + 64+ 16
			end
		else
			blade_collider.x1, blade_collider.x2, blade_collider.y1, blade_collider.y2 = 0,0,0,0
		end
		if attackingTimer <= attackingFinished then
			attackingTimer = attackingTimer + .3
		else
			if not player.secondSlashing then
				player.secondSlashTimer = 20
			end
				MainCharacterAnim:resetAction("SwordAttack1")
				MainCharacterAnim:resetAction("SwordAttack1Jump")
				MainCharacterAnim:resetAction("SwordChargeStrike")
			--else
				MainCharacterAnim:resetAction("SwordAttack2")
				MainCharacterAnim:resetAction("SwordAttack2Jump")
				player.secondSlashing = false
			--end
			resetAttackStuff()
		end
	elseif characterState.crouchAttack and (not player.hurt or characterState.cantKnockBack) then
		MainCharacterAnim:setActionSpeed("CrouchSwordAttack",1.25)
		--button.crouch = true
		MainCharacterAnim:setAction("CrouchSwordAttack")
		MainCharacterAnim:setMode("once")
		if attackingTimer >= 1 and attackingTimer <= 3 then
			local first = 0
			local second = 46
			if direction == 1 then
				blade_collider.x1 = player.x + 32
				blade_collider.x2 = blade_collider.x1 + second
			else 
				blade_collider.x1 = player.x-second
				blade_collider.x2 = player.x
			end
			blade_collider.y1 = player.y+15
			blade_collider.y2  = blade_collider.y1 + 10
		else
			blade_collider.x1, blade_collider.x2, blade_collider.y1, blade_collider.y2 = 0,0,0,0
		end
		if attackingTimer <= (6-player.attackSpeed) then
			attackingTimer = attackingTimer + .3
		else
			characterState.crouchAttack = false
			MainCharacterAnim:resetAction("CrouchSwordAttack")
			attackingTimer = 0
		end
	elseif characterState.jumping and plunging and not characterState.crouchAttack and (not player.hurt or characterState.cantKnockBack) then
		MainCharacterAnim:setActionSpeed("Plunge",2)
		--button.crouch = true
		MainCharacterAnim:setAction("Plunge")
		MainCharacterAnim:setMode("once")
		if attackingTimer >= 2 and attackingTimer <= 10 then
			local first = 0
			local second = 28
			if direction == 1 then
				blade_collider.x1 = player.x
				blade_collider.x2 = blade_collider.x1 + second+8
			else 
				blade_collider.x1 = player.x-8
				blade_collider.x2 = player.x+32
			end
			blade_collider.y1 = player.y+player.img:getHeight()-20
			blade_collider.y2  = blade_collider.y1 + 20+second
		else
			blade_collider.x1, blade_collider.x2, blade_collider.y1, blade_collider.y2 = 0,0,0,0
		end
		if attackingTimer <= 4.5 then
			attackingTimer = attackingTimer + .3
		else
			--characterState.crouchAttack = false
			MainCharacterAnim:resetAction("Plunge")
			plunging = false
			attackingTimer = 0
			plunging = false
		end
	else 
		blade_collider.x1, blade_collider.x2, blade_collider.y1, blade_collider.y2 = 0,0,0,0
		attackingTimer = 0
		--MainCharacterAnim:resetAction("Plunge")
	end





	if love.keyboard.isDown('a') and not (button.button1.boolean and characterState.collision.down) and not (characterState.attacking and characterState.collision.down) and not characterState.crouchAttack and not player.rolling then
		if player.speed >= -player.maxSpeed then
			player.speed = player.speed - player.accelerationFactor
		else player.speed = -player.maxSpeed
		end
		x = player.x + speed*deltaTime -- move up
		characterState.moving = true
		if not characterState.attacking and not button.button1.boolean then
			direction = -1
		end
		if not button.button1.boolean and not characterState.attacking and not characterState.jumping then
			--MainCharacterAnim:resetAction("Jump")
			--MainCharacterAnim:setMode("loop")
			MainCharacterAnim:setAction("Walk")
			MainCharacterAnim:setMode("loop")
		end
	elseif love.keyboard.isDown('d') and not (button.button1.boolean and characterState.collision.down) and not (characterState.attacking and characterState.collision.down) and not characterState.crouchAttack and not player.rolling then
		if player.speed <= player.maxSpeed then
			player.speed = player.speed + player.accelerationFactor
		else player.speed = player.maxSpeed
		end
		x = player.x + speed*deltaTime -- move down
		if not characterState.attacking and not button.button1.boolean then
			direction = 1
		end
		characterState.moving = true
		if not button.button1.boolean and not characterState.attacking and not characterState.jumping then 
			--MainCharacterAnim:resetAction("Jump")
			--MainCharacterAnim:setMode("loop")
			MainCharacterAnim:setAction("Walk")
			MainCharacterAnim:setMode("loop")
		end
	elseif not button.button1.boolean and not characterState.attacking and not characterState.jumping and button.crouch and not characterState.crouchAttack then
		MainCharacterAnim:setAction("Crouch")
		MainCharacterAnim:setMode("loop")
		characterState.moving = false
	elseif not button.button1.boolean and not characterState.attacking and not characterState.jumping and not characterState.crouchAttack and not button.crouch and not player.rolling then
		MainCharacterAnim:setAction("Idle")
		MainCharacterAnim:setMode("loop")
		characterState.moving = false

	end

	if not (love.keyboard.isDown('d') or love.keyboard.isDown('a')) then
		if player.speed ~= 0 then
			local slowdownFactor = 0
			if player.speed > 0 then
				slowdownFactor = -1
			else slowdownFactor = 1
			end
			player.speed = player.speed + slowdownFactor*player.accelerationFactor
			x = player.x + speed*deltaTime
			-- if not characterState.attacking and not player.crouch then
			-- 	MainCharacterAnim:setAction("Walk")
			-- 	MainCharacterAnim:setMode("loop")
			-- end
			-- if love.keyboard.isDown('s') then
			-- 	MainCharacterAnim:setAction("Crouch")
			-- 	MainCharacterAnim:setMode("loop")
			-- end

		end
	end

	if characterState.moving and love.keyboard.isDown("s") and grounded and characterState.attacking then
		characterState.moving = false
	end

	if characterState.jumping and not characterState.attacking and not button.button1.boolean and not characterState.falling then
		--MainCharacterAnim:setActionSpeed("Jump",.8)
		MainCharacterAnim:setMode("once")
		if math.abs(player.speed) > 70 then
			MainCharacterAnim:setAction("Jump2")
		else
			MainCharacterAnim:setAction("Jump1")
		end
	end

	if plunging then
		MainCharacterAnim:setAction("Plunge")
		MainCharacterAnim:setMode("once")
	end

	if player.isChargingAttack then
		player.chargeFill = true
		player.chargeFillValue = player.chargeMultiplier
		player.chargeFillMax = 15
		player.speed = 50
		if not player.secondSlashing then
			player.secondSlashTimer = 20
			MainCharacterAnim:resetAction("SwordAttack1")
		else
			MainCharacterAnim:resetAction("SwordAttack2")
			player.secondSlashing = false
		end
		characterState.attacking = false
		attackingTimer = 0

		if player.chargeMultiplier <= 15 then
			player.chargeMultiplier = player.chargeMultiplier + .5
		end

		MainCharacterAnim:setAction("SwordCharge")
		MainCharacterAnim:setMode("loop")
	else 
		--player.speed = 130
		if not button.button1.boolean then
			player.chargeFill = false
		end
	end

	if player.charging then
		if player.chargeMultiplier >= 0 then
			playerGhostContainer:StartEffect()
			x = player.x + direction*125*5*deltaTime
			MainCharacterAnim:setAction("SwordChargeMove")
			MainCharacterAnim:setMode("loop")
			player.chargeMultiplier = player.chargeMultiplier-1
		else 
			MainCharacterAnim:setAction("SwordChargeMove")
			playerGhostContainer:StopEffect()
			player.charging = false
			player.chargeStrike = true
			characterState.attacking = true
		end
	end



	if player.rolling then
		if player.rollTimer > 13 then
			if love.keyboard.isDown('a') then
				direction = -1
			end
			if love.keyboard.isDown('d') then
				direction = 1
			end
		end
		playerGhostContainer:StartEffect()
		--player.img = love.graphics.newImage('img/MainCharacterAnimations/jumpcollider.png')
		if player.rollTimer > 15 then
			--MainCharacterAnim:setActionSpeed("Dodge", 1.75)
		else
			--MainCharacterAnim:setActionSpeed("Dodge", 3.5)
		end
		x = player.x + direction*2.5*125*deltaTime
		--y = y - 200*.005*2
		characterState.collision = physics:get(characterState.collision,x,y,player.img,0,-1)
		--grounded = characterState.collision.down
		local closestDown = characterState.collision.borderDown
		if grounded then
			if (player.rollTimer)%3 == 0 then
				local dust_obj = dust:new()
				dust_obj.x = player.x + 16
				dust_obj.y = player.y+28
				dust_obj.animator = newCharacter("img", "DustCloud", "png", .3, "Dust")
				table.insert(dashTrailTable,dust_obj)
			end
		end
		if grounded then
			player.offGroundDodge = false
			MainCharacterAnim:setAction("SwordChargeMove")
			MainCharacterAnim:setMode("once")
		else
			--player.offGroundDodge = true
		end
		if characterState.jumping then
			player.offGroundDodge = true
		end
		for _,dust in ipairs(dashTrailTable) do
			dust.animator:update(deltaTime)
			dust.timer = dust.timer - 1
			if dust.timer < 0 then
				table.remove(dashTrailTable,_)
			end
		end
		player.rollTimer = player.rollTimer - 1
		if player.rollTimer <= 0 then
			--MainCharacterAnim:resetAction("Dodge")
			for _,dust in ipairs(dashTrailTable) do
				table.remove(dashTrailTable,_)
			end

			player.rollTimer = 15
			player.rolling = false
			MainCharacterAnim:setAction("Idle")
			player.offGroundDodge = false
			--player.getupTimer = player.getupTimer - 1
			--stopJump = false
			--jumped = false
			--cantJumpAgain = false
			--cantJump = false
			--gravityIterator = 0
			--y = player.y - 32
		end
	elseif not player.charging then
		playerGhostContainer:StopEffect()
	end

	if player.getupTimer < 25 then
		player.getupTimer = player.getupTimer - 1
		MainCharacterAnim:resetAction("Dodge")
		player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')
		if player.getupGroundTriggered == false and grounded then
			player.getupGroundTriggered = true
			grounded = characterState.collision.down
			local closestDown = characterState.collision.borderDown
			if grounded then
				y = closestDown - player.img:getHeight()
			end

		end
		player.speed = 50
		characterState.moving = true
		MainCharacterAnim:setActionSpeed("GetUp", .55)
		MainCharacterAnim:setAction("GetUp")
		MainCharacterAnim:setMode("loop")

		if grounded then
			x = player.x
		elseif love.keyboard.isDown('a') or love.keyboard.isDown('d') then
			x = player.x + direction*speed*deltaTime
		else
			x = player.x
		end
		--y = player.y
		if player.getupTimer <= 0 then

			player.speed = 130
			player.getupTimer = 25
			MainCharacterAnim:resetAction("GetUp")
			player.getupGroundTriggered = false
			characterState.moving = false
		end
	end

	if player.getupTimer < 25 then
		if love.keyboard.isDown('k') then
			player.bufferAttack = true
			player.bufferedKey = 'k'
		end
		if love.keyboard.isDown('l') then
			player.bufferAttack = true
			player.bufferedKey = 'l'
		end
	end

	--arrow shit
	if quiver.arrows ~= quiver.arrowMax then

		quiver.rechargeTimer = quiver.rechargeTimer + 1
		if quiver.rechargeTimer == quiver.rechargeMax then
			quiver.arrows = quiver.arrows + 1
			if quiver.arrows ~= quiver.arrowMax then
				quiver.rechargeTimer = 0
			end
		end
	end


	if button.button1.boolean then
		MainCharacterAnim:setAction(button.button1.animation)
		MainCharacterAnim:play()
		--MainCharacterAnim:setMode("once")
	else 
		-- MainCharacterAnim:resettwo()
	end





	--check collisions now?

	--if player.rolling then y = y + 8 end



	characterState.collision = physics:get(characterState.collision,x,y,player.img,0,-1)
	grounded = characterState.collision.down
	local closestDown = characterState.collision.borderDown
	local groundBox = characterState.collision.collided
	characterState.collision = physics:get(characterState.collision,x,y,player.img,0,1)
	up = characterState.collision.up
	local closestUp = characterState.collision.borderDown
	characterState.collision = physics:get(characterState.collision,x,y,player.img,1,0)
	local rightCollision = characterState.collision
	right = characterState.collision.right
	local closestRight = characterState.collision.borderRight
	local rightBox = characterState.collision.collided
	characterState.collision = physics:get(characterState.collision,x,y,player.img,-1,0)
	local leftCollision = characterState.collision
	left = characterState.collision.left
	local closestLeft = characterState.collision.borderLeft
	local leftBox = characterState.collision.collided


		-- check for one ways here

	characterState.collision= physics:get(characterState.collision,x,y,player.img,0,-1, "player")
	local onewayGrounded = characterState.collision.down
	local onewayClosestDown = characterState.collision.borderDown
	local onewayBox = characterState.collision.collided

	if onewayCheck and characterState.attacking then
		x = player.x 
	end

	if onewayGrounded then
		grounded = true
		groundBox = onewayBox
		closestDown = onewayClosestDown
		grounded = true
		--if characterState.attacking then
			--x = player.x end
	end

	-- if onewayBox == nil or (characterState.onOneWayPlatform and onewayBox.indicator ~= 'p') then
	-- 	characterState.onOneWayPlatform = false
	-- end

	-- if onewayGrounded and (fallingLastFrame or characterState.onOneWayPlatform) then
	-- 	print("tru1")
	-- 	--y = onewayClosestDown - player.img:getHeight()
		
	-- 	--stopJump = false
	-- 	--jumped = false
	-- 	--cantJumpAgain = false
	-- 	--cantJump = false
	-- 	--gravityIterator = 0
	-- 	--characterState.falling = false
	-- 	characterState.onOneWayPlatform = true
	-- else print("false1")
	-- end

	if grounded or onMovingPlatform then
		characterState.falling = false
	end

	--if player.rolling then y = y - 8 end

	if love.keyboard.isDown('s') and characterState.jumping then
		canPlunge = true
	else canPlunge = false
	end





	--extracheck for moving down
	characterState.collision= physics:get(characterState.collision,x,y+3,player.img,0,-1, "player")
	local movingCollision = characterState.collision.down
	local movingClosestDown = characterState.collision.borderDown
	local movingBox = characterState.collision.collided

	if movingCollision and movingBox.move_dir ~= nil and movingBox.move_dir == 1 and not movingBox.leftRight then
		onMovingPlatform = true
		y = movingClosestDown - player.img:getHeight()+2
		y = y + movingBox.move_dir*.015*movingBox.speed
		closestDown = movingClosestDown
	else onMovingPlatform = false
	end
	

	if groundBox ~= nil and groundBox.move_dir ~= nil and not onDiagonalSlope then
		onMovingPlatform = true
		y = closestDown - player.img:getHeight()+2
		--y = player.y
		if groundBox.leftRight then
			x = x + groundBox.move_dir*.015*groundBox.speed
		else
			y = y + groundBox.move_dir*.015*groundBox.speed
		end

	elseif not (movingCollision and movingBox.move_dir ~= nil) then onMovingPlatform = false
	end

	local delta_x = 0
	if x> player.x then
		delta_x = 1
	elseif x == player.x then
		delta_x = 0
	else
		delta_x = -1
	end


	--check for slope below
	local checkSlope_x = player.x + math.abs(player.x-x)/2
	local checkSlope_y = y
	if delta_x == 1 then
		checkSlope_x = checkSlope_x+1
		checkSlope_y = y
	elseif delta_x == -1 then checkSlope_x = player.x + 3
		checkSlope_y = y + 3
	end

	if (grounded and not jumped) or up and not onDiagonalSlope and not onDiagonalSlope2 then
		y = player.y
	end


	--local onDiagonalSlope = false


	characterState.collision = physics:get(characterState.collision,math.floor(checkSlope_x),checkSlope_y,player.img,1,0)
	local DiagonalRightBox = characterState.collision.collided
	characterState.collision = physics:get(characterState.collision,player.x-5,player.y+5,player.img,0,-1)
	local DiagonalGroundBox = characterState.collision.collided
	local slopeSpot = characterState.collision.borderDown

	local pushingBlock = false

	if characterState.hasRing then
		pushingBlock = getNearBox(deltaTime, rightCollision, leftCollision)
	end


	-- if (DiagonalRightBox ~= nil and DiagonalRightBox.indicator == "diagonal") or (DiagonalGroundBox ~= nil and DiagonalGroundBox.indicator == "diagonal") or (rightBox ~= nil and rightBox.indicator == "diagonal") or (groundBox ~= nil and groundBox.indicator == "diagonal") then
	-- 	if delta_x == 1 then
	-- 		local slope_y = y
	-- 		if not right then
	-- 			x = player.x + math.abs(player.x-x)/2
	-- 		end
	-- 		if (rightBox ~= nil and rightBox.id ~= "diag") or (groundBox ~= nil and groundBox.id == "diag") then
	-- 			slope_y = y - math.abs(player.x-x)
	-- 		else slope_y = y - math.abs(player.x-x)/2+.5
	-- 			--x = player.x + 4*math.abs(player.x-x)/4
	-- 		end
	-- 		characterState.collision = physics:get(characterState.collision,x,slope_y,player.img,1,0)
	-- 		closestDown = characterState.collision.borderDown
	-- 		box = characterState.collision.collided
	-- 		if (box ~= nil and box.indicator == "diagonal") and closestDown ~= nil then
	-- 			y = closestDown - player.img:getHeight()
	-- 		else
	-- 			y = slope_y
	-- 		end

	-- 		if (rightBox ~= nil and rightBox.id ~= "diag") or (groundBox ~= nil and groundBox.id == "diag") then
	-- 			y = player.y - math.abs(player.x-x)
	-- 		end
	-- 		delta_x = 0
	-- 	elseif delta_x == -1 then
	-- 		local slope_y = y
	-- 		if (DiagonalRightBox ~= nil and DiagonalRightBox.id ~= "diag") or (groundBox ~= nil and groundBox.id == "diag") then
	-- 			slope_y = player.y + math.abs(player.x-x)+10
	-- 		else slope_y = player.y + math.abs(player.x-x)/2+2
	-- 		end

	-- 		characterState.collision = physics:get(characterState.collision,x,slope_y,player.img,1,0)
	-- 		closestDown = characterState.collision.borderDown

	-- 		if closestDown ~= nil then
	-- 			y = closestDown - player.img:getHeight()
	-- 		end
	-- 		delta_x = 0
	-- 	end
	-- 	--delta_x = 0
	-- 	onDiagonalSlope = true
	-- 	grounded = true
	-- end

	onDiagonalSlope = false
	local slopeSpot = 0
	local side = nil


	onDiagonalSlope, slopeSpot, side = getCornerCollision(x+player.img:getWidth()-4,y+player.img:getHeight(),1)
	local onDiagonalSlope2, slopeSpot2, side2 = getCornerCollision(x+player.img:getWidth()-2,y+player.img:getHeight()-2,1)
	--local onDiagonalSlope3, slopeSpot3 = getRightCornerCollision(x+player.img:getWidth()-2,y+player.img:getHeight()-2)


	--print(slopeSpot)


	local becameGrounded = false
	if prev_grav > gravityIterator then
		becameGrounded = true
		--print("becameGrounded")
	end
	if side == "R" or side2 == "R" then
		if onDiagonalSlope and (not stopJump or becameGrounded) then
			--x = player.x + math.abs(player.x-x)/4
			y = slopeSpot - player.img:getHeight()
			grounded = true
			if not pushingBlock then
				right = false
			end
		end
		if onDiagonalSlope2 and not onDiagonalSlope and (not stopJump or becameGrounded) then
			--x = x + math.abs(player.x-x)/4
			y = slopeSpot2 - player.img:getHeight()
			grounded = true
			if not pushingBlock then
				right = false
			end
			onDiagonalSlope = true
		end
	end

	if delta_x < 0 then
		local onDiagonalSlope3, slopeSpot3, side3 = getCornerCollision(x+player.img:getWidth()-4,y+player.img:getHeight()+10,1)
		local onDiagonalSlope4, slopeSpot4, side3 = getCornerCollision(x+player.img:getWidth()-4,y+player.img:getHeight()+5,1)
		local onDiagonalSlope5, slopeSpot5, side3 = getCornerCollision(x+player.img:getWidth()-4,y+player.img:getHeight()+5,1)

		if side3 == "R" or side4 == "R" or side5 == "R" then
			if onDiagonalSlope4 and not onDiagonalSlope and not stopJump then
				--x = x + math.abs(player.x-x)/4
				y = slopeSpot4 - player.img:getHeight()
				grounded = true
				--print(slopeSpot4)
				if not pushingBlock then
					right = false
				end
				onDiagonalSlope = true
			end
			if onDiagonalSlope3 and not onDiagonalSlope and not stopJump then
				--x = x + math.abs(player.x-x)/4
				y = slopeSpot3 - player.img:getHeight()
				grounded = true
				--print(slopeSpot3)
				if not pushingBlock then
					right = false
				end
				onDiagonalSlope = true
			end
		end
	end

	side = nil
	if not onDiagonalSlope then
		onDiagonalSlope, slopeSpot, side = getCornerCollision(x+4,y+player.img:getHeight(),-1)
		onDiagonalSlope2, slopeSpot2, side2 = getCornerCollision(x+2,y+player.img:getHeight()-2,-1)
		--local onDiagonalSlope10, slopeSpot10, side10 = getCornerCollision(x-10,y+player.img:getHeight()-5,-1)
	end
	--local onDiagonalSlope3, slopeSpot3 = getRightCornerCollision(x+player.img:getWidth()-2,y+player.img:getHeight()-2)

	--print(slopeSpot)
	if side == "L" or side2 == "L" then

		if onDiagonalSlope and (not stopJump or becameGrounded) then
			--x = player.x + math.abs(player.x-x)/4
			y = slopeSpot - player.img:getHeight()
			grounded = true
			if not pushingBlock then
				left = false
			end
		end
		if onDiagonalSlope2 and not onDiagonalSlope and (not stopJump or becameGrounded) then
			--x = x + math.abs(player.x-x)/4
			y = slopeSpot2 - player.img:getHeight()
			grounded = true
			if not pushingBlock then
				left = false
			end
			onDiagonalSlope = true
		end
	end

	if delta_x > 0 then
		local onDiagonalSlope3, slopeSpot3, side3 = getCornerCollision(x+4,y+player.img:getHeight()+10,-1)
		local onDiagonalSlope4, slopeSpot4, side4 = getCornerCollision(x+4,y+player.img:getHeight()+5,-1)
		local onDiagonalSlope5, slopeSpot5, side5 = getCornerCollision(x+4,y+player.img:getHeight()+5,-1)

		if side3 == "L" or side4 == "L" or side5 == "L" then
			if onDiagonalSlope4 and not onDiagonalSlope and not stopJump then
				--x = x + math.abs(player.x-x)/4
				y = slopeSpot4 - player.img:getHeight()
				grounded = true
				--print(slopeSpot4)
				if not pushingBlock then
					left = false
				end
				onDiagonalSlope = true
			end
			if onDiagonalSlope3 and not onDiagonalSlope and not stopJump then
				--x = x + math.abs(player.x-x)/4
				y = slopeSpot3 - player.img:getHeight()
				grounded = true
				--print(slopeSpot3)
				if not pushingBlock then
					left = false
				end
				onDiagonalSlope = true
			end
		end
	end

	-- if slopeSpot then
	-- 	stopJump = false
	-- 	jumped = false
	-- 	cantJumpAgain = false
	-- 	cantJump = false
	-- 	gravityIterator = 0
	-- end


	--if onDiagonalSlope2 then
	--	y = slopSpot2 - player.img:getHeight()
	--	onDiagonalSlope = true
	-- elseif wasOnDiagonalLastUpdate then
	-- 	y = closestDown - player.img:getHeight()
	-- 	right = false
	--end









	if ((right and delta_x == 1) or (left and delta_x == -1)) then --and not onDiagonalSlope then
		x = player.x
	end


	if (right) and characterState.jumping then
		x = player.x
	end

	if (left) and characterState.jumping then
		x = player.x
	end

	if right and rightBox ~= nil and rightBox.move_dir ~= nil then --and (not onDiagonalSlope or pushingBlock) then
		if groundBox ~= nil and groundBox.move_dir == nil then
			x = closestRight - 32
		elseif groundBox == nil then
			x = closestRight - 32
		end
	end
	if left and leftBox ~= nil and leftBox.move_dir ~= nil then --and (not onDiagonalSlope or pushingBlock) then
		if groundBox ~= nil and groundBox.move_dir == nil then
			x = closestLeft
		elseif groundBox == nil then
			x = closestLeft
		end
	end


	--a
	if grounded and closestDown ~= nil and not onDiagonalSlope and ((closestDown - player.img:getHeight())+5 > player.y) then
		--if characterState.attacking then x = player.x end
		if groundedBox ~= nil and (groundedBox.indicator == 'M' or groundedBox.indicator == 'N') then

		else
			stopJump = false
			jumped = false
			cantJumpAgain = false
			cantJump = false
			gravityIterator = 0
			y = closestDown - player.img:getHeight()
			if not characterState.attacking then
				--MainCharacterAnim:resetAction("Jump")
			end
			if plunging then
				attackingTimer = 0
			end
			plunging = false
		end
	end



	


	local hitByEnemy = false
	local hitValue = 0
	hitByEnemy, hitValue = getHit(player.x,player.y)
	if hitByEnemy and player.health >= 0 and not player.hurt  then
		player.health = player.health - hitValue
	end
	if hitByEnemy and not player.hurt then
		player.hurt = true
		player.speed = player.speed/2
	end
	if player.hurt then
		if not characterState.cantKnockBack then

			characterState.collision = physics:get(characterState.collision,player.x,player.y+1,player.img,0,-1, "player")
			local C = characterState.collision.down
			if button.crouch and C then
				player.y = player.y - (64-36)
				resetAttackStuff()
			end
			button.crouch = false
			player.img = love.graphics.newImage('img/MainCharacterAnimations/Walk/01.png')

			stopJump = false
			jumped = false
			cantJumpAgain = false
			cantJump = false
			player.speed = 0

			plunging = false
			attackingTimer = 0
			characterState.attacking = false
			characterState.crouchAttack = false
			MainCharacterAnim:resetAction("CrouchSwordAttack")
			MainCharacterAnim:resetAction("SwordAttack1")
			MainCharacterAnim:resetAction("Plunge")
			--button.button1.bool = false
			resetAttackStuff()
			--button.crouch = false
			button.button1.boolean = false
			canShoot = true
			resetShoot()
			MainCharacterAnim:setAction("Hurt")
			MainCharacterAnim:setMode("loop")
			characterState.collision = physics:get(characterState.collision,player.x+ -direction * 200*deltaTime,y- 100 * deltaTime,player.img,0,-1)
			grounded = characterState.collision.down
			if player.hurtTimer >= 37 then
				x = player.x
				x = x + -direction * 130*deltaTime
				y = y - 130 * deltaTime
				characterState.collision = physics:get(characterState.collision,x,y,player.img,0,-1)
				grounded = characterState.collision.down
				local closestDown = characterState.collision.borderDown
				characterState.collision = physics:get(characterState.collision,x,y,player.img,0,1)
				up = characterState.collision.up
				local closestUp = characterState.collision.borderDown
				characterState.collision = physics:get(characterState.collision,x,y,player.img,1,0)
				local rightCollision = characterState.collision
				right = characterState.collision.right
				local closestRight = characterState.collision.borderRight
				characterState.collision = physics:get(characterState.collision,x,y,player.img,-1,0)
				local leftCollision = characterState.collision
				left = characterState.collision.left
				local closestLeft = characterState.collision.borderLeft
				if right or left then
					x = player.x
				end
				if up then
					y = player.y
				end
			else
				characterState.cantKnockBack = true
			end
		end
		player.hurtTimer = player.hurtTimer - 1
		if closestDown ~= nil and grounded and not (right or left) and not ((closestDown - player.img:getHeight()) <= player.y) then
			y = closestDown - player.img:getHeight()
			characterState.cantKnockBack = true
		end
		if player.hurtTimer <= 0 then
			player.hurt = false
			player.hurtTimer = 50
			player.speed = 130
			characterState.cantKnockBack = false
		end
	end

	-- if up then
	-- 	y = closestUp
	-- end
	-- if left then
	-- 	--x = closestLeft
	-- end
	-- if right then
	-- 	--x = closestRight
	-- end

	if characterState.wallHanging then 
		y = player.y 
		MainCharacterAnim:setAction("OnLedge")
		MainCharacterAnim:setMode("once")
	end


	if onMovingPlatform then
		y = closestDown - player.img:getHeight()+1
	end


	if characterState.initiatedPullUp then
		--MainCharacterAnim:resetAction("OnLedge")
		MainCharacterAnim:setAction("LedgeGetUp")
		MainCharacterAnim:setMode("once")

		y = player.y - 1.5
		x = player.x
		if y <= characterState.pullUp_y - 1.5 then
			characterState.initiatedPullUp = false
			y = characterState.savedLedgePoint - player.img:getHeight()
			MainCharacterAnim:resetAction("OnLedge")
		end
		if y <= characterState.pullUp_y and characterState.initiatedPullUp then
			y = characterState.savedLedgePoint - player.img:getHeight()
			x = player.x + 4 * direction
			MainCharacterAnim:resetAction("LedgeGetUp")
			MainCharacterAnim:setAction("LedgeGetUp")
			--characterState.initiatedPullUp = false
		end
	end


	player.y = y
	player.x = x

	if fallingLastFrame and not characterState.wallHanging then
		fallingLastFrame = false
	end

	if prev_y <= player.y and stopJump then
		stopJump = false
		jumped = false
		cantJumpAgain = false
		cantJump = false
		gravityIterator = 0
		fallingLastFrame = true
	end
	if prev_y < player.y then
		fallingLastFrame = true
		if not button.button1.boolean and not onMovingPlatform and not onDiagonalSlope and not characterState.attacking and (not player.hurt or characterState.cantKnockBack) and not button.crouch and not player.rolling then
			characterState.falling = true
			MainCharacterAnim:setActionSpeed("Fall", .8)
			MainCharacterAnim:setAction("Fall")
		end
	end

	-- local checkFeet = getWallHang(x-direction*16, y+player.img:getHeight()+16)

	-- -- if (right or left) and not checkFeet and not characterState.wallHanging then
	-- -- 	MainCharacterAnim:setAction("WallSlide")
	-- -- end


	prev_y = player.y
end

function getNearBox(deltaTime, colR, colL)
	--local colR = right
	--local colL = left
	local pushSpeed = player.speed/5
	if colR.collided ~= nil then
		if colR.collided.indicator == 'p' then -- or colR.collided.indicator == 'B' then
			local x = colR.collided.x1 + pushSpeed*deltaTime
			local boxCollisions = physics:get(boxCollisions, x+1,colR.collided.y1-1,colR.collided.boxImg,1,0,"pushable")
			if not boxCollisions.right then
				colR.collided.x1 = colR.collided.x1 + pushSpeed*deltaTime
				colR.collided.x2 = colR.collided.x2 + pushSpeed*deltaTime
				return true
			else
			end
		end
	end
	if colL.collided ~= nil then
		if colL.collided.indicator == 'p' then --or colL.collided.indicator == 'B' then
			local x = colL.collided.x1 + pushSpeed*deltaTime
			local boxCollisions = physics:get(boxCollisions, x-1,colL.collided.y1,colL.collided.boxImg,-1,0,"pushable")
			if not boxCollisions.left then
				colL.collided.x1 = colL.collided.x1 + pushSpeed*deltaTime
				colL.collided.x2 = colL.collided.x2 + pushSpeed*deltaTime
				return true
			end
		end
	end
	if colR.collided ~= nil then
		if colR.collided.indicator == 'B' then
			local x = colR.collided.x1 + direction*pushSpeed*deltaTime
			local boxCollisions = physics:get(boxCollisions, x+1,colR.collided.y1,colR.collided.boxImg,1,0,"pushable")
			if not boxCollisions.right then
				colR.collided.x1 = colR.collided.x1 + direction*pushSpeed*deltaTime
				colR.collided.x2 = colR.collided.x2 + direction*pushSpeed*deltaTime
				return true
			end
		end
	end
	if colL.collided ~= nil then
		if colL.collided.indicator == 'B' then
			local x = colL.collided.x1 + direction*pushSpeed*deltaTime
			local boxCollisions = physics:get(boxCollisions, x-1,colL.collided.y1,colL.collided.boxImg,-1,0,"pushable")
			if not boxCollisions.left then
				colL.collided.x1 = colL.collided.x1 + direction*pushSpeed*deltaTime
				colL.collided.x2 = colL.collided.x2 + direction*pushSpeed*deltaTime
				return true
			end
		end
	end
	return false
end

function getHit(x,y)
	for _,enemy in ipairs(hazardBounds) do
		for x_ = player.x+10,player.x + player.img:getWidth()-10 do
			if x_ >= enemy.x1 and x_<= enemy.x2 then
				for y_ = player.y+10, player.y+player.img:getHeight()-10 do
					if y_>= enemy.y1 and y_<= enemy.y2 then
						return true, 1
					end
				end
			end
		end
	end
	for _,enemy in ipairs(rats) do
		if enemy.folder_name ~= "Chest" then
			for x_ = player.x+10,player.x + player.img:getWidth()-10 do
				if x_ >= enemy.x and x_<= enemy.x+enemy.sprite:getWidth() then
					for y_ = player.y+10, player.y+player.img:getHeight()-10 do
						if y_>= enemy.y and y_<= enemy.y+enemy.y_offset + enemy.sprite:getHeight()-enemy.y_offset then
							if not enemy.dead then
								return true, enemy.hitValue
							end
						end
					end
				end
			end
			if enemy.projectile ~= nil then
				--for _,proj in ipairs(enemy.projectiles) do 
					local proj = enemy.projectile
					for x_ = player.x+10,player.x + player.img:getWidth()-10 do
						if x_ >= proj.x and x_<= proj.x+proj.sprite:getWidth() then
							for y_ = player.y+10, player.y+player.img:getHeight()-10 do
								if y_>= proj.y and y_<= proj.y + proj.sprite:getHeight() then
									if proj.destroyTimer < 1 then
										return true, enemy.hitValue
									end
								end
							end
						end
					end
				--end
			end
			if enemy.hurtBox ~= nil then
				for x_ = player.x+10,player.x + player.img:getWidth()-10 do
					if x_ >= enemy.hurtBox.x1 and x_<= enemy.hurtBox.x2 then
						for y_ = player.y+10, player.y+player.img:getHeight()-10 do
							if y_>= enemy.hurtBox.y1 and y_<= enemy.hurtBox.y2 then
								if not enemy.dead then
									return true, enemy.hitValue
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end

function getCoinItem()
	for _,heart in ipairs(heartContainers) do
		for x_ = player.x,player.x + player.img:getWidth() do
			if x_ >= heart.x1 and x_<= heart.x2 then
				print('y')
				for y_ = player.y, player.y+player.img:getHeight() do
					if y_>= heart.y1 and y_<= heart.y2 then
						table.remove(heartContainers,_)
						local ttype = nil
						if heart.sprite_name == "img/Items/health.png" then
							ttype = "coin"
						elseif heart.sprite_name == "img/Items/ammo.png" then
							ttype = "ammo"
						else ttype = "health"
						end
						return true, heart.x1+8,heart.y1+8, ttype
					end
				end
			end
		end
	end
	return false,0
end

function getNearVendor()
	for _,v in ipairs(vendorBounds) do
		for x_ = player.x,player.x + player.img:getWidth() do
			if x_ >= v.x and x_<= v.x+96 then
				for y_ = player.y, player.y+player.img:getHeight() do
					if y_>= v.y and y_<= v.y+64 then
						return true
					end
				end
			end
		end
	end
	return false
end

function getNearFire()
	for _,v in ipairs(respawnBounds) do
		for x_ = player.x,player.x + player.img:getWidth() do
			if x_ >= v.x1 and x_<= v.x1+96 then
				for y_ = player.y, player.y+player.img:getHeight() do
					if y_>= v.y1 and y_<= v.y1+64 then
						if not v.on then 
							player.currentSpawnPoint = v
							return true
						end
					end
				end
			end
		end
	end
	return false
end


function character_controller:draw(dt)
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("line", player.x, player.y, player.img:getWidth(), player.img:getHeight())

	-- love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
	-- love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
	--love.graphics.draw(player.img,thing,player.y, 0,direction,1,0,0)
	local render_x = getFlip()
	local render_y = player.y
	if player.hurt then
		love.graphics.setColor(255,255,255,150)
	end
	love.graphics.setShader(shader)
	playerGhostContainer:draw()
	love.graphics.setShader()
	if (not player.rolling or player.offGroundDodge) and (not button.button1.boolean and not characterState.attacking and not plunging and not player.isChargingAttack and not player.charging and not player.chargeStrike) or (player.hurt and not characterState.cantKnockBack) and not plunging and not (button.button1.class == axe_throw and button.button1.boolean) and not (MainCharacterAnim:getAction() == "AxeThrow") then
		MainCharacterAnim:draw(render_x,render_y,0,direction,1)
	elseif not player.rolling and not characterState.attacking and (not player.hurt or characterState.cantKnockBack) and not plunging and not player.isChargingAttack and not player.charging and not player.chargeStrike and not (button.button1.class == axe_throw and button.button1.boolean) and not (MainCharacterAnim:getAction() == "AxeThrow")  then
		render_y = render_y - 5
		MainCharacterAnim:draw(render_x,render_y,0,direction,1)
	elseif (characterState.attacking or plunging or player.isChargingAttack or player.charging or player.chargeStrike or player.rolling or player.rolling) and not player.secondSlashing and (not player.hurt or characterState.cantKnockBack) and not (button.button1.class == axe_throw and button.button1.boolean) and not (MainCharacterAnim:getAction() == "AxeThrow") then
		render_x = render_x - 10 * direction
		render_y = render_y - 48
		MainCharacterAnim:draw(render_x,render_y,0, direction,1)
	elseif player.secondSlashing or (MainCharacterAnim:getAction() == "AxeThrow")  then
		render_x = render_x - (10+32)*direction
		render_y = render_y - 48
		MainCharacterAnim:draw(render_x,render_y,0,direction,1)
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("line",blade_collider.x1,blade_collider.y1, blade_collider.x2-blade_collider.x1,blade_collider.y2-blade_collider.y1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("line",windowCanvas.x1,windowCanvas.y1, windowCanvas.x2-windowCanvas.x1,windowCanvas.y2-windowCanvas.y1)
	player.render_x = render_x
	player.render_y = render_y
	if player.chargeFill then
		local chargePercent = player.chargeFillValue/player.chargeFillMax
		love.graphics.setColor(0,255,0)
		love.graphics.rectangle("fill", player.x, player.y - 8 , 32*chargePercent, 4)
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("line", player.x, player.y - 8 , 32, 4)
	end
	for _,dust in ipairs(dashTrailTable) do 
		if player.rolling then
			dust.animator:setAction("Dust")
			dust.animator:setActionSpeed("Dust", 3)
			dust.animator:setMode("loop")
			dust.animator:draw(dust.x-direction*8,dust.y,0,1.25,1.25)
		end
	end

	if player.nearVendor or player.nearFire then
		keyIndicator:draw(player.x,player.y-32,0,1,1)
	end

	drawCoinDropper()
end

function character_controller:drawHUD(dt)
	 --draw something here
	local healthPercentage = player.health/player.healthMax
	local window_x = windowSize.x/windowSize.scale
	local window_y = windowSize.y/windowSize.scale
	local offset = window_x/2-window_x/12-25
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,window_x, window_y/6)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,window_y-window_y/6,window_x, window_y/6)
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", window_x/12+25+offset, window_y/24, 50*healthPercentage, 10)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", window_x/12+25+offset, window_y/24, 50, 10)
	love.graphics.setColor(0, 0, 255)
	love.graphics.rectangle("fill", window_x/12+25+ offset, window_y/24+window_y/24, 50, 10)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", window_x/12+25+offset, window_y/24+window_y/24, 50, 10)
	love.graphics.draw(mainCharPortrait,-10+offset,0,0,.8,.8)
	if characterState.hasRing then
		--love.graphics.draw(ring.img,-20+offset,50,0,1,1)
	end
	drawArrowIcons()
	drawDeathCounter()

end

function drawArrowIcons()
	local offset = windowSize.x/2-windowSize.x/12-25+100
	local i = 0
	for n = 1,quiver.arrows do
		local off = i*32
		if n == quiver.arrows then
			if n ~= quiver.arrowMax then 
				love.graphics.setColor(255,255,0,255)
				love.graphics.rectangle("fill", windowSize.x/12+25+offset+60+off,windowSize.y/24, 32*(quiver.rechargeTimer/quiver.rechargeMax), 4)
			end
			love.graphics.setColor(255,255,255,255*(quiver.rechargeTimer/quiver.rechargeMax))
		else love.graphics.setColor(255,255,255,255)
		end
		love.graphics.draw(quiver.Icon,windowSize.x/12+25+offset+60+off,windowSize.y/24,0,1,1)
		love.graphics.setColor(255,255,255,255)

		i = i + 1
	end
end



function character_controller:drawRingBox()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",windowSize.x/3,windowSize.y/3,windowSize.x/3,windowSize.y/3)
	love.graphics.setColor(255,255,255)
	local font = love.graphics.newFont("assets/samplefont.ttf", 15)
	love.graphics.setFont(font)
	love.graphics.printf("You have obtained the\nRing of Power\n\nYou can now push blocks", windowSize.x/2-120, windowSize.y/2-60, windowSize.y/2, 'center')
	-- body
end

function character_controller:drawVendorMenu()
	love.graphics.draw(vendorMenu.images[vendorMenu.position],150,200,0,1,1)
	love.graphics.draw(vendorMenu.portrait,50,200,0,1,1)

	
	-- body
end

function drawDeathCounter()
	love.graphics.setColor(255,255,255)
	local font = love.graphics.newFont("assets/font.ttf", 10)
	love.graphics.setFont(font)
	love.graphics.printf("Death Counter: " .. debugTools.deathCounter .. "\nTime Played: " .. debugTools.timer, 0 ,0, 0, 'left')
	love.graphics.printf("Coins: " .. player.coins, 100 ,0, 0, 'left')
	love.graphics.printf("Ammo: " .. player.ammo, 100 ,50, 0, 'left')

end

function lerp(a,b,t) return (1-t)*a + t*b end







