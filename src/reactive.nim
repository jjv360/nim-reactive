# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import macros
import std/strutils
import std/sequtils
import std/json

# Compile-time arguments injected by the compiler
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
    for pluginName in ReactiveInjectImports.split(",").filterIt(it != ""):
        let pluginIdent = ident(pluginName)
        result.add(quote do: 
            import `pluginIdent`
            export `pluginIdent`
        )

    # Workaround: Autocomplete doesn't work since the app is built using a standard Nim build command. This means no platform plugins are injected...
    # So we can now just import a default plugin for the autocomplete process to use
    when not defined(ReactiveInjectImports):
        result.add(quote do:
            import reactive_platform_win32
            export reactive_platform_win32
        )


# Auto import now
reactiveAutoImport()

## App entry point
template startReactiveApp*(body: untyped) =

    # Call the prepare function that has been exported by the platform plugin
    prepareReactiveAppPlatform()

    # Run the app's startup code
    `body`

    # Call the start function that has been exported by the platform plugin
    startReactiveAppPlatform()


## App entry point without a body
template startReactiveApp*() =
    startReactiveApp:
        discard