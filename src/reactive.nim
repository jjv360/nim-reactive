# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import macros
import std/strutils
import std/sequtils
import std/json

# Compile-time arguments injected by the compiler
const ReactiveProjectRoot {.strdefine.} = ""
const ReactiveInjectImports {.strdefine.} = ""

# Macro to auto-import internal and external plugins
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
        import reactivepkg/config
        import reactivepkg/components
        import reactivepkg/plugins
        import reactivepkg/reactiveUi
        import reactivepkg/timers
        export config, components, plugins, reactiveUi, timers
    )

    # Import all builtin plugins
    # result.add(quote do:
    #     import reactivepkg/plugins/web
    #     export web
    # )

    # Import all injected plugins
    for pluginName in ReactiveInjectImports.split("|").filterIt(it != ""):
        let pluginIdent = ident(pluginName)
        result.add(quote do: 
            import `pluginIdent`
            export `pluginIdent`
        )


# Auto import now
reactiveAutoImport()


## App entry point
proc startReactiveApp*() =

    # Start the platform plugin. 
    ReactivePlugins.shared.activePlatformPlugin.onPlatformStartup()

    # Run async dispatch loop forever
    when defined(js):

        # Javascript does not need to run forever
        discard

    else:

        # For native code, we need to run the asyncdispatch loop forever to prevent the app from exiting and to handle events
        runForever()