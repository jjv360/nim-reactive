# Nim Reactive

![](https://img.shields.io/badge/status-incomplete-red)
![](https://img.shields.io/badge/platforms-macosx%20windows-darkgreen)

Create UI apps from Nim. See the [Notepad example](./examples/notepad.nim) or run `nimble test` to run it.

```nim
import reactive

reactiveStart:
    reactiveMount:
        Window:
            Div(text: "Hello world!")
```

This library is heavily inspired by React Native, except it's reversed. In React Native, all your logic is in JavaScript with calls into native to render components. With this library, all your logic is in native code with calls to JavaScript to render components.

It also uses the built-in WebView component on all target platforms, so your binary stays nice and small.