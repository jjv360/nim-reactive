##
## Helpers to dynamically load a DLL
import std/os
import std/tempfiles
import std/exitprocs
import std/dynlib
import std/macros

# Export things that users of our macro need
export tempfiles, exitprocs, os, dynlib


## Replace defined procs with their dynamic loader versions
proc replaceProcsIn(statements: NimNode, loaderFunctionIdent: NimNode) =

    # Go through statements
    for idx, statement in statements:

        # Check type
        if statement.kind == nnkProcDef and statement.body.kind == nnkEmpty:

            # A proc without a body, this is what we're looking for...
            let procDef = statement
            let procName = procDef.name
            var procNameStr = $procName

            # Create the proc type definition
            let typeDef = newNimNode(nnkProcTy)
            typeDef.add(procDef.params)
            typeDef.add(procDef.pragma)

            # Remove importc:"" pragma if it exists, use it to replace the function name
            if typeDef.pragma.kind != nnkEmpty:
                for idx, pragma in typeDef.pragma:
                    if pragma.kind == nnkExprColonExpr and $pragma[0] == "importc":
                        procNameStr = $pragma[1]
                        typeDef.pragma.del(idx)
                        break

            # Set wrapper code for the function
            procDef.body = quote do:

                # Var to store the actual function pointer
                type FunctionType = `typeDef`
                var functionPointer {.global.} : FunctionType = nil

                # Load the function if it's not loaded already
                if functionPointer == nil:
                
                    # First ensure the lib is loaded
                    let handle = `loaderFunctionIdent`()

                    # Load the function from the lib
                    let p = handle.symAddr(`procNameStr`)
                    functionPointer = cast[FunctionType](p)

                    # Stop if not found
                    if functionPointer == nil:
                        raise newException(OSError, "Unable to find dynamic function: " & `procNameStr`)

                # Done, call and return it
                return functionPointer()

            # Inject param names into the final return statement
            for idx2, param in procDef.params:

                # Ignore the first one (it's the return type)
                if idx2 == 0:
                    continue

                # Add it
                # echo "Adding " & param[0].treeRepr
                let returnStmt = procDef.body[procDef.body.len-1]
                let callStmt = returnStmt[0]
                callStmt.add(param[0])

            # If function doesn't have a return type, remove the "return" part of the last call
            if procDef.params[0].kind == nnkEmpty:
                procDef.body[procDef.body.len-1] = procDef.body[procDef.body.len-1][0]

        else:

            # Process children as well
            replaceProcsIn(statement, loaderFunctionIdent)
            


## Define proc's to import from a dynamic library. All defined proc's will attempt to load the library the first time they're called.
macro dynamicImport*(libName: static[string], code: untyped) =

    # Sanity checks
    if code.kind != nnkStmtList: error("Expected a statement list.", code)

    # Identifiers
    let loaderFunctionIdent = genSym(nskProc, "dynamicImportLoadLib")

    # Go through all defined procs and replace them
    replaceProcsIn(code, loaderFunctionIdent)

    # Export the loader function
    code.insert(0, quote do:
        
        ## Library loader
        proc `loaderFunctionIdent`(): LibHandle =

            # Stop if already loaded
            var handle {.global.} : LibHandle = nil
            if handle != nil:
                return handle

            # Load it
            handle = loadLib(`libName`)
            if handle == nil:
                raise newException(OSError, "Unable to load library: " & `libName`)

            # Done
            return handle
        
    )

    # Done
    return code


## Define proc's to import from an embedded dynamic library. This will save the lib to a temporary folder and load it from there.
macro dynamicImportFromData*(libName: static[string], libData: static[string], code: untyped) =

    # Sanity checks
    if code.kind != nnkStmtList: error("Expected a statement list.", code)

    # Identifiers
    let loaderFunctionIdent = genSym(nskProc, "dynamicImportLoadLib")

    # Go through all defined procs and replace them
    replaceProcsIn(code, loaderFunctionIdent)

    # Export the loader function
    code.insert(0, quote do:
        
        ## Library loader
        proc `loaderFunctionIdent`(): LibHandle =

            # Stop if already loaded
            var handle {.global.} : LibHandle = nil
            if handle != nil:
                return handle

            # Save the DLL to a temporary file
            let libTempPath = genTempPath("NimReactive", "_" & hostCPU & "_" & `libName`)
            writeFile(libTempPath, `libData`)

            # Delete the DLL on exit
            # TODO: Why would an exit proc not be GC-safe? The app is exiting, all memory will get removed anyway...
            {.gcsafe.}:
                addExitProc(proc() =

                    # Unload the DLL so the file is deletable
                    if handle != nil:
                        handle.unloadLib()

                    # Delete it
                    try:
                        removeFile(libTempPath)
                    except OSError:
                        echo "Unable to delete temporary file: " & libTempPath

                )

            # Load it
            handle = loadLib(libTempPath)
            if handle == nil:
                raise newException(OSError, "Unable to load library: " & `libName`)

            # Done
            return handle
        
    )

    # Done
    return code