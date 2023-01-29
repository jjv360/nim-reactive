import classes
import std/tables
import std/strutils


##
## Represents an event
class ReactiveEvent:

    ## Event name
    var name = ""

    ## Event value
    var value = ""

    ## Constructor
    method init(name: string, value: string = "") =
        this.name = name
        this.value = value


##
## Property item within a property bundle
class ReactivePropertyItem:

    ## Value storage
    var stringValue = ""
    var intValue = 0
    var floatValue = 0.0
    var procValue: proc(arg: ReactiveEvent) = nil

    ## Original value type
    var isString = false
    var isInt = false
    var isFloat = false
    var isNumber = false
    var isProc = false


## Convert a string to a PropertyItem
converter propFromString*(value: string) : ReactivePropertyItem =

    # Set string
    let item = ReactivePropertyItem.init()
    item.stringValue = value
    item.isString = true

    # Set int
    try:
        item.intValue = value.parseInt()
    except CatchableError:
        discard

    # Set float
    try:
        item.floatValue = value.parseFloat()
    except CatchableError:
        discard

    # Done
    return item

## Convert an int to a ReactivePropertyItem
converter propFromInt*(value: int) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.stringValue = $value
    item.intValue = value
    item.floatValue = value.toFloat()
    item.isInt = true
    item.isNumber = true
    return item

## Convert a bool to a ReactivePropertyItem
converter propFromBool*(value: bool) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.stringValue = $value
    item.intValue = if value: 1 else: 0
    item.floatValue = if value: 1 else: 0
    item.isInt = true
    item.isNumber = true
    return item

## Convert a float to a ReactivePropertyItem
converter propFromFloat*(value: float) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.stringValue = $value
    item.intValue = value.toInt()
    item.floatValue = value
    item.isFloat = true
    item.isNumber = true
    return item

## Convert an event proc to a ReactivePropertyItem
converter propFromProc*(value: proc(event: ReactiveEvent)) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    item.intValue = 1
    item.floatValue = 1
    item.isProc = true
    return item

## Convert a proc to a ReactivePropertyItem
converter propFromProc*(value: proc()) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.procValue = proc(_: ReactiveEvent) = value()
    item.stringValue = "<proc>"
    item.intValue = 1
    item.floatValue = 1
    item.isProc = true
    return item

## Save a proc to a ReactivePropertyItem ... this is necessary because the converter from proc doesn't seem to work
proc `[]=`*(props: var Table[string, ReactivePropertyItem], name: string, value: proc(event: ReactiveEvent)) =
    let item = ReactivePropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    item.intValue = 1
    item.floatValue = 1
    item.isProc = true
    props[name] = item

## Save a proc to a ReactivePropertyItem ... this is necessary because the converter from proc doesn't seem to work
proc `[]=`*(props: var Table[string, ReactivePropertyItem], name: string, value: proc()) =
    props[name] = proc(_: ReactiveEvent) = value()

## HACK: Save a ReactivePropertyItem to the property list ... somehow the above function is being called in this case without this...
proc `[]=`*(props: var Table[string, ReactivePropertyItem], name: string, value: ReactivePropertyItem) =
    {.warning[deprecated]:off.}:
        props.del(name)
        props.add(name, value) 

## Convert a ReactivePropertyItem to a string
converter propToString*(item: ReactivePropertyItem) : string = 
    if item == nil: return ""
    return item.stringValue

## Convert a ReactivePropertyItem to a cstring
converter propToCString*(item: ReactivePropertyItem) : cstring = 
    if item == nil: return ""
    return item.stringValue.cstring

## Convert a ReactivePropertyItem to an int
converter propToInt*(item: ReactivePropertyItem) : int = 
    if item == nil: return 0
    return item.intValue

## Convert a ReactivePropertyItem to an int32
converter propToInt32*(item: ReactivePropertyItem) : int32 = 
    if item == nil: return 0
    return item.intValue.int32

## Convert a ReactivePropertyItem to an int64
converter propToInt64*(item: ReactivePropertyItem) : int64 = 
    if item == nil: return 0
    return item.intValue.int64

## Convert a ReactivePropertyItem to a float
converter propToFloat*(item: ReactivePropertyItem) : float =
    if item == nil: return 0
    return item.floatValue

## Convert a ReactivePropertyItem to a proc
converter propToProc*(item: ReactivePropertyItem) : proc(event: ReactiveEvent) = 
    if item == nil: return nil
    return item.procValue

## Convert a ReactivePropertyItem to a bool
converter propToBool*(item: ReactivePropertyItem) : bool = 
    if item == nil: return false
    return item.intValue != 0

## Utility to get an optional value from the property bag
proc `{}`*(props: Table[string, ReactivePropertyItem], key: string): ReactivePropertyItem =
    return props.getOrDefault(key, nil)



##
## Base class for all Components.
class Component:

    ## Component props passed into the compnent at render time
    var props: Table[string, ReactivePropertyItem]

    ## Children nodes defined when the component was rendered, if any
    var children: seq[Component]

    ## Actual rendered child nodes
    var renderedChildren: seq[Component]

    ## Parent node, if any
    var renderedParent: Component = nil

    ## Rendered child key
    var renderedKey = ""

    ## Component state
    # var state: Table[string, ReactivePropertyItem]

    ## Private state flags
    var privateHasDoneNativeMount = false
    var privateHasDoneMount = false

    ## Render this component ... default implementation just renders children
    method render(): Component = nil

    ## Debug utility: Print out the component heirarchy from this point
    method printViewHeirarchy(depth: int = 0) =

        # Print ours
        echo "  ".repeat(depth) & "- " & $this

        # Print children
        for child in this.renderedChildren:
            child.printViewHeirarchy(depth + 1)


    ## String description of this component
    method `$`(): string =

        # Build string, start with component name
        var str = this.className()
        
        # Add separator if it has props
        if this.props.len > 0:
            str = str & ":"

        # App props
        for key, value in this.props.pairs:
            str = str & " " & key & "=" & value

        # Done
        return str


    ## Trigger an event
    method sendEventToProps(name: string, value: string = "") = 
        let event = ReactiveEvent.init(name, value)
        let handlerProp = this.props{name}
        if handlerProp != nil and handlerProp.procValue != nil:
            handlerProp.procValue(event)


    ## Trigger an event
    method sendEventToProps(event: ReactiveEvent) = 
        let handlerProp = this.props{event.name}
        if handlerProp != nil and handlerProp.procValue != nil:
            handlerProp.procValue(event)

    ## Called when the component has been mounted
    method onMount() = discard

    ## Called when the component has been updated
    method onUpdate() = discard

    ## Called when the component has been unmounted
    method onUnmount() = discard

    ## Called when the component is first mounted
    method onNativeMount() = discard

    ## Called when the component has been updated
    method onNativeUpdate() = discard

    ## Called on unmount
    method onNativeUnmount() = discard



##
## Base class for native Components.
class NativeComponent of Component





##
## Base class for a native component renderer. The renderer is responsible for converting Components into their native counterparts.
# class ComponentRenderer:

#     ## Renderer ID
#     var id = ""



# ##
# ## Component class, represents something drawn on screen
# class Component of Component:

#     ## Native component renderer, if any.
#     var nativeRenderer: ComponentRenderer

#     ## Get the nearest component renderer for this component
#     method getRenderer(): ComponentRenderer =

#         # Check if we have one
#         if this.nativeRenderer != nil:
#             return this.nativeRenderer

#         # Check parent
#         if this.parent != nil:
#             return this.parent.Component.getRenderer()
        
#         # No renderer found for this Component
#         return nil



##
## Group component which simply renders it's children
class Group of Component