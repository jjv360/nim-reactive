import classes
import reactivepkg/components
import ../base
import ../bindings/gtk
import strutils

## Get parent HWND
# proc parentWithHWND(comp: BaseComponent): Component =

#     # Go through heirarchy
#     var item = comp.parent
#     while item != nil:

#         # Check if this one has a HWND
#         if item of Component and Component(item).hwnd != 0:
#             return Component(item)

#         # Nope, continue up the chain
#         item = item.parent
        
#     # Not found
#     raiseAssert("No parent window handle found.")

##
## Absolute layout. This layout system simply moves the object to an absolute position within it's parent.
class AbsoluteLayout of GnomeLayout:

    ## Coordinates. Examples are: "32px", "50%".
    var x = ""
    var y = ""
    var width = ""
    var height = ""

    ## Fetch pixel value of an input
    method pixelValue(input: string, parentValue: float): int =

        # Check prefix
        if input.startsWith("calc("):

            # Not supported yet
            raiseAssert("calc() values for absolute layout are not supported yet.")

        elif input.endsWith("px"):

            # Already in pixels, just parse it
            return parseFloat(input.substr(0, input.high()-2)).int()

        elif input.endsWith("%"):

            # In percents
            return (parseFloat(input.substr(0, input.high()-1)) / 100 * parentValue).int()

        else:

            # Unknown format
            raiseAssert("Unknown format string for absolute position: " & input)


    ## Perform the layout
    method update(component: BaseComponent) =

        # Stop if not a component
        if not (component of Component): return
        let gnomeComponent = Component(component)

        # Stop if no widget
        if gnomeComponent.gtkWidget == nil:
            return

        # Get parent element
        let parentWidget = gnomeComponent.parentWidget
        if parentWidget == nil:
            return

        # Get parent window's layout information
        let parentWidth = 400.0
        let parentHeight = 400.0

        # Get absolute pixel values for input
        let x = this.pixelValue(this.x, parentWidth)
        let y = this.pixelValue(this.y, parentHeight)
        let width = this.pixelValue(this.width, parentWidth)
        let height = this.pixelValue(this.height, parentHeight)

        # Set layout ... we are assuming the parent is a GtkFixed since that's the only one we support right now
        parentWidget.gtk_fixed_put(gnomeComponent.gtkWidget, x, y)
        gnomeComponent.gtkWidget.gtk_widget_set_size_request(width, height)
        