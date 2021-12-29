import os, osproc
import strformat
import sequtils
import strutils
import docopt
import json
import sugar


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


# Find entrypoint source file
proc findEntrypointFile(projectRoot: string): string =

    # Find .nimble file
    let nimbleFiles = collect(for k in walkDir(projectRoot): k.path).filterIt(it.endsWith(".nimble"))
    if nimbleFiles.len() == 0: raiseAssert("Unable to find the .nimble file in the project root: " & projectRoot)
    if nimbleFiles.len() >= 2: raiseAssert("Too many .nimble files in the project root: " & projectRoot)

    # Get library name
    let libName = nimbleFiles[0].substr(0, nimbleFiles[0].len() - 7)

    # Get source file path
    let sourcePath = absolutePath(projectRoot / "src" / fmt"{libName}.nim")
    if not fileExists(sourcePath): raiseAssert("Could not find entry source file at " & sourcePath)
    return sourcePath


# Check a string, if empty use the other
proc `or` (x: string, y: string): string = return if x.len() == 0: y else: x


## Command line documentation
const doc = """
Nim Reactive - a framework for building cross-platform apps in Nim.

Usage:
    nimble reactive <action> [--platform=<id>]
    reactive (-h | --help)
    reactive --version

Actions:
    build           (Default) Builds your app

Options:
    -h --help       Show this screen.
    --version       Show version.
    --platform=<id> Specify a platform target. Defaults to "web".
""".strip()

# Extract injected vars
var projectRoot = ""
for param in commandLineParams():
    if param.startsWith("--reactive-project-root:"):
        projectRoot = param.substr(24)


# We have been passed unsanitized params that were passed to `nimble reactive xxx`, so filter out the ones that come before our task
var params: seq[string]
var foundSeparator = false
for param in commandLineParams():
    if foundSeparator: params.add(param)
    if param == "reactive": foundSeparator = true


# Parse command line
# const version = slurp()
let args = docopt(doc, version = "Reactive vX.X (TODO)")


# Check if in dev mode ... this just installs the submodules locally so we don't have to commit to git every time
# if fileExists(projectRoot / ".." / ".." / "reactive.nimble"):
    
#     # Install inline dependencies
#     echo "Detected Reactive is in dev mode! Installing local dependencies..."
#     withDir(projectRoot / ".." / ".." / "platforms" / "web"): assert 0 == execShellCmd("nimble install -y")
#     withDir(projectRoot / ".." / ".."): assert 0 == execShellCmd("nimble install -y")


# Check action
if args["xxxxxx"]:

    ## Other actions

else:

    # Build action ... create configuration for the platform binary
    let buildInfo = %* {
        "action": "build",
        "projectRoot": projectRoot,
        "entrypoint": findEntrypointFile(projectRoot)
    }

    # Minify the JSON
    var buildInfoStr = ""
    toUgly(buildInfoStr, buildInfo)

    # Get command to execute
    let platform = $args["--platform"] or "web"
    let cmd = @[pathToPlatformBinary(platform), "--buildinfo:" & buildInfoStr].quoteShellCommand

    # Run the platform binary, and quit with the same exit code
    echo "Running command: " & cmd
    quit(execShellCmd(cmd))