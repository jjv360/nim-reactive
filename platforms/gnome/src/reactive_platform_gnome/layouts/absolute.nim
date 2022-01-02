import classes
import reactivepkg/components
import ../base
import strutils

##
## Absolute layout. This layout system simply moves the object to an absolute position within it's parent.
class AbsoluteLayout of GnomeLayout:

    ## Coordinates. Examples are: "32px", "50%".
    var x = ""
    var y = ""
    var width = ""
    var height = ""

    ## Perform the layout
    method update(component: BaseComponent) = discard