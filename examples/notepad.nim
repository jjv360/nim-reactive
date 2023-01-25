##
## A simple notepad app

# Crate info
import nimcrate
crate:
    id = "nimreactive.example.notepad"
    name = "Notepad"


import reactive
import classes

# Main app window
class MainWindow of Window:

    discard

# Start the app
reactiveStart: 
    
    # Create main window
    mount:
        MainWindow(x: 50, y: 50, width: 200, height: 200)