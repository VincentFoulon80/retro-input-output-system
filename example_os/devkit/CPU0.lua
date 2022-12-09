-- RIOS DEVKIT
-- Set of dev tools to build apps for RIOS
-- The only file you need to edit is new_app.lua
-- The rest is just the devkit setup
-- but feel free to look around! :)

-- Load RIOS and initialize devkit

local rios = require("rios.lua")
local main_video = gdt.VideoChip0
local sec_video = gdt.VideoChip2
local reset_btn = gdt.LedButton4
local pause_btn = gdt.LedButton10
local step_btn = gdt.LedButton11
local speed_knob = gdt.Knob4
local font = gdt.ROM.System.SpriteSheets["StandardFont"]
local paused = false
local paused_time = 0
local reload_timeout = 0
local appid = nil
local tick_count = 0
gdt = nil


-- load your APP here:
local ball = require("ball.lua")


-- init devkit's default background
main_video:Clear(color.gray)
sec_video:Clear(color.gray)

-- update function is repeated every time tick
function update()
    tick_count = tick_count + 1
    local speed = math.round(((speed_knob.Value + 100)/200)*8)-1
    local will_run = speed == 7 or tick_count % 2^(6-speed) == 0
    
    -- handle pause 
    if pause_btn.ButtonDown then
        paused = not paused
        paused_time = rios.CPU().Time
    end
    pause_btn.LedState = paused and math.floor(rios.CPU().Time-paused_time) % 2 == 0
    
    -- run the app
    -- if the app stopped somehow, reload it
    if (will_run and not paused) or step_btn.ButtonDown then
        if rios.countApps(rios) == 0 and reload_timeout == 0 then
            reload_timeout = 60
        elseif reload_timeout > 0 then
            reload_timeout = reload_timeout-1
            main_video:Clear(color.gray)
            main_video:DrawText(vec2(0,0), font, "LAUNCHING APP IN "..reload_timeout, color.black, color.gray)
            if reload_timeout == 0 then
                appid = rios.registerApp(ball)
                main_video:Clear(color.gray)
            end
        end
        rios.debugRunApps(rios)
        if speed == 7 then
            rios.debugRunApps(rios)
        end
    end
    if reset_btn.ButtonDown and appid ~= nil then
        main_video:Clear(color.gray)
        main_video:DrawText(vec2(0,0), font, "DESTROYING APP", color.black, color.gray)
        rios.destroyApp(appid)
        appid = nil
    end
end