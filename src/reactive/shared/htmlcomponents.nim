import classes
import ./basecomponent
import ./htmloutput
import ./webview_bridge
import std/oids


##
## Represents an HTML component
class HTMLComponent of BaseComponent:

    ## The HTML output
    var htmlOutput: ReactiveHTMLOutput = nil

    ## Update HTML output, return true if the HTML was changed
    method renderHTML(): ReactiveHTMLOutput = nil

    ## Called on component mount
    method onNativeMount() =

        # Ask the subclass to update it's HTML
        let output = this.renderHTML()
        if output == nil:
            return

        # Store it
        this.htmlOutput = output
        this.htmlOutput.privateTagID = $genOid()

        # Get WebViewBridge parent
        let bridge = this.nearestWebBridge()
        if bridge == nil:
            raiseAssert(this.className() & " is an HTML component, it must be rendered inside an HTML-based component (such as a Window).")

        # Notify bridge
        bridge.onHTMLChildUpdate(this, this.htmlOutput)


    ## Called on component unmount
    method onNativeUnmount() =

        # Stop if not rendered anyway
        if this.htmlOutput == nil:
            return

        # Get WebViewBridge parent
        let bridge = this.nearestWebBridge()
        if bridge == nil:
            return

        # Notify bridge
        bridge.onHTMLChildRemove(this, this.htmlOutput)

        # Done
        this.htmlOutput = nil




##
## Represents a <div> tag
class Div of HTMLComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =

        # Create component output
        let html = ReactiveHTMLOutput.init()
        html.tagName = "div"
        html.setCSSFromProps(this.props)

        # Done
        return html


## Represents text inside an element
class Text of HTMLComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =

        # Create component output
        let html = ReactiveHTMLOutput.init()
        html.tagName = "font"
        html.setCSSFromProps(this.props)
        html.isTextElement = true
        html.innerText = this.props{"text"}

        # Done
        return html