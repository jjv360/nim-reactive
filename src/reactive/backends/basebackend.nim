##
## Backends are used to display HTML windows and interact with the system.

import classes

## Alert icon types
type ReactiveDialogIcon* = enum Info, Warning, Error, Question

## Generic backend class
class ReactiveBackend:

    # Backend ID
    var id = ""

    # Check if supported
    method supported(): bool = false

    # Load the backend. This is called before the app's reactiveStart:
    method load() = discard

    # Start the backend. This is called after the app's reactiveStart: and most likely will never exit
    method start() = discard

    # Create a new window
    method createWindow() = discard

    # Show an alert
    method alert(text: string, title: string = "", icon: ReactiveDialogIcon = Info) =

        # Just log to console
        let txt = if title == "": text else: title & ": " & text
        echo txt 

