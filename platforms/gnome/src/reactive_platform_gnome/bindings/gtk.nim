##
## Bindings for the GTK functions that we use
## 
## Some reference documentation can be found here:
##  https://people.gnome.org/~shaunm/girdoc/C/index.html
##  https://www.freedesktop.org/software/gstreamer-sdk/data/docs/2012.5/gobject/gobject-Signals.html
##  https://stackoverflow.com/questions/41892302/what-is-the-preferred-way-to-write-gtk-applications

import macros

## Macro which attaches pragmes to the functions for importing from GTK
macro fromGTK(body: untyped) =

    # Go through all statements
    for idx, item in body:

        # Check for function definitions
        if item.kind != nnkProcDef:
            continue

        # Insert pragma definition
        item.pragma = parseStmt("""{. importc, header: "<gtk/gtk.h>" .}""")[0]

    # Done
    return body


# Apply import header to all
fromGTK:

    # Core
    proc gtk_main*()

    # GSignal
    type GCallback* = pointer   # <-- Function pointer, signal type determines the number of args, etc, so we can't define it properly beforehand
    type GHandlerID* = uint64
    proc g_signal_connect*(instance: pointer, detailed_signal: cstring, c_handler: GCallback, data: pointer): GHandlerID

    # GApplication
    type GApplication* = pointer
    proc g_application_run*(app: GApplication, argc: int, argv: seq[cstring]): int
    proc g_application_set_default*(app: GApplication)

    # GtkApplication -> GApplication
    type GtkApplication* = GApplication
    type GApplicationFlags* {. pure .} = enum FLAGS_NONE = 0, IS_SERVICE = 1 shl 0, IS_LAUNCHER = 1 shl 1, HANDLES_OPEN = 1 shl 2, HANDLES_COMMAND_LINE = 1 shl 3, SEND_ENVIRONMENT = 1 shl 4, NON_UNIQUE = 1 shl 5, CAN_OVERRIDE_APP_ID = 1 shl 6, ALLOW_REPLACEMENT = 1 shl 7, REPLACE = 1 shl 8
    proc g_application_id_is_valid*(application_id: cstring): bool
    proc gtk_init*(argc: int, argv: seq[cstring])
    proc gtk_application_new*(application_id: cstring, flags: GApplicationFlags): GtkApplication

    # GtkWidget
    type GtkWidget* = pointer
    proc gtk_widget_destroy*(self: GtkWidget)
    proc gtk_widget_get_parent*(self: GtkWidget): GtkWidget
    proc gtk_widget_show*(self: GtkWidget)
    proc gtk_widget_hide*(self: GtkWidget)
    proc gtk_widget_set_size_request*(self: GtkWidget, x: int, y: int)

    # GtkContainer -> GtkWidget
    type GtkContainer* = pointer
    proc gtk_container_add*(self: GtkContainer, widget: GtkWidget)
    proc gtk_container_remove*(self: GtkContainer, widget: GtkWidget)

    # GtkWindow -> GtkBin -> GtkContainer -> GtkWidget
    type GtkWindow* = pointer
    type GtkWindowType* {. pure .} = enum GTK_WINDOW_TOPLEVEL, GTK_WINDOW_POPUP
    proc gtk_window_set_title*(self: GtkWindow, title: cstring)
    proc gtk_window_new*(`type`: GtkWindowType): GtkWidget
    proc gtk_window_set_application*(self: GtkWindow, application: GtkApplication)
    proc gtk_window_present*(self: GtkWindow)

    # GtkDialog
    type GtkDialog* = pointer
    type GtkMessageType* {. pure .} = enum GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING, GTK_MESSAGE_QUESTION, GTK_MESSAGE_ERROR, GTK_MESSAGE_OTHER
    type GtkButtonsType* {. pure .} = enum GTK_BUTTONS_NONE, GTK_BUTTONS_OK, GTK_BUTTONS_CLOSE, GTK_BUTTONS_CANCEL, GTK_BUTTONS_YES_NO, GTK_BUTTONS_OK_CANCEL
    type GtkDialogFlags* {. pure .} = enum GTK_DIALOG_MODAL = 1 shl 0, GTK_DIALOG_DESTROY_WITH_PARENT = 1 shl 1, GTK_DIALOG_USE_HEADER_BAR = 1 shl 2
    type GtkResponseType* {. pure .} = enum GTK_RESPONSE_HELP = -11, GTK_RESPONSE_APPLY = -10, GTK_RESPONSE_NO = -9, GTK_RESPONSE_YES = -8, GTK_RESPONSE_CLOSE = -7, GTK_RESPONSE_CANCEL = -6, GTK_RESPONSE_OK = -5, GTK_RESPONSE_DELETE_EVENT = -4, GTK_RESPONSE_ACCEPT = -3, GTK_RESPONSE_REJECT = -2, GTK_RESPONSE_NONE = -1
    proc gtk_message_dialog_new*(parent: GtkWindow, flags: set[GtkDialogFlags], `type`: GtkMessageType, buttons: GtkButtonsType, message_format: cstring): GtkWidget
    proc gtk_dialog_run*(self: GtkDialog): GtkResponseType

    # GtkButton -> GtkWidget
    type GtkButton* = GtkWidget
    proc gtk_button_new*(): GtkButton
    proc gtk_button_set_label*(self: GtkButton, label: cstring)

    # GtkFixed -> GtkContainer -> GtkWidget
    type GtkFixed* = GtkContainer
    proc gtk_fixed_new*(): GtkFixed
    proc gtk_fixed_move*(self: GtkFixed, child: GtkWidget, x: int, y: int)
    proc gtk_fixed_put*(self: GtkFixed, child: GtkWidget, x: int, y: int)

