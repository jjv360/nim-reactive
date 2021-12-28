# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import macros

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
        import reactivepkg/config
        import reactivepkg/components
        import reactivepkg/plugins
        import reactivepkg/reactiveUi
        import reactivepkg/timers
        export config, components, plugins,reactiveUi, timers
    )

    # Import all builtin plugins
    result.add(quote do:
        import reactivepkg/plugins/web
        export web
    )

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

# Import builtin plugins
# import reactivepkg/plugins/web

# ## When used as a library, export things
# import reactivepkg/config
# import reactivepkg/component
# export config, component

## This code is run when we are executing our command-line binary.
when isMainModule:
    import os, osproc
    import strformat
    import sequtils
    import strutils

    # Find path to a platform binary
    proc pathToPlatformBinary(platformID: string): string =

        # Try find the exe on the path
        var exe = findExe("reactive_platform_" & platformID)
        if exe != "":
            return exe

        # Not found, try search for built-in platform plugin
        exe = execProcess("nimble path reactive").strip() / fmt"reactive_platform_{platformID}"
        if fileExists(exe):
            return exe

        # Not found, try search for an external platform plugin
        exe = execProcess(fmt"nimble path reactive_platform_{platformID}").strip() / fmt"reactive_platform_{platformID}"
        if fileExists(exe):
            return exe

        # Still not found!
        raiseAssert(fmt"Platform plugin '{platformID}' not found! Have you added the requirement to your nimble file?")

    # First param is always the platform ID
    var args = commandLineParams()
    var platform = args[0]
    args = args[1..args.len-1]

    # Get command to execute
    let cmd = concat(@[pathToPlatformBinary(platform)], args).quoteShellCommand

    # Run the platform binary, and quit with the same exit code
    echo "Running command: " & cmd
    quit(execShellCmd(cmd))

    # CLI-only imports
#     import docopt
#     import std/os
#     import std/osproc
#     import std/strutils
#     import std/strformat
#     import regex

    

#     ## Extract the "Reactive:" section of code from the source file
#     proc extractReactiveConfigSection(sourceCode: string): string =

#         # Read Reactive config section of the code
#         var reactiveSection = ""
#         var isInsideSection = false
#         var whitespacePrefix = ""
#         for line in sourceCode.splitLines:

#             # Check if this is a comment line or an empty line
#             if line.strip().startsWith("#") or line.strip().len == 0:
#                 continue

#             # Check if currently inside the section
#             if isInsideSection:

#                 # Check if we're at the first line or not
#                 if whitespacePrefix.len == 0:

#                     # First line! Record whitespace prefix
#                     var match: RegexMatch
#                     let didMatch = line.find(re"(\s*)", match)
#                     if not didMatch:
#                         raiseAssert("Missing body section of the 'Reactive:' config.")

#                     # Store this line and the whitespace prefix
#                     whitespacePrefix = match.groupFirstCapture(0, line)
#                     reactiveSection &= "\n" & line

#                 elif line.startsWith(whitespacePrefix):

#                     # Still inside the section, store this line
#                     reactiveSection &= "\n" & line

#                 else:

#                     # No longer inside the section
#                     break

#             else:

#                 # Not inside section, check if found
#                 if line.strip().startsWith("Reactive:"):

#                     # Start found
#                     isInsideSection = true
#                     reactiveSection &= "Reactive:"
#                     continue

#                 else:

#                     # Not found yet
#                     continue

#         # Check if found
#         if reactiveSection.len == 0:
#             raiseAssert("Missing 'Reactive:' config section in source code.")

#         # Done
#         return reactiveSection
                
  
#     # Parse command line options
#     # let args = docopt(doc, version = "Nim Reactive 1.0")
#     # let action = $args["<action>"]
#     # let platformName = $args["<platform>"]

    


#     # Read Reactive config section of the code
#     let reactiveSection = extractReactiveConfigSection(readFile(appEntryPath))
    
#     # Build code to use to export the config
#     let exportConfigCode = fmt"""

# # Common imports
# import reactive

# # The app's Reactive: section
# {reactiveSection}

#     """

#     # Run it
#     let output = startProcess("nim", workingDir=absolutePath(appEntryPath / ".."), options={poUsePath, poParentStreams}, args=[
#         "compile",
#         "--run",
#         "--app:gui",
#         "--define:ReactivePlatform:" & platformName,
#         "--define:ReactiveAppEntryFile:" & appEntryPath,
#         "--define:ReactiveAppWantsConfigOutput",
#         appEntryPath
#     ])

#     echo "==============="
#     # echo output
#     echo "==============="


#     # Begin building
#     # echo "Building app: " & appEntryPath
#     # let returnCode = startProcess("nim", workingDir=absolutePath(appEntryPath / ".."), options={poUsePath, poParentStreams}, args=[
#     #     "js", 
#     #     "--app:gui",
#     #     "--define:ReactivePlatform:" & platformName,
#     #     "--define:ReactiveAppEntryFile:" & appEntryPath,
#     #     "--out:" & absolutePath(appEntryPath / ".." / "dist" / "app.js"),
#     #     appEntryPath
#     # ]).waitForExit()

#     # # Write a wrapper HTML file
#     # writeFile(appEntryPath / ".." / "dist" / "app.html", """
#     #     <!DOCTYPE html>
#     #     <html>
#     #     <head>
#     #         <title>App Title</title>
#     #         <meta name="viewport" content="width=device-width, initial-scale=1.0" />
#     #     </head>
#     #     <body>

#     #         <!-- App code -->
#     #         <script src="app.js"></script>
            
#     #     </body>
#     #     </html>
#     # """.strip())

# else:

    