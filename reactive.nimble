# Package
version         = "0.1.0"
author          = "Josh Fox"
description     = "Create reactive UI apps"
license         = "MIT"
srcDir          = "src"
installExt      = @["nim", "png"]


# Dependencies
requires "nim >= 1.6.10"
requires "https://github.com/jjv360/nim-crate >= 0.1.0"
requires "classes >= 0.2.14"
requires "winim >= 3.9.0"
# requires "webview >= 0.1.0"
requires "mummy >= 0.2.7"

# Test script
task test, "Test script":
    exec "nimble install -y"
    exec "nimcrate --run examples/notepad.nim"
