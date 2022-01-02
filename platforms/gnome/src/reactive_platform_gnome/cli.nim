import reactivepkg/utils
import std/os
import std/osproc
import std/strutils
import std/sequtils
import std/json

# Run a nim command
proc run(app: string, prependArgs: seq[string] = @[], args: varargs[string]) =

    # Log it
    echo "Running command: " & app & " " & prependArgs.quoteShellCommand() & " " & args.quoteShellCommand()

    # Run it
    let process = startProcess(app, options={poUsePath, poParentStreams}, args=prependArgs.concat(args.toSeq()))
    let returnCode = process.waitForExit()
    if returnCode != 0:
        raiseAssert("Nim command failed.")


# Fetch build args
let buildInfo = getReactiveBuildOptions()

# Begin building
run "nim", buildInfo["extraBuildFlags"].getElems().mapIt(it.getStr("")), "compile",

    # Build options
    "--cpu:amd64",                                                                              # Building for amd64 CPUs
    "--os:linux",                                                                               # Building for linux
    "--threads:on",                                                                             # We want threading support
    "--define:release",                                                                         # Optimize for release
    "--define:ReactivePlatformGnome",                                                           # Notify Reactive that we are the active platform in this build
    "--define:ReactiveInjectImports:reactive_platform_gnome",                                   # Inject our library when the user does 'import reactive'

    # Extra linux SDKs we will be accessing
    "--passC:" & execProcess("pkg-config --cflags --libs gtk+-3.0").strip(),                    # GTK3 sdk ... must be installed with `apt install libgtk-3-dev`
    "--passL:" & execProcess("pkg-config --cflags --libs gtk+-3.0").strip(),

    # Input and output location
    "--out:" & absolutePath(buildInfo["projectRoot"].getStr() / "dist" / "gnome" / "app-x64"),  # Output binary
    buildInfo["entrypoint"].getStr()                                                            # Main nim entrypoint