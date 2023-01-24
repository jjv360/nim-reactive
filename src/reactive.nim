##
## Entry point for the lib

# General stuff
import reactive/backends
import reactive/components/basecomponent
import reactive/utils
export basecomponent, backends, utils

# Components
import reactive/components/window
export window

## Entry point for a Reactive app
proc reactiveStart*(code: proc()) =

    # Catch errors
    reactiveCrashOnError:

        # Load the backend
        echo "[Reactive] Starting using backend: " & reactiveBackend.id
        reactiveBackend.load()

        # Run their code
        code()

        # Enter the backend's run loop
        reactiveBackend.start()
