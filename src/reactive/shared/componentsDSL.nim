import std/macros


## Convert a single command to output code
var lastID {.compileTime.} = 0
proc componentsConvertSingle(cmd: NimNode): tuple[code: NimNode, varIdent: NimNode] =

    # Generate new identifier for this node
    lastID += 1
    let nodeVarName = ident("node`id" & $lastID)

    # Check command type
    if cmd.kind == nnkIdent:

        # Render a single component, with no props and no children
        let nodeClassIdent = cmd
        let code = quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
        return (code, nodeVarName)

    elif cmd.kind == nnkCall and cmd.len == 1 and cmd[0].kind == nnkIdent:

        # Render a single component, with no props and no children (using calling format)
        let nodeClassIdent = cmd[0]
        let code = quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
        return (code, nodeVarName)

    elif cmd.kind == nnkCall and cmd.len == 2 and cmd[0].kind == nnkObjConstr and cmd[1].kind == nnkStmtList:

        # Render a single component, with props and children in the Object Constructor format, ie: Comp(prop: name): ChildComp()
        let nodeClassIdent = cmd[0][0]
        var code = nnkStmtList.newNimNode()
        
        # Create var
        code.add(quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
        )

        # Go through children props
        for idx, child in cmd[0]:

            # Ignore first, which is the identifier
            if idx == 0:
                continue

            # Check item
            if idx == 0:

                # Skip, this is the identifier
                discard

            elif child.kind == nnkExprEqExpr or child.kind == nnkExprColonExpr:

                # Set a prop value
                let propName = $child[0]
                let propValue = child[1]
                # let PropertyItem = ident"PropertyItem"
                code.add(quote do:
                    let propValue = `propValue`
                    `nodeVarName`.props[`propName`] = propValue
                )

            else:

                # Something else, unknown
                echo cmd.treeRepr
                raiseAssert("Unable to parse DSL, please check your syntax.")
            
        # Go through children components
        for idx, child in cmd[1]:

            # Generate output code
            let gen = componentsConvertSingle(child)

            # Add to the body
            code.add(gen.code)

            # Attach to parent node
            let varIdent = gen.varIdent
            code.add(quote do:
                `nodeVarName`.children.add(`varIdent`)
            )

        return (code, nodeVarName)

    elif cmd.kind == nnkCall or cmd.kind == nnkObjConstr:

        # Render a single component, with props and possibly children in the Function Call format, ie: Comp(prop = name): ChildComp()
        let nodeClassIdent = cmd[0]
        var code = nnkStmtList.newNimNode()
        
        # Create var
        code.add(quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
        )

        # Go through children
        var hasChildrenAtEnd = false
        for idx, child in cmd:

            # Ignore first, which is the identifier
            if idx == 0:
                continue

            # Check item
            if idx == 0:

                # Skip, this is the identifier
                discard

            elif child.kind == nnkExprEqExpr or child.kind == nnkExprColonExpr:

                # Set a prop value
                let propName = $child[0]
                let propValue = child[1]
                # let PropertyItem = ident"PropertyItem"
                code.add(quote do:
                    let propValue = `propValue`
                    `nodeVarName`.props[`propName`] = propValue
                )

            elif child.kind == nnkStmtList and idx == cmd.len-1:

                # Last one is a statement list, meaning it has children
                hasChildrenAtEnd = true

            else:

                # Something else, unknown
                echo cmd.treeRepr
                raiseAssert("Unable to parse DSL, please check your syntax.")
            
        # Go through children components
        if hasChildrenAtEnd:
            for idx, child in cmd[cmd.len-1]:

                # Generate output code
                let gen = componentsConvertSingle(child)

                # Add to the body
                code.add(gen.code)

                # Attach to parent node
                let varIdent = gen.varIdent
                code.add(quote do:
                    `nodeVarName`.children.add(`varIdent`)
                )

        return (code, nodeVarName)

    else:

        # Unknown command format
        echo cmd.treeRepr
        raiseAssert("Unable to parse DSL, please check your syntax.")



## Convert NimNode DSL input to NimNode output code
proc componentsConvert(input: NimNode): NimNode =

    # Identifiers for known classes
    let Group = ident"Group"
    let finalNode = ident"finalNode"

    # Create code block
    var output = nnkStmtList.newNimNode()

    # TODO: If there's only a single component, return it directly

    # Check input
    if input.kind != nnkStmtList:
        echo input.treeRepr
        raiseAssert("Unable to parse DSL, please check your syntax.")

    # Create final node as a group
    output.add(quote do:
        let `finalNode` = `Group`.init()
    )

    # Go through commands
    for cmd in input:
        
        # Generate output code
        let gen = componentsConvertSingle(cmd)

        # Add to the body
        output.add(gen.code)

        # Attach to parent node
        let varIdent = gen.varIdent
        output.add(quote do:
            `finalNode`.children.add(`varIdent`)
        )

    # echo input.treeRepr
    # raiseAssert("D")
    
    
    # let tst = quote do:
    #     let `finalNode` = `Group`.init()
    #     echo "HERE"

    # Done
    return output



##
## Macro for the DSL language of defining components to render
macro components*(code) =

    # Identifiers for known classes
    let finalNode = ident"finalNode"

    # Get output from components:
    let comps = componentsConvert(code)

    # Return the result
    let output = quote do:
    
        # Get node reference
        `comps`
        
        # Return it
        return `finalNode`

    # Debug
    # echo ""
    # echo ""
    # echo "====== Render:"
    # echo output.repr
    # echo ""

    # Done
    return output



##
## Automatically mount and render a set of components
macro reactiveMount*(code: untyped) =

    # Identifiers for known classes
    let finalNode = ident"finalNode"
    let ReactiveMountManager = ident"ReactiveMountManager"

    # Get output from components:
    let comps = componentsConvert(code)

    # Get components then render them
    let output = quote do:
    
        # Get node reference
        `comps`
        
        # Mount it
        `ReactiveMountManager`.shared.mount(`finalNode`)

    # Debug
    # echo ""
    # echo ""
    # echo "====== Mount:"
    # echo output.repr
    # echo ""

    # Done
    return output