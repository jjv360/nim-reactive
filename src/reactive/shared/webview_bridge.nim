import classes
import std/oids

##
## Communicates between a WebView and the native app
class WebViewBridge:

    ## Instance ID
    var instanceID : string = $genOid()
    
    ## Generate HTML boilerplate which is loaded into the WebView to start the connection
    method getHTMLBoilerplate(): string = """
        <!DOCTYPE html>
        <html>
            <head>
                <title>App</title>
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            </head>
            <body>

                <!-- Web app default styling -->
                <style>
                    html, body {
                        margin: 0px;
                        padding: 0px;
                    }
                </style>

                <!-- App code -->
                <h1>HERE</h1>
                <script>
                
                </script>
                
            </body>
        </html>
    """