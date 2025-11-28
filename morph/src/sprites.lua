-- sprite index placeholders for Morph
-- You can draw sprites in these slots later.
-- Players (left side facing right, right side facing left)
--  1: p1 base form
--  2: p1 morph 1
--  3: p1 morph 2
--  4: p1 morph 4 (ascend)
-- 5: p2 base form
-- 6: p2 morph 1
-- 7: p2 morph 2
-- 8: p2 morph 4 (ascend)
-- 32..35: projectile frames (beam/bolt)
-- 128: block/charge effect (shield)
-- 96..99: hit burst / morph-up effect (moved to avoid p2 overlap)

SP_P1={1,2,3,4,5}
SP_P2={5,6,7,8,9} -- if these are blank, we'll auto-flip SP_P1 for side 2
-- fireball sprite index
SP_PROJ={64}
SP_BLOCK=128
SP_HIT={96,97,98,99}

-- safe draw wrappers: if sprite is blank, fallback to shapes
function draw_player(x,y,side,morph,char_set)
	-- use assigned character set for this player
	-- player 2 is always flipped horizontally
	local set = char_set or ((side==1) and SP_P1 or SP_P2)
	-- cap to 4 pre-ascend sprites
	local mi = mid(1, morph+1, min(4, #set))
	local idx = set[mi]
	if idx~=nil then
		spr(idx, x-4, y-4, 1, 1, side==2, false)
	else
		circfill(x,y,4, side==1 and 12 or 8)
	end
end

-- cropped 6x6 center of 8x8 sprite so box feels tighter
-- deprecated cropped draw (kept for reference): using full 8x8 now
-- function draw_player6(...) end

function draw_block(x,y,side)
	if SP_BLOCK and SP_BLOCK>0 then
		spr(SP_BLOCK,x-4,y-4,1,1,side==2,false)
	else
		circ(x,y,6,11)
	end
end

function draw_projectile(x,y,frame,proj_spr,owner)
       local idx=proj_spr or SP_PROJ[(frame%#SP_PROJ)+1]
       if idx and idx>0 then
	       spr(idx,x-4,y-4,1,1,owner==2,false)
       else
	       rectfill(x-2,y-1,x+2,y+1,10)
       end
end

function draw_hit(x,y,frame)
	local idx=SP_HIT[(frame%#SP_HIT)+1]
	if idx and idx>0 then
		spr(idx,x-4,y-4)
	else
		for i=0,4 do circ(x,y,i,9) end
	end
end
