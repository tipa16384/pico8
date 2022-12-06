pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Puzzle 3
-- by Tipa

function _init()

    num_stages = 4

    title_screen = true
    ground_level = 128 - 32
    score = 0
    end_time = time()
    started = false
    crane_at = 1
    crane_open = false

    stacks = {0, 0, 0, 0}
    dropping_crates = {}
    wanted = {}
    time_to_beep_frames = 30
    time_to_beep_frame_gap = 10
    beep_frames = 0

    tension_playing = false
    sfx(-1, 3)

    game_over = false

    reset_board()
end

function reset_board()
end

function stage_left(stage)
    local stage_sep = 8
    local total_stage_width = num_stages * 16 + (num_stages-1) * stage_sep
    local left_x = (128 - total_stage_width)/2
    return left_x + (stage-1) * (16 + stage_sep)
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
            spr(13, x*8, y*8)
        end
    end

    -- set random seed
    srand(123)

    rectfill(8, 8, 128-9, 128-9, 0)
    msgs = { "crates", "advent of code 2022.5", "by", "tipa", "", "place the crates", "in correct stack", "", "press 'x' to start" }
    talktalk(msgs)
end

function is_lit_up(stage)
    if beep_frames == 0 then
        return false
    end
    cur_beep_frames = calc_beep_frames() - beep_frames
    for lit_stage = 1,#wanted do
        if cur_beep_frames >= 0 and cur_beep_frames < time_to_beep_frames then
            return stage == wanted[lit_stage]
        end
        cur_beep_frames -= time_to_beep_frames + time_to_beep_frame_gap
    end
    return false
end

function _draw()
    cls()

    if title_screen then
        display_title_screen()
        return
    end

    -- print 2x2 sprite 14 across the screen at y coord ground_level
    for x=0, 8 do
        spr(14, x*16, ground_level, 2, 2)
    end

    for i=1, num_stages do
        local x = stage_left(i)
        if (is_lit_up(i)) then
            sound_to_play = 9 + i
            if stat(47) != sound_to_play then
                sfx(sound_to_play, 2)
            end
            spr(26, x, ground_level - 8, 2, 1)
        else
            spr(10, x, ground_level - 8, 2, 1)
        end
    end

    local crane_x = stage_left(crane_at);
    spr(28, crane_x-8, 0)
    spr(42, crane_x, 0, 2, 1)
    spr(29, crane_x + 16, 0)

    if crane_open then
        dx = 4
    else
        dx = 0
    end
    spr(44, crane_x - dx - 8, 8, 1, 2)
    spr(45, crane_x + 16 + dx, 8, 1, 2)

    if not crane_open then
        spr(46, crane_x, 8, 2, 2)
    end

    for i=1,#stacks do
        local x = stage_left(i)
        for j=1,stacks[i] do
            local y = ground_level - 8 - 16 * j
            spr(46, x, y, 2, 2)
        end
    end

    -- draw dropping crates
    for i=1,#dropping_crates do
        local crate = dropping_crates[i]
        spr(46, crate.x, crate.y, 2, 2)
    end

    print("score: "..score, 128 - 9 * 4, 120, 8)

    if game_over then
        rectfill(0, 0, 128, 16, 0)
        print("      game over     ", (128 - 20 * 4)/2, 0, ceil(rnd(16)))
        print("press 'x' to restart", (128 - 20 * 4)/2, 8, ceil(rnd(16)))
        return
    end

    if not started then
        msgs = { "watch the lights", "", "place crates", "in correct order", "", "press 'x' to start" }
        talktalk(msgs)
        return
    end

    print("time: "..flr(time() - end_time), 0, 120, 8)

end

function drop_crate()
    local x = stage_left(crane_at)
    local y = 8
    local dx = 0
    local dy = 1
    local crate = {x=x, y=y, dx=dx, dy=dy, stage=crane_at, g=0.5}
    add(dropping_crates, crate)
end

function calc_beep_frames()
    return (time_to_beep_frames + time_to_beep_frame_gap) * #wanted 
end

function start_the_game()
    if not started then
        started = true
        end_time = time()
        -- set random seed
        srand(time())

        -- set wanted to list of 4-6 random stacks (1 to num_stages)
        wanted = {}
        for i=1, 4 do
            add(wanted, 1 + flr(rnd(num_stages)))
        end

        beep_frames = calc_beep_frames()
    end
end

function _update()
    if game_over then
        -- if user presses 'x' restart the game
        if btnp(5) then
            _init()
            start_the_game()
        end
        return
    end

    if title_screen then
        -- if user presses 'x' restart the game
        if btnp(5) then
            title_screen = false
            started = false
        end
        return
    end

    if btnp(5) then
        if not started then
            start_the_game()
            return
        end
        if not crane_open then
            if stacks[crane_at] < 4 and beep_frames == 0 then
                crane_open = true
                drop_crate()
                sfx(7,1)
            end
        else
            crane_open = false
        end
    end

    if not started then
        return
    end

    if beep_frames > 0 then
        beep_frames -= 1
    end

    -- move crane left
    if btnp(0) then
        if crane_at > 1 then
            crane_at = crane_at - 1
            sfx(1,1)
        end
    end
    -- move crane right
    if btnp(1) then
        if crane_at < num_stages then
            crane_at = crane_at + 1
            sfx(1,1)
        end
    end

    -- for each dropping crate
    for i=#dropping_crates, 1, -1 do
        local crate = dropping_crates[i]
        -- move crate
        crate.x = crate.x + crate.dx
        crate.dy += crate.g
        crate.y = crate.y + crate.dy
        -- if crate hits the ground
        local top = ground_level - 8 - 16 * stacks[crate.stage]
        if crate.y+16 >= top then
            -- remove crate from dropping crates
            del(dropping_crates, crate)
            -- add crate to stack
            -- if the first element of wanted is the same as the stack
            if wanted[1] == crate.stage then
                sfx(9+crate.stage, 2)
                -- remove the first element of wanted
                del(wanted, crate.stage)
                -- add 1 to the stack
                stacks[crate.stage] = stacks[crate.stage] + 1
                -- if wanted is empty
                if #wanted == 0 then
                    -- add 1 to score
                    score += 1
                    -- set wanted to list of 4-6 random stacks (1 to num_stages)
                    stacks = {0,0,0,0}
                    wanted = {}
                    for i=1, 4 do
                        add(wanted, 1 + flr(rnd(num_stages)))
                    end
                    -- set beep_frames to calc_beep_frames()
                    beep_frames = calc_beep_frames()
                end
            else
                -- game over
                game_over = true
                sfx(3,1)
            end
        end
    end
end

__gfx__
0888888001bbbb10000220000009900000078880001111000076cc000888888001bbbb1000022000dddddddddddddddd0000000000044000aaaaaaaaaaaaaaaa
889999881b1c33b1002ee200009aa90000788a8805666650077cccc088eeee881b1338b100211200d66666666666666d0000000005444450abbbabbbabbbabbb
899aa998b3c1131b02ecce2009aaaa900787a8281677d661c6cccccc8eeaaee8b331881b021cc12066555555555555660000000004411440bb3bbb3bbb3bb3b3
89a77a98b13cc13b2eceece29aa77aa9787a888216765d61cccccc6d8ea77ae8b318813b21cbbc1266555555555555660000000044d41144b35bb333b333b333
89a77a98b313cc3b2eceece29aa77aa987a8282816d55d61c7cccc6d8ea77ae8b818313b21cbbc1266555555555555660000000044dd4144355b335b33533353
899aa998b3311ccb02ecce2009aaaa908a888280166dd6610c6cc6d08eeaaee8b183133b021cc120065555555555556000000000044dd4405595335535553555
889999881b3331b1002ee200009aa900882828000566665000cccd0088eeee881b3133b100211200066666666666666000000000054444505545355555555559
0888888001bbbb1000022000000990000882800000111100000cc0000888888001bbbb1000022000006666666666660000000000000440005555555595955554
0333333001bbbb10000220000099990000079990001111000076ee000333333001bbbb1000022000dddddddddddddddd22222222222222225555555545495955
33bbbb331b1a33b1002ee20009aaaa9000799a9905cccc50077eeee033bbbb331b133ab1002ee200d66666666666666d2dddddddddddddd25555955555545455
3bbaabb3b3a1131b02effe209aaaaaa90797a9891c77dcc1e6eeeeee3bb66bb3b331aa1b02effe2066989888888a87662d222222222222d25955455595555555
3ba77ab3b13aa13b2ef77fe29aa77aa9797a99981c761dc1eeeeee6d3b6776b3b31aa13b2ef88fe266998a8888a877662d255555555552d25455555544555955
3ba77ab3b313aa3b2ef77fe29aa77aa997a989891cd11dc1e7eeee6d3b6776b3ba1a313b2ef88fe26698a888888787662d252222222252d25555955555555455
3bbaabb3b3311aab02effe209aaaaaa99a9998901ccddcc10e6ee6d03bb66bb3b1a3133b02effe20069aaaaa7a7777602d255dddddd552d25555945555555559
33bbbb331b3331b1002ee20009aaaa909989890005cccc5000eeed0033bbbb331b3133b1002ee20006666666666666602d225d2222d522d25555545595555554
0333333001bbbb1000022000009999000998900000111100000ee0000333333001bbbb100002200000666666666666002d225d2002d522d25495555555594555
01bbbb1001bbbb1000111100000989900882800000111100007988000177771001bbbb100022220022222222222222222d212d2112d212d20555555555555550
1b33c1b11b33a1b105cccc50009898998828280005bbbb500778888017ddc1711b3133b105cccc50dddddddddddddddd2ddddd2112ddddd25599499949949955
b1311c3bb1311a3b1ccddcc1098999a98a8882801b773bb18988888871d11cd7b1a3133b2c77dcc222222222222222222d555d2112d555d25999499944949995
b31cc31bb31aa31b1cd11dc198989a9988a828281b7a53b18888889d7d1ccd17ba1a313b2c761dc255555555555555552d522d2112d522d25949499499949495
b3cc313bb3aa313b1cd167c18999a797787a88821b3553b18788889d7dccd1d7b31aa13b2cd11dc222222222222222222d52dd2222dd52d25999499499949995
bcc1133bbaa1133b1ccd77c1989a79700787a8281bb33bb10e9889d07cc11dd7b331aa1b2ccddcc2dddddddddddddddd2d52d220022d52d25999ffffffff9995
1b1333b11b1333b105cccc5099a7970000787a8805bbbb5000888d00171ddd711b133ab105cccc5022222222222222222d52d220022d52d25994f5f55f5f9995
01bbbb1001bbbb1000111100099970000007888000111100000880000177771001bbbb100022220000000000000000002d52d220022d52d25999ffffffff9995
0aaaaaa001888810001111000999700008887000001111000079bb000eeeeee0018888100011110000000000000000002dd2d220022d5dd25999f55f555f9995
aa9999aa181e228105cccc5099a9970088a8870005888850077bbbb0ee8888ee1822e18105cccc50000000000000000022d2d220022d5d225999ffffffff4995
a998899a82e112181ccddcc1989a7970828a787018772881b9bbbbbbe882288e81211e281ccd77c1000000000000000002d2d220022d5d205999499499949995
a984489a812ee1281cd11dc18999a7972888a78718795281bbbbbb9de824428e821ee2181cd167c1000000000000000002d2d221122d5d205999499499949995
a984489a8212ee281c761dc198989a7982828a7818255281b7bbbb9de824428e82ee21281cd11dc1000000000000000002d2d211112d5d205949499499949995
a998899a82211ee81c77dcc1098999a9082888a818822881039bb9d0e882288e8ee112281ccddcc1000000000000000002dd2d1111d2dd205999499494994995
aa9999aa1822218105cccc5000989899008282880588885000bbbd00ee8888ee1812228105cccc500000000000000000022ddd1111ddd2205599499499994955
0aaaaaa00188881000111100000989900008288000111100000bb0000eeeeee00188881000111100000000000000000000222221122222000555555555555550
__sfx__
000100000d6500d6500d6500e6000e6000d6000d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a0501f0502505024050110500f0500d05009050080500505000050000500000000000000000000000000000000000000000210001b00000000000000000000000000000000000000000000000000000
0002000033250332503325032250302502f2502d2502c2502a25029250272502625023250212501e2501c2501a250182501625013250112500e2500c25009250062500425001250002500b2000b2000b2000a200
00020000000000b2500b2500b2500b2500b2500b2502f4002c40028400244001f4001b40016400032500325003250032500325003250032500345002400014000140000400004000040000400001000010000000
000300000a2500a2500a2500a2500a2500a2500000000000000000f2500f2500f2500f2500f2500000000000000001b2501b2501b2501b2501b2501b250000000000000000000000000000000000000000000000
001000100e020000000d0000d000150300c00000000000000703000000000000f0000f03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00180000115201110011520000001552000700095200a520000000a520085200f5200f5200f0001d0201a0201d02012000220201f0202102000000180201502017020000001d7201572005720007200000000000
000800001655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400180455000000000000000000000025000000000000000000000000000066500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c3500c3500c3500c3000c3500c3500c3500c3500c3500c3500c3000c300000000f3500f3500d3000e3500e350000000e3500e3500000000000000000000000000000000000000000000000000000000
000600001177011760117601174011730117101170011700117000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000600001677016770167601674016730167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001877018760187501874018730187100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001c7701c7701c7601c7501c7301c7100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 06084344

