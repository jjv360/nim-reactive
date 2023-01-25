import std/tables
import classes
import winim/lean
import ../shared/basecomponent


## Base class for any component which uses a Win32 Window and needs to receive window events
class WindowHwndHandler of BaseComponent:

    ## The HWND of this item
    var hwnd : HWND = 0

    ## Create a placeholder window
    method createHwnd(): HWND = 

        # Create hidden event-only window
        this.hwnd = CreateWindowEx(
            0,                              # Extra window styles
            registerWindowClass(),          # Class name
            "Hidden",                       # Window title
            WS_OVERLAPPEDWINDOW,            # Window style

            # Size and position, x, y, width, height
            CW_USEDEFAULT, CW_USEDEFAULT, 
            CW_USEDEFAULT, CW_USEDEFAULT,

            HWND_MESSAGE,                   # Parent window handle (special value to attach to the hidden message-only window)
            0,                              # Menu handle
            0,                              # Instance handle
            cast[pointer](this)             # Additional application data is a pointer to our class instance ... used by wndProcProxy
        )


    ## Destroy the associated HWND
    method destroyHwnd() = 
        if this.hwnd != 0: DestroyWindow(this.hwnd)
        this.hwnd = 0


    # ## Get parent HWND
    # method parentHWND(): HWND =

    #     # Go through heirarchy
    #     var item = this.parent
    #     while item != nil:

    #         # Check if this one has a HWND
    #         if item of WindowHwndHandler and WindowHwndHandler(item).hwnd != 0:
    #             return WindowHwndHandler(item).hwnd

    #         # Nope, continue up the chain
    #         item = item.parent
            
    #     # Not found
    #     return 0


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

            # Remove this window from the active window list, it has been destroyed by the system
            activeHWNDs.del(this.hwnd)
            return 0

        elif uMsg == WM_COMMAND:

            # Special command used for common controls ... the message is actually for a component control, not for this window component. Find the control's component
            let componentHwnd = lParam.HWND()
            let component = activeHWNDs.getOrDefault(componentHwnd, nil).WindowHwndHandler()
            if component == nil:
                echo "[YaGUI] Warning: Received WM_COMMAND for an unknown control. controlHwnd=" & $componentHwnd
                return DefWindowProc(hwnd, uMsg, wParam, lParam)

            # Found it, pass it on
            return component.controlWndProc(componentHwnd, uMsg, wParam, lParam)

        else:

            # Unknown message, let the system handle it in the default way
            return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## WndProc callback for controls
    method controlWndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Unknown message, let the system handle it in the default way
        return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## String description of this component
    method `$`(): string =
        return super.`$`() & " hwnd=" & $this.hwnd


## Proxy function for stdcall to class function
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =

    # Find class instance
    let component = activeHWNDs.getOrDefault(hwnd, nil).WindowHwndHandler()
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