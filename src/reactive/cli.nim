import os, osproc
import strformat
import sequtils
import strutils

# Find path to a platform binary
proc pathToPlatformBinary(platformID: string): string =

    # Try find the exe on the path
    var exe = findExe("reactive_platform_" & platformID)
    if exe != "":
        return exe

    # Not found, try search for built-in platform plugin
    exe = execProcess("nimble path reactive").strip() / fmt"reactive_platform_{platformID}"
    if fileExists(exe):
        return exe

    # Not found, try search for an external platform plugin
    exe = execProcess(fmt"nimble path reactive_platform_{platformID}").strip() / fmt"reactive_platform_{platformID}"
    if fileExists(exe):
        return exe

    # Still not found!
    raiseAssert(fmt"Platform plugin '{platformID}' not found! Have you added the requirement to your nimble file?")

# First param is always the platform ID
var args = commandLineParams()
var platform = args[0]
args = args[1..args.len-1]

# Get command to execute
let cmd = concat(@[pathToPlatformBinary(platform)], args).quoteShellCommand

# Run the platform binary, and quit with the same exit code
echo "Running command: " & cmd
quit(execShellCmd(cmd))