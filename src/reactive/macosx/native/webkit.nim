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