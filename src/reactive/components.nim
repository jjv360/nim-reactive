import macros
import classes
import std/tables


## Register a component with the component registry
macro registerAs*(id: string) = 
    
    ## Dummy command, actual code is handled in the component macro
    discard


##
## Base layout class
class BaseLayout


## The `component` macro is the same as the `class` macro, but allows for extra component-based actions.
macro component*(head: untyped, body: untyped): untyped =
    mixin class

    # Create new output code
    result = newStmtList()

    # Create code to run afterwards
    var codeAfter = newStmtList()

    # Check what format was used
    var className: NimNode
    var baseName: NimNode
    if head.kind == nnkIdent:

        # Format is: class MyClass
        # Default base class should be the Component class
        className = head
        baseName = ident"Component"

    if head.kind == nnkInfix:

        # Format is: class MyClass of BaseClass
        # Do safety checks
        if $head[0] != "of": raiseAssert("Unknown operator " & $head[0])
        if head[1].kind != nnkIdent: raiseAssert("Invalid class name: " & $head[1])
        if head[2].kind != nnkIdent: raiseAssert("Invalid base class name: " & $head[2])
        className = head[1]
        baseName = head[2]

    # Go through each line of code
    traverseClassStatementList body, proc(idx: int, parent: NimNode, node: NimNode) =

        # Check command type
        if node.kind == nnkCommand and node[0].strVal == "registerAs":

            # registerAs command: Replace with a command to add it to the registry
            let componentID = node[1].strVal
            parent[idx] = newStmtList()#newCommentStmtNode("Replaced command: registerAs")
            codeAfter.add(quote do: 
                ComponentRegistry.shared.add(`componentID`, proc(): BaseComponent = `className`.init())
            )

        elif node.kind == nnkCall and node[0].strVal == "render":

            # Render block, change it to be a function definition instead
            let insideCode = node[1]
            parent[idx] = quote do:
                method render(): BaseComponent = 
                    reactiveUi: `insideCode`

        elif node.kind == nnkCall and node[0].strVal == "mount":

            # Mount block, change it to be a function definition instead
            let insideCode = node[1]
            parent[idx] = quote do:
                method didMount() =
                    super.didMount()
                    `insideCode`

    # Class definition
    result.add(quote do: 
        classes.class `className` of `baseName`:
            `body`
    )


    # Add code after class
    result.add(codeAfter)
    return result


## Empty components
macro component*(head: untyped): untyped = quote do: component `head`: discard


## The component is the core of all rendering in Reactive. It is a class which represents an on-screen item. All components are subclasses of `BaseComponent`. The more generic `Component` class is registered by the active platform plugin
class BaseComponent:

    ## Reference ID, used when handling components in arrays.
    var referenceID = ""

    ## Mounted component node ID, or 0 if not mounted
    var mountedNodeID: uint = 0

    ## Component tree item reference
    var componentTreeNode: RootRef = nil

    ## Definition of child items, used while constructing the UI language
    var children: seq[BaseComponent]

    ## Identifies the special Group type
    var isGroupNode = false

    ## Parent component
    var parent: BaseComponent = nil

    ## Layout
    var layout: BaseLayout = nil

    ## Default style fields
    var backgroundColor = ""

    ## Called when the component is created. Used by platform plugins.
    method onPlatformCreate() = raiseAssert("The platform plugin must implement onPlatformCreate().")

    ## Called when the component is created but not added to the screen yet. This is not very useful as no properties will be loaded yet. You should use didMount() and willUnmount() instead.
    method didCreate() = discard

    ## Called when the component should be mounted by the platform plugin
    method onPlatformMount() = raiseAssert("The platform plugin must implement onPlatformMount().")

    ## Called when the component has been added to the screen
    method didMount() = discard

    ## Called when the component should be updated by the platform plugin
    method onPlatformUpdate() = discard # this is optional ... raiseAssert("The platform plugin must implement onPlatformUpdate().")

    ## Called when the component's properties or state is updated.
    method didUpdate() = discard

    ## Called when the component layout should be re-evaluated by the platform plugin
    method onPlatformLayout() = discard # this is optional ... raiseAssert("The platform plugin must implement onPlatformUpdate().")

    ## Called when the layout of this component changed. Layout changes don't trigger a render() unless you call this.updateUi() in here.
    method didLayout() = discard

    ## Called before the component is removed from the screen
    method willUnmount() = discard

    ## Called when the component should be unmounted by the platform plugin
    method onPlatformUnmount() = raiseAssert("The platform plugin must implement onPlatformUnmount().")

    ## Called when the component is removed from memory
    method willDestroy() = discard

    ## Called when the component should be deleted by the platform plugin
    method onPlatformDestroy() = raiseAssert("The platform plugin must implement onPlatformDestroy().")

    ## Force a reload of the UI. This calls render() again.
    method updateUi() =
        echo "Called updateUi()"

    ## Overridden by the app, this controls child components to render.
    method render(): BaseComponent = nil

    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 

        # Copy generic props
        this.children = newProps.children
        this.layout = newProps.layout
        this.backgroundColor = newProps.backgroundColor


## A special component which does not itself render anything. Can be used to group items.
class Group of BaseComponent:

    ## Identifies the special Group type
    var isGroupNode = true

    # Default placeholders
    method onPlatformCreate() = discard
    method onPlatformMount() = discard
    method onPlatformUpdate() = discard
    method onPlatformUnmount() = discard
    method onPlatformDestroy() = discard


## A special component which represents pure text.
class Text of BaseComponent:

    ## Text content
    var internalTextContent = ""

    ## Placeholders
    method onPlatformCreate() = discard
    method onPlatformMount() = discard
    method onPlatformUpdate() = discard
    method onPlatformUnmount() = discard
    method onPlatformDestroy() = discard
    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.internalTextContent = Text(newProps).internalTextContent


## The component database stores references to registered components.
singleton ComponentRegistry:

    ## Registered components and their constructors
    var all: Table[string, proc(): BaseComponent]

    ## Register a component
    method add(id: string, constructor: proc(): BaseComponent) =

        # Add it
        echo "Registered component: " & id
        this.all[id] = constructor


    ## Create a new component instance from it's ID
    method create(id: string): BaseComponent =

        # Make sure it exists
        if not this.all.contains(id):
            raiseAssert("Component with ID '" & id & "' not found in the ComponentRegistry. Has it been registered?")

        # Create it
        let constructor = this.all[id]
        let componentInstance = constructor()

        # Done
        return componentInstance


## Convert a named Component class to the actual class reference. Note that the place where this call is used still needs to have the specified class imported
macro componentNameToReference*(name: string): untyped = ident(name.strVal)