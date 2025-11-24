function music_selector()
    if game_state == "start" then
        music(-1)
        music(0)
    elseif game_state == "play" and start_to_play == false then
        music(-1)
        music(0)
    elseif game_state == "gameover" then
        music(-1)
        music(1)
    end
end