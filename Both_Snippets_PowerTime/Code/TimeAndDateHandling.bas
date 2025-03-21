#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "DateFunctions.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Templates",0,0,40,120)
  '
  funLog("Code Templates")
  '
  ' Date Validation
  ' ---------------
  funLog($CRLF & "Date Validation")
  funDateValidation()
  '
  ' Time periods
  ' ------------
  funLog($CRLF & "Time Periods")
  funTimePeriods()
  '
  ' File Times
  ' ----------
  funLog($CRLF & "File Times")
  funFileTimes(EXE.PATH$ & "TimeAndDateHandling.bas")
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funFileTimes(strFilePath AS STRING) AS LONG
' report on file write times
'
  LOCAL ptFile AS IPOWERTIME
  LET ptFile = CLASS "Powertime"
  '
  LOCAL ptNow AS IPOWERTIME
  LET ptNow = CLASS "Powertime"
  '
  LOCAL uDirData AS DIRDATA       ' UDT with file data
  LOCAL strFilename AS STRING     ' file name found
  LOCAL stmFileDate AS SystemTime ' System time variable
  '
  LOCAL lngSign AS LONG           ' variable that can be
  LOCAL lngDays AS LONG           ' used in the TimeDiff
  LOCAL lngHours AS LONG
  LOCAL lngMinutes AS LONG
  LOCAL lngSeconds AS LONG
  '
  strFilename = DIR$(strFilePath, _
                     ONLY %NORMAL TO uDirData)
                     '
  IF strFileName <> "" THEN
  ' convert to local system time
    FileTimeToSystemTime(BYVAL VARPTR(uDirData.LastWriteTime), _
                         stmFileDate)
                         '
    ' populate the date and time for the file in
    ' Powertime object
    ptFile.NewDate(stmFileDate.wYear, _
                   stmFileDate.wMonth, _
                   stmFileDate.wDay)
                   '
    ptFile.NewTime(stmFileDate.wHour, _
                   stmFileDate.wMinute, _
                   stmFileDate.wSecond)
                   '
    ptNow.Now  ' set date & time to NOW
    '
    ' work out the differnce
    ptNow.TimeDiff (ptFile, lngSign, BYVAL 0, _
                    BYVAL 0, BYVAL 0, _
                    lngSeconds)
                    '
    ' ensure sign is added to time difference
    lngSeconds = lngSeconds * lngSign
    '
    funLog(strFilePath & " found")
    funLog("File is " & FORMAT$(lngSeconds) & " seconds old")
    '
  END IF
'
END FUNCTION
'
FUNCTION funTimePeriods() AS LONG
' report on time periods
' prep the current date/time
  LOCAL ptDateCalc AS IPOWERTIME
  LET ptDateCalc = CLASS "PowerTime"
  '
  ptDateCalc.Now   ' set to now
  '
  funLog("Now = " & ptDateCalc.DayOfWeekString  & " " & _
                    ptDateCalc.DateString  & " " & _
                    ptDateCalc.TimeString24)
                    '
  ' prep the future date/time
  LOCAL ptFutureDate AS IPOWERTIME
  LET ptFutureDate = CLASS "PowerTime"
  '
  ptFutureDate.Now
  '
  ' add on 4 hours
  ptFutureDate.AddHours(4)
  '
  funLog("Future = " & ptFutureDate.DayOfWeekString  & " " & _
                       ptFutureDate.DateString  & " " & _
                       ptFutureDate.TimeString24)
                       '
  ' prep the past date/time
  LOCAL ptPastDate AS IPOWERTIME
  LET ptPastDate = CLASS "PowerTime"
  '
  ptPastDate.Now
  '
  ' take off 4 days
  ptPastDate.AddDays(-4)
  funLog("Past = " & ptPastDate.DayOfWeekString  & " " & _
                     ptPastDate.DateString  & " " & _
                     ptPastDate.TimeString24)
                     '
END FUNCTION
'
FUNCTION funDateValidation() AS LONG
' validate a given date
  LOCAL strDate AS STRING
  strDate = "29/02/2025"
  strDate = "29/03/2025"
  '
  ' is this date valid
  IF ISTRUE funIsDateValid_dd_MM_yyyy(strDate) THEN
    funLog(strDate & " UK Date is valid")
  ELSE
    funlog(strDate & " UK Date is NOT valid")
  END IF
  '
  strDate = "02/29/2025"
  strDate = "03/29/2025"
  IF ISTRUE funIsDateValid_MM_dd_yyyy(strDate) THEN
    funLog(strDate & " US Date is valid")
  ELSE
    funlog(strDate & " US Date is NOT valid")
  END IF
  '
END FUNCTION
