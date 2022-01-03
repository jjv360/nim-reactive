import classes
import sequtils
import tables
import reactivepkg/components
import reactivepkg/componentTree
import ./bindings/gtk
import os


## Base class for web layouts
class GnomeLayout of BaseLayout:

    ## Perform the layout
    method update(component: BaseComponent) = discard
    

## Base class for all Gnome components
class Component of BaseComponent:

    ## GTK Widget
    var gtkWidget: GtkWidget = nil

    # Get most recent ancestor with a valid GtkWidget
    method parentWidget(): GtkWidget =

        # Go through heirarchy
        var item = this.parent
        while item != nil:

            # Check if this one has a HWND
            if item of Component and Component(item).gtkWidget != nil:
                return Component(item).gtkWidget

            # Nope, continue up the chain
            item = item.parent
            
        # Not found
        return nil


    ## Called to mount the component
    method onPlatformMount() =

        # Check if we have a widget to mount
        if this.gtkWidget == nil:
            return

        # Get parent widget
        let parentWidget = this.parentWidget()
        if parentWidget == nil:
            raiseAssert("Unable to find a parent widget to mount our GtkWidget to.")

        ## Add it
        parentWidget.gtk_container_add(this.gtkWidget)


    ## Called when the layout changes
    method onPlatformLayout() =

        # Call layout if it exists
        if this.layout != nil and this.layout of GnomeLayout:
            GnomeLayout(this.layout).update(this)


    ## Overridden by the app, this controls child components to render. By default just renders all children.
    method render(): BaseComponent =

        let g = Group.init()
        g.children = this.children
        return g

    
    ## Update UI
    method updateUi() = ComponentTreeNode(this.componentTreeNode).synchronize()


    ## Called to unmount the component
    method onPlatformUnmount() =

        # Check if we have a widget
        if this.gtkWidget == nil:
            return

        # Get parent widget
        let parentWidget = this.gtkWidget.gtk_widget_get_parent()
        if parentWidget == nil:
            return

        # Remove it
        parentWidget.gtk_container_remove(this.gtkWidget)


    ## Called to destroy the component
    method onPlatformDestroy() =

        # Check if we have a widget
        if this.gtkWidget == nil:
            return

        # We do, destroy it
        this.gtkWidget.gtk_widget_destroy()
        this.gtkWidget = nil



## Initialize the GTK app, this must be called before any GTK functions are called.
var gtkApplication*: GtkApplication = nil
proc InternalInitGTK*() =

    # Only do once
    if gtkApplication != nil:
        return

    # Check if application ID is valid
    const ReactiveAppInfoAppID {.strdefine.} = ""
    if ReactiveAppInfoAppID == "": raiseAssert("Missing app ID. Please check the config in your .nimble file")
    elif not g_application_id_is_valid(ReactiveAppInfoAppID): raiseAssert("The app ID '" & ReactiveAppInfoAppID & "' specified in your .nimble file is not valid. Check the definition of g_application_id_is_valid() for more info.")

    # Init the application
    echo "[Gnome Platform] Initializing GTK"
    gtk_init(commandLineParams().len(), commandLineParams().mapIt(it.cstring()))
    gtkApplication = gtk_application_new(ReactiveAppInfoAppID, FLAGS_NONE)

    # Make it the default application for this process
    g_application_set_default(gtkApplication)

