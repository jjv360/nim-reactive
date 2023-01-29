##
## Functions for interacting with AppKit on Mac
import ./objc
import ./corefoundation
import ./foundation

# Link required libraries
{.passC: "-x objective-c".}
{.passL:"-framework AppKit".}

#### NSEvent
objcImport:

    ## An object that contains information about an input action, such as a mouse click or a key press.
    header "<AppKit/AppKit.h>"
    importClass NSEvent of NSObject

    ## Constants that you use to filter out specific event types from the stream of incoming events.
    type NSEventMask* {.importc, header:"<AppKit/AppKit.h>".} = uint64

    ## A mask that matches any type of event.
    let NSEventMaskAny* {.importc, header:"<AppKit/AppKit.h>".} : NSEventMask



#### NSApplication
objcImport:

    ## An object that contains information about an input action, such as a mouse click or a key press.
    header "<AppKit/AppKit.h>"
    importClass NSApplication of NSObject

    ## Called by the main function to create and run the application.
    proc NSApplicationMain*(argc: cint, argv: cstringArray) {.importc, header:"<AppKit/AppKit.h>".}

    # Static methods
    importStaticMethods(NSApplication):

        ## Returns the application instance, creating it if it doesn’t exist yet.
        proc sharedApplication*(): NSApplication

    # Methods
    importClassMethods(NSApplication):

        ## Returns the next event matching a given mask, or `nil` if no such event is found before a specified expiration date.
        proc nextEventMatchingMask*(mask: NSEventMask, untilDate: NSDate, inMode: NSRunLoopMode, dequeue: bool): NSEvent

        ## Dispatches an event to other objects.
        proc sendEvent*(event: NSEvent)

        ## A Boolean value indicating whether this is the active app.
        proc active*(): bool

        ## Makes the receiver the active app.
        proc activateIgnoringOtherApps*(ignore: bool = true)

        ## Deactivates the receiver.
        proc deactivate*()





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
objcImport:

    ## An object that describes the attributes of a computer’s monitor or screen.
    header "<AppKit/AppKit.h>"
    importClass NSScreen of NSObject

    # Static methods
    importStaticMethods(NSScreen):

        ## Returns the screen object containing the window with the keyboard focus.
        proc mainScreen*(): NSScreen




#### NSView
objcImport:

    ## The infrastructure for drawing, printing, and handling events in an app.
    header "<AppKit/AppKit.h>"
    importClass NSView of NSObject

    # Methods
    importClassMethods(NSView):

        ## The view that is the parent of the current view.
        proc superview*(): NSView

        ## Adds a view to the view’s subviews so it’s displayed above its siblings.
        proc addSubview*(child: NSView)

        ## Unlinks the view from its superview and its window, removes it from the responder chain, and invalidates its cursor rectangles.
        proc removeFromSuperview*()




#### NSWindow
objcImport:

    ## A window that an app displays on the screen.
    header "<AppKit/AppKit.h>"
    importClass NSWindow of NSObject

    # Methods
    importClassMethods(NSWindow):

        ## Initializes an allocated window with the specified values.
        proc initWithContentRect*(
            contentRect: NSRect, 
            styleMask: NSWindowStyleMask = NSWindowStyleMaskTitled or NSWindowStyleMaskClosable or NSWindowStyleMaskMiniaturizable or NSWindowStyleMaskResizable, 
            backing: NSBackingStoreType = NSBackingStoreBuffered, 
            `defer`: bool = false, 
            screen: NSScreen = NSScreen(nil)
        ): NSWindow

        ## Moves the window to the front of the screen list, within its level, and makes it the key window; that is, it shows the window.
        proc makeKeyAndOrderFront*(sender: Id = nil)

        ## Makes the window the main window.
        proc makeMainWindow*()

        ## The window’s content view, the highest accessible view object in the window’s view hierarchy.
        proc contentView*(): NSView

        ## The window’s content view, the highest accessible view object in the window’s view hierarchy.
        proc `contentView=`*(item: NSView)

        ## The string that appears in the title bar of the window or the path to the represented file.
        proc title*(): NSString

        ## The string that appears in the title bar of the window or the path to the represented file.
        proc `title=`*(title: NSString)

        ## Removes the window from the screen.
        proc close*()

    ## A notification that the window object is about to close.
    let NSWindowWillCloseNotification* {.importc, header:"<AppKit/AppKit.h>".} : NSString