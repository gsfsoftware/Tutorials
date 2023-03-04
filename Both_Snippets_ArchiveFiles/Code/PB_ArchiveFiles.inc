' PB_ArchiveFiles.inc
'
' index to routines in this library
'
%ArrayBlock = 500  ' size of blocks in array used to hold filenames
'
'
FUNCTION funArchiveFiles(strFolder AS STRING, _
                         strAction AS STRING, _
                         strLogFile AS STRING, _
                         strWildCard AS STRING, _
                         strTimePeriod AS STRING, _
                         lngUnits AS LONG, _
                         strError AS STRING) AS LONG
' archive files
  DIM a_strFiles() AS DIRDATA
  '
  ' ensure no trailing \
  strFolder = RTRIM$(strFolder,"\")
  '
  ' first check for errors
  IF ISFALSE ISFOLDER(strFolder) THEN
    strError = "Folder '" & strFolder & "' does not exist"
    EXIT FUNCTION
  END IF
  '
  SELECT CASE UCASE$(strAction)
    CASE "LOG","DELETE"
    ' log only
      IF strLogFile = "" THEN
        strError = "Unable to log without a log file path & name"
        EXIT FUNCTION
      END IF
      '
    CASE ELSE
      strError = "Action '" & strAction & "' is unsupported"
      FUNCTION = %FALSE
      EXIT FUNCTION
  END SELECT
  '
  IF strWildCard = "" THEN
    strError = "No wildcard specified"
    EXIT FUNCTION
  END IF
  '
  SELECT CASE UCASE$(strTimeperiod)
    CASE "DAYS", "MINS" , "HOURS"
    CASE ELSE
      strError = "'" & strTimeperiod & "' is not a supported time period"
      EXIT FUNCTION
  END SELECT
  '
  ' all inputs now validated
  IF ISTRUE funScanfolder(strFolder, _
                          strWildCard, _
                          a_strFiles(), _
                          strError) THEN
  ' a_strFiles() now contains all files in folder
    IF ISTRUE funTrimFileList(a_strFiles(), _
                              strTimeperiod, _
                              lngUnits, _
                              strError) THEN
                              '
      IF ISTRUE funLogOrDelete(a_strFiles(), _
                               strFolder, _
                               strAction, _
                               strLogFile, _
                               strTimeperiod, _
                               lngUnits, _
                               strError) THEN
        FUNCTION = %TRUE
        '
      ELSE
      ' some error occurred
        funLog("Unable to log or delete")
        EXIT FUNCTION
      END IF
      '
    ELSE
    ' some error occurred
      funLog("Unable to trim file list")
      EXIT FUNCTION
    END IF
  '
  ELSE
    funLog("Unable to scan folder")
    EXIT FUNCTION
  END IF
  '
END FUNCTION
'
FUNCTION funScanfolder(strFolder AS STRING, _
                       strWildCard AS STRING, _
                       a_strFiles() AS DIRDATA, _
                       strError AS STRING) AS LONG
' scan the folder for files matching wildcard
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngMaxArray AS LONG
  '
  REDIM a_strFiles(1 TO %ArrayBlock) AS DIRDATA
  '
  lngR = 1  ' start at beginning of array
  '
  strFilename = DIR$(strFolder & "\" & strWildCard, _
                     ONLY %NORMAL TO a_strFiles(lngR))
  WHILE LEN(strFilename)
  ' loop until the filename is blank
    INCR lngR  ' advance the counter
    '
    IF lngR > lngMaxArray THEN
    ' if count is greater than space left in array
    ' make the array bigger
      lngMaxArray = lngMaxArray + %ArrayBlock
      REDIM PRESERVE a_strFiles(1 TO lngMaxArray) AS DIRDATA
    END IF
    ' attempt to store the next matching file
    strFilename = DIR$(NEXT, TO a_strFiles(lngR))
    '
  WEND
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funTrimFileList(a_strFiles() AS DIRDATA, _
                         strTimeperiod AS STRING, _
                         lngUnits AS LONG, _
                         strError AS STRING) AS LONG
' trim the array of files not matching timeperiod
  LOCAL ptToday AS IPOWERTIME
  LOCAL ptFile AS IPOWERTIME
  LOCAL BlankValue AS DIRDATA
  LOCAL lngR AS LONG
  LOCAL lngCalcUnits AS LONG
  LOCAL lngSign AS LONG
  '
  BlankValue.FileName = "" ' set up blank entry
  '
  LET ptToday = CLASS "PowerTime"
  LET ptFile = CLASS "Powertime"
  '
  ptToday.Now  ' pick up current date/time
  '
  FOR lngR = 1 TO UBOUND(a_strFiles)
    ptFile.filetime = a_strFiles(lngR).LastWriteTime
    '
    SELECT CASE UCASE$(strTimeperiod)
      CASE "MINS"
        ptToday.TimeDiff(ptFile, lngSign, BYVAL 0, BYVAL 0,lngCalcUnits)
      CASE "HOURS"
        ptToday.TimeDiff(ptFile, lngSign, BYVAL 0, lngCalcUnits,BYVAL 0)
      CASE "DAYS"
        ptToday.TimeDiff(ptFile, lngSign, lngCalcUnits, BYVAL 0,BYVAL 0)
    END SELECT
    '
    IF lngSign = -1 THEN
    ' future data time discovered?
      strError = "Future date/time discovered in " &  _
                 TRIM$(a_strFiles(lngR).filename)
      EXIT FUNCTION
      '
    END IF
    '
    IF lngCalcUnits <= lngUnits THEN
    ' file is newer than expected
    ' file is not to be logged/deleted
      a_strFiles(lngR) = BlankValue ' blank out the record
    '
    END IF
    '
  NEXT lngR
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLogOrDelete(a_strFiles() AS DIRDATA, _
                        strFolder AS STRING, _
                        strAction AS STRING, _
                        strLogFile AS STRING, _
                        strTimePeriod AS STRING, _
                        lngUnits AS LONG, _
                        strError AS STRING) AS LONG
' log or delete the remaining files
  LOCAL lngR AS LONG
  LOCAL lngFile AS LONG
  LOCAL strFilename AS STRING
  '
  TRY
    lngFile = FREEFILE
    OPEN strLogFile FOR OUTPUT AS #lngFile
    '
    PRINT #lngFile, "List of files in -> " & strFolder
    PRINT #lngFile, "Which are older than " & FORMAT$(lngUnits) & _
                    " " & strTimePeriod
    '
    FOR lngR = 1 TO UBOUND(a_strFiles)
      strFilename = TRIM$(a_strFiles(lngR).FileName)
      IF strFilename <> "" THEN
      ' valid file
        SELECT CASE UCASE$(strAction)
          CASE "LOG"
          ' log only
            PRINT #lngFile, strFilename
          CASE "DELETE"
          ' delete the file
            TRY
              KILL strFolder & "\" & strFilename
              PRINT #lngFile, strFilename & " - Deleted"
            CATCH
              PRINT #lngFile, strFilename & " - Unable to delete - " & ERROR$
            FINALLY
            END TRY
            '
        END SELECT
        '
            '
      END IF
      '
    NEXT lngR
    '
    FUNCTION = %TRUE
    '
  CATCH
  ' pick up the error
    strError = "An error has occurred = " & ERROR$
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
