##
## Interaction with the WebView2 API
import std/os
import winim/lean
import ./dynamicimport
import ../dialogs


# Embed + import WebView2Wrapper.dll
const dllName = "WebView2Wrapper_" & hostCPU & ".dll"
const dllData = staticRead(dllName)
dynamicImportFromData(dllName, dllData):
    #alert "Loading: " & dllName



    ########## Generic

    ## Convert a COM error code to a string
    proc WebView2_GetErrorString*(code: HRESULT): cstring {.stdcall.}

    proc WebView2_CreateWindowEx*(dwExStyle: DWORD, lpClassName: LPCWSTR, lpWindowName: LPCWSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.stdcall.}



    ########## Environment

    ## Get the browser version info including channel name if it is not the WebView2 Runtime.
    proc WebView2_GetInstalledVersion*(): cstring {.stdcall.}

    ## Represents the WebView2 Environment.
    type ICoreWebView2Environment* = distinct pointer

    ## Creates an evergreen WebView2 Environment using the installed WebView2 Runtime version.
    proc WebView2_CreateEnvironment*(
        context: pointer,
        callback: proc(errorCode: HRESULT, env: ICoreWebView2Environment, context: pointer) {.stdcall.}
    ) {.stdcall.}

    # ## Creates an evergreen WebView2 Environment using the installed WebView2 Runtime version.
    # proc WebView2_CreateEnvironment*(
    #     callback: proc(errorCode: HRESULT, env: ICoreWebView2Environment) {.closure.}
    # ) =

    #     # Create closure

    #     # Proc is leaving Nim's memory management, so ensure Nim doesn't discard it
    #     # TODO: How do we unref this?
    #     var storedProcs {.global.} : seq[proc(errorCode: HRESULT, env: ICoreWebView2Environment) {.closure.}]
    #     storedProcs.add(callback)

    #     # Call internal
    #     WebView2_CreateEnvironmentImpl(callback)





    ########## Controller

    ## The owner of the CoreWebView2 object that provides support for resizing, showing and hiding, focusing, and other functionality related to windowing and composition.
    type ICoreWebView2Controller* = distinct pointer

    ## Asynchronously create a new WebView.
    proc createController*(
        this: ICoreWebView2Environment, 
        parentHWND: HWND, 
        context: pointer,
        environmentCreatedHandler: proc(errorCode: HRESULT, env: ICoreWebView2Controller, context: pointer) {.stdcall.}
    ) {.stdcall, importc:"WebView2_CreateController".}

    # ## Asynchronously create a new WebView.
    # proc createController*(
    #     this: ICoreWebView2Environment,
    #     parentHWND: HWND,
    #     callback: proc(errorCode: HRESULT, env: ICoreWebView2Controller) {.closure.}
    # ) =

    #     # Proc is leaving Nim's memory management, so ensure Nim doesn't discard it
    #     # TODO: How do we unref this?
    #     var storedProcs {.global.} : seq[proc(errorCode: HRESULT, env: ICoreWebView2Controller) {.closure.}]
    #     storedProcs.add(callback)

    #     # Call internal
    #     createControllerImpl(this, parentHWND, callback)

    ## Set bounds
    proc setBounds*(this: ICoreWebView2Controller, x: int64, y: int64, width: int64, height: int64) {.stdcall, importc:"WebView2_SetBounds".}

    ## Navigate to URL
    proc navigate*(this: ICoreWebView2Controller, url: cstring) {.stdcall, importc:"WebView2_Navigate".}