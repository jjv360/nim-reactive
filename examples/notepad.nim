##
## A simple notepad app

import reactive
import nimcrate
import classes

# Crate info
crate:
    id = "nimreactive.example.notepad"
    name = "Notepad"

# Main app window
class MainWindow of ReactiveWindow:

    discard

# Start the app
reactiveStart:
    
    # Create main window
    MainWindow.init().show()