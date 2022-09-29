#COMPILE EXE    ' compile to an executable
#DIM ALL        ' ensure all variables are declared before use
#DEBUG ERROR ON ' catch any attempt to read beyond array
                ' boundaries
'
#TOOLS OFF      ' turn off integrated development tool
                ' code in compiled code
'
' include the windows 32bit API library
#INCLUDE "win32api.inc"
' include the common display library
#INCLUDE "CommonDisplay.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Arithmetic Operators",0,0,40,120)
  '
  funLog("Arithmetic Operators")
  '
  ? "Answer = ";5 * 4
  '
  LOCAL a,b,c AS LONG
  '
  LET a = 5   ' set their values
  LET b = 4
  '
  '
  LET c = a * b   ' multiply two variables together
                  ' and store the result in the third variable
  ? "Answer = ";c ' print the result out to screen
  '
  LOCAL lngDays AS LONG
  LOCAL lngNumberOfStaff AS LONG
  LOCAL lngPeopleDays AS LONG
  '
  lngDays = 5            ' number of work days in week
  lngNumberOfStaff = 4   ' number of staff in team
  '
  ' determine staff resource in days
  lngPeopleDays = lngDays * lngNumberOfStaff
  '
  PRINT "People Days = " ; lngPeopleDays
  '
  LOCAL lngWorkDay AS LONG
  lngWorkDay = 7  ' length of the workday
  '
  PRINT "Resource Hours = " ; lngPeopleDays * lngWorkDay
  '
  ' how much time will a task take as percentage of all resource
  LOCAL lngTaskHours AS LONG
  lngTaskHours = 11   ' set the number of hours needed for the task
  '
  LOCAL lngResourceHours AS LONG
  lngResourceHours = lngPeopleDays * lngWorkDay
  '
  PRINT "Task % of all resource = " ; _
                (lngTaskHours / lngResourceHours) * 100
  '
  PRINT "Task % of all resource = " ; _
        ROUND((lngTaskHours / lngResourceHours) * 100,2)
  '
  funWait()
  '
END FUNCTION
'
