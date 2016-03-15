-- blow up boxes
--require 'shooter'

-- ideas for other items
-- tauros charge?  moves big blocks (3x3) and destroys certain ones (makes you go fast)
-- what do i do about small blocks?  too small to make sense pushing? maybe only make them 2x2 blocks or 2x1

-- change bow to aim anywhere after a certain amount of time charging on the ground

-- hook and swing item and double jump (hook would work the same as grounded bow)

-- add smoke coming up on the charge animation for bow and a release bow animation
-- ice level with acceleration on ground
-- figure out how to use shaders

--charge sword slash for running slash (horizontal charge)
-- ice arrows to make slippy
-- charge arrows longer for double shot?

itemQuads = {}
itemTiletable = {}
itemBounds = {}
pushableBounds = {}
movingBounds = {}
movingLimits = {}
triggerBounds = {}
hazardBounds = {}
vendorBounds = {}
respawnBounds = {}
switchableDoors = {}
switchBounds = {}


persistantRespawn = {}
persistantDoors = {}

love.filesystem.load("shooter.lua")
require 'acca'

ring = {obtained = false, exists = false, x = 0, y = 0, img = nil}

function loadItemMap(map_path)
	ring.img = love.graphics.newImage("assets/ring_icon.png")
	TileW, TileH = 32,32
	Tileset = love.graphics.newImage('assets/MapStringGenerator/simpletiles1.png')
	TileImg = love.graphics.newImage('assets/32x32.png')
	BigTileImg = love.graphics.newImage('assets/64x64.png')

	for k in pairs(movingBounds) do
   		movingBounds[k] = nil
	end

	for k in pairs(pushableBounds) do
   		pushableBounds[k] = nil
	end

	for k in pairs(triggerBounds) do
   		triggerBounds[k] = nil
	end

	for k in pairs(itemQuads) do
		itemQuads[k] = nil
	end
	for k in pairs(hazardBounds) do
		hazardBounds[k] = nil
	end
	for k in pairs(vendorBounds) do
		vendorBounds[k] = nil
	end
	for k in pairs(heartContainers) do
		heartContainers[k] = nil
	end
	for k in pairs(itemBounds) do
		itemBounds[k] = nil
	end
	for k in pairs(movingLimits) do
		movingLimits[k] = nil
	end
	for k in pairs(respawnBounds) do
		respawnBounds[k] = nil
	end
	for k in pairs(switchableDoors) do
		switchableDoors[k] = nil
	end
	for k in pairs(switchBounds) do
		switchBounds[k] = nil
	end

-- 	local quadInfo = {
-- 	{'o',0,0}, -- background block
-- 	{'D',32,0}, -- destructable
-- 	{"2",64,0}, -- destructable2
-- 	{"1",64,32}, --  destructable 3
-- 	{'p', 32,32}, -- pushable block
-- 	{'b',0,32} --  ground block
-- }
	--resetMap()
	local quadInfo = getMapTileset(map_path, "simpletiles1")

	if map_path == "assets/MapStringGenerator/MapScripts/horizontalroom.lua" and not characterState.hasRing then
		ring.x = 1*32
		ring.y = 23*32
		ring.exists = true
	else
		ring.exists = false
	end

	-- local tileString = [[
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzDDzzz
	-- zzzzzzzzzzzDDzzz
	-- zzzzzzzzzzzDDzzz
	-- zzDDzzzzzzzzzzzz
	-- zzDDzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzDzzzzBlzzzz
	-- zzzzzDDzzzllzpzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzDDzzz
	-- zzzzzzzzzzzDDzzz
	-- zzzzzzzzzzzDDzzz
	-- zzzzzzzzzzzzzzzz
	-- DDDzzzzzzzzzzzzz
	-- DDDzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzBlzzzz
	-- zzzzzzDzzzllzpzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- zzzzzzzzzzzzzzzz
	-- ]]

	local tileString = getMapString(map_path, "Item Layer",false)
	print(tileString)

	---------------------------------------
	-- Seperator
	---------------------------------------

	local tileSetW, tileSetH = Tileset:getWidth(), Tileset:getHeight()

	if quadInfo ~= nil then
		local i = 0
		for _,info in ipairs(quadInfo) do
			print(i)
			itemQuads[info[1]] = love.graphics.newQuad(info[2],info[3],TileW,TileH,tileSetW,tileSetH)
		end

		local width = #(tileString:match("[^\n]+"))

		for x = 1, width, 1 do itemTiletable[x] = {} end

		local x, y = 1,1
		for row in tileString:gmatch("[^\n]+") do
			x = 1
			for character in row:gmatch(".") do 
				--if character == 'D' or character == 'z' or character == 'p' or character == 'B' or character == 'l' or character == "1" or character == "2" or character == 'M' or character == "!" or character == "T" or character == "S" or character == "L" or character == 'N' or character == 'V' then
					itemTiletable[x][y] = character
					x = x+1
				--end
			end
			y = y+1
		end
		loadItemMapColliders()
		loadPushableBlockColliders()
		loadMovingColliders()
		loadTriggers()
		loadRespawn(map_path)
	end
end

function drawItemMap()
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			if char == 'D' or char == "1" or char == "2"  or char == "S" then
				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
				love.graphics.draw(Tileset,itemQuads[char],x,y)
			end
		end
	end
	drawMovingColliders()
	reDrawPushables()
	drawTriggers()
	drawVendors()
end

function drawParticle()
	for num, bounds in ipairs(itemBounds) do
		if bounds.invulnerable then
			bounds.particleSys:draw(bounds.x1-16, bounds.y1-16,0,1,1)
		end
	end
end

function loadItemMapColliders()
	boxiterator = 0
	--_particleSys = newCharacter("img","RockBlowUp","png",0.1,"RockBlowUp")
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, hits = 3, invulnerable = false, invulnerableTimer = 25, particleSys = nil, destroyed = false, boxImg = TileImg, gravityIterator = 0}
			--boxData.particleSys = _particleSys
			if char == 'D' then
				boxData.particleSys = newCharacter("img","RockBlowUp","png",0.1,"RockBlowUp")
				table.insert(itemBounds, boxData)
			end

			if char == 'S' then
				table.insert(hazardBounds,boxData)
			end
			if char == 's' then -- moving one
				boxData.isMoving = true
				boxData.falling = false
				boxData.animator = newCharacter("itemimg", "FireballHazard", "png", 0.1, "Fireball")
				table.insert(hazardBounds,boxData)
			end
			if char == 'H' then
				local heart = heart1:new()
				heart.x1 = x
				heart.y1 = y
				heart.y2 =y + 16
				heart.x2 = x+16
				heart.sprite = love.graphics.newImage(heart.sprite_name)
				table.insert(heartContainers,heart)
			end
		end
	end
	loadVendors()
end

function updateMovingHaz(dt)
	for _, box in ipairs(hazardBounds) do
		if box.isMoving then
			box.animator:update(dt)
			if containedInWindowCanvas(box.x1,box.y1) then
				local boxCollisions = physics:get(boxCollisions, box.x1,box.y1,box.boxImg,0,-1)
				local ground = boxCollisions.down
				local floor = boxCollisions.borderDown
				local changeY1 = box.y1
				local changeY2 = box.y2
				box.gravityIterator = box.gravityIterator+1
				changeY1 = box.y1 + 30*.005*box.gravityIterator - 7
				changeY2 = box.y2 + 30*.005*box.gravityIterator - 7
				if ground then
					box.gravityIterator = 0
				end

				if changeY1>box.y1 then
					box.falling = true
				else box.falling = false
				end
				box.y1 = changeY1
				box.y2 = changeY2
			end
		end
	end
end

function drawMovingHazards()
	for _, box in ipairs(hazardBounds) do
		if box.isMoving then
			local flip = 1
			if box.falling then
				flip = -1
			end
			local Y = box.y1
			if box.falling then
				Y = Y +32
			end
			box.animator:draw(box.x1,Y,0,1,flip)
			love.graphics.rectangle("line", box.x1,box.y1,32,32)
		end
	end
end

function loadVendors()
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			if char == 'V' then
				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
				local vendorData = {x = x,y = y, animator = nil, actionTimer = 200, action = "Talk", isBeingTalkedTo = false, sprite = nil, sprite_name = "img/Vendor/Idle/01.png"}
				vendorData.animator = newCharacter("img","Vendor","png", 0.5,"Talk")
				table.insert(vendorBounds,vendorData)
			end
		end
	end
end

function drawVendors()
	for num, bounds in ipairs(vendorBounds) do
		--print("lol")
		bounds.animator:draw(bounds.x, bounds.y,0,1,1)
	end
	drawMovingHazards()
end

function updateVendors(dt)
	for num, v in ipairs(vendorBounds) do
		v.animator:update(dt)
		print("ok")
		v.animator:setMode("loop")
		v.actionTimer = v.actionTimer - 1
		if v.actionTimer <= 0 then
			if v.action == "Talk" then
				v.animator:setAction("Idle")
				v.action = "Idle"
			else
				v.animator:setAction("Talk")
				v.action = "Talk"
			end
			v.actionTimer = math.random(150,300)

		end
		
	end
	updateRespawn(dt)
	updateMovingHaz(dt)
end



function loadPushableBlockColliders()
	boxiterator = 0
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, boxImg = TileImg, gravityIterator = 0}
			if char == 'p' then
				table.insert(pushableBounds, boxData)
			end
			local boxData = {x1 = x, y1 = y, x2 = x + TileW*2, y2 = y + TileH*2, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, boxImg = BigTileImg, gravityIterator = 0}
			if char == 'B' then
				table.insert(pushableBounds, boxData)
			end
		end
	end
end


function loadTriggers()
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, timer = 70, triggered =false, dustAnimator = nil}
			if char == 'T' then
				table.insert(triggerBounds, boxData)
			end
		end
	end
end

function updateTriggers(dt)
	for _,box in ipairs(triggerBounds) do
		if not box.triggered then
			if player.x > box.x1 and player.x < box.x2 and containedInWindowCanvas(box.x1,box.y1) then
				box.triggered = true
				box.dustAnimator = newCharacter("img", "DustCloud", "png", .3, "Dust")
			end
		end
		if box.triggered then
			box.dustAnimator:update(dt)
			box.timer = box.timer - 1
			if box.timer <= 0 then
				local enemyData = walkingmonster:new()
				enemyData.enemy = enemyData
				enemyData.x = box.x1
				enemyData.y = box.y1 - 32
				enemyData:loadEnemy()
				table.insert(rats,enemyData)
				table.remove(triggerBounds,_)
			end
		end
	end
	updateVendors(dt)
end

function drawTriggers()
	for _,box in ipairs(triggerBounds) do
		if box.triggered then
			box.dustAnimator:setMode("loop")
			box.dustAnimator:setActionSpeed("Dust",4)
			box.dustAnimator:draw(box.x1+math.random(-16,16),box.y1,0,1,1)
		end
	end
end

function updatePushables(dt)
	updateTriggers(dt)
	for _,box in ipairs(pushableBounds) do
		if containedInWindowCanvas(box.x1,box.y1) then
			local boxCollisions = physics:get(boxCollisions, box.x1,box.y1,box.boxImg,0,-1,"pushable")
			local ground = boxCollisions.down
			local floor = boxCollisions.borderDown
			if not ground then
				box.gravityIterator = box.gravityIterator+1
				box.y1 = box.y1 + 35*.005*box.gravityIterator
				box.y2 = box.y2 + 35*.005*box.gravityIterator
			else
				box.gravityIterator = 0
				box.y1 = floor - TileW
				box.y2 = floor
			end
		end
	end
end

function loadMovingColliders()
	loadMovingColliderLimits()
	boxiterator = 0
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + 10, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, boxImg = BigTileImg, move_dir = 1, speed = 60, turnAroundCoolDown = 100, leftRight = true, scale_x = 1}
			if char == 'M' then
				local extendedCollider = false
				for _, box in ipairs(movingBounds) do
					if box.x1 == boxData.x1-TileW and box.y1 == boxData.y1 then
						box.x2 = boxData.x2
						box.scale_x = 2
						extendedCollider = true
					end
				end
				if not extendedCollider then
					table.insert(movingBounds, boxData)
				end
			end
			if char == 'N' then
				boxData.leftRight = false
				table.insert(movingBounds, boxData)
			end
		end
	end
end

function loadMovingColliderLimits()
	boxiterator = 0
	limitsLoaded = false
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, boxImg = BigTileImg}
			if char == 'L' then
				print("KGHDSLKFJGHSKLDJFHGLKSDFHGLKSDHFLGKJDSHFL")
				table.insert(movingLimits, boxData)
			end
		end
	end
	limitsLoaded = true
end


function updateMovingColliders(dt)
	updatePushables(dt)
	if limitsLoaded then
		for num, bounds in ipairs(movingBounds) do
			--if containedInWindowCanvas(bounds.x1,bounds.y1) then
				local check_x,check_y = bounds.x1+16,bounds.y1+16
				if bounds.leftRight then
					bounds.x1 = bounds.speed*.015*bounds.move_dir + bounds.x1
					bounds.x2 = bounds.x1+TileW*bounds.scale_x

					if bounds.move_dir == 1 then
						check_x = bounds.x2
					else check_x = bounds.x1
					end
				else
					bounds.y1 = bounds.speed*.015*bounds.move_dir + bounds.y1
					bounds.y2 = bounds.y1+10

					if bounds.move_dir == 1 then
						check_y = bounds.y2
					else check_y = bounds.y1
					end
				end

				if getMovingLimits(check_x,check_y) then-- and bounds.turnAroundCoolDown == 100 then
					bounds.move_dir = -bounds.move_dir
					bounds.turnAroundCoolDown = bounds.turnAroundCoolDown - 1
				end

				if bounds.turnAroundCoolDown<100 then
					bounds.turnAroundCoolDown = bounds.turnAroundCoolDown - 1
					if bounds.turnAroundCoolDown<= 0 then
						bounds.turnAroundCoolDown = 100
					end
				end

				-- if bounds.x1 <= bounds.limit1 then
				-- 	bounds.move_dir = 1
				-- end
				-- if bounds.x2 >= bounds.limit2 then
				-- 	bounds.move_dir = -1
				-- end 
		end
	end
end

function getMovingLimits(x,y)
	for _,box in ipairs(movingLimits) do
		if x>box.x1 and x<box.x2 then
			if y>box.y1 and y<box.y2 then
				return true
			end
		end
	end
	return false
end


function drawMovingColliders()
	for _, box in ipairs(movingBounds) do
		love.graphics.draw(Tileset,itemQuads['M'],box.x1,box.y1,0,box.scale_x,1)
	end
end

function deletePushableBlocks()
	for num, box in ipairs(pushableBounds) do
		table.remove(pushableBounds,num)
	end
end

function checkBlowUpBoxes(dt)
	updateMovingColliders(dt)
	updateRing()
	for num, bounds in ipairs(itemBounds) do
		if bounds.destroyed and not bounds.invulnerable then
			itemTiletable[bounds.columnIndex][bounds.rowIndex] = "z"
			table.remove(itemBounds, num)
		end
		bounds.particleSys:update(dt)
		if not bounds.invulnerable then
			for numAr, ar in ipairs(arrowsOnScreen) do
				if not ar.stopped then
					if ar.d == 1 then
						s = 19
					else
						s = -19
					end
					if ar.x+s >= bounds.x1 and ar.x+s<= bounds.x2 then
						if ar.y+ar.img:getHeight()/2 >= bounds.y1 and ar.y+ar.img:getHeight()/2 <= bounds.y2 then
							if bounds.hits > 0 then
								bounds.hits = bounds.hits-1
								itemTiletable[bounds.columnIndex][bounds.rowIndex] = tostring(bounds.hits)
								bounds.invulnerable = true
								if bounds.invulnerableTimer == 25 then
									bounds.particleSys:resetAction("RockBlowUp")
								end
							end
							if bounds.hits <= 0 then
								bounds.destroyed = true
								return
							end
							return
						end
					end
				end
			end
		else 
			bounds.invulnerableTimer = bounds.invulnerableTimer - 1
			if bounds.invulnerableTimer<= 0 then
				bounds.invulnerable = false
				bounds.invulnerableTimer = 25
			end
		end
	end
	for num, bounds in ipairs(itemBounds) do
		if not bounds.invulnerable then
			local b_x = 0
			local b_y = 0
			for b_x = blade_collider.x1, blade_collider.x2 do
				for b_y = blade_collider.y1, blade_collider.y2 do
					if b_x >= bounds.x1 and b_x <= bounds.x2 then
						if b_y >= bounds.y1 and b_y <= bounds.y2 then
							if bounds.hits > 0 then
								if characterState.attacking then
									bounds.hits = bounds.hits-0
								end
								bounds.hits = bounds.hits-2
								itemTiletable[bounds.columnIndex][bounds.rowIndex] = tostring(bounds.hits)
								bounds.invulnerable = true
								if bounds.invulnerableTimer == 25 then
									bounds.particleSys:resetAction("RockBlowUp")
								end
							end
							if bounds.hits <= 0 then
								bounds.destroyed = true
								return
							end
							return
						end
					end
				end
			end
		else
			bounds.invulnerableTimer = bounds.invulnerableTimer - 1

			if bounds.invulnerableTimer<= 0 then
				bounds.invulnerable = false
				bounds.invulnerableTimer = 25
			end
		end
	end
end

function reDrawPushables()
	drawRing()
	for num, box in ipairs(pushableBounds) do
		--local x,y = (box.columnIndex-1)*TileW, (box.rowIndex-1)*TileH
		if box.indicator == 'p' then 
			love.graphics.draw(Tileset,itemQuads['p'],box.x1,box.y1)
		end
		if box.indicator == 'B' then
			--love.graphics.draw(BigTileImg,box.x1,box.y1,0,0,1)
			love.graphics.draw(Tileset,itemQuads['p'],box.x1,box.y1)
			love.graphics.draw(Tileset,itemQuads['p'],box.x1+32,box.y1)
			love.graphics.draw(Tileset,itemQuads['p'],box.x1,box.y1+32)
			love.graphics.draw(Tileset,itemQuads['p'],box.x1+32,box.y1+32)
		end
	end
end

function drawRing()
	if ring.exists then
		love.graphics.draw(ring.img,ring.x,ring.y,0,1,1)
	end
end

function updateRing()
	if ring.exists then
		for x_ = player.x+10,player.x + player.img:getWidth()-10 do
			if x_ >= ring.x and x_<= ring.x+ring.img:getWidth() then
				for y_ = player.y+10, player.y+player.img:getHeight()-10 do
					if y_>= ring.y and y_<= ring.y+ring.img:getHeight() then
						ring.exists = false
						ring.obtained = true
						characterState.hasRing = true
					end
				end
			end
		end
	end
end












function loadRespawn(map_path)
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			if char == 'Q' then
				print("SADASD")
				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
				local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, timer = 70, triggered =false, dustAnimator = nil, on = false, room = map_path, state = nil}
				local action = nil
				if persistantRespawn[boxData.room] == nil then
					persistantRespawn[boxData.room] = {state = "Off", on = false}
				else boxData.on = persistantRespawn[boxData.room].on
				end


				-- if player.respawnPointTriggered then
				-- 	action = "On"
				-- 	boxData.on = true
				-- else action = "Off"
				-- end

				boxData.animator = newCharacter("itemimg","Bonfire","png",0.1,persistantRespawn[boxData.room].state)
				table.insert(respawnBounds, boxData)
			end
		end
	end
	loadDoorsAndSwitches(map_path)
end

function updateRespawn(dt)
	for _, respawn in ipairs(respawnBounds) do
		if respawn.on then
			respawn.animator:setAction("On")
			persistantRespawn[respawn.room].on = true 
			persistantRespawn[respawn.room].state = "On"
		end
		respawn.animator:update(dt)
	end
	-- for _,box in ipairs(triggerBounds) do
	-- 	if not box.triggered then
	-- 		if player.x > box.x1 and player.x < box.x2 and containedInWindowCanvas(box.x1,box.y1) then
	-- 			box.triggered = true
	-- 			box.dustAnimator = newCharacter("img", "DustCloud", "png", .3, "Dust")
	-- 		end
	-- 	end
	-- 	if box.triggered then
	-- 		box.dustAnimator:update(dt)
	-- 		box.timer = box.timer - 1
	-- 		if box.timer <= 0 then
	-- 			local enemyData = walkingmonster:new()
	-- 			enemyData.enemy = enemyData
	-- 			enemyData.x = box.x1
	-- 			enemyData.y = box.y1 - 32
	-- 			enemyData:loadEnemy()
	-- 			table.insert(rats,enemyData)
	-- 			table.remove(triggerBounds,_)
	-- 		end
	-- 	end
	-- end
	-- updateVendors(dt)
	updateDoorsAndSwitches()
end

function drawRespawn()
	for _,respawn in ipairs(respawnBounds) do
		respawn.animator:draw(respawn.x1,respawn.y1,0,1,1)
	end
	drawDoorAndSwitches()
end




function loadDoorsAndSwitches(map_path)
	for columnIndex, column in ipairs(itemTiletable) do
		for rowIndex, char in ipairs(column) do
			if char == 'x' then -- door
				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
				local boxData = {x1 = x, y1 = y, x2 = x + TileW-2, y2 = y + TileH*3, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, timer = 70, triggered =false, dustAnimator = nil, on = false, room = map_path, switched = false, permanentSwitch = false}
				local action = nil
				if persistantDoors[boxData.room] == nil then
					persistantDoors[boxData.room] = {switched = false}
				else boxData.switched = persistantDoors[boxData.room].switched
					if persistantDoors[boxData.room].switched then boxData.permanentSwitch = true end
				end

				boxData.sprite = love.graphics.newImage("itemimg/Door/door.png")

				-- if player.respawnPointTriggered then
				-- 	action = "On"
				-- 	boxData.on = true
				-- else action = "Off"
				-- end

				table.insert(switchableDoors, boxData)
			end
			if char == 'Z' then -- switch
				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
				local boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH, indicator = char, column = column, columnIndex = columnIndex, rowIndex = rowIndex, timer = 70, triggered =false, dustAnimator = nil}
				boxData.sprite = love.graphics.newImage("itemimg/Door/Switch/01.png")
				boxData.sprite1 = boxData.sprite
				boxData.sprite2 = love.graphics.newImage("itemimg/Door/Switch/02.png")
				-- if player.respawnPointTriggered then
				-- 	action = "On"
				-- 	boxData.on = true
				-- else action = "Off"
				-- end
				table.insert(switchBounds, boxData)
			end
		end
	end
end

function updateDoorsAndSwitches(dt)
	local switchedSwitch = false
	local playerOnSwitch = false
	for _, switch in ipairs(switchBounds) do
		local boxCollisions = physics:get(boxCollisions, switch.x1,switch.y1,switch.sprite,0,1,"switch")
		local up = boxCollisions.up
		playerOnSwitch = boxCollisions.borderUp
		if up then
			switch.sprite = switch.sprite2
			switch.triggered = true
		else switch.triggered = false
			switch.sprite = switch.sprite1
		end
		switchedSwitch = switch.triggered
	end

	for _, door in ipairs(switchableDoors) do
		door.switched = switchedSwitch
		if door.permanentSwitch then door.switched = true end
		if door.switched then
			local boxCollisions = physics:get(boxCollisions, door.x1,door.y1,door.sprite,0,1, "door")
			local ceiling = boxCollisions.up
			local ceilingTile = boxCollisions.borderUp
			if not ceiling then
				door.y1 = door.y1 - .6
				door.y2 = door.y2 - .6
			elseif not playerOnSwitch then
				persistantDoors[door.room].switched = door.switched
				door.permanentSwitch = true
			end
		else 
			local boxCollisions = physics:get(boxCollisions, door.x1,door.y1,door.sprite,0,-1, "door")
			local ground = boxCollisions.down
			if not ground then
				door.y1 = door.y1 + 1.2
				door.y2 = door.y2 + 1.2
			end
		end	
	end
	-- for _,box in ipairs(triggerBounds) do
	-- 	if not box.triggered then
	-- 		if player.x > box.x1 and player.x < box.x2 and containedInWindowCanvas(box.x1,box.y1) then
	-- 			box.triggered = true
	-- 			box.dustAnimator = newCharacter("img", "DustCloud", "png", .3, "Dust")
	-- 		end
	-- 	end
	-- 	if box.triggered then
	-- 		box.dustAnimator:update(dt)
	-- 		box.timer = box.timer - 1
	-- 		if box.timer <= 0 then
	-- 			local enemyData = walkingmonster:new()
	-- 			enemyData.enemy = enemyData
	-- 			enemyData.x = box.x1
	-- 			enemyData.y = box.y1 - 32
	-- 			enemyData:loadEnemy()
	-- 			table.insert(rats,enemyData)
	-- 			table.remove(triggerBounds,_)
	-- 		end
	-- 	end
	-- end
	-- updateVendors(dt)
end

function drawDoorAndSwitches()
	for _, door in ipairs(switchableDoors) do
		love.graphics.draw(door.sprite,door.x1,door.y1,0,1,1)
	end
	for _, switch in ipairs(switchBounds) do
		love.graphics.draw(switch.sprite,switch.x1,switch.y1,0,1,1)
	end
end





function updateMovingHazards(dt)
	for _,box in ipairs(pushableBounds) do
		if containedInWindowCanvas(box.x1,box.y1) then
			local boxCollisions = physics:get(boxCollisions, box.x1,box.y1,box.boxImg,0,-1,"pushable")
			local ground = boxCollisions.down
			local floor = boxCollisions.borderDown
			if not ground then
				box.gravityIterator = box.gravityIterator+1
				box.y1 = box.y1 + 35*.005*box.gravityIterator
				box.y2 = box.y2 + 35*.005*box.gravityIterator
			else
				box.gravityIterator = 0
				box.y1 = floor - TileW
				box.y2 = floor
			end
		end
	end
end
