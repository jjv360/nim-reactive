import classes
import std/tables

##
## Base class for all Components.
class BaseComponent:

    ## Component props passed into the compnent at render time
    var props: Table[string, string]

    ## Component state
    var state: Table[string, string]

    