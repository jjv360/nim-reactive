##
## Methods and definitions used for the reactive config

import classes
import std/tables
import std/strutils

## Global config class
singleton ReactiveConfig:

    ## Field values
    var config: Table[string, string] = {

        # Use the window that has `registerAs "main"` as the default entry window.
        "all:mainwindow": "main"

    }.toTable

    ## Get a config option
    method get(platformID: string, key: string): string =

        # Get platform specific value
        let id = (platformID.strip() & ":" & key.strip()).toLowerAscii()
        if this.config.contains(id):
            return this.config[id]

        # Get generic value
        let id2 = ("all:" & key.strip()).toLowerAscii()
        if this.config.contains(id2):
            return this.config[id2]

        # Not found
        return ""


    ## Set a config option
    method put(platformID: string, key: string, value: string) =

        # Sanitise the key
        let id = (platformID.strip() & ":" & key.strip()).toLowerAscii()

        # Store the value
        this.config[id] = value

# var mysharedReactiveConfig: ReactiveConfig = nil
# proc shared*(_: type[ReactiveConfig]): ReactiveConfig =
#     if mysharedReactiveConfig == nil: mysharedReactiveConfig = ReactiveConfig.init()
#     return mysharedReactiveConfig



## Configuration entry point
# macro Reactive*(body: untyped) =

#     # Add code to configure options
#     result = newStmtList()

#     # Import all builtin plugins
#     result.add(quote do:
#         import reactivepkg/plugins
#         import reactivepkg/plugins/web
#     )

#     # TODO: Import external plugins
    
#     # Setup config
#     result.add(quote do:

#         # Create namespace function
#         proc setMyReactiveConfig() =

#             # Register a platform
#             template platform(platformID: string, body2: untyped) =
                
#                 # Make sure platform exists in config
#                 # reactiveGlobalConfig["internal:platform.registered." & platformID] = "1"

#                 # Set a variable
#                 proc config(name: string, value: string) =
#                     reactiveGlobalConfig[platformID & ":" & name] = value

#                 # Run their code
#                 body2

#             # Run their code
#             `body`

            # Echo config out
            # echo "=== ReactiveConfigStart ==="
            # for key, value in reactiveGlobalConfig.mpairs:
            #     echo key & " = " & value
            # echo "=== ReactiveConfigEnd"

#         # Run namespace function
#         setMyReactiveConfig()
        
#     )

#     # Start the platform plugin
#     const ReactivePlatform {.strdefine.} = "unknown"
#     result.add(quote do:
#         ReactivePlugins.shared.initPlatform(`ReactivePlatform`)
#     )

#     # result.add(prefix)

#     # Check if the cli tool wants config output
#     # when defined(ReactiveAppWantsConfigOutput):

#     #     # output it
#     #     echo "=== ReactiveConfigStart ==="
#     #     for key, value in reactiveGlobalConfig.mpairs:
#     #         echo key & "=" & value
#     #     echo "=== ReactiveConfigEnd"
#     #     return

#     # Import all plugins




## Configuration entry point
# macro Reactive*(body: untyped) = 
#     discard

    # # Create new macro statement list
    # result = newStmtList()

    # # Fetch all builtin plugins
    # let pluginDirectory = currentSourcePath.parentDir / "plugins"
    # echo "Finding plugins: " & pluginDirectory

    # # Run prefix code
    # let prefixCode = quote do:

        # # Create namespace function
        # proc setMyReactiveConfig() =

        #     # Set a variable
        #     proc config(group: string, name: string, value: string) =
        #         reactiveGlobalConfig[group & ":" & name] = value

        #     # Register a platform
        #     proc platform(name: string) =
                
        #         # Make sure platform exists in config
        #         config "_internal", "platforms.registered." & name, "1"
        #         echo "Registered platform: " & name

        #     # Run their code
        #     body

        # # Run namespace function
        # setMyReactiveConfig()

    # # Add prefix code to body

    # # Register all built-in plugins


    # # Output new config
    # echo "Reactive config:"
    # for key, value in reactiveGlobalConfig.mpairs:
    #     echo " > " & key & " : " & value



