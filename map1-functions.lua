love.filesystem.load("assets/MapStringGenerator/MapStringGenerator.lua")
require 'MapStringGenerator'

Quads = {}
Tiletable = {}
Bounds = {}
tileLookUp = {}
tileLookUpDiag = {}

diagonalBounds = {}
onewayBounds = {}

doorData = {}
doorData.x = 0
doorData.y = 0
doorData.width = 0
doorData.height = 0
doorData.destination = nil
doorData.position = nil

doorPositions = {}

function doorData:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function loadMap(map_path)
	resetMap()

	for k in pairs(tileLookUpDiag) do
   		tileLookUpDiag[k] = nil
	end
	if tileLookUpDiag ~= nil then
		for num,quad in ipairs(tileLookUpDiag) do
			table.remove(tileLookUpDiag,num)
		end
	end

	for k in pairs(diagonalBounds) do
   		diagonalBounds[k] = nil
	end

	for num,quad in ipairs(Quads) do
		table.remove(Quads,num)
	end

	for k in pairs(doorPositions) do
   		doorPositions[k] = nil
	end

	for k in pairs(onewayBounds) do
   		onewayBounds[k] = nil
	end
	for k in pairs(tileLookUp) do
   		tileLookUp[k] = nil
	end

	if Bounds ~= nil then
		for num,quad in ipairs(Bounds) do
			table.remove(Bounds,num)
		end
	end
	TileW, TileH = 32,32
	--TilesetMap = love.graphics.newImage('assets/simpletiles1.png')
	if TilesetMap == nil then
		TilesetMap = love.graphics.newImage('assets/MapStringGenerator/stage1_tilesheet.png')
	end
	-- if roomnumber == 1 then
	-- 	local door = doorData:new()
	-- 	door.x = 49*32
	-- 	door.y = 7*32
	-- 	door.dest_x = 1*32
	-- 	door.dest_y = 2*32 
	-- 	door.offset = 32
	-- 	door.destination = 'assets/MapStringGenerator/firstmap.lua'
	-- 	door.number = 2
	-- 	table.insert(doorPositions, door)

	-- elseif roomnumber == 2 then
	-- 	local door = doorData:new()
	-- 	door.x = 1*32
	-- 	door.y = 2*32
	-- 	door.dest_x = 49*32
	-- 	door.dest_y = 7*32
	-- 	door.offset = -32
	-- 	door.destination = 'assets/MapStringGenerator/secondmap.lua'
	-- 	door.number = 1
	-- 	table.insert(doorPositions, door)
	-- 	local door2 = doorData:new()
	-- 	door2.x = 46*32
	-- 	door2.y = 19*32
	-- 	door2.dest_x = 1*32
	-- 	door2.dest_y = 20*32
	-- 	door2.offset = 32
	-- 	door2.destination = 'assets/MapStringGenerator/thirdmap.lua'
	-- 	door2.number = 3
	-- 	table.insert(doorPositions, door2)
	-- elseif roomnumber == 3 then
	-- 	local door = doorData:new()
	-- 	door.y = 20*32 -- middle of door
	-- 	door.x = 1*32
	-- 	door.dest_x = 46*32
	-- 	door.dest_y = 19*32
	-- 	door.offset = -32
	-- 	door.destination = 'assets/MapStringGenerator/firstmap.lua'
	-- 	door.number = 2
	-- 	table.insert(doorPositions, door)
	-- 	local door2 = doorData:new()
	-- 	door2.y = 6*32 -- middle of door
	-- 	door2.x = 49*32
	-- 	door2.dest_x = 4*32
	-- 	door2.dest_y = 4*32
	-- 	door2.offset = 32
	-- 	door2.destination = 'assets/MapStringGenerator/secondmap.lua'
	-- 	door2.number = 1
	-- 	table.insert(doorPositions, door2)
	-- end

-- 	local quadInfo = {
-- 	{'o',0,0}, -- background block
-- 	{'D',32,0}, -- destructable
-- 	{"2",64,0}, -- destructable2
-- 	{"1",64,32}, --  destructable 3
-- 	{'p', 32,32}, -- pushable block
-- 	{'b',0, 32} --  ground block
-- }
	--local quadInfo = getMapTileset("assets/MapStringGenerator/tiledmapdemo.lua","simpletiles1")
	local quadInfo = getMapTileset(map_path, "stage1_tilesheet")

	-- local tileString = [[
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
	-- boooooooooooooooooooooooooooob
	-- bbboooooooooooooooooooooooooob
	-- boooooooooooooooooooooooooooob
	-- boooooooooooooooooooooooooooob
	-- boooooooobbbbbboooooooobbbbbbb
	-- boooobboooooooooooobboooooooob
	-- boooooooooooooooooooooooooooob
	-- bbooooooooooooobooooooooooooob
	-- boooooooooooooooooooooooooooob
	-- boobbooooooooooooooobbooooooob
	-- bbbbbbbbbbbbbbbbbbbbbbbbboooob
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbooob
	-- oooooooooooooooooooooooooooooo
	-- bbbbbbbbbbbbbbbbbbbbbbbbbooobb
	-- oooooooooooooooooooooooooooooo
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbooob
	-- boooooooooooooooooooooooooooob
	-- booooooooooooooooooooooooooobb
	-- boooooooooooooooooooooooooobbb
	-- boooooooooooooooooooooooooooob
	-- boooooooobbbbbboooooooobbbbbbb
	-- boooobboooooooooooobboooooooob
	-- boooooooooooooooooooooooooooob
	-- bbooooooooooooobooooooooooooob
	-- boooooooooooooooooooooooooooob
	-- boobbooooooooooooooobbooooooob
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
	-- gggggggggggggggggggggggggggggg
	-- bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
	-- gggggggggggggggggggggggggggggg
	-- ]]

	local tileString = getMapString(map_path, "CollisionTiles", true)

	doorPositions = loadDoors(map_path)
	---------------------------------------
	-- Seperator
	---------------------------------------

	local tileSetW, tileSetH = TilesetMap:getWidth(), TilesetMap:getHeight()


	for _,info in ipairs(quadInfo) do
		Quads[info[1]] = love.graphics.newQuad(info[2],info[3],TileW,TileH,tileSetW,tileSetH)
	end

	local width = #(tileString:match("[^\n]+"))

	for x = 1, width, 1 do Tiletable[x] = {} end

	-- remove everything in array first
	local x, y = 1,1
	for row in tileString:gmatch("[^\n]+") do
	--for row in tileString do
		x = 1
		for character in row:gmatch(".") do 
			--if character == 'b' or character == 'o' or character == 'g' or character == 'z' then
			--if character ~= "!" then
			Tiletable[x][y] = "!"
			x = x+1
			--end
		end
		y = y+1
	end

	x, y = 1,1
	for row in tileString:gmatch("[^\n]+") do
		x = 1
		for character in row:gmatch(".") do 
			--if character == 'b' or character == 'o' or character == 'g' or character == 'z' then
			--if character ~= "!" then
			Tiletable[x][y] = character
			--if character == '#'
			x = x+1
			--end
		end
		y = y+1
	end
	loadMapColliders()
end


function drawMap()
	for columnIndex, column in ipairs(Tiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			if char ~= "!" and containedInWindowCanvas2(x,y) then
				love.graphics.draw(TilesetMap,Quads[char],x,y)
			end
		end
	end
	--drawDiagonalColliders()
end

-- function drawDiagonalColliders()
-- 	for columnIndex, column in ipairs(Tiletable) do
-- 		for rowIndex, char in ipairs(column) do
-- 			if char == '/' or char == "(" or char == ")" then
-- 				local graphic = love.graphics.newImage(TilesetMap,Quads[char])
-- 				local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
-- 				love.graphics.draw(graphic,x,y,0,1,1)
-- 			end
-- 		end
-- 	end
-- end

function loadDiagonalColliders()
	local diag = ("assets/diagonalblock.png")
	local diag1 =("assets/diag1.png")
	local diag2 = ("assets/diag2.png")
	local diagL = ("assets/diagonalblockL.png")
	local diag2L =("assets/diag1L.png")
	local diag1L = ("assets/diag2L.png")
	local b_ = ("assets/32x32.png")
	boxiterator = 0
	for columnIndex, column in ipairs(Tiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			if char == '/' or char == ')' or char == '(' then
				local img = nil
				if char == '/' then
					img = diag
				elseif char == "(" then
					img = diag1
				else img = diag2
				end
				local boxData = loadPixelCollisions(img,1,x,y,"R")
				boxData.descendFrom = "R"
				table.insert(diagonalBounds, boxData)
				tileLookUpDiag[columnIndex-1] = tileLookUpDiag[columnIndex-1] or {}
				tileLookUpDiag[columnIndex-1][rowIndex-1] = boxData
			end
			if char == '|' or char == "&" or char == "*" then
				local img = nil
				if char == '|' then
					img = diagL
				elseif char == "&" then
					img = diag1L
				else img = diag2L
				end
				local boxData = loadPixelCollisions(img,1,x,y,"L")
				boxData.descendFrom = "L"
				table.insert(diagonalBounds, boxData)
				tileLookUpDiag[columnIndex-1] = tileLookUpDiag[columnIndex-1] or {}
				tileLookUpDiag[columnIndex-1][rowIndex-1] = boxData
			end
			if char == '0' or char == "%" then
				local img = b_
				local boxData = nil
				if char == '0' then
					boxData = loadPixelCollisions(img,1,x,y,"I")
					boxData.descendFrom = "R"
				else 
					boxData = loadPixelCollisions(img,1,x,y,"I")
					boxData.descendFrom = "L"
				end
				table.insert(diagonalBounds, boxData)
				tileLookUpDiag[columnIndex-1] = tileLookUpDiag[columnIndex-1] or {}
				tileLookUpDiag[columnIndex-1][rowIndex-1] = boxData
			end

		end
	end
end


function loadMapColliders()
	boxiterator = 0
	for num,quad in ipairs(Bounds) do
		table.remove(Bounds,num)
	end

	for k in pairs(Bounds) do
   		Bounds[k] = nil
	end
	for columnIndex, column in ipairs(Tiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + TileH}
			if char ~= "!" and char ~= '`'and not (char == '/' or char == ')' or char == '(' or char == '|' or char == "&" or char == "*" ) and char ~= 'p' and char~='_' and char ~= '0' and char ~= '%' then -- not blank, diagonals, or oneways
				table.insert(Bounds, boxData)
				boxiterator = boxiterator + 1
				tileLookUp[columnIndex-1] = tileLookUp[columnIndex-1] or {}
				tileLookUp[columnIndex-1][rowIndex-1] = boxData
			end
		end
	end
	print("BOUDS = " , boxiterator)
	loadDiagonalColliders()
	loadOneWayColliders()
end

function loadOneWayColliders()
for columnIndex, column in ipairs(Tiletable) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			boxData = {x1 = x, y1 = y, x2 = x + TileW, y2 = y + 6}
			if char == 'p' then
				table.insert(onewayBounds, boxData)
			elseif char == '_' then
				boxData.y1 = y + TileH - 6
				boxData.y2 = y+TileH
				table.insert(onewayBounds,boxData)
			end
		end
	end
end


function loadMapBackground(map_path)
	if BackgroundTile ~= nil then
		for num,quad in ipairs(BackgroundTile) do
			table.remove(BackgroundTile,num)
		end
	end
	BackgroundTile = {}
	local tileString = getMapString(map_path, "BackgroundTiles")
	---------------------------------------
	-- Seperator
	---------------------------------------

	local width = #(tileString:match("[^\n]+"))

	for x = 1, width, 1 do BackgroundTile[x] = {} end

	local x, y = 1,1
	for row in tileString:gmatch("[^\n]+") do
		x = 1
		for character in row:gmatch(".") do 
			--if character == 'b' or character == 'o' or character == 'g' or character == 'z' then
			--if character ~= "!" then
			BackgroundTile[x][y] = character
			x = x+1
			--end
		end
		y = y+1
	end
end

function drawBackground()
	for columnIndex, column in ipairs(BackgroundTile) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			if char ~= "!" and containedInWindowCanvas2(x,y) then
				love.graphics.draw(TilesetMap,Quads[char],x,y)
			end
		end
	end
end

function loadMapForeground(map_path)
	if ForegroundTile ~= nil then
		for num,quad in ipairs(ForegroundTile) do
			table.remove(ForegroundTile,num)
		end
	end
	ForegroundTile = {}
	local tileString = getMapString(map_path, "ForegroundLayer")
	---------------------------------------
	-- Seperator
	---------------------------------------

	local width = #(tileString:match("[^\n]+"))

	for x = 1, width, 1 do ForegroundTile[x] = {} end

	local x, y = 1,1
	for row in tileString:gmatch("[^\n]+") do
		x = 1
		for character in row:gmatch(".") do 
			--if character == 'b' or character == 'o' or character == 'g' or character == 'z' then
			--if character ~= "!" then
			ForegroundTile[x][y] = character
			x = x+1
			--end
		end
		y = y+1
	end
end

function drawForeground()
	for columnIndex, column in ipairs(ForegroundTile) do
		for rowIndex, char in ipairs(column) do
			local x,y = (columnIndex-1)*TileW, (rowIndex-1)*TileH
			if char ~= "!" then
				if char ~= "" and containedInWindowCanvas2(x,y) then
					love.graphics.draw(TilesetMap,Quads[char],x,y)
				end
			end
		end
	end
end
