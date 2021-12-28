##
## Contains the plugin registry

import classes
import std/sequtils

## Base plugin class
class ReactivePlugin:

    ## Defines which platform this plugin provides. An empty string means this plugin does not provide a platform.
    method providesPlatformID(): string = ""

    ## For platform plugins, this is called on app startup
    method onPlatformStartup() = discard


### Plugin registry
singleton ReactivePlugins:

    ## List of installed plugins
    var all: seq[ReactivePlugin]

    ## Active platform ID
    var activePlatformID = "unknown"

    ## Register a plugin
    method register(plugin: ReactivePlugin) =

        # Store it
        this.all.add(plugin)


    ## Get active platform plugin
    method activePlatformPlugin(): ReactivePlugin =

        # Find it
        let filtered = this.all.filterIt(it.providesPlatformID() == this.activePlatformID)
        if filtered.len() == 0:
            raiseAssert("No platform plugins installed that can build to the '" & this.activePlatformID & "' platform.")
        elif filtered.len() >= 2:
            raiseAssert("Multiple platform plugins installed for building to the '" & this.activePlatformID & "' platform.")

        # Return it
        return filtered[0]