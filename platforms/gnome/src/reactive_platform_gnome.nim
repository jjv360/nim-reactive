##
## Entry point fo rthe web platform plugin

import classes
import reactivepkg/plugins
import reactivepkg/components
import reactivepkg/config
import reactivepkg/componentTree
when defined(ReactivePlatformGnome):
    import std/threadpool
    import std/os
    import std/sequtils
    import reactive_platform_gnome/bindings/gtk

    # Export our classes
    import reactive_platform_gnome/base
    import reactive_platform_gnome/alerts
    import reactive_platform_gnome/components/button
    import reactive_platform_gnome/components/label
    import reactive_platform_gnome/components/view
    import reactive_platform_gnome/components/window
    import reactive_platform_gnome/layouts/absolute
    export base, alerts, button, label, view, window, absolute


    ## Prepare the app to be started
    proc prepareReactiveAppPlatform*() =
        discard


    ## Start the app
    proc startReactiveAppPlatform*() =

        # Get main component
        let componentID = ReactiveConfig.shared.get("gnome", "mainWindow")
        
        # Render the specified component tree
        let componentTree = ComponentTree.withRegisteredComponent(componentID)
