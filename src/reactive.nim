##
## Entry point for the lib

# General stuff
import ./reactive/shared/basecomponent
import ./reactive/shared/utils
import ./reactive/shared/mounts
import ./reactive/shared/htmloutput
import ./reactive/shared/basewebcomponent
import ./reactive/shared/webview_bridge
export basecomponent, utils, mounts, htmloutput, basewebcomponent, webview_bridge

# DSL stuff ... we need to export some other libraries as well so they're available from the macro output
import ./reactive/shared/componentsDSL
import std/tables
import classes
export componentsDSL, tables, classes

# Web components
import ./reactive/shared/htmlcomponents
export htmlcomponents

# Platform specific components
when defined(windows):

    # Windows platform
    import ./reactive/windows/dialogs
    import ./reactive/windows/runloop
    import ./reactive/windows/components/window
    import ./reactive/windows/components/trayicon
    import ./reactive/windows/components/hwnd_component
    export dialogs, runloop, window, trayicon, hwnd_component

elif defined(macosx):

    # Mac OS X platform
    import ./reactive/macosx/dialogs
    import ./reactive/macosx/window
    import ./reactive/macosx/runloop
    export dialogs, runloop, window

else:

    # Unknown platform
    static:
        raiseAssert("NimReactive is not supported for this target.")