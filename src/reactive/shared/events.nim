import classes


##
## Represents a generic event
class ReactiveEvent:

    ## Event name
    var name = ""

    ## Event value
    var value = ""

    ## True if the standard event behaviour should be cancelled
    var isHandled = false

    ## Constructor
    method init(name: string, value: string = "") =
        this.name = name
        this.value = value

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

    ## Constructor
    method init(name: string, pointerType : string = "mouse", x : float = 0, y : float = 0) =
        super.init(name)
        this.pointerType = pointerType
        this.x = x
        this.y = y