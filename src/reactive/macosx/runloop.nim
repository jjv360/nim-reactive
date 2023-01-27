# import ./dialogs
import std/asyncdispatch
import ./dialogs
import ./native/foundation
import ./native/appkit



## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    try:

        # TODO: Start the autorelease pool?
        # NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

        # Run their code
        code()

        # Do event loop
        while true:

            # Drain the NSApplication event queue
            while true:

                # Get next event
                let event = NSApplication.sharedApplication.nextEventMatchingMask(NSEventMaskAny, untilDate = NSDate.distantPast, inMode = NSDefaultRunLoopMode, dequeue = true)
                if pointer(event) == nil:
                    break

                # Process the event
                NSApplication.sharedApplication.sendEvent(event)
        
            # Drain the asyncdispatch event queue
            if asyncdispatch.hasPendingOperations():
                asyncdispatch.drain(1)
        
    except CatchableError as err:

        # Show alert
        echo err.msg
        echo err.getStackTrace()
        alert(err.msg, "App crashed", dlgError)