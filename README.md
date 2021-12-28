<h2 align="center">Nim Reactive</h2>
<p align="center">Cross-platform app development in Nim</p>
<p align="center">
  <img src="https://img.shields.io/badge/status-experimental-red" />
  <img src="https://img.shields.io/github/issues/jjv360/nim-reactive" />
  <img src="https://img.shields.io/github/license/jjv360/nim-reactive" />
</p>

---

This is a cross-platform app framework which takes inspiration from React-Native. Build an app once, and deploy to many environments.

## Usage

**Step 1:** Create a new Nim project. Run `nimble init <projectName>` in the terminal to create a nim **binary** project.

**Step 2:** Add Reactive dependency. Copy this into your .nimble file:

```nim
# Dependency section
requires "https://github.com/jjv360/nim-reactive >= 0.1.0"

# Reactive task
task reactive, "Build the app":
    var params = ""
    var foundSeparator = false
    for i in countup(0, paramCount()):
        if foundSeparator: params &= "\"" & paramStr(i) & "\" "
        if paramStr(i) == "reactive": foundSeparator = true
    exec "nimble install -y"
    exec "~/.nimble/bin/reactive " & params
```

**Step 3:** That's it!

## Contributing

To setup your environment:
- Install [VSCode](https://code.visualstudio.com/Download) if you don't have it
- Install [Docker](https://www.docker.com/products/docker-desktop) if you don't have it
- In VSCode, install the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- Open this repo in VSCode, then press the two arrows in the bottom-left, and select Reopen in Container. This will then prepare the dev environment for you.

To run the binary:
- Run `nimble run` in the terminal

To build an example app:
- Run `nimble example` or `nimble example <examplename>` in the terminal

Design goals for this project:
- Cross-platform apps, ie write once deploy everywhere
- An easy to use layout language
- Fast and efficient state updates
- Use native UI toolkits to integrate as seamlessly wiht the target platform as possible