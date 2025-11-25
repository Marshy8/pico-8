-- lightweight effects system: projectiles, hits, and shake

fx={} -- active foreground effects (projectiles, hits)
shake_timer=0
shake_mag=0

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
	end
end

function add_proj(x,y,dir)
	add(fx,{t="proj",x=x,y=y,dir=dir,life=STEP_FRAMES,frame=0})
end

function add_hit(x,y)
	add(fx,{t="hit",x=x,y=y,life=16,frame=0})
	shake_timer=6
	shake_mag=2
end

function update_fx()
	for i=#fx,1,-1 do
		local f=fx[i]
		f.life-=1
		f.frame+=1
		if f.t=="proj" then
			f.x+=f.dir*PROJ_SPEED
		end
		if f.life<=0 then deli(fx,i) end
	end
	if shake_timer>0 then shake_timer-=1 end
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
			draw_projectile(f.x,f.y,f.frame)
		elseif f.t=="hit" then
			draw_hit(f.x,f.y,f.frame)
		end
	end
end
