##
## Functions for interacting with Foundation on Mac
import ./objc

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework Foundation".}
{.passL:"-lobjc".}

## NSObject
objcImport:

    ## The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.
    header "<Foundation/Foundation.h>"
    importClass NSObject of Id



## NSString
objcImport:

    ## A static, plain-text Unicode string object.
    header "<Foundation/Foundation.h>"
    importClass NSString of NSObject

    ## The following constants are provided by NSString as possible string encodings.
    type NSStringEncoding* = NSString

    ## An 8-bit representation of Unicode characters, suitable for transmission or storage by ASCII-based systems.
    importValue NSUTF8StringEncoding: NSStringEncoding

    # Class methods
    importClassMethods(NSString):

        ## A null-terminated UTF8 representation of the string.
        proc UTF8String*(): cstring

    # Static methods
    importStaticMethods(NSString):

        ## Returns a string containing the bytes in a given C array, interpreted according to a given encoding.
        proc stringWithCString*(str: cstring, encoding: NSStringEncoding): NSString

    # Convert a NSString to a Nim string
    converter nsStringToString*(nsString: NSString): string =
        return $nsString.UTF8String

    # Convert a Nim string to a NSString
    converter stringToNsString*(str: string): NSString =
        return NSString.stringWithCString(str, NSUTF8StringEncoding)

    ## Returns a string that represents the contents of the receiving class.
    proc description*(obj: NSObject): NSString {.importobjc, header:"<Foundation/Foundation.h>".}

    ## Get description for any NSObject as a string
    proc `$`*(item: Id): string =
        return NSObject(item).description






#### NSDate
objcImport:

    ## A representation of a specific point in time, independent of any calendar or time zone.
    header "<Foundation/Foundation.h>"
    importClass NSDate of NSObject

    ## A number of seconds.
    type NSTimeInterval = float64

    # Static methods
    importStaticMethods(NSDate):

        ## A date object representing a date in the distant past.
        proc distantPast*(): NSDate

        ## Creates and returns a date object set to the given number of seconds from 00:00:00 UTC on 1 January 1970.
        proc dateWithTimeIntervalSince1970*(secs: NSTimeInterval): NSDate

        ## Creates and returns a date object set to a given number of seconds from the current date and time.
        proc dateWithTimeIntervalSinceNow*(secs: NSTimeInterval): NSDate





#### NSRunLoop

## Modes that a run loop operates in.
type NSRunLoopMode* = NSString

## The mode set to handle input sources other than connection objects.
let NSDefaultRunLoopMode* {.header:"<Foundation/Foundation.h>", importc.} : NSString





#### NSURL
objcImport:

    ## An object that represents the location of a resource, such as an item on a remote server or the path to a local file.
    header "<Foundation/Foundation.h>"
    importClass NSURL of NSObject

    # Static methods
    importStaticMethods(NSURL):

        ## Creates and returns an NSURL object initialized with a provided URL string.
        proc URLWithString*(str: NSString): NSURL

        ## Initializes and returns a newly created NSURL object as a file URL with a specified path.
        proc fileURLWithPath*(path: NSString, isDirectory: bool): NSURL





#### NSNotification
objcImport:

    ## A container for information broadcast through a notification center to all registered observers.
    header "<Foundation/Foundation.h>"
    importClass NSNotification of NSObject

    # Methods
    importClassMethods(NSNotification):

        ## The name of the notification.
        proc name*(): NSString

        ## The object associated with the notification.
        proc `object`*(): NSObject





#### NSNotificationCenter
objcImport:

    ## A notification dispatch mechanism that enables the broadcast of information to registered observers.
    header "<Foundation/Foundation.h>"
    importClass NSNotificationCenter of NSObject

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

    ## A structure that defines the name of a notification.
    type NSNotificationName* = NSString

    # Static methods
    importStaticMethods(NSNotificationCenter):

        ## The app’s default notification center.
        proc defaultCenter*(): NSNotificationCenter

    # Methods
    importClassMethods(NSNotificationCenter):

        ## Creates a notification with a given name and sender and posts it to the notification center.
        proc postNotificationName*(name: NSNotificationName, `object`: NSObject = NSObject(nil))

    ## Adds an entry to the notification center to receive notifications that passed to the provided block.
    proc NimAddNSNotificationHandler(center: NSNotificationCenter, name: NSString, `object`: NSObject, nimProc: pointer, nimEnv: pointer): NSObject {.importc, nodecl.}
    proc addObserverForName*(this: NSNotificationCenter, name: NSString, `object`: NSObject = NSObject(nil), callback: proc(notification: NSNotification) {.closure.}): NSObject =

        # Proc is leaving Nim's memory management, so ensure Nim doesn't discard it
        # TODO: How do we unref this?
        var storedProcs {.global.} : seq[proc(notification: NSNotification) {.closure.}]
        storedProcs.add(callback)

        # Create wrapper class
        return NimAddNSNotificationHandler(this, name, `object`, callback.rawProc, callback.rawEnv)