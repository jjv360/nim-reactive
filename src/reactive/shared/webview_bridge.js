//
// This is the WebView side of the bridge.

// Vars
let overlayDiv = null
let ws = null

/** Called on startup */
window.addEventListener('DOMContentLoaded', function() {

    // Create status overlay
    // overlayDiv = document.createElement('div')
    // overlayDiv.style.cssText = "position: fixed; top: 0px; left: 0px; width: 100%; background-color: rgba(0, 0, 0, 0.9); padding: 20px; box-sizing: border-box; color: white; font-family: Arial, sans-serif; "
    // document.body.appendChild(overlayDiv)

    // // Start websocket
    // startWebSocket()

})

/** Start the web socket */
function startWebSocket() {

    // Stop old one if any
    ws?.close()

    // Create new one
    overlayDiv.innerText = "Status: Connecting"
    ws = new WebSocket(window.nimreactive.websocketAddress)
    ws.onclose = () => {
        overlayDiv.innerText = "Status: Closed"
        setTimeout(startWebSocket, 100)
    }
    ws.onopen = () => overlayDiv.innerText = "Status: Open"
    ws.onmessage = e => overlayDiv.innerText = "Msg: " + e.data

}