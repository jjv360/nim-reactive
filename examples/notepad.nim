##
## A simple notepad app

import ../src/reactive # import reactive
import std/os
import std/json
import classes


## Menu item
class MenuItem of Component:
    method render(): Component = components:
        Div(width: "100%", height: 88, borderBottom: "1px solid rgba(0, 0, 0, 0.1)", display: "flex", alignItems: "center", overflow: "hidden"):
            Div(width: 32, height: 32, margin: 20, border: "1px solid red", flex: "0 0 auto")
            Div(marginRight: 20, flex: "1 1 1px"):
                Div(text: this.props{"title"}.string, fontSize: 15, fontWeight: "bold", color: "black")
                Div(text: this.props{"text"}.string, fontSize: 13, color: "#333", marginTop: 5)



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
                Div(text: "Load")
                Div(text: "Save")
                Div(flex: "1 1 auto")
                Div(text: "Close", onClick: proc() = echo "CLicked close!")

            # Note list
            Div(position: "absolute", top: 50, left: 0, width: 320, height: "calc(100% - 50px)", borderRight: "1px solid rgba(0, 0, 0, 0.1)", overflowX: "hidden", overflowY: "scroll"):
                MenuItem(title: "Note 1", text: "Hello!")
                MenuItem(title: "Note 2", text: "Hello!")
                MenuItem(title: "Note 3", text: "Hello!")
                MenuItem(title: "Note 4", text: "asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj asdsdsadsad skjs kj sj ")
                MenuItem(title: "Note 1", text: "Hello!")
                MenuItem(title: "Note 2", text: "Hello!")
                MenuItem(title: "Note 3", text: "Hello!")
                MenuItem(title: "Note 1", text: "Hello!")
                MenuItem(title: "Note 2", text: "Hello!")
                MenuItem(title: "Note 3", text: "Hello!")
                MenuItem(title: "Note 1", text: "Hello!")
                MenuItem(title: "Note 2", text: "Hello!")
                MenuItem(title: "Note 3", text: "Hello!")
                MenuItem(title: "Note 1", text: "Hello!")
                MenuItem(title: "Note 2", text: "Hello!")
                MenuItem(title: "Note 3", text: "Hello!")


# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        App()