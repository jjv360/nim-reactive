##
## Entry point fo rthe web platform plugin

import classes
import reactivepkg/plugins
import reactivepkg/components
import reactivepkg/config
import reactivepkg/componentTree

## Plugin to provide the Web platform
class Win32Platform of ReactivePlugin:

    ## We provide the web platform
    method providesPlatformID(): string = "win32"

    ## Called on app startup
    method onPlatformStartup() =

        # Only do in JS mode
        when defined(js):

            # Platform starting!
            echo "[Win32 Platform] Starting!"

            # Get main component
            let componentID = ReactiveConfig.shared.get("win32", "mainWindow")
            
            # Render the specified component tree
            let componentTree = ComponentTree.withRegisteredComponent(componentID)


## Register our plugin
ReactivePlugins.shared.register(Win32Platform.new())
        

## Check if we're inside a Web platform build
when defined(ReactivePlatformWin32):
    
    # Register our platform as the active build platform
    ReactivePlugins.shared.activePlatformID = "win32"

    ## Base class for web layouts
    class Win32Layout of BaseLayout:

        ## Perform the layout
        method update(component: BaseComponent) = discard
        

    ## Base class for web components
    class Component of BaseComponent:


        # On create
        method onPlatformCreate() = discard

        
        # On mount
        method onPlatformMount() = discard


        ## Called when the layout changes
        method onPlatformLayout() = discard


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
        method onPlatformCreate() = discard


        ## Called when the component is mounted
        method onPlatformMount() = discard


        ## Called when the component is removed
        method onPlatformUnmount() = discard


        ## Called when the component is destroyed
        method onPlatformDestroy() = discard


    ## Plain view
    component View


    ## Label, displays some text
    component Label:

        # Style properties
        var textColor = ""

        # On create
        method onPlatformCreate() = discard

        # Called when the component is updated
        method onPlatformUpdate() = discard

    
    ## Button component
    component Button:

        # Button title
        var title = "Button"

        # Event: On click
        var onClick: proc() = nil

        # On create
        method onPlatformCreate() = discard


        # Called when the component is updated
        method onPlatformUpdate() = discard

    
    ##
    ## Absolute layout. This layout system simply moves the object to an absolute position within it's parent.
    class AbsoluteLayout of Win32Layout:

        ## Coordinates. Examples are: "32px", "50%".
        var x = ""
        var y = ""
        var width = ""
        var height = ""

        ## Perform the layout
        method update(component: BaseComponent) = discard
