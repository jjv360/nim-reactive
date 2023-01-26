##
## A simple notepad app

# Crate info
import nimcrate
crate:
    id = "nimreactive.example.notepad"
    name = "Notepad"


import ../src/reactive# import reactive
import classes

# Main app window
class MainWindow of Window:

    method render(): BaseComponent = components:
        BaseComponent

# Start the app
reactiveStart: 
    
    # Create main window
    reactiveMount:
        MainWindow(x: 50, y: 50, width: 200, height: 200)
        BaseComponent
        BaseComponent()
        BaseComponent(item = "value", second = 2)
        BaseComponent(item: "value", second: 2)
        BaseComponent(item: "value", second: 2):
            BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")
        BaseComponent(item = "value", second = 2):
            BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")
        BaseComponent:
            BaseComponent(second: "another", item: 1, doubleer: 2, cb: proc() = echo "Hi")