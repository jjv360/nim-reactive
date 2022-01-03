import classes
import reactivepkg/components
import ../base
import ../bindings/gtk

## Get app name
const ReactiveAppInfoTitle {.strdefine.} = "My App"

## Window component
component Window:

    ## Window
    var gtkWindow: GtkWindow = nil

    ## Window title
    var title: string = ReactiveAppInfoTitle

    ## Called when the window is created
    method onPlatformCreate() =

        # Create window
        this.gtkWindow = gtk_window_new(GTK_WINDOW_TOPLEVEL)
        this.gtkWindow.gtk_window_set_application(gtkApplication)

        # Windows can only have a single child widget. Create a container widget
        this.gtkWidget = gtk_fixed_new()
        this.gtkWindow.gtk_container_add(this.gtkWidget)
        this.gtkWidget.gtk_widget_show()


    ## Called to mount the component
    method onPlatformMount() =

        # Present our window to the user
        gtk_window_present(this.gtkWindow)


    ## Called when the properties are updated
    method onPlatformUpdate() =

        # Update properties
        this.gtkWindow.gtk_window_set_title(this.title.cstring())


    ## Called to unmount the component
    method onPlatformUnmount() =

        # Just hide the window
        gtk_widget_hide(this.gtkWindow)


    ## Called when new properties are incoming and need to be copied in
    method updateProperties(newProps: BaseComponent) = 

        # Copy generic props
        let incomingProps = Window(newProps)
        this.title = incomingProps.title