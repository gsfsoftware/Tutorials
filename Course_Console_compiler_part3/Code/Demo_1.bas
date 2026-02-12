#COMPILE EXE
#DIM ALL

'#console off
#INCLUDE "Win32api.inc"
#INCLUDE "PB_CommonConsoleFunctions.inc"
'
%Date = 0  ' used for elements
%Day  = 1  ' in array
'
%Max_days = 90 ' max days to process
'
FUNCTION PBMAIN () AS LONG
  '
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
  LOCAL strResult AS STRING     ' string to report result
  LOCAL strDate AS STRING       ' used for start date
  LOCAL strOutputFile AS STRING ' name/path to output file
  '
  strDate = DATE$           ' set to todays date in MM/dd/yyyy
                            ' format
  strOutputFile = "90 Day list.csv"
  '
  '
  ' run the process
  IF ISTRUE funProcess(strDate, strOutputFile) THEN
    strResult = "Processing Successful "
  ELSE
    strResult = "Processing unsuccessful "
  END IF
  '
  CON.PRINT strResult
  '
  funExitApp(8)
  '
  funAppendToAFile(strLog, _
                   "App ended " & TIME$, _
                   strError)
  '
END FUNCTION
'
FUNCTION funProcess(strDate AS STRING, _
                    strOutputFile AS STRING) AS LONG
' run the main processing
  CON.CAPTION$= "File Production"
  ' set colour to be brown
  CON.COLOR 6,0
  ' set 30 rows by 60 columns
  CON.SCREEN = 30,60
  '
  CON.PRINT "Processing"
  '
  ' output file of last 90 days
  DIM a_strDays(%Max_days,1) AS STRING
  '
  '
  LOCAL lngYear, lngMonth, lngDay AS LONG
  '
  ' populate date variables
  lngYear  = VAL(RIGHT$(strDate,4))
  lngMonth = VAL(LEFT$(strDate,2))
  lngDay   = VAL(MID$(strDate,4,2))
  '
  ' prepare date class
  LOCAL ipDate AS IPOWERTIME
  LET ipDate = CLASS "PowerTime
  ' set the date
  ipDate.NewDate(lngYear,lngMonth,lngDay)
  '
  ' prepare to step back 90 days
  LOCAL lngD AS LONG
  '
  WHILE lngD < UBOUND(a_strDays,1)
  'for lngD = 1 to 90
    ' step back a day
    ipDate.AddDays(-1)
    '
    ' keep only weekdays
    SELECT CASE ipDate.DayOfWeekString
      CASE "Sunday","Saturday"
        ITERATE
      CASE ELSE
        INCR lngD
    END SELECT
    '
    ' populate the array with data
    a_strDays(lngD,%Date) = ipDate.DateString
    a_strDays(lngD,%Day)  = ipDate.DayOfWeekString
    '
   'next lngD
   WEND
  '
  LOCAL lngFileOut AS LONG  ' output file handle
  lngFileOut = FREEFILE     ' assign a handle
  '
  ' output the array to file
  TRY
    OPEN strOutputFile FOR OUTPUT AS #lngFileOut
    'print #lngFileOut,a_strDays()
    ' print out the headers
    PRINT #lngFileOut,$DQ & "Date" & $QCQ;
    PRINT #lngFileOut,"Day of Week" & $DQ
    '
    FOR lngD = 1 TO UBOUND(a_strDays,1)
    ' output each row of data in CSV format
      PRINT #lngFileOut,$DQ & a_strDays(lngD,%Date) & $QCQ;
      PRINT #lngFileOut,a_strDays(lngD,%Day) & $DQ
    NEXT lngD
    FUNCTION = %TRUE
    '
  CATCH
  ' return false if output errors
    FUNCTION = %FALSE
  FINALLY
  ' ensure to close the file
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
