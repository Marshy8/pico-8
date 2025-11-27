-- rendering functions for Morph

function draw_background()
	-- battle arena map (second 16x16 chunk to the right of splash)
	-- splash uses map(0,0,...) earlier; here we draw from x=16
	map(16,0,0,0,16,16)
end

function draw_grid()
	-- draw 5 lane boxes per side
	for r=1,GRID_ROWS do
		local y=row_y(r)
		local l1x0=LANE_X_LEFT-CELL_W/2
		local l1x1=LANE_X_LEFT+CELL_W/2-1
		local r1x0=LANE_X_RIGHT-CELL_W/2
		local r1x1=LANE_X_RIGHT+CELL_W/2-1
		local y0=y-CELL_H/2
		local y1=y+CELL_H/2-1
		rect(l1x0,y0,l1x1,y1,6)
		rect(r1x0,y0,r1x1,y1,6)
	end
end

function draw_players(g)
	-- game over animation: winner ascends, loser sinks
	if g.state==STATE_GAME_OVER and g.victory then
		local win=g.victory.side
		local win_off=g.victory.win_y_offset or 0
		local lose_off=g.victory.lose_y_offset or 0
		local p1y=row_y(g.p1.row)
		local p2y=row_y(g.p2.row)
		-- phase 0: brief flicker cycling winner's morph sprites
		if g.victory.phase==0 then
			local frame=(time()*30)%8
			local spr_id=SP_ASCEND -- base soul sprite
			-- occasionally flash between soul and player sprite to imply "any of them"
			local use_player_spr = frame<4
			if win==3 then
				-- both win: both flicker
				if use_player_spr then draw_player(LANE_X_LEFT, p1y, 1, g.p1.morph, g.p1.char_set) else spr(SP_ASCEND, LANE_X_LEFT-4, p1y-4, 1, 1, false, false) end
				if use_player_spr then draw_player(LANE_X_RIGHT, p2y, 2, g.p2.morph, g.p2.char_set) else spr(SP_ASCEND, LANE_X_RIGHT-4, p2y-4, 1, 1, true, false) end
			elseif win==1 then
				if use_player_spr then draw_player(LANE_X_LEFT, p1y, 1, g.p1.morph, g.p1.char_set) else spr(SP_ASCEND, LANE_X_LEFT-4, p1y-4, 1, 1, false, false) end
				-- loser idle
				draw_player(LANE_X_RIGHT, p2y, 2, g.p2.morph, g.p2.char_set)
			else
				if use_player_spr then draw_player(LANE_X_RIGHT, p2y, 2, g.p2.morph, g.p2.char_set) else spr(SP_ASCEND, LANE_X_RIGHT-4, p2y-4, 1, 1, true, false) end
				-- loser idle
				draw_player(LANE_X_LEFT, p1y, 1, g.p1.morph, g.p1.char_set)
			end
		else
			-- phase 1: winner ascends using sprite 63 (soul), loser sinks
			-- add a small down-then-up arc at the start of phase 1
			local dip=0
			if g.victory.t<8 then dip=-(g.victory.t) end -- small downward dip first
			local soul_y_left = p1y-4 - (win_off+dip)
			local soul_y_right = p2y-4 - (win_off+dip)
			if win==3 then
				-- both win: both ascend
				if soul_y_left>-8 then spr(SP_ASCEND, LANE_X_LEFT-4, soul_y_left, 1, 1, false, false) end
				if soul_y_right>-8 then spr(SP_ASCEND, LANE_X_RIGHT-4, soul_y_right, 1, 1, true, false) end
			elseif win==1 then
				-- only draw soul if still on-screen
				if soul_y_left>-8 then spr(SP_ASCEND, LANE_X_LEFT-4, soul_y_left, 1, 1, false, false) end
				-- loser sinks (stop drawing once fully off-screen)
				local ly = p2y + lose_off
				if ly<136 then draw_player(LANE_X_RIGHT, ly, 2, g.p2.morph, g.p2.char_set) end
			else
				if soul_y_right>-8 then spr(SP_ASCEND, LANE_X_RIGHT-4, soul_y_right, 1, 1, true, false) end
				-- loser sinks (stop drawing once fully off-screen)
				local ly = p1y + lose_off
				if ly<136 then draw_player(LANE_X_LEFT, ly, 1, g.p1.morph, g.p1.char_set) end
			end
		end
		return
	end

	-- normal states: show blunder red outline and players
	if g.p1.blundering then
		local y=row_y(g.p1.row)
		rect(LANE_X_LEFT-CELL_W/2,y-CELL_H/2,LANE_X_LEFT+CELL_W/2-1,y+CELL_H/2-1,8)
	end
	if g.p2.blundering then
		local y=row_y(g.p2.row)
		rect(LANE_X_RIGHT-CELL_W/2,y-CELL_H/2,LANE_X_RIGHT+CELL_W/2-1,y+CELL_H/2-1,8)
	end
	draw_player(LANE_X_LEFT, row_y(g.p1.row), 1, g.p1.morph, g.p1.char_set)
	draw_player(LANE_X_RIGHT, row_y(g.p2.row), 2, g.p2.morph, g.p2.char_set)
end

function draw_hud(g)
	-- morph bars
	rectfill(2,2,60,10,0)
	print("p1 morph:"..g.p1.morph.."/"..WIN_MORPHS,4,4,7)
	rectfill(68,2,126,10,0)
	print("p2 morph:"..g.p2.morph.."/"..WIN_MORPHS,70,4,7)
	-- charge indicators (show total including current round: 2, 4, 8, 16...)
	local p1_total = g.p1.double_count + g.p1.current_round_blunders
	local p2_total = g.p2.double_count + g.p2.current_round_blunders
	if p1_total>0 then print("x"..(2^p1_total).."!",22,12,11) end
	if p2_total>0 then print("x"..(2^p2_total).."!",94,12,11) end
end

function draw_plan_ui(g,who)
	local y=116 -- lowered below movement boxes.
	local x=who==1 and 6 or 82
	local label=who==1 and "p1 plan:" or "p2 plan:"
	print(label,x,y-9,7)
	local plan=(who==1) and g.plan1 or g.plan2
	local confirmed=(who==1) and g.p1_plan_confirmed or g.p2_plan_confirmed
	local show_icons = (not confirmed) or (g.state==STATE_RESOLVE or g.state==STATE_ROUND_END)
	for i=1,ACTIONS_PER_ROUND do
		local ax=x+(i-1)*14
		if confirmed then
			rectfill(ax,y,ax+12,y+9,3)
			rect(ax,y,ax+12,y+9,11)
		else
			rect(ax,y,ax+12,y+9,6)
		end
		local a=plan[i]
		if show_icons and a then
			print(action_icon(a,who),ax+3,y+3,11)
		end
	end
end

function draw_confirm_popup(g,who)
	-- centered popup when a plan has 3 actions and awaiting confirm
	local waiting=(who==1 and g.state==STATE_PLAN_P1 and #g.plan1==ACTIONS_PER_ROUND and not g.p1_plan_confirmed)
		or (who==2 and g.state==STATE_PLAN_P2 and #g.plan2==ACTIONS_PER_ROUND and not g.p2_plan_confirmed)
	if not waiting then return end
	local w,h=96,24
	local x0,y0=64-w/2,64-h/2
	rectfill(x0,y0,x0+w,y0+h,0)
	rect(x0,y0,x0+w,y0+h,7)
	local who_label=(who==1) and "p1 ready?" or "p2 ready?"
	print(who_label,64-#who_label*2,64-8,10)
	local msg="o confirm   x clear"
	print(msg,64-#msg*2,64+2,7)
end

function action_icon(a,who)
	-- simple text icons; could swap for tiny sprites later
	if a==ACT_UP then return "^" end
	if a==ACT_DOWN then return "v" end
	if a==ACT_ATK then return who==1 and ">" or "<" end
	if a==ACT_BLUNDER then return "!!" end
	return "?"
end

function draw_resolution_banner(g)
	local step=g.step_index
	print("resolve step "..step.."/"..ACTIONS_PER_ROUND,40,116,9)
end
