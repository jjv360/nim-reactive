import reactivepkg/utils
import std/os
import std/osproc
import std/strutils
import std/json

# Fetch build args
let buildInfo = getReactiveBuildOptions()

# Begin building
let returnCode = startProcess("nim", options={poUsePath, poParentStreams}, args=[
    "compile",
    "--os:windows",
    "--app:gui",
    "--define:release",
    "--define:ReactivePlatformWin32",
    "--define:ReactiveInjectImports:reactive_platform_win32",
    # "--define:debugclasses",
    "--out:" & absolutePath(buildInfo["projectRoot"].getStr() / "dist" / "win32" / "app-x64.exe"),
    buildInfo["entrypoint"].getStr()
]).waitForExit()