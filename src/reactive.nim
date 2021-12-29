# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import macros
import std/strutils
import std/json

# List of registered plugins
var registeredPlugins {.compileTime.}: seq[string]

# Macro to auto-import submodules
macro reactiveAutoImport() =

    # Create output
    result = newStmtList()

    # Import asyncjs or asyncdispatch
    when defined(js):
        result.add quote do:
            import asyncjs
            export asyncjs
    else:
        result.add quote do:
            import asyncdispatch
            export asyncdispatch
        

    # Import classes which are always used
    result.add(quote do:
        import reactive/config
        import reactive/components
        import reactive/plugins
        import reactive/reactiveUi
        import reactive/timers
        export config, components, plugins,reactiveUi, timers
    )

    # Import all builtin plugins
    # result.add(quote do:
    #     import reactivepkg/plugins/web
    #     export web
    # )

    # Import all external plugins ... read the requires section of the app's nimble config
    echo callsite.repr
    echo gorge("nimble dump --json").strip()
    let requiresList = gorge("nimble dump --json").strip().parseJson()["requires"]
    for requireItem in requiresList.items:
        echo "Importing: " & $requireItem["name"]


# Auto import now
reactiveAutoImport()


## App entry point
template Reactive*(body: untyped) =

    # Create namespace function
    proc reactiveAppInit() =

        # Current platform ID
        var reactiveInitCurrentPlatformID = "all"

        # Platform just sets the current platform ID
        proc platform(platformID: string, body2: proc()) =
            reactiveInitCurrentPlatformID = platformID
            body2()
            reactiveInitCurrentPlatformID = "all"

        # Config sets a config option
        proc config(name: string, value: string) =
            ReactiveConfig.shared.put(reactiveInitCurrentPlatformID, name, value)

        # Run their code
        body

        # Echo config out
        # echo "=== ReactiveConfigStart ==="
        # for key, value in reactiveGlobalConfig.mpairs:
        #     echo key & " = " & value
        # echo "=== ReactiveConfigEnd"

        # Start the platform plugin. 
        ReactivePlugins.shared.activePlatformPlugin.onPlatformStartup()

        # Run async dispatch loop forever
        when defined(js):

            # Javascript does not need to run forever
            discard

        else:

            # For native code, we need to run the asyncdispatch loop forever to prevent the app from exiting
            runForever()

    # Run it
    reactiveAppInit()