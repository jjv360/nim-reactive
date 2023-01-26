import classes
import std/tables
import std/strutils


##
## Property item within a property bundle
class PropertyItem:

    ## Value storage
    var stringValue = ""
    var intValue = 0
    var floatValue = 0.0
    var procValue: proc() = nil


## Convert a string to a PropertyItem
converter propFromString*(value: string) : PropertyItem =

    # Set string
    let item = PropertyItem.init()
    item.stringValue = value

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

## Convert an int to a PropertyItem
converter propFromInt*(value: int) : PropertyItem =
    let item = PropertyItem.init()
    item.stringValue = $value
    item.intValue = value
    item.floatValue = value.toFloat()
    return item

## Convert a float to a PropertyItem
converter propFromFloat*(value: float) : PropertyItem =
    let item = PropertyItem.init()
    item.stringValue = $value
    item.intValue = value.toInt()
    item.floatValue = value
    return item

## Convert a proc to a PropertyItem
converter propFromProc*(value: proc()) : PropertyItem =
    let item = PropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    return item

## Save a proc to a PropertyItem ... this is necessary because the converter from proc doesn't seem to work
proc `[]=`*(props: var Table[string, PropertyItem], name: string, value: proc()) =
    let item = PropertyItem.init()
    item.procValue = value
    item.stringValue = "<proc>"
    props[name] = item

## Convert a PropertyItem to a string
converter propToString*(item: PropertyItem) : string = 
    if item == nil: return ""
    return item.stringValue

## Convert a PropertyItem to a cstring
converter propToCString*(item: PropertyItem) : cstring = 
    if item == nil: return ""
    return item.stringValue.cstring

## Convert a PropertyItem to an int
converter propToInt*(item: PropertyItem) : int = 
    if item == nil: return 0
    return item.intValue

## Convert a PropertyItem to an int32
converter propToInt32*(item: PropertyItem) : int32 = 
    if item == nil: return 0
    return item.intValue.int32

## Convert a PropertyItem to an int64
converter propToInt64*(item: PropertyItem) : int64 = 
    if item == nil: return 0
    return item.intValue.int64

## Convert a PropertyItem to a float
converter propToFloat*(item: PropertyItem) : float =
    if item == nil: return 0
    return item.floatValue

## Convert a PropertyItem to a proc
converter propToProc*(item: PropertyItem) : proc() = 
    if item == nil: return nil
    return item.procValue

## Utility to get an optional value from the property bag
proc `{}`*(props: Table[string, PropertyItem], key: string): PropertyItem =
    return props.getOrDefault(key, nil)



##
## Base class for all Components.
class BaseComponent:

    ## Component props passed into the compnent at render time
    var props: Table[string, PropertyItem]

    ## Children nodes, if any
    var children: seq[BaseComponent]

    ## Parent node, if any
    var parent: BaseComponent = nil

    ## Component state
    var state: Table[string, PropertyItem]

    ## Private state flags
    var privateHasDoneNativeMount = false
    var privateHasDoneMount = false

    ## Render this component ... default implementation just renders children
    method render(): BaseComponent =
        let itm = BaseComponent.init()
        itm.children = this.children
        return itm

    ## Debug utility: Print out the component heirarchy from this point
    method printViewHeirarchy(depth: int = 0) =

        # Print ours
        echo "  ".repeat(depth) & "- " & $this

        # Print children
        for child in this.children:
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
## Group component which simply renders it's children
class Group of BaseComponent


##
## Utility: Unmount this component
template unmount*(component: BaseComponent) =
    ReactiveMountManager.unmount(component)