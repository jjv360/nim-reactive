import std/tables
import std/strutils
import std/json
import classes
import ../shared/basecomponent
import ../shared/mounts
import ../shared/webview_bridge
import ../shared/htmloutput
import ../shared/htmlcomponents
import ./native/corefoundation
import ./native/foundation
import ./native/appkit
import ./native/webkit


##
## This class represents an onscreen window.
class Window of WebViewBridge:

    ## Native window
    var nativeWindow: NSWindow

    ## Web view
    var webview: WKWebView

    ## Called when this component is mounted
    method onNativeMount() =

        # Create window
        let rect = NSRect(origin: CGPoint(x: 500, y: 500), size: CGSize(width: 800, height: 600))
        this.nativeWindow = NSWindow.alloc().initWithContentRect(rect)
        this.nativeWindow.title = this.props{"title"}.string

        # Create web view configuration
        let configuration = WKWebViewConfiguration.alloc().init()
        configuration.userContentController = WKUserContentController.alloc().init()

        # Register JavaScript callback
        configuration.userContentController.addScriptMessageHandler(WKScriptMessageHandler.create(proc(text: NSString) =
            this.onJsCallback(text)
        ), "nimreactiveCallback")

        # Create web view and attach to the window
        this.webview = WKWebView.alloc().initWithFrame(rect, configuration)
        this.nativeWindow.contentView = NSView(this.webview)

        # Show window
        this.nativeWindow.makeKeyAndOrderFront()
        this.nativeWindow.makeMainWindow()

        # Bring app to front
        NSApplication.sharedApplication.activateIgnoringOtherApps()

        # Start the bridge
        # this.bridge = WebViewBridge.init()
        # this.bridge.start()

        # Load web content
        # this.webview.loadHTMLString(this.getHTMLBoilerplate())

        # Add listener for when the window is closed
        discard NSNotificationCenter.defaultCenter.addObserverForName(NSWindowWillCloseNotification, callback = proc(notification: NSNotification) =
            
            # Check if it's our window that was closed
            if notification.object.pointer == this.nativeWindow.pointer:
                this.onWindowClosed()
            
        )


    ## Called on unmount
    method onNativeUnmount() = 
        
        # Close and remove the window
        if this.nativeWindow.pointer != nil:
            this.nativeWindow.close()


    ## Called to inject JS into the page
    method injectJS(js: string) =

        # Do it
        this.webview.evaluateJavaScript(js)


    ## Called when the JS side sends us an event
    method onJsCallback(str: string) =

        # Parse it
        let msg = parseJson(str)

        # Find the target component
        let targetID = msg{"elementID"}.getStr()
        let element = this.renderedElements.getOrDefault(targetID, nil)
        if element == nil: return
        let component = HTMLComponent(element.component)
        
        # Notify it
        component.onJsEvent(msg{"name"}.getStr(), msg{"data"}.getStr())


    ## Called by the system when the user closes the window
    method onWindowClosed() =

        # Unmount it
        ReactiveMountManager.shared.unmount(this)