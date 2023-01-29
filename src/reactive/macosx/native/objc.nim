##
## Functions for interacting with Objective-C
import std/macros
import std/strutils

# Link required libraries
{.passC:"-x objective-c".}
{.passL:"-framework Foundation".}
{.passL:"-lobjc".}


#### Generic types

## Any kind of Objective-C reference
type Id* = distinct pointer

## Id comparison
proc `==`*(a: Id, b: Id): bool = a.pointer == b.pointer

## Describes an unsigned integer.
type NSUInteger* = uint

## The maximum value for an NSUInteger.
let NSUIntegerMax* {.importc, header:"<objc/objc.h>".} : NSUInteger




## Macro to help define Objective-C class imports
macro objcImport*(code: untyped) =

    # Sanity checks
    if code.kind != nnkStmtList: error("Expected a statement list.", code)
    # echo code.treeRepr
    
    # Go through code line by line
    var commentNode = newEmptyNode()
    var headerName = ""
    var idx = 0
    while idx < code.len:

        # Check command
        let cmd = code[idx]
        if cmd.kind == nnkCommand and $cmd[0] == "header":

            # Store header reference for future use
            headerName = $cmd[1]
            code[idx] = newEmptyNode()

        elif cmd.kind == nnkCommentStmt:

            # Store comment for future use
            commentNode = cmd
            code[idx] = newEmptyNode()

        elif cmd.kind == nnkCommand and $cmd[0] == "importClass":

            # Class output
            if cmd[1].kind != nnkInfix: error("Expected syntax: importClass ClassName of SuperclassName", cmd)
            if headerName == "": error("Missing header command.", cmd)
            let classIdent = cmd[1][1]
            let superclassIdent = cmd[1][2]
            let allocWrapperImport = $classIdent & " alloc"
            let allocWrapperIdent = genSym(nskProc, "allocWrapper")
            let allocIdent = ident"alloc"

            # Output class type
            code[idx] = quote do:

                # Define the class
                `commentNode`
                type `classIdent`* = distinct `superclassIdent`

                # Converter to parent
                converter toParent*(input: `classIdent`): `superclassIdent` = `superclassIdent`(input)

                # Converter to pointer
                converter toPointer*(input: `classIdent`): pointer = input.pointer

                # Converter to Id
                converter toId*(input: `classIdent`): Id = Id(input)

                proc `allocWrapperIdent`(): `classIdent` {.importobjc:`allocWrapperImport`, header:`headerName`.}
                ## Allocate memory for this object ... it's a usual pattern in ObjC to do [[MyClass alloc] init] for construction (ie alloc is a separate call)
                proc `allocIdent`*(_: typedesc[`classIdent`]): `classIdent` = `allocWrapperIdent`()

            # Comment is consumed
            commentNode = newNimNode(nnkEmpty)

        elif cmd.kind == nnkCommand and $cmd[0] == "importValue":

            # Value output
            if cmd[1].kind != nnkIdent: error("Expected syntax: importValue VarName: Type", cmd)
            if cmd[2].kind != nnkStmtList: error("Expected syntax: importValue VarName: Type", cmd)
            if cmd[2][0].kind != nnkIdent: error("Expected syntax: importValue VarName: Type", cmd)
            if headerName == "": error("Missing header command.", cmd)
            let varName = cmd[1]
            let varType = cmd[2][0]

            # Output value
            code[idx] = quote do:

                # Define the value
                `commentNode`
                let `varName`* {.importc, header:`headerName`.} : `varType`

            # Comment is consumed
            commentNode = newEmptyNode()

        elif cmd.kind == nnkCall and $cmd[0] == "importClassMethods":

            # Check input
            if headerName == "": error("Missing header command.", cmd)
            if cmd[1].kind != nnkIdent: error("Expected an identifier for the first argument.", cmd)
            if cmd[2].kind != nnkStmtList: error("Expected a statement list.", cmd)
            let classIdent = cmd[1]
            let statements = cmd[2]
            code[idx] = newEmptyNode()

            # Go through each definition
            for idx2, cmd2 in statements:

                # Attach this command directly
                code.insert(idx, cmd2)
                idx += 1

                # Check type
                if cmd2.kind == nnkCommentStmt:

                    # Store comment for future use
                    commentNode = cmd

                elif cmd2.kind == nnkProcDef:

                    # Attach the class instance as the first arg
                    let formalParams = cmd2[3]
                    let thisArg = newIdentDefs(ident"this", classIdent)
                    formalParams.insert(1, thisArg)

                    # Ensure the pragma section exists
                    if cmd2[4].kind == nnkEmpty: cmd2[4] = newNimNode(nnkPragma)
                    let pragmas = cmd2[4]

                    # Get proc name
                    var procIdent = cmd2[0]
                    if procIdent.kind == nnkPostfix:
                        procIdent = procIdent[procIdent.len - 1]

                    # Attach importobjc pragma ... check if this is an assignment though, which uses a special naming convesion, ie `item=` becomes `setItem:`
                    let procName = $procIdent
                    if procName.endsWith("="):
                        pragmas.add(newColonExpr(
                            ident"importobjc", 
                            newStrLitNode("set" & procName.substr(0, 0).toUpper() & procName.substr(1, procName.len - 2))
                        ))
                    else:
                        pragmas.add(ident"importobjc")

                    # Attach header
                    pragmas.add(newColonExpr(
                        ident"header", 
                        newStrLitNode(headerName)
                    ))

        elif cmd.kind == nnkCall and $cmd[0] == "importStaticMethods":

            # Check input
            if headerName == "": error("Missing header command.", cmd)
            if cmd[1].kind != nnkIdent: error("Expected an identifier for the first argument.", cmd)
            if cmd[2].kind != nnkStmtList: error("Expected a statement list.", cmd)
            let classIdent = cmd[1]
            let statements = cmd[2]
            code[idx] = newEmptyNode()

            # Go through each definition
            for idx2, cmd2 in statements:

                # Attach this command directly
                code.insert(idx, cmd2)
                idx += 1

                # Check type
                if cmd2.kind == nnkCommentStmt:

                    # Store comment for future use
                    commentNode = cmd

                elif cmd2.kind == nnkProcDef:

                    # Make a copy of this function
                    let funcCopy = cmd2.copyNimTree()
                    code.insert(idx-1, funcCopy)
                    idx += 1

                    # Ensure copy is not exported .. this also ensures the function name (idx=0) is an Ident
                    if funcCopy[0].kind == nnkPostfix:
                        funcCopy[0] = funcCopy[0][funcCopy[0].len - 1]

                    # Rename the copy to something hidden
                    let funcCopyIdent = genSym(nskProc, "wrapper")
                    funcCopy[0] = funcCopyIdent

                    # Ensure the pragma section exists on the copy
                    if funcCopy[4].kind == nnkEmpty: funcCopy[4] = newNimNode(nnkPragma)
                    let pragmas = funcCopy[4]

                    # Attach importobjc pragma to the copy
                    var funcName = cmd2[0]
                    if funcName.kind == nnkPostfix: funcName = funcName[funcName.len - 1]
                    pragmas.add(newColonExpr(
                        ident"importobjc",
                        newStrLitNode($classIdent & " " & $funcName)
                    ))

                    # Attach header to the copy
                    pragmas.add(newColonExpr(
                        ident"header", 
                        newStrLitNode(headerName)
                    ))

                    # The copy/wrapper function is done! Now we just need to attach a body to the main function to call it... First create a list of arguments
                    let formalParams = cmd2[3]
                    var args: seq[NimNode]
                    for i in 1 ..< formalParams.len:
                        args.add(formalParams[i][0])

                    # Attach the body to call it
                    cmd2[6] = newStmtList(
                        newCall(funcCopyIdent, args)
                    )

                    # Get the typedesc representation of this class
                    let classTypedesc = newNimNode(nnkBracketExpr)
                    classTypedesc.add(ident"typedesc")
                    classTypedesc.add(classIdent)

                    # Add the typedesc as the first argument to the original function
                    formalParams.insert(1, newIdentDefs(
                        ident"_",
                        classTypedesc
                    ))

        # elif cmd.kind == nnkCommand:

        #     # Unknown command
        #     echo cmd.treeRepr
        #     error("Unknown import command: " & $cmd[0], cmd)

        # else:

            # Unknown code, just keep it as is
            # echo cmd.treeRepr
            # raiseAssert("s")
            # discard

        # Next index
        idx += 1

    # echo "====="
    # echo code.repr
    # echo ""
    # echo ""
    # raiseAssert("DD")
    return code