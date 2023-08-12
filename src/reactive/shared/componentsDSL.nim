import std/macros
import std/sugar

## Exports that need to be exposed for lib users
export sugar.capture

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
                    if `propName` == "text": echo "== " & propValue.repr & "\n\n"
                    `nodeVarName`.props[`propName`] = propValue
                )
                # if propName == "text":
                #     echo "==== " & propName
                #     echo code.repr
                #     echo ""
                #     echo ""

            else:

                # Something else, unknown
                error("Unable to parse DSL, please check your syntax.", child)
            
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

    elif cmd.kind == nnkCall and cmd[0].kind == nnkIdent and $cmd[0] == "mapIt":

        # Checks
        if cmd[2].kind != nnkStmtList: error("Missing code block for mapIt().", cmd)
        if cmd[2].len != 1: error("There should only be one rendered component for mapIt().", cmd)

        # DSL for mapping an array to components
        let arrayStmt = cmd[1]
        let componentCmd = cmd[2][0]
        let nodeClassIdent = ident"Group"
        let itIdent = ident"it"
        let idxIdent = ident"idx"
        var code = nnkStmtList.newNimNode()

        # Generate loop body
        let gen = componentsConvertSingle(componentCmd)
        let varIdent = gen.varIdent
        let loopBody = gen.code

        # Generate code
        code.add(quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
            for `idxIdent`, `itIdent` in `arrayStmt`:
                capture `idxIdent`, `itIdent`:
                    `loopBody`
                    `nodeVarName`.children.add(`varIdent`)
        )

        # Done
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
                code.add(quote do:
                    let propValue = `propValue`
                    `nodeVarName`.props[`propName`] = propValue
                )

            elif child.kind == nnkStmtList and idx == cmd.len-1:

                # Last one is a statement list, meaning it has children
                hasChildrenAtEnd = true

            elif child.kind == nnkIdent:

                # A single identifier on it's own, this is the same as "name = true"
                let propName = $child
                code.add(quote do:
                    `nodeVarName`.props[`propName`] = true
                )

            else:

                # Something else, unknown
                error("Unable to parse DSL, please check your syntax.", cmd)
            
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

    elif cmd.kind == nnkIfStmt and cmd[0].kind == nnkElifBranch and cmd[0][1].kind == nnkStmtList:

        # A multiline IF statement ... keep it, but replace the inner code
        var innerCode = cmd[0][1]

        # Create empty Group node and empty statement list
        var code = newStmtList()
        let nodeClassIdent = ident"Group"

        # Replace each child in the stmt list
        for idx, child in innerCode:

            # Generate output code
            let gen = componentsConvertSingle(child)

            # Add to the body
            code.add(gen.code)

            # Attach to parent node
            let varIdent = gen.varIdent
            code.add(quote do:
                `nodeVarName`.children.add(`varIdent`)
            )

        # Prepend the node creation, before the IF
        let allCode = newStmtList()
        allCode.add(quote do:
            let `nodeVarName` = `nodeClassIdent`.init()
        )

        # Keep the IF and replace the body
        var newCode = cmd.copyNimTree()
        newCode[0][1] = code
        allCode.add(newCode)

        # Done
        return (allCode, nodeVarName)

    else:

        # Unknown command format
        error("Unable to parse DSL, please check your syntax.", cmd)



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
        error("Unable to parse DSL, please check your syntax.", input)

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