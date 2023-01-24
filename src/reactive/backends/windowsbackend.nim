import classes
import ./basebackend
import winim/lean
import std/asyncdispatch

##
## Mac OS X backend
## See: https://github.com/jangko/objc (objc runtime)
class WindowsBackend of ReactiveBackend:

    # Backend ID
    var id = "windows"

    # Check if supported
    method supported(): bool =
        when defined(windows):
            return true
        else:
            return false

    # Load the backend. This is called before the app's reactiveStart:
    method load() = 
    
        # Set DPI awareness
        SetProcessDPIAware()


    # Start the backend. This is called after the app's reactiveStart: and never returns
    method start() =

        # Create Win32 timer so our event loop is running at a minimum of 1ms, this is necessary to allow
        # asyncdispatch to run alongside the WIn32 event loop in the same thread
        SetTimer(0, 0, 1, nil)

        # Run the Windows event loop
        var msg: MSG
        while GetMessage(msg, 0, 0, 0) != 0:
            TranslateMessage(msg)
            DispatchMessage(msg)

            # Process asyncdispatch's event loop
            if asyncdispatch.hasPendingOperations():
                asyncdispatch.poll(0)


    # Show an alert
    method alert(text: string, title: string = "", icon: ReactiveDialogIcon = Info) =

        # Get correct icon
        var iconFlag: UINT = MB_ICONINFORMATION
        if icon == ReactiveDialogIcon.Warning: iconFlag = MB_ICONWARNING
        if icon == ReactiveDialogIcon.Error: iconFlag = MB_ICONERROR
        if icon == ReactiveDialogIcon.Question: iconFlag = MB_ICONQUESTION

        # Show message box
        MessageBox(0, text, title, MB_OK or iconFlag)