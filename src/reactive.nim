##
## Entry point for the lib

# General stuff
import ./reactive/shared/basecomponent
import ./reactive/shared/componentsDSL
import ./reactive/shared/utils
export basecomponent, utils, componentsDSL

# Platform specific
when defined(windows):

    # Windows platform
    import ./reactive/windows/dialogs
    import ./reactive/windows/window
    import ./reactive/windows/runloop
    export dialogs, window, runloop

else:

    # Unknown platform
    static:
        raiseAssert("NimReactive is not supported for this target.")