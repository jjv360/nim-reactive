##
## A simple notepad app

import ../src/reactive # import reactive
import std/os
import std/json
import std/asyncdispatch
import classes


## Menu item
class MenuItem of Component:
    method render(): Component = components:
        Div(width: "100%", height: 88, borderBottom: "1px solid rgba(0, 0, 0, 0.1)", display: "flex", alignItems: "center", overflow: "hidden"):
            Div(width: 32, height: 32, margin: 20, border: "1px solid red", flex: "0 0 auto")
            Div(marginRight: 20, flex: "1 1 1px"):
                Div(text: this.props{"title"}, fontSize: 15, fontWeight: "bold", color: "black")
                Div(text: this.props{"text"}, fontSize: 13, color: "#333", marginTop: 5)


## Menubar Button
class BarIcon of Component:

    ## Hovering state
    var isHovering = false

    ## RenderReactivePropertyItem(stringValue: this.props{"text"}, isString: true)
    method render(): Component = components:
        Div(
            text: this.props{"text"}, 
            onClick: this.props{"onClick"},
            onMouseOver: proc() =
                this.isHovering = true
                this.renderAgain()
            ,
            onMouseOut: proc() =
                this.isHovering = false
                this.renderAgain()
            ,
            padding: "17px 12px", 
            height: "100%",
            boxSizing: "border-box",
            backgroundColor: if this.isHovering: "rgba(0, 0, 0, 0.1)" else: "transparent"
        )


## Main app window
class App of Component:

    ## List of notes
    var notes: seq[string] = @[
        "Note 1\nHello!",
        "Note 2\nHi!"
    ]

    ## Called when the window is created
    method onMount() =

        # Load items from storage
        try:
            let notesPath = getHomeDir() / "NimReactiveNotes.json"
            let notesStr = readFile(notesPath)
            let notesJson = parseJson(notesStr)
            for note in notesJson:
                this.notes.add(note.getStr())
        except CatchableError:
            echo "Unable to load existing notes"

        # Update UI
        this.renderAgain()


    ## Called when the window is closed
    method onUnmount() =

        echo "App exited"


    method render(): Component = components:

        # App Window
        Window(x: 50, y: 50, width: 200, height: 200, title: "Notepad"):

            # Background
            Div(backgroundColor: "#f5efc9", position: "absolute", top: 0, left: 0, width: "100%", height: "100%")

            # Header
            Div(backgroundColor: "rgba(0, 0, 0, 0.1)", position: "absolute", top: 0, left: 0, width: "100%", height: 50, display: "flex", alignItems: "center", borderBottom: "1px solid rgba(0, 0, 0, 0.1)"):
                BarIcon(text: "Load")
                BarIcon(text: "Save")
                Div(flex: "1 1 auto")
                BarIcon(text: "Close", onClick: proc() = this.unmount())

            # Note list
            Div(position: "absolute", top: 50, left: 0, width: 320, height: "calc(100% - 50px)", borderRight: "1px solid rgba(0, 0, 0, 0.1)", overflowX: "hidden", overflowY: "scroll"):
                
                # Show empty info if no items found
                Div(text: "No notes", padding: 80, color: "black", opacity: 0.2, textAlign: "center")


# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        App