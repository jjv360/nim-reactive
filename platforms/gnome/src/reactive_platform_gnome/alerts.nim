import ./bindings/gtk
import ./base

# System alert dialog icons
type AlertIconType* = enum information, warning, question

# System alert dialog
proc alert*(text: string, title: string = "", icon: AlertIconType = information) =

    # Ensure GTK is set up, just in case the user opens an alert box before the app starts
    InternalInitGTK()

    # Create dialog
    var dialog = gtk_message_dialog_new(parent=nil, flags={}, type=GTK_MESSAGE_INFO, buttons=GTK_BUTTONS_OK, message_format=text)

    # Set title
    gtk_window_set_title(dialog, title)

    # Run the dialog
    discard gtk_dialog_run(dialog)

    # Done, destroy it
    gtk_widget_destroy(dialog)