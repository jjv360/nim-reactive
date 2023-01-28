import classes
import ./basecomponent


##
## Manages mounted components
singleton ReactiveMountManager:

    ## List of mounted components
    var mountedComponents: seq[Component]

    ## Find the mounted root component for a component tree
    method findMountedComponent(component: Component): Component =

        # Find parent which is mounted
        var node = component
        while node != nil:
            if this.mountedComponents.contains(node):
                return node
            else:
                node = node.renderedParent

        # Not found
        return nil


    ## Mount a component
    method mount(component: Component) =

        # Stop if already mounted
        if this.findMountedComponent(component) != nil:
            raise ValueError.newException("This component tree is already mounted.")

        # Add it
        this.mountedComponents.add(component)

        # Render it
        this.renderComponent(component)


    ## Unmount a component tree, starting from the nearest mounted parent
    method unmount(component: Component) =
        
        # Find parent which is mounted, stop if not found since that means this component tree is already unmounted
        let rootComponent = this.findMountedComponent(component)
        if rootComponent == nil:
            echo "[NimReactive] Unmount skipped since this component tree is not mounted."
            return

        # Remove it
        let idx = this.mountedComponents.find(rootComponent)
        if idx != -1:
            this.mountedComponents.del(idx)

        # Unmount the component
        this.unmountSingle(rootComponent)


    ## Unmount a single component
    method unmountSingle(component: Component) =

        # Stop if nil
        if component == nil:
            return

        # Call unmount on children
        for child in component.renderedChildren:
            this.unmountSingle(child)

        # Unmount it
        component.onUnmount()
        component.onNativeUnmount()


    ## Render a component
    method renderComponent(component: Component) =

        # Perform native mount
        if not component.privateHasDoneNativeMount:
            component.privateHasDoneNativeMount = true
            component.onNativeMount()

        # Call render and get components
        let renderOutput = component.render()
        if renderOutput == nil: 

            # Add children
            component.renderedChildren = component.children
            for child in component.renderedChildren:
                child.renderedParent = component

        else:

            # Add item
            component.renderedChildren = @[renderOutput]
            renderOutput.renderedParent = component


        # Render children as well
        for child in component.renderedChildren:
            this.renderComponent(child)

        # Perform mount
        if not component.privateHasDoneMount:
            component.privateHasDoneMount = true
            component.onMount()