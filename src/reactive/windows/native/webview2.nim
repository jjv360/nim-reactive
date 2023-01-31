##
## Interaction with the WebView2 API
import std/os
import winim/com
import ./dynamicimport


# Embed + import WebView2Wrapper.dll
const dllName = "WebView2Wrapper_" & hostCPU & ".dll"
const dllData = staticRead(dllName)
dynamicImportFromData(dllName, dllData):

    ## Get the browser version info including channel name if it is not the WebView2 Runtime.
    proc WebView2_GetInstalledVersion*(): cstring {.stdcall.}

    ## WebView2 environment COM object
    type ICoreWebView2Environment* = ptr IDispatch

    ## Environment create callback
    type WebView2_CreateEnvironment_Callback* = proc(errorCode: HRESULT, env: ICoreWebView2Environment) {.closure.}

    ## Creates an evergreen WebView2 Environment using the installed WebView2 Runtime version.
    proc WebView2_CreateEnvironment*(environmentCreatedHandler: WebView2_CreateEnvironment_Callback) {.stdcall.}


## Compile and import the C++ wrapper
# {.passL:"-lstdc++".}
# {.compile:"WebView2_wrapper.cpp".}
# proc WebView2CreateCallbackConverter(handler: proc(result: int64, env: pointer) {.closure.}) {.nimcall, importc.}
# proc PrepareWebView2(dllName: cstring): bool {.nimcall, importc.}
# proc GetWebView2Version(): LPWSTR {.nimcall, importc.}
# proc CreateWebView2Environment(callback: proc (resultCode: int64, env: pointer) {.closure.}) {.nimcall, importc.}


##
## WebView2 class
# class WebView2:

#     ## Is attached
#     var parentHwnd: HWND

#     ## Prepare and connect to the library
#     method prepare() {.static.} =

#         # Create object
#         # echo "here1"
#         # let obj = CreateObject("InternetExplorer.Application")
#         # obj.visible = true

#         # echo "here2 " & obj.repr
#         # quit(0)

#         # # Only do once
#         # var isPrepared {.global.} = false
#         # if isPrepared:
#         #     return

#         # # Save DLL to temporary storage
#         # # TODO: Check that 'hostCPU' is the target CPU when cross-compiling
#         # const dllName = "WebView2Loader_" & hostCPU & ".dll"
#         # const dllData = staticRead(dllName)

#         # # Save the DLL to a temporary file
#         # let dllTempPath = genTempPath("NimReactive", "_" & dllName)
#         # writeFile(dllTempPath, dllData)

#         # # Delete the DLL on exit
#         # # TODO: Why would an exit proc not be GC-safe? The app is exiting, all memory will get removed anyway...
#         # addExitProc(proc() =
#         #     removeFile(dllTempPath)
#         # )

#         # Do it
#         # isPrepared = PrepareWebView2(dllTempPath.cstring)
#         # if not isPrepared:
#         #     raise newException(OSError, "Unable to load WebView2Loader.dll")
#         discard


#     ## Get the browser version info including channel name if it is not the WebView2 Runtime.
#     method versionInfo(): string {.static.} =

#         # Get version as Nim string
#         return WebView2_


#     ## Check if installed
#     method isInstalled(): bool {.static.} = WebView2.versionInfo() != ""


#     ## Start automatic install
#     method downloadAndInstall() {.static.} =

#         # Start the download from the official URL
#         raiseAssert("Not implemented yet")


#     ## Prepare environment
#     method getEnvironment(): Future[pointer] {.static, async.} =

#         # Stop if already created
#         var envPointer {.global.} : pointer = nil
#         if envPointer != nil:
#             return envPointer

#         # Prepare WRL callback
#         WebView2CreateCallbackConverter(proc(result: int64, env: pointer) =
#             echo "HERE"
#         )
#         # let handler = proc(self: com.com, name: string, env: pointer): HRESULT =
#         #     echo "HEY"
#         # let sink = newSink(nil, GUID(nil), nil, cast[comEventHandler](handler))

#         # Create environment
#         echo "Env"
#         # CreateCoreWebView2Environment(sink)

#         # Prepare
#         WebView2.prepare()

#         # Create environment
#         # CreateWebView2Environment(proc(resultCode: int64, env: pointer) =
#         #     envPointer = env
#         #     echo "GET"
#         # )

#         # Call it
#         # PrepareWebView2(proc() =
#         #     echo "BACK to nim"
#         # )
#         # discard CreateCoreWebView2EnvironmentWithOptions(environmentCreatedHandler = proc(self: com, name: string): HRESULT =
#         #     echo "HERE"
#         #     return S_OK
#         # )
#         # if result != S_OK:
#         raise newException(OSError, "Unable to create WebView2 environment. ")# & result.toHex)


#     ## Attach WebView to a window
#     method attachTo(window: HWND) {.async.} =

#         # Prepare
#         WebView2.prepare()

#         # Only do once
#         if this.parentHwnd != 0: raise newException(ValueError, "This WebView2 instance has already been attached to a window.")
#         this.parentHwnd = window

#         # Prepare environment
#         let env = await WebView2.getEnvironment()

    




# ## Callback
# # type ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler* =
# #     proc (result: HRESULT, env: pointer): HRESULT

# # ## DLL export to create a WebView2 environment with a custom version of WebView2 Runtime, user data folder, and with or without additional options.
# # proc CreateCoreWebView2EnvironmentWithOptions*(
# #     browserExecutableFolder: PCWSTR = nil,
# #     userDataFolder: PCWSTR = nil,
# #     environmentOptions: pointer = nil,
# #     environmentCreatedHandler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
# # ) = discard