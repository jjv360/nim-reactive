import classes
import std/oids
import std/strutils
import std/tables
import std/json
import ./basecomponent
import ./htmloutput
import ./basewebcomponent


## Code to inject on WebView startup ... other libraries can add to this list when they're imported to include their own code
var reactiveJsInject*: seq[string] = @[

    # Our own code
    """
            
        // Add default styles
        var elem = document.createElement('style')
        elem.innerText = `
            html, body {
                margin: 0px;
                padding: 0px;
                cursor: default;
                user-select: none;
                -webkit-user-select: none;
                overflow: hidden;
                font-family: Arial, sans-serif;
            }
        `
        document.body.appendChild(elem)

        // Prevent right click menu
        document.addEventListener('contextmenu', function(e) {
            if (e.target.tagName.toLowerCase() == "textarea") return
            e.preventDefault()
        })

        // Attach function to send events back to native code
        window.nimreactiveEmit = function(elementID, name, data) {

            // Convert data to string
            if (typeof data == 'object')
                data = JSON.stringify(data)

            // Send it to WebKit (Apple)
            if (window.webkit?.messageHandlers?.nimreactiveCallback) window.webkit.messageHandlers.nimreactiveCallback.postMessage(JSON.stringify({
                elementID: elementID,
                name: name,
                data: data
            }))

            // Send it to WebView2 (Microsoft)
            if (window.chrome?.webview) window.chrome.webview.postMessage(JSON.stringify({
                elementID: elementID,
                name: name,
                data: data
            }))

        }
            
    """

]


##
## Communicates between a WebView and the native app
class WebViewBridge of NativeComponent:

    ## List of rendered HTML components
    var renderedElements: Table[string, ReactiveHTMLOutput]

    ## True if we've done the first injection
    var hasDoneFirstInject = false

    ## Called to inject JS into the page
    method injectJS(js: string) = raiseAssert("WebViewBridge.injectJS() must be implemented by subclasses.")

    ## Called to do the first JS injection
    method doFirstInjection() =

        # Stop if already done
        if this.hasDoneFirstInject: return
        this.hasDoneFirstInject = true

        # Inject
        this.injectJS(reactiveJsInject.join(";\n"))


    ## Called when a child WebComponent is added/updated
    method onHTMLChildUpdate(child: Component, html: ReactiveHTMLOutput, parentTagID: string = "") =

        # Do first injection
        this.doFirstInjection()

        # Store it
        this.renderedElements[html.privateTagID] = html
        
        # Generate JS changes
        let js = """

            // Find it
            var element = document.getElementById(""" & html.privateTagID.jsQuotedString() & """)
            var elemDidExist = element
            if (!element) {

                // Not found, create it
                element = document.createElement(""" & html.tagName.jsQuotedString() & """)
                element.id = """ & html.privateTagID.jsQuotedString() & """;
                document.body.appendChild(element)

            }

            // Update details
            element.className = """ & html.tagClass.jsQuotedString() & """;
            element.style.cssText = """ & html.css.jsQuotedString() & """;

            // Update inner text
            if (""" & $html.isTextElement & """)
                element.innerText = """ & html.innerText.jsQuotedString() & """;

            // Update parent
            var requestedParentID = """ & parentTagID.jsQuotedString() & """;
            var currentParentID = element.parentNode && element.parentNode.id || ""
            if (currentParentID != requestedParentID) {

                // Remove from current parent
                if (element.parentNode)
                    element.parentNode.removeChild(element)

                // Add to parent
                var newParent = document.getElementById(requestedParentID)
                if (newParent)
                    newParent.appendChild(element)

            }

            // Execute JavaScript code on mount
            if (!elemDidExist) {

                // Run it
                function customOnMount(element) {
                    """ & html.jsOnMount & """
                }
                customOnMount(element)

            }

            // Execute JavaScript code on update
            if (elemDidExist) {

                // Run it
                function customOnUpdate(element) {
                    """ & html.jsOnUpdate & """
                }
                customOnUpdate(element)

            }

        """

        # Inject it
        # echo "======="
        # echo js
        # echo ""
        # echo ""
        this.injectJS(js)


    ## Called when a child WebComponent is removed
    method onHTMLChildRemove(child: Component, html: ReactiveHTMLOutput) =
        
        # Remove it
        this.renderedElements.del(html.privateTagID)
        
        # Generate JS changes
        let js = """

            // Find it
            var element = document.getElementById(""" & html.privateTagID.jsQuotedString() & """)
            if (element) {

                // Remove from current parent
                if (element.parentNode)
                    element.parentNode.removeChild(element)

                // Call js removal code
                function customOnRemove(element) {
                    """ & html.jsOnRemove & """
                }
                customOnRemove(element)

            }

        """

        # Inject it
        # echo "======="
        # echo js
        this.injectJS(js)


    ## Called when the JS side sends us an event
    method onJsCallback(str: string) =

        # Parse it
        let msg = parseJson(str)

        # Find the target component
        let targetID = msg{"elementID"}.getStr()
        let element = this.renderedElements.getOrDefault(targetID, nil)
        if element == nil: return
        let component = BaseWebComponent(element.component)
        
        # Notify it
        component.onJsEvent(msg{"name"}.getStr(), msg{"data"}.getStr())



## Get the nearest bridge component for a component
proc nearestWebBridge*(component: Component): WebViewBridge =

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
