-- APP Selector
-- Display a list of APPs, and allow the user to select one from the list

-- CONFIGURATION
-- here you can change the colors used in this menu
-- also you'll need to fill a table with apps to display in you CPU file
-- ```
-- local myapp = require("myapp.lua")
-- local anotherapp = require("anotherapp.lua")
-- local selector = require("selector.lua")
-- selector.appList = {
--     {name="MyAppName", app=myapp},
--     {name="Another App", app=anotherapp},
--     -- etc...
-- }
local col_fg = color.white
local col_bg = color.black
local spacing = 8 -- minimum is 8
local always_run_splashscreen = false

function splashScreen(rios, video, audio, font)
    -- do whatever you want here
    -- if you don't want a splashscreen, empty this function
    video.Clear(col_bg)
    video.DrawText(vec2((video.Width-50)/2,(video.Height/2)-4), font, "Powered by", col_fg, col_bg)
    video.DrawText(vec2((video.Width-20)/2,(video.Height/2)+4), font, "RIOS", col_fg, col_bg)
    rios.sleep(1)
end

-- add any variables you want to use in you app here
local video = nil
local audio = nil
local btn_up = nil
local btn_down = nil
local joystick = nil
local btn_confirm = nil
local font = nil

local first_start = true
local cursor = 0
local scroll = 0

spacing = math.max(spacing, 8)

-- utility function to select the first device available
function getFirstDeviceId(rios, type:number,feature:number?)
    if rios.hasDevice(type, feature) then
        for id,screen in rios.getDeviceList(type, feature) do
            return id
        end
    end
end

app = {
    -- Please fill this table with apps from you CPU file
    appList = {},

    init = function(rios):boolean
        -- import some constants
        local SCREEN = rios.const.device.SCREEN
        local AUDIO = rios.const.device.AUDIO
        local MAIN = rios.const.feature.MAIN
        local BUTTON = rios.const.device.BUTTON
        local JOYSTICK = rios.const.device.JOYSTICK
        local LEFT = rios.const.feature.LEFT
        local UP = rios.const.feature.UP
        local DOWN = rios.const.feature.DOWN
        local CONFIRM = rios.const.feature.CONFIRM

        -- init your app here
        video = rios.getScreenDevice(getFirstDeviceId(rios, SCREEN, MAIN))
        if video.Height < spacing*2 then
            logError("Screen device requires at least "..(spacing*2).."px of height. Reajust spacing or increase the screen size.")
            return false
        end
        audio = rios.getAudioDevice(getFirstDeviceId(rios, AUDIO))
        font = rios.ROM().System.SpriteSheets["StandardFont"]
        btn_up = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, UP))
        btn_down = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, DOWN))
        btn_confirm = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, CONFIRM))

        joystick = rios.getAllJoysticks(LEFT)

        return video ~= nil
    end,
    
    destroy = function(rios)
        video = nil
        audio = nil
        font = nil
        joystick = nil
        btn_up = nil
        btn_down = nil
        btn_accept = nil
        if always_run_splashscreen then
            first_start = true
        end
        -- intentionnaly do not reset cursor
        -- to keep the last selected app
        -- cursor = 0
    end
}

function isJoystickUp():boolean
    return joystick.getY() > 30
end

function isJoystickDown():boolean
    return joystick.getY() < -30
end

app.run = function(rios):boolean
    if first_start then
        first_start = false
        splashScreen(rios, video, audio, font)
        return true
    end
    -- run your app
    video.Clear(col_bg)
    local index = 0
    for _,appEntry in app.appList do 
        local fg = col_fg
        local bg = col_bg
        local position = (index-scroll)*spacing
        if index == cursor then 
            fg = col_bg
            bg = col_fg
            video.FillRect(vec2(0,position), vec2(video.Width, position+spacing-1), bg)
            if btn_confirm.ButtonDown then
                rios.registerApp(appEntry.app)
                return false
            end
        end
        if position >= 0 and position <= video.Height-spacing then 
            video.DrawText(vec2(1,position+(spacing-8)/2), font, appEntry.name, fg, bg)
        end
        index = index + 1

    end

    if ((btn_down ~= nil and btn_down.ButtonDown) or isJoystickDown()) and cursor < index-1 then
        cursor = cursor + 1
    end
    if ((btn_up ~= nil and btn_up.ButtonDown) or isJoystickUp()) and cursor > 0 then
        cursor = cursor - 1
    end
    if (isJoystickDown() or isJoystickUp()) then
        rios.sleep(0.2)
    end
    if cursor*spacing > video.Height/2 then
        local scroll_offset = math.ceil(video.Height/spacing/2)
        scroll = cursor-scroll_offset
    else
        scroll = 0
    end

    -- run forever
    return true
end


return app