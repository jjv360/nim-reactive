import std/tables
import std/browsers
import std/asyncdispatch
import classes
import winim/lean
import ../../shared/basecomponent
import ../../shared/mounts
import ../../shared/webview_bridge
import ../../shared/htmloutput
import ../../shared/htmlcomponents
import ../../shared/properties
import ../dialogs
import ../native/webview2

## List of all active windows
var activeHWNDs: Table[HWND, RootRef]

## Proxy function for stdcall to class function
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

## Register the Win32 "class"
proc registerWindowClass2*(): string =

    # If done already, stop
    const WindowClassName = "NimReactiveWindowClassOld"
    var hasDone {.global.} = false
    if hasDone:
        return WindowClassName

    # Do it
    var wc: WNDCLASSEX
    wc.cbSize = sizeof(WNDCLASSEX).UINT
    wc.lpfnWndProc = wndProcProxy
    wc.hInstance = GetModuleHandle(nil)
    wc.lpszClassName = WindowClassName
    wc.style = CS_HREDRAW or CS_VREDRAW
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    RegisterClassEx(wc)

    # Done
    hasDone = true
    return WindowClassName


##
## This class represents an onscreen window.
class Window of WebViewBridge:

    ## Backend window info
    var hwnd: HWND = 0

    ## WebView2 instance
    # var webview: WebView2
    var wv2controller: ICoreWebView2Controller

    var tstStr = "HelloWorld"

    ## Current window size
    var width = 0.0
    var height = 0.0

    ## Called when this component is mounted
    method onNativeMount() =

        # Load asynchronously
        asyncCheck this.onNativeMountAsync()

    method onNativeMountAsync() {.async.} =

        # Check if WebView2 is available
        if $WebView2_GetInstalledVersion() == "":

            # Prompt the user to ask to install it
            # TODO: Automatically download and install it, showing the user the progress...
            await alert(
                text = "This app requires the WebView2 component.", 
                title = "Missing component", 
                icon = dlgQuestion
            )

            # Open the download URL with the official download URL from Microsoft
            openDefaultBrowser("https://go.microsoft.com/fwlink/p/?LinkId=2124703")

            # Quit the app
            echo "[NimReactive] Exiting since WebView2 is missing."
            quit(3)

        # Create the native window
        this.hwnd = CreateWindow(
            #0,#WS_EX_LAYERED,                   # Extra window styles
            registerWindowClass2(),              # Class name
            this.props{"title"}.cstring,        # Window title
            WS_OVERLAPPEDWINDOW,                # Window style

            # Size and position, x, y, width, height
            this.props{"x"}, this.props{"y"}, 
            this.props{"width"}, this.props{"height"},

            0,                                  # Parent window    
            0,                                  # Menu
            GetModuleHandle(nil),               # Instance handle
            nil                                 # Additional application data, unused since we're keeping references in `activeHWNDs`
        )

        # Store it
        activeHWNDs[this.hwnd] = this

        # Show window
        this.width = this.props{"width"}
        this.height = this.props{"height"}
        ShowWindow(this.hwnd, SW_SHOWDEFAULT)
        UpdateWindow(this.hwnd)

        # Prepare WebView2 environment
        var controller: ICoreWebView2Controller
        let result = WebView2_CreateAndAttach(this.hwnd, controller)
        if result != S_OK:
            raise newException(OSError, "Unable to create WebView2 controller. " & $WebView2_GetErrorString(result))
        if controller.pointer == nil:
            raise newException(OSError, "Unable to create WebView2 controller.")

        # Set initial size
        this.wv2controller = controller
        this.wv2controller.setBounds(0, 0, this.width.int64, this.height.int64)

        # Register script callback
        # TODO: This crashes
        this.wv2controller.addMessageReceivedHandler(cast[pointer](this), proc(context: pointer, text: cstring) {.stdcall.} =
            echo 1
            let this = cast[Window](context)
            echo 2
            this.onJsCallback($text)
        )
        # this.wv2controller.navigate("about:blank")
        # WebView2_CreateEnvironment(cast[pointer](this), proc(result: HRESULT, env: ICoreWebView2Environment, context: pointer) {.cdecl.} =

        #     # Check if failed
        #     let this = cast[Window](context)
        #     if result != S_OK:
        #         raise newException(OSError, "Unable to create WebView2 environment. " & $WebView2_GetErrorString(result))

        #     # Loaded successfully, do the rest
        #     this.wv2env = env

        #     # Create the WebView component
        #     echo "Creating the controller..."
        #     this.wv2env.createController(this.hwnd, cast[pointer](this), proc(result: HRESULT, controller: ICoreWebView2Controller, context: pointer) {.cdecl.} =

        #         # Check if failed
        #         echo "HERE2222"
        #         alert "here2"
        #         let this = cast[Window](context)
        #         alert "here3"
        #         if result != S_OK:
        #             raise newException(OSError, "Unable to create WebView2 controller. " & $WebView2_GetErrorString(result))

        #         # Done
        #         alert "Created controller"
        #         this.wv2controller = controller
        #         this.wv2controller.setBounds(0, 0, this.props{"width"}, this.props{"height"})
        #         this.wv2controller.navigate("https://google.com")
        #         echo "DONE"

        #     )

        # )

        # Create graphics memory for the window
        # let screenDC = GetDC(0)
        # let windowDC = CreateCompatibleDC(screenDC)

        # # Create blend function info
        # var blend : BLENDFUNCTION
        # blend.BlendOp = AC_SRC_OVER
        # blend.SourceConstantAlpha = 255
        # blend.AlphaFormat = AC_SRC_ALPHA


        # var ptPos = POINT(x: this.x.int32, y: this.y.int32)
        # var sizeWnd = SIZE(cx: this.width.int32, cy: this.height.int32)

        # # Position of content in the DC
        # var ptSrc = POINT(x: 0, y: 0)

        # # # Update layered window
        # let success = UpdateLayeredWindow(hwnd, screenDC, &ptPos, &sizeWnd, windowDC, &ptSrc, 0, blend, ULW_ALPHA)
        # let success = SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA)
        # if success == 0:
        #     echo "[YaGUI] Warning: Unable to call SetLayeredWindowAttributes. " & GetLastErrorString()

        # Show window
        # ShowWindow(this.hwnd, SW_SHOWNORMAL)

        # Draw background color
        # this.p_updateLayeredWindow(hwnd)


    ## Called on unmount
    method onNativeUnmount() = 
        if this.hwnd != 0:
            activeHWNDs.del(this.hwnd)
            DestroyWindow(this.hwnd)
        this.hwnd = 0


    ## WndProc callback
    method wndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Check message type
        if uMsg == WM_PAINT:
            
            # Paint the background color onto the window
            var ps: PAINTSTRUCT
            var hdc = BeginPaint(hwnd, ps)
            FillRect(hdc, ps.rcPaint, COLOR_WINDOW+1)
            EndPaint(hwnd, ps)

            # Done
            return 0

        elif uMsg == WM_DESTROY:

            # Windows has destroyed our window, unmount this component
            ReactiveMountManager.shared.unmount(this)

        elif uMsg == WM_COMMAND:

            # Special command used for common controls ... the message is actually for a component control, not for this window component. Find the control's component
            let componentHwnd = lParam.HWND()
            let component = activeHWNDs.getOrDefault(componentHwnd, nil).Window()
            if component == nil:
                echo "[YaGUI] Warning: Received WM_COMMAND for an unknown control. controlHwnd=" & $componentHwnd
                return DefWindowProc(hwnd, uMsg, wParam, lParam)

            # Found it, pass it on
            return component.controlWndProc(componentHwnd, uMsg, wParam, lParam)

        elif uMsg == WM_SIZE:

            # Window has been resized
            this.width = LOWORD(lParam).float
            this.height = HIWORD(lParam).float
            
            # If webview exists, resize it
            if this.wv2controller.pointer != nil:
                this.wv2controller.setBounds(0, 0, this.width.int64, this.height.int64)

            # Done
            return 0

        else:

            # Unknown message, let the system handle it in the default way
            return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## WndProc callback for controls
    method controlWndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Unknown message, let the system handle it in the default way
        return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## String description of this component
    method `$`(): string =
        return super.`$`() & " $hwnd=" & $this.hwnd


    ## Called to inject JS into the page
    method injectJS(js: string) =

        # Do it
        this.wv2controller.executeScript(js)



## Proxy function for stdcall to class function
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =

    # Find class instance
    let component = activeHWNDs.getOrDefault(hwnd, nil).Window()
    if component == nil:

        # No component associated with this HWND, we don't know where to route this message... Maybe it's a thread message or something? 
        # Let's just perform the default action.
        return DefWindowProc(hwnd, uMsg, wParam, lParam)

    # Pass on
    component.wndProc(hwnd, uMsg, wParam, lParam)



## Utility to get the last Win32 error as a string
proc GetLastErrorString*(): string =

    # Get error code
    let err = GetLastError()
    if err == 0:
        return ""

    # Create string buffer and retrieve the error text
    var str = newWString(1024)
    let strLen = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS, nil, err, DWORD MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), str, 1024, nil)
    if strLen == 0:

        # Unable to decode error code, just convert to hex so at least there's something
        return "Win32 error 0x" & err.toHex()

    # Done
    return $str