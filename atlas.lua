local ATLAS = {}

ATLAS.INFO = 
{
    { width = 1, mx = 0, my = 0, offx = 00, len = 5 },
    { width = 2, mx = 0, my = 17, offx = 01, len = 5 },
    { width = 1, mx = 0, my = 17*2, offx = 03, len = 5 },
    { width = 3, mx = 0, my = 17*3, offx = 04, len = 5 },
    { width = 1, mx = 0, my = 17*4, offx = 07, len = 5 },
    { width = 2, mx = 0, my = 17*5, offx = 08, len = 5 },
    { width = 1, mx = 0, my = 17*6, offx = 10, len = 5 },
}

function ATLAS.draw_walls(atlas)
    for ix = 1, #atlas do
        -- Cell A
        cell = ATLAS.INFO[ix]
        map(cell.mx + atlas[ix] * cell.width, cell.my, cell.width, 14, cell.offx * 8, 0, 0)
    end
end

function ATLAS.debug_walls(atlas)
    for i=1,#atlas do
        print(atlas[i], 8 * (ATLAS.INFO[i].offx), 8*16, COLOR.WHITE)
    end
end

function ATLAS.test_mode(ix, view)
    if btnp(0) then view[ix]=view[ix]+1 end
    if btnp(1) then view[ix]=view[ix]-1 end
    if view[ix] < 1 then view[ix] = 0 end
    if btnp(2) then ix=ix-1 end
    if btnp(3) then ix=ix+1 end
    
    if ix <= 0 then ix = #view elseif ix > #view then ix = 1 end
    cls(COLOR.BLACK)
    for i=1,#view do
        if i == ix then
            print(view[i], 16 * i - 1, 8*16, COLOR.YELLOW)
        else
            print(view[i], 16 * i - 1, 8*16, COLOR.WHITE)
        end
    end
    ATLAS.draw_walls(view)
    return ix
end

return ATLAS
