##
## Interaction with system dialogs
import std/os
import std/tempfiles
import std/exitprocs
import ./native/corefoundation
import ./native/foundation

# Get ephemeral directory, which is a temporary directory that is deleted on app exit
proc ephemeralDirectory(): string =

    # Return if already created
    var dir {.global.} = ""
    if dir != "":
        return dir

    # Create ephemeral directory for this app
    dir = createTempDir("nimreactive", "temp")

    # Remove it on app exit
    addExitProc(proc() =
        removeDir(dir)
    )

## Alert icon types
type ReactiveDialogIcon* = enum dlgInfo, dlgWarning, dlgError, dlgQuestion

# Show an alert
proc alert*(text: string, title: string = "", icon: ReactiveDialogIcon = dlgInfo) =
    
    # CoreFoundation can't use data URIs, so save our alert icons to a temporary folder ... unfortunately ...
    try:
        const errorIconData = staticRead("../resources/dialog_error.png")
        const infoIconData = staticRead("../resources/dialog_info.png")
        const warningIconData = staticRead("../resources/dialog_warning.png")
        const questionIconData = staticRead("../resources/dialog_question.png")
        if not fileExists(ephemeralDirectory() / "nimreactive-dialog-error.png"): writeFile(ephemeralDirectory() / "nimreactive-dialog-error.png", errorIconData)
        if not fileExists(ephemeralDirectory() / "nimreactive-dialog-info.png"): writeFile(ephemeralDirectory() / "nimreactive-dialog-info.png", infoIconData)
        if not fileExists(ephemeralDirectory() / "nimreactive-dialog-warning.png"): writeFile(ephemeralDirectory() / "nimreactive-dialog-warning.png", warningIconData)
        if not fileExists(ephemeralDirectory() / "nimreactive-dialog-question.png"): writeFile(ephemeralDirectory() / "nimreactive-dialog-question.png", questionIconData)
    except:
        discard

    # Choose an icon
    var iconURL = NSURL(nil)
    if icon == dlgError: iconURL = NSURL.fileURLWithPath(ephemeralDirectory() / "nimreactive-dialog-error.png", isDirectory = false)
    elif icon == dlgInfo: iconURL = NSURL.fileURLWithPath(ephemeralDirectory() / "nimreactive-dialog-info.png", isDirectory = false)
    elif icon == dlgWarning: iconURL = NSURL.fileURLWithPath(ephemeralDirectory() / "nimreactive-dialog-warning.png", isDirectory = false)
    elif icon == dlgQuestion: iconURL = NSURL.fileURLWithPath(ephemeralDirectory() / "nimreactive-dialog-question.png", isDirectory = false)

    # Show MacOS alert
    discard CFUserNotificationDisplayAlert(iconURL = iconURL, alertHeader = title, alertMessage = text)