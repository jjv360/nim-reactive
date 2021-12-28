##
## Utility functions


## Some options only available in native code
when not defined(js):
    import docopt
    import std/os
    import std/osproc
    import strutils
    import strformat

    ## Command line documentation
    const doc = """
    Nim Reactive - a framework for building cross-platform apps in Nim.

    Usage:
        reactive <action> <path>
        reactive (-h | --help)
        reactive --version

    Options:
        -h --help       Show this screen.
        --version       Show version.
    """.strip()

    ## Fetch command line args
    proc processCommandLine*(customDoc: string = doc): Table[string, docopt.Value] =

        # Parse command line options
        return docopt(customDoc, version = "Nim Reactive 1.0")


    ## Get path to input file
    proc absoluteInputFilePath*(args: Table[string, docopt.Value]): string =

        # Find path to app
        var appEntryPath = absolutePath($args["<path>"])
        if dirExists(appEntryPath) and fileExists(appEntryPath / "app.nim"):

            # User entered a directory instead of the path to the nim file, but we know where it is
            appEntryPath = appEntryPath / "app.nim"

        elif dirExists(appEntryPath):

            # User entered a directory instead of the path to the nim file, and we don't know where the app's entry file is
            raise ValueError.newException("File does not exist: " & (appEntryPath / "app.nim"))

        elif fileExists(appEntryPath):

            # File exists, we're good to go
            return appEntryPath

        else:

            # Not found!
            raise ValueError.newException("File does not exist: " & appEntryPath)