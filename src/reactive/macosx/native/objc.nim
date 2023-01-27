##
## Functions for interacting with Objective-C

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework Foundation".}
{.passL:"-lobjc".}



#### Generic types

## Any kind of Objective-C reference
type Id* = pointer

## Describes an unsigned integer.
type NSUInteger* = uint

## The maximum value for an NSUInteger.
let NSUIntegerMax* {.importc, header:"<objc/objc.h>".} : NSUInteger