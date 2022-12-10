# RIOS API

## OS API

- [countApps](#rioscountappsrios)
- [debugRunApps](#riosdebugrunappsrios)
- [destroyApp](#riosdestroyappapp_idnumber)
- [registerApp](#riosregisterappappnumber)
- [runApps](#riosrunappsrios)


### rios.countApps(rios)

Count how many apps are currently running.

Useful to know for example if all apps have been closed. (=0)

**Parameters:**
- `rios`: An instance of RIOS itself, because the function is built with partial data we need to be sure we got the most complete instance.


### rios.debugRunApps(rios)

Execute registered apps in a debugging environment.

See [runApps](#riosrunappsrios) for more details.  
Errors will be printed on your multitool with a complete traceback.

**Parameters:**
- `rios`: An instance of RIOS itself, because the function is built with partial data we need to be sure we got the most complete instance.

### rios.destroyApp(app_id:number)

Allow you to destroy an app on-demand by providing the app_id.

Not-yet initialized apps will just be discarded, but sleeping and running apps will go straight to the destroy list.

The app will be effectively destroyed on the next call to [runApps](#riosrunappsrios)

**Parameters:**
- `app_id`: the app_id to destroy

### rios.registerApp(app):number

Register an app to the app list.

RIOS will run the init function of the app then proceed to run it on the next call to [runApps](#riosrunappsrios)


**Parameters:**
- `app`: an app to run. Provided by requiring the app file directly

**Returns:**
The app's process ID. Useful if you want to manually [destroy](#riosdestroyappapp_idnumber) it later.

### rios.runApps(rios)

Execute registered apps, also handle init and destroy.

The first parameter must be an instance of rios itself
to prevent having unregistered functions due to using a
being-constructed rios object here

**Parameters:**
- `rios`: An instance of RIOS itself, because the function is built with partial data we need to be sure we got the most complete instance.

## CONSTANTS

- [Device](#device)
  - [MEMORY](#memory)
  - [ROM](#rom)
  - [SCREEN](#screen)
  - [LCD](#lcd)
  - [LED](#led)
  - [AUDIO](#audio)
  - [KEYBOARD](#keyboard)
  - [JOYSTICK](#joystick)
  - [BUTTON](#button)
  - [SLIDER](#slider)
  - [SWITCH](#switch)
  - [KNOB](#knob)
- [Feature](#feature)

RIOS Provides a set of constants to use between APPS and OSes. The rules must be strictly followed in order to keep full compatibility with RIOS.

### Device

Devices are every component you may need to interact with you applications. It contains both Input and Output devices.

Each device must define a feature, provided by the other constant list `rios.const.feature`

#### MEMORY

The OS provides Flash memory

**Features:** `NONE`
```lua
info = {
  available:number --how many bytes are still free
}
```

#### ROM

The OS has ROM access

**Features:** `NONE`

#### SCREEN

The OS provides a screen, or part of a screen

**Features:**, `MAIN`, `SECONDARY`
```lua
info = {
  offset:vec2 -- top-left corner of the allowed screen space
  size:vec2 -- size of the allowed screen space
}
```

#### LCD

The OS provides a LCD screen

**Features:** `NONE`

#### LED

The OS provices a LED

**Features:** `NONE`
```lua
info = {
   matrix:boolean -- if the led is currently a matrix
   size:vec2 -- if matrix = true, this may be anything other than vec2(1,1)
}
```

#### AUDIO

The OS provides audio capabilities

**Features:** `NONE`
```lua
info = {
	  channels:number -- amount of channels available
}
```

#### KEYBOARD

The OS provices keyboard access

**Features:** `NONE`

#### JOYSTICK

The OS provides a joystick or a dpad.

**Features:** `LEFT`, `RIGHT`

#### BUTTON

The OS provides a button

**Features:** `UP`, `DOWN`, `LEFT`, `RIGHT`, `CONFIRM`, `BACK`, `MENU`, `OTHER1`, `OTHER2`
```lua
info = {
    led:boolean -- is the button a LedButton?
    screen:boolean -- is the button a ScreenButton?
    screenInfo = { -- only available when screen=true
       device_id:string -- the device_id the button is connected to
       offset:vec2 -- top-left corner of the screen used by the button
       size:vec2 -- size of the screen used by the button. typically 16x16
   }
}
```

#### SLIDER

The OS provides a slider

**Features:** `NONE`

#### SWITCH

The OS provides a switch

**Features:** `NONE`

#### KNOB

The OS provides a knob

**Features:** `NONE`

### Feature

Features are secondary information used by devices to define their role

- NONE
- UP
- RIGHT
- DOWN
- LEFT
- CONFIRM
- BACK
- OTHER1
- OTHER2
- MENU
- MAIN
- SECONDARY

## APP API

- [CPU](#rioscpu)
- [ROM](#riosrom)
- [getDeviceList](#riosgetdevicelistd_typenumber-featurenumber)
- [hasDevice](#rioshasdeviced_typenumber-featurenumberboolean)
- [getDeviceInfo](#riosgetdeviceinfodevice_id)
- [getInputDevice](#riosgetinputdevicedevice_id)
- [getAllJoysticks](#riosgetalljoysticksfeaturenumber)
  - [getX](#joysticksgetxnumber)
  - [getY](#joysticksgetynumber)
- [getAllButtons](#riosgetallbuttonsfeaturenumber)
  - [isButtonDown](#buttonsisbuttondownboolean)
  - [isButtonUp](#buttonsisbuttonupboolean)
  - [getButtonState](#buttonsgetbuttonstateboolean)
  - [setLedState](#buttonssetledstatestateboolean)
  - [setLedColor](#buttonssetledcolorcolorcolor)
- [getAudioDevice](#riosgetaudiodevicedevice_id)
- [getScreenDevice](#riosgetscreendevicedevice_id)
- [flashSave](#riosflashsavefilestring-table)
- [flashLoad](#riosflashloadfilestring)

### rios.CPU()

Get the CPU instance used by RIOS.

**Returns:**
a CPU instance, basically `gdt.CPU#`

### rios.ROM()

Get the ROM instance

**Returns:**
A ROM instance, basically `gdt.ROM`

### rios.getDeviceList(d_type:number?, feature:number?)

This function will return any device the Operating System let you operate, filtered by type and/or feature.


**Parameters:**
- `d_type`: Any value of `rios.const.device`, or `nil`
- `feature`: Any value of `rios.const.feature`, or `nil`

**Returns:**
A list of device following this schema:
```lua
[device_id] = {
  type = -- any value of rios.const.device
  feature = -- any value of rios.const.feature
  info = -- table displaying informations regarding the device
}
```

### rios.hasDevice(d_type:number, feature:number?):boolean

check if a given device is provided by the OS.

**Parameters:**
- `d_type`: Any value of `rios.const.device`, or `nil`
- `feature`: Any value of `rios.const.feature`, or `nil`

**Returns:**
true if at least one device exist with this type and/or feature


### rios.getDeviceInfo(device_id)

Get the information table from a given device ID.

**Parameters:**
- `device_id`: An ID from the device list

**Returns:**
A list of device following this schema:
```lua
[device_id] = {
  type = -- any value of rios.const.device
  feature = -- any value of rios.const.feature
  info = -- table displaying informations regarding the device
}
```

### rios.getInputDevice(device_id)

Get an Input device from a given device ID.

The device ID must be an input, else `nil` will be returned

**Parameters:**
- `device_id`: An ID from the device list

**Returns:**
An instance of the input : `LedButton`, `Stick`, `Knob`, ...

### rios.getAllJoysticks(feature:number)

Get all the joysticks matching the given feature into a mock joystick.

**Parameters:**
- `feature`: Any value from `rios.const.feature`

**Returns:**
A mock interface that allow you to query multiple joysticks at the same time

#### joysticks.getX():number
Query the X value of the contained joysticks

#### joysticks.getY():number
Query the Y value of the contained joysticks


### rios.getAllButtons(feature:number)

Get all the buttons matching the given feature into a mock button.

**Parameters:**
- `feature`: Any value from `rios.const.feature`

**Returns:**
A mock interface that allow you to query multiple buttons at the same time

#### buttons.isButtonDown():boolean
Query if any button has been pushed down

#### buttons.isButtonUp():boolean
Query if any button has been released

#### buttons.getButtonState():boolean
Query if any button is still pressed

#### buttons.setLedState(state:boolean)
Tell all LedButtons to set their Led State to the provided value

#### buttons.setLedColor(color:color)
Tell all LedButtons to set their Led Color to the provided value


### rios.getAudioDevice(device_id)

Get an Audio device from a given device ID.

The device ID must be of type AUDIO, else `nil` will be returned

**Parameters:**
- `device_id`: An ID from the device list

**Returns:**
A mock instance of the AudioChip.  
Every functions are still in place, you just need to use `.` instead of `:` when calling the functions.  
The only exception is the Volume property, that is now inaccessible. You must use `SetChannelVolume` instead.

### rios.getScreenDevice(device_id)

Get a Screen device from a given device ID.

The device ID must be of type SCREEN or BUTTON with screen=true, else `nil` will be returned

**Parameters:**
- `device_id`: An ID from the device list

**Returns:**
A mock instance of the VideoChip.  
Every functions are still in place, you just need to use `.` instead of `:` when calling the functions.  

Note: the mock video is not entirely finished. While every functions is implemented, they don't all prevent overflowing out of the screen yet.
The most basic ones are done though, like Line and Rectangle. DrawText stops overflowing correctly on the right side of the screen, but not on the bottom.

### rios.flashSave(file:string, table)

Save a given file to the flash memory, if available

**Parameters:**
- `file`: The name of the file to save
- `table`: The data you want to save

### rios.flashLoad(file:string)

Loads a given file to the flash memory, if available

**Parameters:**
- `file`: The name of the file to load

**Returns:**
The stored data, if any