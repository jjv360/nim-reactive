##
## Functions for interacting with Foundation on Mac

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework Foundation".}
{.passL:"-lobjc".}

#### NSObject

## The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.
type NSObject* = distinct pointer

## Compare objects
proc `==`*(a: NSObject, b: NSObject): bool = a.pointer == b.pointer




## NSInteger etc

## The maximum value for an NSUInteger.

let NSUIntegerMax* {.importc, header:"<Foundation/Foundation.h>".} : cint



#### NSString

## A static, plain-text Unicode string object.
type NSString* = distinct NSObject

## The following constants are provided by NSString as possible string encodings.
type NSStringEncoding* = distinct NSString

## An 8-bit representation of Unicode characters, suitable for transmission or storage by ASCII-based systems.
let NSUTF8StringEncoding* {.importobjc, header:"<Foundation/Foundation.h>".} : NSStringEncoding

## A null-terminated UTF8 representation of the string.
proc UTF8String(str: NSString): cstring {.importobjc, header:"<Foundation/Foundation.h>".}

## Returns a string containing the bytes in a given C array, interpreted according to a given encoding.
proc NSString_stringWithCString(arg1: cstring, encoding: NSStringEncoding): NSString {.header:"<Foundation/Foundation.h>", importobjc:"NSString stringWithCString".}
proc stringWithCString*(_: typedesc[NSString], arg1: cstring, encoding: NSStringEncoding): NSString = NSString_stringWithCString(arg1, encoding)

# Convert a NSString to a Nim string
converter nsStringToString*(nsString: NSString): string =
    return $nsString.UTF8String

# Convert a Nim string to a NSString
converter stringToNsString*(str: string): NSString =
    return NSString.stringWithCString(str, NSUTF8StringEncoding)

## Returns a string that represents the contents of the receiving class.
proc description*(obj: NSObject): NSString {.importobjc, header:"<Foundation/Foundation.h>".}

# Get description for any NSObject as a string
# proc `$`*(item: NSObject): string =
#     return item.description




#### NSDate

## A representation of a specific point in time, independent of any calendar or time zone.
type NSDate* = distinct NSObject

## A number of seconds.
type NSTimeInterval = float64

## A date object representing a date in the distant past.
proc NSDate_distantPast(): NSDate {.header:"<Foundation/Foundation.h>", importobjc:"NSDate distantPast".}
proc distantPast*(_: typedesc[NSDate]): NSDate = NSDate_distantPast()

## Creates and returns a date object set to the given number of seconds from 00:00:00 UTC on 1 January 1970.
proc NSDate_dateWithTimeIntervalSince1970(secs: NSTimeInterval): NSDate {.header:"<Foundation/Foundation.h>", importobjc:"NSDate dateWithTimeIntervalSince1970".}
proc dateWithTimeIntervalSince1970*(_: typedesc[NSDate], secs: NSTimeInterval): NSDate = NSDate_dateWithTimeIntervalSince1970(secs)

## Creates and returns a date object set to a given number of seconds from the current date and time.
proc NSDate_dateWithTimeIntervalSinceNow(secs: NSTimeInterval): NSDate {.header:"<Foundation/Foundation.h>", importobjc:"NSDate dateWithTimeIntervalSinceNow".}
proc dateWithTimeIntervalSinceNow*(_: typedesc[NSDate], secs: NSTimeInterval): NSDate = NSDate_dateWithTimeIntervalSinceNow(secs)





#### NSRunLoop

## Modes that a run loop operates in.
type NSRunLoopMode* = NSString

## The mode set to handle input sources other than connection objects.
let NSDefaultRunLoopMode* {.header:"<Foundation/Foundation.h>", importc.} : NSString





#### NSURL

## An object that represents the location of a resource, such as an item on a remote server or the path to a local file.
type NSURL* = distinct NSObject

## Creates and returns an NSURL object initialized with a provided URL string.
proc NSURL_URLWithString(str: NSString): NSURL {.header:"<Foundation/Foundation.h>", importobjc:"NSURL URLWithString".}
proc URLWithString*(_: typedesc[NSURL], str: NSString): NSURL = NSURL_URLWithString(str)

## Initializes and returns a newly created NSURL object as a file URL with a specified path.
proc NSURL_fileURLWithPath(path: NSString, isDirectory: bool): NSURL {.header:"<Foundation/Foundation.h>", importobjc:"NSURL fileURLWithPath".}
proc fileURLWithPath*(_: typedesc[NSURL], path: NSString, isDirectory: bool): NSURL = NSURL_fileURLWithPath(path, isDirectory)





#### NSNotification

## A container for information broadcast through a notification center to all registered observers.
type NSNotification* = distinct NSObject

## The name of the notification.
proc name*(this: NSNotification): NSString {.importobjc, header:"<Foundation/Foundation.h>".}

## The object associated with the notification.
proc `object`*(this: NSNotification): NSObject {.importobjc, header:"<Foundation/Foundation.h>".}





#### NSNotificationCenter

{.emit:"""

    // Wrapper for NSNotificationCenter into Nim
    #import <Foundation/Foundation.h>

    // Add a handler
    NSObject* NimAddNSNotificationHandler(NSNotificationCenter* center, NSString* name, id object, void* nimProc, void* nimEnv) {

        // Add it
        return [center addObserverForName:name object:object queue:nil usingBlock:^(NSNotification* notification) {

            // Send to Nim
            void (*func)(NSNotification*, void*) = nimProc;
            func(notification, nimEnv);

        }];

    }

""".}

## A notification dispatch mechanism that enables the broadcast of information to registered observers.
type NSNotificationCenter* = distinct NSObject

## A structure that defines the name of a notification.
type NSNotificationName* = NSString

## The app’s default notification center.
proc NSNotificationCenter_defaultCenter(): NSNotificationCenter {.importobjc:"NSNotificationCenter defaultCenter", header:"<Foundation/Foundation.h>".}
proc defaultCenter*(_: typedesc[NSNotificationCenter]): NSNotificationCenter = NSNotificationCenter_defaultCenter()

## Creates a notification with a given name and sender and posts it to the notification center.
proc postNotificationName*(this: NSNotificationCenter, name: NSNotificationName, `object`: NSObject = NSObject(nil)) {.importobjc, header:"<Foundation/Foundation.h>".}

## Adds an entry to the notification center to receive notifications that passed to the provided block.
proc NimAddNSNotificationHandler(center: NSNotificationCenter, name: NSString, `object`: NSObject, nimProc: pointer, nimEnv: pointer): NSObject {.importc, nodecl.}
proc addObserverForName*(this: NSNotificationCenter, name: NSString, `object`: NSObject = NSObject(nil), callback: proc(notification: NSNotification) {.closure.}): NSObject =

    # Proc is leaving Nim's memory management, so ensure Nim doesn't discard it
    # TODO: How do we unref this?
    var storedProcs {.global.} : seq[proc(notification: NSNotification) {.closure.}]
    storedProcs.add(callback)

    # Create wrapper class
    return NimAddNSNotificationHandler(this, name, `object`, callback.rawProc, callback.rawEnv)