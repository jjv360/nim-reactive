import classes
import ./basebackend
import std/os


## Locations to search for the Chrome binary. Exposed so that library users can extend it.
var reactiveChromeBinaryLocations*: seq[string] = @[

    # Check if it's on the path
    findExe("chrome"),

    # Common paths on Windows
    "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe", 
    "C:/Program Files (x86)/Google/Application/chrome.exe", 
    "~/AppDataLocal/Google/Chrome/chrome.exe",

    # Common paths on *nix
    "/usr/bin/google-chrome", 
    "/usr/local/sbin/google-chrome", 
    "/usr/local/bin/google-chrome", 
    "/usr/sbin/google-chrome", 
    "/usr/bin/chrome", 
    "/sbin/google-chrome", 
    "/bin/google-chrome",

    # Common paths on MacOS
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "~/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",

]

## Chrome backend
class ChromeBackend of ReactiveBackend:

    # Backend ID
    var id = "chrome"

    # Chrome profile directory


    # Start the backend
    method start() = discard

    ## Find the location of the Chrome binary, or return a blank string if not found
    method findChromeBinaryPath(): string {.static.} =

        # Check environment
        when defined(js):

            # Not supported
            return ""

        else:

            # Go through each path and check if it exists
            for path in reactiveChromeBinaryLocations:
                if path.len > 0:
                    let expandedPath = expandTilde(path)
                    if fileExists(expandedPath):
                        return path

            # Not found
            return ""

    # Check if this backend is available
    method isAvailable(): bool {.static.} = ChromeBackend.findChromeBinaryPath() != ""

    # Create a new window
    method createWindow() =

        # Generate command line arguments
        # See: https://peter.sh/experiments/chromium-command-line-switches/
        # See: https://github.com/puppeteer/puppeteer/blob/756ed705b1ca260c7739d7738bd043260dbe0b88/src/node/Launcher.ts#L204
        var args = @[
            "--app=file://" & (tempPath / "index.html"),
            "--allow-file-access",
            "--allow-file-access-from-files",
            "--window-size=" & windowSize,
            "--user-data-dir=" & (tempPath / "chromedata"),
            "--enable-logging=stderr",
            "--disable-breakpad",
            "--no-first-run"
        ]

