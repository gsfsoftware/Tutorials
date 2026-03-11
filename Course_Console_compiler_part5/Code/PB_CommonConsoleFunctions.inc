' PB_CommonConsoleFunctions.inc

FUNCTION funExitApp(lngDelay AS LONG) AS LONG
' wait and exit the app
  LOCAL lngW AS LONG
  '
  CON.PRINT "Exiting Application ";
  FOR lngW = 1 TO lngDelay
    CON.PRINT ".";
    SLEEP 1000
  NEXT lngW
  '
END FUNCTION
'
FUNCTION funAppendToAFile(strFilePathToAddTo AS STRING, _
                          strData AS STRING, _
                          o_strError AS STRING) AS LONG
' append strData to the file if it exists
' or create a new one if it doesn't
  LOCAL lngFile AS LONG
  '
  lngFile = FREEFILE
  TRY
   IF ISTRUE ISFILE(strFilePathToAddTo) THEN
      OPEN strFilePathToAddTo FOR APPEND LOCK SHARED AS #lngFile
    ELSE
      OPEN strFilePathToAddTo FOR OUTPUT AS #lngFile
    END IF
    '
    PRINT #lngFile, strData
    '
    FUNCTION = %TRUE
  CATCH
    o_strError = ERROR$   ' trap error for debug purposes
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngfile
  END TRY
  '
END FUNCTION
