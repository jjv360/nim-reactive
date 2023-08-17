##
## Interaction with the WebView2 API
## References:
##   - https://www.codeproject.com/Articles/13601/COM-in-plain-C

# I feel dirty after writing this code ... my god, it's bad
# TODO: Better way of using C++ classes???


import std/os
import stdx/dynlib
import winim/lean


# Embed + import WebView2Wrapper.dll
const dllName = "WebView2Wrapper_" & hostCPU & ".dll"
const dllData = staticRead(dllName)
dynamicImportFromData(dllName, dllData):
   
    ## Convert a COM error code to a string
    proc WebView2_GetErrorString*(code: HRESULT): cstring {.stdcall.}

    ## Get the browser version info including channel name if it is not the WebView2 Runtime.
    proc WebView2_GetInstalledVersion*(): cstring {.stdcall.}

    ## The owner of the CoreWebView2 object that provides support for resizing, showing and hiding, focusing, and other functionality related to windowing and composition.
    type ICoreWebView2Controller* = distinct pointer

    ## Creates a WebView and attaches it to the window
    proc WebView2_CreateAndAttach*(parentWindow: HWND, webview: var ICoreWebView2Controller): HRESULT {.stdcall.}

    ## Set bounds
    proc setBounds*(this: ICoreWebView2Controller, x: int64, y: int64, width: int64, height: int64) {.stdcall, importc:"WebView2_SetBounds".}

    ## Navigate to URL
    proc navigate*(this: ICoreWebView2Controller, url: cstring) {.stdcall, importc:"WebView2_Navigate".}

    ## Execute Javascript
    proc executeScript*(this: ICoreWebView2Controller, script: cstring) {.stdcall, importc:"WebView2_ExecuteScript".}

    ## Register a callback for when scripts call `window.chrome.webview.postMessage()`
    proc addMessageReceivedHandler*(
        this: ICoreWebView2Controller,
        context: pointer,
        callback: proc(context: pointer, text: cstring) {.stdcall.}
    ) {.stdcall, importc:"WebView2_AddMessageReceivedHandler".}