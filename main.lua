debug = true

--require( "tablesave.lua" )
require 'physics1'
require 'map1-functions'
require 'itemmap'
require 'charactercontroller'
require 'shooter'
require 'metroidcamera'
love.filesystem.load("acca.lua")
require 'enemystate'

--some player variables
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax




function love.load(arg)
	ingame = false
	if ingame then
	else
		retrofont = love.graphics.newFont("assets/retrofont.ttf", 15)
		cursorimg = love.graphics.newImage("itemimg/Dagger/01.png")
		cursorPosition = 2
		loadPage = 1
		-- love.graphics.setFont(font)
		-- love.graphics.printf("You have obtained the\nRing of Power\n\nYou can now push blocks", windowSize.x/2-120, windowSize.y/2-60, windowSize.y/2, 'center')
	end

end

function loadGame(loadtable)
		background = love.graphics.newImage("assets/background1.png")
	-- background2 = love.graphics.newImage("assets/background2.png")
	-- camera:newLayer(0,function()
	-- 	love.graphics.draw(background,0,0,0,1,1)
	-- 	end)
	-- camera:newLayer(1,function()
	-- 	love.graphics.draw(background2,0,0,0,1,1)
	-- 	end)
	local loadPlayer = true

	if loadtable ~= nil and fileExists(loadtable) then
		player = table.load(loadtable)
		loadPlayer = false
	end

	character_controller:load(arg, loadPlayer)




	shooter:load(arg)
	camera:load(arg)
	metroidcamera:load(arg)
	--startmap = 'assets/MapStringGenerator/MapScripts/entryroom.lua'
	startmap = 'assets/MapStringGenerator/MapScripts/bonfireroom1.lua'
	if loadPlayer then
		--startmap = 'assets/MapStringGenerator/MapScripts/bonfireroom1.lua'
		startmap = 'assets/MapStringGenerator/MapScripts/entryroom.lua'
	else
		startmap = player.respawnRoom
	end

	player.respawnPoint.x = player.x
	player.respawnPoint.y = player.y
	player.respawnRoom = startmap



	loadMap(startmap)
	loadMapBackground(startmap)
	loadMapForeground(startmap)
	loadItemMap(startmap)
	loadEnemies(startmap)
	-- playerImg = nil
	-- playerImg = love.graphics.newImage('assets/aircrafts.png')
	bulletImg = nil
	bullets = {}

	debugTools.startTimer = love.timer.getTime()
	ingame = true
end

function reloadMaps(map_path, door, isRespawn)
	loadMap(map_path)
	loadMapBackground(map_path)
	loadMapForeground(map_path)
	loadItemMap(map_path)
	loadEnemies(map_path)
	player.speed = 0
	if not isRespawn then
		if door.position == "left" then
			for _,d in ipairs(doorPositions) do
				if d.position == "right" then
					player.x = d.x - 48
					player.y = d.y-64
				end
			end
		else
			for _,d in ipairs(doorPositions) do
				if d.position == "left" then
					player.x = d.x + 8
					player.y = d.y-64
				end
			end
		end
	else
		player.x = player.respawnPoint.x
		player.y = player.respawnPoint.y
	end

	--player.x = door.dest_x + door.offset
	--player.y = door.dest_y - 32
end
function love.update(dt)
	if ingame then
		if not ring.obtained and not vendorMenu.interacting then
			character_controller:update(dt)
			local doorBool, doorData  = getDoorPosition()
			if doorBool then
				reloadMaps(doorData.destination,doorData)
			end

			if player.health == 0 then
				debugTools.deathCounter = debugTools.deathCounter + 1
				-- local door = nil
				-- for _,d in ipairs(doorPositions) do
				-- 	if d.position == "left" then
				-- 		door = d
				-- 	end
				-- end
				reloadMaps(player.respawnRoom,nil,true)
				player.health = player.healthMax
				player.hurt = false
			end
			button.button1.class:update(dt)
			metroidcamera:update(dt)
			checkBlowUpBoxes(dt)
			updateEnemies(dt)
			if love.keyboard.isDown('1') then
				deletePushableBlocks()
				loadItemMap()
			end
		end
	else
		if cursorPosition == 2 and love.keyboard.isDown('return') and loadPage == 1 then
			loadPage = 2
		end

	end


end
function love.draw(dt)
	if ingame then
		love.graphics.draw(background,0,0,0,1,1)
		camera:set()
		--camera:draw()
		love.graphics.setDefaultFilter("linear", "linear")
		drawBackground()
		love.graphics.setDefaultFilter("linear", "linear")
		drawMap()
		love.graphics.setDefaultFilter("linear", "linear")
		drawItemMap()
		drawParticle()
		reDrawPushables()
		drawEnemies(dt)
		character_controller:draw()
		drawRespawn()
		drawForeground()
		button.button1.class:draw()
		--drawDebug()
		camera:unset()
		character_controller:drawHUD(dt)
		if ring.obtained then
			character_controller:drawRingBox()
		end
		if vendorMenu.interacting then
			character_controller:drawVendorMenu()
		end
	else
		if loadPage ==1 then
			love.graphics.setFont(retrofont)
			love.graphics.printf("Game Start", windowSize.x/2-120, windowSize.y/2-60, windowSize.y/2, 'center')
			love.graphics.printf("Exit", windowSize.x/2-120, windowSize.y/2, windowSize.y/2, 'center')
			love.graphics.draw(cursorimg,windowSize.x/2-80, windowSize.y/2-60*(cursorPosition-1),0,1,1)
		elseif loadPage == 2 then
			love.graphics.setFont(retrofont)
			local _loadfile = "/Users/alex/Documents/Game/gamesaves/gamesave1.lua"
			if fileExists(_loadfile) then
				love.graphics.printf("Load Game", windowSize.x/2-120, windowSize.y/2-60, windowSize.y/2, 'center')
				love.graphics.printf("New Game", windowSize.x/2-120, windowSize.y/2, windowSize.y/2, 'center')
			else
				love.graphics.printf("New Game", windowSize.x/2-120, windowSize.y/2-60, windowSize.y/2, 'center')
				love.graphics.printf("New Game", windowSize.x/2-120, windowSize.y/2, windowSize.y/2, 'center')
			end
			love.graphics.draw(cursorimg,windowSize.x/2-80, windowSize.y/2-60*(cursorPosition-1),0,1,1)
		end
	end
end

function KeyPressGameStart(key)
	if key == 's' then
		cursorPosition = 1
	end
	if key == 'w' then
		cursorPosition = 2
	end
	if key == 'return' and loadPage == 2 then
		local _loadfile = "/Users/alex/Documents/Game/gamesaves/gamesave1.lua"
		if fileExists(_loadfile) then
			loadGame(_loadfile)
		else
			loadGame()
		end
	end
end

function table.load( sfile )
  local ftables,err = loadfile( sfile )
  if err then return _,err end
  local tables = ftables()
  for idx = 1,#tables do
     local tolinki = {}
     for i,v in pairs( tables[idx] ) do
        if type( v ) == "table" then
           tables[idx][i] = tables[v[1]]
        end
        if type( i ) == "table" and tables[i[1]] then
           table.insert( tolinki,{ i,tables[i[1]] } )
        end
     end
     -- link indices
     for _,v in ipairs( tolinki ) do
        tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
     end
  end
  return tables[1]
end
function tableSave(filename)
	table.save( player , filename )

end

function table.save(  tbl,filename )

	print(fileExists(filename))
  if not fileExists(filename) then
 	createFile(filename)
  end

  local charS,charE = "   ","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
     file:write( "-- Table: {"..idx.."}"..charE )
     file:write( "{"..charE )
     local thandled = {}

     for i,v in ipairs( t ) do
        thandled[i] = true
        local stype = type( v )
        -- only handle value
        if stype == "table" then
           if not lookup[v] then
              table.insert( tables, v )
              lookup[v] = #tables
           end
           file:write( charS.."{"..lookup[v].."},"..charE )
        elseif stype == "string" then
           file:write(  charS..exportstring( v )..","..charE )
        elseif stype == "number" then
           file:write(  charS..tostring( v )..","..charE )
        end
     end

     for i,v in pairs( t ) do
        -- escape handled values
        if (not thandled[i]) then
        
           local str = ""
           local stype = type( i )
           -- handle index
           if stype == "table" then
              if not lookup[i] then
                 table.insert( tables,i )
                 lookup[i] = #tables
              end
              str = charS.."[{"..lookup[i].."}]="
           elseif stype == "string" then
              str = charS.."["..exportstring( i ).."]="
           elseif stype == "number" then
              str = charS.."["..tostring( i ).."]="
           end
        
           if str ~= "" then
              stype = type( v )
              -- handle value
              if stype == "table" then
                 if not lookup[v] then
                    table.insert( tables,v )
                    lookup[v] = #tables
                 end
                 file:write( str.."{"..lookup[v].."},"..charE )
              elseif stype == "string" then
                 file:write( str..exportstring( v )..","..charE )
              elseif stype == "number" then
                 file:write( str..tostring( v )..","..charE )
              end
           end
        end
     end
     file:write( "},"..charE )
  end
  file:write( "}" )
  file:close()
end

function exportstring( s )
    return string.format("%q", s)
end

function createFile(filename)
	file = io.open(filename, "w")
end

function fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

--// The Load Function
function table.load( sfile )
  local ftables,err = loadfile( sfile )
  if err then return _,err end
  local tables = ftables()
  for idx = 1,#tables do
     local tolinki = {}
     for i,v in pairs( tables[idx] ) do
        if type( v ) == "table" then
           tables[idx][i] = tables[v[1]]
        end
        if type( i ) == "table" and tables[i[1]] then
           table.insert( tolinki,{ i,tables[i[1]] } )
        end
     end
     -- link indices
     for _,v in ipairs( tolinki ) do
        tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
     end
  end
  return tables[1]
end