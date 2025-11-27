-- core game model and round resolution

function new_game()
	local g={}
	g.state=STATE_SPLASH
	g.timer=0
	g.round=0 -- will increment when planning starts
	-- randomize character and projectile once per game
	local p1_proj=PROJ_POOL[flr(rnd(#PROJ_POOL))+1]
	local p2_proj=PROJ_POOL[flr(rnd(#PROJ_POOL))+1]
	local p1_char=CHAR_SETS[flr(rnd(#CHAR_SETS))+1]
	local p2_char=CHAR_SETS[flr(rnd(#CHAR_SETS))+1]
	g.p1={row=3,morph=0,hp=1, was_hit=false, blundering=false, double_count=0, current_round_blunders=0, proj_spr=p1_proj, char_set=p1_char}
	g.p2={row=3,morph=0,hp=1, was_hit=false, blundering=false, double_count=0, current_round_blunders=0, proj_spr=p2_proj, char_set=p2_char}
	g.plan1={}
	g.plan2={}
	g.p1_plan_confirmed=false
	g.p2_plan_confirmed=false
	g.step_index=1
	g.step_timer=0
	g.winner=nil
	return g
end

function start_planning(g)
	-- advance round counter
	g.round=g.round+1
	g.plan1={}
	g.plan2={}
	g.p1_plan_confirmed=false
	g.p2_plan_confirmed=false
	g.p1.was_hit=false
	g.p2.was_hit=false
	g.p1.blundering=false
	g.p2.blundering=false
	g.p1.current_round_blunders=0
	g.p2.current_round_blunders=0
	-- character and projectile stay the same for the whole match
	g.state=STATE_PLAN_P1
end

local function consume_double_if_active(attacker)
	local total_count = attacker.double_count + attacker.current_round_blunders
	if total_count>0 then
		local mult=2^total_count
		attacker.double_count=0
		attacker.current_round_blunders=0
		return mult
	end
	return 1
end

function begin_resolution(g)
	g.state=STATE_RESOLVE
	g.step_index=1
	g.step_timer=STEP_FRAMES
	g.p1.blundering=false
	g.p2.blundering=false
	-- x2 is only gained from surviving blunder, no pre-round setup needed
end

local function perform_move(p, act)
	if act==ACT_UP then p.row=clamp_row(p.row-1) end
	if act==ACT_DOWN then p.row=clamp_row(p.row+1) end
end

local function will_attack(act) return act==ACT_ATK end
local function will_blunder(act) return act==ACT_BLUNDER end

local function resolve_attacks(g, a1, a2)
	-- set blundering flags for this step
	g.p1.blundering = will_blunder(a1)
	g.p2.blundering = will_blunder(a2)
	
	-- grant blunder stack immediately when blundering (before attacks resolve)
	if g.p1.blundering then g.p1.current_round_blunders+=1 end
	if g.p2.blundering then g.p2.current_round_blunders+=1 end

	-- if attacking, spawn projectile visuals (hit handled by effects on collision)
	if will_attack(a1) then add_proj(LANE_X_LEFT, row_y(g.p1.row), 1, 1, g.p1.proj_spr) end
	if will_attack(a2) then add_proj(LANE_X_RIGHT, row_y(g.p2.row), -1, 2, g.p2.proj_spr) end
end

local function step_resolve(g)
	local i=g.step_index
	local a1=g.plan1[i]
	local a2=g.plan2[i]
	-- first movement
	perform_move(g.p1,a1)
	perform_move(g.p2,a2)
	-- then attacks and blocks
	resolve_attacks(g,a1,a2)
end

-- called by effects when a projectile collides
function attack_hit(attacker)
	-- attacker: 1 or 2
	-- attacker gains morph on hit, defender takes damage marker
	if attacker==1 then
		local mult=consume_double_if_active(g.p1)
		local morph_gain=BASE_DAMAGE*mult
		local is_double=mult>1 or g.p2.blundering
		-- if defender is blundering, double the morph gain
		if g.p2.blundering then morph_gain=morph_gain*2 end
		g.p1.morph=min(WIN_MORPHS, g.p1.morph+morph_gain)
		g.p2.was_hit=true
		add_hit(LANE_X_RIGHT, row_y(g.p2.row), is_double)
	else
		local mult=consume_double_if_active(g.p2)
		local morph_gain=BASE_DAMAGE*mult
		local is_double=mult>1 or g.p1.blundering
		-- if defender is blundering, double the morph gain
		if g.p1.blundering then morph_gain=morph_gain*2 end
		g.p2.morph=min(WIN_MORPHS, g.p2.morph+morph_gain)
		g.p1.was_hit=true
		add_hit(LANE_X_LEFT, row_y(g.p1.row), is_double)
	end
end

local function after_round_check_double(g)
	-- consolidate current round blunders into permanent stack if survived
	if not g.p1.was_hit then 
		g.p1.double_count=g.p1.double_count+g.p1.current_round_blunders
	else
		-- lose all stacks on hit
		g.p1.double_count=0
	end
	if not g.p2.was_hit then 
		g.p2.double_count=g.p2.double_count+g.p2.current_round_blunders
	else
		-- lose all stacks on hit
		g.p2.double_count=0
	end
end

function update_resolution(g)
	g.step_timer-=1
	if g.step_timer==STEP_FRAMES-1 then
		-- on first frame of step, execute logic
		step_resolve(g)
	end
	if g.step_timer<=0 then
		g.step_index+=1
		if g.p1.morph>=WIN_MORPHS or g.p2.morph>=WIN_MORPHS then
			-- both can win if they both reach WIN_MORPHS
			local p1_wins = g.p1.morph>=WIN_MORPHS
			local p2_wins = g.p2.morph>=WIN_MORPHS
			local w = (p1_wins and p2_wins) and 3 or (p1_wins and 1 or 2)
			begin_game_over(g,w)
			return
		end
		if g.step_index>ACTIONS_PER_ROUND then
			g.state=STATE_ROUND_END
			-- evaluate block/charge
			after_round_check_double(g)
			g.timer=30
		else
			g.step_timer=STEP_FRAMES
			g.p1.blundering=false
			g.p2.blundering=false
		end
	end
end

-- victory animation state
function begin_game_over(g, winner)
	g.winner=winner
	g.state=STATE_GAME_OVER
	-- setup ascend/sink offsets
	g.victory={
		side=winner,
		t=0,
		phase=0, -- 0: flicker, 1: ascend/sink
		win_y_offset=0,
		lose_y_offset=0,
		finished=false
	}
	start_victory_effect(winner)
end

function update_game_over(g)
	if not g.victory or g.victory.finished then return end
	g.victory.t+=1
	-- after 0.5s (~15 frames), switch to ascend phase
	if g.victory.phase==0 and g.victory.t>=15 then
		g.victory.phase=1
		g.victory.t=0
	end
	if g.victory.phase==1 then
		-- winner ascends up, loser sinks down at same speed
		local spd=2
		g.victory.win_y_offset = g.victory.win_y_offset + spd
		g.victory.lose_y_offset = g.victory.lose_y_offset + spd
		-- finish when soul reaches top of screen
		local base_y = (g.victory.side==1) and row_y(g.p1.row) or row_y(g.p2.row)
		-- top-left y of soul sprite as drawn in render
		local top_y = base_y-4 - g.victory.win_y_offset
		-- ensure entire 8px sprite is off-screen; go further to bypass platform clamping
		local loser_base_y = (g.victory.side==1) and row_y(g.p2.row) or row_y(g.p1.row)
		local loser_y = loser_base_y + g.victory.lose_y_offset
		-- for both win, only check if souls are off top (no loser)
		local finish_cond = (g.victory.side==3) and (top_y<=-20) or (top_y<=-20 and loser_y>=136)
		if finish_cond then
			-- stop any screen shake to avoid visual clamping artifacts
			shake_timer=0
			g.victory.finished=true
		end
	end
end
