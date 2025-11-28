function _init()
	g=new_game()
	show_splash=true
    -- start splash music immediately
    music(0)
    -- init sprite parade for splash
    parade={}
    local function init_parade()
        parade={}
        for i=1,16 do
            -- choose sprite index 1..28 (exclude 0)
            local idx=1+flr(rnd(28))
            -- keep sprites near center horizontal line and away from logo
            local y=56+flr(rnd(16)) -- 56..72
            -- bias: more come from the right moving left
            local dir = (rnd(1) < 0.7) and -1 or 1
            local x = dir==-1 and 128+rnd(32) or -16-rnd(32)
            local spd=0.6+rnd(1.4)
            add(parade,{idx=idx,x=x,y=y,dir=dir,spd=spd})
        end
    end
    init_parade()
end

local function anybtnp()
	for i=0,5 do if btnp(i) then return true end end
	return false
end

local function update_planning()
	if g.state==STATE_PLAN_P1 then
		local a=read_plan_input_for(1)
		if a and #g.plan1 < ACTIONS_PER_ROUND then push_plan(g.plan1,a) end
		if plan_redo_pressed() then clear_plan(g.plan1) end
		-- allow confirm anytime; missing steps will be no-ops
		if plan_confirm_pressed() then
			g.p1_plan_confirmed=true
			g.state=STATE_PLAN_P2
		end
	elseif g.state==STATE_PLAN_P2 then
		local a=read_plan_input_for(2)
		if a and #g.plan2 < ACTIONS_PER_ROUND then push_plan(g.plan2,a) end
		if plan_redo_pressed() then clear_plan(g.plan2) end
		if plan_confirm_pressed() then
			g.p2_plan_confirmed=true
			begin_resolution(g)
		end
	end
end

function _update()
    if show_splash then
        -- update sprite parade motion
        if parade then
            for p in all(parade) do
                p.x += p.spd * p.dir
                -- wrap around when off-screen
                if p.dir==1 and p.x>144 then
                    p.x=-16
                    p.y=56+flr(rnd(16))
                    p.spd=0.5+rnd(1.5)
                elseif p.dir==-1 and p.x<-32 then
                    p.x=128
                    p.y=56+flr(rnd(16))
                    p.spd=0.5+rnd(1.5)
                end
            end
        end
        -- stay on splash until a button is pressed
        if anybtnp() then
            show_splash = false
            start_planning(g)
        end
        return
    end

    -- gameplay
    update_fx()
    if g.state == STATE_PLAN_P1 or g.state == STATE_PLAN_P2 then
        update_planning()
    elseif g.state == STATE_RESOLVE then
        update_resolution(g)
    elseif g.state == STATE_ROUND_END then
        g.timer -= 1
        if g.timer <= 0 then start_planning(g) end
    elseif g.state == STATE_GAME_OVER then
        update_game_over(g)
        if anybtnp() and g.victory and g.victory.finished then
            stop_victory_effect()
            g = new_game()
            music(0) -- reset to calm gothic music
            start_planning(g)
        end
    end
end

function _draw()
    cls()
    if show_splash then
        cls(0)
        -- Clean, readable MORPH logo: white fill, black outline, subtle rainbow shadow
        local logo = "MORPH"
            local logo_scale = 1
        local base_x = 64 - flr((#logo * 4 * logo_scale) / 2)
        local base_y = 24
        -- drop shadow with rainbow tint
        local shadow_colors = {8,9,10,11,12}
        for i=1,#shadow_colors do
            local sx = base_x + i-1
            local sy = base_y + i-1
            for dx=0,logo_scale-1 do
                for dy=0,logo_scale-1 do
                    print(logo, sx+dx, sy+dy, shadow_colors[i])
                end
            end
        end
        -- black outline around the text
        local outline_offsets={{-1,0},{1,0},{0,-1},{0,1},{-1,-1},{-1,1},{1,-1},{1,1}}
        for o in all(outline_offsets) do
            for dx=0,logo_scale-1 do
                for dy=0,logo_scale-1 do
                    print(logo, base_x+dx+o[1], base_y+dy+o[2], 0)
                end
            end
        end
            -- solid center text
            print(logo, base_x, base_y, 7)
        -- moving sprite parade
        if parade then
            for p in all(parade) do
                spr(p.idx, p.x, p.y, 1, 1, false, false)
            end
        end

        -- flashing "press any button" text
        if flr(time() * 2) % 2 == 0 then
            print("press any button", 32, 100, 7)
        end
		print("by: maarshy & mike", 28, 120, 7)

        return
    end

    apply_camera_shake()
    -- restore battlefield background map
    draw_background()
    draw_grid()
    if g.state == STATE_PLAN_P1 or g.state == STATE_PLAN_P2 or g.state == STATE_RESOLVE or g.state == STATE_ROUND_END then
        draw_players(g)
        draw_fx()
        draw_hud(g)
        draw_plan_ui(g, 1)
        draw_plan_ui(g, 2)
        -- centered confirm popups when a plan is filled
        draw_confirm_popup(g, 1)
        draw_confirm_popup(g, 2)
        if g.state == STATE_RESOLVE then draw_resolution_banner(g) end
    elseif g.state == STATE_GAME_OVER then
        draw_players(g)
        draw_fx()
        local msg = (g.winner == 3 and "both ascend!" or (g.winner == 1 and "p1 ascends!" or "p2 ascends!"))
        print(msg, 40, 12, 10)
        if g.victory and g.victory.finished then
            print("press any button", 34, 108, 7)
        end
    end
    camera()
end
