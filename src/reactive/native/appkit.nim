##
## Functions for interacting with AppKit on Mac

# Link required libraries
{.passl:"-framework AppKit".}

## App stuff
proc NSApplicationMain*(argc: cint, argv: cstringArray) {.importc, header: "<CoreFoundation/CoreFoundation.h>".}