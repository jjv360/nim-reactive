import classes
import reactivepkg/components
import ../base
import ../bindings/gtk

## Get app name
const ReactiveAppInfoTitle {.strdefine.} = "My App"

## Window component
component Window:

    ## Window title
    var title: string = ReactiveAppInfoTitle

    ## Called when the window is created
    method onPlatformCreate() =

        # Create window
        this.gtkWidget = gtk_window_new(GTK_WINDOW_TOPLEVEL)
        this.gtkWidget.gtk_window_set_application(gtkApplication)

        # Present it to the user
        gtk_window_present(this.gtkWidget)


    ## Called when the properties are updated
    method onPlatformUpdate() =

        # Update properties
        this.gtkWidget.gtk_window_set_title(this.title)


    ## Called when new properties are incoming and need to be copied in
    method updateProperties(newProps: BaseComponent) = 

        # Copy generic props
        let incomingProps = Window(newProps)
        this.title = incomingProps.title