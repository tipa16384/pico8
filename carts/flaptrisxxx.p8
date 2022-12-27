pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Puzzle 10
-- by Tipa

function _init()
    -- initialize the game
    teeshape = {
        center={64, 64},
        spin=1,
        fn=sin,
        polys={
            {-48, -16, 48, -16, 48, 16, -48, 16},
            {-16, -48, 16, -48, 16, -12, -16, -12}
        }
    }

    crossshape = {
        center={64, -64-128},
        spin=3,
        fn=sin,
        polys={
            {-48, -16, 48, -16, 48, 16, -48, 16},
            {-16, -48, 16, -48, 16, 48, -16, 48}
        }
    }

    elshape = {
        center={64, -64},
        spin=0.5,
        fn=cos,
        polys={
            {-48, -16, 48, -16, 48, 16, -48, 16},
            {48, 16, 16, 16, 16, 48, 48, 48}
        }
    }

    tetrads = {
        teeshape,
        elshape,
        crossshape
    }

    player = { pos = {0, 0}, size = { 24, 32 }, velocity = {0, 0}, flap_power=0.5, drag=0.1, max_velocity=3, gravity=0.3 }
    square_angle = 0
    collision = false
    game_over = false
    game_start = false
    scroll_y = 0
    frames_per_scroll = 1
    frame = 0
end

function no_move(angle)
    return 0
end

function _update()
    -- update the game
    square_angle += 0.005

    if game_over then
        _init()
        return
    end

    player.pos[1] = player.pos[1] + player.velocity[1]
    player.pos[2] = player.pos[2] + player.velocity[2]

    if not game_start then
        player.pos[1] = min(max(player.pos[1], (player.size[1]-128)/2), (128-player.size[1])/2)
        player.pos[2] = min(max(player.pos[2], player.size[2]-128), 0)
    else
        frame += 1
        if frame >= frames_per_scroll then
            scroll_y += 1
            frame = 0
        end
    end

    -- if left arrow
    if not collision and not game_over then
        if btn(⬅️) then
            player.velocity[1] = max(player.velocity[1] - player.flap_power, -player.max_velocity)
        end
        if btn(➡️) then
            player.velocity[1] = min(player.velocity[1] + player.flap_power, player.max_velocity)
        end
        if btn(⬆️) then
            player.velocity[2] = max(player.velocity[2] - player.flap_power, -player.max_velocity)
        end
        if btn(⬇️) then
            player.velocity[2] = min(player.velocity[2] + player.flap_power, player.max_velocity)
        end
    end

    if collision and not game_over then
        player.velocity[2] = player.velocity[2] + player.gravity
    else
        player.velocity[2] = min(player.velocity[2] + player.gravity, player.max_velocity)
    end

    if not btn(⬅️) and not btn(➡️) then
        player.velocity[1] = player.velocity[1] * (1 - player.drag)
    end
    if not btn(⬆️) and not btn(⬇️) then
        player.velocity[2] = player.velocity[2] * (1 - player.drag)
    end
end

function _draw()
    -- draw the game
    cls(11)

    -- square is a table of vertices. rotate it by square_angle and assign it to a new table, then render it
    for i=1, #tetrads do
        local tetrad = tetrads[i]
        rotate_and_draw(tetrad, 2 + tetrad.fn(square_angle), 2 + scroll_y, square_angle, 3)
    end
    
    spr(8, (128-player.size[1])/2 + player.pos[1]+2, 128-player.size[2] + player.pos[2]+2, 4, 4)


    -- fill screen with 32x32 sprite at position 0
    for y=-1,3 do
        for x=0,3 do
            spr(0, x*32, y*32 + (scroll_y % 32), 4, 4)
        end
    end

    for i=1, #tetrads do
        local tetrad = tetrads[i]
        rotate_and_draw(tetrad, tetrad.fn(square_angle), scroll_y, square_angle, 8)
    end

    local player_at = { flr(128/2 + player.pos[1]), flr(128 + player.pos[2] - 16) }

    if not game_start then
        if player_at[2] < 112 then
            game_start = true
        end
    end

    if player_at[2] > 150 then
        game_over = true
    elseif player_at[1] < 0 or player_at[1] > 127 or player_at[2] < 0 or player_at[2] > 127 then
        collision = true
    elseif game_start and (peek(0x6000 + player_at[2] * 64 + flr(player_at[1]/2), 1) & 0xf == 8) then
        collision = true
    end

    if game_over then
        print("game over", 0, 0, 8)
    elseif collision then
        print("collision", 0, 0, 9)
    elseif game_start then
        print ("game start", 0, 0, 7)
    end

    print (flr(player_at[1])..", "..flr(player_at[2]), 0, 8, 0)

    spr(4, (128-player.size[1])/2 + player.pos[1], 128-player.size[2] + player.pos[2], 4, 4)


end

function get_intersect(px1, py1, px2, py2, sx1, sy1, sx2, sy2)
    local s1x, s1y, s2x, s2y
    s1x = px2 - px1
    s1y = py2 - py1
    s2x = sx2 - sx1
    s2y = sy2 - sy1

    local s, t
    s = (-s1y * (px1 - sx1) + s1x * (py1 - sy1)) / (-s2x * s1y + s1x * s2y)
    t = ( s2x * (py1 - sy1) - s2y * (px1 - sx1)) / (-s2x * s1y + s1x * s2y)

    if s >= 0 and s <= 1 and t >= 0 and t <= 1 then
        return true
    end

    return false
end

-- rotate a table of vertices
-- by an angle in radians
function rotate_and_draw(shape, dx, dy, angle, color)
    spin_angle = shape.spin * angle
    for i = 1, #shape.polys do
        local v = shape.polys[i]
        local newv={}

        for i=1, #v/2 do
            local x=v[i*2-1]
            local y=v[i*2]

            local nx=x*cos(spin_angle)-y*sin(spin_angle)
            local ny=x*sin(spin_angle)+y*cos(spin_angle)

            add(newv,nx + shape.center[1] + dx)
            add(newv,ny + shape.center[2] + dy)
        end

        render_poly(newv, color)
    end
end

-- draws a filled convex polygon
-- v is an array of vertices
-- {x1, y1, x2, y2} etc
function render_poly(v, col)
    col=col or 5

    -- initialize scan extents
    -- with ludicrous values
    local x1,x2={},{}
    for y=0,127 do
        x1[y],x2[y]=128,-1
    end
    local y1,y2=128,-1

    -- scan convert each pair
    -- of vertices
    for i=1, #v/2 do
        local next=i+1
        if (next>#v/2) next=1

        -- alias verts from array
        local vx1=flr(v[i*2-1])
        local vy1=flr(v[i*2])
        local vx2=flr(v[next*2-1])
        local vy2=flr(v[next*2])

        if vy1>vy2 then
            -- swap verts
            local tempx,tempy=vx1,vy1
            vx1,vy1=vx2,vy2
            vx2,vy2=tempx,tempy
        end

        -- skip horizontal edges and
        -- offscreen polys
        if vy1~=vy2 and vy1<128 and
        vy2>=0 then

            -- clip edge to screen bounds
            if vy1<0 then
                vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
                vy1=0
            end
            if vy2>127 then
                vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
                vy2=127
            end

            -- iterate horizontal scans
            for y=vy1,vy2 do
                if (y<y1) y1=y
                if (y>y2) y2=y

                -- calculate the x coord for
                -- this y coord using math!
                x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

                if (x<x1[y]) x1[y]=x
                if (x>x2[y]) x2[y]=x
            end
        end
    end

    -- render scans
    for y=y1,y2 do
        local sx1=flr(max(0,x1[y]))
        local sx2=flr(min(127,x2[y]))

        local c=col*16+col
        local ofs1=flr((sx1+1)/2)
        local ofs2=flr((sx2+1)/2)
        memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
        pset(sx1,y,c)
        pset(sx2,y,c)
    end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000a00000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000003a000000000000000000000900000000000000000000000000000003000000000000000000000000000000000000000000000000000
00a0000000000000000000a000000000000000000009990000000000000000000000000000033300000000000000000000000000000000000000000000000000
a0aa0a000000000a000000a000000000000000000001910000000000000000000000000000033300000000000000000000000000000000000000000000000000
a0aaaa000000000a000000300000000000000000001c1c1000000000000000000000000000333330000000000000000000000000000000000000000000000000
aaa3a300000000030000000000000000000000000011811000000000000000000000000000333330000000000000000000000000000000000000000000000000
3aa3a000000000000000000000000000000000000014841000000000000000000000000000333330000000000000000000000000000000000000000000000000
03333000000000000000000000000000000000000004840000000000000000000000000000033300000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000014841000000000000000000000000000333330000000000000000000000000000000000000000000000000
0000000000a00000000000000000000000000000001d8d1000000000000000000000000000333330000000000000000000000000000000000000000000000000
0000000000000000000000000000a0000000010001ddddd100010000000000000000030003333333000300000000000000000000000000000000000000000000
00000000000000000000000000000000000015111ddddddd11151000000000000000333333333333333330000000000000000000000000000000000000000000
0000000000000000000000000000000000015ddddd4ddd4ddddd5100000000000003333333333333333333000000000000000000000000000000000000000000
000000000000000000000000000000000001ddddddddddddddddd100000000000003333333333333333333000000000000000000000000000000000000000000
000000000000a0000000000000000000001dddddd2ddddd2dddddd10000000000033333333333333333333300000000000000000000000000000000000000000
00000000000a3000000000000000000001ddddddd2ddddd2ddddddd1000000000333333333333333333333330000000000000000000000000000000000000000
00000000000a000000000000000000001dddddddd1ddddd1dddddddd100000003333333333333333333333333000000000000000000000000000000000000000
000000000a0a0000000aa000000000001ddddddd11ddddd11ddddddd100000003333333333333333333333333000000000000000000000000000000000000000
0000000000030000000aa000000000001dddd111d1ddddd1d111dddd100000003333333333333333333333333000000000000000000000000000000000000000
0000000000000000000000000000000018d11ddd1d1ddd1d1ddd11d8100000003333333333333333333333333000000000000000000000000000000000000000
00000000000000000000000000000000188dd111011ddd110111dd88100000003333333303333333033333333000000000000000000000000000000000000000
000000000000000000000a000000000051111000001ddd1000001111500000003333300000333330000033333000000000000000000000000000000000000000
0000a0000000000000000a00a000000000000000001ddd1000000000000000000000000000333330000000000000000000000000000000000000000000000000
000000000000000000000a0a300000000000000001ddddd100000000000000000000000003333333000000000000000000000000000000000000000000000000
000000000000000000000a0a00000000000000001ddd1ddd10000000000000000000000033333333300000000000000000000000000000000000000000000000
00000000000000000000030300000000000000001d1ddd1d10000000000000000000000033333333300000000000000000000000000000000000000000000000
000000000a00a00000000000000000000000000001dd1dd100000000000000000000000003333333000000000000000000000000000000000000000000000000
0000000003a0a0000000000000000000000000000011111000000000000000000000000000333330000000000000000000000000000000000000000000000000
0000000000a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
