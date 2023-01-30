##
## A simple notepad app

import ../src/reactive # import reactive
import std/os
import std/json
import std/asyncdispatch
import std/strutils
import classes


## Assets
const closeIcon = staticDataURI("assets/close.svg")
const openIcon = staticDataURI("assets/open.svg")
const saveIcon = staticDataURI("assets/save.svg")


## Menu item
class MenuItem of Component:

    ## Hovering state
    var isHovering = false

    ## Render
    method render(): Component = components:
        Div(
            width: "100%", 
            height: 88, 
            padding: 12,
            boxSizing: "border-box",
            borderBottom: "1px solid rgba(0, 0, 0, 0.1)", 
            # display: "flex", 
            # alignItems: "flex-start", 
            overflow: "hidden",
            backgroundColor: if this.props{"selected"}: "rgba(0, 0, 0, 0.05)" else: (if this.isHovering: "rgba(0, 0, 0, 0.05)" else: "transparent"),
            onClick: this.props{"onClick"},
            onMouseOver: proc() =
                this.isHovering = true
                this.renderAgain()
            ,
            onMouseOut: proc() =
                this.isHovering = false
                this.renderAgain()
            ,
        ):
            # Div(width: 32, height: 32, margin: 20, border: "1px solid red", flex: "0 0 auto")
            # Div(margin: 20, flex: "1 1 1px"):
            Div(text: this.props{"title"}, fontSize: 15, fontWeight: "bold", color: "black")
            Div(text: this.props{"text"}, fontSize: 13, color: "black", opacity: 0.4, marginTop: 5)


## Menubar Button
class BarIcon of Component:

    ## Hovering state
    var isHovering = false

    ## Render
    method render(): Component = components:
        Div(
            onClick: this.props{"onClick"},
            onMouseOver: proc() =
                this.isHovering = true
                this.renderAgain()
            ,
            onMouseOut: proc() =
                this.isHovering = false
                this.renderAgain()
            ,
            width: 40, 
            height: "100%",
            boxSizing: "border-box",
            backgroundImage: "url('" & this.props{"icon"} & "')",
            backgroundPosition: "center",
            backgroundSize: "16px 16px",
            backgroundRepeat: "no-repeat",
            backgroundColor: if this.isHovering: "rgba(0, 0, 0, 0.1)" else: "transparent"
        )


## Main app window
class App of Component:

    ## List of notes
    var notes: seq[string]

    ## Editing index
    var selectedNoteIndex = -1

    ## Called when the window is created
    method onMount() =

        # Load items from storage
        try:
            let notesPath = "NimReactiveNotes.json"
            let notesStr = readFile(notesPath)
            let notesJson = parseJson(notesStr)
            for note in notesJson:
                this.notes.add(note.getStr())
            echo "Loaded " & $notesJson.len & " notes"
        except CatchableError:
            echo "Unable to load existing notes"

        # this.notes = @[
        #     "Note 1\nText",
        #     "Note 2\nText 2",
        #     "Note 3\nText 3",
        #     "Note 4",
        #     "Note 5",
        # ]

        # Update UI
        this.renderAgain()


    ## Called when the window is closed
    method onUnmount() =

        # Save notes back
        echo "Saving notes"
        let notesPath = "NimReactiveNotes.json"
        let notesJson = %this.notes
        let notesStr = notesJson.pretty()
        writeFile(notesPath, notesStr)


    method render(): Component = components:

        # App Window
        Window(x: 50, y: 50, width: 800, height: 600, title: "Notepad"):

            # Background
            Div(backgroundColor: "#f5efc9", position: "absolute", top: 0, left: 0, width: "100%", height: "100%")

            # Header
            Div(backgroundColor: "rgba(0, 0, 0, 0.1)", position: "absolute", top: 0, left: 0, width: "100%", height: 40, display: "flex", alignItems: "center", borderBottom: "1px solid rgba(0, 0, 0, 0.1)"):
                BarIcon(icon: openIcon)
                BarIcon(icon: saveIcon)
                Div(flex: "1 1 auto")
                BarIcon(icon: closeIcon, onClick: proc() = this.unmount())

            # Note list
            Div(position: "absolute", top: 40, left: 0, width: 250, height: "calc(100% - 40px)", borderRight: "1px solid rgba(0, 0, 0, 0.1)", boxSizing: "border-box", overflowX: "hidden", overflowY: "scroll"):
                
                # Show empty info if no items found
                Div(display: if this.notes.len == 0: "block" else: "none", text: "No notes", padding: 80, color: "black", opacity: 0.2, textAlign: "center")

                # Show children
                mapIt(this.notes):
                    MenuItem(
                        title: it.split("\n").getOrDefault(0, "Untitled Note"), 
                        text: it.split("\n").getOrDefault(1, "(empty)"),
                        selected: this.selectedNoteIndex == idx,
                        onClick: proc() =
                            this.selectedNoteIndex = idx
                            this.renderAgain()
                    )

            # Note area
            TextArea(
                text: this.notes.getOrDefault(this.selectedNoteIndex), 
                display: if this.selectedNoteIndex >= 0 and this.selectedNoteIndex < this.notes.len: "block" else: "none", 
                position: "absolute", 
                top: 40, 
                right: 0, 
                width: "calc(100% - 250px)", 
                height: "calc(100% - 40px)", 
                border: "none", 
                background: "none", 
                outline: "none", 
                fontSize: 17, 
                lineHeight: 1.3,
                padding: 10,
                boxSizing: "border-box",
                onValue: proc(event: ReactiveEvent) =
                    this.notes[this.selectedNoteIndex] = event.value
                    this.renderAgain()
                    echo "UPDATED NOTE"
                ,
            )

            # No note selected message
            Div(
                text: "No note selected", 
                display: if this.selectedNoteIndex >= 0 and this.selectedNoteIndex < this.notes.len: "none" else: "block", 
                position: "absolute", 
                top: 40, 
                right: 0, 
                width: "calc(100% - 250px)", 
                height: "calc(100% - 40px)", 
                padding: 100,
                boxSizing: "border-box",
                color: "black",
                opacity: 0.25,
                fontSize: 24,
                textAlign: "center",
            )


# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        App