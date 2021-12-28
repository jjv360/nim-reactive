##
## This is a simple Reactive app which just shows all the standard controls.

import reactive
import classes
import times
import strutils

# Setup main window
component MainWindow of Window:

    # Register as main entry point
    registerAs "main"

    ## Input
    var input = ""

    ## Mode
    var inputMode = false

    # Calculator output
    var memory: float = 0

    # Current operation
    var nextOperation = "+"

    # Render UI
    render:

        # Output screen
        Label(textColor="green"):
            if this.inputMode:
                this.input
            else:
                $this.memory

        # Buttons
        Button(title="1", onClick=proc()=this.addInput("1"))
        Button(title="2", onClick=proc()=this.addInput("2"))
        Button(title="3", onClick=proc()=this.addInput("3"))
        Button(title="4", onClick=proc()=this.addInput("4"))
        Button(title="5", onClick=proc()=this.addInput("5"))
        Button(title="6", onClick=proc()=this.addInput("6"))
        Button(title="7", onClick=proc()=this.addInput("7"))
        Button(title="8", onClick=proc()=this.addInput("8"))
        Button(title="9", onClick=proc()=this.addInput("9"))
        Button(title="0", onClick=proc()=this.addInput("0"))
        Button(title=".", onClick=proc()=this.addInput("."))
        Button(title="+", onClick=proc()=this.setNextOperation("+"))
        Button(title="-", onClick=proc()=this.setNextOperation("-"))
        Button(title="*", onClick=proc()=this.setNextOperation("*"))
        Button(title="/", onClick=proc()=this.setNextOperation("/"))
        Button(title="=", onClick=proc()=this.setNextOperation("="))
        Button(title="Clear", onClick=proc()=this.memory=0;this.input="";this.nextOperation="+";this.updateUi())


    # Add a number input
    method addInput(str: string) =

        # Switch to input mode
        this.inputMode = true

        # Special case: If adding a decimal and the input already has a decimal, ignore this
        if str == "." and str in this.input:
            return

        # Update input
        this.input &= str
        this.updateUi()


    # Set the next operation
    method setNextOperation(op: string) =

        # Perform the last pending operation
        if this.nextOperation == "+":
            this.memory += parseFloat(this.input)
        elif this.nextOperation == "*":
            this.memory *= parseFloat(this.input)
        elif this.nextOperation == "-":
            this.memory -= parseFloat(this.input)
        elif this.nextOperation == "/":
            this.memory /= parseFloat(this.input)
        elif this.nextOperation == "=":
            discard#this.memory = parseFloat(this.input)

        # Reset input
        this.input = ""
        this.inputMode = false
        this.updateUi()

        # Store next operation
        this.nextOperation = op

    



# Setup Reactive environment
Reactive:

    # All config fields are optional. This here lists them all set to their defaults.

    # General config options
    config "mainWindow", "main"

    # Enable web platform
    platform "web":
        config "baseUrl", "./"