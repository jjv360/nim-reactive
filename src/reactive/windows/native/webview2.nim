##
## Interaction with the WebView2 API
import std/os
import std/strutils
import std/tempfiles
import std/exitprocs
import std/dynlib
import winim/com
import classes
import ./dynamicimport

# Get CPU architecture for current build
# TODO: Check that 'hostCPU' is the target CPU when cross-compiling
const cpu = when hostCPU == "i386": "x86"
    elif hostCPU == "amd64": "x64"
    elif hostCPU == "arm64": "arm64"
    else: raiseAssert("WebView2 not supported on this CPU architecture.")

# Read the DLL for this build
const nupkgBase = currentSourcePath().parentDir() & "/microsoft.web.webview2.1.0.1518.46"
const dllPath = nupkgBase & "/runtimes/win-" & cpu & "/native/WebView2Loader.dll"

# Workaround: When cross-compiling Windows on *nix, it seems Nim uses \ instead of / in the static context
when defined(windows) and dllPath.startsWith("\\") and not dllPath.startsWith("\\\\"):
    const dllPathFixed = dllPath.replace("\\", "/")
else:
    const dllPathFixed = dllPath

# Read DLL data
const dllData = staticRead(dllPathFixed)

# Imports
dynamicImportFromData("WebView2Loader.dll", dllData):

    ## Get the version of the WebView2 runtime
    proc GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder: PCWSTR, versionInfo: ptr LPWSTR): HRESULT {.gcsafe, stdcall.}



## Get version info
# type Type_GetAvailableCoreWebView2BrowserVersionString = proc (browserExecutableFolder: PCWSTR, versionInfo: ptr LPWSTR): HRESULT {.gcsafe, stdcall.}
# var GetAvailableCoreWebView2BrowserVersionString: Type_GetAvailableCoreWebView2BrowserVersionString = nil

# Callback
# type ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler* = proc (result: HRESULT, env: pointer): HRESULT

## DLL export to create a WebView2 environment with a custom version of WebView2 Runtime, user data folder, and with or without additional options.
# proc CreateCoreWebView2EnvironmentWithOptions*(
#     browserExecutableFolder: PCWSTR = nil,
#     userDataFolder: PCWSTR = nil,
#     environmentOptions: pointer = nil,
#     environmentCreatedHandler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
# ) = discard

## Must be called before any of the WebView2 functions can be used
# proc loadDLL() =

#     # Check if loaded already
#     var handle {.global.} : LibHandle = nil
#     if handle != nil:
#         return

    # # Get CPU architecture for current build
    # # TODO: Check that 'hostCPU' is the target CPU when cross-compiling
    # const cpu = when hostCPU == "i386": "x86"
    #     elif hostCPU == "amd64": "x64"
    #     elif hostCPU == "arm64": "arm64"
    #     else: raiseAssert("WebView2 not supported on this CPU architecture.")

    # # Read the DLL for this build
    # const nupkgBase = currentSourcePath().parentDir() & "/microsoft.web.webview2.1.0.1518.46"
    # const dllPath = nupkgBase & "/runtimes/win-" & cpu & "/native/WebView2Loader.dll"

    # # HACK: Workaround for cross-compiling Windows on *nix, seems Nim uses \ instead of / in the static context
    # when defined(windows) and dllPath.startsWith("\\") and not dllPath.startsWith("\\\\"):
    #     const dllPathFixed = dllPath.replace("\\", "/")
    # else:
    #     const dllPathFixed = dllPath

    # # Read DLL data
    # const dllData = staticRead(dllPathFixed)
    
    # # Save the DLL to a temporary file
    # echo "[NimReactive] Loading WebView2 (" & cpu & ")"
    # let dllTempPath = genTempPath("NimReactive", "_" & cpu & "_WebView2Loader.dll")
    # writeFile(dllTempPath, dllData)

    # # Delete the DLL on exit
    # addExitProc(proc() =
    #     removeFile(dllTempPath)
    # )

#     # Load it
#     handle = loadLib(dllTempPath)
#     if handle == nil:
#         raise newException(OSError, "Unable to load WebView2")

#     # Load functions
#     GetAvailableCoreWebView2BrowserVersionString = cast[Type_GetAvailableCoreWebView2BrowserVersionString](handle.symAddr("GetAvailableCoreWebView2BrowserVersionString"))





##
## WebView2 class
class WebView2:

    ## Get the browser version info including channel name if it is not the WebView2 Runtime.
    method versionInfo*(): string {.static.} =

        # Call it
        var nativeVersionInfo: LPWSTR
        discard GetAvailableCoreWebView2BrowserVersionString(nil, nativeVersionInfo.addr)

        # Convert to a Nim string
        let nimVersionInfo = $nativeVersionInfo

        # Release string
        CoTaskMemFree(nativeVersionInfo)
        return nimVersionInfo


    ## Check if installed
    method isInstalled(): bool {.static.} = WebView2.versionInfo() != ""


    ## Start automatic install
    method downloadAndInstall() {.static.} =

        # Start the download from the official URL
        raiseAssert("Not implemented yet")


## Callback
# type ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler* =
#     proc (result: HRESULT, env: pointer): HRESULT

# ## DLL export to create a WebView2 environment with a custom version of WebView2 Runtime, user data folder, and with or without additional options.
# proc CreateCoreWebView2EnvironmentWithOptions*(
#     browserExecutableFolder: PCWSTR = nil,
#     userDataFolder: PCWSTR = nil,
#     environmentOptions: pointer = nil,
#     environmentCreatedHandler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
# ) = discard