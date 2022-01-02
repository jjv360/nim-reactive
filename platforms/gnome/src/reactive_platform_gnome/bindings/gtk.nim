##
## Bindings for the GTK functions that we use


# GtkApplication
type GtkApplication* = pointer
type GApplicationFlags* {. pure .} = enum FLAGS_NONE = 0, IS_SERVICE = 1 shl 0, IS_LAUNCHER = 1 shl 1, HANDLES_OPEN = 1 shl 2, HANDLES_COMMAND_LINE = 1 shl 3, SEND_ENVIRONMENT = 1 shl 4, NON_UNIQUE = 1 shl 5, CAN_OVERRIDE_APP_ID = 1 shl 6, ALLOW_REPLACEMENT = 1 shl 7, REPLACE = 1 shl 8
proc g_application_id_is_valid*(application_id: cstring): bool {. importc, header: "<gtk/gtk.h>" .}
proc gtk_init*(argc: int, argv: seq[cstring]) {. importc, header: "<gtk/gtk.h>" .}
proc gtk_application_new*(application_id: cstring, flags: GApplicationFlags): GtkApplication {. importc, header: "<gtk/gtk.h>" .}

# GtkWidget
type GtkWidget* = pointer
proc gtk_widget_destroy*(self: GtkWidget) {. importc, header: "<gtk/gtk.h>" .}

# GtkWindow
type GtkWindow* = pointer
proc gtk_window_set_title*(window: GtkWindow, title: cstring) {. importc, header: "<gtk/gtk.h>" .}

# GtkDialog
type GtkDialog* = pointer
type GtkMessageType* {. pure .} = enum GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING, GTK_MESSAGE_QUESTION, GTK_MESSAGE_ERROR, GTK_MESSAGE_OTHER
type GtkButtonsType* {. pure .} = enum GTK_BUTTONS_NONE, GTK_BUTTONS_OK, GTK_BUTTONS_CLOSE, GTK_BUTTONS_CANCEL, GTK_BUTTONS_YES_NO, GTK_BUTTONS_OK_CANCEL
type GtkDialogFlags* {. pure .} = enum GTK_DIALOG_MODAL = 1 shl 0, GTK_DIALOG_DESTROY_WITH_PARENT = 1 shl 1, GTK_DIALOG_USE_HEADER_BAR = 1 shl 2
type GtkResponseType* {. pure .} = enum GTK_RESPONSE_HELP = -11, GTK_RESPONSE_APPLY = -10, GTK_RESPONSE_NO = -9, GTK_RESPONSE_YES = -8, GTK_RESPONSE_CLOSE = -7, GTK_RESPONSE_CANCEL = -6, GTK_RESPONSE_OK = -5, GTK_RESPONSE_DELETE_EVENT = -4, GTK_RESPONSE_ACCEPT = -3, GTK_RESPONSE_REJECT = -2, GTK_RESPONSE_NONE = -1
proc gtk_message_dialog_new*(parent: GtkWindow, flags: set[GtkDialogFlags], `type`: GtkMessageType, buttons: GtkButtonsType, message_format: cstring): GtkWidget {. importc, header: "<gtk/gtk.h>" .}
proc gtk_dialog_run*(self: GtkDialog): GtkResponseType {. importc, header: "<gtk/gtk.h>" .}
