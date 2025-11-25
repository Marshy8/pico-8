
-- splash map display for pico-8

-- show the 16x16 tile region from the map as a splash screen
function _init()
	show_splash = true
	splash_timer = 0
	splash_duration = 2.5 -- seconds
end

local function anybtnp()
	for i = 0, 5 do
		if btnp(i) then
			return true
		end
	end
	return false
end

function _update()
	if show_splash then
		splash_timer = splash_timer + (1 / 30)
		if splash_timer >= splash_duration or anybtnp() then
			show_splash = false
		end
	else
		-- game update placeholder
	end
end

function _draw()
	cls()
	if show_splash then
		-- draw the 16x16 tile region at map origin (0,0) to fill the 128x128 screen
		map(0, 0, 0, 0, 16, 16)
	else
		-- placeholder for after-splash content
		rectfill(0, 0, 127, 127, 0)
		print("game ready", 44, 60, 7)
	end
end
