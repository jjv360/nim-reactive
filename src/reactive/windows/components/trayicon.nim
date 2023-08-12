import std/asyncdispatch
import classes
import winim/mean
import pixie
import ../../shared/basecomponent
import ../../shared/assets
import ./hwnd_component

## Tray message ID
const WM_MyTrayMessage = WM_USER + 1

## Tray icon
class TrayIcon of HWNDComponent:

    ## Check if tray is mounted
    var trayIsMounted = false

    ## The HICON for the tray icon
    var hIcon : HICON

    ## Fetch icon and create an HICON
    method updateIcon() {.async.} =

        # Get icon URL
        var icon = this.props{"icon"}.string
        if icon.len == 0: 
            return

        # Fetch it
        let asset = await ReactiveAssets.shared.loadURL(icon)
        
        # Load image
        var image = decodeImage(asset.data)

        # Resize to the system's desired icon size
        let width = GetSystemMetrics(SM_CXSMICON)
        let height = GetSystemMetrics(SM_CYSMICON)
        if width == 0 or height == 0: raiseWin32Error("Unable to get system tray icon size.")
        if width != image.width or height != image.height:
            image = image.resize(width, height)

        # Create icon information
        var iconInfo : ICONINFO
        iconInfo.fIcon = true           # <-- This is an icon, not a cursor
        
        # Convert pixels to Win32's weird format
        var imgDataARGB = newSeq[uint8](image.width * image.height * 4)
        for i in 0 ..< image.width * image.height:
            let pixel = image.data[i]
            imgDataARGB[i * 4 + 0] = pixel.b
            imgDataARGB[i * 4 + 1] = pixel.g
            imgDataARGB[i * 4 + 2] = pixel.r
            imgDataARGB[i * 4 + 3] = pixel.a

        # Create color bitmap
        iconInfo.hbmColor = CreateBitmap(image.width.int32, image.height.int32, 1, 32, imgDataARGB[0].addr)
        if iconInfo.hbmColor == 0:
            raiseWin32Error("Unable to create bitmap for tray icon.")

        # Create blank bitmask bitmap
        iconInfo.hbmMask = CreateCompatibleBitmap(GetDC(0), image.width.int32, image.height.int32)
        if iconInfo.hbmMask == 0:
            raiseWin32Error("Unable to create mask bitmap for tray icon.")

        # Create the icon
        let hIcon = CreateIconIndirect(iconInfo)
        if hIcon == 0:
            raiseWin32Error("Unable to create icon for system tray icon.")

        # Clean up
        DeleteObject(iconInfo.hbmColor)
        DeleteObject(iconInfo.hbmMask)

        # Done, save icon and refresh
        this.hIcon = hIcon
        if this.trayIsMounted:
            this.updateNativeTray()


    
    ## Called when this component is mounted
    method onNativeMount() =
        super.onNativeMount()

        # Fetch icon
        asyncCheck this.updateIcon()

        # Create it
        this.updateNativeTray()


    ## Called when unmounted
    method onNativeUnmount() =
        super.onNativeUnmount()

        # Unmount it
        var data : NOTIFYICONDATAW
        data.cbSize = sizeof(data).DWORD
        data.hWnd = this.hwnd
        data.uID = 1
        let success = Shell_NotifyIconW(NIM_MODIFY, data)
        if success == 0:
            raiseWin32Error("Unable to create system tray icon.")

        # Unmounted
        this.trayIsMounted = false


    ## Update the tray icon
    method updateNativeTray() =

        # Setup notification data
        var data : NOTIFYICONDATAW
        data.cbSize = sizeof(data).DWORD
        data.uVersion = NOTIFYICON_VERSION_4
        data.hWnd = this.hwnd
        data.uID = 1                                    # <-- No unique ID needed since we make a new window for each tray icon
        data.uFlags = NIF_STATE or NIF_TIP or NIF_SHOWTIP or NIF_MESSAGE
        data.dwState = 0
        data.uCallbackMessage = WM_MyTrayMessage

        # Add icon if we have one
        if this.hIcon != 0:
            data.uFlags = data.uFlags or NIF_ICON
            data.hIcon = this.hIcon

        # Convert tooltip to TCHAR with a 64-byte limit, and copy it into the struct
        var tooltip = this.props{"tooltip"}.string
        if tooltip.len > 63: tooltip = tooltip[0 ..< 63]
        let wTooltip = +$tooltip
        for i in 0 ..< wTooltip.len: 
            data.szTip[i] = wTooltip[i]

        # Check operation
        if this.trayIsMounted:

            # Just update it
            let success = Shell_NotifyIconW(NIM_MODIFY, data)
            if success == 0:
                raiseWin32Error("Unable to create system tray icon.")

        else:

            # Add it
            let success = Shell_NotifyIconW(NIM_ADD, data)
            if success == 0:
                raiseWin32Error("Unable to create system tray icon.")

            # Update version
            Shell_NotifyIconW(NIM_SETVERSION, data)

            # It's mounted now
            this.trayIsMounted = true


    ## WndProc callback
    method wndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Check if message is for another component
        if uMsg != WM_MyTrayMessage:
            return super.wndProc(hwnd, uMsg, wParam, lParam)

        # Check message
        let uMsg2 = LOWORD(lParam)
        if uMsg2 == WM_LBUTTONUP:

            # User activated the tray icon
            echo "Clicked!"
            this.sendEventToProps("onPress")
            this.sendEventToProps("onActivate")
            return 0

        elif uMsg2 == WM_CONTEXTMENU:

            # User activated the tray icon
            echo "Context menu!"
            this.sendEventToProps("onContextMenu")
            this.sendEventToProps("onActivate")
            return 0

        else:

            # Pass on to base
            return super.wndProc(hwnd, uMsg, wParam, lParam)

        