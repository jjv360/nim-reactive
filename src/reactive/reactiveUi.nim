import macros
import sequtils
import classes

# Global last ID
var lastNodeID {.compileTime.} : uint = 0

## Convert a Call action to Component creation code
proc convertCallToComponentCreation(callNode2: NimNode, outputNode: NimNode, parentComponentVarName: string = "") =

    # Make input mutable
    var callNode = callNode2

    # Ignore comment nodes
    if callNode.kind == nnkCommentStmt:
        return

    # Check node type, it should be a Call
    if callNode.kind != nnkCall and callNode.kind != nnkObjConstr:

        # Attempt to get string representation of input
        callNode = quote do:
            Text(internalTextContent = $(`callNode`))

    # Get name for this variable
    var varName = ident("root")
    var isRootComponent = true
    if parentComponentVarName.len() > 0:

        # Increment the last node ID
        lastNodeID += 1

        # Use as unique variable name
        varName = ident("c" & $lastNodeID)
        isRootComponent = false

    # Ensure the component exists
    let componentType = callNode[0]
    # if componentType.getTypeImpl() == nil:
    #     error("The component '" & componentType.strVal & "' was not found. Have you imported it?", componentType)

    # Create variable and init the component class
    let varNameStr = varName.strVal
    outputNode.add(quote do:
        let `varName` = `componentType`.init()
        `varName`.referenceID = `varNameStr`
    )

    # Go through elements of the call
    for idx, subnode in callNode:

        # Check type
        if subnode.kind == nnkExprEqExpr or subnode.kind == nnkExprColonExpr:

            # Setting a prop ... bind the property symbol so we can type check it
            let propName = subnode[0]
            let propValue = subnode[1]
            # let componentSymbol = bindSym("type " &componentType, brOpen)
            # echo componentSymbol.repr
            # let propFieldSymbol = bindSym($componentType & "()." & $propName)
            # echo propFieldSymbol.repr

            # Set the prop
            outputNode.add(quote do:
                `varName`.`propName` = `propValue`
            )

        elif subnode.kind == nnkStmtList:

            # Child items
            traverseClassStatementList subnode, proc(idx: int, parent: NimNode, node: NimNode) =
                convertCallToComponentCreation(node, outputNode, varName.strVal)

    # Finally, add to parent entity if it's not the root component
    if not isRootComponent:

        let parentIdent = ident(parentComponentVarName)
        outputNode.add(quote do:
            `parentIdent`.children.add(`varName`)
        )

##
## This macro converts our "view language" into actual Nim code. The results go from this:
## 
## var out = reactiveUi:
##      View(backgroundColor="red"):
##          Label(textColor="green"): "Hello world!"
## 
## ... to this:
## 
## var out = block:
## 
##      # Create node
##      var node1 = View.init()
##      node1.backgroundColor = "red"
##      
##      # Create child nodes
##      var node1_1 = label.init()
##      node1_1.textColor = "green"
##      node1.uiDefinitionChildren["node1_1"] = node1_1
## 
##      # Done, output the root node
##      node1
macro reactiveUi*(body: untyped): untyped =

    # Get all root elements
    var rootCalls: seq[NimNode]
    traverseClassStatementList body, proc(idx: int, parent: NimNode, node: NimNode) =
        
        # Add all call statements
        if node.kind == nnkCall or node.kind == nnkObjConstr:
            rootCalls.add(node)

    # Check how many items
    var output: NimNode = nil
    if rootCalls.len() == 0:

        # Nothing, render an empty group
        output = quote do:
            Group.init()

    elif rootCalls.len() == 1:

        # Only a single root entity
        # Create output block
        let blockBody = newStmtList()
        output = newBlockStmt(blockBody)

        # Convert root nodes
        convertCallToComponentCreation(rootCalls[0], blockBody)

        # Finally, output the group
        blockBody.add(ident"root")

    else:

        # Only a single root entity
        # Create output block
        let blockBody = newStmtList()
        output = newBlockStmt(blockBody)

        # Create group component
        let input = quote do:
            Group():
                `body`

        # Convert root nodes
        convertCallToComponentCreation(input, blockBody)

        # Finally, output the group
        blockBody.add(ident"root")        

    # Done
    return output