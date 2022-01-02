import classes
import ../base
import reactivepkg/components

    
## Label, displays some text
component Label:

    # Text
    var text = ""

    # Style properties
    var textColor = ""

    # Called when the component is updated
    method onPlatformUpdate() = discard


    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.text = newProps.Label().text
        this.textColor = newProps.Label().textColor