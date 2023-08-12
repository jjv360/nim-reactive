import std/tables
import std/strutils
import classes
import ./events
import ./properties


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
    method sendEventToProps(name: string, value: string = "") : ReactiveEvent {.discardable.} = 
        let event = ReactiveEvent.init(name, value)
        let handlerProp = this.props{name}
        if handlerProp != nil and handlerProp.procValue != nil:
            handlerProp.procValue(event)
        return event


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




## Find a parent with the specified type
proc findParent* [T] (this : Component, _: typedesc[T]) : T =

    # Check if we match
    var current = this.renderedParent
    while current != nil:
        try:
            return current.T()
        except:
            discard
        current = current.renderedParent

    # Not found
    return nil


## Find the first child with the specified type
proc findChild* [T] (this : Component, _: typedesc[T]) : T =

    # Check children
    for child in this.renderedChildren:
        try:
            return child.T()
        except:
            discard

    # None found, search recursively
    for child in this.renderedChildren:
        let found = child.findChild(T)
        if found != nil: return found

    # Not found
    return nil


## Find the first child matching the predicate
proc findChild* [T] (this : Component, pred : proc (it : T) : bool) : T =

    # Check children
    for child in this.renderedChildren:
        try:
            let childCon = child.T()
            if pred(childCon): return childCon
        except:
            discard

    # None found, search recursively
    for child in this.renderedChildren:
        let found = child.findChild(pred)
        if found != nil: return found

    # Not found
    return nil


## Find all children matching the predicate
proc findChildren* [T] (this : Component, includeSubChildren : bool = false, pred : proc (it : T) : bool) : seq[T] =

    # Create list
    var list : seq[T]

    # Check children
    for child in this.renderedChildren:

        # Check if this child is valid, if so add it
        try:

            # Add if it works
            let validChild = child.T()
            if not pred(validChild): raise newException(OSError, "Skip")
            list.add(validChild)
            if not includeSubChildren:
                continue

        except:
            discard

        # Child is not valid, check it's children
        let childList = child.findChildren(includeSubChildren, pred)
        if childList.len > 0:
            list.add(childList)

    # Done
    return list


## Find all children of the specified type
proc findChildren* [T] (this : Component, _: typedesc[T], includeSubChildren : bool = false) : seq[T] =
    return this.findChildren(includeSubChildren, proc(it : T) : bool = true)



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