import std/os
import std/tempfiles
import std/exitprocs
import classes
import ./basebackend
import ../native/corefoundation
import ../native/appkit

##
## Mac OS X backend
## See: https://github.com/jangko/objc (objc runtime)
class MacBackend of ReactiveBackend:

    # Backend ID
    var id = "macosx"

    # Ephemeral directory, will be deleted on app exit
    var p_ephemeralDirectory = ""

    # Check if supported
    method supported(): bool =
        when defined(macosx):
            return true
        else:
            return false


    # Get ephemeral directory, which is a temporary directory that is deleted on app exit
    method ephemeralDirectory(): string =

        # Return if already created
        if this.p_ephemeralDirectory != "":
            return this.p_ephemeralDirectory

        # Create ephemeral directory for this app
        let dir = createTempDir("nimreactive", "temp")
        this.p_ephemeralDirectory = dir

        # Remove it on app exit
        addExitProc(proc() =
            removeDir(dir)
        )


    # Start the backend. This is called after the app's reactiveStart: and never returns
    method start() =

        # Start the NSApplication ... this blocks indefinitely
        var params = commandLineParams()
        params.insert(getAppFilename(), 0)
        NSApplicationMain(params.len.cint, params.allocCStringArray)

    # Show an alert
    method alert(text: string, title: string = "", icon: ReactiveDialogIcon = Info) =

        # CoreFoundation can't use data URIs, so save our alert icons to a temporary folder ... unfortunately ...
        try:
            const errorIconData = staticRead("../resources/dialog_error.png")
            const infoIconData = staticRead("../resources/dialog_info.png")
            const warningIconData = staticRead("../resources/dialog_warning.png")
            const questionIconData = staticRead("../resources/dialog_question.png")
            if not fileExists(this.ephemeralDirectory / "nimreactive-dialog-error.png"): writeFile(this.ephemeralDirectory / "nimreactive-dialog-error.png", errorIconData)
            if not fileExists(this.ephemeralDirectory / "nimreactive-dialog-info.png"): writeFile(this.ephemeralDirectory / "nimreactive-dialog-info.png", infoIconData)
            if not fileExists(this.ephemeralDirectory / "nimreactive-dialog-warning.png"): writeFile(this.ephemeralDirectory / "nimreactive-dialog-warning.png", warningIconData)
            if not fileExists(this.ephemeralDirectory / "nimreactive-dialog-question.png"): writeFile(this.ephemeralDirectory / "nimreactive-dialog-question.png", questionIconData)
        except:
            discard

        # Choose an icon
        var iconURL = ""
        if icon == Error: iconURL = "file://" & (this.ephemeralDirectory / "nimreactive-dialog-error.png")
        elif icon == Info: iconURL = "file://" & (this.ephemeralDirectory / "nimreactive-dialog-info.png")
        elif icon == Warning: iconURL = "file://" & (this.ephemeralDirectory / "nimreactive-dialog-warning.png")
        elif icon == Question: iconURL = "file://" & (this.ephemeralDirectory / "nimreactive-dialog-question.png")
        
        # Create CFURL if there's an icon
        var cfIconUrl: CFURLRef = nil
        if iconURL != "":
            cfIconUrl = CFURLCreateWithString(urlString = iconURL)

        # Show MacOS alert
        var result: CFOptionFlags
        discard CFUserNotificationDisplayAlert(iconURL = cfIconUrl, alertHeader = title, alertMessage = text, responseFlags = addr result)