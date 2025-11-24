enemies = {}
spawn_delay = 90 
spawn_increase = 0.5
spawn_delay_min = 15
spawn_timer = spawn_delay
enemy_speed = 0.25

function move_enemy()
    for enemy in all(enemies) do
        local t = enemy[1]
        local pos = enemy[2]
        if t == 0 then
            pos.y += enemy_speed
        elseif t == 1 then
            pos.y -= enemy_speed
        elseif t == 2 then
            pos.x += enemy_speed
        elseif t == 3 then
            pos.x -= enemy_speed
        end
    end
end

function spawn_enemy()
    spawn_timer -= 1
    if spawn_timer <= 0 then
        local rand_loc = flr(rnd(4))
        local new_enemy
        if rand_loc == 0 then
            new_enemy = {0, {x=60, y=0}}
        elseif rand_loc == 1 then
            new_enemy = {1, {x=60, y=128}}
        elseif rand_loc == 2 then
            new_enemy = {2, {x=0, y=58}}
        else
            new_enemy = {3, {x=128, y=58}}
        end
        add(enemies, new_enemy)
        spawn_delay = max(spawn_delay - spawn_increase, spawn_delay_min)
        spawn_timer = spawn_delay
    end
end

function draw_enemy()
    for enemy in all(enemies) do
        local pos = enemy[2]
        spr(18, pos.x, pos.y)
    end
end

function check_location()
    for enemy in all(enemies) do
        local t = enemy[1]
        local pos = enemy[2]
        if t == 0 then
            if pos.y >= 36 and pos.y < 56 then
                if light_states.up then
                    del(enemies, enemy)
                    score += score_increase_amount
                    sfx(0)
                end
            elseif pos.y >= 60 then
                lose_condition()
            end
        elseif t == 1 then
            if pos.y >= 72 and pos.y < 85 then
                if light_states.down then
                    del(enemies, enemy)
                    score += score_increase_amount
                    sfx(0)
                end
            elseif pos.y <= 68 then
                lose_condition()
            end
        elseif t == 2 then
            if pos.x >= 36 and pos.x < 60 then
                if light_states.left then
                    del(enemies, enemy)
                    score += score_increase_amount
                    sfx(0)
                end
            elseif pos.x >= 60 then
                lose_condition()
            end
        elseif t == 3 then
            if pos.x >= 68 and pos.x < 85 then
                if light_states.right then
                    del(enemies, enemy)
                    score += score_increase_amount
                    sfx(0)
                end
            elseif pos.x <= 68 then
                lose_condition()
            end
        end
    end
end

function lose_condition()
    game_state = "gameover"
    music_selector()
end