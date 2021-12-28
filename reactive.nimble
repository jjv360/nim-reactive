import strformat

# Package

version       = "0.1.2"
author        = "jjv360"
description   = "Cross-platform app development framework"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
namedBin      = @{

    # Main binary
    "reactive": "reactive",

    # Built-in platform plugins
    "reactivepkg/plugins/web": "reactive_platform_web"
    
}.toTable


# Dependencies

requires "nim >= 1.6.2"
requires "classes >= 0.2.12"
requires "docopt >= 0.6.7"
requires "regex >= 0.19.0"
