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
class App of Component:

    ## Called when the window is created
    method onMount() =

        echo "Main Window created!"
        this.printViewHeirarchy()


    ## Called when the window is closed
    method onUnmount() =

        echo "Main window closed"

    method render(): Component = components:

        # App Window
        Window(x: 50, y: 50, width: 200, height: 200, title: "Notepad"):

            # Background
            Div(backgroundColor: "#222", position: "absolute", top: 0, left: 0, width: "100%", height: "100%")

            # Header
            Div(backgroundColor: "#333", position: "absolute", top: 0, left: 0, width: "100%", height: 50, display: "flex", alignItems: "center")


# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        App()

    # proc t() {.async.} =
    #     while true:
    #         await sleepAsync(1000)
    #         echo "HERE"
    # discard t()