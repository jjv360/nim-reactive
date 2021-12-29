##
## Utility functions


## Some options only available in native code
when not defined(js):
    import json
    import os
    import sequtils
    import strutils

    # Fetch the build options passed in from the main binary
    proc getReactiveBuildOptions*(): JsonNode =

        # Get flag
        let flags = commandLineParams().filterIt(it.startsWith "--buildinfo:")
        if flags.len() == 0:
            raiseAssert("Couldn't find build options on the command line. Make sure you use 'nimble reactive xxx' instead of running this binary directly.")

        # Parse JSON
        return flags[0].substr(12).parseJson()