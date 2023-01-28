import classes
import ../shared/basecomponent
import webview

##
## This class represents an onscreen window that can render children as HTML.
class Window of Component:

    ## WebView
    var webview: Webview

    ## Called when this component is mounted
    method onNativeMount() =

        ## Create web view
        echo "[NimReactive] Creating new WebView window"
        this.webview = newWebView()
        while this.webview.loop(1) == 0:
            echo "H|"



    ## Called on unmount
    method onNativeUnmount() = 
        echo "removing weview"