pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Puzzle 10
-- by Tipa

function _init()

    sprite_data = {0, 0, 2, 2, 2, 2, 6, 6, 11, 11, 9, 9, 28, 28, 16, 16, 19, 19, 17, 17, 21, 21, 21, 21, 21, 24, 24, 16, 16, 31, 31, 32, 
    32, 32, 32, 38, 38, 37, 37, 37, -1, -1, -1, 9, 9, 4, 4, 4, 7, 7, 9, 9, 16, 16, 16, 16, 19, 19, 19, 21, 21, 24, 24, 22, 
    22, 24, 24, 31, 31, 31, 31, 40, 40, 40, 28, 28, 28, 39, 39, 1, 1, 1, 1, 1, 6, 6, 11, 11, 11, 11, 11, 14, 14, 2, 2, 16, 
    16, 16, 17, 17, 20, 20, 21, 21, 26, 26, 30, 30, 31, 31, 31, 31, 31, 31, 31, 22, 22, 39, 39, 0, 0, 38, 38, 30, 30, 4, 4, 7, 7, 11, 11, 27, 27, 27, 16, 16, 19, 19, 19, 21, 21, 24, 24, 22, 22, 24, 24, 24, 37, 37, 29, 29, 29, 36, 36, 31, 31, 
    39, 39, -1, -1, 15, 15, 6, 6, 6, -1, -1, 7, 7, 9, 9, 16, 16, 16, 16, 1, 1, 17, 17, 19, 19, 24, 24, 26, 26, 6, 6, 18, 18, 29, 29, 37, 37, 36, 36, 39, 39, 39, 0, 0, 2, 2, 2, 7, 7, 7, 7, 7, 11, 11, 12, 12, 12, 12, 14, 14, 19, 19, 21, 21, 22, 22, 26, 26, 25, 25, 27, 27, 27, 29, 29, 29, 37, 37, 37, 37, 37, 27, 27}

    beam_pos = 0

    title_screen = true
end

function _draw()
    cls()
    
    if title_screen then
        display_title_screen()
        return
    end

    print ("puzzle 10", 0, 0, 7)
    print ("sprite data length " .. #sprite_data, 0, 8, 7)
    print ("press ❎ to restart", 0, 16, 7)

    pixels_per_line = 40

    block_width = flr(128 / pixels_per_line)
    line_x = (128 - pixels_per_line * block_width)/2

    top = (128 - 6 * block_width)/2

    sprite_width = 3 * block_width
    sprite_x = sprite_data[beam_pos + 1]
    sprite_pos = line_x + sprite_x * block_width
    rectfill(sprite_pos, top, sprite_pos + sprite_width, top + 6 * block_width, 2)

    for pixel = 0, beam_pos do
        sprite_x = sprite_data[pixel + 1]
        pixel_x = pixel % pixels_per_line
        pixel_y = flr(pixel / pixels_per_line)
        -- sprite_x is between pixel_x - 1 and pixel_x + 1 inclusive
        if (sprite_x >= pixel_x - 1) and (sprite_x <= pixel_x + 1) then
            spr(1, line_x + pixel_x * block_width, top + pixel_y * block_width)
        else
            spr(0, line_x + pixel_x * block_width, top + pixel_y * block_width)
        end
    end

end

function talktalk(msgs)
    banner_height = 8 * #msgs
    for i=1, #msgs do
        print(msgs[i], 64 - #msgs[i]*2, 64 - banner_height/2 + (i-1)*8, 7)
    end
end

function display_title_screen()
    cls(0)

    for x=0, 16 do
        for y=0, 16 do
            spr(2, x*8, y*8)
        end
    end

    -- set random seed
    srand(123)

    rectfill(8, 8, 128-9, 128-9, 0)
    msgs = { "cathode-ray tube", "advent of code 2022.10", "by", "tipa", "", "crack the code", "", "press ❎ to start" }
    talktalk(msgs)
end


function _update()
    if title_screen then
        -- if user presses 'x' restart the game
        if btnp(❎) then
            title_screen = false
            beam_pos = 0
        end
        return
    end

    beam_pos = min(beam_pos + 1, #sprite_data-1)

    if btnp(❎) then
        beam_pos = 0
    end
end
__gfx__
000000003b30000015aaaa5100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbb000005aaaaaa500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003b300000aa8aa8aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000aa8aa8aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000aa8aa8aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005aa88aa500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000015aaaa5100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
