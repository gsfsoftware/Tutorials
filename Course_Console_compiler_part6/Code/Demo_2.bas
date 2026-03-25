 ' testing performance
#COMPILE EXE
#DIM ALL
'
#TOOLS OFF
'
#INCLUDE "Win32api.inc"
#INCLUDE "PB_CommonConsoleFunctions.inc"

%MAX_LOOP = 100    ' maximum number of loops
'
FUNCTION PBMAIN () AS LONG
'
  LOCAL strLog AS STRING        ' path/name of log
  LOCAL strError AS STRING      ' hold error message returned
  LOCAL strResult AS STRING     ' string to report result
  '
  strLog = EXE.NAME$ & "_log.txt"
  '
  TRY
  ' wipe log if it exists
    KILL strLog
  CATCH
  FINALLY
  END TRY
  '
  IF ISTRUE funAppendToAFile(strLog, _
                             "App started " & TIME$, _
                             strError) THEN
    CON.PRINT "Write to log successful"
  ELSE
    CON.PRINT "Unable to write to log -> " & strError
  END IF
  '
  IF ISTRUE funProcess(strLog) THEN
    strResult = "Processing Successful "
  ELSE
    strResult = "Processing unsuccessful "
  END IF
  '
  CON.PRINT strResult
  '
  funExitApp(3)
  '
  funAppendToAFile(strLog, _
                   "App ended " & TIME$, _
                   strError)
  '
END FUNCTION
'
FUNCTION funProcess(strLog AS STRING) AS LONG
' main processing
  LOCAL lngCount AS LONG     ' counter for loop
  LOCAL qTimer AS QUAD       ' quad timer for clock cycles
  LOCAL strError AS STRING   ' for any errors in saving
  LOCAL strTitle AS STRING   ' title for log message
  '
  strTitle = "No sleep"
  TIX qTimer                 ' start clock cycle count
  '
  FOR lngCount = 1 TO %MAX_LOOP

  NEXT lngCount
  '
  TIX END qTimer             ' end clock count
  '
  mLogMsg(strLog, strTitle, strError)
  ' -----
  strTitle = "1 ms sleep"
  TIX qTimer                 ' start clock cycle count
  '
  FOR lngCount = 1 TO %MAX_LOOP
    SLEEP 1 ' simulate 1 ms processing per loop
    CON.PRINT FORMAT$(lngCount)
  NEXT lngCount
  '
  TIX END qTimer
  '
  mLogMsg(strLog, strTitle, strError)
  '
  strTitle = "1 ms sleep only"
  TIX qTimer                 ' start clock cycle count
  '
  FOR lngCount = 1 TO %MAX_LOOP
    SLEEP 1 ' simulate 1 ms processing per loop
  NEXT lngCount
  '
  TIX END qTimer
  '
  mLogMsg(strLog, strTitle, strError)
   ' -----
  strTitle = "Print only"
  TIX qTimer                 ' start clock cycle count
  '
  FOR lngCount = 1 TO %MAX_LOOP
    CON.PRINT FORMAT$(lngCount)
  NEXT lngCount
  '
  TIX END qTimer
  '
  mLogMsg(strLog, strTitle, strError)
  ' -----
  strTitle = "Limited Print only"
  TIX qTimer                 ' start clock cycle count
  '
  FOR lngCount = 1 TO %MAX_LOOP
    IF lngCount MOD 10 = 0 THEN
    ' only print every 10
      CON.PRINT FORMAT$(lngCount)
    END IF
  NEXT lngCount
  '
  TIX END qTimer
  '
  mLogMsg(strLog, strTitle, strError)
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
MACRO mLogMsg(strLog, strTitle, strError)
' log the msg to file
' printing out the total number of clock
' cycles taken
  funAppendToAFile(strLog, _
                   strTitle & " Clock Cycles =  " & FORMAT$(qTimer,"#,"), _
                   strError)
END MACRO
