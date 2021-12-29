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

**Step 2:** Add Reactive dependency. Copy this into the end of your .nimble file:

```nim
# Dependency section
requires "https://github.com/jjv360/nim-reactive >= 0.1.2"
requires "https://github.com/jjv360/nim-reactive-web >= 0.1.0"

# Reactive task ... ensures dependencies are installed and forwards commands to Reactive
import os
task reactive, "Reactive action":
    var params = @[gorge("nimble path reactive").strip() & "/reactive"]; var foundSeparator = false
    for param in commandLineParams():
        if foundSeparator: params.add(param)
        if param == "reactive": foundSeparator = true
    exec "nimble install -y"; exec params.quoteShellCommand
```

**Step 3:** That's it! Now you can run `nimble reactive web path/to/app.nim` to build your app for `web`.

## Examples

See some example code here:

- [Calculator](https://github.com/jjv360/nim-reactive-calculator)

## Contributing

To setup your environment:
- Install [VSCode](https://code.visualstudio.com/Download) and [Docker](https://www.docker.com/products/docker-desktop) if you don't have them
- In VSCode, install the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- Open this repo in VSCode, then press the two arrows in the bottom-left, and select Reopen in Container. This will then prepare the dev environment for you.