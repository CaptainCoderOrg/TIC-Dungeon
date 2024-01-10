MAP = require("minimap")
local generator = {}

local SPRITE_ADDR = 0x06000
local WALL = 1
local FLOOR = 2
local DOOR = 3

local BLUEPRINTS = {
    lrg_rm = { id = 496 },
    med_rm = { id = 497 },
    sml_rm = { id = 498 },
    ew_hall = { id = 499 },
    ns_hall = { id = 500 },
    t_hall = { id = 501 },
    x_hall = { id = 502 },
}

local CONNECTIONS = nil
local OPPOSITE = { ["NORTH"] = "SOUTH", ["EAST"] = "WEST", ["SOUTH"] = "NORTH", ["WEST"] = "EAST"}
function connections()
    if CONNECTIONS == nil then
        CONNECTIONS = { ["NORTH"] = {}, ["EAST"] = {}, ["SOUTH"] = {}, ["WEST"] = {}, }
        for _, blueprint in pairs(BLUEPRINTS) do
            local room = generator.build_room(blueprint)
            for _,conn in ipairs(room.connections) do
                table.insert(CONNECTIONS[OPPOSITE[conn.dir]], { blueprint = blueprint, pos = conn.pos })
            end
        end
    end
    return CONNECTIONS
end


local CONNECTOR = { "NORTH", "EAST", "SOUTH", "WEST"}

local TILE = {
    [1] = DOOR,
    [2] = DOOR,
    [3] = DOOR,
    [4] = DOOR,
    [15] = WALL,
    [13] = FLOOR,
}

local offset = 0
local x = 0
local y = 0
local base = nil
local top = 0
local left = 90
local last_p = { x = 0, y = 0 }
function generator.debug()
    if btnp(4) then 
        if base ~= nil then
            generator.clear_map(base, left, top)
        end
        base = generator.build_room(BLUEPRINTS.lrg_rm) 
        local result = generator.add_room(base)
        while result do 
            result = generator.add_room(base)
        end
        generator.place_room(base, left, top)
    end
    if btn(0) then y = y - 1 end
    if btn(1) then y = y + 1 end
    if btn(2) then x = x - 1 end
    if btn(3) then x = x + 1 end

    local mx = x // 8
    local my = y // 8
    local rx = x % 8
    local ry = y % 8

    -- if btnp(4) or btn(5) then
    --     local success = generator.add_room(base)
    --     generator.place_room(base, 90, 0)
    -- end
    
    -- MAP.draw({ x = 90, y = 0 }, 10, 14 * 8, 8)
    cls(0)
    map(90 + mx, my, 30, 17, -rx, -ry)
    
end

function generator.add_room(base)
    if #base.connections == 0 then return false end
    local next_conn = table.remove(base.connections)
    last_p = next_conn.pos
    local chance = math.random(1, next_conn.depth)
    if chance > 1 then 
        base.set_tile(next_conn.pos, WALL)
        return true
    end
    local options = connections()[next_conn.dir]
    local option = options[math.random(1, #options)]
    local to_add = generator.build_room(option.blueprint, next_conn.depth + 1)
    generator.merge_rooms(base, next_conn.pos, to_add, option.pos)
    return true
end

function generator.merge_rooms(base, bpos, to_add, apos)
    local xoff = apos.x - bpos.x
    local yoff = apos.y - bpos.y
    trace("Merging...")
    for _,conn in pairs(to_add.connections) do
        local _cp= p(conn.pos.x-xoff, conn.pos.y-yoff)
        if base.tiles[_cp] == nil then
            table.insert(base.connections, { pos = _cp, dir = conn.dir, depth = conn.depth })
        end
    end
    for pos,tile in pairs(to_add.tiles) do
        local _pos = p(pos.x - xoff, pos.y - yoff)
        -- if base.tiles[_pos] ~= nil then
            -- trace(_pos.x .. ", " .. _pos.y .. " skipped: " .. base.tiles[_pos])
        -- end
        if base.tiles[_pos] == nil then
            base.set_tile(_pos, tile)
        end
    end
    base.set_tile(bpos, FLOOR)
    local count = 0
    for pos, tile in pairs(base.tiles) do
        count = count + 1
    end
    trace("Merge complete: " .. count)
    
end

local phash = {}
function p(x, y) 
    local hash = x  + y * 1000
    if phash[hash] == nil then
        phash[hash] = { x = x, y = y}
    end
    return phash[hash]
end

function generator.build_room(blueprint, depth)
    if depth == nil then depth = 1 end
    local room = { tiles = {}, connections = {} }
    local ADDR = SPRITE_ADDR * 2 + (blueprint.id - 256) * 64
    room.set_tile = function (pos, tile)
        if tile ~= nil then 
            room.tiles[pos] = tile
        end
    end

    room.set_data = function (pos, data)
        if TILE[data] ~= nil then
            room.tiles[pos] = TILE[data]
        end
        if CONNECTOR[data] ~= nil then
            table.insert(room.connections, { pos = pos, dir = CONNECTOR[data], depth = depth })
        end
    end

    for x = 0, 7 do
        for y = 0, 7 do
            local data = peek4(ADDR + x + y * 8)
            room.set_data(p(x, y), data)
        end
    end
    return room
end

function generator.place_room(room, mx, my)
    local MAP_HEIGHT = 136
    local MAP_WIDTH = 240
    for pos,tile in pairs(room.tiles) do
        local dy = (((my + pos.y) % MAP_HEIGHT) + MAP_HEIGHT) % MAP_HEIGHT
        local dx = (((mx + pos.x) % MAP_WIDTH) + MAP_WIDTH) % MAP_WIDTH
        if dx ~= mx + pos.x then 
            trace("x : " .. mx + pos.x .. " => " .. dx)
        end
        mset(dx, dy, tile)
    end
end

function generator.clear_map(room, mx, my)
    local MAP_HEIGHT = 136
    local MAP_WIDTH = 240
    for pos,tile in pairs(room.tiles) do
        local dy = (((my + pos.y) % MAP_HEIGHT) + MAP_HEIGHT) % MAP_HEIGHT
        local dx = (((mx + pos.x) % MAP_WIDTH) + MAP_WIDTH) % MAP_WIDTH
        mset(dx, dy, 0)
    end
end

return generator
