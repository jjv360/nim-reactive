import std/macros

##
## Macro for the DSL language of defining components to render
macro components*(code) =

    # Identifiers for known classes
    let Group = ident"Group"

    return quote do:
        return `Group`.init()


##
## Automatically mount and render a set of components
template mount*(code: untyped) =
    
    # Get node reference
    let node = components:
        code
    
    # Mount it
    node.mount()