import std/oids
import std/tables
import classes
import ./basecomponent
import ./htmloutput
import ./webview_bridge
import ./basewebcomponent
import ./properties


##
## Represents an HTML component
class WebComponent of BaseWebComponent:

    ## The HTML output
    var htmlOutput: ReactiveHTMLOutput = nil

    ## Update HTML output, return true if the HTML was changed
    method renderHTML(): ReactiveHTMLOutput =

        # Create component output
        let html = ReactiveHTMLOutput.init()
        html.tagName = "div"
        html.setCSSFromProps(this.props)

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

        # Check if it's an WebComponent and if it has rendered info
        try:
            let htmlComp = WebComponent(fromComp)
            if htmlComp.htmlOutput != nil:
                return htmlComp.htmlOutput.privateTagID
        except ObjectConversionDefect:
            discard

        # Not found, continue up the chain
        if fromComp.renderedParent == nil:
            return ""
        else:
            return this.getRenderedParentID(fromComp.renderedParent)




##
## Represents a <div> tag
class View of WebComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "div"

        # Add inner text if it has any
        if this.props.hasKey("text"):
            output.isTextElement = true
            output.innerText = this.props["text"]

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

        if this.props.hasKey("onPointerOver"):
            output.jsOnMount &= ";\n element.onpointerover = function(e) { window.nimreactiveEmit(element.id, 'event:onPointerOver') } "
            output.jsOnUpdate &= ";\n element.onpointerover = function(e) { window.nimreactiveEmit(element.id, 'event:onPointerOver') } "

        if this.props.hasKey("onPointerOut"):
            output.jsOnMount &= ";\n element.onpointerout = function(e) { window.nimreactiveEmit(element.id, 'event:onPointerOut') } "
            output.jsOnUpdate &= ";\n element.onpointerout = function(e) { window.nimreactiveEmit(element.id, 'event:onPointerOut') } "

        return output


    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) =

        # Check event
        if name == "event:onClick":             this.sendEventToProps("onClick")
        elif name == "event:onMouseOver":       this.sendEventToProps("onMouseOver")
        elif name == "event:onMouseOut":        this.sendEventToProps("onMouseOut")
        elif name == "event:onPointerOver":     this.sendEventToProps("onPointerOver")
        elif name == "event:onPointerOut":      this.sendEventToProps("onPointerOut")




##
## Rendered as a <font> tag
class Text of WebComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "font"

        # Add inner text
        output.isTextElement = true
        output.innerText = this.props{"text"}
        return output




##
## Rendered as a <textarea> tag
class TextArea of WebComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "textarea"

        # Add current value
        let js = ";\n element.value = " & this.props{"value"}.string.jsQuotedString()
        output.jsOnMount = js
        output.jsOnUpdate = js

        # Add change listener
        if this.props{"onValue"}:
            let js = ";\n element.oninput = function(e) { window.nimreactiveEmit(element.id, 'event:onValue', e.target.value) } "
            output.jsOnMount &= js
            output.jsOnUpdate &= js

        return output


    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) =

        # Check event
        if name == "event:onValue":
            this.sendEventToProps("onValue", data)






##
## Rendered as an <input> tag
class InputField of WebComponent:

    ## Returns raw HTML component information
    method renderHTML(): ReactiveHTMLOutput =
        let output = super.renderHTML()
        output.tagName = "input"

        # Add current value
        let js = ";\n element.value = " & this.props{"value"}.string.jsQuotedString()
        output.jsOnMount = js
        output.jsOnUpdate = js

        # Add change listener
        if this.props{"onValue"}:
            let js = ";\n element.onchange = function(e) { window.nimreactiveEmit(element.id, 'event:onValue', e.target.value) } "
            output.jsOnMount &= js
            output.jsOnUpdate &= js

        return output


    ## Called when an event is received from the JS side
    method onJsEvent(name: string, data: string) =

        # Check event
        if name == "event:onValue":
            this.sendEventToProps("onValue", data)

