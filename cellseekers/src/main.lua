game_state = "start"
start_to_play = true

function _init()
    music_selector()
    score = 0
    energy = max_energy
    random_string = {flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2)), flr(rnd(2))}
    zx_sprites = {false, false, false, false, false}
    light_states = {
    left = false,
    right = false,
    up = false,
    down = false
    }
    index = 1
    enemies = {}
end

function _update()
    if game_state == "start" then
        if btnp(4) then
            game_state = "play"
            start_to_play = true
            _init()
        end
    elseif game_state == "play" then
        light_switch()
        light_drain()
        light_recharge()
        check_minigame_input()
        update_lock()
        spawn_enemy()
        move_enemy()
        check_location()
        update_light_sound()
    elseif game_state == "gameover" then
        if btnp(4) then
            game_state = "play"
            start_to_play = false
            _init()
        elseif btnp(5) then
            game_state = "start"
            start_to_play = true
            _init()
        end
    end
end

function _draw()
    cls()
    if game_state == "start" then
        draw_start_screen()
    elseif game_state == "play" then
        draw_game()
    elseif game_state == "gameover" then
        draw_game_over()
    end
end
