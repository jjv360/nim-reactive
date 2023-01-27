##
## Functions for interacting with Foundation on Mac

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework Foundation".}
{.passL:"-lobjc".}

#### NSObject

type NSObject* = distinct pointer



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

## A date object representing a date in the distant past.
proc NSDate_distantPast(): NSDate {.header:"<Foundation/Foundation.h>", importobjc:"NSDate distantPast".}
proc distantPast*(_: typedesc[NSDate]): NSDate = NSDate_distantPast()





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


