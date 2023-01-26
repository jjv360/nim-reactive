import classes
import ./basecomponent

##
## Manages mounted components
singleton ReactiveMountManager:

    ## List of mounted components
    var mountedComponents: seq[BaseComponent]

    ## Mount a component
    method mount(component: BaseComponent) =

        echo "HERE"