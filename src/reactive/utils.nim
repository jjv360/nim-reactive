##
## Generic utilities

import ./backends

## Do some code and crash the app if it fails
template reactiveCrashOnError*(code: untyped) =

    # Catch errors
    try:

        # Do their code
        code

    except Exception as err:

        # Crash, log it
        echo "[Reactive] App crash: " & err.msg
        echo err.getStackTrace()

        # Show error dialog if possible
        try:
            reactiveBackend.alert(err.msg, "Application crashed!", ReactiveDialogIcon.Error)
        except:
            discard

        # End the process
        quit(1000)