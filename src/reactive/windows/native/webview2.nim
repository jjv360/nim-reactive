##
## Interaction with the WebView2 API
import std/os
import winim/lean
import ./dynamicimport


# Embed + import WebView2Wrapper.dll
const dllName = "WebView2Wrapper_" & hostCPU & ".dll"
const dllData = staticRead(dllName)
dynamicImportFromData(dllName, dllData):


    ########## Environment

    ## Get the browser version info including channel name if it is not the WebView2 Runtime.
    proc WebView2_GetInstalledVersion*(): cstring {.stdcall.}

    ## Represents the WebView2 Environment.
    type ICoreWebView2Environment* = distinct pointer

    ## Environment create callback
    type WebView2_CreateEnvironment_Callback* = proc(errorCode: HRESULT, env: ICoreWebView2Environment) {.closure.}

    ## Creates an evergreen WebView2 Environment using the installed WebView2 Runtime version.
    proc WebView2_CreateEnvironment*(
        environmentCreatedHandler: proc(errorCode: HRESULT, env: ICoreWebView2Environment) {.closure.}
    ) {.stdcall.}



    ########## Controller

    ## The owner of the CoreWebView2 object that provides support for resizing, showing and hiding, focusing, and other functionality related to windowing and composition.
    type ICoreWebView2Controller* = distinct pointer

    ## Asynchronously create a new WebView.
    proc createController*(
        this: ICoreWebView2Environment, 
        parentWindow: HWND, 
        environmentCreatedHandler: proc(errorCode: HRESULT, env: ICoreWebView2Controller) {.closure.}
    ) {.stdcall, importc:"WebView2_CreateController".}

    ## Set bounds
    proc setBounds*(this: ICoreWebView2Controller, x: int64, y: int64, width: int64, height: int64) {.stdcall, importc:"WebView2_SetBounds".}

    ## Navigate to URL
    proc navigate*(this: ICoreWebView2Controller, url: cstring) {.stdcall, importc:"WebView2_Navigate".}