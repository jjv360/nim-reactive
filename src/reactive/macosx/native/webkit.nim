##
## Integrate web content seamlessly into your app, and customize content interactions to meet your app’s needs.

import ./objc
import ./appkit
import ./corefoundation
import ./foundation

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework WebKit".}
{.passL:"-lobjc".}




#### WKNavigation
objcImport:

    ## An object that tracks the loading progress of a webpage.
    header "<WebKit/WebKit.h>"
    importClass WKNavigation of NSObject




#### WKScriptMessageHandler
objcImport:

    ## An interface for receiving messages from JavaScript code running in a webpage.
    header "<WebKit/WebKit.h>"
    importClass WKScriptMessageHandler of NSObject

    {.emit:"""

        // Wrapper for WKScriptMessageHandler into Nim
        #import <WebKit/WebKit.h>

        @interface NimWKScriptMessageHandler : NSObject <WKScriptMessageHandler>
            @property void* nimClosureProc;
            @property void* nimClosureEnv;
        @end

        @implementation NimWKScriptMessageHandler

            - (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message {

                // Convert body to string
                NSString* str = nil;
                if (!message.body)
                    str = @"";
                if ([message.body isKindOfClass:[NSString class]])
                    str = message.body;
                else
                    str = [message.body stringValue];

                // Call back to Nim ... Note: Nim closures are a function which take an extra "env" pointer as the last argument
                void (*func)(NSString*, void*) = self.nimClosureProc;
                func(str, self.nimClosureEnv);

            }

        @end

        // Create wrapper
        NSObject* NimWKScriptMessageHandlerCreate(void* nimProc, void* nimEnv) {

            // Create it
            NimWKScriptMessageHandler* handler = [[NimWKScriptMessageHandler alloc] init];
            handler.nimClosureProc = nimProc;
            handler.nimClosureEnv = nimEnv;
            return handler;

        }

    """.}

    ## Create a script message handler (wrapper for Nim)
    proc NimWKScriptMessageHandlerCreate(nimProc : pointer, nimEnv : pointer): WKScriptMessageHandler {.importc, nodecl.}
    proc create*(_: typedesc[WKScriptMessageHandler], callback: proc(message: NSString) {.closure.}): WKScriptMessageHandler =

        # Proc is leaving Nim's memory management, so ensure Nim doesn't discard it
        # TODO: How do we unref this?
        var storedProcs {.global.} : seq[proc(message: NSString) {.closure.}]
        storedProcs.add(callback)

        # Create wrapper class
        return NimWKScriptMessageHandlerCreate(callback.rawProc, callback.rawEnv)



#### WKUserContentController
objcImport:

    ## An object for managing interactions between JavaScript code and your web view, and for filtering content in your web view.
    header "<WebKit/WebKit.h>"
    importClass WKUserContentController of NSObject
    
    # Methods
    importClassMethods(WKUserContentController):

        ## Initialize
        proc init*(): WKUserContentController

        ## Installs a message handler that you can call from your JavaScript code.
        proc addScriptMessageHandler*(scriptMessageHandler: WKScriptMessageHandler, name: NSString)




#### WKWebViewConfiguration
objcImport:

    ## A collection of properties that you use to initialize a web view.
    header "<WebKit/WebKit.h>"
    importClass WKWebViewConfiguration of NSObject

    # Methods
    importClassMethods(WKWebViewConfiguration):

        ## Initialize class
        proc init*(): WKWebViewConfiguration

        ## The object that coordinates interactions between your app’s native code and the webpage’s scripts and other content.
        proc userContentController*(): WKUserContentController

        ## The object that coordinates interactions between your app’s native code and the webpage’s scripts and other content.
        proc `userContentController=`*(item: WKUserContentController)






#### WKWebView
objcImport:

    ## An object that displays interactive web content, such as for an in-app browser.
    header "<WebKit/WebKit.h>"
    importClass WKWebView of NSObject
    
    # Methods
    importClassMethods(WKWebView):

        ## Creates a web view and initializes it with the specified frame and configuration data.
        proc initWithFrame*(frame: CGRect, configuration: WKWebViewConfiguration): WKWebView

        ## Loads the contents of the specified HTML string and navigates to it.
        proc loadHTMLString*(html: NSString, baseURL: NSURL = NSURL(nil)): WKNavigation {.discardable.}

        ## Evaluates the specified JavaScript string.
        proc evaluateJavaScript*(javaScriptString: NSString, completionHandler: pointer = nil)