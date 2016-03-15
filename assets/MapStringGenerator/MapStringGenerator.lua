local sti = require "sti"

function getMapString()

    -- Load a map exported to Lua from Tiled
    map = sti.new("assets/testmap.lua")

    -- Create a Custom Layer
    --map:addCustomLayer("Sprite Layer", 3)

    -- Add data to Custom Layer
    local tileLayer = map.layers["Tile Layer 1"]
    --local itemLayer = map.layers["BlocksAndPushables"]
    local mapString = [[]]
    --for _,layers in ipairs(tileLayer) do
    local tileData = tileLayer.data
    for y = 0,100 do
        for x = 0,100 do
            if tileData[y][x] ~= nil then
                --mapString = mapString .. tileData[y][x].properties["tilevalue"]
                mapString = mapString .. "b"
            else
                mapString = mapString .. "z"
            end
        end
        mapString = mapString .. "\n"
    end
    return mapString
end