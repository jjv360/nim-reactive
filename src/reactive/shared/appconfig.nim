import std/json
import std/os
import classes
import ./app

## Allows the app to read and write user configuration options
singleton ReactiveAppConfig:

    ## All current options
    var json : JsonNode = newJObject()

    ## Constructor
    method init() =

        # Catch errors
        try:

            # Load json
            let configPath = ReactiveApp.dataDir / "config.json"
            if fileExists(configPath):
                this.json = parseFile(configPath)

        except:

            # Failed
            echo "[Reactive] Unable to load config: " & getCurrentExceptionMsg()
            

    ## Get a value from the config
    method get(key : string) : JsonNode =
        return this.json{key}


    ## Get a value from the config
    method getString(key : string) : string =
        return this.json{key}.getStr("")


    ## Get a list of strings
    method getStrings(key : string) : seq[string] =

        # Collect strings
        var strs : seq[string]
        for str in this.json{key}.getElems():
            if str.kind == JString:
                strs.add(str.str)

        # Done
        return strs


    ## Get a list of objects
    method getObjects(key : string) : seq[JsonNode] = this.json{key}.getElems()

            
    ## Put a value to the config
    method set(key : string, value : string) =
        this.json[key] = %value
        this.save()

            
    ## Put a value to the config
    method set(key : string, value : JsonNode) =
        this.json[key] = value
        this.save()


    ## Put a list of strings
    method set(key : string, values : seq[string]) =

        # Create array
        var arr = newJArray()
        for str in values:
            arr.add(%str)

        # Set
        this.json[key] = arr
        this.save()


    ## Add a string to a list of strings
    method add(key : string, value : string) =

        # Get current list
        var values = this.getStrings(key)

        # Add it
        values.add(value)
        this.set(key, values)


    ## Add an object to a list of objects
    method add(key : string, value : JsonNode) =

        # Get current list
        var values = this.json{key}
        if values == nil or values.kind != JArray:
            values = newJArray()

        # Add it
        values.add(value)
        this.set(key, values)


    ## Save config
    method save() =

        # Ensure directory exists
        let configPath = ReactiveApp.dataDir / "config.json"
        discard existsOrCreateDir(configPath.parentDir)

        # Save JSON
        writeFile(configPath, this.json.pretty(4))