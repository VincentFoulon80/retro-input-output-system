-- Secondary CPU that handle the volume and resolution knobs


local hres = gdt.Knob0
local vres = gdt.Knob1
local volume = gdt.Knob2
local speed = gdt.Knob4

local font = gdt.ROM.System.SpriteSheets["StandardFont"]

local audio = gdt.AudioChip0
local video = gdt.VideoChip1
local video2 = gdt.VideoChip3

-- update function is repeated every time tick
function update()

    local hresv = math.round(((hres.Value + 100)/200)*128)
    local vresv = math.round(((vres.Value + 100)/200)*128)
    local volv = ((volume.Value + 100)/200)*100
    local speedv = math.round(((speed.Value + 100)/200)*8)-1
    if not speed.IsMoving then
        speed.Value = (((speedv+1)/8)*200)-100
    end
    speedv = 1/64*(2^speedv)*100

    video:Clear(color.black)
    video:DrawText(vec2(2,4), font, ""..hresv, color.white, color.black)
    video:DrawText(vec2(2,33), font, ""..vresv, color.white, color.black)
    video2:Clear(color.black)
    video2:DrawText(vec2(2,4), font, string.format("%.1f", speedv).."%", color.white, color.black)
    audio.Volume = volv
end