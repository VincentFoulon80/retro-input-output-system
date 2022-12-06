-- App template for rios applications
-- the first thing to avoid any compatibility issue is to not use gdt at all
-- instead let rios give you the devices you need

-- add any variables you want to use in you app here
-- local myvar = "stuff"
app = {
    -- Initialize app, setup variables, fetch rios devices...
    -- return true if successfully initalized
    -- return false to quit immediately
    init = function(rios):boolean
        -- init your app here
        return true
    end,
    -- Run one tick of the app. The OS will most of the time call this function on each tick
    -- return true if the app should continue to run
    run = function(rios):boolean
        -- run your app
        return true
    end,
    -- The app is about to be destroyed, finish what you were doing and save your state if needed
    destroy = function(rios)
        -- uninit your app here
    end
}


return app