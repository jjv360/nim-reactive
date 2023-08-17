import std/asyncdispatch
import stdx/dynlib
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

        # Run the Windows event loop
        var msg: MSG
        while true:

            # Drain the Win32 event queue
            while PeekMessage(msg, 0, 0, 0, PM_REMOVE) != 0:
                TranslateMessage(msg)
                DispatchMessage(msg)

            # Process pending asyncdispatch events
            if asyncdispatch.hasPendingOperations():
                asyncdispatch.drain(timeout = 50)

            # Quit the app if there's no pending operations on asyncdispatch and there's no mounted components
            if not asyncdispatch.hasPendingOperations() and ReactiveMountManager.shared.mountedComponents.len == 0:
                break
        
    except:

        # Show alert
        displayCurrentException()