-- Retro Input/Output System (RIOS)
-- This file provide a set of functions to call in order to create an app
-- for any Operating System supporting this interface

-- a given app must not implement the update function, but instead provide three:
-- + setup: initialize itself, for the first use
-- + run: equivalent of the update function, runs on each tick after the setup
-- + destroy: clean itself, potentially save state, before being removed by the OS
-- see app_template.lua for details

-- UTILITY FUNCTIONS

-- use this function to change channel numbers at will
function rerouteChannel(channel:number):number
    return channel
end

-- create a mock table mimicking AudioChip
-- useful if you want your OS to keep audio channels for itself
-- and still provide an interface to apps
function mockAudio(audio:AudioChip)
    return {
        GetSpectrumData = function(channel:number, samplesCount:number)
            channel = rerouteChannel(channel)
            return audio:GetSpectrumData(channel, samplesCount)
        end,
        GetDspTime = function()
            return audio:GetDspTime()
        end,
        Play = function(sample:AudioSample, channel:number)
            channel = rerouteChannel(channel)
            return audio:Play(sample, channel)
        end,
        PlayScheduled = function(sample:AudioSample, channel:number, dspTime:number)
            channel = rerouteChannel(channel)
            return audio:PlayScheduled(sample, channel, dspTime)
        end,
        PlayLoop = function(sample:AudioSample, channel:number)
            channel = rerouteChannel(channel)
            return audio:PlayLoop(sample, channel)
        end,
        PlayLoopScheduled = function(sample:AudioSample, channel:number, dspTime:number)
            channel = rerouteChannel(channel)
            return audio:PlayLoopScheduled(sample, channel, dspTime)
        end,
        Stop = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:Stop(channel)
        end,
        Pause = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:Pause(channel)
        end,
        UnPause = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:UnPause(channel)
        end,
        IsPlaying = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:IsPlaying(channel)
        end,
        GetPlayTime = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:GetPlayTime(channel)
        end,
        SeekPlayTime = function(time:number, channel:number)
            channel = rerouteChannel(channel)
            return audio:SeekPlayTime(time, channel)
        end,
        SetChannelVolume = function(volume:number, channel:number)
            channel = rerouteChannel(channel)
            return audio:SetChannelVolume(volume, channel)
        end,
        GetChannelVolume = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:GetChannelVolume(channel)
        end,
        SetChannelPitch = function(pitch:number, channel:number)
            channel = rerouteChannel(channel)
            return audio:SetChannelPitch(pitch, channel)
        end,
        GetChannelPitch = function(channel:number)
            channel = rerouteChannel(channel)
            return audio:GetChannelPitch(channel)
        end
    }
end

-- create a mock table mimicking VideoChip
-- useful if you want your OS to manage part of the available screen space
-- The functions will try to prevent drawing outside of the designated area
function mockVideo(video:VideoChip, offset:vec2, size:vec2)
    local scrEnd = vec2(offset.X + size.X, offset.Y + size.Y)
    return {
        Width = size.X,
        Height = size.Y,
        Clear = function(color:color)
            return video:FillRect(offset, scrEnd, color)
        end,
        SetPixel = function(position:vec2, color:color)
            local position = vec2(position.X+offset.X, position.Y+offset.Y);
            if position.X >= offset.X and position.X <= scrEnd.X and position.Y >= offset.Y and position.Y <= scrEnd.Y then
                return video:SetPixel(position, color)
            end
        end,
        DrawPointGrid = function(gridOffset:vec2, dotsDistance:number, color:color)
            -- todo
            -- disabled, as there is no way to prevent writing over the entire screen
        end,
        DrawLine = function(start:vec2, target:vec2, color:color)
            local start = vec2(start.X+offset.X, start.Y+offset.Y)
            local target = vec2(target.X+offset.X,target.Y+offset.Y)
            -- clamp coordinates inside the boundaries of the screen
            -- find coordinates with modified lerp formula
            -- (start.X-offset.X)/(start.X-target.X)
            function iLerpX(s, t, o)
                local coef = (s.X-o.X)/(s.X-t.X)
                return vec2(o.X, math.round(s.Y+coef*(t.Y-s.Y)))
            end
            function iLerpY(s, t, o)
                local coef = (s.Y-o.Y)/(s.Y-t.Y)
                return vec2(math.round(s.X+coef*(t.X-s.X)), o.Y)
            end
            if start.X < offset.X then
                start = iLerpX(start, target, offset)
            end
            if start.Y < offset.Y then
                start = iLerpY(start, target, offset)
            end
            if start.X > scrEnd.X then 
                start = iLerpX(start, target, scrEnd)
            end
            if start.Y > scrEnd.Y then
                start = iLerpY(start, target, scrEnd)
            end
            if target.X < offset.X then
                target = iLerpX(target, start, offset)
            end
            if target.Y < offset.Y then
                target = iLerpY(target, start, offset)
            end
            if target.X > scrEnd.X then
                target = iLerpX(target, start, scrEnd)
            end
            if target.Y > scrEnd.Y then
                target = iLerpY(target, start, scrEnd)
            end
            return video:DrawLine(start, target, color)
        end,
        DrawCircle = function(position:vec2, radius:number, color:color)
            local position = vec2(math.clamp(position.X+offset.X, offset.X, scrEnd.X), math.clamp(position.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:DrawCircle(position, radius, color)
        end,
        FillCircle = function(position:vec2, radius:number, color:color)
            local position = vec2(math.clamp(position.X+offset.X, offset.X, scrEnd.X), math.clamp(position.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:FillCircle(position, radius, color)
        end,
        DrawRect = function(position1:vec2, position2:vec2, color:color)
            local position1 = vec2(math.clamp(position1.X+offset.X, offset.X, scrEnd.X), math.clamp(position1.Y+offset.Y, offset.Y, scrEnd.Y))
            local position2 = vec2(math.clamp(position2.X+offset.X, offset.X, scrEnd.X), math.clamp(position2.Y+offset.Y, offset.Y, scrEnd.Y))
            return video:DrawRect(position1, position2, color)
        end,
        FillRect = function(position1:vec2, position2:vec2, color:color)
            local position1 = vec2(math.clamp(position1.X+offset.X, offset.X, scrEnd.X), math.clamp(position1.Y+offset.Y, offset.Y, scrEnd.Y))
            local position2 = vec2(math.clamp(position2.X+offset.X, offset.X, scrEnd.X), math.clamp(position2.Y+offset.Y, offset.Y, scrEnd.Y))
            return video:FillRect(position1, position2, color)
        end,
        DrawTriangle = function(position1:vec2, position2:vec2, position3:vec2, color:color)
            local position1 = vec2(math.clamp(position1.X+offset.X, offset.X, scrEnd.X), math.clamp(position1.Y+offset.Y, offset.Y, scrEnd.Y))
            local position2 = vec2(math.clamp(position2.X+offset.X, offset.X, scrEnd.X), math.clamp(position2.Y+offset.Y, offset.Y, scrEnd.Y))
            local position3 = vec2(math.clamp(position3.X+offset.X, offset.X, scrEnd.X), math.clamp(position3.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:DrawTriangle(position1, position2, position3, color)
        end,
        FillTriangle = function(position1:vec2, position2:vec2, position3:vec2, color:color)
            local position1 = vec2(math.clamp(position1.X+offset.X, offset.X, scrEnd.X), math.clamp(position1.Y+offset.Y, offset.Y, scrEnd.Y))
            local position2 = vec2(math.clamp(position2.X+offset.X, offset.X, scrEnd.X), math.clamp(position2.Y+offset.Y, offset.Y, scrEnd.Y))
            local position3 = vec2(math.clamp(position3.X+offset.X, offset.X, scrEnd.X), math.clamp(position3.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:FillTriangle(position1, position2, position3, color)
        end,
        DrawSprite = function(position:vec2, spriteSheet:SpriteSheet, spriteX:number, spriteY:number, tintColor:color, backgroundColor:color)
            local position = vec2(math.clamp(position.X+offset.X, offset.X, scrEnd.X), math.clamp(position.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:DrawSprite(position, spriteSheet, spriteX, spriteY, tintColor, backgroundColor)
        end,
        DrawText = function(position:vec2, fontSprite:SpriteSheet, text:string, textColor:color, backgroundColor:color)
            local position = vec2(math.clamp(position.X+offset.X, offset.X, scrEnd.X), math.clamp(position.Y+offset.Y, offset.Y, scrEnd.Y))
            local maxSize = (scrEnd.X-position.X+2)/5
            text = string.sub(text,1,maxSize)
            return video:DrawText(position, fontSprite, text, textColor, backgroundColor)
        end,
        RasterSprite = function(position1:vec2, position2:vec2, position3:vec2, position4:vec2, spriteSheet:SpriteSheet, spriteX:number, spriteY:number, tintColor:color, backgroundColor:color)
            local position1 = vec2(math.clamp(position1.X+offset.X, offset.X, scrEnd.X), math.clamp(position1.Y+offset.Y, offset.Y, scrEnd.Y))
            local position2 = vec2(math.clamp(position2.X+offset.X, offset.X, scrEnd.X), math.clamp(position2.Y+offset.Y, offset.Y, scrEnd.Y))
            local position3 = vec2(math.clamp(position3.X+offset.X, offset.X, scrEnd.X), math.clamp(position3.Y+offset.Y, offset.Y, scrEnd.Y))
            local position4 = vec2(math.clamp(position4.X+offset.X, offset.X, scrEnd.X), math.clamp(position4.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:RasterSprite(position1, position2, position3, position4, spriteSheet, spriteX, spriteY, tintColor, backgroundColor)
        end,
        DrawRenderBuffer = function(position:vec2, renderBuffer:RenderBuffer, width:number, height:number)
            local position = vec2(math.clamp(position.X+offset.X, offset.X, scrEnd.X), math.clamp(position.Y+offset.Y, offset.Y, scrEnd.Y))
            -- todo
            return video:DrawRenderBuffer(position, renderBuffer, width, height)
        end,
    }
end

rios = {}

-- CONSTANTS
rios.const = {
    device = {
        -- the OS provides flash memory
        -- info = {
        --   available:number --how many bytes are still free
        -- }
        MEMORY = 0, 
        -- the OS provides ROM interface
        ROM = 1, 
        -- the OS provides a screen
        -- info = {
        --    offset:vec2 -- top-left corner of the allowed screen space
        --    size:vec2 -- size of the allowed screen space
        -- }
        SCREEN = 2,
        -- the OS provides a LCD screen
        LCD = 3,
        -- the OS provices a LED
        -- info = {
        --    matrix:boolean -- if the led is currently a matrix
        --    size:vec2 -- if matrix = true, this may be anything other than vec2(1,1)
        -- }
        LED = 4,
        -- the OS provides audio capabilities
        -- info = {
        -- 	  channels:number -- amount of channels available
        -- }
        AUDIO = 5,
        -- the OS provides keyboard access
        KEYBOARD = 6,
        -- the OS provides a joystick or a dpad
        JOYSTICK = 7,
        -- the OS provides a button
        -- info = {
        --     led:boolean -- is the button a LedButton?
        --     screen:boolean -- is the button a ScreenButton?
        --     screenInfo = { -- only available when screen=true
        --        device_id:string -- the device_id the button is connected to
        --        offset:vec2 -- top-left corner of the screen used by the button
        --        size:vec2 -- size of the screen used by the button. typically 16x16
        --    }
        -- }
        BUTTON = 8,
        -- the OS provides a slider
        SLIDER = 9,
        -- the OS provide a switch
        SWITCH = 10,
        -- the OS provide a knob
        KNOB = 11
    },
    feature = {
        NONE = 0,
        -- input
        -- directions are also allowed for :
        -- - joysticks (left, right)
        -- - sliders (up, down, left, right)
        UP = 1,
        RIGHT = 2,
        DOWN = 3,
        LEFT = 4,
        CONFIRM = 5, -- A
        BACK = 6, -- B
        OTHER1 = 7, -- C
        OTHER2 = 8, -- D
        MENU = 9, -- start button
        -- screen
        MAIN = 10,  -- largest screen
        SECONDARY = 11, -- smallest screen, used to display small info
    }
}

local devices = {
    main_screen = gdt.VideoChip0,
    audio = gdt.AudioChip0,
    menu_btn = gdt.LedButton0,
}

-- FUNCTIONS

-- getDeviceList will return any device the Operating System
-- let you operate, filtered by type and/or feature.
-- a device must be of the following schema:
-- [device_id] = {
--   type = -- any value of rgopi.const.device
--   feature = -- any value of rgopi.const.feature
--	 info = -- table displaying informations regarding the device
-- }
rios.getDeviceList = function(d_type:number?, feature:number?)
    list = {
        main_screen = {
            type=rios.const.device.SCREEN,
            feature=rios.const.feature.MAIN,
            info = {
                offset = vec2(0,0),
                size = vec2(devices.main_screen.Width, devices.main_screen.Height),
            }
        },
        audio = {
            type=rios.const.device.AUDIO,
            feature=rios.const.feature.NONE,
            info = {
                channels = 4
            }
        },
        menu_btn = {
            type=rios.const.device.BUTTON,
            feature=rios.const.feature.MENU,
            info = {
                led=false,
                screen=false,
            }
        }
    }
    local search = {}
    for id, device in list do
        if d_type == nil or device.type == d_type then
            if feature == nil or device.feature == feature then
                search[id] = device
            end
        end
    end
    return search
end

-- check if a given device is provided by the OS
-- parameter must be from rgopi.const.device
rios.hasDevice = function(d_type:number, feature:number?):boolean
    -- minimal implementation
    for id, device in rios.getDeviceList() do
        if device.type == d_type then
            if feature == nil or device.feature == feature then
                return true
            end
        end
    end
    return false
end

-- fetch a device's info
rios.getDeviceInfo = function(device_id)
    -- minimal implementation
    return rios.getDeviceList()[device_id]
end

-- provides the given input device (anything other than input must return nil)
-- You must return the component instance (LedButton, Slider, Knob, ...) or nil
rios.getInputDevice = function(device_id)
    -- minimal implementation
    local info = rios.getDeviceInfo(device_id)
    if devices[device_id] ~= nil and (info.type == rios.const.device.KEYBOARD or info.type == rios.const.device.JOYSTICK or info.type == rios.const.device.BUTTON or info.type == rios.const.device.SLIDER or info.type == rios.const.device.SWITCH or info.type == rios.const.device.KNOB) then
        return devices[device_id]
    end
    return nil
end

-- provides a mock joystick that combines multiple in one
-- The joysticks must share the same feature (NONE, LEFT or RIGHT)
rios.getAllJoysticks = function(feature:number)
    local joysticks = {}
    for id, info in rios.getDeviceList(JOYSTICK, feature) do
        table.insert(joysticks, rios.getInputDevice(id))
    end
    return {
        getX = function()
            for _,joystick in joysticks do
                if joystick.X ~= 0 then return joystick.X end
            end
            return 0
        end,
        getY = function()
            for _,joystick in joysticks do
                if joystick.Y ~= 0 then return joystick.Y end
            end
            return 0
        end
    }
end

-- provides a mock button that combines multiple in one
-- The buttons must share the same feature (UP, DOWN, ACCEPT, MENU, etc...)
rios.getAllButtons = function(feature:number)
    local buttons = {}
    for id, info in rios.getDeviceList(BUTTON, feature) do
        table.insert(buttons, rios.getInputDevice(id))
    end
    return {
        isButtonDown = function()
            for _,button in buttons do
                if button.ButtonDown then return true end
            end
            return false
        end,
        isButtonUp = function()
            for _,button in buttons do
                if button.ButtonUp then return true end
            end
            return false
        end,
        getButtonState = function()
            for _,button in buttons do
                if button.ButtonState then return true end
            end
            return false
        end,
        setledColor = function(color:color)
            for _,button in buttons do
                if button.LedColor ~= nil then
                    button.LedColor = color
                end
            end
        end,
        setLedState = function(state:boolean)
            for _,button in buttons do
                if button.LedState ~= nil then
                    button.LedState = state
                end
            end
        end
    }
end

-- provides an audio device (anything other than audio must return nil)
-- You must return a mock interface, see mockAudio function above
rios.getAudioDevice = function(device_id)
    -- minimal implementation
    local info = rios.getDeviceInfo(device_id)
    if devices[device_id] ~= nil and info.type == rios.const.device.AUDIO then
        return mockAudio(devices[device_id])
    end
    return nil
end

-- provides a screen device (anything other than screen or button with screen must return nil)
-- You must return a mock interface, see mockVideo function above
rios.getScreenDevice = function(device_id)
    -- minimal implementation
    local d_info = rios.getDeviceInfo(device_id)
    if devices[device_id] ~= nil and d_info.type == rios.const.device.SCREEN then
        local video = devices[device_id]
        return mockVideo(video, d_info.info.offset, d_info.info.size)
    elseif devices[device_id] ~= nil and d_info.type == rios.const.device.BUTTON and d_info.info.screen == true then
        if devices[d_info.info.screenInfo.device_id] ~= nil then
            local video = devices[d_info.info.screenInfo.device_id]
            if video ~= nil then
                return mockVideo(video, d_info.info.screenInfo.offset, d_info.info.screenInfo.size)
            end
        end
    end
    return nil
end

-- save a file to memory
rios.flashSave = function(file:string, table)
    -- minimal implementation
    local data = gdt.FlashMemory0:Load()
    data[file] = table
    gdt.FlashMemory0:Save(data)
end
-- load a file from memory
rios.flashLoad = function(file:string)
    -- minimal implementation
    local data = gdt.FlashMemory0:Load()
    return data[file]
end

rios.ROM = function()
    return gdt.ROM
end

-- return the CPU running rios
rios.CPU = function()
    return gdt.CPU0
end

-- APP MANAGEMENT

-- keep track of the active apps and their various states
rios.apps = {
    toInit = {},
    toRun = {},
    sleeping = {},
    toDestroy = {}
}
rios.internal = {
    run_id = nil,
    pid_count = 0
}

-- register an app to the app list
-- rios will soon run the init function of the app
-- then proceed to run it
-- This function will return the app id of the provided app
rios.registerApp = function(app):number
    rios.internal.pid_count = rios.internal.pid_count + 1
    rios.apps.toInit[rios.internal.pid_count] = app
    return rios.internal.pid_count
end

-- Makes your program sleep for a certain amount of time
-- you may want to do a yield after calling this function
-- if you need to keep the feature as close as the real sleep
rios.sleep = function(duration:number)
    if rios.internal.run_id ~= nil then
        rios.apps.sleeping[rios.internal.run_id] = {
            time = rios.CPU().Time+duration,
            app = rios.apps.toRun[rios.internal.run_id]
        }
        rios.apps.toRun[rios.internal.run_id] = nil
    end
end

-- Allow you to destroy an app on-demand by providing the app_id
-- not-yet initialized apps will just be discarded, but sleeping 
-- and running apps will go straight to the destroy list
rios.destroyApp = function(app_id:number)
    if rios.apps.toInit[app_id] ~= nil then
        rios.apps.toInit[app_id] = nil
    elseif rios.apps.toRun[app_id] ~= nil then
        rios.apps.toDestroy[app_id] = rios.apps.toRun[app_id]
        rios.apps.toRun[app_id] = nil
    elseif rios.apps.sleeping[app_id] ~= nil then
        rios.apps.toDestroy[app_id] = rios.apps.sleeping[app_id].app
        rios.apps.sleeping[app_id] = nil
    end
end

-- execute registered apps. Also handle init and destroy
-- The first parameter must be an instance of rios itself
-- to prevent having unregistered functions due to using a
-- being-constructed rios object here
rios.runApps = function(rios)
    for id, app in rios.apps.toInit do
        if typeof(app.init) == "function" then
            if app.init(rios) then
                rios.apps.toRun[id] = app
            end
        end
        rios.apps.toInit[id] = nil
    end
    for id, sleeping_app in rios.apps.sleeping do
        if sleeping_app.time < rios.CPU().Time then
            rios.apps.toRun[id] = sleeping_app.app
            rios.apps.sleeping[id] = nil
        end
    end
    for id, app in rios.apps.toRun do
        if typeof(app.run) == "function" then
            rios.internal.run_id = id
            if not app.run(rios) then
                rios.apps.toDestroy[id] = app
                rios.apps.toRun[id] = nil
            end
        end
    end
    rios.internal.run_id = nil
    for id, app in rios.apps.toDestroy do
        if typeof(app.destroy) == "function" then
            app.destroy(rios)
        end
        rios.apps.toDestroy[id] = nil
    end
end

-- Execute registered apps in a debugging environment.
-- see runApps for more details
-- errors will be printed on your multitool with the traceback
rios.debugRunApps = function(rios)
    function doRun()
        rios.runApps(rios)
    end
    function onErr(err_msg)
        setFgColor(31)
        print("== ERROR ==========")
        print(err_msg)
        print("-- trace ----------")
        print(debug.traceback())
        print("===================")
        resetFgColor()
    end
    xpcall(doRun, onErr)
end

-- Count how many apps are currently running
-- Useful to know for example if all apps have been
-- closed.
rios.countApps = function(rios)
    local count = 0
    for _ in rios.apps.toInit do count = count + 1 end
    for _ in rios.apps.toRun do count = count + 1 end
    for _ in rios.apps.sleeping do count = count + 1 end
    for _ in rios.apps.toDestroy do count = count + 1 end
    return count
end


return rios