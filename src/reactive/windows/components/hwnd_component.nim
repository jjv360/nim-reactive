import std/tables
import classes
import winim/lean
import ../../shared/basecomponent
import ../../shared/mounts

## List of all active windows
var activeHWNDs: Table[HWND, RootRef]

## Proxy function for stdcall to class function
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

## Register the Win32 "class"
proc registerWindowClass*(): string =

    # If done already, stop
    const WindowClassName = "NimReactiveWindowClass"
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
## This class represents an HWND Win32 window.
class HWNDComponent of NativeComponent:

    ## Backend window info
    var hwnd: HWND = 0

    ## Current window information
    var x = 0.0
    var y = 0.0
    var width = 0.0
    var height = 0.0


    ## Creates the native HWND window. The default action just creates a hidden message-only system window.
    method createNativeHWND() : HWND = CreateWindowExW(
        0,                                  # Extra window styles
        registerWindowClass(),              # Class name
        "HiddenWindow",                     # Window title
        0,                                  # Window style

        # Size and position, x, y, width, height
        0, 0, 0, 0,

        HWND_MESSAGE,                       # Parent window    
        0,                                  # Menu
        GetModuleHandle(nil),               # Instance handle
        nil                                 # Additional application data, unused since we're keeping references in `activeHWNDs`
    )

    ## Destroys the native HWND. The default action just calls DestroyWindow().
    method destroyNativeHWND() = DestroyWindow(this.hwnd)


    ## Called when this component is mounted
    method onNativeMount() =

        # Create native window
        this.hwnd = this.createNativeHWND()

        # Store it
        activeHWNDs[this.hwnd] = this


    ## Called on unmount
    method onNativeUnmount() = 

        # Destroy the window
        activeHWNDs.del(this.hwnd)
        this.destroyNativeHWND()
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
            let component = activeHWNDs.getOrDefault(componentHwnd, nil).HWNDComponent()
            if component == nil:
                echo "[Reactive] Warning: Received WM_COMMAND for an unknown control. controlHwnd=" & $componentHwnd
                return DefWindowProc(hwnd, uMsg, wParam, lParam)

            # Found it, pass it on
            return component.controlWndProc(componentHwnd, uMsg, wParam, lParam)

        elif uMsg == WM_SIZE:

            # Window has been resized
            this.width = LOWORD(lParam).float
            this.height = HIWORD(lParam).float
            
            # Trigger an update
            this.onNativeUpdate()

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



## Proxy function for stdcall to class function
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =

    # Find class instance
    let component = activeHWNDs.getOrDefault(hwnd, nil).HWNDComponent()
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


## Raise the latest Win32 error as an exception
proc raiseWin32Error*(prefix : string = "") =
    raise newException(OSError, prefix & " - Win32 error: " & GetLastErrorString())