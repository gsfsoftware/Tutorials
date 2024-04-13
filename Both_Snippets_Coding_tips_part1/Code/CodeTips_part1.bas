#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' start the program off from a common template
' allowing you to have a common structure to applications
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
' data storage
GLOBAL a() AS STRING                ' storage for staff data
GLOBAL ga_strStaffData() AS STRING  ' storage for staff data
'
' array limits
%MaxStaff = 1000     ' set maximum number of array elements
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Tips",0,0,40,120)
  '
  funLog("Code Tips")
  '
  ' draft out the structure of what the application is going to do
  '
  ' check any preconditions for app to run
  ' e.g. only allow this app to run on Saturdays - otherwise quit
  IF ISFALSE funCheckDay("Saturday") THEN
  ' its not Saturday - so log and exit
    funLog("App exit as it's not Saturday")
    funWait()
    EXIT FUNCTION
  ELSE
  ' it's Saturday so we can continue
    funLog("Processing started " & TIME$ & " on " & DATE$)
  '
  END IF
  '
  ' work out what data will flow into this app
  ' and how it is stored
  ' redimension the staff array
  REDIM ga_strStaffData(1000) AS STRING
  REDIM ga_strStaffData(%MaxStaff) AS STRING
  REDIM ga_strStaffData(funGetMaxStaff) AS STRING
  '
  funGetStaffData()
  '
  ' make the function report success/failure
  IF ISFALSE funGetStaffData() THEN
  ' unable to get staff data
    funLog("Report loading error in log")
    funWait()
    EXIT FUNCTION
  END IF
  '
  funLog("Maximum staff = " & FORMAT$(UBOUND(ga_strStaffData)))
  '
  ' and what manipulations the app will perform
  '
  ' make the function report success/failure
  IF ISFALSE funAdjustStaffArray() THEN
  ' error occurred in manipulations?
    funLog("Report error in log")
    funWait()
    EXIT FUNCTION
  END IF
  '
  ' and what data the app outputs - and to where
  IF ISTRUE funSaveData() THEN
  ' data has been saved successfully
    funLog("Data saved successfully")
  ELSE
  ' error occurred in saving data
    funLog("Unable to save the data")
  END IF
  '
  ' applications will evolve - so document as you go
  '
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funAdjustStaffArray() AS LONG
' manipulate array and report %TRUE if
' everything worked
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGetStaffData() AS LONG
' return %TRUE if data loaded successfully
' load the data from some data source
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGetMaxStaff() AS LONG
' work out the maximum number of staff
' and return the count
  FUNCTION = 1000
  '
END FUNCTION
'
FUNCTION funCheckDay(strDayName AS STRING) AS LONG
' check to see if strDayName = todays day name
' return %TRUE if it is
  LOCAL ipDate AS IPOWERTIME
  LET ipDate = CLASS "PowerTime"
  '
  ipDate.Now  ' pick up current local date & time
  '
  ' test the day name of current date
  IF LCASE$(ipDate.DayOfWeekString) = LCASE$(strDayName) THEN
  ' day name matches
    FUNCTION = %TRUE
  ELSE
  ' day name does not match
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funSaveData() AS LONG
' return %TRUE if data saved successfully
' save the data back to the data source
  FUNCTION = %TRUE
  '
END FUNCTION
