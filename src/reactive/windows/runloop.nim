import std/asyncdispatch
import stdx/dynlib
import std/times
import ./dialogs
import winim/mean
import ../shared/mounts
import ../shared/utils

## Useful functions from uxtheme.dll
dynamicImport("uxtheme.dll"):

    ## Preferred app modes
    type PreferredAppMode = enum 
        APPMODE_DEFAULT = 0
        APPMODE_ALLOWDARK = 1
        APPMODE_FORCEDARK = 2
        APPMODE_FORCELIGHT = 3
        APPMODE_MAX = 4

    ## Set the preferred app mode, mainly changes context menus
    proc SetPreferredAppMode(mode : PreferredAppMode) {.stdcall, winapiOrdinal:135, winapiVersion: "10.0.17763".}


## Run the WinApi event loop
proc winApiEventLoop() {.async.} =

    # Run continuously while there are mounted components
    while ReactiveMountManager.shared.mountedComponents.len > 0:

        # Drain the Win32 event queue
        var msg: MSG
        while PeekMessage(msg, 0, 0, 0, PM_REMOVE) != 0:
            TranslateMessage(msg)
            DispatchMessage(msg)

        # Yield to the dispatcher
        await sleepAsync(5)


## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    try:

        # Set DPI awareness
        SetProcessDPIAware()

        # Allow app to be in dark mode if the system is in dark mode
        try:
            SetPreferredAppMode(APPMODE_ALLOWDARK)
        except:
            echo "[Reactive] Failed to set dark mode support: " & getCurrentExceptionMsg()

        # Run their code
        code()

        # Setup WinApi event loop
        asyncCheck winApiEventLoop()

        # Run the async dispatcher forever
        runForever()
        
    except:

        # Show alert
        displayCurrentException()