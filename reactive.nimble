import strformat

# Package

version       = "0.1.1"
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
import os
task reactive, "Build the app":
    var params = @[gorge("nimble path reactive").strip() & "/reactive"]; var foundSeparator = false
    for param in commandLineParams():
        if foundSeparator: params.add(param)
        if param == "reactive": foundSeparator = true
    exec "nimble install -y"; exec params.quoteShellCommand