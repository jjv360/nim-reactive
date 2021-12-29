import classes
import ./components
import macros
import strutils

## Get a new unique node ID
proc getNextNodeID(): uint =
    var lastUsedNodeID {.global.}: uint = 1
    lastUsedNodeID += 1
    return lastUsedNodeID

## Find item matching criteria, or nil if not found
proc findItem [T] (s: openArray[T], pred: proc(x: T): bool {.closure.}): T {.effectsOf: pred.} =
    for item in s:
        if pred(item):
            return item
    return nil

## Find item matching criteria, or nil if not found
# template findIt [T] (s: openArray[T], pred: untyped): untyped = s.findItem(proc(it {.inject.}: T): bool = pred)
template findIt [T] (s: openArray[T], pred: untyped): untyped = 
    block:
        var foundItem: T = nil
        for it {.inject.} in s:
            if pred:
                foundItem = it
                break
        foundItem


## Represents a node within the component tree. Note that BaseComponent instances are used two different ways, the
## first time the node is mounted it becomes a complete component, but when receiving state updates via render()
## functions, it is only used for it's properties.
class ComponentTreeNode:

    ## Unique node ID
    var nodeID: uint = getNextNodeID()

    ## Component at this node
    var component: BaseComponent = nil
    var componentIsMounted = false
    var componentIsCreated = false

    ## Parent node
    var parentNode: ComponentTreeNode = nil

    ## Child nodes
    var childNodes: seq[ComponentTreeNode]

    ## Synchronize state changes starting from this node
    method synchronize() =

        # Check if created
        if not this.componentIsCreated:

            # Create it
            this.component.onPlatformCreate()
            this.component.didCreate()
            this.componentIsCreated = true

        # Special case: Check for group node
        if this.component.isGroupNode:

            # Sync each child
            for idx, child in this.component.children:
                this.synchronizeChildComponent(child)

        else:

            # Sync child from cmoponent's render
            let childComponent: BaseComponent = this.component.render()
            if childComponent != nil:
                this.synchronizeChildComponent(childComponent)

        # Check if mounted
        if not this.componentIsMounted:

            # Mount it
            this.component.onPlatformMount()
            this.component.didMount()
            this.componentIsMounted = true

        # Do layout
        this.component.onPlatformLayout()
        this.component.didLayout()

        # Notify updated
        this.component.onPlatformUpdate()
        this.component.didUpdate()


    method synchronizeChildComponent(childComponent: BaseComponent) =

        # Check if we have this child node already
        var childNode: ComponentTreeNode = this.childNodes.findIt(it.component.referenceID == childComponent.referenceID)
        if childNode == nil:

            # Create child node
            childNode = ComponentTreeNode()
            childNode.component = childComponent
            childNode.component.parent = this.component
            childNode.component.componentTreeNode = childNode
            childNode.parentNode = this
            this.childNodes.add(childNode)

        else:

            # Update properties of the child
            childNode.component.updateProperties(childComponent)
            
        # Synchronize child node
        childNode.synchronize()


    ## Debug: Output tree representation as a string
    method repr(depth = 1): string =

        # Output this node details
        var str = " ".repeat(depth * 2)
        str &= "- "
        str &= this.component.className
        str &= "\n"

        # Output child node details
        for idx, child in this.childNodes:
            str &= child.repr(depth + 1)

        # Done
        return str



    # # Mount a specific component based on it's ID at this node
    # method mountComponentWithID(id: string) =

    #     # Create the component
    #     let component = ComponentRegistry.shared.create(id)

    #     # Call lifecycle events
    #     component.onPlatformCreate()
    #     component.didCreate()

    #     # Mount it
    #     this.mountComponent(component)


    # # Mount a specific component at this node
    # method mountComponent(component: BaseComponent) =

    #     # Sanity check: Stop if there's already a mounted node here
    #     if this.component != nil:
    #         raiseAssert("[ComponentTree] Unable to mount component, there is already a mounted component here.")

    #     # Sanity check: Stop if this component is already mounted
    #     if component.mountedNodeID != 0:
    #         raiseAssert("[ComponentTree] Unable to mount component, it is already mounted.")

    #     # Mount it
    #     echo "[ComponentTree] Mounting: " & component.className
    #     this.component = component
    #     this.component.mountedNodeID = this.nodeID

    #     # Store reference to the parent component
    #     if this.parentNode != nil:
    #         this.component.parent = this.parentNode.component

    #     # Synchronize state starting from this node
    #     this.synchronize()


    # ## Synchronize state between this node and the actual component
    # method synchronize() =

        # # Check if created
        # if not this.componentIsCreated:

        #     # Create it
        #     this.component.onPlatformCreate()
        #     this.component.didCreate()
        #     this.componentIsCreated = true

        # # Check if mounted
        # if not this.componentIsMounted:

        #     # Mount it
        #     this.component.onPlatformMount()
        #     this.component.didMount()
        #     this.componentIsMounted = true

    #     # Get children render info
    #     let subcomponent = this.component.render()
    #     if subcomponent != nil:

    #         # Create node for subcomponent
    #         this.synchronizeSubcomponent(subcomponent)

    #     # Notify updated
    #     echo "HERE " & this.component.className
    #     this.component.onPlatformUpdate()
    #     this.component.didUpdate()


    # ## Synchronize a subcomponent
    # method synchronizeSubcomponent(subcomponent: BaseComponent) =

    #     # Check if child exists with this ref
    #     # let procs = proc(it: ComponentTreeNode): bool = it.component.referenceID == subcomponent.referenceID
    #     var childNode: ComponentTreeNode = this.childNodes.findIt(it.component.referenceID == subcomponent.referenceID)
        # if childNode == nil:

        #     # Create child node
        #     childNode = ComponentTreeNode()
        #     childNode.parentNode = this
        #     this.childNodes.add(childNode)

        #     # Mount component
        #     echo "CHILD node " & subcomponent.className
        #     childNode.mountComponent(subcomponent)

    #     # Check child items
    #     for childComponent in subcomponent.uiDefinitionChildren:

    #         # Synchronize subcomponent
    #         echo "CHILD component " & childComponent.className
    #         # childNode.synchronize()








## This class is responsible for managing the state of a component tree, and updating the nodes as their props change etc.
class ComponentTree:

    ## Base entry
    var rootEntry: ComponentTreeNode = nil

    ## Create a new tree with the specified node as a root
    method withRegisteredComponent(id: string): ComponentTree {.static.} =

        # Create new tree
        let tree = ComponentTree.init()

        # Mount the root node
        tree.rootEntry = ComponentTreeNode.init()
        tree.rootEntry.component = ComponentRegistry.shared.create(id)
        tree.rootEntry.component.componentTreeNode = tree.rootEntry

        # Start synchronizing
        tree.rootEntry.synchronize()

        # Output the tree format
        # echo "[Reactive] Creating new tree:\n" & tree.rootEntry.repr

        # Done
        return tree