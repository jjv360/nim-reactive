<h2 align="center">Nim Reactive</h2>
<p align="center">Cross-platform app development in Nim</p>
<p align="center">
  <img src="https://img.shields.io/badge/status-experimental-red" />
  <img src="https://img.shields.io/github/issues/jjv360/nim-reactive" />
  <img src="https://img.shields.io/github/license/jjv360/nim-reactive" />
</p>

---

> ⚠️ **Warning:** This is not complete yet.

This is a cross-platform app framework which takes inspiration from React-Native. Build an app once, and deploy to many environments.

## Usage

**Step 1:** Create a new Nim project. Run `nimble init <projectName>` to create a nim **library** (not a binary) project.

**Step 2:** Add Reactive dependency. Copy this into the end of your .nimble file, and then run `nimble install --depsOnly`:

```nim
# Dependency section
requires "https://github.com/jjv360/nim-reactive >= 0.1.2"
requires "https://github.com/jjv360/nim-reactive-web >= 0.1.0"

# Reactive task
import os, sequtils, json
task reactive, "Reactive action":

    # Your app configuration
    var reactiveParams = %* {
        "appID": "org.myapp",
        "title": "My App"
    }

    # Task runner, don't change this
    template reactiveExe(): string = (gorge("nimble path reactive").strip() & "/reactive_task").toExe()
    if not fileExists(reactiveExe): exec "nimble install --depsOnly -y"
    if not fileExists(reactiveExe): raiseAssert("Unable to find the Reactive binary!")
    withDir(thisDir()): exec @[reactiveExe].concat(commandLineParams()).concat(@["--reactive-params:" & $reactiveParams]).quoteShellCommand()
```

**Step 3:** That's it! Now you can run `nimble reactive` to build your app.

## Examples

See some example code here:

- [Calculator](https://github.com/jjv360/nim-reactive-calculator)

## Contributing

To setup your environment:
- Install [VSCode](https://code.visualstudio.com/Download) and [Docker](https://www.docker.com/products/docker-desktop) if you don't have them
- In VSCode, install the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- Open this repo in VSCode, then press the two arrows in the bottom-left, and select Reopen in Container. This will then prepare the dev environment for you.

Then, to build the example app:
- Run `nimble reactiveExample calculator build --platform:web`