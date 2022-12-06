function getFirstDevice(rios, type:number,feature:number?)
    if rios.hasDevice(type, feature) then
        for id,screen in rios.getDeviceList(type, feature) do
            return id
        end
    end
end

local SPE_NONE = 0
local SPE_DOUBLE = 1
local SPE_HARD = 2
local SPE_LIFE = 3
local SPE_HARDER = 4

levels = {
    spe = {
        NONE = SPE_NONE,
        DOUBLE = SPE_DOUBLE,
        HARD = SPE_HARD,
        LIFE = SPE_LIFE,
        HARDER = SPE_HARDER,
    },
    colors = {
        [SPE_NONE] = Color(99,155,255),
        [SPE_DOUBLE] = color.white,
        [SPE_HARD] = color.blue,
        [SPE_LIFE] = color.yellow,
        [SPE_HARDER] = color.magenta
    }
}

local video = nil
local slider = nil
local width = 0
local height = 0
local brick_w = 0
local brick_h = 0
local cursor_w = 0
local dt = 0

local paused = false

local level = 1
local lives = 3
local balls = {}

local bricks = {}

local font = nil

function getCursorPos():number
    if slider ~= nil then 
        return math.round((slider.Value/100)*(width-cursor_w))
    end
    return 0
end

function createBall(x:number, y:number, vx:number, vy:number)
    table.insert(balls, {pos=vec2(x,y),vel=vec2(vx,vy)})
end

function checkBallCursor(ball):boolean
    if ball.pos.Y >= height-4 and ball.pos.Y <= height then
        local cursor = getCursorPos()
        if ball.pos.X >= cursor - 1 and ball.pos.X <= cursor + cursor_w+1 then
            if ball.pos.x < cursor + (cursor_w/3) then
                ball.vel = vec2(ball.vel.X-1,ball.vel.Y)
            end
            if ball.pos.x > cursor + 2*(cursor_w/3) then
                ball.vel = vec2(ball.vel.X+1,ball.vel.Y)
            end
            return true
        end	
    end
    return false
end

function checkBallSides(ball):boolean
    if ball.pos.X<=0 then 
        ball.vel = vec2(math.abs(ball.vel.X), ball.vel.Y)
        return true
    elseif ball.pos.X >= width then
        ball.vel = vec2(-math.abs(ball.vel.X), ball.vel.Y)
        return true
    end
    return false
end

function checkBallTop(ballPos:vec2):boolean
    return ballPos.Y <= 1
end

function checkBallBottom(ballPos:vec2):boolean
    return ballPos.Y > height+10
end

function checkBallBricks(ball):boolean
    for id, brick in bricks do
        local b_x = brick.x*brick_w
        local b_y = brick.y*brick_h
        if ball.pos.Y >= b_y-1 and ball.pos.Y <= b_y+brick_h+1 then
            if ball.pos.X >= b_x-1 and ball.pos.X <= b_x+brick_w+1 then
                if ball.pos.X <= b_x then
                    ball.vel = vec2(-math.abs(ball.vel.X), ball.vel.Y)
                end
                if ball.pos.X >= b_x+brick_w then
                    ball.vel = vec2(math.abs(ball.vel.X), ball.vel.Y)
                end
                if ball.pos.Y <= b_y then
                    ball.vel = vec2(ball.vel.X, -math.abs(ball.vel.Y))
                end
                if ball.pos.Y >= b_y+brick_h then
                    ball.vel = vec2(ball.vel.X, math.abs(ball.vel.Y))
                end
                if brick.spe == levels.spe.HARDER then
                    brick.spe = levels.spe.HARD
                    brick.col = levels.colors[levels.spe.HARD]
                elseif brick.spe == levels.spe.HARD then
                    brick.spe = levels.spe.NONE
                    brick.col = levels.colors[levels.spe.NONE]
                else
                    if brick.spe == levels.spe.DOUBLE then
                        createBall(ball.pos.X, ball.pos.Y, -ball.vel.X,-ball.vel.Y)
                    end
                    if brick.spe == levels.spe.LIFE then
                        --audio:Play(sfx_life, 2)
                        lives = lives + 1
                    end
                    table.remove(bricks,id)
                end
                return true				
            end
        end
    end
    return false
end

function updateBalls()
    for id, ball in balls do 
        ball.pos = vec2(ball.pos.X + ball.vel.X, ball.pos.Y + ball.vel.Y)
        if checkBallCursor(ball) or checkBallTop(ball.pos) then
            --audio:Play(sfx_bup, 1)
            ball.vel = vec2(ball.vel.X, -ball.vel.Y)
        end
        if checkBallSides(ball) then
            --audio:Play(sfx_bup, 1)
        end
        if checkBallBottom(ball.pos) then
            table.remove(balls, id)
        end
        if checkBallBricks(ball) then
            --audio:Play(sfx_beep, 1)		
        end
        
    end
end

function generateGame()
    --audio:Play(sfx_start, 1)
    video.Clear(color.black)
    table.clear(balls)
    video.DrawText(vec2(0,0), font, "LEVEL "..level, color.white, color.black)
    video.DrawText(vec2(0,10), font, "LIVES "..lives, color.white, color.black)
    sleep(2)
    createBall(getCursorPos()+(cursor_w/2), height-5, 2, -2)
    if table.maxn(bricks) == 0 then
        --local lvlcnt = table.maxn(levels.db)
        --local lvl = ((level-1) % lvlcnt)+1
        for j=0,6 do
            for i=0,7 do
                local col = color.green
                if (i+j) % 2 == 0 then
                    col = color.magenta
                end
                table.insert(bricks, {
                    x=i,
                    y=j,
                    spe=0,
                    col=col,
                })
            end
        end
    end
end

function drawPlayer()
    local pos = getCursorPos()
    video.FillRect(vec2(pos,height-3), vec2(pos+cursor_w,height-2), color.white)
end

function drawBalls()
    for _, ball in balls do
        if ball.pos.Y < height then
            video.FillCircle(ball.pos, 1, color.white)
        end
    end
end

function drawBricks()
    for _, brick in bricks do
        local b_tl = vec2(brick.x*brick_w, brick.y*brick_h)
        local b_br = vec2(brick.x*brick_w+brick_w-1, brick.y*brick_h+brick_h-1)
        video.FillRect(b_tl, b_br, brick.col)
    end
end

app = {
    -- Initialize app, setup variables, fetch rios devices...
    init = function(rios):boolean
        font = rios.ROM().System.SpriteSheets["StandardFont"]
        local SCREEN = rios.const.device.SCREEN
        local MAIN = rios.const.feature.MAIN
            local SLIDER = rios.const.device.SLIDER
                        
            local video_id = getFirstDevice(rios, SCREEN, MAIN)
            video = rios.getScreenDevice(video_id)
            if video == nil then return false end
            local video_info = rios.getDeviceInfo(video_id)
            width = video_info.info.size.X
            height = video_info.info.size.Y
            if height < 24 or width < 16 then
                -- can't guarantee that the game is playable under a height of 24px or a width of 16px
                return false
            end
            brick_w = width/8
            brick_h = height/16
            cursor_w = width/4
        
            local slider_id = getFirstDevice(rios, SLIDER)
            slider = rios.getInputDevice(slider_id)
            bricks = {}
            generateGame()
            
        return true
    end,
    -- Run one tick of the app. The OS will most of the time call this function on each tick
    -- return true if the app should continue to run
    run = function(rios):boolean
        video.Clear(color.black)

        
        drawPlayer()
        drawBalls()
        drawBricks()
        
        dt = dt + rios.CPU().DeltaTime
        if dt > 0.032 then
            dt = 0
            updateBalls()
            if table.maxn(balls) == 0 then
                -- lost a life
                if lives > 0 then
                    --audio:Play(sfx_gameover, 1)
                    lives = lives - 1
                    sleep(1.5)
                    if lives > 0 then
                        generateGame()
                    end
                end
            end
            if table.maxn(bricks) == 0 then
                --audio:Play(sfx_win, 1)
                video.Clear(color.black)
                video.DrawText(vec2(0,0), font, "LEVEL", color.white, color.black)
                video.DrawText(vec2(0,10), font, "CLEARED", color.white, color.black)
                sleep(1.5)
                video.Clear(color.black)
                -- level finished
                level = level + 1
                generateGame()
            end
        end
        if lives <= 0 then
            video.DrawText(vec2(0,0), font, "GAME OVER", color.white, color.black)
            sleep(3)
            lives = 3
            bricks = {}
            generateGame()
        end

        return true
    end,
    -- The app is about to be destroyed, finish what you were doing and save your state if needed
    destroy = function(rios)
        video = nil
        slider = nil
        balls = {}
        bricks = {}
    end
}


return app