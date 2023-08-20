##
## This file is imported from the user's .nimble file to describe the extra package options.
## Everything in here must be runnable at compile time.

import std/os
import std/with
export with, commandLineParams

## Reactive package info
type ReactivePackageInfo* = object

    ## App bundle ID
    bundleID* : string

    ## Display name
    displayName* : string


## Shared package info var
var reactivePackageInfo* : ReactivePackageInfo

## Wrapper for setting the package info
template reactive*(code : untyped) =

    # Set it
    with reactivePackageInfo:
        code

    # Output the package info
    if commandLineParams().find("ReactiveDumpPackageInfo") != -1:
        echo "=== Reactive Package Info ==="
        for name, value in reactivePackageInfo.fieldPairs: echo name, ": ", value
        echo "version: ", version
        echo "=== Reactive Package Info End ==="