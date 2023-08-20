import std/tables
import std/strutils
import classes
import ./events


##
## Property item within a property bundle
class ReactivePropertyItem:

    ## Value storage
    var stringValue = ""
    var intValue = 0
    var floatValue = 0.0
    var procValue: proc(arg: ReactiveEvent) = nil
    var objValue: RootRef = nil

    ## Original value type
    var isString = false
    var isInt = false
    var isFloat = false
    var isNumber = false
    var isProc = false
    var isObj = false


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

## Convert an object to a ReactivePropertyItem
converter propFromObject*(value: RootRef) : ReactivePropertyItem =
    let item = ReactivePropertyItem.init()
    item.objValue = value
    item.stringValue = "<object>"
    item.intValue = 1
    item.floatValue = 1
    item.isObj = true
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

## Utility to return a class type from a property
proc asObject* [T] (this : ReactivePropertyItem, t : typedesc[T]) : T = 
    if this == nil: return nil
    if not this.isObj: raiseAssert("This property is not an object.")
    return this.objValue.RootRef.T
