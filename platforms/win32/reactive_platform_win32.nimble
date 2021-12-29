# Package

version                                 = "0.1.5"
author                                  = "jjv360"
description                             = "Plugin for Reactive which provides deployment to Windows using the Win32 API."
license                                 = "MIT"
srcDir                                  = "src"
installExt                              = @["nim"]
namedBin["reactive_platform_win32/cli"]   = "reactive_platform_win32"


# Dependencies

requires "nim >= 1.6.2"
requires "https://github.com/jjv360/nim-reactive >= 0.1.5"