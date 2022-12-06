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
            -- todo
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
        -- the OS provides a joystick
        JOYSTICK = 7,
        -- the OS provides a button
        -- info = {
        --     led:boolean -- is the button a LedButton?
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
        UP = 1,
        RIGHT = 2,
        DOWN = 3,
        LEFT = 4,
        CONFIRM = 5,
        BACK = 6,
        OTHER1 = 7,
        OTHER2 = 8,
        MENU = 9,
        -- screen
        MAIN = 10,  -- largest screen
        SECONDARY = 11, -- smallest screen, used to display small info
    }
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
        -- todo
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
    -- todo
end

-- provides an audio device (anything other than audio must return nil)
-- You must return a mock interface, see mockAudio function above
rios.getAudioDevice = function(device_id)
    -- todo
end

-- provides a screen device (anything other than screen must return nil)
-- You must return a mock interface, see mockVideo function above
rios.getScreenDevice = function(device_id)
    -- todo
end

-- save a file to memory
rios.flashSave = function(file:string, table)
    -- todo
end
-- load a file from memory
rios.flashLoad = function(file:string)
    -- todo
end

rios.ROM = function()
    return gdt.ROM
end

return rios