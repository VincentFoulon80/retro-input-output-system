-- Retro Gadgets

local rios = require("rios.lua")

-- load an app to play
-- here we load the "ball" example app
local app = require("ball.lua")

-- init the app
rios.registerApp(app)

-- update function is repeated every time tick
function update()
	gdt.VideoChip0:Clear(color.gray)
	rios.runApps(rios)
end