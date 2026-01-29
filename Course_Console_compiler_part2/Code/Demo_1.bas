#COMPILE EXE
#DIM ALL

'#console off
#INCLUDE "Win32api.inc"
#INCLUDE "PB_CommonConsoleFunctions.inc"


FUNCTION PBMAIN () AS LONG
  ' sleep 10000
  CON.PRINT "Hello world2"
  '
  LOCAL strLog AS STRING
  LOCAL strError AS STRING
  '
  strLog = EXE.NAME$ & "_log.txt"
  '
  TRY
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
  funExitApp(8)
  '
  funAppendToAFile(strLog, _
                   "App ended " & TIME$, _
                   strError)
  '
END FUNCTION
'
