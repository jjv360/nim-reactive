import classes
import ../base
import reactivepkg/components
import ../bindings/gtk


## Button component
component Button:

    # Button title
    var title = "Button"

    # Event: On click
    var onClick: proc() = nil

    ## Called when the window is created
    method onPlatformCreate() =

        # Create window
        this.gtkWidget = gtk_button_new()
        this.gtkWidget.gtk_widget_show()
        
        # Connect event listener
        # this.connectSignal(this.gtkWidget, "clicked")


    ## Called on update
    method onPlatformUpdate() =

        # Update title
        this.gtkWidget.gtk_button_set_label(this.title.cstring())


    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.title = newProps.Button().title
        this.onClick = newProps.Button().onClick