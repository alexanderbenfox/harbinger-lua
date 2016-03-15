local sti = require "assets/MapStringGenerator/sti"

layerInfo ={}
layerInfo.layerWidth = 0
layerInfo.layerHeight = 0

local map_loaded = false
local map = nil

function getMapString(map_path, layer_name, main_layer)

    -- Load a map exported to Lua from Tiled
    if not map_loaded then
        map = sti.new(map_path, nil)
        map_loaded = true
    end

    -- Create a Custom Layer
    --map:addCustomLayer("Sprite Layer", 3)

    -- Add data to Custom Layer
    local tileLayer = map.layers[layer_name]
    --local itemLayer = map.layers["BlocksAndPushables"]
    local mapString = [[]]
    if tileLayer == nil then
        return mapString .. "!"
    end
    --for _,layers in ipairs(tileLayer) do
    local tileData = tileLayer.data
    for y = 1,tileLayer.height do
        for x = 1,tileLayer.width do
            if tileData[y][x] ~= nil then
                mapString = mapString .. tileData[y][x].properties["tilechar"]
                --mapString = mapString .. "b"
            else
                mapString = mapString .. "z"
            end
        end
        mapString = mapString .. "\n"
    end



    --set up the layer info for the camera
    if main_layer then
        layerInfo.layerHeight = tileLayer.height*32
        layerInfo.layerWidth = tileLayer.width*32
    end

    return mapString
end

function resetMap()
    map_loaded = false
    map = nil
end

function loadDoors(map_path)
    if not map_loaded then
        map = sti.new(map_path, nil)
        map_loaded = true
    end
    
    local doorObjects = map.layers["Door Layer"].objects
    local doors = {}

    for _,obj in ipairs(doorObjects) do
        local door = {}
        door.x = obj.x
        door.y = obj.y
        door.width = obj.width
        door.height = obj.height
        door.destination = obj.properties["destination"]
        door.position = obj.properties["position"]
        --if door.position == "right" then door.x = door.x - door.width end
        table.insert(doors,door)
        print(door.x)
    end

    return doors
end

function getMapTileset(map_path, tileset_name)

        -- Load a map exported to Lua from Tiled
    if not map_loaded then
        map = sti.new(map_path, nil)
        map_loaded = true
    end

    -- Create a Custom Layer
    --map:addCustomLayer("Sprite Layer", 3)

    -- Add data to Custom Layer
    local tileset = nil
    for _,tiles in ipairs(map.tilesets) do
        if tiles.name == tileset_name then
            tileset = tiles
        end
    end

    if tileset == nil then
        return
    end


    local quadInfo = {}
    local function getTiles(i, t, m, s)
        i = i - m
        local n = 0

        while i >= t do
            i = i - t
            if n ~= 0 then i = i - s end
            if i >= 0 then n = n + 1 end
        end

        return n
    end

    local quad = love.graphics.newQuad
    local mw   = 32
    local iw   = tileset.imagewidth
    local ih   = tileset.imageheight
    local tw   = tileset.tilewidth
    local th   = tileset.tileheight
    local s    = tileset.spacing
    local m    = tileset.margin
    local w    = getTiles(iw, tw, m, s)
    local h    = getTiles(ih, th, m, s)

    local tileinfo = tileset.tiles
    local charlist = {}

    for _,tile in ipairs(tileinfo) do
        if tile.properties["tilechar"] ~= nil then
            table.insert(charlist,tile.properties["tilechar"])
        else table.insert(charlist,"!")
            print("ha")
        end

    end

    for y = 1,h do
        for x = 1,w do
            local char = table.remove(charlist,1)
            local info = {char,(x-1)*32,(y-1)*32}
            table.insert(quadInfo,info)
        end
    end

    return quadInfo

end

function getMapQuads()
end