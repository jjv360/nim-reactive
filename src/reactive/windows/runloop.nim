import std/asyncdispatch
import ./dialogs
import winim/lean
import ../shared/mounts

## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    try:

        # Set DPI awareness
        SetProcessDPIAware()

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
        
    except Exception as err:

        # Show alert
        echo err.msg
        echo err.getStackTrace()
        alert(err.msg, "App crashed", dlgError)