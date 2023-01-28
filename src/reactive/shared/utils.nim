##
## Generic utilities
import std/mimetypes
import std/base64
import std/os

## Generate a static data URI for a file and embed it as a string
proc staticDataURI*(filename: static[string]): string =

    # Get path of function caller
    let callerFileName = instantiationInfo(fullPaths = true).filename
    let callerDir = parentDir(callerFileName)
    let absoluteFilename = absolutePath(filename, callerDir)

    # Get file data
    let data = staticRead(absoluteFilename)

    # Base64 encode the data
    let base64data = encode(data)

    # Get mime type for file based on the file name
    let extension = splitFile(filename).ext
    let mime = newMimetypes().getMimetype(extension)

    # Done, generate URL
    return "data:" & mime & ";base64," & base64data