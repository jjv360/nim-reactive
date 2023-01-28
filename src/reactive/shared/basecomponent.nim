import classes
import std/tables
import std/strutils


##
## Property item within a property bundle
class ReactivePropertyItem:

    ## Value storage
    var stringValue = ""
    var intValue = 0
    var floatValue = 0.0
    var procValue: proc() = nil

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

## Convert a float to a ReactivePropertyItem
converter propFromFloat*(value: float) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.stringValue = $value
    item.intValue = value.toInt()
    item.floatValue = value
    item.isFloat = true
    item.isNumber = true
    return item

## Convert a proc to a ReactivePropertyItem
converter propFromProc*(value: proc()) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    item.isProc = true
    return item

## Save a proc to a ReactivePropertyItem ... this is necessary because the converter from proc doesn't seem to work
proc `[]=`*(props: var Table[string, ReactivePropertyItem], name: string, value: proc()) =
    let item = ReactivePropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    props[name] = item

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
converter propToProc*(item: ReactivePropertyItem) : proc() = 
    if item == nil: return nil
    return item.procValue

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


    ## Called when the component is first mounted ... this is used by native code to create the necessary UI etc
    method onNativeMount() = discard

    ## Called when the component has been mounted
    method onMount() = discard

    ## Called when the component has been unmounted
    method onUnmount() = discard

    ## Called on unmount
    method onNativeUnmount() = discard





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


##
## Utility: Unmount this component
template unmount*(component: Component) =
    ReactiveMountManager.unmount(component)