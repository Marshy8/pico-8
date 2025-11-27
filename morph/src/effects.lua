-- lightweight effects system: projectiles, hits, and shake

fx={} -- active foreground effects (projectiles, hits)
shake_timer=0
shake_mag=0
flash_timer=0
flash_color=7
flash_is_double=false

-- victory particle mode
victory_active=false
victory_side=nil -- 1 or 2

-- background particle fields (ash + embers always active)
bg_particles={}

function spawn_ash(intensity)
	local p={}
	p.x=rnd(128)
	p.y=-4
	p.spd=0.4+ rnd(0.4) + intensity*0.4
	p.dx=rnd(0.3)-0.15
	p.col=5
	p.type="ash"
	p.life=flr(140/p.spd)
	add(bg_particles,p)
end

function spawn_ember(intensity)
	local p={}
	p.x=rnd(128)
	p.y=-4
	p.spd=0.6+ rnd(0.6) + intensity*0.6
	p.dx=rnd(0.4)-0.2
	p.col=(rnd()<0.5) and 9 or 10
	p.type="ember"
	p.life=flr(120/p.spd)
	add(bg_particles,p)
end

function update_bg_particles()
	if victory_active then
		-- special particles: winning side white/pink rising, losing side fiery embers
		-- for both win (side==3), whole screen white/pink rising
		local win_left = (victory_side==1)
		local both_win = (victory_side==3)
		local win_min = both_win and 0 or (win_left and 0 or 64)
		local win_max = both_win and 127 or (win_left and 63 or 127)
		local lose_min = both_win and -1 or (win_left and 64 or 0)
		local lose_max = both_win and -1 or (win_left and 127 or 63)
		local cap=240
		if #bg_particles<cap then
			-- winning side stream upward
			-- stronger stream on winning side
			if rnd()<0.96 then
				local p={}
				p.x=win_min + rnd(win_max-win_min)
				p.y=128
				p.spd=-(1.2+rnd(1.0))
				p.dx=rnd(0.2)-0.1
				p.col=(rnd()<0.5) and 7 or 14 -- white or pink
				p.type="victory"
				p.life=flr(160/abs(p.spd))
				add(bg_particles,p)
			end
			-- losing side embers downward (skip if both win)
			if not both_win and rnd()<0.92 then
				local p={}
				p.x=lose_min + rnd(lose_max-lose_min)
				p.y=-4
				p.spd=1.0+rnd(1.0)
				p.dx=rnd(0.3)-0.15
				p.col=(rnd()<0.5) and 9 or 10
				p.type="ember"
				p.life=flr(140/p.spd)
				add(bg_particles,p)
			end
		end
	else
		-- intensity based on morph + round progression (more drastic per round)
		local intensity=0
		if g and g.p1 and g.p2 then
			local morph_sum=g.p1.morph+g.p2.morph
			intensity= morph_sum/(WIN_MORPHS*2) *0.8 + (g.round-1)*0.25
			if intensity>1.5 then intensity=1.5 end
		end
		-- spawn ash and embers with separate probabilities, higher caps
		local cap=200
		if #bg_particles<cap then
			if rnd()<min(0.9, 0.35+0.55*intensity) then spawn_ash(intensity) end
			if rnd()<min(0.8, 0.15+0.50*intensity) then spawn_ember(intensity) end
		end
	end
	for i=#bg_particles,1,-1 do
		local p=bg_particles[i]
		p.y+=p.spd
		p.x+=p.dx
		p.life-=1
		if p.y>132 or p.life<=0 then deli(bg_particles,i) end
	end
end

function draw_bg_particles()
	for p in all(bg_particles) do
		pset(p.x,p.y,p.col)
		if p.type=="ember" and rnd()<0.4 then pset(p.x-1,p.y,8) end
		if p.type=="victory" and rnd()<0.5 then pset(p.x+1,p.y,7) end
	end
end

function add_proj(x,y,dir,owner,proj_spr)
	add(fx,{t="proj",x=x,y=y,dir=dir,life=STEP_FRAMES,frame=0,owner=owner,proj_spr=proj_spr})
end

function add_sparkle(x,y)
	-- tiny white/pink sparkle burst
	add(fx,{t="spark",x=x,y=y,life=12,frame=0})
end

function start_victory_effect(side)
	victory_active=true
	victory_side=side
	-- clear existing particles for stronger contrast
	while #bg_particles>0 do deli(bg_particles,#bg_particles) end
end

function stop_victory_effect()
	victory_active=false
	victory_side=nil
	-- clear victory particles; normal ash/embers will resume
	while #bg_particles>0 do deli(bg_particles,#bg_particles) end
end

function add_hit(x,y,is_double_hit)
	add(fx,{t="hit",x=x,y=y,life=16,frame=0})
	shake_timer=is_double_hit and 10 or 6
	shake_mag=is_double_hit and 3 or 2
	flash_timer=is_double_hit and 12 or 3
	flash_color=7 -- white flash on hit
	flash_is_double=is_double_hit or false
end

function update_fx()
	for i=#fx,1,-1 do
		local f=fx[i]
		f.life-=1
		f.frame+=1
		if f.t=="proj" then
			f.x+=f.dir*PROJ_SPEED
			-- collision check at target side (hit detection)
			if f.owner==1 and f.x>=LANE_X_RIGHT-4 and f.x<=LANE_X_RIGHT+4 then
				-- only hit if rows match this step
				if g.p1.row==g.p2.row then
					attack_hit(1)
					f.life=0 -- despawn on hit or block
				end
			end
			if f.owner==2 and f.x<=LANE_X_LEFT+4 and f.x>=LANE_X_LEFT-4 then
				if g.p2.row==g.p1.row then
					attack_hit(2)
					f.life=0 -- despawn on hit or block
				end
			end
			-- despawn only when completely off-screen
			if f.x<-8 or f.x>136 then f.life=0 end
		end
		if f.life<=0 then deli(fx,i) end
	end
	if shake_timer>0 then shake_timer-=1 end
	if flash_timer>0 then flash_timer-=1 end
	update_bg_particles()
end

function cam_shake_start(frames,mag)
	shake_timer=frames or 6
	shake_mag=mag or 2
end

function apply_camera_shake()
	if shake_timer>0 then
		camera(rnd(shake_mag*2)-shake_mag, rnd(shake_mag*2)-shake_mag)
	else
		camera()
	end
end

function draw_fx()
	draw_bg_particles()
	for f in all(fx) do
		if f.t=="proj" then
			draw_projectile(f.x,f.y,f.frame,f.proj_spr)
		elseif f.t=="hit" then
			draw_hit(f.x,f.y,f.frame)
		elseif f.t=="spark" then
			local c = (f.frame%2==0) and 7 or 14
			pset(f.x,f.y,c)
			pset(f.x-1,f.y,c)
			pset(f.x+1,f.y,c)
			pset(f.x,f.y-1,c)
			pset(f.x,f.y+1,c)
			if rnd()<0.5 then pset(f.x-2,f.y,c) pset(f.x+2,f.y,c) end
		end
	end
	-- screen flash on hit (alternating white/red for 2x hits)
	if flash_timer>0 then
		local col=flash_color
		if flash_is_double and flash_timer%4<2 then
			col=8 -- alternate to red
		end
		rectfill(0,0,127,127,col)
	end
end
