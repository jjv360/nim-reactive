##
## Functions for interacting with AppKit on Mac
import ./objc
import ./corefoundation
import ./foundation

# Link required libraries
{.passC: "-x objective-c".}
{.passL:"-framework AppKit".}

#### NSEvent

## An object that contains information about an input action, such as a mouse click or a key press.
type NSEvent* = distinct pointer

## Constants that you use to filter out specific event types from the stream of incoming events.
type NSEventMask* {.importc, header:"<AppKit/AppKit.h>".} = uint64

## A mask that matches any type of event.
let NSEventMaskAny* {.importc, header:"<AppKit/AppKit.h>".} : NSEventMask



#### NSApplication

## An object that manages an app’s main event loop and resources used by all of that app’s objects.
type NSApplication* = distinct NSObject

## Called by the main function to create and run the application.
proc NSApplicationMain*(argc: cint, argv: cstringArray) {.importc, header:"<AppKit/AppKit.h>".}

## Returns the application instance, creating it if it doesn’t exist yet.
proc NSApplication_sharedApplication(): NSApplication {.importobjc:"NSApplication sharedApplication", header:"<AppKit/AppKit.h>".}
proc sharedApplication*(_: typedesc[NSApplication]): NSApplication = NSApplication_sharedApplication()

## Returns the next event matching a given mask, or `nil` if no such event is found before a specified expiration date.
proc nextEventMatchingMask*(this: NSApplication, mask: NSEventMask, untilDate: NSDate, inMode: NSRunLoopMode, dequeue: bool): NSEvent {.importobjc, header:"<AppKit/AppKit.h>".}

## Dispatches an event to other objects.
proc sendEvent*(this: NSApplication, event: NSEvent) {.importobjc, header:"<AppKit/AppKit.h>".}

## A Boolean value indicating whether this is the active app.
proc active*(this: NSApplication): bool {.importobjc:"isActive", header:"<AppKit/AppKit.h>".}

## Makes the receiver the active app.
proc activateIgnoringOtherApps*(this: NSApplication, ignore: bool = true) {.importobjc, header:"<AppKit/AppKit.h>".}

## Deactivates the receiver.
proc deactivate*(this: NSApplication) {.importobjc, header:"<AppKit/AppKit.h>".}





#### NSWindowStyleMask

## Constants that specify the style of a window, and that you can combine with the C bitwise OR operator.
type NSWindowStyleMask* = NSUInteger

## The window displays none of the usual peripheral elements. Useful only for display or caching purposes. A window that uses NSWindowStyleMaskBorderless can’t become key or main, unless the value of canBecomeKeyWindow or canBecomeMainWindow is YES. Note that you can set a window’s or panel’s style mask to NSWindowStyleMaskBorderless in Interface Builder by deselecting Title Bar in the Appearance section of the Attributes inspector.
let NSWindowStyleMaskBorderless* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window displays a title bar.
let NSWindowStyleMaskTitled* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window displays a close button.
let NSWindowStyleMaskClosable* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window displays a minimize button.
let NSWindowStyleMaskMiniaturizable* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window can be resized by the user.
let NSWindowStyleMaskResizable* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window can appear full screen. A fullscreen window does not draw its title bar, and may have special handling for its toolbar. (This mask is automatically toggled when toggleFullScreen: is called.)
let NSWindowStyleMaskFullScreen* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## When set, the window’s contentView consumes the full size of the window. Although you can combine this constant with other window style masks, it is respected only for windows with a title bar. Note that using this mask opts in to layer-backing. Use the contentLayoutRect or the contentLayoutGuide to lay out views underneath the title bar–toolbar area.
let NSWindowStyleMaskFullSizeContentView* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window is a panel or a subclass of NSPanel.
let NSWindowStyleMaskUtilityWindow* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window is a document-modal panel (or a subclass of NSPanel).
let NSWindowStyleMaskDocModalWindow* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window is a panel or a subclass of NSPanel that does not activate the owning app.
let NSWindowStyleMaskNonactivatingPanel* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask

## The window is a HUD panel.
let NSWindowStyleMaskHUDWindow* {.importc, header:"<AppKit/AppKit.h>".} : NSWindowStyleMask




#### NSBackingStoreType

## Constants that specify how the window device buffers the drawing done in a window.
type NSBackingStoreType* = NSUInteger

## The window renders all drawing into a display buffer and then flushes it to the screen.
let NSBackingStoreBuffered* {.importc, header:"<AppKit/AppKit.h>".} : NSBackingStoreType




#### NSScreen

## An object that describes the attributes of a computer’s monitor or screen.
type NSScreen* = distinct NSObject

## Returns the screen object containing the window with the keyboard focus.
proc NSScreen_mainScreen(): NSScreen {.importc, header:"<AppKit/AppKit.h>".}
proc mainScreen*(_: typedesc[NSScreen]) = NSScreen_mainScreen()




#### NSView

## The infrastructure for drawing, printing, and handling events in an app.
type NSView* = distinct NSObject

## The view that is the parent of the current view.
proc superview*(this: NSView): NSView {.importc, header:"<AppKit/AppKit.h>".}

## Adds a view to the view’s subviews so it’s displayed above its siblings.
proc addSubview*(this: NSView, child: NSView) {.importc, header:"<AppKit/AppKit.h>".}

## Unlinks the view from its superview and its window, removes it from the responder chain, and invalidates its cursor rectangles.
proc removeFromSuperview*(this: NSView) {.importc, header:"<AppKit/AppKit.h>".}




#### NSWindow

## A window that an app displays on the screen.
type NSWindow* = distinct NSObject

## Allocate memory
proc NSWindow_alloc(): NSWindow {.importobjc:"NSWindow alloc", header:"<AppKit/AppKit.h>".}
proc alloc*(_: typedesc[NSWindow]): NSWindow = NSWindow_alloc()

## Initializes an allocated window with the specified values.
proc initWithContentRect*(
    this: NSWindow, 
    contentRect: NSRect, 
    styleMask: NSWindowStyleMask = NSWindowStyleMaskTitled or NSWindowStyleMaskClosable or NSWindowStyleMaskMiniaturizable or NSWindowStyleMaskResizable, 
    backing: NSBackingStoreType = NSBackingStoreBuffered, 
    `defer`: bool = false, 
    screen: NSScreen = NSScreen(nil)
): NSWindow {.importobjc, header:"<AppKit/AppKit.h>".}

## Moves the window to the front of the screen list, within its level, and makes it the key window; that is, it shows the window.
proc makeKeyAndOrderFront*(this: NSWindow, sender: Id = nil) {.importobjc, header:"<AppKit/AppKit.h>".}

## Makes the window the main window.
proc makeMainWindow*(this: NSWindow) {.importobjc, header:"<AppKit/AppKit.h>".}

## The window’s content view, the highest accessible view object in the window’s view hierarchy.
proc contentView*(this: NSWindow): NSView {.importobjc, header:"<AppKit/AppKit.h>".}

## The window’s content view, the highest accessible view object in the window’s view hierarchy.
proc `contentView=`*(this: NSWindow, item: NSView) {.importobjc:"setContentView", header:"<AppKit/AppKit.h>".}

## The string that appears in the title bar of the window or the path to the represented file.
proc title*(this: NSWindow): NSString {.importobjc, header:"<AppKit/AppKit.h>".}

## The string that appears in the title bar of the window or the path to the represented file.
proc `title=`*(this: NSWindow, title: NSString) {.importobjc:"setTitle", header:"<AppKit/AppKit.h>".}