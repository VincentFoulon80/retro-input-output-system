-- Retro Gadgets

local rios = require("rios.lua")

-- load an app to play
-- here we load the "ball" example app
local app = require("ball.lua")

-- init the app
local app_running = app.init(rios)

-- update function is repeated every time tick
function update()
	gdt.VideoChip0:Clear(color.gray)
	if app_running then
		app_running = app.run(rios)
	end
end