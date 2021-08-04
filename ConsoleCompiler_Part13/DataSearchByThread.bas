#COMPILE EXE
#DIM ALL

#INCLUDE "Win32Api.inc"

GLOBAL a_strWork() AS STRING

#INCLUDE "PB_FileHandlingRoutines.inc"

$DataFile = "MyLargeFile.txt"

TYPE udtSearchCriteria
  lngThread AS LONG
  lngStart AS LONG
  lngEnd AS LONG
  lngColumn AS LONG
  strCriteria AS STRING *50
END TYPE

FUNCTION PBMAIN () AS LONG
  '
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  LOCAL strHeaders AS STRING
  '
  LOCAL uSearchCriteria_1 AS udtSearchCriteria
  LOCAL uSearchCriteria_2 AS udtSearchCriteria
  '
  DIM idThread(1 TO 2) AS LONG
  DIM idThreadStatus(1 TO 2) AS LONG
  '
  CON.CAPTION$= "Data analysis"
  CON.COLOR 10,0
  '
  IF ISTRUE funReadTheFileIntoAnArray($DataFile, a_strWork()) THEN
  ' the function worked
    CON.STDOUT "File read into array of " & _
               FORMAT$(UBOUND(a_strWork)) & " records"
  '
    PREFIX "uSearchCriteria_1."
      lngThread = 1
      lngStart = 1
      lngEnd = UBOUND(a_strWork)
      lngColumn = 5
      strCriteria = "Blue"
    END PREFIX
    '
    THREAD CREATE funReadArray(BYVAL VARPTR(uSearchCriteria_1)) _
                               TO idThread(1)
    PREFIX "uSearchCriteria_2."
      lngStart = 1
      lngEnd = UBOUND(a_strWork)
      lngColumn = 6
      strCriteria = "B RhD positive (B+)"
    END PREFIX
    '
    ' now read data from the array
    THREAD CREATE funReadArray(BYVAL VARPTR(uSearchCriteria_2)) _
                               TO idThread(2)
    ' what happens now?
    ' are they both finished?
    LOCAL TotalThreadCount AS LONG
    TotalThreadCount = 2
    funWaitForThreads(TotalThreadCount, idThread(), 1)
  '
  ELSE
    CON.STDOUT "Unable to read the input file"
  END IF
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
END FUNCTION
'
FUNCTION funWaitForThreads(ThreadToWaitFor AS LONG, hThread() AS LONG, _
                           StartThreadIndex AS LONG) AS LONG
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
      CASE %WAIT_OBJECT_0    : IF 01 THEN 'Use zero to bypass following status MessageBox
                               CON.STDOUT "Total threads" & STR$(TotalThreadCount) & $CRLF & _
                               "Current group size is" & STR$(ThreadBatch)     & $CRLF & _
                               "Thread index " & STR$(StartThreadIndex) & " to " & _
                               STR$(StartThreadIndex + ThreadBatch - 1) & " done..."
                             END IF
      CASE %WAIT_ABANDONED_0
        CON.STDOUT "WAIT_ABANDONED_0"
      CASE %WAIT_TIMEOUT
        CON.STDOUT "WAIT_TIMEOUT"
      CASE %WAIT_FAILED
        CON.STDOUT WinError$(LastError)
      CASE ELSE
        CON.STDOUT WinError$(LastError)
    END SELECT
    '
    StartThreadIndex += %MAXIMUM_WAIT_OBJECTS
    ThreadToWaitFor  -= %MAXIMUM_WAIT_OBJECTS
  LOOP WHILE ThreadToWaitFor > 0
  '
END FUNCTION
'
FUNCTION WinError$(BYVAL ErrorIndex AS LONG) AS STRING
 LOCAL zBuffer AS ASCIIZ * 1024

 FormatMessage(%FORMAT_MESSAGE_FROM_SYSTEM, BYVAL %NULL, ErrorIndex, %NULL, ZBuffer, SIZEOF(ZBuffer), BYVAL %NULL)
 REPLACE $CRLF WITH $SPC IN zBuffer
 FUNCTION = "Error" & STR$(ErrorIndex) & ": " & zBuffer

END FUNCTION
'
THREAD FUNCTION funReadArray(BYVAL pType AS udtSearchCriteria PTR) AS LONG
' search the array for data
  LOCAL TP AS udtSearchCriteria ' set up a local type
  TP = @pType                   ' copy the parameters to a local copy
  '
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngR = TP.lngStart TO TP.lngEnd
    IF PARSE$(a_strWork(lngR),$TAB, TP.lngColumn) = _
              TRIM$(TP.strCriteria) THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  CON.STDOUT TP.strCriteria & " = " & FORMAT$(lngCount)
  CON.STDOUT ""
  '
END FUNCTION
