# NimReactive - Documentation

NimReactive is a library for creating graphical user interfaces with Nim, heavily inspired by React Native. A Reactive app can be very simple, for example:

```nim
import reactive

reactiveStart:
    reactiveMount:
        Window:
            Div(text: "Hello world!")
```

Your app begins with the call to `reactiveStart`. You can run your code within the block, mount UI components etc. After it returns, the app will be kept alive until there are no more pending operations on asyncdispatch, and there are no more mounted components.

`reactiveMount:` is a shortcut for quickly creating a and mounting a set of components. In the example above, it creates a window with a text element inside and then mounts it.



## Component DSL

The `reactiveMount:` and `components:` macros allow you to define your component structure. The format of the language is like this:

```nim
ComponentName(propName1: propValue1, propName2: propValue2, ... etc):
    ChildComponent1
    ChildComponent2
    ... etc
```


## Creating components

To create a custom component, subclass the `Component` class.

```nim
import reactive

## My custom component
class MyComponent of Component:

    ## Called when your component is mounted
    method onMount() = discard

    ## Called when your component is updated
    method onUpdate() = discard

    ## Called when your component is unmounted
    method onUnmount() = discard

    ## Render the content of your component
    method render(): Component =

        # {} can be used instead of [] on `this.props` to
        # get a blank value if the prop wasn't specified.
        let label = this.props{"label"}

        # Render UI
        components:
            Window:
                Div(text: label)

## Mount and render
reactiveStart:
    reactiveMount:
        MyComponent(label: "Hello world!")
```




## Component types

- **Generic components:** These components are subclasses of `Component` which don't render anything on their own, but can have their own child heirarchy.

- **Native components:** These are subclasses of `NativeComponent` which override the `onNativeMount()`, `onNativeUpdate()` and `onNativeUnmount()` methods. Native components can do whatever they like in these methods to interact with the native OS.

- **Web components:** These are subclasses of `WebComponent` which override the `renderHTML()` method to return HTML tag info. There are JavaScript hooks which allows these components to perform actions on the Web side.

  > Note that web components are only usable inside of a WebView Bridge component, such as `Window`.

- **WebView Bridge components:** These are special native components which convert child Web components into JavaScript and display them in a WebView.


## Reference

Method              | Description
--------------------|----------------------------
`components:`       | Shortcut for creating a component tree via DSL and returning it.
`reactiveMount:`    | Shortcut for creating and mounting a component tree via DSL. Can be used at any point in the app lifecycle.
`reactiveStart:`    | Defines the code to run at the start of your app.
`.renderAgain()`    | Can be called on any component to notify that the state has changed, and that it should be rendered again.
`.props`            | A table of props that were passed into the component when it was rendered.
`.unmount()`        | Can be called on any component to unmount the entire component tree.

Component           | Type      | Description
--------------------|-----------|----------------
`Div`               | Web       | A `<div>` tag.
`Text`              | Web       | A `<font>` tag.
`TextArea`          | Web       | A `<textarea>` tag with callbacks for when the value changes.
`Window`            | Bridge    | Renders a native window on screen, and allows Web components to be rendered inside.