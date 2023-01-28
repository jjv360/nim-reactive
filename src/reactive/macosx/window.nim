import std/tables
import std/strutils
import classes
import ../shared/basecomponent
import ../shared/mounts
import ../shared/webview_bridge
import ../shared/htmloutput
import ./native/corefoundation
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

        # Create web view
        let configuration = WKWebViewConfiguration.alloc().init()
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


    ## Called on unmount
    method onNativeUnmount() = 
        echo "unmount"


    ## Called to inject JS into the page
    method injectJS(js: string) =

        # Do it
        this.webview.evaluateJavaScript(js)