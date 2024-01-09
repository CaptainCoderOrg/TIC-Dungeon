local DIR = {}
local LABELS = { "NORTH", "EAST", "SOUTH", "WEST" }
DIR.N = 0
DIR.E = 1
DIR.S = 2
DIR.W = 3

function DIR.opposite(dir)
    return (dir + 2) % 4
end

function DIR.rotate_cw(dir)
    return (dir + 1) % 4
end

function DIR.rotate_ccw(dir)
    return (dir + 3) % 4
end

function DIR.label(dir)
    return LABELS[dir % 4 + 1]
end

function DIR.step(pos, dir)
	if dir == DIR.N then return { x = pos.x, y = pos.y - 1 } end
	if dir == DIR.S	then return { x = pos.x, y = pos.y + 1 } end
	if dir == DIR.E then return { x = pos.x + 1, y = pos.y } end
	if dir == DIR.W then return { x = pos.x - 1, y = pos.y } end
    error("Invalid step: " .. dir)
end

return DIR