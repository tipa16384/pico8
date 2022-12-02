pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- Puzzle 1
-- by Tipa

function _init()
    restart()
    width = 16
    height = 16
    map_size = 10
    px = map_size/2
    py = map_size/2
    oob_sprite = 0
    player_sprite = 1
    star_sprite = 2
    tree_sprite = 3
    empty_sprite = 4
    path_sprite = 5
    tree_player_sprite = 6
    sprite_width = 8
    star_x = 0
    star_y = 0
    last_time = 0
    move_per_sec = 10
    tree_power = false
    hunger = 0
    max_hunger = 100
    hunger_per_sec = 1
    hunger_per_star = 2
    hunger_per_tree = 10
    last_ate_time = time()
    -- make an array of (map_size*map_size/10) unique x,y positions that are not the same as player or star position
    path = {}
    place_star()
    sfx(5)
end

function restart()
    dead_trees = 0
    game_start_time = time()
end

function modhunger(offset)
    hunger = hunger + offset
    if hunger < 0 then
        hunger = 0
    end
    if hunger > max_hunger then
        hunger = max_hunger
    end
end

function is_game_over()
    return hunger >= max_hunger
end

function _draw()
    cls()

    camera((px-width/2) * sprite_width, -(height/2-py) * sprite_width)
	clear_map()
    draw_map()
    draw_score()

end

function draw_score()
    camera(0,0)
    -- erase top 16 pixels of screen
    rectfill(0,0,127,15,0)
    print("hunger: "..hunger, 0, 0, 7)
    print("score: "..dead_trees, 10*8, 0, 7)
    if is_game_over() then
        print("game over - press x to restart", 0, 8, 7)
        sfx(-5)
        sfx(-4)
        sfx(-3)
        sfx(-2)
        sfx(-1)
    else
        print("press z for tree power", 0, 8, 7)
    end
end

function _update()
    if is_game_over() then
        -- if game over, wait for x to restart
        if btnp(5) then
            restart()
            _init()
        end
        return
    end

    local npx, npy = px, py

    current_time = time()

    -- if current time is more than 1 second after last time, add hunger_per_sec to hunger
    if current_time > last_ate_time + 1 then
        modhunger(hunger_per_sec)
        last_ate_time = current_time
    end

    -- if player on star move star
    if px == star_x and py == star_y then
        sfx(1)
        place_star()
        dead_trees = dead_trees + 1
    end
    -- only process keystrokes at most three times a second
    if (current_time - last_time) > (1/move_per_sec) then
        last_time = current_time
        if btn(0) then
            npx = px - 1
        elseif btn(1) then
            npx = px + 1
        elseif btn(2) then
            npy = py - 1
        elseif btn(3) then
            npy = py + 1
        end

        -- if Z is pressed, toggle tree power
        if btn(4) then
            tree_power = not tree_power
            if tree_power then
                sfx(2)
            else
                sfx(3)
            end
        end
    end

    -- check if player is out of bounds
    if npx < 0 then
        npx = 0
    elseif px >= map_size then
        npx = map_size-1
    end
    if npy < 0 then
        npy = 0
    elseif npy >= map_size then
        npy = map_size-1
    end

    -- if tree_power and npx,npy is in path, remove it
    if tree_power then
        for i=1,#path do
            if path[i].x == npx and path[i].y == npy then
                del (path, path[i])
                tree_power = false
                modhunger(hunger_per_tree)
                sfx(3)
                break
            end
        end
    end
    -- check if npx,npy is in path
    if in_path(npx, npy) then
        npx = px
        npy = py
    end

    px = npx
    py = npy
end

-- function place_star sets a random star position on the map that is not the player's position and not in the path
function place_star()
    repeat
        star_x = flr(rnd(map_size))
        star_y = flr(rnd(map_size))
    until (star_x ~= px or star_y ~= py) and not in_path(star_x, star_y)

    -- add a random x,y to path that is not the player position, star position, or already in path
    local x = 0
    local y = 0
    repeat
        x = flr(rnd(map_size))
        y = flr(rnd(map_size))
    until (x ~= px or y ~= py) and (x ~= star_x or y ~= star_y) and not in_path(x, y)
    add(path, {x=x, y=y})
    modhunger(-hunger_per_star)
end

-- function in_path returns true if x,y is in the path
function in_path(x, y)
    for i=1,#path do
        if path[i].x == x and path[i].y == y then
            return true
        end
    end
    return false
end

-- function clear_map fills the screen with sprite oob_sprite
function clear_map()
    for x = -1, map_size do
        for y = -1, map_size do
            if x < 0 or x >= map_size or y < 0 or y >= map_size then
                spr(oob_sprite, x * sprite_width, y * sprite_width)
            end
        end
    end
end

function draw_map()
    -- iterate through height and width
    for y = 0, map_size-1 do
        for x = 0, map_size-1 do
            spr(path_sprite, x * sprite_width, y * sprite_width)
            -- if x,y in path then draw tree_sprite
            for i=1,#path do
                if path[i].x == x and path[i].y == y then
                    spr(tree_sprite, x * sprite_width, y * sprite_width)
                end
            end
            if y == star_y and x == star_x then
                spr(star_sprite, x * sprite_width, y * sprite_width)
            end
            if y == py and x == px then
                if tree_power then
                    spr(tree_player_sprite, x * sprite_width, y * sprite_width)
                else
                    spr(player_sprite, x * sprite_width, y * sprite_width)
                end
            end
        end
    end
end

__gfx__
cccccccc000000000000000000333300000000004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc00bb0000040a040003bb3430000000004444544400880000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc080bb000009a9000333bb3b300000000444444450b088000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000660000aa7aa003bb3b333000000004454444400066000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000ff000009a9000333bb3830000000044444444000ff000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc00bbbb00040a04003b433b33000000004444444400888800000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc00bbbb00000000000333bb30000000004444544500888800000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000bb0000000000000333300000000004544444400088000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d6500d6500d6500e6000e6000d6000d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a0501f0502505024050110500f0500d05009050080500505000050000500000000000000000000000000000000000000000210001b00000000000000000000000000000000000000000000000000000
000100000205001050010500105001050010500105001050020500305003050040500605007050090500b0500c0500d0500f05011050130501405016050190501c0501f05022050260502a0502e0503305039050
00010000000003945038450374503645034450324502f4502c45028450244501f4501b45016450114500e4500c450094500745005450034500345002450014500145000450004500045000450001500015000000
000200003b6503a6503a650316501e650006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000100e020000000d0000d000150300c00000000000000703000000000000f0000f03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
