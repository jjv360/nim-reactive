import classes
import std/oids
import std/strutils
import ./basecomponent
import ./htmloutput

## JavaScript bridge code
const bridgeJsCode = staticRead("webview_bridge.js")

## Escape JavaScriopt string, assuming it's injected with single quotation marks (')
proc jsSanitize(input: string): string =
    return input.replace("'", "\\'").replace("\n", "\\n")

##
## Communicates between a WebView and the native app
class WebViewBridge of BaseComponent:

    ## List of rendered HTML components
    var renderedHtml: seq[ReactiveHTMLOutput]

    ## True if we've done the first injection
    var hasDoneFirstInject = false


    ## Called to inject JS into the page
    method injectJS(js: string) = raiseAssert("WebViewBridge.injectJS() must be implemented by subclasses.")


    ## Called when a child HTMLComponent is added/updated
    method onHTMLChildUpdate(child: BaseComponent, html: ReactiveHTMLOutput) =

        # Do first injection
        if not this.hasDoneFirstInject:
            this.hasDoneFirstInject = true

            # Inject
            this.injectJS("""
            
                // Add default styles
                var elem = document.createElement('style')
                elem.innerText = "
                    html, body {
                        margin: 0px;
                        padding: 0px;
                        cursor: default;
                        user-select: none;
                        -webkit-user-select: none;
                        overflow: hidden;
                    }
                "
                document.body.appendChild(elem)
            
            """)
        
        # Generate JS changes
        let js = """

            // Find it
            var elem = document.getElementById('""" & html.privateTagID.jsSanitize() & """')
            if (!elem) {

                // Not found, create it
                elem = document.createElement('""" & html.tagName.jsSanitize() & """')
                elem.id = '""" & html.privateTagID.jsSanitize() & """'
                document.body.appendChild(elem)

            }

            // Update details
            elem.className = '""" & html.tagClass.jsSanitize() & """'
            elem.style.cssText = '""" & html.css.jsSanitize() & """'

        """

        # Inject it
        echo js
        this.injectJS(js)


    ## Called when a child HTMLComponent is removed
    method onHTMLChildRemove(child: BaseComponent, html: ReactiveHTMLOutput) =
        raiseAssert("WebViewBridge.onHTMLChildRemove() must be implemented by subclasses.")


## Get the nearest bridge component for a component
proc nearestWebBridge*(component: BaseComponent): WebViewBridge =

    # Stop if nil
    if component == nil:
        return nil

    # Try this one
    try:

        # Succeeds if it's a WebView
        return WebViewBridge(component)

    except ObjectConversionDefect:

        # Nope, try it's parent
        return component.renderedParent.nearestWebBridge()





# ##
# ## Communicates between a WebView and the native app
# when defined(js):

#     ##
#     ## Communicates between a WebView and the native app on JS
#     class WebViewBridge of WebViewBridgeBase


# else:

#     import mummy
#     import mummy/routers
#     # import std/threads

#     ##
#     ## Communicates between a WebView and the native app on JS
#     class WebViewBridge of WebViewBridgeBase:

#         ## WebSocket server
#         var server: Server

#         ## Server thread
#         var serverThread: Thread[WebViewBridge]

#         ## Start the bridge
#         method start() =

#             # Create router with a single handler
#             var router: Router
#             router.get("/", proc(request: Request) =
#                 let websocket = request.upgradeToWebSocket()
#                 websocket.send("Hello world from WebSocket!")
#             )

#             # Create server
#             this.server = newServer(router)
#             echo "Serving on http://localhost:8080"

#             # Wait until server is ready
#             # this.server.waitUntilReady()

#             # Start the server on a new thread
#             this.serverThread.createThread(proc(this: WebViewBridge) {.thread, nimcall.} =
#                 {.gcsafe.}:     # <-- Yikes
#                     this.server.serve(Port(8080))
#             , this)


#         ## Shut down the bridge
#         method destroy() =

#             # Stop the server
#             if this.server != nil:
#                 this.server.close()
