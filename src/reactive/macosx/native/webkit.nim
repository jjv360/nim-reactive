##
## Integrate web content seamlessly into your app, and customize content interactions to meet your app’s needs.

import ./appkit
import ./corefoundation
import ./foundation

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework WebKit".}
{.passL:"-lobjc".}




#### WKWebViewConfiguration

## A collection of properties that you use to initialize a web view.
type WKWebViewConfiguration* = distinct NSObject

## Allocate memory
proc WKWebViewConfiguration_alloc(): WKWebViewConfiguration {.importobjc:"WKWebViewConfiguration alloc", header:"<WebKit/WebKit.h>".}
proc alloc*(_: typedesc[WKWebViewConfiguration]): WKWebViewConfiguration = WKWebViewConfiguration_alloc()

## Initialize class
proc init*(this: WKWebViewConfiguration): WKWebViewConfiguration {.importobjc, header:"<WebKit/WebKit.h>".}




#### WKNavigation

## An object that tracks the loading progress of a webpage.
type WKNavigation* = distinct NSObject




#### WKScriptMessageHandler

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

## An interface for receiving messages from JavaScript code running in a webpage.
type WKScriptMessageHandler* = distinct NSObject

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

## An object for managing interactions between JavaScript code and your web view, and for filtering content in your web view.
type WKUserContentController* = distinct NSObject

## Allocate memory
proc WKUserContentController_alloc(): WKUserContentController {.importobjc:"WKUserContentController alloc", header:"<WebKit/WebKit.h>".}
proc alloc*(_: typedesc[WKUserContentController]): WKUserContentController = WKUserContentController_alloc()

## Initialize
proc init*(this: WKUserContentController): WKUserContentController {.importobjc, header:"<WebKit/WebKit.h>".}

## Installs a message handler that you can call from your JavaScript code.
proc addScriptMessageHandler*(this: WKUserContentController, scriptMessageHandler: WKScriptMessageHandler, name: NSString) {.importobjc, header:"<WebKit/WebKit.h>".}

## The object that coordinates interactions between your app’s native code and the webpage’s scripts and other content.
proc userContentController*(this: WKWebViewConfiguration): WKUserContentController {.importobjc, header:"<WebKit/WebKit.h>".}

## The object that coordinates interactions between your app’s native code and the webpage’s scripts and other content.
proc `userContentController=`*(this: WKWebViewConfiguration, item: WKUserContentController) {.importobjc:"setUserContentController", header:"<WebKit/WebKit.h>".}






#### WKWebView

## An object that displays interactive web content, such as for an in-app browser.
type WKWebView* = distinct NSView

## Allocate memory
proc WKWebView_alloc(): WKWebView {.importobjc:"WKWebView alloc", header:"<WebKit/WebKit.h>".}
proc alloc*(_: typedesc[WKWebView]): WKWebView = WKWebView_alloc()

## Creates a web view and initializes it with the specified frame and configuration data.
proc initWithFrame*(this: WKWebView, frame: CGRect, configuration: WKWebViewConfiguration): WKWebView {.importobjc, header:"<WebKit/WebKit.h>".}

## Loads the contents of the specified HTML string and navigates to it.
proc loadHTMLString*(this: WKWebView, html: NSString, baseURL: NSURL = NSURL(nil)): WKNavigation {.importobjc, header:"<WebKit/WebKit.h>", discardable.}

## Evaluates the specified JavaScript string.
proc evaluateJavaScript*(this: WKWebView, javaScriptString: NSString, completionHandler: pointer = nil) {.importobjc, header:"<WebKit/WebKit.h>".}