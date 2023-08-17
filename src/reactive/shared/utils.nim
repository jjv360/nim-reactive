##
## Generic utilities
import std/mimetypes
import std/base64
import std/os
import std/strutils

## Generate a static data URI for a file and embed it as a string
proc staticDataURI*(filename: static[string]): string =

    # Get path of function caller
    let callerFileName = instantiationInfo(fullPaths = true).filename
    let callerDir = parentDir(callerFileName)
    var absoluteFilename = absolutePath(filename, callerDir)

    # HACK: Workaround for cross-compiling Windows on *nix, seems Nim uses \ instead of / in the static context
    when defined(windows):
        if absoluteFilename.startsWith("\\") and not absoluteFilename.startsWith("\\\\"):
            absoluteFilename = absoluteFilename.replace("\\", "/")

    # Get file data
    let data = staticRead(absoluteFilename)

    # Base64 encode the data
    let base64data = encode(data)

    # Get mime type for file based on the file name
    let extension = splitFile(filename).ext
    let mime = newMimetypes().getMimetype(extension)

    # Done, generate URL
    return "data:" & mime & ";base64," & base64data


## Display an error dialog
template displayCurrentException*(title : string = "Error") =

    # Get error string
    var str = getCurrentExceptionMsg()

    # Log it
    echo "[Reactive] " & title & " - " & str

    # Strip out the async traceback
    let idx = str.find("Async traceback:\n")
    if idx != -1:
        str = str[0 ..< idx]

    # Show alert dialog
    alert(str, title, dlgError)