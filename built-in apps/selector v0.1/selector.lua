--[[ App Selector
Display a list of apps, and allow the user to select one from the list

CONFIGURATION
here you can change the colors used in this menu
also you'll need to fill a table with apps to display in you CPU file
**IMPORTANT: Icons are optional, and should be 16x16 or less.**
app entry format: {name="name",app=luafile,icon={"image",x,y}},
local myapp = require("myapp.lua")
local anotherapp = require("anotherapp.lua")
local selector = require("selector.lua")
selector.appList = {
    {name="MyAppName", app=myapp, icon={"myapp.png",0,0}},
    {name="Another App", app=anotherapp, icon={"anotherapp's icon.png",0,0}},
    -- etc...
]]
local col_fg = Color(255,255,255)
local col_tile = Color(50,50,50)
local col_bg = Color(5,4,3)
local outer_spacing = 8 -- minimum is 8
local inner_spacing = 4
local tile_size = 72
tile_size=vec2(tile_size,tile_size+7+inner_spacing)
local max_len = math.floor((tile_size.x-inner_spacing)/5)
local auto_grid = true -- should grid width be auto-calculated (not currently recommended)
local grid_width = 2 -- set custom grid width here
function gridCalc(video)
	if auto_grid then
		grid_width = math.floor(video.Width/((outer_spacing*1.5)+tile_size.x))
	end
end
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
local btn_right = nil
local btn_left = nil
local joystick = nil
local btn_confirm = nil
local font = nil

local first_start = true
local cursor = 0
local scroll = 0

-- spacing = math.max(outer_spacing, 8)

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
				local RIGHT = rios.const.feature.RIGHT
        local LEFT = rios.const.feature.LEFT
        local UP = rios.const.feature.UP
        local DOWN = rios.const.feature.DOWN
        local CONFIRM = rios.const.feature.CONFIRM
        local ROM = rios.ROM()

        -- init your app here
        video = rios.getScreenDevice(getFirstDeviceId(rios, SCREEN, MAIN))
				gridCalc(video)
        if video.Height < (outer_spacing*2)+(tile_size.y) and video.Width < (outer_spacing*2)+(tile_size.x) then
						logError("Screen device requires at least "..((outer_spacing*2)+(tile_size.y)).."px of height and at least "..((outer_spacing*2)+(tile_size.x)).."px of width. Reajust spacing or increase the screen size.")
						return false
        elseif video.Height < (outer_spacing*2)+(tile_size.y) then
						logError("Screen device requires at least "..((outer_spacing*2)+(tile_size.y)).."px of height. Reajust spacing or increase the screen size.")
						return false
				elseif video.Width < (outer_spacing*2)+(tile_size.x) then
						logError("Screen device requires at least "..((outer_spacing*2)+(tile_size.x)).."px of width. Reajust spacing or increase the screen size.")
						return false
        end
        audio = rios.getAudioDevice(getFirstDeviceId(rios, AUDIO))
        font = rios.ROM().System.SpriteSheets["StandardFont"]
        btn_up = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, UP))
        btn_down = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, DOWN))
        btn_right = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, RIGHT))
        btn_left = rios.getInputDevice(getFirstDeviceId(rios, BUTTON, LEFT))
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
        btn_right = nil
        btn_left = nil
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

function isJoystickRight():boolean
    return joystick.getX() > 30
end

function isJoystickLeft():boolean
    return joystick.getX() < -30
end

app.run = function(rios):boolean
    if first_start then
        first_start = false
        splashScreen(rios, video, audio, font)
        return true
    end
    -- run your app
    video.Clear(col_bg)
		local scroll_down = false
    local index = 0
    for _,appEntry in app.appList do
        local ellipsis = rios.ROM().User.SpriteSheets["selector spritesheet.png"]
        local y_idx = math.floor(index/grid_width)
        local x_idx = index-(y_idx*grid_width)
        local fg = col_fg
        local bg = col_tile
				local none = ColorRGBA(0,0,0,0)
				local imagesize = vec2(tile_size.x-(inner_spacing*2)-1,tile_size.x-(inner_spacing*2)-1)
        local position = vec2(0,((y_idx-scroll)*(outer_spacing+tile_size.y))+outer_spacing)
				position = vec2((x_idx*(outer_spacing+tile_size.x)+(video.Width/2))-(((tile_size.x*grid_width)+(outer_spacing*(grid_width-1)))/2),position.y)
				local imagepos = position+vec2(inner_spacing,inner_spacing)
				if scroll_down == false then
						scroll_down = (position.y+tile_size.y)>video.Height
				end
        if position.y >= 0 and position.y <= video.Height-outer_spacing then
						video.FillRect(position, position+tile_size-vec2(1,1), bg)
						video.FillRect(imagepos,imagepos+imagesize,col_bg)
						if appEntry.icon ~= nil then
								local icon = rios.ROM().User.SpriteSheets[appEntry.icon[1]]
								local rs = math.floor((imagesize.x+1)/16)*16
								local pos = imagepos
								local decimal = ((imagesize.x+1)/16)%1
								if decimal ~= 0 then
										pos = (imagepos+((imagesize+vec2(1,1))/2))-(vec2(rs,rs)/2)
								end
								video.RasterSprite(pos,pos+vec2(rs,0),pos+vec2(rs,rs),pos+vec2(0,rs),icon,appEntry.icon[2],appEntry.icon[3],color.white,col_bg)
						end
						if string.len(appEntry.name) > max_len then
							--	local xpos = ((position.x+tile_size.x)-(max_len*5))/2
								local xpos = (position.x+(tile_size.x/2))-(max_len*5/2)
								video.DrawText((vec2(xpos,position.y+((outer_spacing-8)/2)+tile_size.x)), font, string.sub(appEntry.name,1,max_len-1), fg, bg)
								video.DrawSprite(vec2((xpos)+(5*(max_len-1)),position.y+((outer_spacing-8)/2)+tile_size.x),ellipsis,0,0,fg,none)
						else
							--	local xpos = ((position.x+tile_size.x)-(string.len(appEntry.name)*5))/2
								local xpos = (position.x+(tile_size.x/2))-(string.len(appEntry.name)*5/2)
            		video.DrawText(vec2(xpos,position.y+((outer_spacing-8)/2)+tile_size.x), font, appEntry.name, fg, bg)
						end
        end
				if index == cursor then 
 						video.DrawRect(position, vec2(position.x+tile_size.x-1, position.y+tile_size.y-1), fg)
            if btn_confirm.ButtonDown then
                rios.registerApp(appEntry.app)
                return false
            end
        end
        index = index + 1
    end
		if scroll_down then
				local arrows = rios.ROM().User.SpriteSheets["selector spritesheet.png"]
				local pos = vec2((video.Width/2)-4,(video.Height-1)-(outer_spacing/2)-4)
				video.DrawSprite(pos,arrows,1,0,color.white,color.clear)
		end
		if scroll > 0 then
				local arrows = rios.ROM().User.SpriteSheets["selector spritesheet.png"]
				local pos = vec2((video.Width/2)-4,(outer_spacing/2)-3)
				video.DrawSprite(pos,arrows,2,0,color.white,color.clear)
		end

    if ((btn_right ~= nil and btn_right.ButtonDown) or isJoystickRight()) and cursor < index-1 then
        cursor = cursor + 1
    end
    if ((btn_left ~= nil and btn_left.ButtonDown) or isJoystickLeft()) and cursor > 0 then
        cursor = cursor - 1
    end
		if ((btn_up ~= nil and btn_up.ButtonDown) or isJoystickUp()) then
			cursor = math.max((cursor-grid_width),0)
		end
		if ((btn_down ~= nil and btn_down.ButtonDown) or isJoystickDown()) then
			cursor = math.min((cursor+grid_width),index-1)
		end
    if (isJoystickDown() or isJoystickUp() or isJoystickLeft() or isJoystickRight()) then
        rios.sleep(0.2)
    end
--    if cursor*(tile_size.y+outer_spacing) > video.Height then
--        local scroll_offset = math.ceil(video.Height/(tile_size.y+outer_spacing))
--        scroll = cursor-scroll_offset
--    else
--        scroll = 0
--    end
		scroll=math.floor(cursor/grid_width)

    -- run forever
    return true
end


return app
