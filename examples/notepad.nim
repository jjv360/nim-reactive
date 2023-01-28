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


import ../src/reactive # import reactive
import std/asyncdispatch
import classes

# Main app window
class MainWindow of BaseComponent:

    ## Called when the window is created
    method onMount() =

        echo "Main Window created!"
        this.printViewHeirarchy()


    ## Called when the window is closed
    method onUnmount() =

        echo "Main window closed"

    method render(): BaseComponent = components:

        # Background
        Div(backgroundColor: "#222", position: "absolute", top: 0, left: 0, width: "100%", height: "100%")

        # Header
        Div(backgroundColor: "#333", position: "absolute", top: 0, left: 0, width: "100%", height: 50, )


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

    # proc t() {.async.} =
    #     while true:
    #         await sleepAsync(1000)
    #         echo "HERE"
    # discard t()