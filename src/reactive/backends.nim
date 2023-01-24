##
## Backends are used to display HTML windows and interact with the system.

import ./backends/basebackend
export basebackend

# Select backend
when defined(macosx):

    # Use the Mac backend
    import ./backends/macbackend
    let reactiveBackend* = MacBackend.init()

elif defined(windows):

    # Use the Mac backend
    import ./backends/windowsbackend
    let reactiveBackend* = WindowsBackend.init()
    
else:

    # No supported backend found
    raiseAssert("No backend found for this platform.")