##
## Interaction with the WebView2 API
import std/os
import winim/lean

# Get CPU architecture for current build
# TODO: Check that 'hostCPU' is the target CPU when cross-compiling
const cpu = when hostCPU == "i386": "x86"
    elif hostCPU == "amd64": "x64"
    elif hostCPU == "arm64": "arm64"
    else: raiseAssert("WebView2 not supported on this CPU architecture.")

# Read the DLL for this build
const nupkgBase = currentSourcePath().parentDir() & "/microsoft.web.webview2.1.0.1518.46"
const dllPath = nupkgBase & "/runtimes/win-" & cpu & "/native/WebView2Loader.dll"
const dllData = staticRead(dllPath)


# Statically link to the correct WebView2Loader.dll
# This is a small loader DLL around 150KB so it's safe to statically link it without causing bloat
# See: https://github.com/MicrosoftEdge/WebView2Feedback/issues/2462
const nupkgBase = currentSourcePath().parentDir() & "/microsoft.web.webview2.1.0.1518.46"
const runtimePathPrefix = nupkgBase & "/build/native/"
const runtimePathPostfix = "/WebView2LoaderStatic.lib"
{.passL:"bufferoverflow.lib".}
when hostCPU == "i386":
    {.passL:runtimePathPrefix & "x86" & runtimePathPostfix.}
elif hostCPU == "amd64":
    {.passL:runtimePathPrefix & "x64" & runtimePathPostfix.}
elif hostCPU == "arm64":
    {.passL:runtimePathPrefix & "arm64" & runtimePathPostfix.}
else:
    raiseAssert("WebView2 not supported on this CPU architecture.")

## Get the browser version info including channel name if it is not the WebView2 Runtime.
## NOTE: Must free the string with CoTaskMemFree() after.
proc GetAvailableCoreWebView2BrowserVersionString*(browserExecutableFolder: PCWSTR = nil, versionInfo: ptr LPWSTR): HRESULT {.cdecl, importc, discardable.}

## Callback
type ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler* =
    proc (result: HRESULT, env: pointer): HRESULT

## DLL export to create a WebView2 environment with a custom version of WebView2 Runtime, user data folder, and with or without additional options.
proc CreateCoreWebView2EnvironmentWithOptions*(
    browserExecutableFolder: PCWSTR = nil,
    userDataFolder: PCWSTR = nil,
    environmentOptions: pointer = nil,
    environmentCreatedHandler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
) {.cdecl, importc.}