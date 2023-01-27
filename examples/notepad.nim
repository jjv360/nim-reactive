##
## A simple notepad app

# Crate info
import nimcrate
crate:
    id = "nimreactive.example.notepad"
    name = "Notepad"

    # Supported platforms
    target "windows"
    target "macosx"


import ../src/reactive# import reactive
import std/asyncdispatch
import classes

# Main app window
class MainWindow of Window:

    ## Called when the window is created
    method onMount() =

        echo "Main Window created!"


    ## Called when the window is closed
    method onUnmount() =

        echo "Main window closed"

    method render(): BaseComponent = components:
        BaseComponent


# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        MainWindow(x: 50, y: 50, width: 200, height: 200, title: "Notepad")
        # BaseComponent
        # BaseComponent()
        # BaseComponent(item = "value", second = 2)
        # BaseComponent(item: "value", second: 2)
        # BaseComponent(item: "value", second: 2):
        #     BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")
        # BaseComponent(item = "value", second = 2):
        #     BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")
        # BaseComponent:
        #     BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")

    proc t() {.async.} =
        while true:
            await sleepAsync(1000)
            echo "HERE"
    discard t()