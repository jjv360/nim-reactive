##
## Entry point fo rthe web platform plugin

import classes
import ../plugins
import ../components
import ../config
import ../componentTree

# JS specific imports
when defined(js):
    import std/dom except Window, class

    # I'm importing native JS references directly instead of using std/dom, since that library seems to cause all
    # sorts of issues with common names, like Window, class, etc, and Nim always defaults to using those for some reason.
    # proc innerText(elem: Element): string {. importjs: "#.innerText" .}
    # proc `innerText=`(elem: Element, content: string) {. importjs: "function(txt) { #.innerText = @ }" .}

## Plugin to provide the Web platform
class WebPlatform of ReactivePlugin:

    ## We provide the web platform
    method providesPlatformID(): string = "web"

    ## Called on app startup
    method onPlatformStartup() =

        # Only do in JS mode
        when defined(js):

            # Platform starting!
            echo "[Web Platform] Starting!"

            # Get main component
            let componentID = ReactiveConfig.shared.get("web", "mainWindow")
            
            # Render the specified component tree
            let componentTree = ComponentTree.withRegisteredComponent(componentID)


## Register our plugin
ReactivePlugins.shared.register(WebPlatform.new())
        

## Check if we're inside a Web platform build
when defined(js) and defined(ReactivePlatformWeb):
    
    # Register our platform as the active build platform
    ReactivePlugins.shared.activePlatformID = "web"

    ## Base class for web components
    class Component of BaseComponent:

        # DOM container for this item
        var element: Element = nil

        # Mark this as a web component
        var platformSpecificType = "web"

        ## Get component as instance of Component
        # method fromBase(base: BaseComponent): Component {.static.} =
        #     if base.platformSpecificType == "web": return Component(base)
        #     else: return nil

        # Get most recent ancestor with a valid element
        method parentElement(): Element =
            if this.parent != nil and Component(this.parent).element != nil: return Component(this.parent).element
            elif this.parent != nil: return Component(this.parent).parentElement()
            else: raiseAssert("No parent element found.")


        # On create
        method onPlatformCreate() =

            # Create element
            this.element = document.createElement("div")

        
        # On mount
        method onPlatformMount() =
        
            # Mount to parent element
            this.parentElement.appendChild(this.element)


        # On unmount
        method onPlatformUnmount() = echo "unmounting"

        ## Overridden by the app, this controls child components to render. By default just renders all children.
        method render(): BaseComponent =

            let g = Group.init()
            g.children = this.children
            return g

        ## Update UI
        method updateUi() = ComponentTreeNode(this.componentTreeNode).synchronize()


    ## Window component
    component Window:

        ## Called when the component is created
        method onPlatformCreate() =

            # Create the DOM element immediately
            this.element = document.createElement("div")
            this.element.className = "reactive-web-window"
            this.element.setAttribute("style", "position: absolute; top: 0px; left: 0px; width: 100%; height: 100%; overflow: hidden; ")


        ## Called when the component is mounted
        method onPlatformMount() =

            # Attach window to the screen
            document.body.appendChild(this.element)


        ## Called when the component is removed
        method onPlatformUnmount() =

            # Remove window element
            echo "[Web] Window unmounted"
            document.body.removeChild(this.element)


        ## Called when the component is destroyed
        method onPlatformDestroy() =

            # Remove dom element from memory
            echo "[Web] Window deleted"
            this.element = nil


    ## Plain view
    component View


    ## Label, displays some text
    component Label:

        # Style properties
        var textColor = ""

        # On create
        method onPlatformCreate() =

            # Create element
            this.element = document.createElement("div")
            this.element.setAttribute("style", "display: inline-block; ")

        # Called when the component is updated
        method onPlatformUpdate() =

            # Update text
            for child in this.children:
                if child.className == "Text":
                    let text = Text(child).internalTextContent
                    this.element.innerText = text
                    break

    
    ## Button component
    component Button:

        # Button title
        var title = "Button"

        # Event: On click
        var onClick: proc() = nil

        # On create
        method onPlatformCreate() =

            # Create element
            this.element = document.createElement("button")


        # Called when the component is updated
        method onPlatformUpdate() =

            # Update text
            this.element.innerText = this.title

            # Register events
            if this.onClick != nil: this.element.onClick = proc(_: Event) = this.onClick()
            


## Called when being run as a binary
when isMainModule:
    import ../utils
    import std/os
    import std/osproc
    import std/strutils

    # Fetch command line
    let args = processCommandLine()

    # Fetch input file
    let appEntryPath = absoluteInputFilePath(args)

    # Begin building
    echo "Building app for web: " & appEntryPath
    let returnCode = startProcess("nim", workingDir=absolutePath(appEntryPath / ".."), options={poUsePath, poParentStreams}, args=[
        "js", 
        "--app:gui",
        "--define:release",
        "--define:ReactivePlatformWeb",
        "--define:ReactiveAppEntryFile:" & appEntryPath,
        # "--define:debugclasses",
        "--out:" & absolutePath(appEntryPath / ".." / "dist" / "app.js"),
        appEntryPath
    ]).waitForExit()

    # Write a wrapper HTML file
    writeFile(appEntryPath / ".." / "dist" / "app.html", """
        <!DOCTYPE html>
        <html>
        <head>
            <title>App Title</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        </head>
        <body>

            <!-- Web app default styling -->
            <style>
                html, body {
                    margin: 0px;
                    padding: 0px;
                }
            </style>

            <!-- App code -->
            <script src="app.js"></script>
            
        </body>
        </html>
    """.strip())