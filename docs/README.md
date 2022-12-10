# RIOS For OS Devs:

## Setting up RIOS on your gadget

- Download a `rios.lua` file from any example or the empty one at the root of this repository
- If you took the empty file:
    - Fill the functions with missing functionality (see `-- todo`)
- If you took any of the example file:
    - Set up the two device lists located in the middle of the rios file, below the constants
- On the `CPU` file of your gadget, require `rios.lua` in a variable
  ```lua
  local rios = require("rios.lua")
  ```
- (OPTIONAL) remove access to gdt just after requiring RIOS
  ```lua
  gdt = nil
  ```

## Running apps using RIOS

- Require the apps you want to run, and use the `registerApp` function to register it to RIOS
- In the `update()` function, run: 
  ```lua
  rios.runApps(rios)
  ```

# RIOS For App devs

## Devkit

You may want to use the [Devkit](https://steamcommunity.com/sharedfiles/filedetails/?id=2899473449) to build your apps, since it gives you plenty of tools to help you code your apps:
- Many different inputs are available to play with
- Features a main and secondary screen
- Errors are reported with a full traceback so you can debug your code easily
- You can change the main screen size from any value up to 128x128
- You can pause the execution of you app, and do a step-by-step run
- You can also change the execution speed of your app, e.g. to slow it down

## Building apps

If you start with a blank file, it is advised to at least copy the [app template](https://github.com/VincentFoulon80/retro-input-output-system/blob/master/example_app/app_template.lua) or the [devkit's Hello world app](https://github.com/VincentFoulon80/retro-input-output-system/blob/master/example_os/devkit/new_app.lua).

You can then have a look at the [API](API.md)