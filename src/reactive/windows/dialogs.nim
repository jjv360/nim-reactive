##
## Interaction with system dialogs
import winim/lean

## Alert icon types
type ReactiveDialogIcon* = enum dlgInfo, dlgWarning, dlgError, dlgQuestion

# Show an alert
proc alert*(text: string, title: string = "", icon: ReactiveDialogIcon = dlgInfo) =

    # Get correct icon
    var iconFlag: UINT = MB_ICONINFORMATION
    if icon == ReactiveDialogIcon.dlgWarning: iconFlag = MB_ICONWARNING
    if icon == ReactiveDialogIcon.dlgError: iconFlag = MB_ICONERROR
    if icon == ReactiveDialogIcon.dlgQuestion: iconFlag = MB_ICONQUESTION

    # Show message box
    MessageBox(0, text, title, MB_OK or iconFlag)


# Show a confirmation prompt
proc confirm*(text: string, title: string = "", icon: ReactiveDialogIcon = dlgInfo) : bool =

    # Get correct icon
    var iconFlag: UINT = MB_ICONINFORMATION
    if icon == ReactiveDialogIcon.dlgWarning: iconFlag = MB_ICONWARNING
    if icon == ReactiveDialogIcon.dlgError: iconFlag = MB_ICONERROR
    if icon == ReactiveDialogIcon.dlgQuestion: iconFlag = MB_ICONQUESTION

    # Show message box
    let res = MessageBox(0, text, title, MB_OKCANCEL or iconFlag)
    if res == IDOK: 
        return true
    else: 
        return false