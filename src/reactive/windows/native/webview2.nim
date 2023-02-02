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
type CallbackVTbl {.pure, inheritable.} = object of IUnknownVtbl
    Invoke: proc(self: ptr IUnknown, result: HRESULT, obj: ptr IUnknown): HRESULT {.stdcall.}
type Callback {.pure.} = ref object
    lpVtbl: ptr CallbackVTbl
    vtbl: CallbackVTbl
    nimCallback: proc(result: HRESULT, obj: ptr IUNknown) {.closure.}

## Create callback
proc makeCppCallback(nimCallback: proc(result: HRESULT, obj: ptr IUnknown) {.closure.}): Callback =

    # Create the C++ class and it's VTable
    var cb = Callback()
    cb.nimCallback = nimCallback
    cb.lpVtbl = &cb.vtbl
    cb.vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
        echo "H0"
        return E_NOINTERFACE
    cb.vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} = 
        echo "H1"
        return 1
    cb.vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} = 
        echo "H2"
        var cb2 = cast[Callback](self)
        GC_unref(cb2)
        return 1
    cb.vtbl.Invoke = proc(self: ptr IUnknown, result2: HRESULT, obj: ptr IUnknown): HRESULT {.stdcall.} =
        echo "H3"
        
        # Call the Nim function
        var cb2 = cast[Callback](self)
        cb2.nimCallback(result2, obj)

        # Done, unmark it for GC
        # GC_unref(cb2)
        return S_OK

    # Mark it so it doesn't get GC'd
    GC_ref(cb)

    # Done
    return cb









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
    environment: ptr ICoreWebView2Environment

## Get the currently installed version of the WebView2 (evergreen) runtime. Returns a blank string if not installed.
proc version*(_: typedesc[WebView2]): string =

    # Call it
    var wStr: LPWSTR
    discard GetAvailableCoreWebView2BrowserVersionString(nil, wStr)

    # Convert to Nim string and release it
    let str = $wStr
    CoTaskMemFree(wStr)
    return str

## Convert an HRESULT into an error string
proc errorString*(_: typedesc[WebView2], code: HRESULT): string =

    # Check known error codes
    if code == HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND): return "Couldn't find Edge WebView2 Runtime. Do you have a version installed?"
    if code == HRESULT_FROM_WIN32(ERROR_FILE_EXISTS): return "User data folder cannot be created because a file with the same name already exists."
    if code == E_ACCESSDENIED: return "Unable to create user data folder, Access Denied."
    if code == E_FAIL: return "Edge runtime unable to start"

    # Create string buffer and retrieve the error text
    var str = newWString(1024)
    let strLen = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS, nil, code, DWORD MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), str, 1024, nil)
    if strLen == 0:

        # Unable to decode error code, just convert to hex so at least there's something
        return "Win32 error 0x" & code.toHex()

    else:

        # Got it
        return $str


## Initialize and attach to a window
proc create*(_: typedesc[WebView2], parentWindow: HWND): Future[WebView2] {.async.} =

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
    var environmentFuture = Future[ptr ICoreWebView2Environment]()
    let result = CreateCoreWebView2Environment(makeCppCallback(proc(result: HRESULT, env: ptr IUnknown) {.closure.} =
        echo "HERE"
        environmentFuture.complete(cast[ptr ICoreWebView2Environment](env))
    ))
    if result != S_OK: raise newException(OSError, "Unable to create WebView2 environment. " & WebView2.errorString(result))
    let environment = await environmentFuture
    if environment == nil:
        raise newException(OSError, "No WebView2 environment was created.")

    # Init controller
    echo "Init controller"
    this.environment = environment
    let result2 = this.environment.vtbl.CreateCoreWebView2Controller(this.environment, parentWindow, makeCppCallback(proc(result: HRESULT, env: ptr IUnknown) {.closure.} =
        echo "HEREE"
    ))
    if result2 != S_OK: raise newException(OSError, "Unable to create WebView2 controller. " & WebView2.errorString(result2))

    # Done
    return this