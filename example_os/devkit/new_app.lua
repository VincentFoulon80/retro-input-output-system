-- App template for rios applications
-- the first thing to avoid any compatibility issue is to not use gdt at all
-- instead let rios give you the devices you need

-- utility function to select the first device available
function getFirstDeviceId(rios, type:number,feature:number?)
    if rios.hasDevice(type, feature) then
        for id,screen in rios.getDeviceList(type, feature) do
            return id
        end
    end
end


-- add any variables you want to use in you app here
local video = nil
local font = nil
local menu = nil

app = {
    -- Initialize app, setup variables, fetch rios devices...
    -- return true if successfully initalized
    -- return false to quit immediately
    init = function(rios):boolean
        -- import some constants
        local SCREEN = rios.const.device.SCREEN
        local MAIN = rios.const.feature.MAIN
        local BUTTON = rios.const.device.BUTTON
        local MENU = rios.const.feature.MENU

        -- init your app here
        video = rios.getScreenDevice(getFirstDeviceId(rios, SCREEN, MAIN))
        menu = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, MENU))
        font = rios.ROM().System.SpriteSheets["StandardFont"]

        return video ~= nil
 
    end,
    -- Run one tick of the app. The OS will most of the time call this function on each tick
    -- return true if the app should continue to run
    run = function(rios):boolean
        -- run your app
        video.Clear(color.black)
        video.DrawText(vec2(0,(video.Height-7)/2), font, "Hello, world!", color.white, color.black)

        -- run until menu is pressed
        return not menu.ButtonDown
    end,
    -- The app is about to be destroyed, finish what you were doing and save your state if needed
    destroy = function(rios)
        -- uninit your app here
        video = nil
        font = nil
        menu = nil
    end
}


return app