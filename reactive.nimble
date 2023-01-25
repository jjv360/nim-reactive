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
requires "classes >= 0.2.13"
requires "winim >= 3.9.0"

# Test script
task test, "Test script":
    exec "nimble install -y"
    exec "nimcrate --run --target:windows examples/notepad.nim"

# Build the CoreFoundation library interop file (only works on Mac with Xcode installed)
# task buildInteropCoreFoundation, "Build interop for CoreFoundation":
#
#     # Ensure c2nim is installed
#     exec "nimble install c2nim -y"
#
#     # Get list of header files
#     let frameworkPath = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/CoreFoundation.framework"
#     if not dirExists(frameworkPath): raiseAssert("Unable to build, CoreFoundation.framework was not found.")
#     let allFiles = listFiles(frameworkPath & "/Headers").commandLine(" ")
#
#     # Create wrapper
#     echo "Building wrapper..."
#     exec "c2nim --concat --out:./src/reactive/native/corefoundation_wrapper.nim " & allFiles