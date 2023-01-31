import std/asyncdispatch
import ./dialogs
import winim/com
import ../shared/mounts

## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    try:

        # Set DPI awareness
        SetProcessDPIAware()

        # Run their code
        code()

        # Create Win32 timer so our event loop is running at a minimum of 1ms, this is necessary to allow
        # asyncdispatch to run alongside the Win32 event loop in the same thread
        SetTimer(0, 0, 1, nil)

        # Run the Windows event loop
        var msg: MSG
        while GetMessage(msg, 0, 0, 0) != 0:
            TranslateMessage(msg)
            DispatchMessage(msg)

            # Process asyncdispatch's event loop
            if asyncdispatch.hasPendingOperations():
                asyncdispatch.drain(1)

            # Quit the app if there's no pending operations on asyncdispatch and there's no mounted components
            if not asyncdispatch.hasPendingOperations() and ReactiveMountManager.shared.mountedComponents.len == 0:
                break
        
    except Exception as err:

        # Show alert
        echo err.msg
        echo err.getStackTrace()
        alert(err.msg, "App crashed", dlgError)