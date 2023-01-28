import std/sequtils
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
            # echo "[NimReactive] Unmount skipped since this component tree is not mounted."
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
        var requestedChildren: seq[Component]
        if renderOutput == nil:
            requestedChildren = component.children
        else:
            requestedChildren = @[renderOutput]

        # Synchronize children list ... first add/update all children
        for idx, child in requestedChildren:

            # Get child key
            var key: string = child.props{"key"}
            if key.len == 0:
                key = child.className() & "-" & $idx

            # Find existing child
            var existingChild: Component = nil
            for it in component.renderedChildren:
                if it.renderedKey == key:
                    existingChild = it
                    break

            # Check if child already exists
            if existingChild == nil:

                # Not found, add it
                child.renderedKey = key
                component.renderedChildren.add(child)
                child.renderedParent = component

            else:

                # Child exists! Update the props on the child
                existingChild.props = child.props
                existingChild.children = child.children


        # Remove all rendered children that are no longer being rendered
        var nextIdx = 0
        while nextIdx < component.renderedChildren.len:

            # Get child key
            let idx = nextIdx
            nextIdx += 1
            let child = component.renderedChildren[idx]
            var key: string = child.props{"key"}
            if key.len == 0:
                key = child.className() & "-" & $idx

            # Find requested child
            var requestedChild: Component = nil
            for it in requestedChildren:

                # Get child key
                var childKey: string = it.props{"key"}
                if childKey.len == 0:
                    childKey = it.className() & "-" & $idx

                # Check if matches
                if childKey == key:
                    requestedChild = it
                    break

            # Stop if found
            if requestedChild != nil:
                continue

            # Not found, remove this child
            this.unmountSingle(child)
            component.renderedChildren.delete(idx)
            nextIdx -= 1


        # Render children as well
        for child in component.renderedChildren:
            this.renderComponent(child)

        # Perform mount
        if not component.privateHasDoneMount:
            component.privateHasDoneMount = true
            component.onMount()
        else:
            component.onNativeUpdate()
            component.onUpdate()


## Render the component again. Call this whenevr your component's state changes.
proc renderAgain*(this: Component) =

    # Ensure this component is mounted
    let mountedComponent = ReactiveMountManager.shared.findMountedComponent(this)
    if mountedComponent == nil:
        echo "[NimReactive] renderAgain() ignored since this component is not mounted"
        return

    # Render it
    ReactiveMountManager.shared.renderComponent(this)



##
## Utility: Unmount this component
proc unmount*(component: Component) =
    ReactiveMountManager.shared.unmount(component)