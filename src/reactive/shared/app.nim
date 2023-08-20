import std/compilesettings
import std/tables
import std/os
import std/strutils

##
## Provides general information about the current app.
type ReactiveApp* = object of RootRef


## Get the path to the project's Nimble file
proc nimbleFilePath() : string =

    # Get path
    var path = querySetting(SingleValueSetting.projectFull).parentDir
    while true:

        # Fetch all files in this folder
        var nimbleFile = ""
        for file in walkDir(path):
            if file.path.toLower().endsWith(".nimble"):
                return file.path

        # Stop if found
        if nimbleFile != "":
            return nimbleFile

        # Go up one
        let upPath = path.parentDir()
        if upPath.len < 4 or upPath == path: return ""
        path = upPath
    
    

## Get the key/value pairs returned from the project's Nimble file
proc getProjectInfo() : Table[string, string] =

    # Get table
    var tbl : Table[string, string]

    # Read Nimble file
    const nimFile = nimbleFilePath()
    if nimFile == "":
        return tbl

    # Dump output
    const nimbleDump = staticExec(@["nim", "e", nimFile, "ReactiveDumpPackageInfo"].quoteShellCommand)

    # Get starting offset
    const startIdx = nimbleDump.find("=== Reactive Package Info ===")
    if startIdx == -1:
        return tbl

    # Get ending offset
    const endIdx = nimbleDump.find("=== Reactive Package Info End ===")
    if endIdx == -1 or endIdx < startIdx:
        return tbl

    # Parse items
    for line in nimbleDump[startIdx ..< endIdx].splitLines:

        # Get key/value
        let splitIdx = line.find(":")
        if splitIdx == -1:
            continue

        # Get key/value
        let key = line[0 ..< splitIdx].strip()
        let val = line[splitIdx + 1 ..< ^0].strip()

        # Add to table
        tbl[key] = val

    # Done
    return tbl


## Project information
const projectInfoTable = getProjectInfo()


## Get the current app's name.
proc projectName*(_: typedesc[ReactiveApp]): string =

    # Get Nim project name
    const ProjectName = querySetting(SingleValueSetting.projectName)
    return ProjectName

## Get the current app's display name.
proc name*(_: typedesc[ReactiveApp]): string =

    # Get display name
    const ProjectName = querySetting(SingleValueSetting.projectName)
    const DisplayName = projectInfoTable.getOrDefault("displayName", ProjectName)
    return DisplayName

## Get the current app's version.
proc version*(_: typedesc[ReactiveApp]): string =

    # Get project version
    const NimblePkgVersion {.strdefine.} = ""
    const ProjectVersion = projectInfoTable.getOrDefault("version", NimblePkgVersion)
    return ProjectVersion

## Get the current app's bundle ID.
proc bundleID*(_: typedesc[ReactiveApp]): string =

    # Get project version
    const BundleID = projectInfoTable.getOrDefault("bundleID", "reactive." & ReactiveApp.projectName)
    return BundleID

## Get the current app's data directory
proc dataDir*(_: typedesc[ReactiveApp]): string = getDataDir() / ReactiveApp.bundleID

## Get the current app's cache directory
proc cacheDir*(_: typedesc[ReactiveApp]): string = getCacheDir(ReactiveApp.bundleID)

## Get the current app's temporary directory
proc tempDir*(_: typedesc[ReactiveApp]): string = getTempDir() / ReactiveApp.bundleID