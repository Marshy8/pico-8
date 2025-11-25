-- core game model and round resolution

function new_game()
	local g={}
	g.state=STATE_SPLASH
	g.timer=0
	g.round=0 -- will increment when planning starts
	g.p1={row=3,morph=0,hp=1, was_hit=false, blocking=false, double_ready=false, double_active=false}
	g.p2={row=3,morph=0,hp=1, was_hit=false, blocking=false, double_ready=false, double_active=false}
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
	g.p1.blocking=false
	g.p2.blocking=false
	g.state=STATE_PLAN_P1
end

local function consume_double_if_active(attacker)
	if attacker.double_active then
		attacker.double_active=false
		return 2
	end
	return 1
end

local function prepare_double_for_next_round(p)
	-- called at round end if player blocked at least once and was not hit
	p.double_ready=true
end

local function begin_next_round_apply_double(g)
	-- activate double for players who earned it last round
	for p in all({g.p1,g.p2}) do
		if p.double_ready then
			p.double_ready=false
			p.double_active=true
		else
			p.double_active=false
		end
	end
end

function begin_resolution(g)
	g.state=STATE_RESOLVE
	g.step_index=1
	g.step_timer=STEP_FRAMES
	g.p1.blocking=false
	g.p2.blocking=false
	begin_next_round_apply_double(g)
end

local function perform_move(p, act)
	if act==ACT_UP then p.row=clamp_row(p.row-1) end
	if act==ACT_DOWN then p.row=clamp_row(p.row+1) end
end

local function will_attack(act) return act==ACT_ATK end
local function will_block(act) return act==ACT_BLK end

local function resolve_attacks(g, a1, a2)
	-- set blocking flags for this step
	g.p1.blocking = will_block(a1)
	g.p2.blocking = will_block(a2)

	-- if attacking, spawn projectile visuals
	if will_attack(a1) then add_proj(LANE_X_LEFT, row_y(g.p1.row), 1) end
	if will_attack(a2) then add_proj(LANE_X_RIGHT, row_y(g.p2.row), -1) end

	-- check hits: attacks travel straight; if in same row this step, they connect
	-- simultaneous resolution: both can hit in same step
	if will_attack(a1) and g.p1.row==g.p2.row then
		local mult=consume_double_if_active(g.p1)
		if not g.p2.blocking then
			g.p2.morph+=BASE_DAMAGE*mult
			g.p2.was_hit=true
			add_hit(LANE_X_RIGHT, row_y(g.p2.row))
		else
			-- blocked, no hit
		end
	end
	if will_attack(a2) and g.p2.row==g.p1.row then
		local mult=consume_double_if_active(g.p2)
		if not g.p1.blocking then
			g.p1.morph+=BASE_DAMAGE*mult
			g.p1.was_hit=true
			add_hit(LANE_X_LEFT, row_y(g.p1.row))
		else
			-- blocked, no hit
		end
	end
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

local function after_round_check_double(g)
	-- if player used block at least once and was not hit during the whole round, they earn double next round
	local p1_blocked=false
	local p2_blocked=false
	for i=1,#g.plan1 do if g.plan1[i]==ACT_BLK then p1_blocked=true break end end
	for i=1,#g.plan2 do if g.plan2[i]==ACT_BLK then p2_blocked=true break end end
	if p1_blocked and not g.p1.was_hit then prepare_double_for_next_round(g.p1) end
	if p2_blocked and not g.p2.was_hit then prepare_double_for_next_round(g.p2) end
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
			g.winner=(g.p1.morph>=WIN_MORPHS) and 1 or 2
			g.state=STATE_GAME_OVER
			return
		end
		if g.step_index>ACTIONS_PER_ROUND then
			g.state=STATE_ROUND_END
			-- evaluate block/charge
			after_round_check_double(g)
			g.timer=30
		else
			g.step_timer=STEP_FRAMES
			g.p1.blocking=false
			g.p2.blocking=false
		end
	end
end
