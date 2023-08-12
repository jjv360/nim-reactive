# Package
version         = "0.3.4"
author          = "Josh Fox"
description     = "Create reactive UI apps"
license         = "MIT"
srcDir          = "src"
installExt      = @["nim", "png", "dll"]


# Dependencies
requires "nim >= 1.6.10"
requires "classes >= 0.3.16"
requires "winim >= 3.9.0"
requires "pixie >= 5.0.6"
# requires "webview >= 0.1.0"
# requires "mummy >= 0.2.7"

## Test script
task test, "Test script":
    exec "nimble install -y"
    exec "nim r examples/notepad.nim"


## Copy WebView2 DLLs from the Visual Studio project
task copyWebView2, "Copy WebView2Wrapper.dll":
    cpFile("extras/WebView2Wrapper/Release/WebView2Wrapper.dll", "src/reactive/windows/native/WebView2Wrapper_i386.dll")
    cpFile("extras/WebView2Wrapper/x64/Release/WebView2Wrapper.dll", "src/reactive/windows/native/WebView2Wrapper_amd64.dll")
    cpFile("extras/WebView2Wrapper/arm64/Release/WebView2Wrapper.dll", "src/reactive/windows/native/WebView2Wrapper_arm64.dll")
    # cpFile("extras/WebView2Wrapper/Release/WebView2Wrapper.lib", "src/reactive/windows/native/WebView2Wrapper_i386.lib")
    # cpFile("extras/WebView2Wrapper/x64/Release/WebView2Wrapper.lib", "src/reactive/windows/native/WebView2Wrapper_amd64.lib")
    # cpFile("extras/WebView2Wrapper/arm64/Release/WebView2Wrapper.lib", "src/reactive/windows/native/WebView2Wrapper_arm64.lib")