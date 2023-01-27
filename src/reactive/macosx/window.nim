import std/tables
import classes
import ./dialogs
import ../shared/basecomponent
import ../shared/mounts
import ./native/corefoundation
import ./native/appkit
import ./native/webkit
import ../shared/webview_bridge


##
## This class represents an onscreen window.
class Window of BaseComponent:

    ## Native window
    var nativeWindow: NSWindow

    ## Web view
    var webview: WKWebView

    ## Web view bridge
    var bridge: WebViewBridge = WebViewBridge.init()

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

        # Load web content
        this.webview.loadHTMLString(this.bridge.getHTMLBoilerplate())

        # Show window
        this.nativeWindow.makeKeyAndOrderFront()
        this.nativeWindow.makeMainWindow()

        # Bring app to front
        NSApplication.sharedApplication.activateIgnoringOtherApps()


    ## Called on unmount
    method onNativeUnmount() = 
        echo "unmount"