##
## Interaction with system dialogs
import winim/lean
import stdx/asyncdispatch
# import std/times

## Alert icon types
type ReactiveDialogIcon* = enum dlgInfo, dlgWarning, dlgError, dlgQuestion

# Show an alert
proc alert*(text: string, title: string = "", icon: ReactiveDialogIcon = dlgInfo) {.async.} =

    # Get correct icon
    var iconFlag: UINT = MB_ICONINFORMATION
    if icon == ReactiveDialogIcon.dlgWarning: iconFlag = MB_ICONWARNING
    if icon == ReactiveDialogIcon.dlgError: iconFlag = MB_ICONERROR
    if icon == ReactiveDialogIcon.dlgQuestion: iconFlag = MB_ICONQUESTION

    # Show message box
    awaitThread(text, title, iconFlag):
        MessageBox(0, text, title, MB_OK or iconFlag)


# Show a confirmation prompt
proc confirm*(text: string, title: string = "", icon: ReactiveDialogIcon = dlgInfo) : Future[bool] {.async.} =

    # Get correct icon
    var iconFlag: UINT = MB_ICONINFORMATION
    if icon == ReactiveDialogIcon.dlgWarning: iconFlag = MB_ICONWARNING
    if icon == ReactiveDialogIcon.dlgError: iconFlag = MB_ICONERROR
    if icon == ReactiveDialogIcon.dlgQuestion: iconFlag = MB_ICONQUESTION

    # Show message box
    var res : int32 
    awaitThread(text, title, iconFlag, res): res = MessageBox(0, text, title, MB_OKCANCEL or iconFlag)
    if res == IDOK: 
        return true
    else: 
        return false

