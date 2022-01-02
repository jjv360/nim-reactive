import os, osproc
import strformat
import sequtils
import strutils
import json
import sugar
import tables


# Do an operation in the specified working directory
# From: https://github.com/nim-lang/fusion/blob/1bde44921fe3deaf13094480b132c9cf80b0ce14/src/fusion/scripting.nim#L4
template withDir*(dir: string, body: untyped): untyped =
    let curDir = getCurrentDir()
    try:
        setCurrentDir(dir)
        body
    finally:
        setCurrentDir(curDir)


# Find path to a platform binary
proc pathToPlatformBinary(platformID: string): string =

    # Try search for an external platform plugin
    var exe = execProcess(fmt"nimble path reactive_platform_{platformID}").strip() / fmt"reactive_platform_{platformID}.out"
    if fileExists(exe):
        return exe

    # Try search for built-in platform plugin
    exe = execProcess("nimble path reactive").strip() / fmt"reactive_platform_{platformID}.out"
    if fileExists(exe):
        return exe

    # Try find the exe on the path
    exe = findExe("reactive_platform_" & platformID)
    if exe != "":
        return exe

    # Still not found!
    raiseAssert(fmt"Platform plugin '{platformID}' not found! Have you added the requirement to your nimble file?")


# Find entrypoint source file
proc findEntrypointFile(projectRoot: string): string =

    # Find .nimble file
    let nimbleFiles = collect(for k in walkDir(projectRoot): k.path).filterIt(it.endsWith(".nimble"))
    if nimbleFiles.len() == 0: raiseAssert("Unable to find the .nimble file in the project root: " & projectRoot)
    if nimbleFiles.len() >= 2: raiseAssert("Too many .nimble files in the project root: " & projectRoot)

    # Get library name
    let libName = nimbleFiles[0].splitFile().name

    # Get source file path
    let sourcePath = absolutePath(projectRoot / "src" / fmt"{libName}.nim")
    if not fileExists(sourcePath): raiseAssert("Could not find entry source file at " & sourcePath)
    return sourcePath


# Check a string, if empty use the other
proc `or` (x: string, y: string): string = return if x == "" or x == "nil": y else: x


## Command line documentation
const doc = """
Nim Reactive - a framework for building cross-platform apps in Nim.

Usage:
    nimble reactive
    nimble reactive help
    nimble reactive build

Actions:
    help            Shows this help information.
    build           (Default) Builds your app

Options:
    --version       Show version.
    --platform:<p>  Specify a platform target. Defaults to "web".
""".strip()

# Process command line args
var foundSeparator = false
var action = ""
var cmdlineParams: Table[string, string]
for param in commandLineParams():

    # We have been passed unsanitized params that were passed to `nimble reactive xxx`, so filter out the ones that come before our task
    if not foundSeparator:
        if param == "reactive": foundSeparator = true
        continue

    # Check param type
    if param.startsWith("--"):

        # We found a flag, separate it into key:val
        var sepIdx = param.find(":")
        if sepIdx == -1: sepIdx = param.find("=")
        if sepIdx == -1:

            # This is a flag, default to "true"
            let key = param[2 .. param.high].toLowerAscii()
            let value = "true"
            cmdlineParams[key] = value

        else:

            # This is an argument, store it
            let key = param[2 .. sepIdx-1].toLowerAscii()
            let value = param[sepIdx+1 .. param.high]
            cmdlineParams[key] = value

    else:

        # Build command, only one is supported
        if action != "": raiseAssert("Only one command can be specified.")
        action = param.toLowerAscii()


# Set defaults
if not cmdlineParams.contains("platform"): cmdlineParams["platform"] = "web"

# Get app info from nimble task
if not cmdlineParams.contains("reactive-params"): raiseAssert("Couldn't find --reactive-params flag. Are you sure you are running the binary through the `nimble reactive` task?")
let appInfo = cmdlineParams["reactive-params"].parseJson()
cmdlineParams.del("reactive-params")


# Get project root, which is the current working directory. The nimble script which runs us ensures we are
# in the correct directory, so we don't have to make sure here.
let projectRoot = absolutePath(getCurrentDir())

## Check what to do
if cmdlineParams.contains("help"):

    # Show help text
    echo doc

elif action == "build":

    # Create configuration for the platform binary
    let buildInfo = %* {
        "action": "build",
        "projectRoot": projectRoot,
        "entrypoint": findEntrypointFile(projectRoot),
        "cmdline": cmdlineParams,
        "appInfo": appInfo,
        "extraBuildFlags": [
            "--define:ReactiveProjectRoot:" & projectRoot,
            "--define:ReactiveAppInfoAppID:" & appInfo["appID"].getStr(""),
            "--define:ReactiveAppInfoTitle:" & appInfo["title"].getStr("")
        ],
    }

    # Minify the JSON
    var buildInfoStr = ""
    toUgly(buildInfoStr, buildInfo)

    # Get command to execute
    let cmd = @[pathToPlatformBinary(cmdlineParams["platform"]), "--buildinfo:" & buildInfoStr].quoteShellCommand

    # Run the platform binary, and quit with the same exit code
    echo "Running command: " & cmd
    quit(execShellCmd(cmd))
