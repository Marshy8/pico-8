-- input collection for planning phase

-- map forward/back per player to attack/block
-- single-controller planning input
-- player parameter only affects forward/back interpretation
function read_plan_input_for(player)
	local up=btnp(BTN_UP,0)
	local down=btnp(BTN_DOWN,0)
	local left=btnp(BTN_LEFT,0)
	local right=btnp(BTN_RIGHT,0)
	-- explicit mapping: left=blunder for p1, attack for p2; right=attack for p1, blunder for p2
	if up then return ACT_UP end
	if down then return ACT_DOWN end
	if player==1 then
		if left then return ACT_BLUNDER end
		if right then return ACT_ATK end
	else
		-- player 2: facing left, so left=attack, right=blunder
		if left then return ACT_ATK end
		if right then return ACT_BLUNDER end
	end
	return nil
end

-- confirm when plan filled: BTN_O (index 0)
function plan_confirm_pressed()
	return btnp(BTN_O,0)
end

-- redo (pop last) BTN_X (index 0)
function plan_redo_pressed()
	return btnp(BTN_X,0)
end

-- enforce: at most 2 identical actions in a row
local function violates_triple(plan, act)
	if #plan>=2 then
		return plan[#plan]==act and plan[#plan-1]==act
	end
	return false
end

function push_plan(plan, act)
	if act and #plan < ACTIONS_PER_ROUND then
		add(plan, act)
	end
end

function pop_plan(plan)
	if #plan>0 then deli(plan, #plan) end
end

function clear_plan(plan)
	while #plan>0 do deli(plan,#plan) end
end

