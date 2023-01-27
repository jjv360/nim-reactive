##
## Entry point for the lib

# General stuff
import ./reactive/shared/basecomponent
import ./reactive/shared/utils
import ./reactive/shared/mounts
export basecomponent, utils, mounts

# DSL stuff ... we need to export some other libraries as well so they're available from the macro output
import ./reactive/shared/componentsDSL
import std/tables
import classes
export componentsDSL, tables, classes

# Generic components
# import ./reactive/components/window
# export window

# Platform specific components
when defined(windows):

    # Windows platform
    import ./reactive/windows/dialogs
    import ./reactive/windows/window
    import ./reactive/windows/runloop
    export dialogs, runloop, window

elif defined(macosx):

    # Windows platform
    import ./reactive/macosx/dialogs
    import ./reactive/macosx/window
    import ./reactive/macosx/runloop
    export dialogs, runloop, window

else:

    # Unknown platform
    static:
        raiseAssert("NimReactive is not supported for this target.")