pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Puzzle 3
-- by Tipa

function _init()
    gems_per_side = 5
    side_size = 16
    total_gems = gems_per_side * gems_per_side

    cursor = ceil(total_gems/2)

    title_screen = true

    score = 0
    end_time = time() + 30
    started = false

    tension_playing = false
    sfx(-1, 3)

    game_over = false

    reset_board()
end

function reset_board()
    nums={}
    for i=0, total_gems do
        add(nums, i+1)
    end

    select1 = -1
    select1_color = 2

    -- shuffle the array
    shuffle(nums)
end

function display_title_screen()
    cls(0)

    for x=0, 16 do
        for y=0, 16 do
            spr(flr(rnd(64)+1), x*8, y*8)
        end
    end

    -- set random seed
    srand(123)

    rectfill(8, 8, 128-8, 128-8, 0)
    msgs = { "gems", "by", "tipa", "", "find the two", "matching gems", "", "press 'x' to start" }

    banner_height = 8 * #msgs
    for i=1, #msgs do
        print(msgs[i], 64 - #msgs[i]*2, 64 - banner_height/2 + (i-1)*8, 7)
    end

end

function _draw()
    cls()

    if title_screen then
        display_title_screen()
        return
    end

    if select1 == -1 then
        msg = "select gem with 'x'"
    else
        msg = "select its match with 'x'"
    end

    tx = (128 - #msg * 4) / 2
    print(msg, tx, 0, 8)

    local margin = 2
    local side_size_with_box = side_size + margin
    bx = (128 - gems_per_side * side_size_with_box) / 2
    by = (128 - gems_per_side * side_size_with_box) / 2

    -- draw the numbers
    for i=0,total_gems-1 do
        local x=i%gems_per_side
        local y=flr(i/gems_per_side)
        local sprite_index = i + 1
        local sprnum = nums[sprite_index]
        if select1 == sprite_index then
            rectfill(bx + x * side_size_with_box+1, by + y * side_size_with_box+1, bx + x * side_size_with_box + side_size_with_box-2, by + y * side_size_with_box + side_size_with_box-2, select1_color)
        end
        if cursor == sprite_index then
            rect(bx + x * side_size_with_box, by + y * side_size_with_box, bx + x * side_size_with_box + side_size_with_box - 1, by + y * side_size_with_box + side_size_with_box - 1, 7)
        end

        sspr((sprnum % 16) * 8, (flr(sprnum / 16)) * 8, 8, 8, bx + x * side_size_with_box + margin/2, by + y * side_size_with_box + margin/2, side_size, side_size)
    end

    print("score: "..score, 128 - 9 * 4, 120, 8)

    if game_over then
        rectfill(0, 0, 128, 16, 0)
        print("      game over     ", (128 - 20 * 4)/2, 0, ceil(rnd(16)))
        print("press 'x' to restart", (128 - 20 * 4)/2, 8, ceil(rnd(16)))
        return
    end

    if not started then
        rectfill(0, 128/2-12, 128, 128/2+12, 0)
        print("press 'x' to start", (128 - 18 * 4)/2, 128/2 - 4, ceil(rnd(16)))
        return
    end

    print("time: "..flr(end_time - time()), 0, 120, 8)

end

function start_the_game()
    if not started then
        started = true
        end_time = time() + 30
        sfx(6, 3)
        -- set random seed
        srand(time())
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
            start_the_game()
            started = false
        end
        return
    end

    if btnp(5) then
        if not started then
            start_the_game()
            return
        end
        if select1 == -1 then
            select1 = cursor
            sfx(1)
        elseif select1 == cursor then
            select1 = -1
            sfx(1)
        elseif nums[cursor] == nums[select1] then
            reset_board()
            sfx(4)
            score += 1
            end_time += 7
        else
            select1 = -1
            sfx(3)
        end
    end

    if started and end_time - time() <= 10 then
        if end_time - time() < 0 then
            sfx(-1, 3)
            sfx(2, 3)
            game_over = true
            return
        end

        if not tension_playing then
            sfx(5, 3)
            tension_playing = true
        end
    elseif tension_playing then
        sfx(-1, 3)
        tension_playing = false
    end

    local old_cursor = cursor
    -- left arrow decrement cursor
    if btnp(0) then
        cursor = cursor - 1
        if cursor < 1 then
            cursor = total_gems
        end
    end
    -- right arrow increment cursor
    if btnp(1) then
        cursor = cursor + 1
        if cursor > total_gems then
            cursor = 1
        end
    end
    -- up arrow decrement cursor by gems_per_side
    if btnp(2) then
        cursor = cursor - gems_per_side
        if cursor < 1 then
            cursor += total_gems
        end
    end
    -- down arrow increment cursor by gems_per_side
    if btnp(3) then
        cursor = cursor + gems_per_side
        if cursor > total_gems then
            cursor -= total_gems
        end
    end

    if cursor != old_cursor then
        sfx(7)
    end

    if (time() * 1000) % 2 == 0 then
        select1_color = 2
    else
        select1_color = 4
    end
end

function fixme(n)
    if n < 0 then return 1 end
    if n > total_gems-1 then return total_gems-1 end
    return n
end


function shuffle(arr)
    for i=1,#arr do
        local j=fixme(flr(rnd(#arr))+1)
        local ij = fixme(i)
        arr[ij],arr[j]=arr[j],arr[ij]
    end
    local k=fixme(flr(rnd(#arr))+1)
    local l=fixme(flr(rnd(#arr))+1)
    -- recalc l until k us not equal to l
    while k==l do
        l=fixme(flr(rnd(total_gems))+1)
    end
    arr[l] = arr[k]
end

__gfx__
0888888001bbbb10000220000009900000078880001111000076cc000888888001bbbb100002200000022000003dd00000cdd00000edd000008dd00000bdd000
889999881b1c33b1002ee200009aa90000788a8805666650077cccc088eeee881b1338b1002112000028820003366d000cc66d000ee66d0008899d000bb99d00
899aa998b3c1131b02ecce2009aaaa900787a8281677d661c6cccccc8eeaaee8b331881b021cc12002888820333336d0ccccc6d0eeeee6d0888889d0bbbbb9d0
89a77a98b13cc13b2eceece29aa77aa9787a888216765d61cccccc6d8ea77ae8b318813b21cbbc122887788233333333cccccccceeeeeeee88888888bbbbbbbb
89a77a98b313cc3b2eceece29aa77aa987a8282816d55d61c7cccc6d8ea77ae8b818313b21cbbc1228877882633333336ccccccc6eeeeeee988888889bbbbbbb
899aa998b3311ccb02ecce2009aaaa908a888280166dd6610c6cc6d08eeaaee8b183133b021cc120028888207733363077ccc6c077eee6e07788898077bbb9b0
889999881b3331b1002ee200009aa900882828000566665000cccd0088eeee881b3133b1002112000028820007637300076c7c00076e7e0007987e00079b7300
0888888001bbbb1000022000000990000882800000111100000cc0000888888001bbbb1000022000000220000033300000ccc00000eee0000088800000bbb000
0333333001bbbb10000220000099990000079990001111000076ee000333333001bbbb10000220000011110000aaaa0000111100001111000011110000111100
33bbbb331b1a33b1002ee20009aaaa9000799a9905cccc50077eeee033bbbb331b133ab1002ee20005bbbb500acccca0056666500566665005bbbb5005888850
3bbaabb3b3a1131b02effe209aaaaaa90797a9891c77dcc1e6eeeeee3bb66bb3b331aa1b02effe201bb33bb1acacca6a166dd661166dd6611bb33bb118822881
3ba77ab3b13aa13b2ef77fe29aa77aa9797a99981c761dc1eeeeee6d3b6776b3b31aa13b2ef88fe21b3553b1acca7cca16d55d6116d55d611b3553b118255281
3ba77ab3b313aa3b2ef77fe29aa77aa997a989891cd11dc1e7eeee6d3b6776b3ba1a313b2ef88fe21b35a7b1acc7acca16765d6116d567611b7a53b118795281
3bbaabb3b3311aab02effe209aaaaaa99a9998901ccddcc10e6ee6d03bb66bb3b1a3133b02effe201bb377b1acac6aca1677d661166d77611b773bb118772881
33bbbb331b3331b1002ee20009aaaa909989890005cccc5000eeed0033bbbb331b3133b1002ee20005bbbb500accc6a0056666500566665005bbbb5005888850
0333333001bbbb1000022000009999000998900000111100000ee0000333333001bbbb10000220000011110000aaaa0000111100001111000011110000111100
01bbbb1001bbbb1000111100000989900882800000111100007988000177771001bbbb10002222000007eee000aaaa000bb3b00009989000000b3bb00bbb7000
1b33c1b11b33a1b105cccc50009898998828280005bbbb500778888017ddc1711b3133b105cccc50007e7aee0a8888a0bb3b3b009989890000b3b3bbbba7b700
b1311c3bb1311a3b1ccddcc1098999a98a8882801b773bb18988888871d11cd7b1a3133b2c77dcc207e7ae9ea8a88a6ababbb3b09a9998900b3bbbabb3ba7b70
b31cc31bb31aa31b1cd11dc198989a9988a828281b7a53b18888889d7d1ccd17ba1a313b2c761dc27e7aeee8a88a788abbab3b3b99a98989b3b3ba7b3bbba7b7
b3cc313bb3aa313b1cd167c18999a797787a88821b3553b18788889d7dccd1d7b31aa13b2cd11dc2eeae9e8ea887a88a7b7abbb3797a99983bbba7b7b3b3babb
bcc1133bbaa1133b1ccd77c1989a79700787a8281bb33bb10e9889d07cc11dd7b331aa1b2ccddcc2eaeee8e0a8a86a8a07b7ab3b0797a989b3ba7b700b3bbbab
1b1333b11b1333b105cccc5099a7970000787a8805bbbb5000888d00171ddd711b133ab105cccc50ee9e8e000a8886a0007b7abb00797a99bbabb70000b3b3bb
01bbbb1001bbbb1000111100099970000007888000111100000880000177771001bbbb10002222000ee8e00000aaaa000007bbb0000799900bbb7000000b3bb0
0aaaaaa001888810001111000999700008887000001111000079bb000eeeeee001888810001111000eee70000882800000099000002222000ccc70000007ccc0
aa9999aa181e228105cccc5099a9970088a8870005888850077bbbb0ee8888ee1822e18105cccc50eeaee700882828000092290002999920cca7c700007c7acc
a998899a82e112181ccddcc1989a7970828a787018772881b9bbbbbbe882288e81211e281ccd77c1e9ea7e708e8882800922229029999992c1ca7c7007c7ac1c
a984489a812ee1281cd11dc18999a7972888a78718795281bbbbbb9de824428e821ee2181cd167c18eeea7e788e82828922aa229299aa9921ccca7c77c7accc1
a984489a8212ee281c761dc198989a7982828a7818255281b7bbbb9de824428e82ee21281cd11dc1e8e9ea7e787e8882922aa229299aa992c1c1caccccac1c1c
a998899a82211ee81c77dcc1098999a9082888a818822881039bb9d0e882288e8ee112281ccddcc10e8eeeae0787e82809222290299999920c1cccaccaccc1c0
aa9999aa1822218105cccc5000989899008282880588885000bbbd00ee8888ee1812228105cccc5000e8e9ee00787e88009229000299992000c1c1cccc1c1c00
0aaaaaa00188881000111100000989900008288000111100000bb0000eeeeee00188881000111100000e8ee0000788800009900000222200000c1cc00cc1c000
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
__music__
04 06084344

