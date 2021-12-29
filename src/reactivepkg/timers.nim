import classes
when defined(js):
    import std/dom
    import asyncjs
else:
    import asyncdispatch

## Timer class
classes.class ReactiveTimer:

    ## Internal system timer, if any
    var internalTimer: RootRef = nil

    ## Check if it's repeating or not
    var repeating = false

    ## True if cancelled
    var cancelled = false

    ## Interval in seconds
    var interval : float = 0

    ## Create a repeating timer
    method createRepeating(seconds: float, callback: proc()): ReactiveTimer {.static.} =

        # Create it
        let timer = ReactiveTimer().init()
        timer.interval = seconds
        timer.repeating = true

        # Check engine
        when defined(js):

            # On JS, use setInterval
            timer.internalTimer = setInterval(callback, int(seconds * 1000))

        else:

            # Run native timer loop
            discard timer.nativeTimerLoop(callback)

        # Done
        return timer

    ## Create a once-off timer
    method createOnceOff(seconds: float, callback: proc()): ReactiveTimer {.static.} =

        # Create it
        let timer = ReactiveTimer().init()
        timer.interval = seconds
        timer.repeating = false

        # Check engine
        when defined(js):

            # On JS, use setTimeout
            timer.internalTimer = setTimeout(callback, int(seconds * 1000))

        else:

            # Run native timer loop
            discard timer.nativeTimerLoop(callback)

        # Done
        return timer

    ## Cancel a timer
    method cancel() =

        # Mark it as cancelled
        this.cancelled = true

        # Check engine
        when defined(js):

            # Cancel it
            if this.repeating:
                clearInterval(cast[Interval](this.internalTimer))
            else:
                clearTimeout(cast[TimeOut](this.internalTimer))


    ## Run a native timer loop
    method nativeTimerLoop(callback: proc()) {.async.} =

        # When in native only
        when not defined(js):

            # Forever loop
            while true:
            
                # Sleep for the required amount of time
                await sleepAsync(this.interval * 1000)

                # Check if cancelled
                if this.cancelled:
                    break

                # Run callback
                callback()

                # Stop if not repeating
                if not this.repeating:
                    break
