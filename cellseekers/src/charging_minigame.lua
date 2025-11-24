random_string = {flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2))}
zx_sprites = {false, false, false, false, false}
index = 1

function draw_minigame_sprites()
    local base_x = 69
    local y = 118

    rectfill(79, 110, 126, 126, 0)
    print("minigame", 88, 111, 7)

    for i, v in ipairs(random_string) do
        local x = base_x + i * 10
        if not zx_sprites[i] then
            spr(26 + v, x, y)
        else
            spr(42 + v, x, y)
        end
    end
end

function check_minigame_input()
    if lights_locked == true then return end
    if btnp(4) then
        if random_string[index] == 1 then
            zx_sprites[index] = true
            if index < 5 then
                index += 1
                sfx(1)
            elseif lights_locked == false then
                end_game()
            end
        else
            lock_lights()
            reset_minigame()
        end
    elseif btnp(5) then
        if random_string[index] == 0 then
            zx_sprites[index] = true
            if index < 5 then
                index += 1
                sfx(1)
            elseif lights_locked == false then
                end_game()
            end
        else
            lock_lights()
            reset_minigame()
        end
    end
end

function end_game()
    sfx(2)
    energy += 10
    if energy > max_energy then energy = max_energy end
    index = 1
    random_string = {flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2))}
    zx_sprites = {false, false, false, false, false}
    draw_minigame_sprites()
end

function reset_minigame()
    index = 1
    random_string = {flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2))}
    zx_sprites = {false, false, false, false, false}
end
