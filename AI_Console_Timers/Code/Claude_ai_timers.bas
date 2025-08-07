#COMPILE EXE
#DIM ALL

' PowerBASIC Console Timer Demonstration
' This program demonstrates various timer techniques in PowerBASIC

#INCLUDE "WIN32API.INC"

DECLARE FUNCTION GetTickCount LIB "KERNEL32.DLL" () AS DWORD
'DECLARE SUB Sleep LIB "KERNEL32.DLL" ALIAS "Sleep" (BYVAL dwMilliseconds AS DWORD)

FUNCTION PBMAIN () AS LONG
    LOCAL startTime, currentTime, elapsedTime AS DWORD
    LOCAL counter, maxCount AS LONG
    LOCAL userInput AS STRING
    LOCAL choice AS LONG
    LOCAL timerInterval AS DWORD

    CLS
    PRINT "PowerBASIC Timer Demonstration"
    PRINT STRING$(40, "=")
    PRINT

    DO
        PRINT "Choose a timer demonstration:"
        PRINT "1. Simple elapsed time timer"
        PRINT "2. Countdown timer"
        PRINT "3. Periodic timer with counter"
        PRINT "4. Stopwatch timer"
        PRINT "5. Performance timing test"
        PRINT "0. Exit"
        PRINT
        PRINT "Enter your choice (0-5): ";

        LINE INPUT userInput
        choice = VAL(userInput)
        PRINT

        SELECT CASE choice
            CASE 1
                CALL DemoElapsedTimer
            CASE 2
                CALL DemoCountdownTimer
            CASE 3
                CALL DemoPeriodicTimer
            CASE 4
                CALL DemoStopwatch
            CASE 5
                CALL DemoPerformanceTiming
            CASE 0
                PRINT "Goodbye!"
                EXIT DO
            CASE ELSE
                PRINT "Invalid choice. Please try again."
        END SELECT

        PRINT
        PRINT "Press Enter to continue..."
        LINE INPUT userInput
        CLS
    LOOP

    FUNCTION = 0
END FUNCTION

' Demonstration 1: Simple Elapsed Time Timer
SUB DemoElapsedTimer
    LOCAL startTime, currentTime AS DWORD
    LOCAL seconds AS LONG

    PRINT "=== Simple Elapsed Time Timer ==="
    PRINT "Timer will run for 10 seconds, showing elapsed time..."
    PRINT "Press Ctrl+C to interrupt if needed"
    PRINT

    startTime = GetTickCount()

    FOR seconds = 1 TO 10
        SLEEP(1000)  ' Wait 1 second
        currentTime = GetTickCount()
        PRINT "Elapsed time: " & FORMAT$(seconds) & " seconds (" & FORMAT$(currentTime - startTime) & " ms)"
    NEXT seconds

    PRINT
    PRINT "Timer demonstration complete!"
END SUB

' Demonstration 2: Countdown Timer
SUB DemoCountdownTimer
    LOCAL countdown AS LONG
    LOCAL userInput AS STRING

    PRINT "=== Countdown Timer ==="
    PRINT "Enter countdown time in seconds: ";
    LINE INPUT userInput
    countdown = VAL(userInput)

    IF countdown <= 0 THEN
        PRINT "Invalid time entered."
        EXIT SUB
    END IF

    PRINT
    PRINT "Starting countdown from " & FORMAT$(countdown) & " seconds..."
    PRINT

    WHILE countdown > 0
        PRINT "Time remaining: " & FORMAT$(countdown) & " seconds"
        SLEEP(1000)
        DECR countdown
    WEND

    PRINT
    PRINT "*** TIME'S UP! ***"

    ' Beep to signal completion (if system supports it)
    PRINT CHR$(7);  ' Bell character
END SUB

' Demonstration 3: Periodic Timer with Counter
SUB DemoPeriodicTimer
    LOCAL counter, maxCount AS LONG
    LOCAL intervalMs AS DWORD
    LOCAL startTime, lastTime, currentTime AS DWORD

    PRINT "=== Periodic Timer with Counter ==="
    PRINT "This timer will tick every 500ms for 20 iterations"
    PRINT

    counter = 0
    maxCount = 20
    intervalMs = 500

    startTime = GetTickCount()
    lastTime = startTime

    WHILE counter < maxCount
        currentTime = GetTickCount()

        IF (currentTime - lastTime) >= intervalMs THEN
            INCR counter
            PRINT "Tick #" & FORMAT$(counter) & " at " & FORMAT$(currentTime - startTime) & "ms"
            lastTime = currentTime
        END IF

        SLEEP(10)  ' Small sleep to prevent excessive CPU usage
    WEND

    PRINT
    PRINT "Periodic timer completed " & FORMAT$(maxCount) & " iterations."
END SUB

' Demonstration 4: Stopwatch Timer
SUB DemoStopwatch
    LOCAL startTime, currentTime, elapsedMs AS DWORD
    LOCAL running AS LONG
    LOCAL userInput AS STRING

    PRINT "=== Stopwatch Timer ==="
    PRINT "Commands:"
    PRINT "  S = Start/Stop"
    PRINT "  R = Reset"
    PRINT "  Q = Quit"
    PRINT

    startTime = 0
    elapsedMs = 0
    running = 0

    DO
        IF running THEN
            currentTime = GetTickCount()
            elapsedMs = currentTime - startTime
            PRINT CHR$(13) & "Elapsed: " & FormatTime(elapsedMs) & " [RUNNING] (S=Stop, R=Reset, Q=Quit)";
        ELSE
            PRINT CHR$(13) & "Elapsed: " & FormatTime(elapsedMs) & " [STOPPED] (S=Start, R=Reset, Q=Quit)";
        END IF

        ' Check for keypress (simplified - in real app you might use more sophisticated input)
        SLEEP(100)

        ' Simulate getting user input (in a real console app, you'd need non-blocking input)
        ' For demonstration, we'll run for a few seconds then break
        STATIC demoCounter AS LONG
        INCR demoCounter

        IF demoCounter = 1 THEN
            PRINT
            PRINT
            PRINT "Starting stopwatch..."
            startTime = GetTickCount()
            running = -1
        ELSEIF demoCounter = 30 THEN  ' About 3 seconds
            PRINT
            PRINT
            PRINT "Stopping stopwatch..."
            running = 0
        ELSEIF demoCounter = 50 THEN  ' About 5 seconds total
            PRINT
            PRINT
            PRINT "Resetting and exiting stopwatch demo..."
            EXIT DO
        END IF

    LOOP
END SUB

' Demonstration 5: Performance Timing Test
SUB DemoPerformanceTiming
    LOCAL startTime, endTime, elapsedMs AS DWORD
    LOCAL i, iterations AS LONG
    LOCAL testValue AS DOUBLE

    PRINT "=== Performance Timing Test ==="
    PRINT "Testing performance of mathematical operations..."
    PRINT

    iterations = 1000000

    ' Test 1: Simple arithmetic
    PRINT "Test 1: " & FORMAT$(iterations) & " arithmetic operations..."
    startTime = GetTickCount()

    FOR i = 1 TO iterations
        testValue = i * 3.14159 / 2.71828
    NEXT i

    endTime = GetTickCount()
    elapsedMs = endTime - startTime

    PRINT "Completed in: " & FORMAT$(elapsedMs) & " milliseconds"
    PRINT "Operations per second: " & FORMAT$(iterations / (elapsedMs / 1000.0), "###,###,##0")
    PRINT

    ' Test 2: String operations
    PRINT "Test 2: String concatenation test..."
    startTime = GetTickCount()

    LOCAL testString AS STRING
    testString = ""

    FOR i = 1 TO 10000
        testString = testString + STR$(i)
    NEXT i

    endTime = GetTickCount()
    elapsedMs = endTime - startTime

    PRINT "String length: " & FORMAT$(LEN(testString)) & " characters"
    PRINT "Completed in: " & FORMAT$(elapsedMs) & " milliseconds"
    PRINT

    PRINT "Performance timing tests completed."
END SUB

' Helper function to format milliseconds as MM:SS.mmm
FUNCTION FormatTime(BYVAL milliseconds AS DWORD) AS STRING
    LOCAL minutes, seconds, ms AS LONG
    LOCAL result AS STRING

    minutes = milliseconds \ 60000
    seconds = (milliseconds MOD 60000) \ 1000
    ms = milliseconds MOD 1000

    result = FORMAT$(minutes, "00") & ":" & FORMAT$(seconds, "00") & "." & FORMAT$(ms, "000")

    FUNCTION = result
END FUNCTION
