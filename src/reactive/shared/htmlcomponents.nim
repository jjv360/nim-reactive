import classes
import ./basecomponent
import ./htmloutput
import ./webview_bridge
import std/oids
import std/tables


##
## Represents an HTML component
class HTMLComponent of Component:

    ## The HTML output
    var htmlOutput: ReactiveHTMLOutput = nil

    ## Update HTML output, return true if the HTML was changed
    method renderHTML(): ReactiveHTMLOutput =

        # Create component output
        let html = ReactiveHTMLOutput.init()
        html.tagName = "div"
        html.setCSSFromProps(this.props)

        # Add inner text if it has any
        if this.props.hasKey("text"):
            html.isTextElement = true
            html.innerText = this.props["text"]

        # Done
        return html

    ## Called on component mount
    method onNativeMount() =

        # Ask the subclass to update it's HTML
        let output = this.renderHTML()
        if output == nil:
            return

        # Store it
        this.htmlOutput = output
        this.htmlOutput.privateTagID = $genOid()
        this.htmlOutput.component = this

        # Get WebViewBridge parent
        let bridge = this.nearestWebBridge()
        if bridge == nil:
            raiseAssert(this.className() & " is an HTML component, it must be rendered inside an HTML-based component (such as a Window).")

        # Notify bridge
        bridge.onHTMLChildUpdate(this, this.htmlOutput, this.getRenderedParentID())


    ## Called on component update
    method onNativeUpdate() =

        # Ask the subclass to update it's HTML
        let output = this.renderHTML()
        if output == nil:
            return

        # Store it and ensure important fields haven't changed
        let originalHtml = this.htmlOutput
        this.htmlOutput = output
        this.htmlOutput.privateTagID = originalHtml.privateTagID
        this.htmlOutput.component = this

        # Get WebViewBridge parent
        let bridge = this.nearestWebBridge()
        if bridge == nil:
            raiseAssert(this.className() & " is an HTML component, it must be rendered inside an HTML-based component (such as a Window).")

        # Notify bridge
        bridge.onHTMLChildUpdate(this, this.htmlOutput, this.getRenderedParentID())


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


    ## Get the element ID of the nearest rendered parent
    method getRenderedParentID(fromComponent: Component = nil): string =

        # Set from
        let fromComp = if fromComponent == nil: this.renderedParent else: fromComponent

        # Check if it's an HTMLComponent and if it has rendered info
        try:
            let htmlComp = HTMLComponent(fromComp)
            if htmlComp.htmlOutput != nil:
                return htmlComp.htmlOutput.privateTagID
        except ObjectConversionDefect:
            discard

        # Not found, continue up the chain
        if fromComp.renderedParent == nil:
            return ""
        else:
            return this.getRenderedParentID(fromComp.renderedParent)


    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) = discard




##
## Represents a <div> tag
class Div of HTMLComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "div"

        # Attach handlers to JavaScript
        if this.props.hasKey("onClick"):
            output.jsOnMount &= ";\n element.onclick = function(e) { window.nimreactiveEmit(element.id, 'event:onClick') } "
            output.jsOnUpdate &= ";\n element.onclick = function(e) { window.nimreactiveEmit(element.id, 'event:onClick') } "

        if this.props.hasKey("onMouseOver"):
            output.jsOnMount &= ";\n element.onmouseover = function(e) { window.nimreactiveEmit(element.id, 'event:onMouseOver') } "
            output.jsOnUpdate &= ";\n element.onmouseover = function(e) { window.nimreactiveEmit(element.id, 'event:onMouseOver') } "

        if this.props.hasKey("onMouseOut"):
            output.jsOnMount &= ";\n element.onmouseout = function(e) { window.nimreactiveEmit(element.id, 'event:onMouseOut') } "
            output.jsOnUpdate &= ";\n element.onmouseout = function(e) { window.nimreactiveEmit(element.id, 'event:onMouseOut') } "

        return output


    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) =

        # Check event
        if name == "event:onClick":

            # Call handler
            let handlerProp = this.props{"onClick"}
            if handlerProp != nil and handlerProp.procValue != nil:
                handlerProp.procValue()
        
        elif name == "event:onMouseOver":

            # Call handler
            let handlerProp = this.props{"onMouseOver"}
            if handlerProp != nil and handlerProp.procValue != nil:
                handlerProp.procValue()
        
        elif name == "event:onMouseOut":

            # Call handler
            let handlerProp = this.props{"onMouseOut"}
            if handlerProp != nil and handlerProp.procValue != nil:
                handlerProp.procValue()




##
## Rendered as a <font> tag
class Text of HTMLComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "font"
        return output
