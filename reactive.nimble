# Package

version                     = "0.1.7"
author                      = "jjv360"
description                 = "Cross-platform app development framework"
license                     = "MIT"
srcDir                      = "src"
installExt                  = @["nim", "nims"]
namedBin["reactivepkg/cli"] = "reactive_task"


# Dependencies

requires "nim >= 1.6.2"
requires "classes >= 0.2.12"
requires "regex >= 0.19.0"



# Dev task, forwards commands to an app in the examples folder
import os, sequtils
task reactiveExample, "Build an example app, installing all dependencies locally":

    # TODO: Use `nimble develop` for this?? This is not working well
    # Install plugins
    withDir thisDir() / "platforms" / "web": exec "nimble install -y"
    withDir thisDir() / "platforms" / "win32": exec "nimble install -y"
    withDir thisDir() / "platforms" / "gnome": exec "nimble install -y"

    # Install main
    withDir thisDir(): exec "nimble install -y"

    # Find command line args
    var params: seq[string]
    var foundSeparator = false
    for param in commandLineParams():
        if foundSeparator: params.add(param)
        if param == "reactiveExample": foundSeparator = true

    # Get example name
    var exampleName = params[0]
    params = params[1 .. params.len()-1]

    # Pass on command to the example app
    withDir thisDir() / "examples" / exampleName:
        exec @["nimble", "reactive"].concat(params).quoteShellCommand