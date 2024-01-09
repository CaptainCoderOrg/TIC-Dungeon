local DIR = require("dir")
local MINIMAP = {}

MINIMAP.sprites = {
    player = 257,
    wall = 1,
    floor = 2
}

function MINIMAP.draw(player, r, offx, offy)
    local x = player.x - r
    local y = player.y - r
    local d = r*2
    local roff = r*8
    map(x, y, d, d, offx, offy, 0)
    spr(MINIMAP.sprites.player, offx + roff, offy + roff, 0, 1, 0, player.dir)
end

function MINIMAP.is_wall(pos)
    local id = mget(pos.x, pos.y)
    return id == MINIMAP.sprites.wall
end

function MINIMAP.build_atlas(player)
    local view = visible_cells(player)
    local A = cell_a(view)
    local B = cell_b(view)
    local C = cell_c(view)
    local D = cell_d(view)
    local E = cell_e(view)
    local F = cell_f(view)
    local G = cell_g(view)
    return {A, B, C, D, E, F, G}
end

function visible_cells(player)
    local v = {}
    local forward = Player.dir
    local left = DIR.rotate_ccw(Player.dir)
    local right = DIR.rotate_cw(Player.dir)
    v.f = DIR.step(Player, forward)
    v.l = DIR.step(Player, left)
    v.fl = DIR.step(v.f, left)
    v.r = DIR.step(Player, right)
    v.fr = DIR.step(v.f, right)
    v.ff = DIR.step(v.f, forward)
    v.ffl = DIR.step(v.ff, left)
    v.ffr = DIR.step(v.ff, right)
    v.fff = DIR.step(v.ff, forward)
    v.fffl = DIR.step(v.fff, left)
    v.fffr = DIR.step(v.fff, right)
    -- This is the view from the player's perspective
    -- where p is the player looking forward
    -- fffl, fff, fffr
    --  ffl,  ff,  ffr,
    --   fl,   f,   fr,
    --    l,   p,    r
    return v
end

function cell_a(view)
    if MINIMAP.is_wall(view.l) then return 1 end
    if MINIMAP.is_wall(view.fl) then return 2 end
    if MINIMAP.is_wall(view.ffl) then return 3 end
    if MINIMAP.is_wall(view.fffl) then return 4 end
    return 0
end

function cell_b(view)
    if MINIMAP.is_wall(view.f) then return 2 end
    if MINIMAP.is_wall(view.fl) then return 1 end
    if MINIMAP.is_wall(view.ffl) then return 3 end
    if MINIMAP.is_wall(view.fffl) then return 4 end
    return 0
end

function cell_c(view)
    if MINIMAP.is_wall(view.f) then return 2 end
    if MINIMAP.is_wall(view.ff) then return 3 end
    if MINIMAP.is_wall(view.ffl) then return 1 end
    if MINIMAP.is_wall(view.fffl) then return 4 end    
    return 0
end

function cell_d(view)
    if MINIMAP.is_wall(view.f) then return 1 end
    if MINIMAP.is_wall(view.ff) then return 2 end
    if MINIMAP.is_wall(view.fff) then return 3 end
    return 0
end

function cell_e(view)
    if MINIMAP.is_wall(view.f) then return 2 end
    if MINIMAP.is_wall(view.ff) then return 3 end
    if MINIMAP.is_wall(view.ffr) then return 1 end
    if MINIMAP.is_wall(view.fffr) then return 4 end
    return 0
end

function cell_f(view)
    if MINIMAP.is_wall(view.f) then return 2 end
    if MINIMAP.is_wall(view.fr) then return 1 end
    if MINIMAP.is_wall(view.ffr) then return 3 end
    if MINIMAP.is_wall(view.fffr) then return 4 end
    return 0
end

function cell_g(view)
    if MINIMAP.is_wall(view.r) then return 1 end
    if MINIMAP.is_wall(view.fr) then return 2 end
    if MINIMAP.is_wall(view.ffr) then return 3 end
    if MINIMAP.is_wall(view.fffr) then return 4 end
    return 0
end

return MINIMAP