# import ./dialogs
import std/asyncdispatch
import std/os
import ./dialogs
import ./native/foundation
import ./native/appkit
import ../shared/mounts



## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    try:

        # Run their code
        code()

        # Do event loop
        while true:

            # Drain the NSApplication event queue
            while true:

                # Get next event
                let blockUntil = NSDate.dateWithTimeIntervalSinceNow(0.002)
                let event = NSApplication.sharedApplication.nextEventMatchingMask(NSEventMaskAny, untilDate = blockUntil, inMode = NSDefaultRunLoopMode, dequeue = true)
                if pointer(event) == nil:
                    break

                # Process the event
                NSApplication.sharedApplication.sendEvent(event)
        
            # Drain the asyncdispatch event queue
            if asyncdispatch.hasPendingOperations():
                asyncdispatch.drain(timeout = 2)

            # Quit the app if there's no pending operations on asyncdispatch and there's no rendered windows
            if not asyncdispatch.hasPendingOperations() and ReactiveMountManager.shared.mountedComponents.len == 0:
                break
        
    except CatchableError as err:

        # Show alert
        echo err.msg
        echo err.getStackTrace()
        alert(err.msg, "App crashed", dlgError)