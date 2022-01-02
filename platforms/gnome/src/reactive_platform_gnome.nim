##
## Entry point for the Gnome platform plugin

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


    ## Called when the "activate" signal is sent
    proc onActivate(app: GApplication, user_data: pointer) =

        # Only do once
        echo "[Gnome Platform] Activate event sent."
        var isDone {.global.} = false
        if isDone: return
        isDone = true

        # Get main component
        let componentID = ReactiveConfig.shared.get("gnome", "mainWindow")
        
        # Render the specified component tree
        let componentTree = ComponentTree.withRegisteredComponent(componentID)


    ## Start the app
    proc startReactiveAppPlatform*() =

        # Ensure GTK is inited
        InternalInitGTK()

        # Register listeners for the application's signals
        discard g_signal_connect(gtkApplication, "activate", onActivate, nil)

        # Start the main app's event loop
        echo "[Gnome Platform] Event loop started."
        # gtk_main()
        let returnValue = g_application_run(gtkApplication, commandLineParams().len(), commandLineParams().mapIt(it.cstring()))
        echo "[Gnome Platform] Event loop stopped."

        # App is done, we should quit now with GTK's return value
        quit(returnValue)
