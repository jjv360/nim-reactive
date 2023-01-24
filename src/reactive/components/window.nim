import classes
import ./basecomponent
import ../backends

##
## This class represents an onscreen window.
class ReactiveWindow of BaseComponent:

    ## Backend window info
    

    ## Create a new window
    method show() =

        # Create a window on the backend
        # reactiveBackend.createWindow()
        reactiveBackend.alert("Showing window")