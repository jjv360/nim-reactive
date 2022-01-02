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


    ## Called when the component is created
    method onPlatformCreate() = discard

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


## Initialize the GTK app, this must be called before any GTK functions are called.
var gtkApplication: GtkApplication = nil
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
