-- Ball that bounce around on the screen
function getFirstDevice(rios, type:number,feature:number?)
    if rios.hasDevice(type, feature) then
        for id,screen in rios.getDeviceList(type, feature) do
            return id
        end
    end
end

local ball = {x=5,y=5, vx=2,vy=1}
local video = nil
local menu_button = nil
local width = 0
local height = 0

app = {
    -- get an instance of the screen
    init = function(rios):boolean
        -- import some consts to ease the reading below
        local SCREEN = rios.const.device.SCREEN
        local MAIN = rios.const.feature.MAIN
        local MENU = rios.const.feature.MENU
        local BUTTON = rios.const.device.BUTTON

        -- get video device
        video = rios.getScreenDevice(getFirstDevice(rios, SCREEN, MAIN))
        ball.x = video.Width/2
        ball.y = video.Height/2
   
        -- get button device if available, not mandatory
        menu_button = rios.getInputDevice(getFirstDevice(rios, BUTTON, MENU))

        -- success if we got a screen
        return video ~= nil
    end,
    -- Run one tick of the app. The OS will most of the time call this function on each tick
    -- return true if the app should continue to run
    run = function(rios):boolean
        -- move the ball and make it bounce the edge
        ball.x = ball.x + ball.vx
        ball.y = ball.y + ball.vy
        if ball.x <= 0 or ball.x >= video.Width then 
                ball.vx = -ball.vx
        end
        if ball.y <= 0 or ball.y >= video.Height then
                ball.vy = -ball.vy	
        end

        -- draw the ball
        video.Clear(color.black)
        video.SetPixel(vec2(ball.x, ball.y), color.white)

        -- if the button exist, use it to close the app
        if menu_button ~= nil and menu_button.ButtonDown then
            return false
        end

        -- else continue indefinitely
        return true
    end,
    -- The app is about to be destroyed, finish what you were doing and save your state if needed
    destroy = function(rios)
        -- reset devices
        video = nil
        menu_button = nil
    end
}


return app