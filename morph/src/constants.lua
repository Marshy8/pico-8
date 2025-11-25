-- constants and basic shared types for Morph

-- grid is 1x5 lanes per side (rows 1..5)
GRID_ROWS=5

-- cell box dimensions (each lane box). player sprite will be cropped to 6x6 inside.
-- enlarged cell so full 8x8 sprite fits with padding
CELL_W=12
CELL_H=12
SPR_W=8
SPR_H=8

-- x positions for left and right lanes
LANE_X_LEFT=28
LANE_X_RIGHT=100

-- y positions by row helper
function row_y(row)
	-- adjust spacing for larger boxes
	return 24 + (row-1)*18
end

-- per-round parameters
ACTIONS_PER_ROUND=3

-- animation timing (in frames)
STEP_FRAMES=28 -- duration to play each action step
PROJ_SPEED=4 -- pixels per frame for projectile

-- damage / morph
BASE_DAMAGE=1
WIN_MORPHS=4

-- buttons (ids are per PICO-8)
BTN_LEFT=0
BTN_RIGHT=1
BTN_UP=2
BTN_DOWN=3
BTN_O=4
BTN_X=5

-- action ids
ACT_UP=1
ACT_DOWN=2
ACT_ATK=3
ACT_BLK=4

-- state machine ids
STATE_SPLASH=1
STATE_PLAN_P1=2
STATE_PLAN_P2=3
STATE_RESOLVE=4
STATE_ROUND_END=5
STATE_GAME_OVER=6

-- sprite ids placeholders configured in sprites.lua
-- see sprites.lua for mapping comments

-- utility: clamp row to grid
function clamp_row(r)
	if r<1 then return 1 end
	if r>GRID_ROWS then return GRID_ROWS end
	return r
end
