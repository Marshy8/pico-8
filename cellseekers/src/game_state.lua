function draw_start_screen()
    map(16, 0, 0, 0, 16, 16)
    print("cell", 45, 60, 9)
    print("seekers", 65, 60, 0)
    print("z", 62, 80, 0)
    print("to start", 49, 90, 0)
    print("by:marshy", 90, 120, 0)
end

function draw_game()
    map(0, 0, 0, 0, 16, 16)
    draw_all_lights()
    draw_enemy()
    draw_energy_bar()
    draw_minigame_sprites()
    draw_score()
end

function draw_game_over()
    if game_state == "gameover" then
        draw_game()
        rectfill(20, 40, 108, 80, 0)
        print("game over", 47, 50, 8)
        print("press z to restart", 29, 60, 7)
        print("press x to go to menu", 23, 70, 7)
    end
end