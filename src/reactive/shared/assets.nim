import std/os
import std/strutils
import std/strformat
import std/asyncdispatch
import std/uri
import std/mimetypes
import stdx/sequtils
import stdx/sugar
import classes
import ./utils



##
## Represents an single asset resource
class ReactiveAsset:

    ## Unique asset ID for embedded assets
    var embeddedID = 0

    ## The name of the asset
    var name : string

    ## Full path of the asset
    var fullPath : string

    ## The type of the asset
    var mimetype : string

    ## The asset data in memory
    var data : string




##
## The asset cache is a singleton that holds all the assets that are loaded.
singleton ReactiveAssets:

    ## List of loaded assets
    var assets : seq[ReactiveAsset]

    ## Load data for asset
    method loadURL(url : string) : Future[ReactiveAsset] {.async.} =
        
        # Check type
        let uri = parseUri(url)
        if uri.scheme == "asset":

            # An embedded asset
            let id = parseInt(uri.hostname)
            let asset = this.assets.findIt(it.embeddedID == id)
            if asset == nil:
                raise newException(Exception, "Asset not found: " & url)

            # Return it
            return asset

        else:

            # Unknown data format
            raise newException(IOError, fmt"Unknown data URI scheme: {uri.scheme}")



## Bundle an asset and return it's unique asset URL
proc reactiveAsset*(filepath : static[string]) : string =

    # Get absolute path to the asset based on the caller information
    const callerFileName = instantiationInfo(0, fullPaths = true).filename
    const callerDir = parentDir(callerFileName)
    const absolutePath = absolutePath(filepath, callerDir)

    # HACK: Workaround for cross-compiling Windows on *nix, seems Nim uses \ instead of / in the static context
    when defined(windows):
        const shouldReplace = absolutePath.startsWith("\\") and not absolutePath.startsWith("\\\\")
        const absolutePath2 = 
            if shouldReplace: absolutePath.replace("\\", "/") 
            else: absolutePath
    else:
        const absolutePath2 = absolutePath

    # Get file data
    const fileData = staticRead(absolutePath2)
    const extension = splitFile(absolutePath2)[2]
    const mime = newMimetypes().getMimetype(extension)

    # Add to assets if needed
    var asset = ReactiveAssets.shared.assets.findIt(it.fullPath == absolutePath2)
    if asset == nil:

        # Generate unique embedded ID
        var lastID {.global.} = 0
        lastID += 1

        # Create new asset
        asset = ReactiveAsset.init()
        asset.embeddedID = lastID
        asset.name = extractFilename(absolutePath2)
        asset.fullPath = absolutePath2
        asset.data = fileData
        asset.mimetype = mime
        ReactiveAssets.shared.assets.add(asset)

    # Get asset url
    return "asset://" & $asset.embeddedID
    
