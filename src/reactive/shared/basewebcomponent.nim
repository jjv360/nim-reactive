import classes
import ./basecomponent

##
## Base web component
class BaseWebComponent of Component:

    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) = discard