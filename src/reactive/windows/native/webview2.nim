##
## Interaction with the WebView2 API
## References:
##   - https://www.codeproject.com/Articles/13601/COM-in-plain-C


import std/os
import std/oids
import std/asyncdispatch
import winim
import winim/com
import ./nimDispatch
import ./dynamicimport
import ../dialogs
















## Generic callback C++ class
type CallbackVTbl {.pure, inheritable.} = object
    AddRef: proc(self: pointer): ULONG {.stdcall.}
    Release: proc(self: pointer): ULONG {.stdcall.}
    Invoke: proc(self: pointer, result: HRESULT, obj: pointer): HRESULT {.stdcall.}
type Callback {.pure.} = ref object
    lpVtbl: ptr CallbackVTbl
    vtbl: CallbackVTbl
    nimCallback: proc(result: HRESULT, obj: pointer) {.closure.}

## Create callback
proc makeCppCallback(nimCallback: proc(result: HRESULT, obj: pointer) {.closure.}): Callback =

    # Create the C++ class and it's VTable
    var cb = Callback()
    cb.nimCallback = nimCallback
    cb.lpVtbl = &cb.vtbl
    cb.vtbl.AddRef = proc(self: pointer): ULONG {.stdcall.} = 1
    cb.vtbl.Release = proc(self: pointer): ULONG {.stdcall.} = 1
    cb.vtbl.Invoke = proc(self: pointer, result2: HRESULT, obj: pointer): HRESULT {.stdcall.} =
        
        # Call the Nim function
        var cb2 = cast[ptr Callback](self)[]
        cb2.nimCallback(result2, obj)

        # Done, unmark it for GC
        GC_unref(cb2)
        return S_OK

    # Mark it so it doesn't get GC'd
    GC_ref(cb)

    # Done
    return cb.addr









# Dependencies
# From: https://github.com/MicrosoftEdge/WebView2Samples/blob/5caa009c6860d27fef1a5826c942aea5853c4f54/GettingStartedGuides/Win32_GettingStarted/WebView2GettingStarted.vcxproj#L145
#{.passL:"-lkernel32 -luser32 -lgdi32 -lwinspool -lcomdlg32 -ladvapi32 -lshell32 -lole32 -loleaut32 -luuid -lodbc32 -lodbccp32".}

# Embed + import WebView2Loader.dll
const dllName1 = "WebView2Loader_" & hostCPU & ".dll"
const dllData1 = staticRead(dllName1)
dynamicImportFromData(dllName1, dllData1):
    proc GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder: PCWSTR, versionInfo: var LPWSTR): HRESULT {.stdcall.}
    proc CreateCoreWebView2Environment(handler: Callback): HRESULT {.stdcall.}









## ICoreWebView2Environment

type ICoreWebView2EnvironmentVTbl {.pure, inheritable.} = object of IUnknownVtbl
    # AddRef: proc(self: pointer): ULONG {.stdcall.}
    # Release: proc(self: pointer): ULONG {.stdcall.}
    # Invoke: proc(self: pointer, result: HRESULT, obj: ptr IDispatch): HRESULT {.stdcall.}
    CreateCoreWebView2Controller: proc(self: pointer, parentWindow: HWND, handler: Callback): HRESULT
type ICoreWebView2Environment {.pure.} = ref object
    lpVtbl: ptr ICoreWebView2EnvironmentVTbl
    vtbl: ICoreWebView2EnvironmentVTbl








## WebView2 class
type WebView2* = ref object of RootRef
    environment: com
    controller: com

## Get the currently installed version of the WebView2 (evergreen) runtime. Returns a blank string if not installed.
proc version*(_: typedesc[WebView2]): string =

    # Call it
    var wStr: LPWSTR
    discard GetAvailableCoreWebView2BrowserVersionString(nil, wStr)

    # Convert to Nim string and release it
    let str = $wStr
    CoTaskMemFree(wStr)
    return str

## Initialize and attach to a window
proc createWebView*(parentWindow: HWND): Future[WebView2] {.async.} =

    # Create instance
    var this = WebView2()
    # this.callbackDispatch.lpVtbl = this.callbackVtbl.addr
    # this.callbacks = newCom(this.callbackDispatch)

    # Initialize COM
    var res = CoInitializeEx(nil, COINIT_APARTMENTTHREADED)
    if res != S_OK and res != S_FALSE:
        raise newException(OSError, "Unable to initialize COM.")
    
    # Get environment
    echo "Init environment"
    var environmentFuture = Future[ICoreWebView2Environment]()
    discard CreateCoreWebView2Environment(makeCppCallback(proc(result: HRESULT, env: pointer) {.closure.} =
        environmentFuture.complete(cast[ICoreWebView2Environment](env))
    ))
    let environment = await environmentFuture
    if environment == nil:
        raise newException(OSError, "Unable to create WebView2 environment.")

    # Init controller
    # echo "Init controller"
    # this.environment = wrap(environment)
    # this.environment.CreateCoreWebView2Controller(makeCppCallback(proc(result: HRESULT, env: ptr IDispatch) {.closure.} =
    #     echo "HEREE"
    # ))

    # Done
    return this