import classes
import ../base
import reactivepkg/components


## Button component
component Button:

    # Button title
    var title = "Button"

    # Event: On click
    var onClick: proc() = nil

    # Called when the component is updated
    method onPlatformUpdate() = discard


    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.title = newProps.Button().title
        this.onClick = newProps.Button().onClick