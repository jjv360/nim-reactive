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




# ## Represents text inside an element
# class CustomHtmlComponent of HTMLComponent:

#     ## Returns raw HTML component information
#     method renderHTML(): ReactiveHTMLOutput =

#         # Create component output
#         let html = ReactiveHTMLOutput.init()
#         html.tagName = "div"
#         html.setCSSFromProps(this.props)
        
#         # JS inject
#         html.jsOnMount = """
#             var count = 0
#             setInterval(function() {
#                 count += 1
#                 element.innerText = "Counter: " + count
#             }, 250)
#         """

#         # Done
#         return html



# Main app window
class App of Component:

    ## Called when the window is created
    method onMount() =

        echo "App started!"
        this.printViewHeirarchy()


    ## Called when the window is closed
    method onUnmount() =

        echo "App exited"

    method render(): Component = components:

        # App Window
        Window(x: 50, y: 50, width: 200, height: 200, title: "Notepad"):

            # Background
            Div(backgroundColor: "#181818", position: "absolute", top: 0, left: 0, width: "100%", height: "100%")

            # Header
            Div(backgroundColor: "#222", position: "absolute", top: 0, left: 0, width: "100%", height: 50, display: "flex", alignItems: "center", boxShadow: "0px 0px 4px rgba(0, 0, 0, 0.2)"):
                Div(text: "Load")
                Div(text: "Save")
                Div(flex: "1 1 auto")
                Div(text: "Close")


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