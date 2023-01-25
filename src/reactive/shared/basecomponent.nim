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



##
## Prop bundle, contains a list of key/value properties of multiple types
class PropertyBundle:

    ## Storage
    var items : Table[string, PropertyItem]

    ## Get prop as string or blank if it doesn't exist
    method str(name: string, default: string = ""): string = 
        let item = this.items.getOrDefault(name, nil)
        if item != nil:
            return item.stringValue
        else:
            return default

    ## Get prop as int
    method int(name: string, default: int = 0): int = 
        let item = this.items.getOrDefault(name, nil)
        if item != nil:
            return item.intValue
        else:
            return default

    ## Get prop as float
    method float(name: string, default: float = 0): float = 
        let item = this.items.getOrDefault(name, nil)
        if item != nil:
            return item.floatValue
        else:
            return default

    ## Get prop as string or blank if it doesn't exist
    method `[]`(name: string): string = this.str(name)

    ## Set string value
    method `[]=`(name: string, value: string) =

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

        # Store it
        this.items[name] = item

    ## Set int value
    method `[]=`(name: string, value: int) =

        # Set values
        let item = PropertyItem.init()
        item.stringValue = $value
        item.intValue = value
        item.floatValue = value.toFloat()
        this.items[name] = item

    ## Set float value
    method `[]=`(name: string, value: float) =

        # Set values
        let item = PropertyItem.init()
        item.stringValue = $value
        item.intValue = value.toInt()
        item.floatValue = value
        this.items[name] = item

    ## Set proc value
    method `[]=`(name: string, value: proc()) =

        # Set values
        let item = PropertyItem.init()
        item.procValue = value
        this.items[name] = item


##
## Base class for all Components.
class BaseComponent:

    ## Component props passed into the compnent at render time
    var props: PropertyBundle = PropertyBundle.init()

    ## Children nodes, if any
    var children: seq[BaseComponent]

    ## Component state
    var state: PropertyBundle = PropertyBundle.init()

    ## Render this component ... default implementation just renders children
    method render(): seq[BaseComponent] = this.children

    ## Start rendering the tree from this Component. Only native components need to implement this.
    ## This is called by the app when they want to create a new top-level component, such as a
    ## Window, ContextMenu, etc.
    method mount() = raiseAssert("This component cannot be mounted.")

    ## Remove this component from the system if it's mounted
    method unmount() = discard

    ## Debug utility: Print out the component heirarchy from this point
    method printViewHeirarchy(depth: int = 0) =

        # Print ours
        echo "  ".repeat(depth) & "- " & $this

        # Print children
        for child in this.children:
            child.printViewHeirarchy(depth + 1)


    ## String description of this component
    method `$`(): string =

        # Build string
        var str = this.className() & ":"
        for key, value in this.props.items.pairs:
            str = str & " " & key & "=" & value.stringValue

        # Done
        return str


    


    ## Get state as string or blank if it doesn't exist
    method state(name: string, default: string = ""): string = 
        return this.state.getOrDefault(name, default)

    ## Get state as int
    method stateInt(name: string, default: int = 0): int = 
        try:
            if not this.state.hasKey(name): return default
            return this.state.getOrDefault(name).parseInt()
        except CatchableError:
            return default

    ## Get state as float
    method stateFloat(name: string, default: float = 0): float = 
        try:
            if not this.state.hasKey(name): return default
            return this.state.getOrDefault(name).parseFloat()
        except CatchableError:
            return default



##
## Group component which simply renders it's children
class Group of BaseComponent