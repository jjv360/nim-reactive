##
## Functions for interacting with CoreFoundation on Mac. We shouldn't be using these directly since the Foundation framework
## has better versions of all functions, but sometimes it's missing something...
## 
## Note: Most CFWhateverRef classes are directly swappable with NSWhatever classes. ("Whatever" being whatever your class is)
import ./foundation





#### CGFloat

## The basic type for floating-point scalar values in Core Graphics and related frameworks.
type CGFloat* = cfloat





#### CGPoint

## A structure that contains width and height values.
type CGPoint* {.bycopy, importc, header: "<CoreGraphics/CoreGraphics.h>".} = object
    x*: CGFloat
    y*: CGFloat




#### CGSize

type CGSize* {.bycopy, importc, header: "<CoreGraphics/CoreGraphics.h>".} = object
    width*: CGFloat
    height*: CGFloat





#### CGRect

## A structure that contains the location and dimensions of a rectangle.
type CGRect* {.bycopy, importc, header: "<CoreGraphics/CoreGraphics.h>".} = object
    origin*: CGPoint
    size*: CGSize





#### NSRect

## A rectangle.
type NSRect* = CGRect





#### CFUserNotification

## A CFUserNotification object presents a simple dialog on the screen and optionally receives feedback from the user.
type CFUserNotificationRef* = distinct NSObject

## A bitfield used for passing special allocation and other requests into Core Foundation functions.
type CFOptionFlags* = uint64

## The notification is not serious.
let kCFUserNotificationPlainAlertLevel* {.importc, header: "<CoreFoundation/CoreFoundation.h>".} : CFOptionFlags

## Displays a user notification dialog and waits for a user response.
proc CFUserNotificationDisplayAlert*(
    timeout: float64 = 0, 
    flags: CFOptionFlags = kCFUserNotificationPlainAlertLevel, 
    iconURL: NSURL = NSURL(nil), 
    soundURL: NSURL = NSURL(nil), 
    localizationURL: NSURL = NSURL(nil), 
    alertHeader: NSString, 
    alertMessage: NSString, 
    defaultButtonTitle: NSString = "Close", 
    alternateButtonTitle: NSString = NSString(nil),
    otherButtonTitle: NSString = NSString(nil),
    responseFlags: ptr CFOptionFlags = nil
): int32 {.importc, header: "<CoreFoundation/CoreFoundation.h>".}