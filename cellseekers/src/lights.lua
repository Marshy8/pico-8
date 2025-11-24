light_states = {
    left = false,
    right = false,
    up = false,
    down = false
}
energy = 100
max_energy = 100
energy_decrease_rate = 0.1
energy_recharge_rate = 0.005
lights_locked = false
lock_timer = 0
lock_duration = 50
light_sound_timer = 0

function light_switch()
    if lights_locked then return end
    if energy > 0 then
        if btnp(0) then
            if not light_states.left then sfx(4) end
            light_states.left = not light_states.left
        elseif btnp(1) then
            if not light_states.right then sfx(4) end
            light_states.right = not light_states.right
        elseif btnp(2) then
            if not light_states.up then sfx(4) end
            light_states.up = not light_states.up
        elseif btnp(3) then
            if not light_states.down then sfx(4) end
            light_states.down = not light_states.down
        end
    end
end

function update_light_sound()
    if light_states.left or light_states.right or light_states.up or light_states.down then
        light_sound_timer -= 1
        if light_sound_timer <= 0 then
            sfx(4)
            light_sound_timer = 1
        end
    else
        light_sound_timer = 0
    end
end

function disable_lights_if_empty()
    if energy <= 0 then
        for k in pairs(light_states) do
            light_states[k] = false
        end
    end
end

function light_drain()
    if lights_locked then return end
    local lights_on = 0
    for _, v in pairs(light_states) do
        if v then lights_on += 1 end
    end

    energy -= lights_on * energy_decrease_rate
    if energy < 0 then energy = 0 end

    disable_lights_if_empty()
end

function light_recharge()
    if lights_locked then return end
    local any_on = false
    for _, v in pairs(light_states) do
        if v then
            any_on = true
            break
        end
    end

    if not any_on and energy < max_energy then
        energy += energy_recharge_rate
        if energy > max_energy then energy = max_energy end
    end
end

function lock_lights()
    lights_locked = true
    lock_timer = lock_duration
    turn_off_all_lights()
    sfx(3)
end

function turn_off_all_lights()
    for k in pairs(light_states) do
        light_states[k] = false
    end
end

function update_lock()
    if lights_locked then
        lock_timer -=1
        if lock_timer <= 0 then
            lights_locked = false
        end
    end
end

function draw_all_lights()
    if light_states.up then
        draw_sprite_block_2x2(7, 5, 32, 33, 48, 49)
    end
    if light_states.down then
        draw_sprite_block_2x2(7, 9, 34, 35, 50, 51)
    end
    if light_states.left then
        draw_sprite_block_2x2(5, 7, 38, 39, 54, 55)
    end
    if light_states.right then
        draw_sprite_block_2x2(9, 7, 36, 37, 52, 53)
    end
end

function draw_sprite_block_2x2(tx, ty, s1, s2, s3, s4)
    spr(s1, tx * 8, ty * 8)
    spr(s2, (tx+1) * 8, ty * 8)
    spr(s3, tx * 8, (ty+1) * 8)
    spr(s4, (tx+1) * 8, (ty+1) * 8)
end

function draw_energy_bar()
    local bar_width = 100
    local bar_height = 3
    local bar_x = (128 - bar_width) / 2
    local bar_y = 2
    local fill_width = bar_width * (energy / max_energy)

    rect(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, 1) -- border

    local color
    if lights_locked then
        color = (flr(time()*8)%2==0) and 8 or 9
    elseif energy > 50 then
        color = 11
    elseif energy > 25 then
        color = 10
    else
        color = 8
    end

    rectfill(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, color)
end

