import classes
import winim/mean
import ../../shared/basecomponent
import ./hwnd_component

## Tray icon
class TrayIcon of HWNDComponent:

    # Check if tray is mounted
    var trayIsMounted = false
    
    ## Called when this component is mounted
    method onNativeMount() =
        super.onNativeMount()

        # Create it
        this.updateNativeTray()


    ## Called when unmounted
    method onNativeUnmount() =

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
        data.hWnd = this.hwnd
        data.uID = 1                                    # <-- No unique ID needed since we make a new window for each tray icon
        data.uFlags = NIF_STATE or NIF_TIP or NIF_SHOWTIP
        data.dwState = 0

        # Convert tooltip to TCHAR with a 64-byte limit, and copy it into the struct
        var tooltip = this.props{"tooltip"}.string
        if tooltip.len > 64: tooltip = tooltip[0 ..< 63]
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
            data.uVersion = NOTIFYICON_VERSION_4
            Shell_NotifyIconW(NIM_SETVERSION, data)

            # It's mounted now
            this.trayIsMounted = true