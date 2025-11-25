-- Morph main entry and state loop

-- simple splash using map, then enter planning
function _init()
	g=new_game()
	show_splash=true
	splash_timer=0
	splash_duration=2.5
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
		-- require confirm to advance after exactly filled
		if #g.plan1==ACTIONS_PER_ROUND and plan_confirm_pressed() then
			g.p1_plan_confirmed=true
			g.state=STATE_PLAN_P2
		end
	elseif g.state==STATE_PLAN_P2 then
		local a=read_plan_input_for(2)
		if a and #g.plan2 < ACTIONS_PER_ROUND then push_plan(g.plan2,a) end
		if plan_redo_pressed() then clear_plan(g.plan2) end
		if #g.plan2==ACTIONS_PER_ROUND and plan_confirm_pressed() then
			g.p2_plan_confirmed=true
			begin_resolution(g)
		end
	end
end

function _update()
	if show_splash then
		splash_timer+=1/30
		if splash_timer>=splash_duration or anybtnp() then
			show_splash=false
			start_planning(g)
		end
		return
	end

	-- gameplay
	update_fx()
	if g.state==STATE_PLAN_P1 or g.state==STATE_PLAN_P2 then
		update_planning()
	elseif g.state==STATE_RESOLVE then
		update_resolution(g)
	elseif g.state==STATE_ROUND_END then
		g.timer-=1
		if g.timer<=0 then start_planning(g) end
	elseif g.state==STATE_GAME_OVER then
		if anybtnp() then
			g=new_game()
			start_planning(g)
		end
	end
end

function _draw()
	cls()
	if show_splash then
		map(0,0,0,0,16,16)
		print("morph",56,6,7)
		print("press any button",32,112,7)
		return
	end

	apply_camera_shake()
	-- restore battlefield background map
	draw_background()
	draw_grid()
	if g.state==STATE_PLAN_P1 or g.state==STATE_PLAN_P2 or g.state==STATE_RESOLVE or g.state==STATE_ROUND_END then
		draw_players(g)
		draw_fx()
		draw_hud(g)
		draw_plan_ui(g,1)
		draw_plan_ui(g,2)
		-- centered confirm popups when a plan is filled
		draw_confirm_popup(g,1)
		draw_confirm_popup(g,2)
		if g.state==STATE_RESOLVE then draw_resolution_banner(g) end
	elseif g.state==STATE_GAME_OVER then
		local msg=(g.winner==1 and "p1 ascends!" or "p2 ascends!")
		print(msg,40,60,10)
		print("press any button",34,72,7)
	end
	camera()
end
