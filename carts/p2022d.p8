pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Elf Defense
-- by Tipa

function _init()

    title_screen = true

    player_loc = {x=8,y=8,facing_left=false}
    camp = {x=1,y=1,w=13,h=13}
    -- treasure is sprite 34. it has a location and a health. Health is from 10-20.
    treasure = {x=0,y=0,health=0,sprite=34}
    -- treasure_list is a list of treasure locations. It is used to determine if a treasure is already there.
    treasure_list = {}

    -- enemy is sprite 17. It has a location, a health, and a direction.
    enemy = {x=0,y=0,health=0,sprite=17,direction=0}
    enemy_list = {}
    game_over_message = ""

    add_treasure()

    player_speed = 1

    score = 0
    end_time = time() + 120
    started = false

    tension_playing = false
    sfx(-1, 3)

    game_over = false

    reset_board()

    last_spawn_time = time()
    enemy_move_time = time()
end

function add_treasure()
    -- make a copy of treasure and add it to the treasure_list with a random location that is within the camp and
    -- not the same location as the player or any other treasure.
    local t = {sprite=treasure.sprite}

    used_locations = find_used_locations()

    local x = 0
    local y = 0
    local treasure_loc = {x=0,y=0}
    local treasure_exists = true
    while treasure_exists do
        x = flr(rnd(camp.w-1)) + camp.x + 1
        y = flr(rnd(camp.h-1)) + camp.y + 1
        treasure_loc = {x=x,y=y}
        treasure_exists = false
        for i=1,#used_locations do
            if treasure_loc.x == used_locations[i].x and treasure_loc.y == used_locations[i].y then
                treasure_exists = true
            end
        end
    end
    t.x = x
    t.y = y
    t.health = rnd(10) + 10
    add(treasure_list, t)

    add_enemy()
end

function add_enemy() 
    -- enemy spawns at the edge of the camp. It has a random direction and a random health.
    local e = {sprite=enemy.sprite}
    local x = 0
    local y = 0
    used_locations = find_used_locations()
    local location_used = true

    while location_used do
        local edge = flr(rnd(4))
        if edge == 0 then
            x = camp.x+1
            y = flr(rnd(camp.h-1)) + camp.y + 1
        elseif edge == 1 then
            x = camp.x + camp.w -1
            y = flr(rnd(camp.h-1)) + camp.y + 1
        elseif edge == 2 then
            x = flr(rnd(camp.w-1)) + camp.x + 1
            y = camp.y + 1
        elseif edge == 3 then
            x = flr(rnd(camp.w-1)) + camp.x + 1
            y = camp.y + camp.h - 1
        end
        -- check to see if location used
        location_used = false
        for i=1,#used_locations do
            if x == used_locations[i].x and y == used_locations[i].y then
                location_used = true
            end
        end
    end
    e.x = x
    e.y = y
    e.health = rnd(4) + 2
    e.direction = flr(rnd(4))
    add(enemy_list, e)

end


function find_used_locations()
    -- find all the locations that are used by the player, treasure, and enemies.
    local used_locations = {}
    for i=1,#treasure_list do
        add(used_locations, {x=treasure_list[i].x, y=treasure_list[i].y})
    end
    for i=1,#enemy_list do
        add(used_locations, {x=enemy_list[i].x, y=enemy_list[i].y})
    end
    add(used_locations, {x=player_loc.x, y=player_loc.y})
    return used_locations
end

function reset_board()

end

function display_title_screen()
    cls(0)

    for x=0, 16 do
        for y=0, 16 do
            spr(63, x*8, y*8)
        end
    end

    -- set random seed
    srand(123)

    rectfill(8, 8, 128-9, 128-9, 0)
    msgs = { "elf defense", "by", "tipa", "(advent of code 2022.4)", "", "the camp is", "under attack!", "assign elves to", "its defense!", "", "press 'x' to start" }

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

    -- fill the screen with sprite 20
    for x=0, 16 do
        for y=0, 16 do
            spr(20, x*8, y*8)
        end
    end

    -- draw a border with camp, upper left corner is sprite 4, upper right corner is sprite 5,
    -- lower left corner is sprite 4 flipped vertically, lower right corner is sprite 5 flipped vertically,
    -- left and right side is sprite 6, top and bottom side is sprite 7
    spr(4, camp.x*8, camp.y*8)
    spr(5, camp.x*8 + camp.w*8, camp.y*8)
    spr(4, camp.x*8, camp.y*8 + camp.h*8, 1, 1, false, true)
    spr(5, camp.x*8 + camp.w*8, camp.y*8 + camp.h*8, 1, 1, false, true)
    for x=1, camp.w-1 do
        spr(7, camp.x*8 + x*8, camp.y*8)
        spr(7, camp.x*8 + x*8, camp.y*8 + camp.h*8, 1, 1, false, true)
    end
    for y=1, camp.h-1 do
        spr(6, camp.x*8, camp.y*8 + y*8)
        spr(6, camp.x*8 + camp.w*8, camp.y*8 + y*8, 1, 1, false, false)
    end

    -- draw sprite 63 at the edges of the screen
    for x=0, 16 do
        spr(63, x*8, 0)
        spr(63, x*8, 128-8)
        spr(63, 0, x*8)
        spr(63, 128-8, x*8)
    end

    -- draw sprite 0 at player position
    spr(0, player_loc.x*8, player_loc.y*8, 1, 1, player_loc.facing_left)

    -- draw all the treasures
    for i=1,#treasure_list do
        local t = treasure_list[i]
        spr(t.sprite, t.x*8, t.y*8)
    end

    -- draw all the enemies
    for i=1,#enemy_list do
        local e = enemy_list[i]
        spr(e.sprite, e.x*8, e.y*8, 1, 1, e.direction == 1)
    end

    if game_over then
        print("      game over     ", (128 - 20 * 4)/2, 0, ceil(rnd(16)))
        print("press 'x' to restart", (128 - 20 * 4)/2, 8, ceil(rnd(16)))
        print(game_over_message, (128 - #game_over_message * 4)/2, 16, ceil(rnd(16)))
        return
    end

    -- if any enemies, display "kill the monsters" along the bottom of the screen
    if #enemy_list > 0 then
    msg = "kill the monsters"
    -- else if any treasure, display "save the treasure" along the bottom of the screen
    elseif #treasure_list > 0 then
        msg = "save the treasure"
    -- else display "the camp is silent"
    else
        msg = "the camp is silent"
    end

    display_status(msg)

    -- display score and remaining time along the top of the screen
    print("score: "..score, 0, 0, 7)
    print("time: "..flr(end_time-time()), 128-9*4, 0, 7)

end

function display_status(msg)
    -- display the message centered on the bottom of the screen
    print(msg, (128 - #msg*4)/2, 128-8, 7)
end

function move_enemies()
    -- if time is > enemy_move_time + 1 second, move all enemies toward their closest treasure. if their destination is used, don't move them.
    hit_something = false
    if time() > enemy_move_time + 1 then
        enemy_move_time = time()
        for i=1,#enemy_list do
            local e = enemy_list[i]
            local closest_treasure = find_closest_treasure(e)
            if closest_treasure then
                x, y = e.x,e.y
                if e.x < closest_treasure.x then
                    x = e.x + 1
                elseif e.x > closest_treasure.x then
                    x = e.x - 1
                end
                if e.y < closest_treasure.y then
                    y = e.y + 1
                elseif e.y > closest_treasure.y then
                    y = e.y - 1
                end
                -- if x,y is closest_treasure location, decrement closest_treasure health
                if x == closest_treasure.x and y == closest_treasure.y then
                    closest_treasure.health = closest_treasure.health - 1
                    hit_something = true
                    if closest_treasure.health <= 0 then
                        -- remove treasure
                        del(treasure_list, closest_treasure)
                        sfx(2)
                        score -= 20
                        hit_something = false
                    end
                end
                -- if nothing at x,y, move there
                location_used = false
                used_locations = find_used_locations()
                for i=1,#used_locations do
                    if x == used_locations[i].x and y == used_locations[i].y then
                        location_used = true
                    end
                end
                if not location_used then
                    e.x = x
                    e.y = y
                end
            end
        end
    end

    if hit_something then
        sfx(11)
    end
end

function find_closest_treasure(e)
    local closest_treasure = nil
    local closest_distance = 999
    for i=1,#treasure_list do
        local t = treasure_list[i]
        local distance = abs(e.x - t.x) + abs(e.y - t.y)
        if distance < closest_distance then
            closest_distance = distance
            closest_treasure = t
        end
    end
    return closest_treasure
end


function start_the_game()
    if not started then
        started = true
        end_time = time() + 120
        sfx(6, 3)
        -- set random seed
        srand(time())
        last_spawn_time = time()
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
        end
        return
    end

    if score < 0 then
        game_over = true
        game_over_message = "treasure was destroyed"
        return
    end

    if time() > end_time then
        game_over = true
        game_over_message = "you saved the camp!"
        return
    end

    old_player_loc = {x=player_loc.x, y=player_loc.y}

    -- right arrow move player right
    if btnp(1) then
        player_loc.x = player_loc.x + player_speed
        player_loc.facing_left = false
    end
    -- up arrow move player up
    if btnp(2) then
        player_loc.y = player_loc.y - player_speed
    end
    -- left arrow move player left
    if btnp(0) then
        player_loc.x = player_loc.x - player_speed
        player_loc.facing_left = true
    end
    -- down arrow move player down
    if btnp(3) then
        player_loc.y = player_loc.y + player_speed
    end

    -- if player outside camp boundary, reset player location to old_player_loc
    if player_loc.x <= camp.x or player_loc.x >= camp.x + camp.w or player_loc.y <= camp.y or player_loc.y >= camp.y + camp.h then
        player_loc.x = old_player_loc.x
        player_loc.y = old_player_loc.y
        sfx(1)
    end

    -- if player position same as any treasure, decrement treasure health and if health is 0, remove treasure
    for i=#treasure_list,1,-1 do
        local t = treasure_list[i]
        if t ~= nil and  t.x == player_loc.x and t.y == player_loc.y then
            t.health = t.health - 1
            if t.health <= 0 then
                sfx(2)
                del(treasure_list, t)
                score += 5
            else
                player_loc.x = old_player_loc.x
                player_loc.y = old_player_loc.y
                sfx(10)
            end
        end
    end

    -- prevent moving into enemy
    for i=1,#enemy_list do
        local e = enemy_list[i]
        if e ~= nil and e.x == player_loc.x and e.y == player_loc.y then
            -- decrease enemy health
            e.health = e.health - 1
            if e.health <= 0 then
                sfx(2)
                del(enemy_list, e)
                score += 1
            else
                player_loc.x = old_player_loc.x
                player_loc.y = old_player_loc.y
                sfx(10)
            end
        end
    end

    -- if player loc different from old_player_loc play sfx 0
    if player_loc.x ~= old_player_loc.x or player_loc.y ~= old_player_loc.y then
        sfx(0)
    end

    move_enemies()

    -- every five seconds, spawn a new treasure
    if started and (time() - last_spawn_time > 5) then
        last_spawn_time = time()
        add_treasure()
        sfx(4)
    end
end

__gfx__
0bbbb0000d666666700033000b044000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000
bbfffb0002d666676003333000444400000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000
b0fff006022dddd660003300000444b0000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000
0bbff060022dddd66033333300444000000444444444000000040000444444440000000000000000000000000000000000000000000000000000000000000000
0fbbbf00022dddd66003333000444400000400000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000
04444000022dddd66033333305555550000400000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbb00002d1111d6000550000055000000400000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000
005050000d111111d005555000055000000400000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888000c0cccc0c0000001000066000545555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
878878000c1111c00000660000666600555554550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08778000dc8cc8cd0001111000666600555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808808001dccccd10011111100666600555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008800001d7cc7d10011111100666600555455550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888000011111100001111005555550555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011001100000110000055000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777000000dddd000070070000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000d2222d00078870000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000077000d2122d00788887000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000077000d2212d00788787000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077770000d2222d0078788700aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000dddddd0007777000a0cc0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077700001111111100077770000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bb3430
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333bb3b3
0b300b300b300b300b300b300b300b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bb3b333
3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333bb383
300b300b300b300b300b300b300b300b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b433b33
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333bb30
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333300
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
000300001c5501c5701b5401b5201b5101b51024500245002350023500235002350023500245002450023500235001e5001f5001e5001d5001d5001d500005000050000500005000050000500005000050000500
000400002f64031670316602f6502a65026640216301d63017620116100b610046000260001600006001b6000b600096000660003600026000060000600006000060000600006000060000600006000060000600
__music__
04 06084344

