' PB_ThreadFunctions.inc


FUNCTION funWaitForThreads(ThreadToWaitFor AS LONG, hThread() AS LONG, _
                           StartThreadIndex AS LONG) AS LONG
' wait for treads to finish
  LOCAL Looper           AS LONG
  LOCAL RetVal           AS LONG
  LOCAL TotalThreadCount AS LONG
  LOCAL LastError        AS LONG
  LOCAL ThreadBatch      AS LONG

  '
  DO
    ThreadBatch = MIN(%MAXIMUM_WAIT_OBJECTS, ThreadToWaitFor) 'Do wait for a batch of threads
    RetVal = WaitForMultipleObjects(ThreadBatch, _ 'MAXIMUM_WAIT_OBJECTS = 64
                                  BYVAL VARPTR(hThread(StartThreadIndex)), _
                                  %TRUE, %INFINITE)
    LastError = GetLastError 'Check if successfull or if an error occured
    SELECT CASE RetVal
      CASE %WAIT_OBJECT_0
        IF 01 THEN 'Use zero to bypass following status MessageBox
          funLog "Total threads" & STR$(TotalThreadCount) & $CRLF & _
                 "Current group size is" & STR$(ThreadBatch)     & $CRLF & _
                 "Thread index " & STR$(StartThreadIndex) & " to " & _
                 STR$(StartThreadIndex + ThreadBatch - 1) & " done..."
        END IF
        '
      CASE %WAIT_ABANDONED_0
        funLog "WAIT_ABANDONED_0"
        '
      CASE %WAIT_TIMEOUT
        funLog "WAIT_TIMEOUT"
        '
      CASE %WAIT_FAILED
        funLog WinError$(LastError)
        '
      CASE ELSE
        funLog WinError$(LastError)
        '
    END SELECT
    '
    StartThreadIndex += %MAXIMUM_WAIT_OBJECTS
    ThreadToWaitFor  -= %MAXIMUM_WAIT_OBJECTS
  LOOP WHILE ThreadToWaitFor > 0
  '
END FUNCTION
'
FUNCTION WinError$(BYVAL ErrorIndex AS LONG) AS STRING
 ' report on errors
 LOCAL zBuffer AS ASCIIZ * 1024

 FormatMessage(%FORMAT_MESSAGE_FROM_SYSTEM, BYVAL %NULL, ErrorIndex, %NULL, ZBuffer, SIZEOF(ZBuffer), BYVAL %NULL)
 REPLACE $CRLF WITH $SPC IN zBuffer
 FUNCTION = "Error" & STR$(ErrorIndex) & ": " & zBuffer

END FUNCTION
