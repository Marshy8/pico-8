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
	-- center divider
	line(64,8,64,120,6)
end

function draw_players(g)
	draw_player(LANE_X_LEFT, row_y(g.p1.row), 1, g.p1.morph)
	if g.p1.blocking then draw_block(LANE_X_LEFT, row_y(g.p1.row)) end

	draw_player(LANE_X_RIGHT, row_y(g.p2.row), 2, g.p2.morph)
	if g.p2.blocking then draw_block(LANE_X_RIGHT, row_y(g.p2.row)) end
end

function draw_hud(g)
	-- morph bars
	rectfill(2,2,60,10,0)
	print("p1 morph:"..g.p1.morph.."/"..WIN_MORPHS,4,4,7)
	rectfill(68,2,126,10,0)
	print("p2 morph:"..g.p2.morph.."/"..WIN_MORPHS,70,4,7)
	-- charge indicators (next round double)
	if g.p1.double_ready then print("x2 next",4,12,10) end
	if g.p2.double_ready then print("x2 next",98,12,10) end
	if g.p1.double_active then print("x2!",30,12,11) end
	if g.p2.double_active then print("x2!",94,12,11) end
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
	if a==ACT_BLK then return "[]" end
	return "?"
end

function draw_resolution_banner(g)
	local step=g.step_index
	print("resolve step "..step.."/"..ACTIONS_PER_ROUND,40,116,9)
end
