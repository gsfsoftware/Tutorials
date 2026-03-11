#COMPILE EXE
#DIM ALL
'
#TOOLS OFF

'#console off
#INCLUDE "Win32api.inc"
#INCLUDE "PB_CommonConsoleFunctions.inc"
'
#INCLUDE "Datefunctions.inc"   ' date functions library
'
$DATE_Format = "UK"  ' change to "US" for USA format
'
' fields in the Output day list
ENUM Output_Day
  Date    = 0  ' used for elements
  Day     = 1  ' in array
  Workers = 2  ' number of workers available
END ENUM
'
' fields in the holiday array
ENUM Holiday
  Employee = 1  ' employee id
  StaffName     ' employee name
  Date          ' holiday date
END ENUM
'
' field in the staff array
ENUM Staff
  Employee = 1  ' employee id
  StaffName     ' employee name
  StartDate     ' Start date
  EndDate       ' End date
END ENUM
'
' files to be processed
$OutputFile = "Output Day list.csv"
$Holidays   = "Holidays.csv"
$Staff      = "Staff.csv"
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
  ' wipe the output file
  TRY
    KILL $OutputFile
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
  strOutputFile = $OutputFile
  '
  '
  ' run the process
  IF ISTRUE funProcess(strDate, _
                       strOutputFile, _
                       strLog) THEN
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
  ' use profile command while developing to
  ' check for inefficient subroutines and functions
  'PROFILE "Profile.txt"
  '
END FUNCTION
'
FUNCTION funProcess(strDate AS STRING, _
                    strOutputFile AS STRING, _
                    strLog AS STRING) AS LONG
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
  DIM a_strDays(%Max_days,%Output_day.Workers) AS STRING
  '
  ' data store for holiday requests
  DIM a_strHolidays() AS STRING
  DIM a_strStaff() AS STRING
  '
  LOCAL strError AS STRING

  ' first load the holidays file
  IF ISTRUE funReadTheCSVFileIntoAnArray($Holidays, _
                                         a_strHolidays()) THEN
    CON.PRINT "Holidays Loaded"
    IF ISTRUE funReadTheCSVFileIntoAnArray($Staff, _
                                           a_strStaff()) THEN
      CON.PRINT "Staff loaded"
    ELSE
      strError = "Staff not loaded"
      CON.PRINT strError
      ' failure to load staff
      funAppendToAFile(strLog, _
                       "Unable to load staff data"  & TIME$, _
                       strError)
      EXIT FUNCTION
    END IF
  '
  ELSE
    CON.PRINT "Holidays not loaded"
    EXIT FUNCTION
  END IF
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
  ' prepare to step forward 90 days
  LOCAL lngD AS LONG
  '
  WHILE lngD < UBOUND(a_strDays,1)
  ' step forward a day
    ipDate.AddDays(1)
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
    a_strDays(lngD,%Output_day.Date) = ipDate.DateString
    a_strDays(lngD,%Output_day.Day)  = ipDate.DayOfWeekString
    a_strDays(lngD,%Output_day.Workers) = _
                   FORMAT$(funWorkersAvailable(ipDate.DateString, _
                           a_strHolidays(), _
                           a_strStaff()))
    '
   WEND
   '
  ' save entire array to disk - more efficient
  IF ISTRUE funSaveArray(strOutputFile,a_strDays(), _
                         strError) THEN
    CON.PRINT "File saved successfully"
    FUNCTION = %TRUE
  ELSE
    CON.PRINT "File unable to be saved " & strError
  END IF
  '
END FUNCTION
'
FUNCTION funTotalWorkersOnDate(BYREF a_strStaff() AS STRING, _
                               strDate AS STRING) AS LONG
' work out the total number of workers
' on that day
  LOCAL lngTotal AS LONG
  LOCAL strPeriodStart AS STRING ' used for start of employment
  LOCAL strPeriodEnd AS STRING   ' used for end of employment
  '
  LOCAL lngS AS LONG
  ' now count the workers
  FOR lngS = 1 TO UBOUND(a_strStaff)
    ' pick up staff start and end employment dates
    strPeriodStart = a_strStaff(lngS,%Staff.StartDate)
    strPeriodEnd   = a_strStaff(lngS,%Staff.EndDate)
    '
    IF strPeriodEnd = "" THEN
    ' no end date so still working on current?
      strPeriodEnd = strDate
    END IF
    '
    IF ISTRUE funIsFutureDate(strPeriodStart, _
                              strDate, _
                              $DATE_Format) THEN
    ' staff start date is in future of date we are processing
    ' so dont count this member of staff
      ITERATE FOR
      '
    END IF
    '
    ' check for past end dates
    IF ISTRUE funIsFutureDate(strDate, _
                              strPeriodEnd, _
                              $DATE_Format) THEN
    ' staff end date is before date we are processing
    ' so dont count this memebr of staff
      ITERATE FOR
    END IF
    '
    IF ISTRUE funDateInPeriod(strDate, _
                       strPeriodStart, _
                       strPeriodEnd, _
                       $DATE_Format) THEN
      INCR lngTotal
    END IF
    '
  NEXT lngS
  '
  FUNCTION = lngTotal
  '
END FUNCTION
'
FUNCTION funWorkersAvailable(strDate AS STRING, _
                             a_strHolidays() AS STRING, _
                             a_strStaff() AS STRING) AS LONG
' return number of workers available on this day
' by sweeping through the holidays list and
' reducing the total staff for each member of
' staff on holiday on the given day
'
' first get total staff on the date
  LOCAL lngTotalStaff AS LONG
  LOCAL strHoliday AS STRING
  '
  lngTotalStaff = funTotalWorkersOnDate(a_strStaff(), _
                                        strDate)
  '
  ' now reduce that number by those on holiday on that date
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_strHolidays)
    strHoliday = a_strHolidays(lngR,%Holiday.Date)
    IF strHoliday = strDate THEN
      DECR lngTotalStaff
    END IF
  NEXT lngR
  '
  FUNCTION = lngTotalStaff
  '
END FUNCTION
'
FUNCTION funSaveArray(strOutputFile AS STRING, _
                      BYREF a_strDays() AS STRING, _
                      strError AS STRING) AS LONG
                      '
  LOCAL lngFileOut AS LONG  ' output file handle
  LOCAL lngD AS LONG
  lngFileOut = FREEFILE     ' assign a handle
  '
  ' output the array to file
  TRY
    ERRCLEAR ' clear any existing errors
    OPEN strOutputFile FOR OUTPUT AS #lngFileOut
    ' print out the headers
    PRINT #lngFileOut,$DQ & "Date" & $QCQ;
    PRINT #lngFileOut,"Day of Week" & $QCQ;
    PRINT #lngFileOut,"Workers Available" & $DQ
    '
    FOR lngD = 1 TO UBOUND(a_strDays,1)
    ' output each row of data in CSV format
      PRINT #lngFileOut,$DQ & a_strDays(lngD,%Output_day.Date) & $QCQ;
      PRINT #lngFileOut,a_strDays(lngD,%Output_day.Day) & $QCQ;
      PRINT #lngFileOut,a_strDays(lngD,%Output_day.Workers) & $DQ
    NEXT lngD
    FUNCTION = %TRUE
    '
  CATCH
  ' return false if output errors
    strError = ERROR$(ERR) ' return the error string
    FUNCTION = %FALSE
  FINALLY
  ' ensure we close the file
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
'
FUNCTION funReadTheCSVFileIntoAnArray(strFilename AS STRING, _
                               BYREF a_strWork() AS STRING) AS LONG
' read a CSV file into a 2 dimensional array
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    DECR lngRecords ' reduce count by 1
    ' read the header line
    LINE INPUT #lngFile,strData
    '
    lngColumns = PARSECOUNT(strData,"")
    REDIM a_strWork(lngRecords ,lngColumns) AS STRING
    '
    FOR lngR = 0 TO lngRecords
      FOR lngC = 1 TO lngColumns
        a_strWork(lngR,lngC) = PARSE$(strData,"",lngC)
      NEXT lngC
      IF NOT EOF(#lngFile) THEN
        LINE INPUT #lngFile,strData
      END IF
    NEXT lngR
    '
    FUNCTION = %TRUE
  CATCH
    ' error occurred
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
'
END FUNCTION
