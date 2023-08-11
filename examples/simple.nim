##
## Super simple app which just shows a window
import ../src/reactive # import reactive

reactiveStart:
    reactiveMount:
        Window:
            View(text: "Hello world!")