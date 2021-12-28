import strformat

# Package

version       = "0.1.0"
author        = "jjv360"
description   = "Cross-platform app development framework"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
namedBin      = @{
    "reactive": "reactive",
    "reactivepkg/plugins/web": "reactive.web"
}.toTable


# Dependencies

requires "nim >= 1.6.2"
requires "classes >= 0.2.12"
requires "docopt >= 0.6.7"
requires "regex >= 0.19.0"


# Build tasks

task example, "Build the example app":

    # Build and install this lib, replacing existing version
    exec "nimble install -y"

    # Find start of OUR params, which is the ones that follow the task name
    var paramsStartIndex = -1
    for i in countup(0, paramCount()):
        if paramStr(i) == "example":
            paramsStartIndex = i
            break

    # Sanity check: Make sure we found the start of our params
    if paramsStartIndex == -1:
        raise ValueError.newException("Couldn't find our params on the command line!")

    # Get requested platform
    var platformName = if paramCount() >= paramsStartIndex+1: paramStr(paramsStartIndex + 1) else: "web"

    # Run it to build the example app
    exec "~/.nimble/bin/reactive.{platformName} build \"example/app.nim\"".fmt