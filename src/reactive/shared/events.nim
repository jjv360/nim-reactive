import classes


##
## Represents a generic event
class ReactiveEvent:

    ## Event name
    var name = ""

    ## Event value
    var value = ""

    ## Source component
    var source : RootRef = nil

    ## True if the standard event behaviour should be cancelled
    var isHandled = false

    ## Mark as handled, which prevents the default behaviour
    method handled() =
        this.isHandled = true


##
## Represents a pointer edvice event
class ReactivePointerEvent of ReactiveEvent:

    ## X coordinate
    var x = 0.0

    ## Y coordinate
    var y = 0.0

    ## Button index
    var button = 0

    ## Pointer type
    var pointerType = "mouse"


##
## Event emitter class
class ReactiveEventEmitter:

    ## Event handlers
    