import std/tables
import stdx/asyncdispatch
import classes
import winim/mean
import ../../shared/basecomponent
import ../../shared/properties
import ./hwnd_component


## Last used unique menu ID
var LastMenuID = 1


##
## A child menu item
class MenuItem of Component:

    ## Unique menu item ID
    var hMenuID = 0

    ## Build the HMENU resource
    method buildHMENU(parent : HMENU, index : int) =

        # Create unique menu item ID if necessary
        if this.hMenuID == 0:
            this.hMenuID = LastMenuID
            LastMenuID += 1

        # Create menu item info
        var menuItemInfo : MENUITEMINFOW
        menuItemInfo.cbSize = sizeof(menuItemInfo).UINT
        menuItemInfo.fMask = MIIM_ID or MIIM_FTYPE or MIIM_STATE or MIIM_STRING
        menuItemInfo.fType = MFT_STRING
        menuItemInfo.wID = this.hMenuID.UINT
        menuItemInfo.dwTypeData = this.props{"title"}.string
        menuItemInfo.cch = this.props{"title"}.string.len.UINT

        # If it's a separator, set the flag
        if this.props{"separator"}:
            menuItemInfo.fType = menuItemInfo.fType or MFT_SEPARATOR

        # If it's disabled, set the flag
        if this.props{"disabled"}:
            menuItemInfo.fState = menuItemInfo.fState or MFS_DISABLED

        # If it's checked, show checkmark
        if this.props{"checked"}:
            menuItemInfo.fState = menuItemInfo.fState or MFS_CHECKED

        # Check if there's a submenu
        let submenuItems = this.findChildren(MenuItem)
        for index, submenuItem in submenuItems:

            # If this is the first one, create the menu
            if menuItemInfo.hSubMenu == 0:
                menuItemInfo.hSubMenu = CreatePopupMenu()
                menuItemInfo.fMask = menuItemInfo.fMask or MIIM_SUBMENU

            # Add it to the submenu
            submenuItem.buildHMENU(menuItemInfo.hSubMenu, index)

        # Create menu item
        let success = InsertMenuItemW(parent, index.UINT, TRUE, menuItemInfo)
        if success == FALSE:
            raiseWin32Error("Unable to create menu item.")


##
## Represents a system popup menu
class Menu of Component:

    ## Build the HMENU resource
    method buildHMENU() : HMENU =

        # Create menu
        let hMenu = CreatePopupMenu()
        if hMenu == FALSE:
            raiseWin32Error("Unable to create popup menu.")

        # Get menu items
        let children = this.findChildren(MenuItem)
        for idx, menuItem in children:
            menuItem.buildHMENU(hMenu, idx)

        # If no items, create en empty item
        if children.len == 0:

            # Create blank menu item
            let text = "(no items)"
            var menuItemInfo : MENUITEMINFOW
            menuItemInfo.cbSize = sizeof(menuItemInfo).UINT
            menuItemInfo.fMask = MIIM_FTYPE or MIIM_STATE or MIIM_STRING
            menuItemInfo.fType = MFT_STRING
            menuItemInfo.dwTypeData = text
            menuItemInfo.cch = text.len.UINT
            menuItemInfo.fState = MFS_DISABLED
            let success = InsertMenuItemW(hMenu, 0, TRUE, menuItemInfo)
            if success == FALSE:
                raiseWin32Error("Unable to create menu item.")

        # Done
        return hMenu

    ## Show context menu from the current cursor position
    method displayContextMenu() {.async.} =

        # Build menu
        let hMenu = this.buildHMENU()

        # Get cursor position
        var cursorPos : POINT
        let winResult1 = GetCursorPos(cursorPos)
        if winResult1 == FALSE:
            raiseWin32Error("Unable to get cursor position.")

        # Show menu in new thread
        var winResult2 : WINBOOL = 0
        awaitThread(winResult2, hMenu, cursorPos):

            # Create temporary window
            let hwnd = CreateWindowExW(
                0,                                  # Extra window styles
                registerWindowClass(),              # Class name
                "HiddenWindow",                     # Window title
                0,                                  # Window style

                # Size and position, x, y, width, height
                0, 0, 0, 0,

                HWND_MESSAGE,                       # Parent window    
                0,                                  # Menu
                GetModuleHandle(nil),               # Instance handle
                nil                                 # Extra data
            )

            # Workaround: The menu doesn't close unless the user clicks a menu item. This issue is addressed in the elusive MSDN article Q135788.
            # Basically, the HWND needs to be made foreground before calling TrackPopupMenu(). Very weird, considering the window isn't even a
            # real window...
            SetForegroundWindow(hwnd)

            # Run the menu
            winResult2 = TrackPopupMenuEx(hMenu, TPM_NONOTIFY or TPM_RETURNCMD or TPM_RIGHTBUTTON, cursorPos.x, cursorPos.y, hwnd, nil)

            # Destroy the temporary window
            DestroyWindow(hwnd)

        # Check if cancelled
        if winResult2 == FALSE:
            return

        # Get selected item
        let selectedItem = this.findChild(proc(it : MenuItem) : bool = it.hMenuID == winResult2)
        if selectedItem == nil:
            echo "Unable to find selected menu item."
            return

        # Execute it
        selectedItem.sendEventToProps("onPress")
        return